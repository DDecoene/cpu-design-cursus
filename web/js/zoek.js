// Zoeken in zoek.json: woorden die beginnen met wat je typt, alle woorden moeten voorkomen.
export const normaliseer = (s) => s.toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "");
export const woorden = (s) => normaliseer(s).split(/[^a-z0-9]+/).filter(Boolean);

// secties: [{u: url, p: pagina, k: kopje, t: tekst}]
export function bouwIndex(secties) {
  return secties.map((s) => ({ s, kop: woorden(`${s.p} ${s.k}`), tekst: woorden(s.t) }));
}

export function fragment(tekst, q, breed = 70) {
  const re = /[\p{L}\p{N}]+/gu;
  let m;
  while ((m = re.exec(tekst)) !== null) {
    const w = normaliseer(m[0]);
    if (q.some((x) => w.startsWith(x))) {
      const van = Math.max(0, m.index - breed);
      const tot = Math.min(tekst.length, m.index + breed);
      return (van > 0 ? "…" : "") + tekst.slice(van, tot) + (tot < tekst.length ? "…" : "");
    }
  }
  return tekst.slice(0, breed * 2) + (tekst.length > breed * 2 ? "…" : "");
}

export function zoek(index, vraag, max = 10) {
  const q = woorden(vraag);
  if (q.length === 0) return [];
  const treffers = [];
  for (const e of index) {
    let score = 0;
    for (const w of q) {
      const inKop = e.kop.some((x) => x.startsWith(w));
      const nTekst = e.tekst.filter((x) => x.startsWith(w)).length;
      if (!inKop && nTekst === 0) { score = 0; break; }
      score += (inKop ? 5 : 0) + Math.min(nTekst, 5);
    }
    if (score > 0) treffers.push({ s: e.s, score });
  }
  treffers.sort((a, b) => b.score - a.score);
  return treffers.slice(0, max).map((r) => ({ ...r.s, fragment: fragment(r.s.t, q) }));
}
