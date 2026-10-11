# t8_op_74hc_print

De T8 gebouwd uit 74HC-chips, als simulatie met modellen van de chips en scripts voor de onderdelenlijst en het ROM. Niet gebouwd op een print.

Hoort bij week 25 van de cursus. Draai de tests met:

```text
python3 test_labs.py t8_op_74hc_print
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `hc74xx.v` | Gedragsmodellen van de 74HC-chips en geheugens op de printplaat, met typische vertragingen bij 5 V. |
| `pair_hw.v` | Eén bord naast één gedragsmodel (week 19), beide met hetzelfde programma. |
| `t8_board.v` | De transport-triggered architecture T8 uit echte 74HC-chips. Dit bestand is het schema in tekstvorm: elke 'u_...' is één chip op de printplaat, elke 'wire' een draad. |
| `tta.v` | T8: een transport-triggered architecture. De enige instructie is MOVE: bron -> bestemming. |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_t8_board.v` | Acht programma's tegelijk, elk op een eigen bord naast het gedragsmodel (pair_hw.v). |
| `tb_t8_board_random.v` | 300 willekeurige programma's op het 74HC-bord en het gedragsmodel, cyclus voor cyclus vergeleken. |

## Programma's

| Bestand | Wat |
|---|---|
| `add16.tta` | 16-bit optelling met ADC: 0x01FF + 0x0001 = 0x0200. Uitvoer: 0x00 dan 0x02. |
| `array.tta` | Som van een rij van 8 bytes in het datageheugen, daarna een schrijf/lees-test. Uitvoer: 36, 99. |
| `call.tta` | Een subroutine die R0 verdubbelt, twee keer aangeroepen. Uitvoer: 28. |
| `fib.tta` | De eerste tien Fibonacci-getallen naar de uitvoer: 0 1 1 2 3 5 8 13 21 34. |
| `guards.tta` | Test van alle guards. Uitvoer: 1 3 6 7 8 9 4. |
| `io.tta` | Lees de ingangspoort, tel er 1 bij op en schrijf het naar de uitgangspoort. |
| `mul.tta` | 13 x 11 door herhaald optellen. Uitvoer: 143. |
| `sum.tta` | Som van 1 tot 10 met alleen moves. Uitvoer: 55. |

## Scripts en tests

| Bestand | Wat |
|---|---|
| `bom.py` | Telt de chips in het schema (t8_board.v) en maakt een onderdelenlijst (BOM) met een prijsindicatie. |
| `split_rom.py` | Splitst een TTA-programma (tta_asm.py maakt 24-bit-woorden in een .hex-bestand) in drie binaire bestanden van |
| `sweep.py` | Zoekt hoe snel de klok van het 74HC-bord kan, en of het ontwerp robuust is voor snelle en trage chips. |
| `test_split_rom.py` | De drie EEPROM-bestanden moeten samen precies de oorspronkelijke 24-bit-woorden opleveren. |
| `tta_asm.py` | Assembler voor de transport-triggered architecture T8. |

## Overig

| Bestand | Wat |
|---|---|
| `array.dat` |  |
