import test from "node:test";
import assert from "node:assert/strict";
import { SLEUTEL, standaard, valideer, maakOpslag, zetGedaan, zetLaatst, voortgang, exporteer, importeer } from "../js/opslag.js";

const nepOpslag = (begin = {}) => {
  const d = { ...begin };
  return { getItem: (k) => (k in d ? d[k] : null), setItem: (k, v) => { d[k] = String(v); }, d };
};

test("valideer houdt alleen geldige weken, sorteert en ontdubbelt", () => {
  const s = valideer({ gedaan: [3, 1, 3, 0, 31, 2.5, "4", null], laatst: 5, thema: "donker", rommel: 1 }, 30);
  assert.deepEqual(s, { gedaan: [1, 3], laatst: 5, thema: "donker" });
});

test("valideer valt terug op standaardwaarden bij verkeerde types", () => {
  assert.deepEqual(valideer({ gedaan: "1,2", laatst: 99, thema: "paars" }, 30), standaard());
  for (const x of [null, [], "tekst", 42, undefined]) assert.equal(valideer(x, 30), null);
});

test("lezen: leeg, kapot of vreemd geeft standaard en geen fout", () => {
  assert.deepEqual(maakOpslag(nepOpslag(), 30).lees(), standaard());
  assert.deepEqual(maakOpslag(nepOpslag({ [SLEUTEL]: "{kapot" }), 30).lees(), standaard());
  assert.deepEqual(maakOpslag(nepOpslag({ [SLEUTEL]: "[1,2]" }), 30).lees(), standaard());
});

test("schrijven en teruglezen", () => {
  const o = maakOpslag(nepOpslag(), 30);
  assert.equal(o.schrijf({ gedaan: [2], laatst: 2, thema: "licht" }), true);
  assert.deepEqual(o.lees(), { gedaan: [2], laatst: 2, thema: "licht" });
  assert.equal(o.werkt, true);
});

test("opslag die fouten geeft of ontbreekt: geen crash, werkt=false", () => {
  const stuk = { getItem() { throw new Error("geblokkeerd"); }, setItem() { throw new Error("vol"); } };
  const a = maakOpslag(stuk, 30);
  assert.deepEqual(a.lees(), standaard());
  assert.equal(a.schrijf(standaard()), false);
  assert.equal(a.werkt, false);
  const b = maakOpslag(undefined, 30);
  assert.deepEqual(b.lees(), standaard());
  assert.equal(b.werkt, false);
});

test("afvinken, uitvinken en laatst", () => {
  let s = standaard();
  s = zetGedaan(s, 3, true); s = zetGedaan(s, 1, true); s = zetGedaan(s, 3, true);
  assert.deepEqual(s.gedaan, [1, 3]);
  s = zetGedaan(s, 1, false);
  assert.deepEqual(s.gedaan, [3]);
  assert.equal(zetLaatst(s, 7).laatst, 7);
});

test("voortgang telt per groep weken", () => {
  assert.deepEqual(voortgang({ ...standaard(), gedaan: [1, 2, 9] }, [1, 2, 3, 4]), { klaar: 2, totaal: 4 });
});

test("export en import samen; vreemde bestanden worden geweigerd", () => {
  const s = { gedaan: [1, 2], laatst: 2, thema: "donker" };
  assert.deepEqual(importeer(exporteer(s), 30), { ok: true, staat: s });
  for (const tekst of ["geen json", "{}", "[]", "null", "42", '{"naam":"x"}']) assert.equal(importeer(tekst, 30).ok, false, tekst);
});

test("import weigert bestanden die niet door exporteer zijn gemaakt, ook als een bekend veld erin zit", () => {
  for (const tekst of ['{"thema":"dark"}', '{"gedaan":"1,2,3"}', '{"laatst":null}', '{"gedaan":[1,2]}']) {
    assert.equal(importeer(tekst, 30).ok, false, tekst);
  }
});
