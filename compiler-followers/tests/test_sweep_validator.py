#!/usr/bin/env python3
"""Offline acceptance tests. All generated reviews and Git histories are synthetic."""
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HEADER = "commit\tdimensions\ttarget\toutcome\trationale\n"
OUTCOMES = ["apply", "adapt", "already-covered", "not-applicable", "defer-measurement"]


def git(repo, *args):
    return subprocess.run(["git", "-C", str(repo), *args], check=True,
                          text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                          timeout=15).stdout.strip()


class SweepTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.upstream = self.work / "upstream"
        self.upstream.mkdir()
        git(self.upstream, "init", "-q", "-b", "main")
        git(self.upstream, "config", "user.name", "fixture")
        git(self.upstream, "config", "user.email", "fixture@example.invalid")
        (self.upstream / "root").write_text("base\n")
        git(self.upstream, "add", ".")
        git(self.upstream, "commit", "-qm", "base")
        self.start = git(self.upstream, "rev-parse", "HEAD")
        git(self.upstream, "checkout", "-qb", "side")
        for number in [1, 2]:
            (self.upstream / "side").write_text(str(number))
            git(self.upstream, "add", ".")
            git(self.upstream, "commit", "-qm", "side " + str(number))
        self.side = git(self.upstream, "rev-parse", "HEAD")
        git(self.upstream, "checkout", "-q", "main")
        (self.upstream / "main").write_text("main\n")
        git(self.upstream, "add", ".")
        git(self.upstream, "commit", "-qm", "main change")
        self.before_merge = git(self.upstream, "rev-parse", "HEAD")
        git(self.upstream, "merge", "-q", "--no-ff", "side", "-m", "merge")
        self.end = git(self.upstream, "rev-parse", "HEAD")
        self.commits = git(self.upstream, "rev-list", "--reverse", "--topo-order",
                           self.start + ".." + self.end).splitlines()
        self.aici = self.work / "aici"
        self.receipt = self.aici / "compiler-followers/arm-thumb-sweep"
        self.receipt.mkdir(parents=True)
        self.policy = self.receipt.parent / "policy.tsv"
        shutil.copyfile(ROOT / "policy.tsv", self.policy)
        self.checkpoint = self.receipt.parent / "arm-thumb.checkpoint"
        self.checkpoint.write_text(self.start + "\n")
        self.targets = [line.split("\t")[0] for line in self.policy.read_text().splitlines()[1:]]
        self.rows = [[commit, "2", target, OUTCOMES[i % len(OUTCOMES)],
                      "Synthetic fixture only; no implementation evidence."]
                     for commit in self.commits for i, target in enumerate(self.targets)]
        self.meta = {"receipt_version": "2", "upstream_repository": "isomorphisms/idric-arm-thumb",
                     "upstream_ref": "main", "from": self.start, "through": self.end,
                     "policy_sha256": hashlib.sha256(self.policy.read_bytes()).hexdigest(),
                     "coverage": "full-policy-matrix"}
        self.save()
        git(self.aici, "init", "-q", "-b", "main")
        git(self.aici, "config", "user.name", "fixture")
        git(self.aici, "config", "user.email", "fixture@example.invalid")
        git(self.aici, "add", ".")
        git(self.aici, "commit", "-qm", "trusted checkpoint")
        self.base = git(self.aici, "rev-parse", "HEAD")

    def save(self):
        (self.receipt / "meta.tsv").write_text("field\tvalue\n" + "".join(
            key + "\t" + value + "\n" for key, value in self.meta.items()))
        (self.receipt / "classifications.tsv").write_text(HEADER + "".join(
            "\t".join(row) + "\n" for row in self.rows))

    def invoke(self, expected="", *, start=None, end=None, upstream=None, base=None, ref="main"):
        env = dict(os.environ, UPSTREAM_GIT=str(upstream or self.upstream))
        if base is None:
            args = ["sh", str(ROOT / "validate-sweep.sh"), str(self.policy), str(self.receipt),
                    start or self.start, end or self.end, ref]
        else:
            args = ["sh", str(ROOT / "check-checkpoint.sh"), base, end or self.end, ref]
        protected = [self.checkpoint, self.policy, self.receipt / "meta.tsv",
                     self.receipt / "classifications.tsv"]
        before = {path: path.read_bytes() for path in protected if path.exists()}
        heads = [git(repo, "rev-parse", "HEAD") for repo in [self.aici, self.upstream]]
        result = subprocess.run(args, cwd=self.aici, env=env, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=15)
        self.assertEqual(before, {path: path.read_bytes() for path in before})
        self.assertEqual(heads, [git(repo, "rev-parse", "HEAD") for repo in [self.aici, self.upstream]])
        if expected:
            self.assertNotEqual(result.returncode, 0, result.stdout)
            self.assertIn(expected, result.stderr)
            self.assertNotIn("result\tPASS", result.stdout)
        else:
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("result\tPASS\n", result.stdout)
            self.assertIn("checkpoint_action\tread-only\n", result.stdout)
            self.assertIn("merge_readiness\tnot-asserted\n", result.stdout)
            self.assertIn("target_execution\tnot-asserted\n", result.stdout)
        return result

    def test_full_matrix_all_outcomes_and_side_history(self):
        result = self.invoke()
        self.assertIn("commit_count\t4\n", result.stdout)
        self.assertIn("classification_count\t" + str(4 * len(self.targets)) + "\n", result.stdout)

    def test_each_individual_row_is_required(self):
        rows = self.rows[:]
        for index in range(len(rows)):
            with self.subTest(row=index):
                self.rows = rows[:index] + rows[index + 1:]
                self.save()
                self.invoke("matrix is incomplete")

    def test_zero_delta(self):
        self.meta["through"] = self.start
        self.rows = []
        self.save()
        self.invoke(end=self.start)

    def test_zero_delta_cannot_mask_latest(self):
        self.meta["through"] = self.start
        self.rows = []
        self.save()
        self.invoke("receipt ends at", base=self.base)

    def test_duplicate_row(self):
        self.rows.append(self.rows[0])
        self.save()
        self.invoke("duplicate commit/target")

    def test_missing_side_history(self):
        self.rows = [row for row in self.rows if row[0] != self.side]
        self.save()
        self.invoke("matrix is incomplete")

    def test_missing_merge(self):
        self.rows = [row for row in self.rows if row[0] != self.end]
        self.save()
        self.invoke("matrix is incomplete")

    def test_missing_target(self):
        self.rows = [row for row in self.rows if row[2] != "switch1-tegra-x1"]
        self.save()
        self.invoke("matrix is incomplete")

    def test_inconsistent_commit_dimensions(self):
        self.rows[0][1] = "3"
        self.save()
        self.invoke("inconsistent dimensions")

    def test_changed_policy(self):
        self.policy.write_text(self.policy.read_text().replace("Primary human-guided", "Lead human-guided"))
        self.invoke("exact policy")

    def test_forged_authority_in_policy(self):
        self.policy.write_text(self.policy.read_text().replace(
            "arm-thumb\tisomorphisms/idric-arm-thumb\tmain", "arm-thumb\tisomorphisms/other\tmain"))
        self.meta["policy_sha256"] = hashlib.sha256(self.policy.read_bytes()).hexdigest()
        self.save()
        self.invoke("primary authority")

    def test_empty_policy(self):
        self.policy.write_text("")
        self.invoke("invalid policy")

    def test_platform_cannot_become_codegen(self):
        self.policy.write_text(self.policy.read_text().replace(
            "switch\tplatform-overlay\tplatform-only", "switch\tcpu-codegen\tplatform-only"))
        self.invoke("invalid policy")

    def test_duplicate_metadata(self):
        with (self.receipt / "meta.tsv").open("a") as stream:
            stream.write("from\t" + self.start + "\n")
        self.invoke("unique version-2 fields")

    def test_unknown_metadata(self):
        self.meta["from_typo"] = self.meta.pop("from")
        self.save()
        self.invoke("unique version-2 fields")

    def test_missing_classifications(self):
        (self.receipt / "classifications.tsv").unlink()
        self.invoke("missing classifications.tsv")

    def test_missing_metadata(self):
        (self.receipt / "meta.tsv").unlink()
        self.invoke("missing meta.tsv")

    def test_reverse_ancestry(self):
        self.meta.update({"from": self.end, "through": self.start})
        self.save()
        self.invoke("not an ancestor", start=self.end, end=self.start)

    def test_divergent_ancestry(self):
        self.meta.update({"from": self.before_merge, "through": self.side})
        self.save()
        self.invoke("not an ancestor", start=self.before_merge, end=self.side)

    def test_shallow_history(self):
        shallow = self.work / "shallow"
        git(self.work, "clone", "-q", "--depth=1", self.upstream.as_uri(), str(shallow))
        self.invoke("shallow upstream history", upstream=shallow)

    def test_grafted_history(self):
        (self.upstream / ".git/info/grafts").write_text(self.end + "\n")
        self.invoke("grafted upstream history")

    def test_replace_refs_do_not_hide_history(self):
        git(self.upstream, "replace", self.end, self.start)
        self.invoke()

    def test_no_implicit_checkpoint_to_itself_default(self):
        result = subprocess.run(["sh", str(ROOT / "validate-sweep.sh")],
                                text=True, capture_output=True, timeout=15)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("usage:", result.stderr)

    def test_prospective_receipt_does_not_move_checkpoint(self):
        self.invoke(base=self.base)

    def test_complete_checkpoint_proposal_is_checked_not_written(self):
        self.checkpoint.write_text(self.end + "\n")
        self.invoke(base=self.base)

    def test_incomplete_checkpoint_proposal(self):
        self.checkpoint.write_text(self.end + "\n")
        self.rows.pop()
        self.save()
        self.invoke("matrix is incomplete", base=self.base)

    def test_forged_checkpoint_and_receipt_start(self):
        self.checkpoint.write_text(self.end + "\n")
        self.meta["from"] = self.end
        self.rows = []
        self.save()
        self.invoke("receipt starts at", base=self.base)

    def test_partial_checkpoint_proposal(self):
        self.checkpoint.write_text(self.before_merge + "\n")
        self.invoke("independently resolved upstream head", base=self.base)

    def test_alternate_ref_cannot_advance_main_checkpoint(self):
        self.checkpoint.write_text(self.end + "\n")
        self.invoke("must target ARM/Thumb main", base=self.base, ref="side")

    def test_unknown_base_is_not_bootstrap(self):
        self.invoke("trusted base commit is unavailable", base="a" * 40)

    def test_missing_checkpoint_in_existing_policy_is_not_bootstrap(self):
        git(self.aici, "rm", "-q", "compiler-followers/arm-thumb.checkpoint")
        git(self.aici, "commit", "-qm", "broken base")
        base = git(self.aici, "rev-parse", "HEAD")
        self.checkpoint.write_text(self.start + "\n")
        self.invoke("policy but no checkpoint", base=base)

    def test_bootstrap_uses_fixed_reviewed_seed(self):
        # New-branch events cannot trust an arbitrary candidate checkpoint.
        self.checkpoint.write_text(self.end + "\n")
        self.meta["from"] = self.end
        self.rows = []
        self.save()
        result = self.invoke("receipt starts at", base="0" * 40)
        self.assertIn("expected 5f132d2f68cdd5ee7ddd98788af882598ad4c2f8", result.stderr)

    def test_retained_transition_with_no_new_delta(self):
        self.checkpoint.write_text(self.end + "\n")
        git(self.aici, "add", ".")
        git(self.aici, "commit", "-qm", "already reviewed transition")
        self.invoke(base=git(self.aici, "rev-parse", "HEAD"))


# Independent test cases so a schema failure cannot mask an unrelated rejection.
def row_test(column, value, expected):
    def test(self):
        self.rows[0][column] = value
        self.save()
        self.invoke(expected)
    return test


for name, column, value, expected in [
    ("unknown_commit", 0, "a" * 40, "commit outside exact delta"),
    ("unknown_target", 2, "not-a-policy-target", "target outside policy"),
    ("unknown_dimension", 1, "6", "bad change dimensions"),
    ("repeated_dimension", 1, "2,2", "unique and ascending"),
    ("unsorted_dimensions", 1, "3,2", "unique and ascending"),
    ("pending_outcome", 3, "PENDING", "bad outcome"),
    ("blank_rationale", 4, "   ", "empty rationale"),
    ("excess_column", 4, "reason\textra", "bad classification field count"),
]:
    setattr(SweepTests, "test_" + name, row_test(column, value, expected))


def metadata_test(key, value, expected):
    def test(self):
        self.meta[key] = value
        self.save()
        self.invoke(expected)
    return test


for name, key, value, expected in [
    ("wrong_repository", "upstream_repository", "isomorphisms/other", "wrong upstream authority"),
    ("wrong_ref", "upstream_ref", "side", "different upstream ref"),
    ("forged_start", "from", "a" * 40, "receipt starts at"),
    ("stale_end", "through", "a" * 40, "receipt ends at"),
    ("wrong_coverage", "coverage", "some-targets", "full policy coverage"),
    ("legacy_receipt", "receipt_version", "1", "unsupported receipt version"),
]:
    setattr(SweepTests, "test_" + name, metadata_test(key, value, expected))


if __name__ == "__main__":
    unittest.main(verbosity=2)
