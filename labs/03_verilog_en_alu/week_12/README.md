# week_12

De code bij week 12: Getalrepresentatie, shifters en vermenigvuldigen.

Hoort bij week 12 van de cursus. Draai de tests met:

```text
python3 test_labs.py week_12
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `mul8.v` | 8x8 -> 16 bits, zonder teken, 8 cycli. |
| `sext.v` | Tekenuitbreiding van 8 naar 16 bits. |
| `shifter.v` | Barrel shifter. mode: 00 LSL, 01 LSR, 10 ASR, 11 ROR. |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_mul8.v` | 12 rst_n = 1; |
| `tb_shifter.v` | Testbench voor `shifter`. |
