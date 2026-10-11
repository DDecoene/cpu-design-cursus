# t8_transport_triggered

De T8, een transport-triggered architecture: één soort instructie, de move. Met assembler en testprogramma's.

Hoort bij week 19 van de cursus. Draai de tests met:

```text
python3 test_labs.py t8_transport_triggered
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `tta.v` | T8: een transport-triggered architecture. De enige instructie is MOVE: bron -> bestemming. |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_tta.v` | Slaat de uitvoer van een T8 op. |
| `tb_tta_answers.v` | 22 rst_n = 1; |
| `tb_tta_random.v` | Willekeurige TTA-programma's tegen een referentiemodel (integers, geen hardwaretrucs). |
| `tb_tta_run.v` | Draait een geassembleerd TTA-programma en toont uitvoer en eindtoestand. Gebruik via run_tta.sh. |

## Programma's

| Bestand | Wat |
|---|---|
| `add16.tta` | 16-bit optelling met ADC: 0x01FF + 0x0001 = 0x0200. Uitvoer: 0x00 dan 0x02. |
| `answers.tta` | Uitwerkingen van de oefeningen. Uitvoer: 200 9 250 91. |
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
| `run_tta.sh` | Gebruik: bash run_tta.sh programma.tta [invoerwaarde] Assembleert een TTA-programma en draait het in de simulator. |
| `test_tta_asm.py` | Tests voor de TTA-assembler. |
| `tta_asm.py` | Assembler voor de transport-triggered architecture T8. |

## Overig

| Bestand | Wat |
|---|---|
| `array.dat` |  |
