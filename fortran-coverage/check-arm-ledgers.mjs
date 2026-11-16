#!/usr/bin/env node
// Independent structural oracle: imports neither the producer nor its tables.
import assert from 'node:assert/strict';
import {readFileSync,writeFileSync,mkdtempSync,rmSync,existsSync,readdirSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {resolve,join,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {tmpdir} from 'node:os';
const sha=b=>createHash('sha256').update(b).digest('hex');
const demand=(p,e)=>assert(p,e);
const run=(exe,args,diagnostic='ORACLE_COMMAND_FAILED')=>{const r=spawnSync(exe,args,{maxBuffer:8*1024*1024,env:{...process.env,LC_ALL:'C',GIT_NO_REPLACE_OBJECTS:'1'}});demand(!r.error&&r.status===0,diagnostic+' '+exe+' '+args.join(' '));return r.stdout;};
const unc=s=>s.replace(/\\(\\|t|n)/g,(_,c)=>({'\\':'\\',t:'\t',n:'\n'}[c]));
const tsv=s=>s.trimEnd().split('\n').map(l=>l.split('\t').map(unc));
const originalCommit='0655e12c0e19b3dde360ed097ee88ba7b2c6d060';
const specimens=[
 ['softfp','examples/r-lm-native-armv7-a32/softfp-execution/call_r_qr.armv7-softfp','bfb8e71c45d914fa698dfb2e6371f2c391392dde72ce8e5cf0fc5e6716759170','examples/r-lm-native-armv7-a32/softfp-execution/linked-executable.softfp.disasm.txt','6ea0be8aca6fa3d140a54ea5870071a0cf787e27c69815f504be163f68583d16','GNU_LINUX_EABI_BASE_SOFTFP',2005,49,4],
 ['hardfp','examples/r-lm-native-armv7-linux-hardfp-linked/call_r_qr.armv7-hardfp','b9a4219bf33c136a3aa948a2dbe48c2f8daac9237a10bcf53cd89b3ed0eaf2dd','examples/r-lm-native-armv7-linux-hardfp-linked/linked-executable.armv7-hardfp.disasm.txt','fc0778ed8cada3d8751188784d1d4786bab7be6a58c33fab3993d2f2b5bb1ee7','GNU_LINUX_EABI_VFP_HARDFP',1437,49,2]
];
function gitSource(repo,commit,path){return run('git',['-C',repo,'cat-file','blob',commit+':'+path],'MISSING_SOURCE_EVIDENCE');}
function expectedSources(repo){
 const result=[],temp=mkdtempSync(join(tmpdir(),'aici-arm-ledger-'));
 try{for(const [name,bpath,bhash,lpath,lhash,abi,ni,nd,ng]of specimens){
  const b=gitSource(repo,originalCommit,bpath),l=gitSource(repo,originalCommit,lpath);demand(sha(b)===bhash&&sha(l)===lhash,'ORIGINAL_DIGEST_CHANGED');
  demand(readFileSync(join(repo,bpath)).equals(b)&&readFileSync(join(repo,lpath)).equals(l),'ARCHIVE_WORKTREE_CHANGED');
  const file=join(temp,name);writeFileSync(file,b);
  const header=run('readelf',['-hW',file]).toString(),attrs=run('readelf',['-AW',file]).toString();
  demand(header.includes('Machine:                           ARM')&&header.includes('little endian'),'SOURCE_MACHINE');
  demand(name==='hardfp'?attrs.includes('Tag_ABI_VFP_args: VFP registers')&&header.includes('hard-float ABI'):!attrs.includes('Tag_ABI_VFP_args: VFP registers')&&header.includes('soft-float ABI'),'ABI_EVIDENCE');
  const sections=[];for(const line of run('readelf',['-SW',file]).toString().split('\n')){const m=/^\s*\[\s*(\d+)\]\s+(\S+)\s+(\S+)\s+([0-9a-f]+)\s+([0-9a-f]+)\s+([0-9a-f]+)\s+([0-9a-f]+)\s*(.*?)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/.exec(line);if(m)sections.push({index:Number(m[1]),name:m[2],address:parseInt(m[4],16),offset:parseInt(m[5],16),size:parseInt(m[6],16),flags:m[8]});}
  const mapping=[];for(const line of run('readelf',['-sW',file]).toString().split('\n')){const x=line.trim().split(/\s+/);if(/^\d+:$/.test(x[0])&&/^\$[atd](?:\.|$)/.test(x[7]||'')&&/^\d+$/.test(x[6]))mapping.push({section:Number(x[6]),address:parseInt(x[1],16),mode:{a:'A32',t:'T32',d:'DATA'}[x[7][1]]});}
  const mode=(s,a)=>{const ms=mapping.filter(m=>m.section===s.index&&m.address<=a).sort((x,y)=>y.address-x.address);demand(ms.length,'MISSING_MAPPING_SYMBOL');return ms[0].mode;};
  const rows=[];let section,symbol;
  for(const [i,line]of l.toString().split('\n').entries()){
   const head=/^Disassembly of section (.+):$/.exec(line);if(head){section=sections.find(s=>s.name===head[1]);demand(section,'MISSING_EXECUTABLE_SECTION');continue;}
   const sym=/^[0-9a-f]+ <(.+)>:$/.exec(line);if(sym){symbol=sym[1];continue;}
   const cols=line.split('\t');if(/^\s*[0-9a-f]+:$/.test(cols[0]||'')){
    demand(section,'SECTION_NOT_SET');const address=parseInt(cols[0],16),words=(cols[1]||'').trim().split(/\s+/);demand(words.every(w=>/^(?:[0-9a-f]{4}|[0-9a-f]{8})$/.test(w)),'NATIVE_ENCODING');
    const bytes=words.map(w=>w.match(/../g).reverse().join('')).join(''),assembly=cols.slice(2).join('\t').trim(),isa=mode(section,address),width=bytes.length/2,offset=section.offset+address-section.address;
    demand(b.subarray(offset,offset+width).toString('hex')===bytes,'SOURCE_LISTING_BYTE_MISMATCH');demand(mode(section,address+width-1)===isa,'CROSSED_MAPPING_BOUNDARY');
    const kind=isa==='DATA'?'DATA':'INSTRUCTION';demand(assembly.startsWith('.')===(kind==='DATA'),'SOURCE_DATA_CLASSIFICATION');
    if(isa==='A32')demand(width===4,'SOURCE_A32_WIDTH');if(isa==='T32'){const prefix=parseInt(words[0],16)&0xf800;demand(width===(prefix>=0xe800?4:2),'SOURCE_T32_WIDTH');}
    rows.push({kind,section:section.name,address,offset,bytes,isa,assembly,symbol,line:i+1,ordinal:rows.length+1});continue;
   }
   demand(/^\s*$|^\s*\.\.\.\s*$|file format/.test(line),'UNPARSED_NATIVE_SOURCE_LINE '+(i+1));
  }
  const gaps=[];for(const s of sections.filter(s=>s.flags.includes('X')&&s.size)){let end=s.address;for(const r of rows.filter(r=>r.section===s.name)){demand(r.address>=end,'NATIVE_OVERLAP_OR_ORDER');if(r.address>end)gap(end,r.address);end=r.address+r.bytes.length/2;}if(end<s.address+s.size)gap(end,s.address+s.size);function gap(a,z){demand(mode(s,a)==='DATA'&&mode(s,z-1)==='DATA','UNDECODED_GAP_REQUIRES_NEW_SCOPE');const offset=s.offset+a-s.address;gaps.push({kind:'GAP',section:s.name,address:a,offset,bytes:b.subarray(offset,offset+z-a).toString('hex'),isa:'DATA',assembly:'UNPRINTED_CAPTURED_BYTES',symbol:'UNPRINTED_RANGE',line:'NONE_SUPPRESSED_RANGE'});}}
  const all=[...rows,...gaps].sort((a,b)=>a.offset-b.offset);for(const r of all)r.id=r.kind==='GAP'?lhash+':gap:'+r.section+':'+r.address:lhash+':'+r.ordinal;
  demand(rows.filter(r=>r.kind==='INSTRUCTION').length===ni&&rows.filter(r=>r.kind==='DATA').length===nd&&gaps.length===ng,'SOURCE_COUNTS');
  const relocs=[];let relsection='';for(const line of run('readelf',['-rW',file]).toString().split('\n')){const h=/^Relocation section '([^']+)'/.exec(line);if(h){relsection=h[1];continue;}const m=/^\s*([0-9a-f]{8})\s+([0-9a-f]{8})\s+(R_\S+)/.exec(line);if(m)relocs.push([bhash,relsection,parseInt(m[1],16),Number(BigInt('0x'+m[2])&255n)]);}
  result.push({name,bhash,lhash,abi,all,relocs,ni,nd,ng});
 }}finally{rmSync(temp,{recursive:true,force:true});}
 return result;
}
function candidate(dir){const names=['softfp.instructions.english','hardfp.instructions.english','crosswalk.tsv','ranges.tsv','summary.tsv','operation-catalogue.tsv'];demand(readdirSync(dir).sort().join('|')===names.sort().join('|'),'UNEXPECTED_OR_MISSING_OUTPUT_FILE');return new Map(names.map(n=>[n,readFileSync(join(dir,n),'utf8')]));}
function entries(text){const matches=[...text.matchAll(/^(INSTRUCTION|DATA|GAP) (\d+) \| (\S+) \| 0x([0-9a-f]+) \| ([0-9a-f]+) \| (A32|T32|DATA) \| (.+)$/gm)];let line=1,previous=0;return matches.map((m,i)=>{line+=text.slice(previous,m.index).split('\n').length-1;previous=m.index;return {kind:m[1],number:Number(m[2]),section:m[3],address:parseInt(m[4],16),bytes:m[5],isa:m[6],assembly:m[7],line,body:text.slice(m.index+m[0].length,matches[i+1]?.index??text.length)};});}
const field=(r,key)=>r.body.split('\n').find(l=>l.startsWith('  '+key+': '))?.slice(key.length+4);
function check(expected,files,relocations,manifest){
 const expectedManifest=specimens.map(([n,b,bh,l,lh,a,ni,nd,ng])=>[n,originalCommit,b,bh,l,lh,a,String(ni),String(nd),String(ng)]);assert.deepEqual(manifest.slice(1),expectedManifest,'SPECIMEN_SCOPE_OR_ABI_CHANGED');
 const cross=tsv(files.get('crosswalk.tsv')).slice(1),ranges=tsv(files.get('ranges.tsv')).slice(1),summary=tsv(files.get('summary.tsv')).slice(1),catalogue=tsv(files.get('operation-catalogue.tsv')).slice(1);let count=0,ci=0;const observed=new Map();
 demand(summary.length===expected.length,'SUMMARY_COUNT');
 for(const source of expected){
  const text=files.get(source.name+'.instructions.english'),es=entries(text),rs=source.all;
  demand(text.includes('Source commit: '+originalCommit)&&text.includes('Binary SHA-256: '+source.bhash)&&text.includes('Listing SHA-256: '+source.lhash)&&text.includes('ABI evidence: '+source.abi),'LEDGER_PROVENANCE');
  demand(text.includes('Meaning status: ANNOTATED_ONLY. Complete effects: UNVERIFIED.'),'LEDGER_HEADER_OVERCLAIM');
  demand(es.length===rs.length,'DROPPED_OR_DUPLICATED_LEDGER_ENTRY');
  for(let i=0;i<rs.length;i++){
   const r=rs[i],e=es[i];demand(e.number===i+1&&e.address===r.address&&e.section===r.section,'REORDERED_LEDGER');demand(e.bytes===r.bytes,'ALTERED_LEDGER_BYTES');demand(e.kind===r.kind&&e.isa===r.isa,'DATA_OR_ISA_MISCLASSIFIED');demand(e.assembly===r.assembly,'ALTERED_LEDGER_ASSEMBLY');
   demand(field(e,'Evidence record')===r.id&&field(e,'Original symbol')===r.symbol&&field(e,'Native listing line')===String(r.line),'NATIVE_LINK_LOST');
   const c=cross[ci],g=ranges[ci];demand(c&&g,'CROSSWALK_OR_RANGE_MISSING');
   assert.deepEqual(c.slice(0,11),[r.id,source.name,r.kind,r.section,String(r.address),String(r.offset),r.bytes,r.isa,String(r.bytes.length/2),source.name+'.instructions.english',String(e.line)],'CROSSWALK_MISMATCH');
   assert.deepEqual(g,[source.name,r.section,String(r.address),String(r.address+r.bytes.length/2),String(r.offset),String(r.bytes.length/2),r.kind,r.isa,r.bytes,r.id],'EXECUTABLE_RANGE_MISMATCH');ci++;
   if(r.kind==='INSTRUCTION'){
    count++;const mm=/^(\S+)\s*(.*)$/s.exec(r.assembly),effect=field(e,'Preliminary effect'),title=field(e,'Preliminary operation');
    demand(title?.length>8&&effect?.length>30&&field(e,'Exact operands')===(mm[2]||'(none)'),'MISSING_OR_UNBOUND_PRELIMINARY_DESCRIPTION');
    demand(field(e,'Meaning status')==='ANNOTATED_ONLY; complete effects UNVERIFIED.'&&c[12]==='ANNOTATED_ONLY'&&c[13]==='UNVERIFIED','UNVERIFIED_SEMANTICS_MARKED_COMPLETE');
    demand(field(e,'Sequential successor only')===`0x${(r.address+r.bytes.length/2).toString(16)} (${r.bytes.length/2} encoded bytes). Actual control and faults remain separate.`,'WRONG_INSTRUCTION_WIDTH_OR_SUCCESSOR');
    const predicate=field(e,'Predicate evidence');if(r.isa==='A32'){const code=parseInt(r.bytes.match(/../g).reverse().join(''),16)>>>28;demand(predicate?.startsWith(['EQ:','NE:','CS:','CC:','MI:','PL:','VS:','VC:','HI:','LS:','GE:','LT:','GT:','LE:','AL:','UNCONDITIONAL_ENCODING_SPACE'][code]),'WRONG_A32_PREDICATE');}else demand(predicate?.includes('ITSTATE')&&!predicate.includes('AL: unconditional'),'THUMB_CONTEXT_ERASED');
    const key=r.isa+'|'+mm[1],cat=catalogue.find(c=>c[0]===key);demand(cat&&cat[1]===c[11]&&cat[5]==='UNVERIFIED','OPERATION_CATALOGUE_MISMATCH');observed.set(key,(observed.get(key)||0)+1);
   }else demand(c[11]==='NONE'&&c[12]==='DATA_ONLY'&&c[13]==='UNVERIFIED'&&field(e,'Interpretation status')==='DATA_PAYLOAD_MEANING_UNVERIFIED.'&&!e.body.includes('Sequential successor only:'),'DATA_GRANTED_INSTRUCTION_SEMANTICS');
  }
  const s=summary.find(r=>r[0]===source.name);demand(s,'MISSING_SPECIMEN_SUMMARY');
  assert.deepEqual(s.slice(0,9),[source.name,String(source.ni),String(rs.filter(r=>r.isa==='A32').length),String(rs.filter(r=>r.isa==='T32').length),String(source.nd),String(source.ng),String(rs.filter(r=>r.kind==='GAP').reduce((n,r)=>n+r.bytes.length/2,0)),String(source.relocs.length),'ANNOTATED_ONLY'],'FALSE_OR_DOUBLE_COUNTED_TOTAL');
  demand(s[9]==='UNVERIFIED'&&s[10]==='UNKNOWN'&&s[11]==='UNKNOWN','SEMANTIC_LIBRARY_OR_LANGUAGE_OVERCLAIM');
  const reported=relocations.filter(r=>r[0]===source.bhash).map(r=>[r[0],r[1],Number(r[3]),Number(r[4])]);assert.deepEqual(reported,source.relocs,'MISSING_FROZEN_RELOCATION');
 }
 demand(cross.length===ci&&ranges.length===ci,'EXTRA_CROSSWALK_OR_RANGE');demand(catalogue.length===observed.size&&new Set(catalogue.map(c=>c[0])).size===catalogue.length,'EXTRA_OR_DUPLICATED_CATALOGUE_FORM');for(const c of catalogue)demand(Number(c[4])===observed.get(c[0]),'FALSE_CATALOGUE_TOTAL');
 return {instructions:count,data:expected.reduce((n,s)=>n+s.nd,0),gaps:expected.reduce((n,s)=>n+s.ng,0),ledgerEntries:ci,meaning:'ANNOTATED_ONLY',completeEffects:'UNVERIFIED',libraryClosure:'UNKNOWN',wholeFortran:'UNKNOWN'};
}
function negatives(expected,files,relocations,manifest,repo){
 const cases=[];const bad=(name,file,mutate,reason)=>{const fs=new Map(files);fs.set(file,mutate(fs.get(file)));let err='';try{check(expected,fs,relocations,manifest);}catch(e){err=e.message;}demand(err.includes(reason),'MUTANT_NOT_REJECTED '+name+' '+err);cases.push([name,'REJECTED',reason]);};
 const name='hardfp.instructions.english';
 const blocks=s=>{const starts=[...s.matchAll(/^(?:INSTRUCTION|DATA|GAP) \d+ \|/gm)].map(m=>m.index);return [s.slice(0,starts[0]),starts.map((start,i)=>s.slice(start,starts[i+1]??s.length))];};
 bad('dropped instruction',name,s=>{const [h,bs]=blocks(s);bs.splice(0,1);return h+bs.join('\n');},'DROPPED_OR_DUPLICATED_LEDGER_ENTRY');
 bad('duplicated instruction',name,s=>{const [h,bs]=blocks(s);bs.splice(0,0,bs[0]);return h+bs.join('\n');},'DROPPED_OR_DUPLICATED_LEDGER_ENTRY');
 bad('reordered instructions',name,s=>{const [h,bs]=blocks(s);[bs[0],bs[1]]=[bs[1],bs[0]];return h+bs.join('\n');},'REORDERED_LEDGER');
 bad('altered bytes',name,s=>s.replace('08402de9','00402de9'),'ALTERED_LEDGER_BYTES');
 bad('altered operands',name,s=>s.replace('push\t{r3, lr}','push\t{r4, lr}'),'ALTERED_LEDGER_ASSEMBLY');
 bad('data called instruction',name,s=>s.replace(/^DATA /m,'INSTRUCTION '),'DATA_OR_ISA_MISCLASSIFIED');
 bad('Thumb called A32',name,s=>s.replace(' | T32 | ',' | A32 | '),'DATA_OR_ISA_MISCLASSIFIED');
 bad('Thumb uses fixed four-byte successor',name,s=>s.replace('0x926 (2 encoded bytes)','0x928 (4 encoded bytes)'),'WRONG_INSTRUCTION_WIDTH_OR_SUCCESSOR');
 bad('dropped suppressed range',name,s=>{const [h,bs]=blocks(s);return h+bs.filter(b=>!b.startsWith('GAP ')).join('\n');},'DROPPED_OR_DUPLICATED_LEDGER_ENTRY');
 bad('erased Thumb context',name,s=>s.replace('ITSTATE_CONTEXT_UNKNOWN','AL: unconditional'),'THUMB_CONTEXT_ERASED');
 bad('wrong A32 predicate',name,s=>s.replace('Predicate evidence: AL:','Predicate evidence: NE:'),'WRONG_A32_PREDICATE');
 bad('meaning promoted complete',name,s=>s.replace('ANNOTATED_ONLY; complete effects UNVERIFIED.','VERIFIED; complete effects COMPLETE.'),'UNVERIFIED_SEMANTICS_MARKED_COMPLETE');
 bad('description missing',name,s=>s.replace(/^  Preliminary effect: .+\n/m,''),'MISSING_OR_UNBOUND_PRELIMINARY_DESCRIPTION');
 bad('crosswalk missing','crosswalk.tsv',s=>s.split('\n').filter((_,i)=>i!==1).join('\n'),'CROSSWALK_MISMATCH');
 bad('double-counted totals','summary.tsv',s=>s.replace('softfp\t2005','softfp\t4006'),'FALSE_OR_DOUBLE_COUNTED_TOTAL');
 bad('library closure overclaim','summary.tsv',s=>s.replace('\tUNKNOWN\tUNKNOWN','\tCOMPLETE\tUNKNOWN'),'SEMANTIC_LIBRARY_OR_LANGUAGE_OVERCLAIM');
 bad('whole Fortran overclaim','summary.tsv',s=>s.replace('\tUNKNOWN\tUNKNOWN','\tUNKNOWN\tCOMPLETE'),'SEMANTIC_LIBRARY_OR_LANGUAGE_OVERCLAIM');
 bad('header promotes meaning',name,s=>s.replace('Complete effects: UNVERIFIED.','Complete effects: VERIFIED.'),'LEDGER_HEADER_OVERCLAIM');
 bad('range missing','ranges.tsv',s=>s.split('\n').filter((_,i)=>i!==1).join('\n'),'EXECUTABLE_RANGE_MISMATCH');
 let err='';try{check(expected,files,relocations.filter(r=>r[0]!==specimens[0][2]),manifest);}catch(e){err=e.message;}demand(err.includes('MISSING_FROZEN_RELOCATION'),'RELOCATION_MUTANT_ACCEPTED');cases.push(['missing relocation','REJECTED','MISSING_FROZEN_RELOCATION']);
 err='';try{const m=manifest.map(r=>[...r]);m[1][6]=m[2][6];check(expected,files,relocations,m);}catch(e){err=e.message;}demand(err.includes('SPECIMEN_SCOPE_OR_ABI_CHANGED'),'ABI_MUTANT_ACCEPTED');cases.push(['ABI conflation','REJECTED','SPECIMEN_SCOPE_OR_ABI_CHANGED']);
 err='';try{gitSource(repo,'0'.repeat(40),specimens[0][1]);}catch(e){err=e.message;}demand(err.includes('MISSING_SOURCE_EVIDENCE'),'MISSING_SOURCE_WAS_INVENTED');cases.push(['unavailable original Git evidence','MISSING_EXPLICITLY','MISSING_SOURCE_EVIDENCE']);return cases;
}
const args=process.argv.slice(2),arg=(k,d)=>args.includes(k)?args[args.indexOf(k)+1]:d;demand(args.includes('--repository'),'EXPLICIT_REPOSITORY_REQUIRED');
const repo=resolve(arg('--repository')),dir=resolve(arg('--directory',join(repo,'coverage/fortran/arm-linked/generated'))),expected=expectedSources(repo),files=candidate(dir),relocations=tsv(readFileSync(join(repo,'coverage/fortran/generated/relocations.tsv'),'utf8')).slice(1),manifest=tsv(readFileSync(join(repo,'coverage/fortran/arm-linked/specimens.tsv'),'utf8'));
const result=check(expected,files,relocations,manifest),mutants=args.includes('--self-test')?negatives(expected,files,relocations,manifest,repo):[];
console.log('PASS independent linked ARM ledger accounting: '+JSON.stringify(result));for(const r of mutants)console.log(r.join('\t'));
if(args.includes('--receipt')){const dest=resolve(arg('--receipt'));demand(!existsSync(dest),'REFUSE_EXISTING_RECEIPT');const oracle=resolve(dirname(fileURLToPath(import.meta.url)),'..');demand(!run('git',['-C',repo,'status','--porcelain','--untracked-files=all','--','coverage/fortran/arm-linked','coverage/fortran/generated','examples/autogenerated/arm-linked-ledgers','.github/workflows/fortran-coverage.yml']).length,'DIRTY_LEAF_CANNOT_ISSUE_EXACT_HEAD_RECEIPT');demand(!run('git',['-C',oracle,'status','--porcelain','--','fortran-coverage/check-arm-ledgers.mjs']).length,'DIRTY_ORACLE_CANNOT_ISSUE_EXACT_HEAD_RECEIPT');const rows=[['result','PASS_STRUCTURAL_LEDGER_ACCOUNTING_ONLY'],['leaf_commit',run('git',['-C',repo,'rev-parse','HEAD']).toString().trim()],['ai_ci_commit',run('git',['-C',oracle,'rev-parse','HEAD']).toString().trim()],['oracle_source_sha256',sha(readFileSync(fileURLToPath(import.meta.url)))],['node',process.version],['readelf',run('readelf',['--version']).toString().split('\n')[0]],['negative_cases',mutants.length],['meaning','ANNOTATED_ONLY'],['complete_effects','UNVERIFIED'],['library_closure','UNKNOWN'],['whole_fortran','UNKNOWN'],['specimens_sha256',sha(readFileSync(join(repo,'coverage/fortran/arm-linked/specimens.tsv')))]];for(const [n,b]of [...files].sort())rows.push(['sha256:'+n,sha(b)]);writeFileSync(dest,'key\tvalue\n'+rows.map(r=>r.join('\t')).join('\n')+'\n');}
