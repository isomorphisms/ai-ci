// ai-ci-owned independent finite-coefficient acceptance. Execute through FP.
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {isAbsolute, resolve} from 'node:path';
import {pathToFileURL} from 'node:url';

const maximumOrder = 160;
const apiNames = [
  'multiplyCoefficients', 'eisensteinCoefficients',
  'discriminantCoefficients', 'heckePrimeCoefficients',
];

class AcceptanceFailure extends Error {
  constructor(code, detail) {
    super(`${code}: ${detail}`);
    this.code = code;
  }
}

function requireCondition(condition, code, detail) {
  if (!condition) throw new AcceptanceFailure(code, detail);
}

function requireEqualCoefficients(actual, expected, code, detail) {
  requireCondition(Array.isArray(actual), code, `${detail}: output is not an array`);
  requireCondition(actual.length === expected.length, code, `${detail}: wrong retained order`);
  for (let degree = 0; degree < expected.length; degree += 1) {
    requireCondition(typeof actual[degree] === 'bigint' && actual[degree] === expected[degree],
      code, `${detail}: degree ${degree}, got ${String(actual[degree])}, expected ${expected[degree]}`);
  }
}

function requireRejection(action, expectedClass, code, detail) {
  let observed;
  try { action(); } catch (error) { observed = error; }
  requireCondition(observed instanceof expectedClass, code,
    `${detail}: expected ${expectedClass.name}, got ${observed?.constructor?.name ?? 'acceptance'}`);
}

// Direct per-number divisor enumeration, unlike the consumer's divisor sieve.
function divisorPowerSum(number, power) {
  let sum = 0n;
  for (let divisor = 1; divisor <= number; divisor += 1) {
    if (number % divisor === 0) sum += BigInt(divisor) ** BigInt(power);
  }
  return sum;
}

function eisensteinReference(weight, order) {
  const scale = weight === 4 ? 240n : -504n;
  return Array.from({length: order + 1}, (_, degree) =>
    degree === 0 ? 1n : scale * divisorPowerSum(degree, weight - 1));
}

// Logarithmic derivative, not the consumer's repeated product:
// (n-1) tau(n) = -24 sum_{j=1}^{n-1} sigma_1(j) tau(n-j).
function discriminantReference(order) {
  const coefficients = Array(order + 1).fill(0n);
  if (order === 0) return coefficients;
  coefficients[1] = 1n;
  const divisors = Array.from({length: order + 1}, (_, number) => divisorPowerSum(number, 1));
  for (let degree = 2; degree <= order; degree += 1) {
    let numerator = 0n;
    for (let lower = 1; lower < degree; lower += 1) {
      numerator -= 24n * divisors[lower] * coefficients[degree - lower];
    }
    const denominator = BigInt(degree - 1);
    requireCondition(numerator % denominator === 0n, 'reference-recurrence',
      `nonintegral tau coefficient at degree ${degree}`);
    coefficients[degree] = numerator / denominator;
  }
  return coefficients;
}

function convolutionReference(first, second, order) {
  return Array.from({length: order + 1}, (_, degree) => {
    let value = 0n;
    for (let left = 0; left <= degree; left += 1) value += first[left] * second[degree - left];
    return value;
  });
}

const referenceFourth = eisensteinReference(4, maximumOrder);
const referenceSixth = eisensteinReference(6, maximumOrder);
const referenceDelta = discriminantReference(maximumOrder);

function checkCandidate(candidate) {
  for (const name of apiNames) {
    requireCondition(typeof candidate[name] === 'function', 'modular-api', `missing ${name}`);
  }
  const fourth = candidate.eisensteinCoefficients(4, maximumOrder);
  const sixth = candidate.eisensteinCoefficients(6, maximumOrder);
  const delta = candidate.discriminantCoefficients(maximumOrder);
  requireEqualCoefficients(fourth, referenceFourth, 'e4-coefficients', 'E4 direct divisor reference');
  requireEqualCoefficients(sixth, referenceSixth, 'e6-coefficients', 'E6 direct divisor reference');
  requireEqualCoefficients(delta, referenceDelta, 'delta-coefficients', 'Delta logarithmic-derivative reference');
  requireEqualCoefficients(candidate.discriminantCoefficients(0), [0n], 'delta-coefficients', 'order zero');
  requireEqualCoefficients(candidate.discriminantCoefficients(1), [0n, 1n], 'delta-coefficients', 'order one');

  const first = Array.from({length: 34}, (_, degree) =>
    (degree % 2 === 0 ? 1n : -1n) * ((1n << 80n) + BigInt(degree + 1) ** 3n));
  const second = Array.from({length: 34}, (_, degree) => BigInt(2 * degree - 17));
  for (const order of [0, 1, 7, 33]) {
    requireEqualCoefficients(candidate.multiplyCoefficients(first, second, order),
      convolutionReference(first, second, order), 'coefficient-product', `finite convolution through ${order}`);
  }
  const identityOrder = 32;
  const fourthSquared = candidate.multiplyCoefficients(fourth, fourth, identityOrder);
  const fourthCubed = candidate.multiplyCoefficients(fourthSquared, fourth, identityOrder);
  const sixthSquared = candidate.multiplyCoefficients(sixth, sixth, identityOrder);
  requireEqualCoefficients(fourthCubed.map((value, degree) => value - sixthSquared[degree]),
    referenceDelta.slice(0, identityOrder + 1).map(value => 1728n * value),
    'modular-identity', 'E4^3-E6^2=1728 Delta');

  for (const prime of [2, 3, 5]) {
    const order = 32;
    const arbitrary = Array.from({length: prime * order + 1}, (_, degree) =>
      (degree % 2 === 0 ? 1n : -1n) * ((1n << 70n) + BigInt(degree + 1) ** 4n));
    for (const weight of [4, 6, 12]) {
      const scale = BigInt(prime) ** BigInt(weight - 1);
      const expected = Array.from({length: order + 1}, (_, degree) => {
        let value = arbitrary[prime * degree];
        if (degree % prime === 0) value += scale * arbitrary[degree / prime];
        return value;
      });
      requireEqualCoefficients(candidate.heckePrimeCoefficients(arbitrary, weight, prime, order),
        expected, 'hecke-finite-data', `T${prime}, arbitrary finite weight ${weight}`);
    }
    for (const [weight, values] of [[4, fourth], [6, sixth], [12, delta]]) {
      const eigenvalue = weight === 12 ? referenceDelta[prime] : 1n + BigInt(prime) ** BigInt(weight - 1);
      requireEqualCoefficients(candidate.heckePrimeCoefficients(values, weight, prime, order),
        values.slice(0, order + 1).map(value => eigenvalue * value),
        'hecke-eigenform', `T${prime}, weight ${weight} eigenform`);
    }
    requireRejection(() => candidate.heckePrimeCoefficients(arbitrary.slice(0, prime * order), 12, prime, order),
      RangeError, 'hecke-input-precision', `T${prime} requires coefficient ${prime * order}`);
  }
  requireEqualCoefficients(candidate.heckePrimeCoefficients([3n], 4, 2, 0), [27n],
    'hecke-finite-data', 'Hecke constant term');
  for (const prime of [0, 1, 4, 9, 2.5, NaN, Infinity]) {
    requireRejection(() => candidate.heckePrimeCoefficients(delta, 12, prime, 2),
      RangeError, 'hecke-index-rejection', `invalid prime ${prime}`);
  }
  for (const order of [-1, 0.5, NaN, Infinity, 4097]) {
    requireRejection(() => candidate.discriminantCoefficients(order),
      RangeError, 'finite-order-rejection', `invalid order ${order}`);
  }
  for (const weight of [2, 8, 4.5, NaN]) {
    requireRejection(() => candidate.eisensteinCoefficients(weight, 2),
      RangeError, 'eisenstein-weight-rejection', `unsupported E weight ${weight}`);
  }
  for (const weight of [0, 1, 3, 4.5, NaN, 4098]) {
    requireRejection(() => candidate.heckePrimeCoefficients(delta, weight, 2, 2),
      RangeError, 'hecke-weight-rejection', `invalid Hecke weight ${weight}`);
  }
  requireRejection(() => candidate.multiplyCoefficients([1], [1n], 0),
    TypeError, 'coefficient-type-rejection', 'Number coefficients');
  requireRejection(() => candidate.multiplyCoefficients(Array(2), [1n, 1n], 1),
    TypeError, 'coefficient-type-rejection', 'sparse coefficients');
  requireRejection(() => candidate.multiplyCoefficients([1n], [1n], 1),
    RangeError, 'product-input-precision', 'missing coefficient at requested order');
}

function proveMutantRejected(candidate, name, expectedCode, replacement) {
  let observed;
  try { checkCandidate({...candidate, ...replacement}); } catch (error) { observed = error; }
  requireCondition(observed instanceof AcceptanceFailure && observed.code === expectedCode,
    'mutant-rejection', `${name}: expected ${expectedCode}, got ${observed?.code ?? observed?.message ?? 'PASS'}`);
  return `${name}\tREJECTED\t${expectedCode}`;
}

function verifySourceIdentity(actual, expected) {
  requireCondition(/^[0-9a-f]{64}$/.test(expected) && actual === expected,
    'source-identity', 'candidate SHA256 does not match declared bytes');
}

export function verifyModularModule(candidate) {
  // Check the reference's independent published low-order coefficients first.
  requireEqualCoefficients(referenceDelta.slice(0, 11),
    [0n, 1n, -24n, 252n, -1472n, 4830n, -6048n, -16744n, 84480n, -113643n, -115920n],
    'reference-recurrence', 'known tau prefix');
  checkCandidate(candidate);
  const mutate = (method, index) => (...args) => {
    const values = candidate[method](...args);
    values[Math.min(index, values.length - 1)] += 1n;
    return values;
  };
  const rows = [];
  const reject = (name, code, replacement) => rows.push(proveMutantRejected(candidate, name, code, replacement));
  reject('missing-export', 'modular-api', {discriminantCoefficients: undefined});
  reject('wrong-e4', 'e4-coefficients', {eisensteinCoefficients: (weight, order) => {
    const values = candidate.eisensteinCoefficients(weight, order);
    if (weight === 4) values[order] += 1n;
    return values;
  }});
  reject('wrong-e6', 'e6-coefficients', {eisensteinCoefficients: (weight, order) => {
    const values = candidate.eisensteinCoefficients(weight, order);
    if (weight === 6) values[order] += 1n;
    return values;
  }});
  reject('wrong-delta-above-consumer-fixtures', 'delta-coefficients', {
    discriminantCoefficients: mutate('discriminantCoefficients', 131),
  });
  reject('wrong-convolution', 'coefficient-product', {multiplyCoefficients: mutate('multiplyCoefficients', 0)});
  reject('wrong-modular-identity-product', 'modular-identity', {multiplyCoefficients: (first, second, order) => {
    const values = candidate.multiplyCoefficients(first, second, order);
    if (first[0] === 1n && second[0] === 1n && order === 32) values[32] += 1n;
    return values;
  }});
  reject('wrong-hecke-arithmetic', 'hecke-finite-data', {
    heckePrimeCoefficients: mutate('heckePrimeCoefficients', 0),
  });
  reject('wrong-hecke-eigenform', 'hecke-eigenform', {heckePrimeCoefficients: (values, weight, prime, order) => {
    const result = candidate.heckePrimeCoefficients(values, weight, prime, order);
    if (values[0] === 0n && weight === 12) result[1] += 1n;
    return result;
  }});
  reject('hecke-zero-pads-missing-input', 'hecke-input-precision', {
    heckePrimeCoefficients: (values, weight, prime, order) => {
      if (values.length <= prime * order) return Array(order + 1).fill(0n);
      return candidate.heckePrimeCoefficients(values, weight, prime, order);
    },
  });
  reject('hecke-accepts-composite', 'hecke-index-rejection', {
    heckePrimeCoefficients: (values, weight, prime, order) => prime === 4 ?
      Array(order + 1).fill(0n) : candidate.heckePrimeCoefficients(values, weight, prime, order),
  });
  reject('accepts-negative-order', 'finite-order-rejection', {
    discriminantCoefficients: order => order === -1 ? [0n] : candidate.discriminantCoefficients(order),
  });
  reject('accepts-unsupported-eisenstein-weight', 'eisenstein-weight-rejection', {
    eisensteinCoefficients: (weight, order) => weight === 8 ? [1n] : candidate.eisensteinCoefficients(weight, order),
  });
  reject('accepts-odd-hecke-weight', 'hecke-weight-rejection', {
    heckePrimeCoefficients: (values, weight, prime, order) => weight === 3 ?
      Array(order + 1).fill(0n) : candidate.heckePrimeCoefficients(values, weight, prime, order),
  });
  reject('accepts-number-coefficients', 'coefficient-type-rejection', {
    multiplyCoefficients: (first, second, order) => typeof first[0] === 'number' ?
      [1n] : candidate.multiplyCoefficients(first, second, order),
  });
  reject('product-zero-pads-missing-input', 'product-input-precision', {
    multiplyCoefficients: (first, second, order) => first.length <= order || second.length <= order ?
      Array(order + 1).fill(0n) : candidate.multiplyCoefficients(first, second, order),
  });
  verifySourceIdentity('a'.repeat(64), 'a'.repeat(64));
  let sourceMismatch;
  try { verifySourceIdentity('a'.repeat(64), 'b'.repeat(64)); } catch (error) { sourceMismatch = error; }
  requireCondition(sourceMismatch?.code === 'source-identity', 'mutant-rejection', 'wrong source identity not rejected');
  rows.push('wrong-source-digest\tREJECTED\tsource-identity');
  return rows;
}

async function main() {
  const [sourcePath, expectedSha, ...extra] = process.argv.slice(2);
  requireCondition(sourcePath && isAbsolute(sourcePath) && extra.length === 0,
    'invocation', 'use an absolute candidate module path and optional expected SHA256');
  const bytes = await readFile(sourcePath);
  const digest = createHash('sha256').update(bytes).digest('hex');
  if (expectedSha !== undefined) verifySourceIdentity(digest, expectedSha);
  // Loading the byte buffer binds execution to the digest even if the path moves.
  // This contract accepts a self-contained module, without relative imports.
  const candidate = await import(`data:text/javascript;base64,${bytes.toString('base64')}`);
  const rows = verifyModularModule(candidate);
  console.log('contract\tdirichlet-finite-modular-v0');
  console.log('acceptance-owner\tisomorphisms/ai-ci');
  console.log('aici-base\t0797259b567afb1d8921e9c3c008ca6221dcc784');
  console.log(`candidate-path\t${sourcePath}`);
  console.log(`candidate-sha256\t${digest}`);
  console.log(`source-binding\t${expectedSha === undefined ? 'external-controller-receipt' : 'expected-sha-verified'}`);
  console.log('coefficient-order\t160');
  console.log('modular-identity-order\t32');
  console.log('hecke-primes\t2,3,5');
  console.log('hecke-output-order\t32');
  console.log(`known-bad-count\t${rows.length}`);
  for (const row of rows) console.log(`known-bad\t${row}`);
  console.log('scope\tfinite-exact-data; no modularity, analytic convergence, native-compiler or device proof');
  console.log('result\tPASS');
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  main().catch(error => {
    console.error(`result\tFAIL\t${error.code ?? 'candidate-exception'}\t${error.message}`);
    process.exitCode = 1;
  });
}
