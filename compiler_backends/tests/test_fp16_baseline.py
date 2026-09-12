import importlib.util
from pathlib import Path
import tempfile
import unittest


MODULE_PATH = Path(__file__).parents[1] / "fp16_baseline.py"
SPEC = importlib.util.spec_from_file_location("fp16_baseline", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
baseline = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(baseline)


class FP16BaselineTests(unittest.TestCase):
    def test_established_observation_passes(self):
        expected = {"fp16.test": "1"}
        observations = {
            "fp16.test": {
                "backend": "idris-shader-backend",
                "metric": "fp16.test",
                "readable": "1",
                "present": "1",
                "path": "x",
                "needle": "y",
            }
        }
        self.assertEqual(baseline.regressions(expected, observations), [])

    def test_missing_or_regressed_observation_fails(self):
        expected = {"fp16.present": "1", "fp16.missing": "1"}
        observations = {
            "fp16.present": {
                "backend": "idris-shader-backend",
                "metric": "fp16.present",
                "readable": "1",
                "present": "0",
                "path": "x",
                "needle": "y",
            }
        }
        failures = baseline.regressions(expected, observations)
        self.assertIn("fp16.missing: missing observation", failures)
        self.assertIn(
            "fp16.present: expected present=1, observed present=0", failures
        )

    def test_unreadable_source_is_not_accepted_as_absence(self):
        expected = {"fp16.test": "0"}
        observations = {
            "fp16.test": {
                "backend": "idris-shader-backend",
                "metric": "fp16.test",
                "readable": "0",
                "present": "0",
                "path": "missing",
                "needle": "y",
            }
        }
        self.assertEqual(
            baseline.regressions(expected, observations),
            ["fp16.test: source unreadable"],
        )


if __name__ == "__main__":
    unittest.main()
