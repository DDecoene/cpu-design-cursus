# week_06

De code bij week 6: Registers, tellers en de klok.

Hoort bij week 6 van de cursus. Draai de tests met:

```text
python3 test_labs.py week_06
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `counter.v` |  |
| `lfsr.v` | 8-bit LFSR (linear feedback shift register): een pseudo-willekeurige reeks. |
| `regs.v` | Register met asynchrone reset en load-enable. |
| `shift.v` | Serieel-in, parallel-uit schuifregister. |
| `sync.v` | Twee-flipflop-synchronizer voor asynchrone ingangen. |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_regs.v` | Testbench voor `regs`. |
| `tb_sync.v` | Testbench voor `sync`. |
