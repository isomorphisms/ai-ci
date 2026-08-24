import { appendFile } from "node:fs/promises";
import {
  PASS,
  evaluateGate,
  renderSummary,
  writeJson,
} from "../src/ai-ci.mjs";

function input(name, fallback = "") {
  const value = process.env[`INPUT_${name.toUpperCase()}`];
  return value === undefined || value === "" ? fallback : value;
}

function workflowEscape(value) {
  return String(value).replaceAll("%", "%25").replaceAll("\r", "%0D").replaceAll("\n", "%0A");
}

async function setOutput(name, value) {
  if (process.env.GITHUB_OUTPUT) {
    await appendFile(process.env.GITHUB_OUTPUT, `${name}=${value}\n`, "utf8");
  }
}

try {
  const result = await evaluateGate({
    contractPath: input("CONTRACT", ".ai-ci/contract.json"),
    evidenceDirectory: input("EVIDENCE_DIR", ".ai-ci/evidence"),
    expectedCommit: input("EXPECTED_COMMIT", process.env.GITHUB_SHA ?? ""),
    root: input("ROOT", "."),
  });
  const output = input("OUTPUT");
  if (output) await writeJson(output, result);
  if (process.env.GITHUB_STEP_SUMMARY) {
    await appendFile(process.env.GITHUB_STEP_SUMMARY, renderSummary(result), "utf8");
  }
  await setOutput("status", result.status);
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  if (result.status !== PASS) {
    process.stdout.write(`::error title=AI CI acceptance gate::${workflowEscape(result.status)}\n`);
    process.exitCode = 1;
  }
} catch (error) {
  process.stdout.write(`::error title=AI CI acceptance gate::${workflowEscape(`NOT VERIFIED: ${error.message}`)}\n`);
  process.exitCode = 1;
}
