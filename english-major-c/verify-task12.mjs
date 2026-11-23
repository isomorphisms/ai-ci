import assert from 'node:assert/strict';
import {execFileSync, spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {mkdirSync, readFileSync, writeFileSync} from 'node:fs';
import {join, resolve} from 'node:path';

export function verifyTask12({here, operation, pin, buildId, cases, dependencies = []}) {
  const [consumerPath, ndkPath, qemu, outputPath] = process.argv.slice(2);
  if (!outputPath) throw new Error('Expected producer checkout, NDK root, qemu-arm and output directory.');
  const producer = resolve(consumerPath);
  const ndk = resolve(ndkPath);
  const out = resolve(outputPath);
  mkdirSync(out, {recursive: true});
  const git = (...args) => execFileSync('git', ['-C', producer, ...args], {encoding: 'utf8'}).trim();
  assert.equal(git('rev-parse', 'HEAD'), pin);
  assert.equal(git('status', '--porcelain', '--untracked-files=all'), '');
  assert.match(readFileSync(join(ndk, 'source.properties'), 'utf8'), /^Pkg.Revision = 27\.2\.12479018$/m);
  const manifest = readFileSync(join(here, '../../ci/build-toolchain.tsv'), 'utf8').trimEnd().split('\n');
  const rows = manifest.filter(line => line.startsWith(buildId + '\t')).map(line => line.split('\t'));
  assert.equal(rows.length, 1);
  const [[, target, compiler, ickRevision, capability, evidence]] = rows;
  assert.equal(target, 'armv7a-linux-androideabi21');
  assert.equal(compiler, 'ndk');
  assert.equal(ickRevision, 'c61e448251744a2f40ad743ebef1a027bdcd2f9d');
  assert.match(capability, /^gap:.+T32.+A32/);
  assert.ok(evidence.includes(pin));
  console.log('Build selection:', ...rows[0]);
  const bin = join(ndk, 'toolchains/llvm/prebuilt/linux-x86_64/bin');
  const source = readFileSync(join(producer, 'arm/thumb', operation, operation + '.english'), 'utf8');
  const frontend = join(producer, '_/tools/compile-english-assembly.mjs');
  const companionAssembly = dependencies.map(dependency => {
    const input = join(producer, 'arm/thumb', dependency, dependency + '.english');
    const output = join(out, dependency + '.s');
    execFileSync(process.execPath, [frontend, input, output]);
    return output;
  });
  const digest = path => createHash('sha256').update(readFileSync(path)).digest('hex');
  for (const [name, before, after, expected] of cases) {
    const english = join(out, name + '.english');
    const assembly = join(out, name + '.s');
    const elf = join(out, name + '.elf');
    const trace = join(out, name + '.trace');
    if (before !== null) assert.equal(source.split(before).length, 2, 'Mutant must alter exactly one instruction.');
    writeFileSync(english, before === null ? source : source.replace(before, after));
    execFileSync(process.execPath, [frontend, english, assembly]);
    execFileSync(join(bin, 'clang'), ['--target=' + target, '-march=armv7-a', '-marm', '-nostdlib', '-static',
                                     '-Wl,--build-id=none,-e,_start', join(here, 'caller.s'), ...companionAssembly, assembly, '-o', elf]);
    const result = spawnSync(qemu, ['-cpu', 'cortex-a9', '-d', 'in_asm,exec', '-D', trace, elf],
                             {timeout: 10000, encoding: 'utf8'});
    if (result.error) throw result.error;
    assert.equal(result.signal, null, 'Unexpected signal in ' + name);
    assert.equal(result.status, expected, name + ': wrong failing case or normal exit: ' + result.stderr);
    assert.ok(readFileSync(trace).length > 0);
    console.log(name, 'elf', digest(elf), 'exit', result.status, 'trace', digest(trace));
  }
}
