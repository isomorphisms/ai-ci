import {dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {verifyTask12} from '../verify-task12.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const cases = [
  ['original', null, null, 0],
  ['return-link', 'Copy "containing identity"', 'Copy "current link"', 2],
  ['read-busy-field', '20 bytes beyond', '24 bytes beyond', 2],
  ['compare-id-to-itself', 'Compare "current id" with "requested id"',
                           'Compare "current id" with "current id"', 3],
];
verifyTask12({here, operation: 'identity-find', pin: 'ce52cf665e302588a6334d4efa4e495da40bab5b',
              buildId: 'emc-task12-interworking', cases});
console.log('Seven independent A32-to-T32 calls passed. Three altered English programs failed at their expected calls.');
