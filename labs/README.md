# De code bij de cursus

Alle Verilog-, assembler- en Python-code staat hier, gegroepeerd zoals de hoofdstukken in `src/`: eerst de fase, dan de week of het project. In elke labmap staat een `README.md` met een korte uitleg en een bestandenlijst. Alles wordt getest met `python3 test_labs.py` (zie het README in de hoofdmap).

## Machines in de cursus

| Naam | Wat het is |
|------|------------|
| W8 | onze 8-bit registermachine (week 13-17) |
| W8F | de FPGA-vriendelijke versie van de W8 (blok-RAM, LD kost 3 cycli) |
| S8 | de stackmachine met Forth (week 18) |
| T8 | de transport-triggered machine, TTA (week 19) |

## Waar staat wat

| Fase | Labmap | Weken | Inhoud |
|------|--------|-------|--------|
| 01 | `week_01` … `week_04` | 1-4 | losse oefeningen per week |
| 02 | `week_05` … `week_08` | 5-8 | losse oefeningen per week |
| 03 | `week_09` … `week_12` | 9-12 | losse oefeningen per week |
| 04 | `w8_cpu` | 13-17 | de 8-bit CPU met assembler, stap voor stap |
| 05 | `s8_stackmachine_forth` | 18 | stackmachine en Forth-compiler |
| 05 | `t8_transport_triggered` | 19 | de TTA-machine |
| 05 | `w8_pipeline` | 20 | de W8 met pijplijn |
| 05 | `w8_caches_en_voorspelling` | 21 | cache, sprongvoorspeller en een simulator van de W8 |
| 05 | `w8_interrupts_en_io` | 22 | interrupts, timer en UART |
| 06 | `w8_op_fpga` | 23-24 | de W8F op een FPGA, synthese en timing |
| 06 | `t8_op_74hc_print` | 25 | de T8 uit losse 74HC-chips (plan, gesimuleerd) |
| 06 | `t8_naar_silicium` | 26 | de T8 als Tiny Tapeout-chip |
| 07 | `beeldcomputer` | 27-30 | gesimuleerde beeldcomputer: VGA, framebuffer, SPI, SD-kaart |
| 07 | `beeldcomputer_op_fpga` | 30 | synthese voor de iCE40 (pinbestand, flow) |

## Namen van bestanden

Een achtervoegsel zegt welke versie van de W8 het is: `_f` is de W8F (FPGA), `_i` is met interrupts, `_p` is met pijplijn, `_v` is met video, `_b` is met video en SPI (de beeldcomputer). Bestanden die met `tb_` beginnen zijn testbenches; `test_` zijn Python-tests. De `.hex`-bestanden staan niet in git: `test_labs.py` bouwt ze uit de `.asm`-, `.tta`- en `.fs`-bestanden.
