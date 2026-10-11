#!/usr/bin/env python3
"""Tests voor de website: de HTML-lezer, de linkcontrole, het pandoc-filter en de PDF-namen.

  python3 test_site.py           (de JS-tests draaien apart: node --test web/test/*.test.js)
"""
import pathlib
import shutil
import sys
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "web"))
import bouw  # noqa: E402
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


class ControleerTest(unittest.TestCase):
    def site(self, paginas):
        tmp = pathlib.Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, tmp)
        for rel, inhoud in paginas.items():
            (tmp / rel).parent.mkdir(parents=True, exist_ok=True)
            (tmp / rel).write_text(inhoud)
        return tmp

    def test_goede_site(self):
        tmp = self.site({
            "index.html": '<h1 id="top">Start</h1><a href="week/01/">w1</a><a href="https://example.org/x">ext</a>',
            "week/01/index.html": '<h2 id="k">Kop</h2><a href="../../">terug</a><a href="#k">hier</a>'
                                  '<a href="../../#top">kop op start</a>',
        })
        self.assertEqual(bouw.controleer(tmp, ["index.html", "week/01/index.html"]), [])

    def test_ontbrekende_pagina(self):
        tmp = self.site({"index.html": "<h1>x</h1>"})
        self.assertEqual(bouw.controleer(tmp, ["index.html", "week/02/index.html"]),
                         ["ontbrekende pagina: week/02/index.html"])

    def test_kapotte_links(self):
        tmp = self.site({
            "index.html": '<a href="week/09/">weg</a><a href="#bestaat-niet">kop</a>',
            "week/01/index.html": '<a href="../../#ook-niet">kop</a>',
        })
        p = bouw.controleer(tmp, [])
        self.assertEqual(len(p), 3)
        self.assertTrue(any("week/09/" in x for x in p))


class PdfNamenTest(unittest.TestCase):
    def test_namen_komen_voor_in_build_py(self):
        # de downloadknoppen wijzen naar releases/latest/download/<naam>: de naam moet kloppen met wat build.py maakt
        bron = (ROOT / "build.py").read_text()
        for naam, _, _ in bouw.PDFS:
            self.assertIn(f'"{naam}"', bron)


@unittest.skipUnless(shutil.which(bouw.PANDOC), "pandoc niet gevonden")
class FilterTest(unittest.TestCase):
    def md(self, tekst):
        tmp = pathlib.Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, tmp)
        f = tmp / "week.md"
        f.write_text(tekst)
        return f

    def test_week(self):
        vs = sorted((ROOT / "labs").rglob("*.v"))
        regels = lambda f: len(f.read_text().splitlines())
        kort = next(f for f in vs if regels(f) <= 40).relative_to(ROOT / "labs").as_posix()
        lang = next(f for f in vs if regels(f) > 40).relative_to(ROOT / "labs").as_posix()
        f = self.md(f"""<p class="subtitle">Fase 1 · Proef · ongeveer 12 uur</p>

# Week 3: Proef

## Wat je na deze week kunt

- iets

## 1. Deel

Zie week 2, week 31 en `week 4`.

```{{.verilog include="{kort}"}}
```

```{{.verilog include="{lang}"}}
```

## 9. Oefeningen

1. vraag

## 10. Antwoorden

1. ja

## 11. Zelftest

1. vraag

Antwoorden: (1) ja
""")
        h = bouw.pandoc_html(f, soort="week", nr=3, maxweek=30)
        self.assertIn('<h1 id="week-3-proef">Week 3: Proef</h1>', h)   # kop wordt geen link
        self.assertIn('<div class="subtitel">', h)
        self.assertIn('<div class="doelen">', h)
        self.assertIn('<a href="@BASIS@week/02/">week 2</a>', h)
        self.assertNotIn("week/31", h)                                 # buiten bereik
        self.assertNotIn("week/04", h)                                 # in code
        self.assertEqual(h.count('class="listing"'), 2)
        self.assertEqual(h.count('<details class="lang"'), 1)          # alleen de lange listing klapt
        self.assertEqual(h.count('<details class="antwoorden">'), 2)   # oefeningen en zelftest

    def test_ontbrekende_include_faalt(self):
        f = self.md('# Week 3: Proef\n\n```{.verilog include="bestaat/niet.v"}\n```\n')
        with self.assertRaises(SystemExit):
            bouw.pandoc_html(f, soort="week", nr=3, maxweek=30)


if __name__ == "__main__":
    unittest.main()
