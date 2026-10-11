# s8_stackmachine_forth

De S8, een stackmachine, en een kleine Forth-compiler in Python die programma's voor de S8 maakt.

Hoort bij week 18 van de cursus. Draai de tests met:

```text
python3 test_labs.py s8_stackmachine_forth
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `s8.v` | S8: een stackmachine in de geest van Forth. |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_answers_fs.v` | 22 rst_n = 1; |
| `tb_forth.v` | Vijf door de Forth-compiler gemaakte programma's, elk op zijn eigen stackmachine. |
| `tb_s8_basic.v` | Test van de stackmachine met met de hand samengestelde bytes. |
| `tb_s8_run.v` | Draait een met forth.py gemaakt programma en toont de stapel. Gebruik via runfs.sh. |

## Programma's

| Bestand | Wat |
|---|---|
| `answers.fs` |  |
| `arith.fs` |  |
| `counter.fs` |  |
| `fact.fs` |  |
| `fib.fs` |  |
| `sum.fs` |  |

## Scripts en tests

| Bestand | Wat |
|---|---|
| `forth.py` | Een kleine Forth-compiler voor de stackmachine S8. |
| `runfs.sh` | Gebruik: bash runfs.sh programma.fs Compileert een Forth-programma en draait het op de stackmachine S8. |
| `test_forth.py` | Tests voor de Forth-compiler: bytes van kleine programma's, controlestructuren, foutmeldingen. |
