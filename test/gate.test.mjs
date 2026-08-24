import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { copyFile, mkdir, mkdtemp, readFile, symlink, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  FAIL,
  NOT_VERIFIED,
  PASS,
  compareBytes,
  evaluateGate,
  runCheck,
} from "../src/ai-ci.mjs";

const COMMIT = "1111111111111111111111111111111111111111";
const STALE_COMMIT = "2222222222222222222222222222222222222222";
const FIXTURES = path.resolve("test/fixtures");
const ACTION = path.resolve("action/index.mjs");
const FIXED_TIME = new Date("2026-08-24T12:00:00.000Z");

async function fixture(name) {
  return JSON.parse(await readFile(path.join(FIXTURES, name), "utf8"));
}

async function setup() {
  const root = await mkdtemp(path.join(os.tmpdir(), "ai-ci-test-"));
  await mkdir(path.join(root, "dist"), { recursive: true });
  await mkdir(path.join(root, "evidence"), { recursive: true });
  await copyFile(path.join(FIXTURES, "artifact.bin"), path.join(root, "dist/final.bin"));
  await copyFile(path.join(FIXTURES, "contract.json"), path.join(root, "contract.json"));
  return root;
}

async function putReport(root, fixtureName, targetName = fixtureName, change = (value) => value) {
  const value = change(await fixture(fixtureName));
  if (value.artifact?.sha256 === "REPLACE_WITH_FIXTURE_DIGEST") {
    const bytes = await readFile(path.join(root, "dist/final.bin"));
    value.artifact.sha256 = createHash("sha256").update(bytes).digest("hex");
  }
  await writeFile(path.join(root, "evidence", targetName), `${JSON.stringify(value, null, 2)}\n`);
}

async function evaluate(root) {
  return evaluateGate({
    contractPath: path.join(root, "contract.json"),
    evidenceDirectory: path.join(root, "evidence"),
    expectedCommit: COMMIT,
    root,
    now: FIXED_TIME,
  });
}

test("PASS requires every current report and the exact artifact bytes", async () => {
  const root = await setup();
  await putReport(root, "final-artifact-pass.json");
  await putReport(root, "clean-machine-pass.json");
  const gate = await evaluate(root);
  assert.equal(gate.status, PASS);
  assert.deepEqual(gate.checks.map((check) => check.status), [PASS, PASS]);
});

test("an absent required report is NOT VERIFIED", async () => {
  const root = await setup();
  await putReport(root, "final-artifact-pass.json");
  const gate = await evaluate(root);
  assert.equal(gate.status, NOT_VERIFIED);
  assert.match(gate.checks[1].reason, /absent/);
});

test("skipped, blocked, and cancelled never become PASS", async (context) => {
  for (const status of ["skipped", "blocked", "cancelled"]) {
    await context.test(status, async () => {
      const root = await setup();
      await putReport(root, "final-artifact-pass.json");
      await putReport(root, "clean-machine-skipped.json", "smoke.json", (report) => ({ ...report, status }));
      assert.equal((await evaluate(root)).status, NOT_VERIFIED);
    });
  }
});

test("a PASS report from a different commit is NOT VERIFIED", async () => {
  const root = await setup();
  await putReport(root, "final-artifact-pass.json", "final.json", (report) => ({ ...report, commit: STALE_COMMIT }));
  await putReport(root, "clean-machine-pass.json");
  const gate = await evaluate(root);
  assert.equal(gate.status, NOT_VERIFIED);
  assert.match(gate.checks[0].reason, /stale report/);
});

test("changing an artifact after its test invalidates PASS", async () => {
  const root = await setup();
  await putReport(root, "final-artifact-pass.json");
  await putReport(root, "clean-machine-pass.json");
  await writeFile(path.join(root, "dist/final.bin"), "different bytes\n");
  const gate = await evaluate(root);
  assert.equal(gate.status, NOT_VERIFIED);
  assert.match(gate.checks[0].reason, /artifact bytes changed/);
});

test("a current check that ran and failed produces FAIL", async () => {
  const root = await setup();
  await putReport(root, "final-artifact-pass.json");
  await putReport(root, "clean-machine-fail.json");
  const gate = await evaluate(root);
  assert.equal(gate.status, FAIL);
});

test("duplicate reports are ambiguous rather than green", async () => {
  const root = await setup();
  await putReport(root, "final-artifact-pass.json");
  await putReport(root, "clean-machine-pass.json", "smoke-a.json");
  await putReport(root, "clean-machine-pass.json", "smoke-b.json");
  const gate = await evaluate(root);
  assert.equal(gate.status, NOT_VERIFIED);
  assert.match(gate.checks[1].reason, /multiple reports/);
});

test("malformed evidence prevents a green aggregate", async () => {
  const root = await setup();
  await putReport(root, "final-artifact-pass.json");
  await putReport(root, "clean-machine-pass.json");
  await writeFile(path.join(root, "evidence/broken.json"), "{\n");
  const gate = await evaluate(root);
  assert.equal(gate.status, NOT_VERIFIED);
  assert.equal(gate.checks.at(-1).name, "evidence-input");
});

test("artifact paths and symlinks cannot escape the checked workspace", async () => {
  const root = await setup();
  const outside = path.join(path.dirname(root), `${path.basename(root)}-outside.bin`);
  await writeFile(outside, "outside\n");
  await symlink(outside, path.join(root, "dist/escape.bin"));
  await putReport(root, "final-artifact-pass.json", "final.json", (report) => ({
    ...report,
    artifact: {
      path: "dist/escape.bin",
      sha256: createHash("sha256").update("outside\n").digest("hex"),
    },
  }));
  await putReport(root, "clean-machine-pass.json");
  const gate = await evaluate(root);
  assert.equal(gate.status, NOT_VERIFIED);
  assert.match(gate.checks[0].reason, /symlink escapes/);
});

test("runCheck directly executes argv and records produced bytes", async () => {
  const root = await setup();
  const output = path.join(root, "evidence/direct.json");
  const evidence = await runCheck({
    check: "direct-build",
    commit: COMMIT,
    environment: "node-test",
    artifactPath: "dist/direct.bin",
    outputPath: output,
    root,
    command: [process.execPath, "-e", "require('fs').writeFileSync('dist/direct.bin', 'direct bytes\\n')"],
    now: FIXED_TIME,
  });
  assert.equal(evidence.status, PASS);
  assert.match(evidence.artifact.sha256, /^[0-9a-f]{64}$/);
  assert.deepEqual(JSON.parse(await readFile(output, "utf8")), evidence);
});

test("runCheck distinguishes an executed failure from unavailable evidence", async () => {
  const root = await setup();
  const failed = await runCheck({
    check: "executed-failure",
    commit: COMMIT,
    environment: "node-test",
    outputPath: path.join(root, "failed.json"),
    root,
    command: [process.execPath, "-e", "process.exit(7)"],
    now: FIXED_TIME,
  });
  assert.equal(failed.status, FAIL);

  const unavailable = await runCheck({
    check: "unavailable",
    commit: COMMIT,
    environment: "node-test",
    outputPath: path.join(root, "unavailable.json"),
    root,
    command: [path.join(root, "does-not-exist")],
    now: FIXED_TIME,
  });
  assert.equal(unavailable.status, NOT_VERIFIED);
});

test("same-bytes compares content rather than filenames", async () => {
  const root = await setup();
  await copyFile(path.join(root, "dist/final.bin"), path.join(root, "dist/released.bin"));
  let comparison = await compareBytes({ root, left: "dist/final.bin", right: "dist/released.bin" });
  assert.equal(comparison.same, true);
  await writeFile(path.join(root, "dist/released.bin"), "changed release\n");
  comparison = await compareBytes({ root, left: "dist/final.bin", right: "dist/released.bin" });
  assert.equal(comparison.same, false);
});

test("the GitHub Action publishes PASS and a three-state summary", async () => {
  const root = await setup();
  await putReport(root, "final-artifact-pass.json");
  await putReport(root, "clean-machine-pass.json");
  const outputFile = path.join(root, "github-output.txt");
  const summaryFile = path.join(root, "github-summary.md");
  const action = spawnSync(process.execPath, [ACTION], {
    cwd: root,
    encoding: "utf8",
    env: {
      ...process.env,
      GITHUB_SHA: COMMIT,
      GITHUB_OUTPUT: outputFile,
      GITHUB_STEP_SUMMARY: summaryFile,
      INPUT_CONTRACT: "contract.json",
      INPUT_EVIDENCE_DIR: "evidence",
      INPUT_EXPECTED_COMMIT: COMMIT,
      INPUT_ROOT: ".",
      INPUT_OUTPUT: "gate.json",
    },
  });
  assert.equal(action.status, 0, action.stderr || action.stdout);
  assert.match(await readFile(outputFile, "utf8"), /^status=PASS$/m);
  assert.match(await readFile(summaryFile, "utf8"), /Overall: \*\*PASS\*\*/);
  assert.equal(JSON.parse(await readFile(path.join(root, "gate.json"), "utf8")).status, PASS);
});

test("the GitHub Action makes NOT VERIFIED an unsuccessful job", async () => {
  const root = await setup();
  await putReport(root, "final-artifact-pass.json");
  const outputFile = path.join(root, "github-output.txt");
  const summaryFile = path.join(root, "github-summary.md");
  const action = spawnSync(process.execPath, [ACTION], {
    cwd: root,
    encoding: "utf8",
    env: {
      ...process.env,
      GITHUB_SHA: COMMIT,
      GITHUB_OUTPUT: outputFile,
      GITHUB_STEP_SUMMARY: summaryFile,
      INPUT_CONTRACT: "contract.json",
      INPUT_EVIDENCE_DIR: "evidence",
      INPUT_EXPECTED_COMMIT: COMMIT,
      INPUT_ROOT: ".",
    },
  });
  assert.equal(action.status, 1);
  assert.match(action.stdout, /::error title=AI CI acceptance gate::NOT VERIFIED/);
  assert.match(await readFile(outputFile, "utf8"), /^status=NOT VERIFIED$/m);
  assert.match(await readFile(summaryFile, "utf8"), /Overall: \*\*NOT VERIFIED\*\*/);
});
