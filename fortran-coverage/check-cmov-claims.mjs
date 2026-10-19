#!/usr/bin/env node
// Checks a finite claim slice against original bytes and a pinned Intel source.
// No QR code, assembler, linker, compiler, or specimen executable is invoked.
import assert from 'node:assert/strict';
import {readFileSync,writeFileSync,mkdtempSync,rmSync,existsSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {join,resolve,dirname} from 'node:path';
import {tmpdir} from 'node:os';
import {fileURLToPath} from 'node:url';
const demand=(b,m)=>assert(b,m),sha=b=>createHash('sha256').update(b).digest('hex');
const run=(p,a)=>{const r=spawnSync(p,a,{maxBuffer:8*1024*1024,env:{...process.env,LC_ALL:'C',GIT_NO_REPLACE_OBJECTS:'1'}});demand(!r.error&&r.status===0,'MISSING_SOURCE_OR_COMMAND '+p+' '+a.join(' '));return r.stdout;};
const parse=b=>b.toString().trimEnd().split('\n').map(l=>l.split('\t'));
const sourcePin='0655e12c0e19b3dde360ed097ee88ba7b2c6d060';
const primaryBlob='72a27b29b4e5287f03ca83155964c8e501bb49eb';
const lowRegisters=['eax','ecx','edx','ebx','esp','ebp','esi','edi',...Array.from({length:8},(_,i)=>'r'+(i+8)+'d')];
const highRegisters=['rax','rcx','rdx','rbx','rsp','rbp','rsi','rdi',...Array.from({length:8},(_,i)=>'r'+(i+8))];
function decoded(bytes){const b=Buffer.from(bytes.replaceAll(' ',''),'hex');let i=0,rex=0;if((b[0]&0xf0)===0x40)rex=b[i++];demand(!(rex&8)&&b[i++]===15,'UNSUPPORTED_CMOV_WIDTH_OR_OPCODE');const cc=b[i++];demand(cc===78||cc===79,'UNSUPPORTED_CMOV_CONDITION');const modrm=b[i++];demand((modrm>>>6)===3&&i===b.length,'NOT_REGISTER_SOURCE_OR_EXTRA_BYTES');const d=((modrm>>>3)&7)+((rex&4)?8:0),s=(modrm&7)+((rex&1)?8:0);return {destination:lowRegisters[d],whole:highRegisters[d],source:lowRegisters[s],condition:cc===78?'LE':'G',length:b.length};}
function original(repo){
 const temp=mkdtempSync(join(tmpdir(),'aici-cmov-')),out=[];
 out.incompleteCounts={};
 try{for(const name of ['dqrls','dqrdc2','dqrsl','linked-executable']){
  const prefix='examples/r-lm-native-x86-64/',path=prefix+(name==='linked-executable'?'call_r_qr':name+'.o');
  const binary=run('git',['-C',repo,'cat-file','blob',sourcePin+':'+path]);const file=join(temp,name);writeFileSync(file,binary);
  const native=run('objdump',name==='linked-executable'?['-d','-M','intel',file]:['-dr','-M','intel','--disassemble='+name+'_',file]).toString();
  const listing=run('git',['-C',repo,'cat-file','blob',sourcePin+':'+prefix+name+'.x86-64.disasm.txt']).toString();
  let ordinal=0;for(const line of listing.split('\n')){const cols=line.split('\t');if(!/^\s*[0-9a-f]+:$/.test(cols[0]||'')||!cols[2]?.trim())continue;ordinal++;const op=cols[2].trim().split(/\s+/)[0];if(/^(shl|sar|shr|imul|ucomisd|comisd|mulsd|divsd|addsd|subsd|sqrtsd|maxsd|cvtsi2sd)$/.test(op))out.incompleteCounts[op]=(out.incompleteCounts[op]||0)+1;if(!/^cmov(?:le|g)\s+(?:e\w+|r\d+d),/.test(cols[2].trim()))continue;
   const address=parseInt(cols[0],16),bytes=cols[1].trim().replace(/\s+/g,' '),a=cols.slice(2).join('\t').trim(),x=decoded(bytes);
   const raw=native.split('\n').find(l=>new RegExp('^\\s*'+address.toString(16)+':\\t').test(l));demand(raw,'INDEPENDENT_DECODE_MISSING');const decodedColumns=raw.split('\t');demand(decodedColumns[1].trim().replace(/\s+/g,' ')===bytes&&decodedColumns[2].replace(/\s+/g,' ').trim()===a.replace(/\s+/g,' '),'INDEPENDENT_DECODE_DIFFERS');
   out.push({name,ordinal:String(ordinal).padStart(4,'0'),address,bytes,assembly:a,...x});
  }
 }}finally{rmSync(temp,{recursive:true,force:true});}demand(out.length===8&&new Set(out.map(r=>r.bytes)).size===4,'CMOV_SCOPE_CHANGED');return out;
}
function annotations(repo){return new Map(['dqrdc2','dqrsl','linked-executable'].map(name=>[name,readFileSync(join(repo,'examples/r-lm-native-x86-64/english-translation',name+'.x86-64.instructions.english'),'utf8')]));}
function check(rows,remaining,texts,source,primary){
 demand(createHash('sha1').update('blob '+primary.length+'\0').update(primary).digest('hex')===primaryBlob,'PRIMARY_REFERENCE_CHANGED');
 const doc=primary.toString();demand(doc.includes('DEST[63:32] := 0')&&doc.includes('temp := SRC')&&doc.includes('SF=OF')&&doc.includes('ZF=1 or SF'), 'PRIMARY_RULE_UNAVAILABLE');
 demand(rows.length===source.length,'DROPPED_OR_DUPLICATED_CLAIM');let transitions=0;const cases=[];
 for(let i=0;i<source.length;i++){const r=source[i],c=rows[i];assert.deepEqual(c,[r.name,r.ordinal,'0x'+r.address.toString(16),r.bytes,r.destination,r.whole,r.source,r.condition,'32','REGISTER','CLEAR_BOTH_OUTCOMES','PRESERVED','UNVERIFIED'],'CLAIM_IDENTITY_OR_RULE_CHANGED');
  const lines=texts.get(r.name).split('\n'),line=lines.findIndex(l=>l.startsWith('INSTRUCTION '+r.ordinal+' | '));demand(line>=0,'ANNOTATION_MISSING');const header=lines[line].match(/^INSTRUCTION \d+ \| 0x([0-9a-f]+) \| ([0-9a-f ]+) \| (.+)$/);demand(header&&parseInt(header[1],16)===r.address&&header[2]===r.bytes&&header[3]===r.assembly,'ANNOTATION_BYTES_OR_OPERANDS_CHANGED');
  const e=lines[line+3];demand(e.startsWith('  Detailed first-pass effect: '),'EFFECT_MISSING');
  const predicate=/Check (ZF=[01]) (or|and) SF (differs from|equals) OF;/.exec(e);demand(predicate,'UNPARSED_PREDICATE');
  demand(e.includes('Read the original low 32 bits of '+r.destination+' and the 32-bit register '+r.source+'.')&&e.includes('select '+r.source+' if true, or the old low 32 bits of '+r.destination+' if false.'),'WRONG_SELECTION_OPERANDS');
  demand(e.includes('In BOTH cases')&&e.includes('clearing bits 63 through 32 of '+r.whole+', including when the condition is false.'),'UPPER_HALF_RULE_LOST');demand(e.includes('No condition flag changes.'),'FLAG_PRESERVATION_LOST');
  demand(lines[line+4]===`  Sequential successor if not otherwise redirected or faulting: 0x${(r.address+r.length).toString(16)} (${r.length} bytes).`,'SEQUENTIAL_SUCCESSOR_CHANGED');
  // All 32 assignments to CF/PF/ZF/SF/OF; three disclosed data pairs, not all data.
  const values=[[0xdeadbeef12345678n,0x76543210n],[0xffffffffffffffffn,0n],[0x8000000000000000n,0xffffffffn]];
  for(let flags=0;flags<32;flags++){const z=(flags>>>2)&1,s=(flags>>>3)&1,o=(flags>>>4)&1,expected=r.condition==='LE'?(z===1||s!==o):(z===0&&s===o),left=z===Number(predicate[1].slice(-1)),right=predicate[3]==='equals'?s===o:s!==o,observed=predicate[2]==='or'?(left||right):(left&&right);demand(observed===expected,'WRONG_CONDITION_TRUTH_TABLE');
   for(let j=0;j<values.length;j++){const [old,src]=values[j],result=observed?src&0xffffffffn:old&0xffffffffn;demand((result>>32n)===0n,'UPPER_HALF_NOT_ZERO');cases.push([r.name,r.ordinal,flags,j,expected?1:0,old.toString(16),src.toString(16),result.toString(16),'PRIMARY_RULE_MODEL_ONLY']);transitions++;}
  }
 }
 const counts=source.incompleteCounts;demand(Object.values(counts).reduce((a,b)=>a+b,0)===117&&remaining.length===Object.keys(counts).length,'REMAINING_SCOPE_CHANGED');for(const [name,count]of Object.entries(counts)){const r=remaining.find(r=>r[0]===name);demand(r&&Number(r[1])===count&&r[2]==='UNVERIFIED'&&r[3].length>20,'REMAINING_CLAIMS_PROMOTED_OR_MISSING');}
 return {transitions,cases};
}
const args=process.argv.slice(2),arg=k=>args[args.indexOf(k)+1];demand(args.includes('--repository')&&args.includes('--primary-file'),'EXPLICIT_REPOSITORY_AND_PRIMARY_REQUIRED');
const repo=resolve(arg('--repository')),dir=join(repo,'coverage/fortran/cmov-slice'),rows=parse(readFileSync(join(dir,'claims.tsv'))).slice(1),remaining=parse(readFileSync(join(dir,'remaining.tsv'))).slice(1),texts=annotations(repo),source=original(repo),primary=readFileSync(resolve(arg('--primary-file'))),result=check(rows,remaining,texts,source,primary),mutants=[];
if(args.includes('--self-test')){const test=(label,mutate,diagnostic)=>{let error='';const rs=rows.map(r=>[...r]),rem=remaining.map(r=>[...r]),ts=new Map(texts);try{mutate(rs,rem,ts);check(rs,rem,ts,source,primary);}catch(e){error=e.message;}demand(error.includes(diagnostic),'MUTANT_ACCEPTED_OR_WRONG_DIAGNOSTIC '+label+' '+error);mutants.push([label,'REJECTED',diagnostic]);};
 test('dropped claim',r=>r.pop(),'DROPPED_OR_DUPLICATED_CLAIM');test('duplicated claim',r=>r.push([...r[0]]),'DROPPED_OR_DUPLICATED_CLAIM');test('reordered claim',r=>{[r[0],r[1]]=[r[1],r[0]];},'CLAIM_IDENTITY_OR_RULE_CHANGED');test('false high-half preservation',r=>r[0][10]='PRESERVE_IF_FALSE','CLAIM_IDENTITY_OR_RULE_CHANGED');test('full semantics overclaim',r=>r[0][12]='VERIFIED','CLAIM_IDENTITY_OR_RULE_CHANGED');test('117 remaining promoted',(_,r)=>r[0][2]='VERIFIED','REMAINING_CLAIMS_PROMOTED_OR_MISSING');
 test('inverted English predicate',(_,r,t)=>t.set('dqrdc2',t.get('dqrdc2').replace('Check ZF=1 or SF differs from OF;','Check ZF=1 or SF equals OF;')),'WRONG_CONDITION_TRUTH_TABLE');test('wrong English source',(_,r,t)=>t.set('dqrdc2',t.get('dqrdc2').replace('select r8d if true','select eax if true')),'WRONG_SELECTION_OPERANDS');test('lost English high-half rule',(_,r,t)=>t.set('dqrdc2',t.get('dqrdc2').replace('In BOTH cases','Only when true')),'UPPER_HALF_RULE_LOST');test('changed flags',(_,r,t)=>t.set('dqrdc2',t.get('dqrdc2').replace('No condition flag changes.','Condition flags change.')),'FLAG_PRESERVATION_LOST');
 let error='';try{check(rows,remaining,texts,source,Buffer.concat([primary,Buffer.from('altered')]));}catch(e){error=e.message;}demand(error.includes('PRIMARY_REFERENCE_CHANGED'),'PRIMARY_MUTANT_NOT_REJECTED');mutants.push(['altered primary source','REJECTED','PRIMARY_REFERENCE_CHANGED']);
}
console.log('PASS finite CMOV claim check: 8 occurrences, 4 encodings, 256 flag assignments, '+result.transitions+' modeled data transitions; '+mutants.length+' corruptions rejected.');for(const r of mutants)console.log(r.join('\t'));console.log('COMPLETE_EFFECTS=UNVERIFIED; 117 other descriptions remain UNVERIFIED; no new native execution.');
if(args.includes('--receipt')){const out=resolve(arg('--receipt'));demand(!existsSync(out)&&!existsSync(out+'.cases.tsv'),'REFUSE_EXISTING_RECEIPT');const oracle=resolve(dirname(fileURLToPath(import.meta.url)),'..');demand(!run('git',['-C',repo,'status','--porcelain','--untracked-files=all','--','coverage/fortran/cmov-slice','examples/r-lm-native-x86-64/english-translation','.github/workflows/fortran-coverage.yml']).length,'DIRTY_LEAF');demand(!run('git',['-C',oracle,'status','--porcelain','--','fortran-coverage/check-cmov-claims.mjs']).length,'DIRTY_ORACLE');const body='listing\trecord\tflag_assignment\tdata_pair\tpredicate\told\tsource\tresult\tevidence\n'+result.cases.map(r=>r.join('\t')).join('\n')+'\n';const receipt=[['result','PASS_FINITE_CLAIM_CHECK_ONLY'],['leaf_commit',run('git',['-C',repo,'rev-parse','HEAD']).toString().trim()],['ai_ci_commit',run('git',['-C',oracle,'rev-parse','HEAD']).toString().trim()],['oracle_sha256',sha(readFileSync(fileURLToPath(import.meta.url)))],['primary_git_blob',primaryBlob],['primary_sha256',sha(primary)],['claims_sha256',sha(readFileSync(join(dir,'claims.tsv')))],['remaining_sha256',sha(readFileSync(join(dir,'remaining.tsv')))],['cases_sha256',sha(body)],['flag_assignments',256],['modeled_data_transitions',result.transitions],['corruptions_rejected',mutants.length],['new_native_execution','NOT_RUN'],['complete_effects','UNVERIFIED'],['library_closure','UNKNOWN'],['whole_fortran','UNKNOWN']];writeFileSync(out+'.cases.tsv',body);writeFileSync(out,'key\tvalue\n'+receipt.map(r=>r.join('\t')).join('\n')+'\n');}
