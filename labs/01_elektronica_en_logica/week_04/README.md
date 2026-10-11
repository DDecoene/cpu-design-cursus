# week_04

De code bij week 4: Combinatorische bouwblokken.

Hoort bij week 4 van de cursus. Draai de tests met:

```text
python3 test_labs.py week_04
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `adder.v` | 4-bit ripple-carry opteller: vier full adders, de carry "rimpelt" van rechts naar links. |
| `decoder.v` |  |
| `mux.v` | Een 2:1 mux met instelbare breedte (W bits). |
| `seg7.v` | Uitgang: {a,b,c,d,e,f,g}, 1 = segment aan. |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_adder4.v` | 1; |
| `tb_mux_dec_seg.v` | Testbench voor `mux_dec_seg`. |
