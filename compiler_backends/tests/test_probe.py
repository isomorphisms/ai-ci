import importlib.util
from pathlib import Path
import tempfile
import unittest


MODULE_PATH = Path(__file__).parents[1] / "probe.py"
SPEC = importlib.util.spec_from_file_location("compiler_backend_probe", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
probe = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(probe)


class ProbeTests(unittest.TestCase):
    def write_matrix(self, directory: Path, rows: list[str]) -> Path:
        path = directory / "matrix.tsv"
        path.write_text(
            "backend\tmetric\tpath\tneedle\n" + "\n".join(rows) + "\n",
            encoding="utf-8",
        )
        return path

    def test_present_absent_and_missing_files_are_observations(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            (root / "IR.idr").write_text("AddFloat32\n", encoding="utf-8")
            matrix = self.write_matrix(
                root,
                [
                    "thumb\tarith.add\tIR.idr\tAddFloat32",
                    "thumb\tarith.subtract\tIR.idr\tSubtractFloat32",
                    "thumb\tmemory.load\tMissing.idr\tLoadFloat32",
                ],
            )

            rows = probe.load_matrix(matrix)
            observed = probe.observe(rows, {"thumb": root})

            by_metric = {row["metric"]: row for row in observed}
            self.assertEqual(by_metric["arith.add"]["present"], "1")
            self.assertEqual(by_metric["arith.add"]["readable"], "1")
            self.assertEqual(by_metric["arith.subtract"]["present"], "0")
            self.assertEqual(by_metric["arith.subtract"]["readable"], "1")
            self.assertEqual(by_metric["memory.load"]["present"], "0")
            self.assertEqual(by_metric["memory.load"]["readable"], "0")

    def test_rows_are_sorted_for_repeatable_output(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            matrix = self.write_matrix(
                root,
                [
                    "z\tm2\tfile\tneedle",
                    "a\tm9\tfile\tneedle",
                    "a\tm1\tfile\tneedle",
                ],
            )
            rows = probe.load_matrix(matrix)
            self.assertEqual(
                [(row["backend"], row["metric"]) for row in rows],
                [("a", "m1"), ("a", "m9"), ("z", "m2")],
            )

    def test_duplicate_backend_metric_is_rejected(self):
        with tempfile.TemporaryDirectory() as raw:
            root = Path(raw)
            matrix = self.write_matrix(
                root,
                [
                    "thumb\tarith.add\tA\tone",
                    "thumb\tarith.add\tB\ttwo",
                ],
            )
            with self.assertRaises(ValueError):
                probe.load_matrix(matrix)


if __name__ == "__main__":
    unittest.main()
