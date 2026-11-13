// Independent AI-CI acceptance for the bounded English Major C QR A32 entry.
// Invokes the consumer's actual pinned-Idric executable; no assembly, word
// generation or source parsing is delegated to an imitation encoder.
import assert from 'node:assert/strict';
import {readFileSync, mkdtempSync, writeFileSync, rmSync, statSync} from 'node:fs';
import {spawnSync, execFileSync} from 'node:child_process';
import {tmpdir} from 'node:os';
import {join} from 'node:path';

// Independently pinned original QR object words, never used by the encoder.
const pinnedOriginalWords = [
  'e92d4ff0','e1a06003','e592c000','e24dd04c','e5914000',
  'e1a03002','e1a0a001','e1cc8fcc','e59dc074','e1c44fc4',
  'e59d2084','e58dc000','e59dc088','e58d2004','e58dc00c',
  'e59d208c','e59dc090','e58d2008','e1a02001','e58dc010',
  'e58d0028','e58d302c','e58d8038'
];
const pinnedOracle = pinnedOriginalWords.map((word,index)=>[index*4,word]);
const wordPattern = /^[0-9a-f]{8}$/;
function assertWords(emitted, oracle) {
  assert.equal(emitted.length, 23, 'exactly 23 emitted words are required');
  assert.deepEqual(emitted.map(row => [row.address, row.word]), oracle,
    'actual Idric English output must equal original QR object at all 23 offsets');
}
function assertChange(before, after, changedIndex, newWord) {
  assert.equal(after.length, before.length, 'operand mutation changed word count');
  for(let index=0; index<before.length; index++) {
    assert.equal(after[index].address, before[index].address,
      'operand mutation changed a byte offset');
    assert.equal(after[index].word, index===changedIndex ? newWord : before[index].word,
      'wrong machine word after a valid operand mutation at index '+index);
  }
  assert.notEqual(after[changedIndex].word,before[changedIndex].word,
    'valid operand change was ignored; likely an archived-word lookup');
}
function selfTest() {
  const oracle=Array.from({length:23},(_,index)=>[index*4,'e1a06003']);
  const rows=oracle.map(([address,word])=>({address,word}));
  assertWords(rows,oracle);
  assert.throws(()=>assertWords(rows.slice(1),oracle));
  const wrong=rows.map(row=>({...row}));
  wrong[9].word='e1a06002';
  assert.throws(()=>assertWords(wrong,oracle));
  const duplicate=rows.map(row=>({...row}));
  duplicate[5].address=16;
  assert.throws(()=>assertWords(duplicate,oracle));
  const changed=rows.map(row=>({...row}));
  changed[1].word='e1a06002';
  assertChange(rows,changed,1,'e1a06002');
  assert.throws(()=>assertChange(rows,rows,1,'e1a06002'));
  assert.throws(()=>assertChange(rows,changed,1,'e1a06004'));
  console.log('AICI_A32_VERIFIER_SELF_TEST=PASS');
}
function run(binary, args) {
  const result=spawnSync(binary,args,{encoding:'utf8',shell:false,
    timeout:15000,maxBuffer:1024*1024});
  assert.equal(result.error,undefined,'Could not execute real Idric binary: '+result.error);
  return result;
}
function englishResult(binary, source) {
  const directory=mkdtempSync(join(tmpdir(),'aici-english-a32-'));
  try {
    const path=join(directory,'qr-entry.english');
    writeFileSync(path,source,'utf8');
    return run(binary,['--english',path]);
  } finally {
    rmSync(directory,{recursive:true,force:true});
  }
}
function parseEnglish(binary, source, expectedSentences) {
  const result=englishResult(binary,source);
  assert.equal(result.status,0,'Actual Idric English encoding failed:\n'+result.stdout+'\n'+result.stderr);
  const lines=result.stdout.trimEnd().split(/\r?\n/);
  assert.equal(lines.at(-1),'A32_ENGLISH_INSTRUCTIONS=23');
  assert.equal(lines.length,47,'Unexpected English compiler output length');
  const echoes=lines.filter(line=>line.startsWith('ENGLISH|'));
  const outputs=lines.filter(line=>line.startsWith('WORD|'));
  assert.equal(echoes.length,23,'one exact English echo per sentence');
  assert.equal(outputs.length,23,'one machine word per English sentence');
  assert.deepEqual(echoes.map(line=>line.split('|').slice(2).join('|')),
    expectedSentences,'original English descriptions must be preserved');
  return outputs.map(line=>{
    const fields=line.split('|');
    assert.ok(fields.length>=4,'word and English operation description required');
    assert.match(fields[1],/^(0|[1-9][0-9]*)$/,'decimal byte offset required');
    assert.match(fields[2],wordPattern,'eight hex digits required');
    assert.ok(fields.slice(3).join('|').length>10,'full-English semantic description required');
    return {address:Number(fields[1]),word:fields[2],description:fields.slice(3).join('|')};
  });
}
function alteredOnce(source, before, after) {
  assert.equal(source.split(before).length,2,'missing or ambiguous original source mutation marker: '+before);
  return source.replace(before,after);
}
function main() {
  const [binary,englishPath,objectPath,projectRoot]=process.argv.slice(2);
  assert.ok(binary && englishPath && objectPath && projectRoot,
    'Usage: node verify-a32-23.mjs IDRIC_BINARY ENGLISH_SOURCE ORIGINAL_DISASSEMBLY SOURCE_REPO_ROOT');
  assert.ok(statSync(binary).isFile(),'Idric compiler executable missing');
  const checkedHead=execFileSync('git',['-C',projectRoot,'rev-parse','HEAD'],
    {encoding:'utf8'}).trim();
  assert.match(checkedHead,/^[0-9a-f]{40}$/);
  if(process.env.EXPECTED_SOURCE_SHA)
    assert.equal(checkedHead,process.env.EXPECTED_SOURCE_SHA,
      'Source checkout is not the requested exact PR head');
  const source=readFileSync(englishPath,'utf8');
  const disassembly=readFileSync(objectPath,'utf8');
  const sentences=source.split(/\r?\n/).filter(line=>line.startsWith('At byte offset '));
  assert.equal(sentences.length,23,'Original archived source must have 23 English sentences');
  const oracle=disassembly.split(/\r?\n/).map(line=>{
    const parts=line.match(/^\s*([0-9a-f]+):\s+([0-9a-f]{8})\s+\S+/i);
    return parts ? [parseInt(parts[1],16),parts[2].toLowerCase()] : null;
  }).filter(row=>row && row[0]<=0x58);
  assert.equal(oracle.length,23,'Original archived object must have 23 machine instructions');
  assert.deepEqual(oracle,pinnedOracle,
    'Original QR object bytes do not match independent AI-CI oracle');
  for(let index=0;index<23;index++) {
    assert.equal(oracle[index][0],index*4,'Original QR byte address changed');
    const sentence=sentences[index].match(/^At byte offset 0x([0-9a-f]+),/);
    assert.ok(sentence,'Malformed English byte offset');
    assert.equal(parseInt(sentence[1],16),index*4,'English offsets must match QR object');
  }

  const original=parseEnglish(binary,source,sentences);
  assertWords(original,oracle);
  // The independent raw-word decoding mode must agree with the description
  // emitted by English -> typed instruction -> word encoding.
  for(const row of original) {
    const decoded=run(binary,['--word',row.word]);
    assert.equal(decoded.status,0,'Raw-bit Idric decoder rejected '+row.word);
    assert.equal(decoded.stdout.trim(),row.description,
      'Raw-bit Idric decoder disagrees at offset '+row.address);
  }

  const validMutations=[
    ['At byte offset 0x0004, copy the four-byte value in register r3 into register r6.',
     'At byte offset 0x0004, copy the four-byte value in register r2 into register r6.',
     1,'e1a06002'],
    ['At byte offset 0x0034, store the four-byte value in register r2 at register r13 plus 0x4.',
     'At byte offset 0x0034, store the four-byte value in register r2 at register r13 plus 0x8.',
     13,'e58d2008'],
    ['At byte offset 0x0040, read a four-byte word at register r13 plus 0x90 into register r12.',
     'At byte offset 0x0040, read a four-byte word at register r13 plus 0x91 into register r12.',
     16,'e59dc091']
  ];
  for(const [before,after,index,expectedWord] of validMutations) {
    const changedSource=alteredOnce(source,before,after);
    const changedSentences=changedSource.split(/\r?\n/)
      .filter(line=>line.startsWith('At byte offset '));
    const changed=parseEnglish(binary,changedSource,changedSentences);
    assertChange(original,changed,index,expectedWord);
  }
  const invalid=[
    alteredOnce(source,'into register r6.','into register r16.'),
    alteredOnce(source,'r4, r5, r6, r7','r4, r6, r5, r7'),
    alteredOnce(source,'r4, r5, r6, r7','r4, r4, r6, r7'),
    alteredOnce(source,'subtract 0x4c from','subtract 0x100 from'),
    alteredOnce(source,'plus 0x90 into register r12.','plus 0x1000 into register r12.'),
    alteredOnce(source,'at register r2 plus 0x0','at register r15 plus 0x0'),
    alteredOnce(source,
      'At byte offset 0x001c, retain register r12 in register r8 when its signed four-byte value is nonnegative; otherwise write zero.',
      'At byte offset 0x001c, retain register r12 in register r8 when its signed four-byte value is negative; otherwise write zero.'),
    alteredOnce(source,'into register r6.','inside register r6.'),
    alteredOnce(source,'At byte offset 0x0018,','At byte offset 0x0014,'),
    source.replace(/^At byte offset 0x0010,.*\n/m,''),
    source+'At byte offset 0x005c, copy the four-byte value in register r3 into register r6.\n',
    source+'At byte offset 0x005c, call an unresolved target.\n'
  ];
  for(const [index,altered] of invalid.entries()) {
    assert.notEqual(altered,source,'Hostile mutation was a no-op at '+index);
    const attempt=englishResult(binary,altered);
    assert.notEqual(attempt.status,0,
      'Actual Idric binary accepted forbidden English source mutation '+index);
  }
  console.log('AICI_ENGLISH_A32_23=PASS|head='+checkedHead+
    '|original_words=23/23|raw_decoder=23/23|valid_operand_mutations=3/3|hostile_rejections='+invalid.length+'/'+invalid.length+
    '|relocation_0x005c=EXCLUDED');
}
if(process.argv[2]==='--self-test') selfTest();
else main();
