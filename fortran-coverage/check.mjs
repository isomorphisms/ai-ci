#!/usr/bin/env node
import assert from 'node:assert/strict';
import {readFileSync,writeFileSync,mkdtempSync,rmSync,existsSync,readdirSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {join,resolve,dirname,basename} from 'node:path';
import {fileURLToPath} from 'node:url';
import {tmpdir} from 'node:os';
import {load_worktree_paths} from './worktree-paths.mjs';
const hash=b=>createHash('sha256').update(b).digest('hex');
const exec=(exe,args)=>{const r=spawnSync(exe,args,{encoding:null,maxBuffer:64*1024*1024,env:{...process.env,LC_ALL:'C',GIT_CONFIG_NOSYSTEM:'1',GIT_CONFIG_GLOBAL:'/dev/null',GIT_NO_REPLACE_OBJECTS:'1'}});assert(!r.error&&r.status===0,'ORACLE_COMMAND_FAILED '+exe+' '+r.stderr);return r.stdout;};
const unc=s=>s.replace(/\\(\\|t|r|n)/g,(_,c)=>({'\\':'\\',t:'\t',r:'\r',n:'\n'}[c]));
const parse=b=>b.toString('utf8').trimEnd().split('\n').map(l=>l.split('\t').map(unc));
function fail(ok,name){assert(ok,name);}
function loadExpected(repo,worktree_paths){
 const pins=parse(readFileSync(worktree_paths.path('coverage/fortran/source-heads.tsv'))).slice(1),byId=new Map(),occurrences=[];
 for(const p of pins){const commit=p[4];const raw=exec('git',['-c','core.quotepath=false','-C',repo,'ls-tree','-rz',commit]).toString('utf8');for(const entry of raw.split('\0').filter(Boolean)){const n=entry.indexOf('\t'),[mode,type,blob]=entry.slice(0,n).split(' '),path=entry.slice(n+1);fail(type==='blob','ORACLE_GIT_OBJECT_KIND');const b=exec('git',['-C',repo,'cat-file','blob',blob]),id=hash(b);occurrences.push([p[1],commit,path,mode,blob,id,String(b.length)]);if(!byId.has(id))byId.set(id,{b,id,path,commit,blob});}}
 const temporary=mkdtempSync(join(tmpdir(),'aici-fortran-'));const binaries=new Map();
 try{for(const a of byId.values())if(a.b.subarray(0,4).toString('hex')==='7f454c46'){
  const path=join(temporary,a.id);writeFileSync(path,a.b);const header=exec('readelf',['-hW',path]).toString('utf8');const machine=header.includes('Machine:                           ARM')?'ARM':header.includes('Advanced Micro Devices X86-64')?'X86':'UNKNOWN';fail(machine!=='UNKNOWN','ORACLE_MACHINE');
  const sectionText=exec('readelf',['-SW',path]).toString('utf8'),sections=[];
  for(const line of sectionText.split('\n')){const m=/^\s*\[\s*(\d+)\]\s+(\S+)\s+(\S+)\s+([0-9a-f]+)\s+([0-9a-f]+)\s+([0-9a-f]+)\s+([0-9a-f]+)\s*(.*?)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/.exec(line);if(m)sections.push({index:Number(m[1]),name:m[2],type:m[3],address:parseInt(m[4],16),offset:parseInt(m[5],16),size:parseInt(m[6],16),flags:m[8]});}
  fail(sections.length>0,'ORACLE_NO_SECTIONS');const symText=exec('readelf',['-sW',path]).toString('utf8'),mapping=[];
  for(const line of symText.split('\n')){const x=line.trim().split(/\s+/);if(/^\d+:$/.test(x[0])&&/^\$[atd](?:\.|$)/.test(x[7]||'')&&/^\d+$/.test(x[6]))mapping.push({address:parseInt(x[1],16),section:Number(x[6]),mode:{a:'A32',t:'T32',d:'DATA'}[x[7][1]]});}
  const relocText=exec('readelf',['-rW',path]).toString('utf8'),relocs=[];let relocationSection='';for(const line of relocText.split('\n')){const h=/^Relocation section '([^']+)'/.exec(line);if(h){relocationSection=h[1];continue;}const m=/^\s*([0-9a-f]{8,16})\s+([0-9a-f]{8,16})\s+(R_\S+)/.exec(line);if(m){const info=BigInt('0x'+m[2]);relocs.push([relocationSection,parseInt(m[1],16),Number(info&(machine==='ARM'?255n:0xffffffffn))]);}}
  binaries.set(a.id,{...a,machine,sections,mapping,relocs});
 }}finally{rmSync(temporary,{recursive:true,force:true});}
 return {byId,occurrences,binaries};
}
function nativeRows(text,binary){let section='',symbol='',previous;const out=[],relocs=[];
 for(const [i,line]of text.split('\n').entries()){
  if(line.startsWith('Disassembly of section ')){section=line.slice(23,-1);continue;}
  const sym=/^[0-9a-f]+ <(.+)>:$/.exec(line);if(sym){symbol=sym[1];continue;}
  const relocation=/^\s*([0-9a-f]+):\s+(R_\S+)\s+(.+)$/.exec(line);if(relocation){relocs.push([section,parseInt(relocation[1],16),relocation[2],relocation[3].trim(),i+1]);continue;}
  const columns=line.split('\t');if(!/^\s*[0-9a-f]+:$/.test(columns[0]||''))continue;
  const address=parseInt(columns[0],16),words=(columns[1]||'').trim().split(/\s+/);if(!words[0])continue;
  const bytes=binary.machine==='X86'?words.join(''):words.map(w=>w.match(/../g).reverse().join('')).join('');
  fail(/^(?:[0-9a-f]{2})+$/.test(bytes),'ORACLE_LISTING_HEX');const assembly=columns.slice(2).join('\t').trim();
  if(!assembly){fail(previous&&previous.address+previous.bytes.length/2===address,'ORACLE_CONTINUATION');previous.bytes+=bytes;continue;}
  const s=binary.sections.find(s=>s.name===section);fail(s,'ORACLE_LISTING_SECTION');let mode='x86-64';if(binary.machine==='ARM'){const maps=binary.mapping.filter(m=>m.section===s.index&&m.address<=address).sort((a,b)=>b.address-a.address);fail(maps.length,'ORACLE_MAPPING_MISSING');mode=maps[0].mode;}
  previous={section,address,bytes,assembly,mode,kind:mode==='DATA'?'DATA':'INSTRUCTION',line:i+1,symbol};out.push(previous);
 }return {out,relocs};
}
function readTables(dir){const out=new Map();for(const name of readdirSync(dir))if(name.endsWith('.tsv'))out.set(name,parse(readFileSync(join(dir,name))));return out;}
function check(expected,tables){
 const rows=n=>{fail(tables.has(n),'MISSING_TABLE '+n);return tables.get(n).slice(1);};const artifacts=rows('artifacts.tsv');fail(artifacts.length===expected.byId.size,'ARTIFACT_COUNT');fail(new Set(artifacts.map(r=>r[0])).size===artifacts.length,'DUPLICATE_ARTIFACT');for(const r of artifacts){const a=expected.byId.get(r[0]);fail(a&&String(a.b.length)===r[1],'ALTERED_ARTIFACT');}
 const occurrences=rows('occurrences.tsv');fail(occurrences.length===expected.occurrences.length,'SOURCE_OCCURRENCE_COUNT');for(let i=0;i<occurrences.length;i++)assert.deepEqual(occurrences[i].slice(0,7),expected.occurrences[i],'SOURCE_OCCURRENCE_MISMATCH');
 const ranges=rows('file-ranges.tsv'),sections=rows('sections.tsv'),relocations=rows('relocations.tsv');
 for(const [id,b]of expected.binaries){let end=0;const rr=ranges.filter(r=>r[0]===id);fail(rr.length,'MISSING_BINARY_PARTITION');for(const r of rr){fail(Number(r[1])===end&&Number(r[2])>end,'FILE_GAP_OR_OVERLAP');end=Number(r[2]);fail(hash(b.b.subarray(Number(r[1]),end))===r[5],'ALTERED_RANGE_BYTES');}fail(end===b.b.length,'SWALLOWED_FILE_GAP');for(const s of b.sections){const r=sections.find(r=>r[0]===id&&Number(r[1])===s.index);fail(r&&r[2]===s.name&&Number(r[5])===s.address&&Number(r[6])===s.offset&&Number(r[7])===s.size,'SECTION_MISMATCH');}const cr=relocations.filter(r=>r[0]===id);fail(cr.length===b.relocs.length,'MISSING_RELOCATION');for(let i=0;i<cr.length;i++)assert.deepEqual([cr[i][1],Number(cr[i][3]),Number(cr[i][4])],b.relocs[i],'RELOCATION_MISMATCH');}
 fail(relocations.length===[...expected.binaries.values()].reduce((n,b)=>n+b.relocs.length,0),'EXTRA_RELOCATION');
 const records=rows('records.tsv'),gaps=rows('listing-gaps.tsv'),printed=rows('printed-relocations.tsv'),seenListing=new Set();let sourceInstructions=0;
 for(const a of expected.byId.values())if(/\.disasm\.txt$/.test(a.path)){
  const candidate=records.filter(r=>r[1]===a.id);fail(candidate.length,'MISSING_LISTING');const binary=expected.binaries.get(candidate[0][2]);fail(binary,'LISTING_BINARY_MISSING');const original=nativeRows(a.b.toString('utf8'),binary);fail(candidate.length===original.out.length,'DROPPED_OR_DUPLICATED_INSTRUCTION');seenListing.add(a.id);
  for(let i=0;i<candidate.length;i++){const r=candidate[i],o=original.out[i];fail(Number(r[4])===i+1&&Number(r[6])===o.address&&r[3]===o.section,'REORDERED_INSTRUCTION');fail(r[8]===o.bytes,'ALTERED_INSTRUCTION_BYTES');fail(r[10]===o.mode&&r[11]===o.kind,'DATA_OR_ISA_MISCLASSIFIED');fail(r[13]===o.assembly,'ALTERED_OPERANDS');const s=binary.sections.find(s=>s.name===r[3]),offset=s.offset+o.address-s.address;fail(Number(r[7])===offset&&binary.b.subarray(offset,offset+o.bytes.length/2).toString('hex')===o.bytes,'BINARY_BYTE_MISMATCH');fail(r[17]==='SEMANTICS_UNVERIFIED','UNVERIFIED_SEMANTICS_COMPLETE');if(o.kind==='INSTRUCTION')sourceInstructions++;}
  const pr=printed.filter(r=>r[0]===a.id);fail(pr.length===original.relocs.length,'MISSING_PRINTED_RELOCATION');for(let i=0;i<pr.length;i++)assert.deepEqual([pr[i][2],Number(pr[i][3]),pr[i][4],pr[i][5],Number(pr[i][6])],original.relocs[i],'PRINTED_RELOCATION_MISMATCH');
  for(const s of binary.sections.filter(s=>s.flags.includes('X')&&s.size)){const intervals=[...candidate.filter(r=>r[3]===s.name).map(r=>[Number(r[6]),Number(r[6])+Number(r[9])]),...gaps.filter(g=>g[0]===a.id&&g[2]===s.name).map(g=>[Number(g[3]),Number(g[4])])].sort((a,b)=>a[0]-b[0]);let end=s.address;for(const range of intervals){fail(range[0]===end&&range[1]>end,'SWALLOWED_EXECUTABLE_GAP');end=range[1];}fail(end===s.address+s.size,'SWALLOWED_EXECUTABLE_GAP');}
 }
 const listedBinaryIds=new Set(records.map(r=>r[2]));for(const [id,b]of expected.binaries)if(!listedBinaryIds.has(id)){const expectedGaps=b.sections.filter(s=>s.flags.includes('X')&&s.size),reported=gaps.filter(g=>g[0]==='NO_LISTING'&&g[1]===id);fail(reported.length===expectedGaps.length,'UNLISTED_OBJECT_GAP_OMITTED');for(const s of expectedGaps)fail(reported.some(g=>g[2]===s.name&&Number(g[3])===s.address&&Number(g[4])===s.address+s.size),'UNLISTED_OBJECT_GAP_OMITTED');}
 fail(records.every(r=>seenListing.has(r[1])),'INVENTED_LISTING');fail(new Set(records.map(r=>r[0])).size===records.length,'DUPLICATE_RECORD_ID');
 const counts=new Map(rows('summary.tsv').map(r=>[r[0],r[1]]));fail(Number(counts.get('instruction_listing_records'))===sourceInstructions,'FALSE_INSTRUCTION_TOTAL');fail(counts.get('library_closure_denominator')==='UNKNOWN','FALSE_LIBRARY_COVERAGE');fail(counts.get('fortran_language_feature_denominator')==='UNKNOWN','FALSE_LANGUAGE_COVERAGE');fail(counts.get('fully_independently_verified_semantic_forms')==='0','UNVERIFIED_SEMANTICS_COMPLETE');
 const forms=rows('semantic-forms.tsv');fail(forms.every(r=>r[15]==='UNVERIFIED_COMPLETE_EFFECTS'),'UNVERIFIED_SEMANTICS_COMPLETE');fail(Number(counts.get('observed_instruction_forms'))===forms.length,'FORM_COUNT');
 const dependencies=rows('dependencies.tsv');fail(dependencies.every(r=>r[5]==='UNKNOWN'&&['NOT_CAPTURED_IN_THIS_ELF','SHARED_LIBRARY_FILE_NOT_ARCHIVED_BY_THIS_REFERENCE','LOADER_BYTES_NOT_IN_THIS_ELF'].includes(r[4])),'FALSE_LIBRARY_BODY_COVERAGE');
 const english=rows('english-crosswalk.tsv'),englishIds=new Set();for(const a of expected.byId.values())if(/\.instructions\.english$/.test(a.path)){const original=[...a.b.toString('utf8').matchAll(/^(INSTRUCTION|DATA) (\d+) \| 0x([0-9a-f]+) \| ([0-9a-f ]+) \| (.+)$/gm)],cr=english.filter(r=>r[0]===a.id);fail(cr.length===original.length,'MISSING_ENGLISH_ROW');englishIds.add(a.id);for(let i=0;i<cr.length;i++){const c=cr[i],o=original[i],r=records.find(r=>r[0]===c[3]);fail(r&&Number(c[6])===parseInt(o[3],16)&&c[4]===o[1],'ENGLISH_MAPPING_MISMATCH');const bytes=r[10]==='x86-64'?o[4].replaceAll(' ',''):o[4].trim().split(/\s+/).map(w=>w.match(/../g).reverse().join('')).join('');fail(bytes===r[8],'ENGLISH_BYTES_MISMATCH');fail(['ANNOTATED_ONLY','MISSING'].includes(c[8]),'UNVERIFIED_ENGLISH_COMPLETE');}}
 fail(english.every(r=>englishIds.has(r[0])),'INVENTED_ENGLISH_ARTIFACT');
 return {artifacts:artifacts.length,elf:expected.binaries.size,relocations:relocations.length,listings:seenListing.size,instructions:sourceInstructions,englishRows:english.length,semanticForms:forms.length,semanticAcceptance:'UNVERIFIED',libraryClosure:'UNKNOWN',languageCoverage:'UNKNOWN'};
}
function selfTest(expected,tables){const cases=[];const run=(name,file,mutate,diagnostic)=>{const candidate=new Map(tables),rows=tables.get(file).map(r=>[...r]);mutate(rows);candidate.set(file,rows);let message='';try{check(expected,candidate);}catch(e){message=e.message;}fail(message.includes(diagnostic),'MUTANT_NOT_REJECTED_FOR_INTENDED_REASON '+name+' '+message);cases.push([name,'REJECTED',diagnostic]);};
 run('dropped instruction','records.tsv',r=>r.splice(1,1),'DROPPED_OR_DUPLICATED_INSTRUCTION');
 run('duplicated instruction','records.tsv',r=>r.splice(1,0,[...r[1]]),'DROPPED_OR_DUPLICATED_INSTRUCTION');
 run('reordered instruction','records.tsv',r=>{[r[1],r[2]]=[r[2],r[1]];},'REORDERED_INSTRUCTION');
 run('altered encoding','records.tsv',r=>r[1][8]='00'+r[1][8].slice(2),'ALTERED_INSTRUCTION_BYTES');
 run('missing ELF relocation','relocations.tsv',r=>r.splice(1,1),'MISSING_RELOCATION');
 run('missing printed relocation','printed-relocations.tsv',r=>r.splice(1,1),'MISSING_PRINTED_RELOCATION');
 run('literal data as instruction','records.tsv',r=>r.find(r=>r[11]==='DATA')[11]='INSTRUCTION','DATA_OR_ISA_MISCLASSIFIED');
 run('swallowed executable gap','listing-gaps.tsv',r=>{const i=r.findIndex(r=>r[0]!=='listing'&&r[0]!=='NO_LISTING');r.splice(i,1);},'SWALLOWED_EXECUTABLE_GAP');
 run('swallowed physical-file gap','file-ranges.tsv',r=>r.splice(1,1),'FILE_GAP_OR_OVERLAP');
 run('library coverage overclaim','summary.tsv',r=>r.find(r=>r[0]==='library_closure_denominator')[1]='0','FALSE_LIBRARY_COVERAGE');
 run('semantic form overclaim','semantic-forms.tsv',r=>r[1][15]='VERIFIED','UNVERIFIED_SEMANTICS_COMPLETE');
 run('semantic instruction overclaim','records.tsv',r=>r[1][17]='COMPLETE','UNVERIFIED_SEMANTICS_COMPLETE');
 run('linked copies double counted','summary.tsv',r=>r.find(r=>r[0]==='instruction_listing_records')[1]='999999','FALSE_INSTRUCTION_TOTAL');
 run('Fortran language overclaim','summary.tsv',r=>r.find(r=>r[0]==='fortran_language_feature_denominator')[1]='ALL_FORTRAN','FALSE_LANGUAGE_COVERAGE');
 run('English row dropped','english-crosswalk.tsv',r=>r.splice(1,1),'MISSING_ENGLISH_ROW');
 run('unlisted object omitted','listing-gaps.tsv',r=>r.splice(r.findIndex(r=>r[0]==='NO_LISTING'),1),'UNLISTED_OBJECT_GAP_OMITTED');
 run('uncaptured library body falsely covered','dependencies.tsv',r=>r[1][4]='CAPTURED_AND_COMPLETE','FALSE_LIBRARY_BODY_COVERAGE');return cases;}
const args=process.argv.slice(2),arg=(n,f)=>args.includes(n)?args[args.indexOf(n)+1]:f;
const repo=resolve(arg('--repository',''));fail(args.includes('--repository'),'EXPLICIT_REPOSITORY_REQUIRED');
const worktree_paths=load_worktree_paths(repo,args),inventory=resolve(arg('--inventory',worktree_paths.path('coverage/fortran/generated')));
const expected=loadExpected(repo,worktree_paths),tables=readTables(inventory),result=check(expected,tables),mutants=args.includes('--self-test')?selfTest(expected,tables):[];
console.log('PASS independent raw-source/readelf accounting: '+JSON.stringify(result));for(const row of mutants)console.log(row.join('\t'));
if(args.includes('--receipt')){const path=resolve(arg('--receipt'));fail(!existsSync(path),'REFUSE_EXISTING_RECEIPT');const oracle=resolve(dirname(fileURLToPath(import.meta.url)),'..');if(args.includes('--path-map')){fail(!exec('git',['-C',repo,'status','--porcelain','--untracked-files=all','--',...worktree_paths.git_scopes(['coverage/fortran','examples/autogenerated/fortran-coverage','.github/workflows/fortran-coverage.yml'])]).length,'DIRTY_LEAF_CANNOT_ISSUE_EXACT_HEAD_RECEIPT');fail(!exec('git',['-C',oracle,'status','--porcelain','--','fortran-coverage/check.mjs','fortran-coverage/worktree-paths.mjs']).length,'DIRTY_ORACLE_CANNOT_ISSUE_EXACT_HEAD_RECEIPT');}const identity=exec('git',['-C',oracle,'rev-parse','HEAD']).toString().trim(),leaf=exec('git',['-C',repo,'rev-parse','HEAD']).toString().trim();const lines=[['result','PASS_STRUCTURAL_ACCOUNTING_ONLY'],['leaf_commit',leaf],['ai_ci_commit',identity],['oracle_source_sha256',hash(readFileSync(fileURLToPath(import.meta.url)))],['source_pins_sha256',hash(readFileSync(worktree_paths.path('coverage/fortran/source-heads.tsv')))],['node',process.version],['readelf',exec('readelf',['--version']).toString().split('\n')[0]],['negative_mutants_rejected',mutants.length],['semantics','UNVERIFIED'],['library_closure','UNKNOWN'],['fortran_language_coverage','UNKNOWN']];lines.push(...worktree_paths.receipt_fields);for(const [name]of [...tables].sort((a,b)=>a[0].localeCompare(b[0])))lines.push(['table_sha256:'+name,hash(readFileSync(join(inventory,name)))]);writeFileSync(path,'key\tvalue\n'+lines.map(r=>r.join('\t')).join('\n')+'\n');}
