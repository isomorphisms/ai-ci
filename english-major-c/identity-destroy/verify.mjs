import {dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {verifyTask12} from '../verify-task12.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const backlink = 'Store exactly four bytes from "predecessor link" at 4 bytes beyond the address in "requested id or successor link".';
const release = 'Call the function named "identity_release" and put the return address into the link register.';
const cases = [
  ['original', null, null, 0],
  ['one-way-splice', backlink, '', 34],
  ['release-neighbor', release, 'Copy "predecessor link" into "sentinel or containing identity" without changing the condition flags.\n' + release, 32],
  ['no-release', release, '', 35],
  ['wrong-retired-marker', 'Put 290 into the low sixteen bits', 'Put 291 into the low sixteen bits', 36],
];
verifyTask12({here, operation: 'identity-destroy', pin: '5548fed6fa936b1f80d7a16bb9299acda6b05523',
              buildId: 'emc-task12-destroy', dependencies: ['identity-find'], cases});
console.log('Seven sequential removals and misses passed, including four verified release callbacks. Four incorrect programs failed at the expected checks.');
