#!/usr/bin/env python3
"""Bouwt het boek uit src/<fase>/week_NN.md en de code in labs/.

  pdf/cpu-design-cursus.pdf                 voor het scherm: alles in één bestand, klikbaar
  pdf/cpu-design-cursus-print.pdf           om af te drukken (recto-verso, rugmarge): tekst en antwoorden
  pdf/cpu-design-cursus-codeboek-print.pdf  om af te drukken: de lange listings, als tweede map
  build/site/                               de webcursus (GitHub Pages): ./build.py site, alleen pandoc nodig

Nodig: pandoc (3.1 of nieuwer) en typst (0.15). Gebruik:
  ./build.py              alle drie
  ./build.py scherm       alleen de schermversie (sneller tijdens het schrijven)
"""
import json, os, pathlib, re, shutil, subprocess, sys

root = pathlib.Path(__file__).resolve().parent
src = root / "src"
uit = root / "build" / "typst"
pdf = root / "pdf"
TYPST = os.environ.get("TYPST", "typst")
PANDOC = os.environ.get("PANDOC", "pandoc")


def hoofdstukken():
    """Leest de weken in: nummer, titel en fase (uit de mapnaam), plus het pad van elk hoofdstuk."""
    weken, paden = {}, {}
    for md in sorted(src.glob("*/week_*.md")):
        tekst = md.read_text()
        nr = int(md.stem[5:])
        titel = re.search(r"^# Week \d+: (.*)$", tekst, re.M).group(1).strip()
        weken[nr] = {"titel": titel, "fase": int(md.parent.name[:2])}
        paden[nr] = md
    return weken, paden


def fasen():
    """Thema en resultaat per fase, uit src/<fase>/fase.md (regels 'titel: ...' en 'resultaat: ...')."""
    info = {}
    for f in sorted(src.glob("*/fase.md")):
        velden = dict(re.findall(r"^(\w+): (.*)$", f.read_text(), re.M))
        info[int(f.parent.name[:2])] = {"titel": velden["titel"].strip(), "resultaat": velden["resultaat"].strip()}
    return info


def pandoc(md, **meta):
    args = [PANDOC, str(md), "-f", "markdown", "-t", "typst", "--wrap=none",
            "--lua-filter", str(root / "boek" / "filter.lua"), "-o", str(uit / (meta["sleutel"] + ".typ"))]
    meta["uitmap"] = str(uit)
    for k, v in meta.items():
        args += ["-M", f"{k}={v}"]
    subprocess.run(args, check=True, cwd=root)


def typst_tekst(s):
    return "[" + s.replace("\\", "\\\\").replace("[", "\\[").replace("]", "\\]").replace("#", "\\#") + "]"


def hoofdbestand(weken, fase_info, met_boek=True, met_codeboek=True, titel_sub=None):
    r = ['#import "/boek/boek.typ": *', "#show: boek"]
    r.append(f"#titelpagina(ondertitel: {typst_tekst(titel_sub) if titel_sub else 'none'})")
    r.append("#colofon()")
    r.append("#inhoud()")
    if met_boek:
        r.append('#include "00_syllabus.typ"')
        for fase, info in sorted(fase_info.items()):
            nrs = [n for n, w in sorted(weken.items()) if w["fase"] == fase]
            r.append(f"#deel({fase}, {typst_tekst(info['titel'])}, weken: {tuple(nrs) if len(nrs) > 1 else '(' + str(nrs[0]) + ',)'}, "
                     f"beschrijving: {typst_tekst(info['resultaat'] + '.')})")
            r += [f'#include "week{n:02d}.typ"' for n in nrs]
        r.append('#deel("bijlagen", [Bijlagen], beschrijving: [Naslag bij de cursus: een Verilog-spiekbrief, '
                 'de drie instructiesets, de 74HC-chips, formules, gereedschap en een woordenlijst.])')
        r.append('#include "99_bijlagen.typ"')
        r.append('#deel("antwoorden", [Antwoorden], beschrijving: [De antwoorden op de oefeningen en de zelftests, '
                 'per week. Probeer eerst zelf: een antwoord dat je opzoekt, onthoud je slechter dan een antwoord '
                 'dat je zelf vindt.])')
        r += [f'#include "week{n:02d}-antw.typ"' for n in sorted(weken)]
    if met_codeboek:
        r.append('#deel("codeboek", [Codeboek], beschrijving: [De lange listings uit de weken, volledig en met '
                 'regelnummers. In de tekst staat op hun plaats een verwijzing. Alle code staat ook in de map '
                 '`labs/` van de repository en wordt daar automatisch getest.])')
        r += [f'#include "week{n:02d}-code.typ"' for n in sorted(weken)]
    return "\n".join(r) + "\n"


def git_versie():
    return subprocess.run(["git", "describe", "--tags", "--always", "--dirty"], cwd=root,
                          capture_output=True, text=True).stdout.strip() or "ontwikkelversie"


def website():
    """Bouwt de webcursus in build/site/ (zie web/bouw.py)."""
    if not shutil.which(PANDOC):
        sys.exit(f"{PANDOC} niet gevonden (zie README: De PDF's bouwen)")
    sys.path.insert(0, str(root / "web"))
    import bouw
    weken, paden = hoofdstukken()
    problemen = bouw.bouw_site(weken, paden, fasen(), root / "build" / "site", git_versie())
    if problemen:
        sys.exit("De site heeft problemen:\n  " + "\n  ".join(problemen))
    print("ok  build/site/index.html")


def main():
    if sys.argv[1:] == ["site"]:
        return website()
    welke = sys.argv[1:] or ["scherm", "print", "codeboek"]
    for prog in (PANDOC, TYPST):
        if not shutil.which(prog):
            sys.exit(f"{prog} niet gevonden (zie README: De PDF's bouwen)")
    uit.mkdir(parents=True, exist_ok=True)
    pdf.mkdir(exist_ok=True)

    weken, paden = hoofdstukken()
    fase_info = fasen()
    (uit / "weken.json").write_text(json.dumps({"weken": {str(k): v for k, v in weken.items()}}, ensure_ascii=False))

    pandoc(src / "00_voorwerk" / "syllabus.md", sleutel="00_syllabus", soort="voor")
    pandoc(src / "99_bijlagen" / "bijlagen.md", sleutel="99_bijlagen", soort="bijlagen")
    for nr, w in weken.items():
        pandoc(paden[nr], sleutel=f"week{nr:02d}", soort="week", nr=nr, fase=w["fase"])

    versie = git_versie()
    uitgaven = {
        "scherm": ("main-scherm.typ", hoofdbestand(weken, fase_info), "scherm", "cpu-design-cursus.pdf"),
        "print": ("main-print.typ", hoofdbestand(weken, fase_info, met_codeboek=False), "print",
                  "cpu-design-cursus-print.pdf"),
        "codeboek": ("main-codeboek.typ", hoofdbestand(weken, fase_info, met_boek=False, titel_sub="Codeboek"),
                     "print", "cpu-design-cursus-codeboek-print.pdf"),
    }
    for naam in welke:
        bestand, inhoud, modus, doel = uitgaven[naam]
        (uit / bestand).write_text(inhoud)
        zonder_tags = ["--no-pdf-tags"] if modus == "print" else []  # op papier geen nut, en scheelt veel grootte
        subprocess.run([TYPST, "compile", *zonder_tags, "--root", str(root), "--font-path", str(root / "boek" / "fonts"),
                        "--ignore-system-fonts", "--input", f"modus={modus}", "--input", f"versie={versie}",
                        "--input", f"uitgave={naam}", str(uit / bestand), str(pdf / doel)], check=True, cwd=root)
        print(f"ok  pdf/{doel}")


if __name__ == "__main__":
    main()
