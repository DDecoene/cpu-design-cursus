# week_08

De code bij week 8: Geheugen en de bus.

Hoort bij week 8 van de cursus. Draai de tests met:

```text
python3 test_labs.py week_08
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `bus.v` | Drie bronnen op één bus. Elk zet zijn data alleen op de bus als zijn oe aan staat. |
| `memory.v` | Synchroon schrijven, asynchroon (combinatorisch) lezen. Net zoals een eenvoudig SRAM. |
| `regfile.v` |  |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_mem.v` | Testbench voor `mem`. |
| `tb_regfile_bus.v` | Testbench voor `regfile_bus`. |
