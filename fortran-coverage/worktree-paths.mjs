// Relocate current files without changing paths in historical Git snapshots.
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { lstatSync, readFileSync, realpathSync } from 'node:fs';
import { dirname, isAbsolute, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

function require_relative_path(path) {
  assert(typeof path === 'string' && path.length > 0 &&
    !isAbsolute(path) && !/^[A-Za-z]:/.test(path) &&
    !/[\\\x00-\x1f\x7f]/.test(path) &&
    path.split('/').every(part => part !== '' && part !== '.' && part !== '..'),
  'PATH_MAP_INVALID_PATH');
  return path;
}

function is_same_path_or_child(path, parent) {
  return path === parent || path.startsWith(parent + '/');
}

function resolve_inside_repository(repository, path) {
  const absolute = resolve(repository, require_relative_path(path));
  // Check existing ancestors too: a missing leaf must not hide an escaping symlink.
  let ancestor = absolute;
  while (true) {
    try { lstatSync(ancestor); break; }
    catch (error) {
      if (error.code !== 'ENOENT' && error.code !== 'ENOTDIR') throw error;
      ancestor = dirname(ancestor);
    }
  }
  const observed = relative(repository, realpathSync(ancestor));
  assert(observed !== '..' && !observed.startsWith('..' + sep) &&
    !isAbsolute(observed), 'PATH_MAP_ESCAPE');
  return absolute;
}

export function load_worktree_paths(repository, arguments_list) {
  const root = realpathSync(repository);
  const option_indices = arguments_list.flatMap((value, index) =>
    value === '--path-map' ? [index] : []);
  assert(option_indices.length <= 1, 'PATH_MAP_DUPLICATE_OPTION');
  const entries = [];
  const receipt_fields = [];
  let map_path;
  if (option_indices.length) {
    map_path = arguments_list[option_indices[0] + 1];
    assert(map_path && !map_path.startsWith('--'), 'PATH_MAP_ARGUMENT_REQUIRED');
    const bytes = readFileSync(resolve_inside_repository(root, map_path));
    const text = bytes.toString('utf8');
    assert(Buffer.from(text, 'utf8').equals(bytes), 'PATH_MAP_ENCODING');
    const lines = text.split(/\r?\n/);
    if (lines.at(-1) === '') lines.pop();
    assert(lines.shift() === 'old_path\tnew_path', 'PATH_MAP_HEADER');
    const sources = new Set();
    for (const line of lines) {
      const columns = line.split('\t');
      assert(columns.length === 2, 'PATH_MAP_COLUMNS');
      const [old_path, new_path] = columns.map(require_relative_path);
      assert(!sources.has(old_path), 'PATH_MAP_DUPLICATE_SOURCE');
      sources.add(old_path);
      resolve_inside_repository(root, new_path);
      entries.push({ old_path, new_path });
    }
    entries.sort((left, right) => right.old_path.length - left.old_path.length);
    receipt_fields.push(['worktree_path_map', map_path],
      ['worktree_path_map_sha256', createHash('sha256').update(bytes).digest('hex')]);
  }
  receipt_fields.push(['worktree_path_resolver_sha256', createHash('sha256')
    .update(readFileSync(fileURLToPath(import.meta.url))).digest('hex')]);

  function current_relative_path(logical_path) {
    require_relative_path(logical_path);
    const match = entries.find(entry =>
      is_same_path_or_child(logical_path, entry.old_path));
    return match ? match.new_path + logical_path.slice(match.old_path.length) : logical_path;
  }

  return {
    path(logical_path) {
      return resolve_inside_repository(root, current_relative_path(logical_path));
    },
    git_scopes(logical_scopes) {
      const paths = new Set(map_path ? [map_path] : []);
      for (const scope of logical_scopes) {
        paths.add(current_relative_path(scope));
        // A directory may have been split into several destinations.
        for (const entry of entries) {
          if (is_same_path_or_child(entry.old_path, scope)) paths.add(entry.new_path);
        }
      }
      return [...paths].sort().map(path => ':(literal)' + path);
    },
    receipt_fields,
  };
}
