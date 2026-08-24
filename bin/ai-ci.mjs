#!/usr/bin/env node

import { parseArgs } from "node:util";
import {
  ContractError,
  appendSummary,
  compareBytes,
  evaluateGate,
  exitCodeFor,
  renderSummary,
  runCheck,
  writeJson,
} from "../src/ai-ci.mjs";

function required(values, name) {
  const value = values[name];
  if (typeof value !== "string" || value === "") {
    throw new ContractError(`--${name} is required`);
  }
  return value;
}

function help() {
  process.stdout.write(`ai-ci

Commands:
  gate        Aggregate required evidence without false-green states
  run         Run one check directly and write its evidence report
  same-bytes  Compare two files by SHA-256

Run "ai-ci <command> --help" for command options.
`);
}

async function gate(args) {
  const { values } = parseArgs({
    args,
    strict: true,
    options: {
      contract: { type: "string" },
      "evidence-dir": { type: "string" },
      commit: { type: "string" },
      root: { type: "string", default: "." },
      output: { type: "string" },
      summary: { type: "string" },
      help: { type: "boolean", short: "h" },
    },
  });
  if (values.help) {
    process.stdout.write("ai-ci gate --contract FILE --evidence-dir DIR --commit SHA [--root DIR] [--output FILE] [--summary FILE]\n");
    return 0;
  }
  const result = await evaluateGate({
    contractPath: required(values, "contract"),
    evidenceDirectory: required(values, "evidence-dir"),
    expectedCommit: required(values, "commit"),
    root: values.root,
  });
  if (values.output) await writeJson(values.output, result);
  if (values.summary) await appendSummary(values.summary, renderSummary(result));
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  return exitCodeFor(result.status);
}

async function run(args) {
  const { values, positionals } = parseArgs({
    args,
    strict: true,
    allowPositionals: true,
    options: {
      check: { type: "string" },
      commit: { type: "string" },
      environment: { type: "string" },
      artifact: { type: "string" },
      output: { type: "string" },
      root: { type: "string", default: "." },
      help: { type: "boolean", short: "h" },
    },
  });
  if (values.help) {
    process.stdout.write("ai-ci run --check NAME --commit SHA --environment TEXT [--artifact FILE] --output FILE -- COMMAND [ARG...]\n");
    return 0;
  }
  if (positionals.length === 0) {
    throw new ContractError("run requires a command after --");
  }
  const evidence = await runCheck({
    check: required(values, "check"),
    commit: required(values, "commit"),
    environment: required(values, "environment"),
    artifactPath: values.artifact ?? null,
    outputPath: required(values, "output"),
    root: values.root,
    command: positionals,
  });
  process.stdout.write(`${JSON.stringify(evidence, null, 2)}\n`);
  return exitCodeFor(evidence.status);
}

async function sameBytes(args) {
  const { values } = parseArgs({
    args,
    strict: true,
    options: {
      left: { type: "string" },
      right: { type: "string" },
      root: { type: "string", default: "." },
      help: { type: "boolean", short: "h" },
    },
  });
  if (values.help) {
    process.stdout.write("ai-ci same-bytes --left FILE --right FILE [--root DIR]\n");
    return 0;
  }
  const comparison = await compareBytes({
    root: values.root,
    left: required(values, "left"),
    right: required(values, "right"),
  });
  process.stdout.write(`${JSON.stringify(comparison, null, 2)}\n`);
  return comparison.same ? 0 : 1;
}

async function main() {
  const [command, ...args] = process.argv.slice(2);
  if (command === undefined || command === "help" || command === "--help" || command === "-h") {
    help();
    return 0;
  }
  if (command === "gate") return gate(args);
  if (command === "run") return run(args);
  if (command === "same-bytes") return sameBytes(args);
  throw new ContractError(`unknown command: ${command}`);
}

try {
  process.exitCode = await main();
} catch (error) {
  const prefix = error instanceof ContractError ? "NOT VERIFIED" : "ERROR";
  process.stderr.write(`${prefix}: ${error.message}\n`);
  process.exitCode = 2;
}
