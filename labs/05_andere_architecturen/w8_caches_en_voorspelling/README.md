# w8_caches_en_voorspelling

Een cache in Verilog, een model van sprongvoorspellers in Python en `w8iss.py`, een simulator van de W8 om programma's te meten.

Hoort bij week 21 van de cursus. Draai de tests met:

```text
python3 test_labs.py w8_caches_en_voorspelling
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `cache.v` | Een direct-mapped cache voor 8-bit adressen: 16 regels van 4 bytes (64 bytes in totaal). |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_cache.v` | Testbench voor `cache`. |

## Programma's

| Bestand | Wat |
|---|---|
| `calls.asm` | Subroutines met CALL en RET. R7 bevat het terugkeeradres, dus een geneste aanroep moet het bewaren. |
| `gcd.asm` | Grootste gemene deler van 252 en 105 (Euclides met aftrekken). Resultaat in R1 (21). |
| `mul.asm` | 16-bit product van 200 x 150 met shift-and-add. Resultaat in R5:R4 (0x7530 = 30000). |
| `primes.asm` | Zeef van Eratosthenes voor 2..99. Vlaggen op adres 100+n. R3 = aantal priemgetallen (25). |
| `sort.asm` | Bubble sort van 8 bytes op adres 16..23 (zonder teken, oplopend). |
| `sum.asm` | Som van 1 tot 10. Resultaat in R1 (55). |

## Scripts en tests

| Bestand | Wat |
|---|---|
| `asm.py` | Assembler voor de 8-bit CPU van deze cursus. |
| `predict.py` | Sprongvoorspellers vergelijken op sporen van echte W8-programma's. |
| `test_predict.py` | Test van de ISS (tegen de resultaten van de Verilog-CPU) en van de voorspellers. |
| `w8iss.py` | Instructieset-simulator (ISS) voor W8 in Python. Voert een programma uit en bewaart een spoor van alle |

## Overig

| Bestand | Wat |
|---|---|
| `sort.dat` |  |
