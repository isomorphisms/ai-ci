"""Source scanner must not confuse literals, comments or floor division."""
import importlib.util
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]
PATH = ROOT / "scripts" / "audit_division_glyph.py"
spec = importlib.util.spec_from_file_location("division_audit", PATH)
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


class DivisionGlyphTests(unittest.TestCase):
    def kinds(self, source, language):
        return [x["kind"] for x in audit.scan_text(source, language)]

    def test_c_operators_comments_preprocessor_and_strings(self):
        source = (
            '#include <sys/a.h>\n'
            '#define URL "http://a/b"\n'
            'float x = 12 / 3; /* / */ // /\n'
            'float y = 6 ÷ 2; char *s = "/";\n'
            'x /= 2;\n'
        )
        self.assertEqual(
            self.kinds(source, "c"),
            ["ascii_division_candidate", "division_glyph", "compound_division"],
        )

    def test_lua_floor_is_different_from_true_division(self):
        source = (
            'local x = 12 / 3; local y = 12 // 3\n'
            '-- / ÷\n'
            'local z = [=[ / ÷ ]=]\n'
            '--[=[ / ÷ ]=]\n'
            'return 12 ÷ 3\n'
        )
        self.assertEqual(
            self.kinds(source, "lua"),
            ["ascii_division_candidate", "lua_floor_division", "division_glyph"],
        )

    def test_idric_nested_comment_and_distinct_inequality(self):
        source = (
            'value = 12 / 3\n'
            '-- /\n'
            '{- / {- ÷ -} / -}\n'
            'neq = value /= 4\n'
            'result = 12 ÷ 3\n'
        )
        self.assertEqual(
            self.kinds(source, "idric"),
            ["ascii_division_candidate", "non_arithmetic_slash_equals",
             "division_glyph"],
        )

    def test_exclude_vendor_sources_and_keep_maintained_files(self):
        self.assertIsNone(audit.classify(pathlib.Path("vendor/lib/source.c")))
        self.assertIsNone(audit.classify(pathlib.Path("out/demo.lua")))
        self.assertEqual(audit.classify(pathlib.Path("fourier/fft.c")), "c")
        self.assertEqual(audit.classify(pathlib.Path("src/Shape.idric")), "idric")


if __name__ == "__main__":
    unittest.main()
