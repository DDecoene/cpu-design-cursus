# week_10

De code bij week 10: Testbenches, golfvormen en verificatie.

Hoort bij week 10 van de cursus. Draai de tests met:

```text
python3 test_labs.py week_10
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `adders.v` |  |
| `fifo.v` |  |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_bughunt.v` | Het referentiemodel is hier gewoon de optelling zelf. |
| `tb_fifo.v` | Referentiemodel: een gewone array met een schrijf- en leesindex, zonder hardware-trucs. |
| `tb_wave.v` | Testbench voor `wave`. |

## Scripts en tests

| Bestand | Wat |
|---|---|
| `run_all.sh` | Gebruik: bash run_all.sh   (in een map met je .v-bestanden) |

## Overig

| Bestand | Wat |
|---|---|
| `wave.vcd` |  |
