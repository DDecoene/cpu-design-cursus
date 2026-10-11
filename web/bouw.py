"""Bouwt de website: pandoc-HTML per hoofdstuk, in een sjabloon met zijbalk, navigatie en zoekindex.

Wordt aangeroepen door `build.py site`. Alles komt in build/site/ (relatieve links, dus ook onder
https://<naam>.github.io/<repo>/ te gebruiken).
"""
import html
import json
import os
import pathlib
import posixpath
import re
import shutil
import string
import subprocess
import sys

from pagina import lees

WEB = pathlib.Path(__file__).resolve().parent
ROOT = WEB.parent
PANDOC = os.environ.get("PANDOC", "pandoc")
REPO = "https://github.com/DDecoene/cpu-design-cursus"
RELEASE = REPO + "/releases/latest/download/"
# bestandsnamen van de release (zie build.py); test_site.py bewaakt dat ze kloppen
PDFS = [
    ("cpu-design-cursus.pdf", "Voor het scherm", "alles in één bestand, met klikbare inhoud en verwijzingen"),
    ("cpu-design-cursus-print.pdf", "Om af te drukken", "recto-verso op A4, met een bredere binnenmarge voor een ringmap"),
    ("cpu-design-cursus-codeboek-print.pdf", "Codeboek", "de lange listings, als tweede map naast het boek"),
]
esc = html.escape


def pandoc_html(md, **meta):
    args = [PANDOC, str(md), "-f", "markdown", "-t", "html5", "--wrap=none", "--lua-filter", str(WEB / "filter.lua")]
    for k, v in meta.items():
        args += ["-M", f"{k}={v}"]
    r = subprocess.run(args, cwd=ROOT, capture_output=True, text=True)
    if r.returncode:
        sys.exit(f"pandoc faalde op {md}:\n{r.stderr}")
    return r.stdout


def weken_van_fase(weken, fase):
    return [n for n, w in sorted(weken.items()) if w["fase"] == fase]


def zijbalk(weken, fase_info, huidig, basis):
    def top(sleutel, pad, tekst):
        cur = ' aria-current="page"' if huidig == sleutel else ""
        return f'<a class="top" href="{basis}{pad}"{cur}>{tekst}</a>'

    r = [top("start", "", "Start"), top("syllabus", "syllabus/", "Syllabus")]
    for fase, info in sorted(fase_info.items()):
        nrs = weken_van_fase(weken, fase)
        open_ = " open" if huidig in nrs else ""
        r.append(f'<details class="fase"{open_}><summary>Fase {fase} · {esc(info["titel"])}</summary><ul>')
        for n in nrs:
            cur = ' aria-current="page"' if n == huidig else ""
            r.append(f'<li><a href="{basis}week/{n:02d}/" data-week="{n}"{cur}>'
                     f'<span class="vink" aria-hidden="true"></span>Week {n}: {esc(weken[n]["titel"])}</a></li>')
        r.append("</ul></details>")
    r.append(top("bijlagen", "bijlagen/", "Bijlagen"))
    return "\n".join(r)


def fasekaarten(weken, fase_info, basis):
    r = ['<section id="fasen"><h2>De zeven fasen</h2><div class="kaarten">']
    for fase, info in sorted(fase_info.items()):
        nrs = weken_van_fase(weken, fase)
        bereik = f"Week {nrs[0]}" if len(nrs) == 1 else f"Week {nrs[0]} tot {nrs[-1]}"
        r.append(f'<article class="fase-kaart" data-fase="{fase}">'
                 f'<h3><a href="{basis}week/{nrs[0]:02d}/">Fase {fase} · {esc(info["titel"])}</a></h3>'
                 f'<p>{esc(info["resultaat"])}.</p><p class="weken">{bereik}</p>'
                 f'<progress max="{len(nrs)}" value="0"></progress> <span class="fase-tekst">0 van {len(nrs)} weken</span>'
                 f"</article>")
    r.append("</div></section>")
    return "\n".join(r)


def downloads():
    r = ['<section id="downloads"><h2>Het boek als PDF</h2>',
         "<p>Dezelfde cursus als boek, voor offline lezen en afdrukken. De PDF's worden bij elke release opnieuw gebouwd.</p><ul>"]
    for naam, titel, uitleg in PDFS:
        r.append(f'<li><a href="{RELEASE}{naam}">{esc(titel)}</a>: {esc(uitleg)}</li>')
    r.append("</ul></section>")
    return "\n".join(r)


VOORTGANG = """<section id="voortgang"><h2>Mijn voortgang</h2>
<p>Je voortgang wordt alleen in deze browser bewaard, op dit apparaat. Wil je hem meenemen of bewaren, gebruik dan een bestand.</p>
<p><button id="export" type="button" class="knop rand">Bewaar als bestand</button>
<label class="knop rand">Laad uit bestand<input id="import" type="file" accept=".json,application/json" hidden></label></p>
<p id="importmelding" role="status"></p></section>"""

OPSLAGMELDING = '<p id="opslagmelding" role="status" hidden>Voortgang wordt in deze browser niet bewaard.</p>'


def weeknav(n, nrs, basis):
    i = nrs.index(n)
    if i > 0:
        vorig = f'<a rel="prev" href="{basis}week/{nrs[i - 1]:02d}/">← Week {nrs[i - 1]}</a>'
    else:
        vorig = f'<a rel="prev" href="{basis}syllabus/">← Syllabus</a>'
    if i < len(nrs) - 1:
        volgend = f'<a rel="next" href="{basis}week/{nrs[i + 1]:02d}/">Week {nrs[i + 1]} →</a>'
    else:
        volgend = f'<a rel="next" href="{basis}bijlagen/">Bijlagen →</a>'
    return (f'<p class="afvinken"><button id="afvinken" type="button" data-week="{n}" aria-pressed="false">'
            f"Markeer als gedaan</button></p>{OPSLAGMELDING}"
            f'<nav class="vorig-volgend" aria-label="Vorige en volgende week">{vorig}{volgend}</nav>')


def toc(p):
    items = [f'<li class="n{n}"><a href="#{i}">{esc(t)}</a></li>' for n, i, t in p.kopjes if n in (2, 3) and i]
    return "<h2>Op deze pagina</h2><ul>" + "".join(items) + "</ul>" if items else ""


def bouw_site(weken, paden, fase_info, uit, versie):
    """Schrijft de hele site naar `uit` en geeft de lijst met gevonden problemen terug (leeg = goed)."""
    uit = pathlib.Path(uit)
    if uit.exists():
        shutil.rmtree(uit)
    uit.mkdir(parents=True)
    for m in ("css", "js"):
        shutil.copytree(WEB / m, uit / m)
    maxweek = max(weken)
    sjabloon = string.Template((WEB / "sjabloon.html").read_text())
    cursus = json.dumps({
        "maxweek": maxweek,
        "fasen": [{"nr": f, "weken": weken_van_fase(weken, f)} for f in sorted(fase_info)],
    }).replace("</", "<\\/")
    nrs = sorted(weken)
    zoek = []
    verwacht = ["index.html", "syllabus/index.html", "bijlagen/index.html"] + [f"week/{n:02d}/index.html" for n in nrs]

    def schrijf(rel, diepte, huidig, inhoud, onderaan="", in_zoek=True):
        basis = "../" * diepte
        inhoud = inhoud.replace("@BASIS@", basis)
        p = lees(inhoud)
        titel = p.kopjes[0][2] if p.kopjes else "CPU Design Cursus"
        pagina = sjabloon.substitute(
            titel=esc(titel if huidig == "start" else f"{titel} · CPU Design Cursus"), basis=basis,
            zijbalk=zijbalk(weken, fase_info, huidig, basis), inhoud=inhoud,
            onderaan=onderaan.replace("@BASIS@", basis), toc=toc(p), versie=esc(versie), cursus=cursus)
        doel = uit / rel
        doel.parent.mkdir(parents=True, exist_ok=True)
        doel.write_text(pagina)
        if in_zoek:
            for s in p.secties:
                zoek.append({"u": posixpath.dirname(rel) + "/" + (f"#{s['id']}" if s["id"] else ""),
                             "p": titel, "k": s["kop"], "t": s["tekst"]})

    meta = dict(maxweek=maxweek)
    start = pandoc_html(WEB / "start.md", soort="start", **meta)
    schrijf("index.html", 0, "start",
            start + fasekaarten(weken, fase_info, "@BASIS@") + downloads() + VOORTGANG + OPSLAGMELDING, in_zoek=False)
    schrijf("syllabus/index.html", 1, "syllabus", pandoc_html(ROOT / "src/00_voorwerk/syllabus.md", soort="voor", **meta))
    schrijf("bijlagen/index.html", 1, "bijlagen", pandoc_html(ROOT / "src/99_bijlagen/bijlagen.md", soort="bijlagen", **meta))
    for n in nrs:
        schrijf(f"week/{n:02d}/index.html", 2, n,
                pandoc_html(paden[n], soort="week", nr=n, **meta), onderaan=weeknav(n, nrs, "@BASIS@"))
    (uit / "zoek.json").write_text(json.dumps(zoek, ensure_ascii=False, separators=(",", ":")))
    return controleer(uit, verwacht)


def controleer(uit, verwacht):
    """Zoekt ontbrekende pagina's en kapotte interne links (naar een pagina of een kop die er niet is)."""
    uit = pathlib.Path(uit)
    paginas = {p.relative_to(uit).as_posix(): lees(p.read_text()) for p in uit.rglob("index.html")}
    problemen = [f"ontbrekende pagina: {v}" for v in sorted(set(verwacht) - set(paginas))]
    for naam, p in sorted(paginas.items()):
        for href in p.links:
            if re.match(r"^(https?:|mailto:)", href):
                continue
            doel, _, frag = href.partition("#")
            if doel:
                pad = posixpath.normpath(posixpath.join(posixpath.dirname(naam), doel))
                pad = "index.html" if pad == "." else pad if pad.endswith(".html") else pad + "/index.html"
            else:
                pad = naam
            if pad not in paginas:
                problemen.append(f"{naam}: link naar onbekende pagina {href}")
            elif frag and frag not in paginas[pad].ids:
                problemen.append(f"{naam}: link naar onbekende kop {href}")
    return problemen
