// Voortgang van de lezer in localStorage. Geen DOM hier: alles is te testen met een nepopslag.
export const SLEUTEL = "cpu-cursus-v1";
export const THEMAS = ["systeem", "licht", "donker"];

export function standaard() {
  return { gedaan: [], laatst: null, thema: "systeem" };
}

const isWeek = (x, max) => Number.isInteger(x) && x >= 1 && x <= max;

// Maakt van onbekende invoer een geldige staat, of null als het geen object is. Onbekende velden verdwijnen.
export function valideer(obj, maxWeek) {
  if (obj === null || typeof obj !== "object" || Array.isArray(obj)) return null;
  const gedaan = Array.isArray(obj.gedaan)
    ? [...new Set(obj.gedaan.filter((w) => isWeek(w, maxWeek)))].sort((a, b) => a - b)
    : [];
  return {
    gedaan,
    laatst: isWeek(obj.laatst, maxWeek) ? obj.laatst : null,
    thema: THEMAS.includes(obj.thema) ? obj.thema : "systeem",
  };
}

// storage mag ontbreken of fouten geven (privévenster, geblokkeerd, vol): dan werkt de site zonder voortgang.
export function maakOpslag(storage, maxWeek) {
  let werkt = true;
  return {
    get werkt() {
      return werkt;
    },
    lees() {
      try {
        const tekst = storage.getItem(SLEUTEL);
        if (tekst === null) return standaard();
        return valideer(JSON.parse(tekst), maxWeek) ?? standaard();
      } catch {
        werkt = false;
        return standaard();
      }
    },
    schrijf(staat) {
      try {
        storage.setItem(SLEUTEL, JSON.stringify(staat));
        return true;
      } catch {
        werkt = false;
        return false;
      }
    },
  };
}

export function zetGedaan(staat, week, gedaan) {
  const rest = staat.gedaan.filter((w) => w !== week);
  return { ...staat, gedaan: (gedaan ? [...rest, week] : rest).sort((a, b) => a - b) };
}

export function zetLaatst(staat, week) {
  return { ...staat, laatst: week };
}

// Hoeveel van de gegeven weken zijn gedaan?
export function voortgang(staat, weken) {
  return { klaar: weken.filter((w) => staat.gedaan.includes(w)).length, totaal: weken.length };
}

export function exporteer(staat) {
  return JSON.stringify({ formaat: SLEUTEL, ...staat }, null, 2);
}

export function importeer(tekst, maxWeek) {
  let obj;
  try {
    obj = JSON.parse(tekst);
  } catch {
    return { ok: false, fout: "Dit is geen geldig JSON-bestand." };
  }
  // alleen bestanden uit exporteer(): een ander JSON-bestand met een veld "thema" mag je voortgang niet wissen
  const staat = obj && obj.formaat === SLEUTEL ? valideer(obj, maxWeek) : null;
  if (!staat) return { ok: false, fout: "Dit bestand bevat geen voortgang van deze cursus." };
  return { ok: true, staat };
}
