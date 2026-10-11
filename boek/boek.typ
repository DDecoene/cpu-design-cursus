// Opmaak van het boek. build.py maakt de hoofdstukken (via pandoc en filter.lua)
// en een hoofdbestand per uitgave; dit bestand bepaalt hoe alles eruitziet.
//
// Invoer (typst --input):
//   modus   scherm | print   scherm: links klikbaar, geen lege pagina's
//                            print:  recto-verso, rugmarge, hoofdstukken op een rechterpagina
//   versie  bijvoorbeeld v0.3.0

#let modus = sys.inputs.at("modus", default: "scherm")
#let print = modus == "print"
#let versie = sys.inputs.at("versie", default: "ontwikkelversie")
#let repo = "https://github.com/DDecoene/cpu-design-cursus"
#let site = "https://ddecoene.github.io/cpu-design-cursus/"
#let gegevens = json("/build/typst/weken.json")

// ---------------------------------------------------------------- kleuren en letters
// Dezelfde stijl als de website: warm papier, een kleur per fase (1 t/m 7) en Nunito.
#let inkt = rgb("#2b2320")
#let papier = rgb("#fff8ee")
#let vlak = rgb("#fdeedd")
#let lijn = rgb("#ecd9c3")
#let grijs = rgb("#6b5a50")
#let accent = rgb("#c2255c")
#let rood = rgb("#b3261e")
#let rood-bleek = rgb("#fbeceb")
#let codebg = rgb("#fdf6ec")
#let achter = if print { white } else { papier }

#let fasekleuren = (rgb("#f03e3e"), rgb("#ffa94d"), rgb("#ffd166"), rgb("#06d6a0"), rgb("#4dabf7"), rgb("#7950f2"), rgb("#e64980"))
// tekstkleur op zo'n vlak
#let fase-opkleuren = (white, inkt, inkt, rgb("#12302a"), rgb("#0d2740"), white, white)
// kleur voor tekst op papier (donkerder, zodat het leesbaar blijft)
#let fase-tekstkleuren = (rgb("#c92a2a"), rgb("#d9480f"), rgb("#a07800"), rgb("#0b7a5a"), rgb("#1864ab"), rgb("#5f3dc4"), rgb("#c2255c"))

// De fase waarin we zitten (0 = geen fase: voorwerk en bijlagen); week-kop en deel zetten hem.
#let fase-nu = state("fase", 0)
// Alleen binnen een context te gebruiken:
#let fase-vlak() = { let f = fase-nu.get(); if f == 0 { accent } else { fasekleuren.at(f - 1) } }
#let fase-op() = { let f = fase-nu.get(); if f == 0 { white } else { fase-opkleuren.at(f - 1) } }
#let fase-tekst() = { let f = fase-nu.get(); if f == 0 { accent } else { fase-tekstkleuren.at(f - 1) } }

#let serif = ("Nunito", "Libertinus Serif")
#let sans = ("Nunito", "Libertinus Serif")
#let mono = ("IBM Plex Mono", "DejaVu Sans Mono")

// een afgeronde balk onder een kop
#let balk(kleur, breed: 22mm) = rect(width: breed, height: 2.4mm, radius: 1.2mm, fill: kleur)

// de "metrolijn" door de zeven fasen; actief = 0 kleurt alle stations
#let metro(actief: 0, breed: 100%, maat: 7mm) = block(width: breed, height: maat * 1.5, {
  place(top + left, dx: maat / 2, dy: (maat * 1.5 - 2mm) / 2, rect(width: 100% - maat, height: 2mm, radius: 1mm, fill: gradient.linear(..fasekleuren)))
  stack(dir: ltr, ..range(7).map(i => {
    let nu = actief == i + 1
    let d = if nu { maat * 1.4 } else { maat }
    (
      box(width: maat * 1.5, height: maat * 1.5, align(center + horizon,
        box(width: d, height: d, radius: 50%, fill: fasekleuren.at(i), stroke: 1.1mm + achter,
          align(center + horizon, text(size: d * 0.36, weight: "bold", fill: fase-opkleuren.at(i), str(i + 1)))))),
      if i < 6 { h(1fr) },
    )
  }).flatten())
})

// ---------------------------------------------------------------- hulpjes
#let sectienr = (..n) => n.pos().slice(1).map(str).join(".")

#let paginanr(loc) = numbering("1", ..counter(page).at(loc))

#let paginaverwijzing(lab, tekst: none) = context {
  let q = query(lab)
  if q.len() > 0 {
    let loc = q.first().location()
    link(loc, if tekst == none [blz. #paginanr(loc)] else [#tekst])
  }
}

#let week-titel(nr) = gegevens.weken.at(str(nr)).titel

#let taal-van(pad) = {
  let ext = pad.split(".").last()
  (
    v: "verilog", vh: "verilog", sv: "verilog",
    py: "python", sh: "bash",
    asm: "w8asm", tta: "w8asm", fs: "forth",
  ).at(ext, default: "text")
}

#let hoofdstuk-begin() = pagebreak(weak: true, to: if print { "odd" } else { none })

#let hoofdstuk-einde() = [#metadata("einde") <hoofdstukeinde>]

// ---------------------------------------------------------------- code
#let lees-code(pad, van: none, tot: none) = {
  let r = read("/labs/" + pad).split("\n")
  if r.len() > 0 and r.last() == "" { r = r.slice(0, -1) }
  let a = if van == none { 1 } else { van }
  let b = if tot == none { r.len() } else { tot }
  (r.slice(a - 1, b).join("\n"), a)
}

#let code-met-nummers(tekst, taal, start: 1) = {
  // het nummer in een vaste kolom; een te lange regel loopt verder in zijn eigen kolom
  show raw.where(block: true): it => grid(
    columns: (2.3em, 1fr), column-gutter: 0.9em, row-gutter: 0.48em,
    ..it.lines.map(l => (
      align(right, text(fill: grijs.lighten(20%), size: 0.85em, str(l.number + start - 1))),
      l.body,
    )).flatten(),
  )
  set par(justify: false, leading: 0.48em)
  raw(tekst, lang: taal, block: true)
}

#let listing-kop(nr, pad, extra: none) = text(font: sans, size: 8pt, fill: grijs)[
  #context text(fill: fase-tekst(), weight: "bold")[Listing #nr]
  #h(0.5em) #text(font: mono)[labs/#pad] #extra
]

#let listing(nr: "", pad: "", regels: 0, van: none, tot: none) = {
  let (tekst, start) = lees-code(pad, van: van, tot: tot)
  let kort = tekst.split("\n").len() <= 15
  let extra = if van != none [ · regels #van–#tot van #regels] else []
  context block(
    width: 100%, breakable: not kort, above: 1.1em, below: 1.1em,
    fill: codebg, stroke: (left: 3pt + fase-vlak(), rest: 0.8pt + lijn), radius: 5pt, inset: (x: 9pt, top: 7pt, bottom: 8pt),
  )[
    #listing-kop(nr, pad, extra: extra)
    #v(-3pt)
    #code-met-nummers(tekst, taal-van(pad), start: start)
  ]
}

#let codekaart(nr: "", pad: "", regels: 0, deel: false) = [#block(
  width: 100%, breakable: false, above: 1.1em, below: 1.1em,
  fill: vlak, stroke: 1pt + lijn, radius: 8pt, inset: 10pt,
)[
  #grid(
    columns: (auto, 1fr), column-gutter: 10pt, align: horizon,
    context box(fill: fase-vlak(), radius: 5pt, inset: (x: 6pt, y: 7pt),
      text(font: mono, size: 10pt, fill: fase-op(), weight: "bold")[</>]),
    [
      #set par(justify: false)
      #text(font: sans, size: 9.5pt)[
        #context text(fill: fase-tekst(), weight: "bold")[Listing #nr] #h(0.4em)
        #text(font: mono, size: 8.5pt)[labs/#pad] #h(0.4em) #text(fill: grijs)[#regels regels]
      ] \
      #text(size: 9pt)[
        #if deel [Het volledige bestand staat] else [De volledige code staat] in het
        #context {
          let q = query(label("cb-" + nr))
          if q.len() > 0 [#link(q.first().location())[codeboek, blz. #paginanr(q.first().location())]] else [codeboek onder listing #nr]
        }
        en op #link(repo + "/blob/main/labs/" + pad)[GitHub].
      ]
    ],
  )
]#label("kaart-" + nr)]

// losse codeblokken uit de tekst: voorbeelden, schema's, commando's
#let codeblok(taal: "text", tekst) = block(
  width: 100%, breakable: true, above: 1em, below: 1em,
  fill: codebg, stroke: 0.8pt + lijn, inset: (x: 9pt, y: 8pt), radius: 6pt,
  raw(tekst, lang: taal, block: true),
)

// ---------------------------------------------------------------- kaders
#let kader(soort: "info", titel: none, body) = context {
  let waarschuwing = soort == "waarschuwing"
  let rand = if waarschuwing { rood } else { fase-vlak() }
  let kleur = if waarschuwing { rood } else { fase-tekst() }
  let fond = if waarschuwing { rood-bleek } else { rand.lighten(85%) }
  block(
    width: 100%, breakable: true, above: 1.1em, below: 1.1em,
    fill: fond, stroke: 1.3pt + rand, radius: 8pt, inset: (x: 13pt, y: 10pt),
  )[
    #if titel != none { text(font: sans, weight: "bold", fill: kleur, titel); h(0.35em) }
    #body
  ]
}

#let leerdoelen(body) = context {
  let k = fase-vlak()
  block(
    width: 100%, breakable: false, above: 1.4em, below: 1.6em,
    fill: k.lighten(88%), stroke: 1.6pt + k, radius: 10pt, inset: (x: 15pt, top: 11pt, bottom: 13pt),
  )[
    #text(font: sans, size: 10pt, weight: "bold", fill: fase-tekst(), upper[Wat je na deze week kunt])
    #v(2pt)
    #set list(marker: text(fill: fase-tekst(), font: mono)[☐], indent: 0pt, body-indent: 0.6em)
    #body
  ]
}

#let naar-antwoorden(nr, zelftest: false) = block(above: 0.9em, below: 1.2em)[
  #text(font: sans, size: 9pt, fill: grijs)[
    #context text(fill: fase-tekst())[▸] #if zelftest [De antwoorden van de zelftest] else [De antwoorden van de oefeningen]
    staan achteraan in het boek, #paginaverwijzing(label("antw-" + str(nr))).
  ]
]

// ---------------------------------------------------------------- koppen en openers
#let week-kop(nr: 0, fase: 0, sub: none, titel) = {
  hoofdstuk-begin()
  fase-nu.update(fase)
  counter(heading).update((fase, nr - 1))
  v(14mm)
  context {
    grid(
      columns: (auto, 1fr), column-gutter: 14pt, align: horizon,
      box(width: 21mm, height: 21mm, radius: 6.5mm, fill: fase-vlak(),
        align(center + horizon, text(font: sans, size: 30pt, weight: "extrabold", fill: fase-op(), str(nr)))),
      [#heading(level: 2, numbering: (..n) => str(nr), supplement: [Week], titel)#label("week-" + str(nr))],
    )
    if sub != none {
      v(8pt)
      text(font: sans, size: 10pt, weight: "semibold", fill: grijs, sub)
    }
    v(8pt)
    balk(fase-vlak(), breed: 100%)
    v(8pt)
  }
}

#let bijlage-kop(letter: "", sub: none, titel) = {
  hoofdstuk-begin()
  fase-nu.update(0)
  v(18mm)
  text(font: sans, size: 10pt, weight: "bold", fill: accent, tracking: 0.12em)[BIJLAGE #letter]
  v(-4pt)
  [#heading(level: 2, numbering: (..n) => letter, supplement: [Bijlage], titel)#label("bijlage-" + letter)]
  if sub != none { text(font: sans, size: 10pt, weight: "semibold", fill: grijs, sub) }
  v(6pt)
  balk(accent, breed: 100%)
  v(8pt)
}

#let voor-kop(sub: none, titel) = {
  hoofdstuk-begin()
  fase-nu.update(0)
  v(18mm)
  heading(level: 2, numbering: none, titel)
  if sub != none { text(font: sans, size: 10pt, weight: "semibold", fill: grijs, sub) }
  v(6pt)
  balk(accent, breed: 100%)
  v(8pt)
}

#let deel(nr, titel, weken: (), beschrijving: none, label-naam: none) = {
  pagebreak(weak: true, to: if print { "odd" } else { none })
  [#metadata(nr) <deelpagina>]
  fase-nu.update(if type(nr) == int { nr } else { 0 })
  context {
    v(35mm)
    if type(nr) == int {
      metro(actief: nr, breed: 80%, maat: 7.5mm)
      v(6mm)
      text(font: sans, size: 12pt, weight: "bold", fill: fase-tekst(), tracking: 0.15em)[FASE #nr]
    }
    v(-2pt)
    heading(level: 1, numbering: none, titel)
    v(4pt)
    balk(fase-vlak(), breed: 35%)
    v(12pt)
    if beschrijving != none {
      block(width: 85%, text(size: 11pt, beschrijving))
    }
    if weken.len() > 0 {
      v(10pt)
      set text(font: sans, size: 10.5pt)
      for w in weken {
        block(above: 0.8em, below: 0.8em, grid(
          columns: (2.8em, 1fr, auto), column-gutter: 6pt, align: horizon,
          box(width: 2em, height: 1.5em, radius: 0.55em, fill: fase-vlak(),
            align(center + horizon, text(size: 0.9em, weight: "bold", fill: fase-op(), str(w)))),
          week-titel(w),
          text(fill: grijs, paginaverwijzing(label("week-" + str(w)))),
        ))
      }
    }
  }
  pagebreak(weak: true)
}

#let antwoorden-week(nr) = [#fase-nu.update(gegevens.weken.at(str(nr)).fase)#heading(level: 2, numbering: none, supplement: [Antwoorden], outlined: false, bookmarked: true)[Week #nr · #week-titel(nr)]#label("antw-" + str(nr))]

#let codeboek-week(nr) = [#fase-nu.update(gegevens.weken.at(str(nr)).fase)#heading(level: 2, numbering: none, supplement: [Codeboek], outlined: sys.inputs.at("uitgave", default: "") == "codeboek", bookmarked: true)[Week #nr · #week-titel(nr)]]

#let codeboek-listing(nr: "", pad: "") = {
  let (tekst, _) = lees-code(pad)
  [#context block(
    width: 100%, sticky: true, above: 1.6em, below: 0.5em,
    stroke: (bottom: 1.2pt + fase-vlak()), inset: (bottom: 4pt),
  )[
    #text(font: sans, size: 9.5pt)[
      #text(fill: fase-tekst(), weight: "bold")[Listing #nr] #h(0.5em)
      #text(font: mono, size: 9pt)[labs/#pad]
      #h(1fr)
      #context {
        let q = query(label("kaart-" + nr))
        if q.len() > 0 { text(fill: grijs, size: 8.5pt)[uitleg: #link(q.first().location())[blz. #paginanr(q.first().location())]] }
        else { text(fill: grijs, size: 8.5pt)[week #nr.split(".").first()] }
      }
    ]
  ]#label("cb-" + nr)]
  code-met-nummers(tekst, taal-van(pad))
}

// ---------------------------------------------------------------- titelpagina, colofon, inhoud
#let titelpagina(ondertitel: none) = {
  set page(header: none, footer: none, margin: (x: 25mm, top: 42mm, bottom: 25mm),
    background: place(top, rect(width: 100%, height: 6mm, fill: gradient.linear(..fasekleuren))))
  text(font: sans, size: 12pt, weight: "bold", fill: accent, tracking: 0.15em)[VAN NUL TOT CHIPBOUWER]
  v(4pt)
  text(font: sans, size: 46pt, weight: "extrabold", fill: inkt)[CPU Design \ Cursus]
  v(14pt)
  metro(breed: 100%, maat: 10mm)
  v(10pt)
  if ondertitel != none { text(font: sans, size: 14pt, weight: "semibold", fill: grijs, ondertitel) }
  v(1fr)
  block(width: 100%, fill: vlak, stroke: 1.2pt + lijn, radius: 12pt, inset: 14pt)[
    #set par(justify: false)
    #text(font: sans, size: 12pt, weight: "extrabold", fill: accent)[Ook online] \
    #text(font: sans, size: 10.5pt)[Lees de cursus in je browser, met zoeken en voortgang die je zelf bijhoudt:] \
    #let adres = text(font: sans, size: 12pt, weight: "bold", fill: accent)[ddecoene.github.io/cpu-design-cursus]
    #if print { adres } else { link(site, adres) }
  ]
  v(14pt)
  text(font: sans, size: 11pt, weight: "bold")[Dennis Decoene]
  v(2pt)
  text(font: sans, size: 9pt, fill: grijs)[#versie]
}

#let colofon() = {
  set page(header: none, footer: none)
  set text(size: 9pt)
  v(1fr)
  [
    *CPU Design Cursus: van nul tot chipbouwer* \
    Dennis Decoene · #versie

    Ook online: #link(site)[#site.replace("https://", "")], de webcursus met zoeken en voortgang.

    Bron, code en de nieuwste versie: #link(repo)[#repo.replace("https://", "")]. \
    Alle code uit dit boek staat in de map `labs/` van die repository en wordt bij elke wijziging
    automatisch getest.

    De tekst valt onder de licentie Creative Commons Naamsvermelding-GelijkDelen 4.0 (CC BY-SA 4.0),
    de code onder de MIT-licentie. Zie `LICENSE.md`.

    Gezet met Typst in Nunito en IBM Plex Mono.
    #if print [Deze uitgave is bedoeld om recto-verso af te drukken op A4 en heeft een bredere binnenmarge voor een ringmap.] else [Deze uitgave is bedoeld voor het scherm: de inhoud, de verwijzingen naar listings en antwoorden en de webadressen zijn klikbaar.]
  ]
}

#let inhoud() = {
  pagebreak(weak: true, to: if print { "odd" } else { none })
  [#metadata("inhoud") <deelpagina>]
  v(12mm)
  text(font: sans, size: 24pt, weight: "extrabold", fill: inkt)[Inhoud]
  v(8pt)
  show outline.entry.where(level: 1): it => {
    set text(font: sans, weight: "bold", fill: inkt)
    v(10pt, weak: true)
    link(it.element.location(), it.indented(none, [#it.body() #box(width: 1fr) #it.page()]))
  }
  show outline.entry.where(level: 2): it => {
    set text(size: 10pt)
    link(it.element.location(), it.indented(
      box(width: 1.6em, text(font: sans, fill: grijs, if it.prefix() != none { it.prefix() })),
      [#it.body() #box(width: 1fr, repeat(text(fill: lijn)[.], gap: 2pt)) #text(font: sans, it.page())],
    ))
  }
  outline(title: none, depth: 2, indent: 0pt)
}

// ---------------------------------------------------------------- kop- en voettekst
#let kop-en-voet(voet: false) = context {
  let p = here().page()
  let merken = query(selector(heading.where(level: 1)).or(heading.where(level: 2)).or(<hoofdstukeinde>).or(<deelpagina>))
    .filter(e => e.location().page() <= p)
  if merken.len() == 0 { return }
  let laatste = merken.last()
  let pl = laatste.location().page()
  // openingspagina's en lege pagina's na een hoofdstuk krijgen geen kop
  let is-kop = laatste.func() == heading and laatste.supplement not in ([Antwoorden], [Codeboek])
  let is-merk = laatste.func() == metadata
  if is-kop and pl == p { if not voet { return } }
  if is-merk and laatste.value != "einde" and pl == p { return }
  if is-merk and pl < p { return }
  if is-kop and laatste.level == 1 and pl < p { return }   // achterkant van een deelpagina
  let deel-kop = merken.filter(e => e.func() == heading and e.level == 1)
  let hfst = merken.filter(e => e.func() == heading and e.level == 2)
  set text(font: sans, size: 8pt, fill: grijs)
  if voet {
    let nr = text(fill: fase-tekst(), weight: "bold", counter(page).display())
    let adres = text(fill: grijs, site.replace("https://", "").trim("/", at: end))
    let adres = if print { adres } else { link(site, adres) }
    if print {
      if calc.even(p) { grid(columns: (auto, 1fr), nr, align(right, adres)) } else { grid(columns: (1fr, auto), adres, nr) }
    } else { grid(columns: (1fr, auto), adres, nr) }
    return
  }
  let links = if deel-kop.len() > 0 { deel-kop.last().body } else { [] }
  let rechts = if hfst.len() > 0 {
    let h = hfst.last()
    if h.numbering != none [#numbering(h.numbering, ..counter(heading).at(h.location())) · #h.body] else [#h.body]
  } else { [] }
  let inhoud = if print {
    if calc.even(p) { align(left, links) } else { align(right, rechts) }
  } else { grid(columns: (1fr, auto), links, rechts) }
  block(width: 100%, stroke: (bottom: 1pt + fase-vlak()), inset: (bottom: 4pt), inhoud)
}

// ---------------------------------------------------------------- het boek
#let boek(body) = {
  set document(title: "CPU Design Cursus", author: "Dennis Decoene")
  set page(
    paper: "a4",
    margin: if print { (inside: 30mm, outside: 20mm, top: 24mm, bottom: 22mm) } else { (x: 25mm, top: 24mm, bottom: 22mm) },
    header: kop-en-voet(),
    footer: kop-en-voet(voet: true),
    fill: if print { none } else { papier },
  )
  set text(font: serif, size: 10pt, lang: "nl", hyphenate: true, fill: inkt)
  set par(justify: true, leading: 0.7em, spacing: 1em)
  set heading(numbering: none)
  set list(indent: 0.4em, body-indent: 0.5em)
  set enum(indent: 0.2em, body-indent: 0.5em)
  set footnote.entry(separator: line(length: 25%, stroke: 0.5pt + lijn))
  set raw(syntaxes: ("syntaxes/verilog.sublime-syntax", "syntaxes/w8asm.sublime-syntax", "syntaxes/forth.sublime-syntax"))

  show heading.where(level: 1): it => block(below: 0.6em, text(font: sans, size: 32pt, weight: "extrabold", fill: inkt, it.body))
  show heading.where(level: 2): it => {
    if it.supplement in ([Antwoorden], [Codeboek]) {
      block(above: 2em, below: 1em, sticky: true,
        text(font: sans, size: 15pt, weight: "extrabold", fill: inkt, it.body))
    } else {
      block(above: 0pt, below: 0.4em, text(font: sans, size: 24pt, weight: "extrabold", fill: inkt, hyphenate: false, it.body))
    }
  }
  show heading.where(level: 3): it => block(above: 1.8em, below: 0.9em, sticky: true, {
    set text(font: sans, size: 13pt, weight: "bold", fill: inkt, hyphenate: false)
    if it.numbering != none {
      context text(fill: fase-tekst(), counter(heading).display(it.numbering))
      h(0.6em)
    }
    it.body
  })
  show heading.where(level: 4): it => block(above: 1.4em, below: 0.7em, sticky: true,
    text(font: sans, size: 11pt, weight: "semibold", fill: inkt, hyphenate: false, it.body))
  show heading.where(level: 5): it => block(above: 1.2em, below: 0.6em, sticky: true,
    text(font: sans, size: 10pt, weight: "semibold", style: "italic", it.body))

  // code
  show raw: set text(font: mono, size: 8pt)
  // code in de lopende tekst: geen kader, zodat een lange regel gewoon kan afbreken
  show raw.where(block: false): set text(size: 1.05em, fill: rgb("#8a2c58"))
  show raw.where(block: true): set par(justify: false)

  // tabellen
  show figure.where(kind: table): set block(breakable: true)
  show figure: set block(above: 1.1em, below: 1.1em)
  set table(
    stroke: (x, y) => (bottom: if y == 0 { 1.4pt + inkt } else { 0.5pt + lijn }),
    fill: (x, y) => if y == 0 { vlak },
    inset: (x: 6pt, y: 5pt),
  )
  show table: set text(font: sans, size: 8.5pt)
  show table: set par(justify: false)
  show table.cell.where(y: 0): set text(fill: inkt, weight: "bold")

  // koppelingen
  show link: it => {
    if type(it.dest) == str {
      set text(fill: if print { black } else { accent })
      it
      if print and not (it.body.has("text") and it.body.text == it.dest) {
        footnote(text(font: mono, size: 7.5pt, it.dest))
      }
    } else { it }
  }

  body
}

// pandoc gebruikt dit soms
#let horizontalrule = line(length: 100%, stroke: 0.5pt + lijn)
