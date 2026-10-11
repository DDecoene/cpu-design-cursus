// Verbindt de pagina met opslag.js en zoek.js. Alles is optioneel: zonder JS blijft de cursus leesbaar.
import { SLEUTEL, THEMAS, maakOpslag, zetGedaan, zetLaatst, voortgang, exporteer, importeer } from "./opslag.js";
import { bouwIndex, zoek } from "./zoek.js";

const $ = (id) => document.getElementById(id);
const cursus = JSON.parse($("cursus").textContent);
const basis = document.body.dataset.basis;

let opslag;
try {
  opslag = maakOpslag(window.localStorage, cursus.maxweek);
} catch {
  opslag = maakOpslag(undefined, cursus.maxweek);
}
let staat = opslag.lees();

function bewaar() {
  opslag.schrijf(staat);
  if (!opslag.werkt && $("opslagmelding")) $("opslagmelding").hidden = false;
}

// een ander tabblad kan de voortgang veranderd hebben: lees opnieuw vóór elke wijziging en bij een storage-event
function ververs() {
  if (opslag.werkt) staat = opslag.lees();
}

function toonThema() {
  const el = document.documentElement;
  if (staat.thema === "systeem") delete el.dataset.thema;
  else el.dataset.thema = staat.thema;
  $("themaknop").textContent = "Thema";
  $("themaknop").title = $("themaknop").ariaLabel = `Thema: ${staat.thema} (klik om te wisselen)`;
}

function toonVoortgang() {
  for (const a of document.querySelectorAll("#zijbalk a[data-week]")) {
    a.classList.toggle("gedaan", staat.gedaan.includes(Number(a.dataset.week)));
  }
  for (const kaart of document.querySelectorAll(".fase-kaart")) {
    const fase = cursus.fasen.find((f) => f.nr === Number(kaart.dataset.fase));
    const { klaar, totaal } = voortgang(staat, fase.weken);
    kaart.querySelector("progress").value = klaar;
    kaart.querySelector(".fase-tekst").textContent = `${klaar} van ${totaal} weken`;
  }
  for (const station of document.querySelectorAll(".station")) {
    const fase = cursus.fasen.find((f) => f.nr === Number(station.dataset.fase));
    const { klaar, totaal } = voortgang(staat, fase.weken);
    station.querySelector("i").style.setProperty("--p", String(Math.round((100 * klaar) / totaal)));
    station.dataset.status = klaar === totaal ? "klaar" : klaar > 0 ? "bezig" : "nog";
  }
  const verder = $("verder");
  if (verder && staat.laatst) {
    verder.href = `${basis}week/${String(staat.laatst).padStart(2, "0")}/`;
    verder.textContent = `Ga verder met week ${staat.laatst}`;
  }
  const knop = $("afvinken");
  if (knop) {
    const gedaan = staat.gedaan.includes(Number(knop.dataset.week));
    knop.setAttribute("aria-pressed", String(gedaan));
    knop.textContent = gedaan ? "Gedaan ✓ (klik om te wissen)" : "Markeer als gedaan";
  }
}

toonThema();
$("themaknop").addEventListener("click", () => {
  ververs();
  staat = { ...staat, thema: THEMAS[(THEMAS.indexOf(staat.thema) + 1) % THEMAS.length] };
  bewaar();
  toonThema();
});

const afvinken = $("afvinken");
if (afvinken) {
  const week = Number(afvinken.dataset.week);
  staat = zetLaatst(staat, week);
  bewaar();
  afvinken.addEventListener("click", () => {
    ververs();
    staat = zetGedaan(staat, week, !staat.gedaan.includes(week));
    bewaar();
    toonVoortgang();
  });
}
toonVoortgang();

window.addEventListener("storage", (e) => {
  if (e.key !== null && e.key !== SLEUTEL) return;
  ververs();
  toonThema();
  toonVoortgang();
});

if ($("export")) {
  $("export").addEventListener("click", () => {
    const a = document.createElement("a");
    a.href = URL.createObjectURL(new Blob([exporteer(staat)], { type: "application/json" }));
    a.download = "cpu-cursus-voortgang.json";
    a.click();
    URL.revokeObjectURL(a.href);
  });
  $("import").addEventListener("change", async (e) => {
    const bestand = e.target.files[0];
    if (!bestand) return;
    const r = importeer(await bestand.text(), cursus.maxweek);
    if (r.ok) {
      staat = r.staat;
      bewaar();
      toonThema();
      toonVoortgang();
    }
    $("importmelding").textContent = r.ok ? "Voortgang geladen." : r.fout;
    e.target.value = "";
  });
}

// kopieerknop bij elk codeblok
for (const pre of document.querySelectorAll("main pre")) {
  const omhulsel = document.createElement("div");
  omhulsel.className = "codeblok";
  pre.replaceWith(omhulsel);
  const k = document.createElement("button");
  k.type = "button";
  k.className = "kopieer";
  k.textContent = "Kopieer";
  k.addEventListener("click", async () => {
    try {
      await navigator.clipboard.writeText(pre.innerText);
      k.textContent = "Gekopieerd";
    } catch {
      k.textContent = "Mislukt";
    }
    setTimeout(() => (k.textContent = "Kopieer"), 1500);
  });
  omhulsel.append(pre, k);
}

// menu op smal scherm
$("menuknop").addEventListener("click", () => {
  const open = document.body.classList.toggle("menu-open");
  $("menuknop").setAttribute("aria-expanded", String(open));
});

// zoeken: de index wordt pas bij het eerste gebruik geladen
const vak = $("zoekvak");
const lijst = $("zoekresultaten");
let indexBelofte = null;
const laadIndex = () => (indexBelofte ??= fetch(`${basis}zoek.json`).then((r) => r.json()).then(bouwIndex));

vak.addEventListener("input", async () => {
  const vraag = vak.value;
  if (!vraag.trim()) {
    lijst.hidden = true;
    return;
  }
  let treffers;
  try {
    treffers = zoek(await laadIndex(), vraag);
  } catch {
    indexBelofte = null;
    return;
  }
  if (vak.value !== vraag) return; // een nieuwere zoekopdracht is al bezig
  lijst.replaceChildren(
    ...(treffers.length
      ? treffers.map((t) => {
          const li = document.createElement("li");
          const a = document.createElement("a");
          a.href = basis + t.u;
          const titel = document.createElement("strong");
          titel.textContent = t.k && t.k !== t.p ? `${t.p} › ${t.k}` : t.p;
          const tekst = document.createElement("span");
          tekst.textContent = t.fragment;
          a.append(titel, tekst);
          li.append(a);
          return li;
        })
      : [Object.assign(document.createElement("li"), { textContent: "Niets gevonden.", style: "padding:8px" })]),
  );
  lijst.hidden = false;
});
document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") lijst.hidden = true;
});
document.addEventListener("click", (e) => {
  if (!e.target.closest(".zoek")) lijst.hidden = true;
});
