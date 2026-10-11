import test from "node:test";
import assert from "node:assert/strict";
import { bouwIndex, zoek, woorden } from "../js/zoek.js";

const index = bouwIndex([
  { u: "week/06/#flipflops", p: "Week 6: Flipflops en registers", k: "Flipflops", t: "Een flipflop onthoudt één bit. Het register bestaat uit acht flipflops." },
  { u: "week/12/#vermenigvuldiger", p: "Week 12: Shifters", k: "Vermenigvuldigen", t: "Een sequentiële vermenigvuldiger telt op en schuift." },
  { u: "week/20/#pipeline", p: "Week 20: Pipelining", k: "De pijplijn", t: "Een pipeline verdeelt de instructie in stappen." },
]);

test("voorvoegsel, hoofdletters en accenten", () => {
  assert.equal(zoek(index, "FLIPFLOP")[0].u, "week/06/#flipflops");
  assert.equal(zoek(index, "sequentiele")[0].u, "week/12/#vermenigvuldiger");
  assert.equal(zoek(index, "pipe")[0].u, "week/20/#pipeline");
});

test("alle woorden moeten voorkomen", () => {
  assert.equal(zoek(index, "flipflop pipeline").length, 0);
  assert.equal(zoek(index, "flipflop bit").length, 1);
});

test("kopje weegt zwaarder dan tekst", () => {
  const i = bouwIndex([
    { u: "a", p: "A", k: "Iets anders", t: "register register register" },
    { u: "b", p: "B", k: "Register", t: "kort" },
  ]);
  assert.equal(zoek(i, "register")[0].u, "b");
});

test("lege of rare invoer geeft niets en geen fout", () => {
  for (const q of ["", "   ", "***", "(", "[", "\\", ".*", "+?"]) assert.deepEqual(zoek(index, q), []);
});

test("fragment staat rond de treffer", () => {
  const r = zoek(index, "bestaat")[0];
  assert.match(r.fragment, /bestaat/);
  assert.deepEqual(woorden("74HC-chips"), ["74hc", "chips"]);
});
