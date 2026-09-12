import importlib.util
from pathlib import Path
import unittest


ROOT = Path(__file__).parents[1]
MODULE_PATH = ROOT / "probe.py"
MATRIX_PATH = ROOT / "fp16_probes.tsv"
SPEC = importlib.util.spec_from_file_location("compiler_backend_probe_fp16", MODULE_PATH)
assert SPEC is not None and SPEC.loader is not None
probe = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(probe)


class FP16MatrixTests(unittest.TestCase):
    def test_parallel_fp16_surface_is_complete_and_unique(self):
        rows = probe.load_matrix(MATRIX_PATH)
        metrics = {row["metric"] for row in rows}
        self.assertEqual(
            metrics,
            {
                "fp16.semantic_width_declared",
                "fp16.f16_selects_mediump",
                "fp16.f32_selects_highp",
                "fp16.default_remains_f32",
                "fp16.portable_exact_f16_not_claimed",
                "fp16.powervr_profile_native",
                "fp16.test_widths_distinct",
                "fp16.test_scalar_mediump",
                "fp16.test_vec2_mediump",
                "fp16.test_vec3_mediump",
                "fp16.test_vec4_mediump",
                "fp16.test_generic_not_native",
                "fp16.test_powervr_native",
                "fp16.test_powervr_vector",
                "fp16.test_no_silent_f32_demotion",
                "fp16.compiler_directive_parsed",
                "fp16.checked_ir_width_selected",
                "fp16.emitter_width_selected",
                "fp16.invalid_width_rejected",
                "fp16.compiler_test_f16",
                "fp16.ir_scalar_width_carried",
                "fp16.ir_vector_width_carried",
                "fp16.ir_array_width_carried",
                "fp16.explicit_f16_to_f32",
                "fp16.explicit_f32_to_f16",
                "fp16.emitter_width_aware",
                "fp16.source_type_exposed",
                "fp16.powervr_framebuffer_oracle_ci",
            },
        )
        self.assertTrue(all(row["backend"] == "idris-shader-backend" for row in rows))

    def test_matrix_separates_whole_shader_mode_from_mixed_width_milestones(self):
        rows = probe.load_matrix(MATRIX_PATH)
        metrics = {row["metric"] for row in rows}
        for metric in {
            "fp16.compiler_directive_parsed",
            "fp16.checked_ir_width_selected",
            "fp16.emitter_width_selected",
            "fp16.invalid_width_rejected",
            "fp16.compiler_test_f16",
        }:
            self.assertIn(metric, metrics)
        for metric in {
            "fp16.ir_scalar_width_carried",
            "fp16.ir_vector_width_carried",
            "fp16.ir_array_width_carried",
            "fp16.explicit_f16_to_f32",
            "fp16.explicit_f32_to_f16",
            "fp16.source_type_exposed",
            "fp16.powervr_framebuffer_oracle_ci",
        }:
            self.assertIn(metric, metrics)

    def test_matrix_observes_policy_tests_compiler_and_target_milestones(self):
        rows = probe.load_matrix(MATRIX_PATH)
        metrics = {row["metric"] for row in rows}
        self.assertTrue(any(metric.startswith("fp16.test_") for metric in metrics))
        self.assertTrue(any("ir_" in metric for metric in metrics))
        self.assertIn("fp16.compiler_test_f16", metrics)
        self.assertIn("fp16.powervr_profile_native", metrics)
        self.assertIn("fp16.powervr_framebuffer_oracle_ci", metrics)


if __name__ == "__main__":
    unittest.main()
