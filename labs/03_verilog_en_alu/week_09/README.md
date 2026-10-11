# week_09

De code bij week 9: Verilog, hardware beschrijven.

Hoort bij week 9 van de cursus. Draai de tests met:

```text
python3 test_labs.py week_09
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `addn.v` |  |
| `blocking.v` | Drie keer hetzelfde idee: een 3-staps vertraging voor een bit. |
| `funcs.v` |  |
| `prio.v` | Prioriteitsencoder: het nummer van de hoogste ingang die 1 is. |
| `sv_style.v` |  |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_blocking.v` | Beginwaarden: alles op 0 laten lopen. |
| `tb_bouwstenen.v` | Testbench voor `bouwstenen`. |
| `tb_sv.v` | 12 rst_n = 1; en = 1; |
