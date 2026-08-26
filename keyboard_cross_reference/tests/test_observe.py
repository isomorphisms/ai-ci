import io
from pathlib import Path
import tempfile
import unittest

import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import observe


HARDWARE = r"""
movement : Board
movement = MkBoard "cursor"
  [ [ one "MOVE" ] ]

programming : Board
programming = MkBoard "program"
  [ [ two "ASSIGN" "LEFT", one "LAMBDA", one "FLOAT", two "NEW" "THING" ] ]
"""

SOFTWARE = r"""
pages =
  [ Page "Programming"
      [ Row
          [ text_key "←\nASSIGN" "←", text_key "λ" "λ"
          , text_key "𝔽\nFLOAT" "𝔽", text_key "THIN\nSPACE" " "
          ]
      ]
  , Page "Unicode"
      [ Row [ text_key "∞" "∞" ] ]
  ]
"""


class KeyboardCrossReferenceTests(unittest.TestCase):
    def test_parses_and_normalizes_both_layout_languages(self):
        hardware = observe.parse_hardware(HARDWARE)
        software = observe.parse_software(SOFTWARE)

        self.assertEqual(
            hardware["programming"],
            {"ASSIGN LEFT", "LAMBDA", "FLOAT", "NEW THING"},
        )
        self.assertEqual(
            software["Programming"],
            {"ASSIGN", "LAMBDA", "FLOAT", "THIN SPACE"},
        )

    def test_observation_keeps_directional_differences(self):
        rows = observe.observe(
            observe.parse_hardware(HARDWARE),
            observe.parse_software(SOFTWARE),
            [
                {
                    "hardware_board": "movement",
                    "software_page": "-",
                    "mode": "hardware_only",
                },
                {
                    "hardware_board": "programming",
                    "software_page": "Programming",
                    "mode": "mirror",
                },
            ],
        )

        relations = {
            (row["relation"], row["hardware_board"], row["software_page"], row["concept"])
            for row in rows
        }
        self.assertIn(("shared", "programming", "Programming", "FLOAT"), relations)
        self.assertIn(("shared", "programming", "Programming", "LAMBDA"), relations)
        self.assertIn(
            ("hardware_only", "programming", "Programming", "NEW THING"),
            relations,
        )
        self.assertIn(
            ("software_only", "programming", "Programming", "THIN SPACE"),
            relations,
        )
        self.assertIn(("hardware_only_board", "movement", "", ""), relations)
        self.assertIn(("unmapped_software_page", "", "Unicode", ""), relations)

    def test_new_hardware_board_is_never_silently_ignored(self):
        rows = observe.observe(
            observe.parse_hardware(HARDWARE),
            observe.parse_software(SOFTWARE),
            [
                {
                    "hardware_board": "programming",
                    "software_page": "Programming",
                    "mode": "mirror",
                }
            ],
        )
        self.assertIn(
            {
                "hardware_board": "movement",
                "software_page": "",
                "relation": "unmapped_hardware_board",
                "concept": "",
            },
            rows,
        )

    def test_map_rejects_duplicate_hardware_board(self):
        text = (
            "hardware_board\tsoftware_page\tmode\n"
            "programming\tProgramming\tmirror\n"
            "programming\t-\thardware_only\n"
        )
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "map.tsv"
            path.write_text(text, encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "duplicate hardware board"):
                observe.load_map(path)

    def test_tsv_output_is_stable(self):
        rows = [
            {
                "hardware_board": "programming",
                "software_page": "Programming",
                "relation": "shared",
                "concept": "FLOAT",
            }
        ]
        output = io.StringIO()
        observe.write_tsv(rows, output)
        self.assertEqual(
            output.getvalue(),
            "hardware_board\tsoftware_page\trelation\tconcept\n"
            "programming\tProgramming\tshared\tFLOAT\n",
        )


if __name__ == "__main__":
    unittest.main()
