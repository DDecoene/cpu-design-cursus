# beeldcomputer_op_fpga

De synthese van de beeldcomputer voor een iCE40 UP5K: toplevel, klok-PLL, een voorbeeld van een pinbestand en `flow.sh`. Gebruikt de bestanden uit `../beeldcomputer`.

Hoort bij week 30 van de cursus. Draai de tests met:

```text
python3 test_labs.py beeldcomputer_op_fpga
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `ice40_top.v` | Het toplevel voor een iCE40 UP5K-bord met een klok van 12 MHz (bijvoorbeeld de iCEBreaker), een VGA-module met 4 bit per kleur en een microSD-module. |
| `pll_ice40.v` | De pixelklok uit de 12 MHz van het bord, met de PLL van de iCE40. |

## Scripts en tests

| Bestand | Wat |
|---|---|
| `flow.sh` | Synthese, plaatsen en routeren en een bitstream voor de beeldcomputer op een iCE40 UP5K, met de open-source tools. |

## Overig

| Bestand | Wat |
|---|---|
| `beeld_voorbeeld.pcf` | Voorbeeld van een pinbestand voor nextpnr (iCE40). |
