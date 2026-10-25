import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { mkdtempSync, mkdirSync, readFileSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { test } from 'node:test';
import { load_worktree_paths } from './worktree-paths.mjs';

function with_repository(operation) {
  const root = mkdtempSync(join(tmpdir(), 'aici-worktree-paths-'));
  try { operation(root); }
  finally { rmSync(root, { recursive: true, force: true }); }
}

function write_file(root, path, content) {
  mkdirSync(dirname(join(root, path)), { recursive: true });
  writeFileSync(join(root, path), content);
}

function map_files(root, rows) {
  const text = 'old_path\tnew_path\n' + rows.map(row => row.join('\t')).join('\n') + '\n';
  write_file(root, '_/path-map.tsv', text);
  return load_worktree_paths(root, ['--path-map', '_/path-map.tsv']);
}

test('without a map the existing repository paths remain unchanged', () => with_repository(root => {
  write_file(root, 'coverage/fortran/source-heads.tsv', 'original source pins');
  const paths = load_worktree_paths(root, []);
  assert.equal(readFileSync(paths.path('coverage/fortran/source-heads.tsv'), 'utf8'), 'original source pins');
  assert.deepEqual(paths.git_scopes(['coverage/fortran']), [':(literal)coverage/fortran']);
  assert(!paths.receipt_fields.some(([name]) => name === 'worktree_path_map'));
}));

test('longest prefix and exact file overrides find the same bytes after a split', () => with_repository(root => {
  write_file(root, '_/coverage/fortran/source-heads.tsv', 'historical/path is unchanged');
  write_file(root, 'arm/qr/dqrls.disasm.txt', 'original assembly');
  write_file(root, '_/artifacts/dqrls.o', 'original object');
  const paths = map_files(root, [
    ['coverage', '_/coverage'],
    ['examples', '_/examples'],
    ['examples/qr', 'arm/qr'],
    ['examples/qr/dqrls.o', '_/artifacts/dqrls.o'],
  ]);
  assert.equal(readFileSync(paths.path('coverage/fortran/source-heads.tsv'), 'utf8'), 'historical/path is unchanged');
  assert.equal(readFileSync(paths.path('examples/qr/dqrls.disasm.txt'), 'utf8'), 'original assembly');
  assert.equal(readFileSync(paths.path('examples/qr/dqrls.o'), 'utf8'), 'original object');
  assert.equal(paths.path('examples-old/qr'), join(root, 'examples-old/qr'));
  assert.deepEqual(paths.git_scopes(['examples/qr']), [
    ':(literal)_/artifacts/dqrls.o', ':(literal)_/path-map.tsv', ':(literal)arm/qr',
  ]);
  assert.equal(new Map(paths.receipt_fields).get('worktree_path_map_sha256'),
    createHash('sha256').update(readFileSync(join(root, '_/path-map.tsv'))).digest('hex'));
}));

test('duplicate sources are rejected even when their destinations agree', () => with_repository(root => {
  assert.throws(() => map_files(root, [['coverage', '_/coverage'], ['coverage', '_/coverage']]),
    { message: 'PATH_MAP_DUPLICATE_SOURCE' });
}));

test('nonrelative and noncanonical paths cannot escape or alias an entry', () => with_repository(root => {
  for (const invalid of ['', '/tmp/elsewhere', '../elsewhere', 'a/../b', './a', 'a//b',
    'a/', 'C:/outside', 'a\\b', 'a\0b']) {
    assert.throws(() => map_files(root, [['source', invalid]]), { message: 'PATH_MAP_INVALID_PATH' });
    assert.throws(() => map_files(root, [[invalid, 'target']]), { message: 'PATH_MAP_INVALID_PATH' });
  }
}));

test('malformed headers and rows fail at their own diagnostic', () => with_repository(root => {
  for (const [text, message] of [
    ['source\ttarget\na\tb\n', 'PATH_MAP_HEADER'],
    ['old_path\tnew_path\na\tb\tc\n', 'PATH_MAP_COLUMNS'],
    ['old_path\tnew_path\n\n', 'PATH_MAP_COLUMNS'],
  ]) {
    write_file(root, '_/path-map.tsv', text);
    assert.throws(() => load_worktree_paths(root, ['--path-map', '_/path-map.tsv']), { message });
  }
  assert.throws(() => load_worktree_paths(root, ['--path-map']), { message: 'PATH_MAP_ARGUMENT_REQUIRED' });
  assert.throws(() => load_worktree_paths(root, ['--path-map', 'a', '--path-map', 'b']),
    { message: 'PATH_MAP_DUPLICATE_OPTION' });
  write_file(root, '_/path-map.tsv', Buffer.from([0xff]));
  assert.throws(() => load_worktree_paths(root, ['--path-map', '_/path-map.tsv']),
    { message: 'PATH_MAP_ENCODING' });
}));

test('escaping symlink ancestors are rejected even for missing descendants', () => with_repository(root => {
  const outside = mkdtempSync(join(tmpdir(), 'aici-path-outside-'));
  try {
    symlinkSync(outside, join(root, 'escape'), 'dir');
    assert.throws(() => map_files(root, [['source', 'escape/missing/file']]), { message: 'PATH_MAP_ESCAPE' });
    write_file(outside, 'map.tsv', 'old_path\tnew_path\nsource\ttarget\n');
    assert.throws(() => load_worktree_paths(root, ['--path-map', 'escape/map.tsv']), { message: 'PATH_MAP_ESCAPE' });
  } finally { rmSync(outside, { recursive: true, force: true }); }
}));

test('Git detects dirty mappings and files moved outside their original directory', () => with_repository(root => {
  write_file(root, '_/coverage/fortran/source-heads.tsv', 'original pins');
  write_file(root, 'fortran/claims.tsv', 'original claims');
  const paths = map_files(root, [
    ['coverage', '_/coverage'],
    ['coverage/fortran/claims.tsv', 'fortran/claims.tsv'],
  ]);
  function git(arguments_list) {
    const result = spawnSync('git', ['-C', root, ...arguments_list], { encoding: 'utf8' });
    assert.ifError(result.error);
    assert.equal(result.status, 0, result.stderr);
    return result.stdout;
  }
  git(['init', '--quiet']);
  git(['add', '.']);
  git(['-c', 'user.name=Path map fixture', '-c', 'user.email=path-map@example.invalid',
    'commit', '--quiet', '-m', 'Preserve original fixture']);
  const status = () => git(['status', '--porcelain', '--untracked-files=all', '--',
    ...paths.git_scopes(['coverage/fortran'])]);
  assert.equal(status(), '');
  write_file(root, 'fortran/claims.tsv', 'corrupt claims');
  assert.match(status(), /fortran\/claims\.tsv/);
  write_file(root, 'fortran/claims.tsv', 'original claims');
  write_file(root, '_/path-map.tsv', 'old_path\tnew_path\ncoverage\twrong\n');
  assert.match(status(), /_\/path-map\.tsv/);
}));

test('all three checker entrypoints validate the same map before reading candidate data', () => with_repository(root => {
  write_file(root, '_/path-map.tsv', 'old_path\tnew_path\ncoverage\t../outside\n');
  for (const name of ['check.mjs', 'check-arm-ledgers.mjs', 'check-cmov-claims.mjs']) {
    const result = spawnSync(process.execPath, [join(dirname(fileURLToPath(import.meta.url)), name),
      '--repository', root, '--path-map', '_/path-map.tsv', '--primary-file', join(root, 'unused')],
    { encoding: 'utf8' });
    assert.equal(result.status, 1, name);
    assert.match(result.stderr, /PATH_MAP_INVALID_PATH/, name);
  }
}));
