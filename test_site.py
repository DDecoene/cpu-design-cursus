#!/usr/bin/env python3
"""Tests voor de website: de HTML-lezer, de linkcontrole, het pandoc-filter en de PDF-namen.

  python3 test_site.py           (de JS-tests draaien apart: node --test web/test/*.test.js)
"""
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "web"))
from pagina import lees  # noqa: E402


class PaginaTest(unittest.TestCase):
    def test_kopjes_ids_links_en_tekst_zonder_code(self):
        p = lees('<h1 id="a">Titel</h1><p>Intro <a href="x/">l</a></p><h2 id="b">Deel</h2>'
                 '<pre><code><span id="cb1">skip</span></code></pre><p>Tekst &amp; meer</p>')
        self.assertEqual(p.kopjes, [(1, "a", "Titel"), (2, "b", "Deel")])
        self.assertEqual(p.links, ["x/"])
        self.assertEqual(p.ids, {"a", "b", "cb1"})
        self.assertEqual(p.secties, [{"id": "a", "kop": "Titel", "tekst": "Intro l"},
                                     {"id": "b", "kop": "Deel", "tekst": "Tekst & meer"}])


if __name__ == "__main__":
    unittest.main()
