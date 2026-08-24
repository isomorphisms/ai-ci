import { createHash } from "node:crypto";
import { createReadStream } from "node:fs";
import {
  appendFile,
  mkdir,
  readFile,
  readdir,
  realpath,
  rename,
  stat,
  unlink,
  writeFile,
} from "node:fs/promises";
import path from "node:path";
import { spawn } from "node:child_process";

export const PASS = "PASS";
export const FAIL = "FAIL";
export const NOT_VERIFIED = "NOT VERIFIED";
export const SCHEMA_VERSION = 1;

const CHECK_NAME = /^[a-z0-9](?:[a-z0-9._-]*[a-z0-9])?$/;
const COMMIT_SHA = /^[0-9a-f]{40}$/i;
const SHA256 = /^[0-9a-f]{64}$/i;

export class ContractError extends Error {}

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function requireNonemptyString(value, label) {
  if (typeof value !== "string" || value.trim() === "") {
    throw new ContractError(`${label} must be a nonempty string`);
  }
  return value;
}

export function validateCommit(commit) {
  requireNonemptyString(commit, "commit");
  if (!COMMIT_SHA.test(commit)) {
    throw new ContractError("commit must be a full 40-character Git SHA");
  }
  return commit.toLowerCase();
}

export async function readJson(filePath) {
  const text = await readFile(filePath, "utf8");
  try {
    return JSON.parse(text);
  } catch (error) {
    throw new ContractError(`${filePath}: invalid JSON: ${error.message}`);
  }
}

export async function writeJson(filePath, value) {
  const parent = path.dirname(filePath);
  await mkdir(parent, { recursive: true });
  const temporary = `${filePath}.tmp-${process.pid}-${Date.now()}`;
  await writeFile(temporary, `${JSON.stringify(value, null, 2)}\n`, "utf8");
  try {
    await rename(temporary, filePath);
  } catch (error) {
    await unlink(temporary).catch(() => {});
    throw error;
  }
}

export async function appendSummary(filePath, markdown) {
  await appendFile(filePath, markdown, "utf8");
}

async function sha256File(filePath) {
  const digest = createHash("sha256");
  await new Promise((resolve, reject) => {
    const stream = createReadStream(filePath);
    stream.on("data", (chunk) => digest.update(chunk));
    stream.on("error", reject);
    stream.on("end", resolve);
  });
  return digest.digest("hex");
}

function pathIsInside(rootPath, candidatePath) {
  const relative = path.relative(rootPath, candidatePath);
  return relative === "" || (!relative.startsWith(`..${path.sep}`) && relative !== ".." && !path.isAbsolute(relative));
}

export async function hashArtifact(root, artifactPath) {
  requireNonemptyString(root, "artifact root");
  requireNonemptyString(artifactPath, "artifact path");
  if (path.isAbsolute(artifactPath)) {
    throw new ContractError("artifact path must be relative to the repository root");
  }

  const lexicalRoot = path.resolve(root);
  const lexicalArtifact = path.resolve(lexicalRoot, artifactPath);
  if (!pathIsInside(lexicalRoot, lexicalArtifact)) {
    throw new ContractError("artifact path escapes the repository root");
  }

  let resolvedRoot;
  let resolvedArtifact;
  try {
    resolvedRoot = await realpath(lexicalRoot);
    resolvedArtifact = await realpath(lexicalArtifact);
  } catch (error) {
    throw new ContractError(`artifact is unavailable: ${artifactPath}: ${error.message}`);
  }
  if (!pathIsInside(resolvedRoot, resolvedArtifact)) {
    throw new ContractError("artifact symlink escapes the repository root");
  }

  const metadata = await stat(resolvedArtifact);
  if (!metadata.isFile()) {
    throw new ContractError(`artifact is not a regular file: ${artifactPath}`);
  }
  return sha256File(resolvedArtifact);
}

export function validateContract(value) {
  if (!isObject(value)) {
    throw new ContractError("contract must be a JSON object");
  }
  if (value.schema_version !== SCHEMA_VERSION) {
    throw new ContractError(`contract schema_version must be ${SCHEMA_VERSION}`);
  }
  if (!Array.isArray(value.required_checks) || value.required_checks.length === 0) {
    throw new ContractError("contract must require at least one check");
  }

  const names = new Set();
  const requiredChecks = value.required_checks.map((item, index) => {
    if (!isObject(item)) {
      throw new ContractError(`required_checks[${index}] must be an object`);
    }
    const name = requireNonemptyString(item.name, `required_checks[${index}].name`);
    if (!CHECK_NAME.test(name)) {
      throw new ContractError(`invalid check name: ${name}`);
    }
    if (names.has(name)) {
      throw new ContractError(`duplicate required check: ${name}`);
    }
    names.add(name);
    if (typeof item.artifact_required !== "boolean") {
      throw new ContractError(`${name}.artifact_required must be true or false`);
    }
    return {
      name,
      artifact_required: item.artifact_required,
      description: typeof item.description === "string" ? item.description : "",
    };
  });

  return { schema_version: SCHEMA_VERSION, required_checks: requiredChecks };
}

async function loadEvidenceDirectory(directory) {
  let entries;
  try {
    entries = await readdir(directory, { withFileTypes: true });
  } catch (error) {
    if (error.code === "ENOENT") {
      return { reports: [], errors: [`evidence directory is absent: ${directory}`] };
    }
    throw error;
  }

  const reports = [];
  const errors = [];
  const files = entries
    .filter((entry) => entry.isFile() && entry.name.endsWith(".json"))
    .map((entry) => entry.name)
    .sort();

  for (const filename of files) {
    const filePath = path.join(directory, filename);
    let value;
    try {
      value = await readJson(filePath);
    } catch (error) {
      errors.push(error.message);
      continue;
    }
    if (!isObject(value) || typeof value.check !== "string" || value.check.trim() === "") {
      errors.push(`${filePath}: evidence report has no check name`);
      continue;
    }
    reports.push({ filename, value });
  }
  return { reports, errors };
}

function commandIsExact(command) {
  return Array.isArray(command) && command.length > 0 && command.every(
    (part) => typeof part === "string" && part !== "",
  );
}

function result(name, status, reason, filename = null, artifact = null) {
  return {
    name,
    status,
    reason,
    evidence_file: filename,
    artifact,
  };
}

async function evaluateReport(requirement, report, expectedCommit, root) {
  const { value, filename } = report;
  if (value.schema_version !== SCHEMA_VERSION) {
    return result(requirement.name, NOT_VERIFIED, `evidence schema_version must be ${SCHEMA_VERSION}`, filename);
  }

  if (value.status === NOT_VERIFIED) {
    const reason = typeof value.reason === "string" && value.reason.trim() !== ""
      ? value.reason
      : "the report marked this check NOT VERIFIED";
    return result(requirement.name, NOT_VERIFIED, reason, filename);
  }
  if (value.status !== PASS && value.status !== FAIL) {
    const reported = typeof value.status === "string" ? value.status : "missing";
    return result(requirement.name, NOT_VERIFIED, `non-verifying status: ${reported}`, filename);
  }

  if (typeof value.commit !== "string" || !COMMIT_SHA.test(value.commit)) {
    return result(requirement.name, NOT_VERIFIED, "report has no full commit SHA", filename);
  }
  if (value.commit.toLowerCase() !== expectedCommit) {
    return result(
      requirement.name,
      NOT_VERIFIED,
      `stale report: ${value.commit.toLowerCase()} does not match ${expectedCommit}`,
      filename,
    );
  }
  if (!commandIsExact(value.command)) {
    return result(requirement.name, NOT_VERIFIED, "report has no exact command argv", filename);
  }
  if (typeof value.environment !== "string" || value.environment.trim() === "") {
    return result(requirement.name, NOT_VERIFIED, "report has no execution environment", filename);
  }

  if (value.status === FAIL) {
    const reason = typeof value.reason === "string" && value.reason.trim() !== ""
      ? value.reason
      : "the check ran and failed";
    return result(requirement.name, FAIL, reason, filename, value.artifact ?? null);
  }

  if (value.artifact === undefined || value.artifact === null) {
    if (requirement.artifact_required) {
      return result(requirement.name, NOT_VERIFIED, "required artifact evidence is absent", filename);
    }
    return result(requirement.name, PASS, "current commit was verified", filename);
  }
  if (!isObject(value.artifact)) {
    return result(requirement.name, NOT_VERIFIED, "artifact evidence must be an object", filename);
  }
  if (typeof value.artifact.path !== "string" || value.artifact.path.trim() === "") {
    return result(requirement.name, NOT_VERIFIED, "artifact path is absent", filename);
  }
  if (typeof value.artifact.sha256 !== "string" || !SHA256.test(value.artifact.sha256)) {
    return result(requirement.name, NOT_VERIFIED, "artifact SHA-256 is absent or invalid", filename);
  }

  let observedDigest;
  try {
    observedDigest = await hashArtifact(root, value.artifact.path);
  } catch (error) {
    return result(requirement.name, NOT_VERIFIED, error.message, filename, value.artifact);
  }
  if (observedDigest !== value.artifact.sha256.toLowerCase()) {
    return result(
      requirement.name,
      NOT_VERIFIED,
      `artifact bytes changed: report ${value.artifact.sha256.toLowerCase()}, current ${observedDigest}`,
      filename,
      value.artifact,
    );
  }
  return result(requirement.name, PASS, "current commit and exact artifact bytes were verified", filename, value.artifact);
}

export async function evaluateGate({ contractPath, evidenceDirectory, expectedCommit, root = ".", now = new Date() }) {
  const commit = validateCommit(expectedCommit);
  const contract = validateContract(await readJson(contractPath));
  const evidence = await loadEvidenceDirectory(evidenceDirectory);
  const byCheck = new Map();
  for (const report of evidence.reports) {
    const existing = byCheck.get(report.value.check) ?? [];
    existing.push(report);
    byCheck.set(report.value.check, existing);
  }

  const checks = [];
  for (const requirement of contract.required_checks) {
    const reports = byCheck.get(requirement.name) ?? [];
    if (reports.length === 0) {
      checks.push(result(requirement.name, NOT_VERIFIED, "required evidence report is absent"));
    } else if (reports.length > 1) {
      checks.push(result(requirement.name, NOT_VERIFIED, "multiple reports make the evidence ambiguous"));
    } else {
      checks.push(await evaluateReport(requirement, reports[0], commit, root));
    }
  }

  for (const error of evidence.errors) {
    checks.push(result("evidence-input", NOT_VERIFIED, error));
  }

  let status = PASS;
  if (checks.some((check) => check.status === FAIL)) {
    status = FAIL;
  } else if (checks.some((check) => check.status === NOT_VERIFIED)) {
    status = NOT_VERIFIED;
  }

  return {
    schema_version: SCHEMA_VERSION,
    status,
    expected_commit: commit,
    generated_at: now.toISOString(),
    checks,
  };
}

export function exitCodeFor(status) {
  if (status === PASS) return 0;
  if (status === FAIL) return 1;
  return 2;
}

function escapeTableCell(value) {
  return String(value).replaceAll("|", "\\|").replaceAll("\n", " ");
}

export function renderSummary(gate) {
  const lines = [
    "## AI CI acceptance gate",
    "",
    `Overall: **${gate.status}**`,
    "",
    `Expected commit: \`${gate.expected_commit}\``,
    "",
    "| Check | Status | Evidence | Reason |",
    "| --- | --- | --- | --- |",
  ];
  for (const check of gate.checks) {
    lines.push(
      `| ${escapeTableCell(check.name)} | ${escapeTableCell(check.status)} | ${escapeTableCell(check.evidence_file ?? "—")} | ${escapeTableCell(check.reason)} |`,
    );
  }
  lines.push("");
  return `${lines.join("\n")}\n`;
}

function waitForChild(command, args, options) {
  return new Promise((resolve) => {
    let settled = false;
    const finish = (outcome) => {
      if (!settled) {
        settled = true;
        resolve(outcome);
      }
    };
    let child;
    try {
      child = spawn(command, args, options);
    } catch (error) {
      finish({ kind: "unavailable", error });
      return;
    }
    child.on("error", (error) => finish({ kind: "unavailable", error }));
    child.on("exit", (code, signal) => finish({ kind: "exit", code, signal }));
  });
}

export async function runCheck({
  check,
  commit,
  environment,
  artifactPath = null,
  outputPath,
  root = ".",
  command,
  now = new Date(),
}) {
  if (!CHECK_NAME.test(requireNonemptyString(check, "check"))) {
    throw new ContractError(`invalid check name: ${check}`);
  }
  const normalizedCommit = validateCommit(commit);
  requireNonemptyString(environment, "environment");
  requireNonemptyString(outputPath, "output path");
  if (!commandIsExact(command)) {
    throw new ContractError("command must contain an executable and exact argv");
  }

  const base = {
    schema_version: SCHEMA_VERSION,
    check,
    commit: normalizedCommit,
    command,
    environment,
    observed_at: now.toISOString(),
  };
  const outcome = await waitForChild(command[0], command.slice(1), {
    cwd: root,
    env: process.env,
    shell: false,
    stdio: "inherit",
  });

  let evidence;
  if (outcome.kind === "unavailable") {
    evidence = {
      ...base,
      status: NOT_VERIFIED,
      reason: `command could not start: ${outcome.error.message}`,
    };
  } else if (outcome.code !== 0) {
    const ending = outcome.signal ? `signal ${outcome.signal}` : `exit ${outcome.code}`;
    evidence = { ...base, status: FAIL, reason: `command ended with ${ending}` };
  } else if (artifactPath !== null) {
    try {
      const digest = await hashArtifact(root, artifactPath);
      evidence = {
        ...base,
        status: PASS,
        reason: "command exited 0 and artifact bytes were recorded",
        artifact: { path: artifactPath, sha256: digest },
      };
    } catch (error) {
      evidence = {
        ...base,
        status: FAIL,
        reason: `command exited 0 but the expected artifact was not produced: ${error.message}`,
      };
    }
  } else {
    evidence = { ...base, status: PASS, reason: "command exited 0" };
  }

  await writeJson(outputPath, evidence);
  return evidence;
}

export async function compareBytes({ root = ".", left, right }) {
  const leftDigest = await hashArtifact(root, left);
  const rightDigest = await hashArtifact(root, right);
  return {
    same: leftDigest === rightDigest,
    left: { path: left, sha256: leftDigest },
    right: { path: right, sha256: rightDigest },
  };
}
