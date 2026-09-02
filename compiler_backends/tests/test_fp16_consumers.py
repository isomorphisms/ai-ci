import importlib.util
from pathlib import Path
import unittest


ROOT = Path(__file__).parents[1]
MODULE_PATH = ROOT / "probe.py"
MATRIX_PATH = ROOT / "fp16_consumers.tsv"
SPEC = importlib.util.spec_from_file_location("compiler_backend_probe_fp16_consumers", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
probe = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(probe)


class FP16ConsumerMatrixTests(unittest.TestCase):
    def test_algebraic_variety_consumer_surface_is_complete_and_unique(self):
        rows = probe.load_matrix(MATRIX_PATH)
        metrics = {row["metric"] for row in rows}
        self.assertEqual(
            metrics,
            {
                "fp16.consumer.ave.backend_revision_pin",
                "fp16.consumer.ave.f16_compile",
                "fp16.consumer.ave.f32_compile",
                "fp16.consumer.ave.f16_ir_and_mediump",
                "fp16.consumer.ave.f32_ir_and_highp",
                "fp16.consumer.ave.glsl_validation",
                "fp16.consumer.ave.invalid_f64_rejected",
                "fp16.consumer.ave.evidence_retained",
            },
        )
        self.assertTrue(
            all(row["backend"] == "algebraic-variety-explorer-mobile" for row in rows)
        )

    def test_consumer_keeps_f16_and_f32_evidence_separate(self):
        rows = probe.load_matrix(MATRIX_PATH)
        metrics = {row["metric"] for row in rows}
        self.assertIn("fp16.consumer.ave.f16_compile", metrics)
        self.assertIn("fp16.consumer.ave.f32_compile", metrics)
        self.assertIn("fp16.consumer.ave.f16_ir_and_mediump", metrics)
        self.assertIn("fp16.consumer.ave.f32_ir_and_highp", metrics)
        self.assertIn("fp16.consumer.ave.invalid_f64_rejected", metrics)


if __name__ == "__main__":
    unittest.main()
