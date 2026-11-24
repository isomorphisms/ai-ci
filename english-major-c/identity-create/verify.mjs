import {dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {verifyTask12} from '../verify-task12.mjs';

const sourcePointer = 'Copy "original name" into "id argument or source cursor" without changing the condition flags.\nCall the function named "identity_created"';
const cases = [
  ['original', null, null, 0],
  ['duplicate-accepted', 'Put 1 into the low', 'Put 0 into the low', 40],
  ['allocation-short', 'Put 36 into the low', 'Put 35 into the low', 41],
  ['truncate-early', 'Put 19 into the low', 'Put 18 into the low', 45],
  ['keep-dirty-busy', 'at 24 bytes beyond', 'at 25 bytes beyond', 46],
  ['notify-wrong-name', sourcePointer, sourcePointer.replace('"original name"', '"sentinel"'), 48],
];
verifyTask12({here: dirname(fileURLToPath(import.meta.url)), operation: 'identity-create',
              pin: '4ea41e726a77650f7355a7f73081d33cd812460c',
              buildId: 'emc-task12-create', dependencies: ['identity-find'], cases});
console.log('Seven create attempts passed, including three insertions and two forced allocation failures. Five incorrect programs failed at the expected checks.');
