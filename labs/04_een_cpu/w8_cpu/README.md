# w8_cpu

De 8-bit CPU van de cursus, de W8: ALU, datapath, besturing, de Python-assembler en de testprogramma's. Je bouwt hem in vijf weken op in deze ene map.

Hoort bij week 13-17 van de cursus. Draai de tests met:

```text
python3 test_labs.py w8_cpu
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `alu.v` | 8-bit (parametrisch) ALU met vlaggen Z, N, C, V. |
| `asm_funcs.vh` | Mini-assembler in Verilog-functies: bouw een instructiewoord uit zijn velden. |
| `control.v` | De besturingseenheid: een controlegeheugen (control store) dat voor elke combinatie van (opcode, stap) een controlewoord oplevert. Stap 0 = ophalen, stap 1 = uitvoeren. |
| `cpu.v` | De complete CPU: datapath + besturing + geheugens. |
| `datapath.v` | Het datapath: PC, instructieregister, registerbestand, ALU, vlaggen. |
| `idecode.v` | Haalt de velden uit een 16-bit instructie. |
| `memories.v` | Instructiegeheugen: 256 woorden van 16 bit, asynchroon lezen, gevuld uit een hex-bestand. |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_answers.v` | Controleert de uitwerkingen van de oefeningen van week 17. |
| `tb_asm.v` | Draait zes door de assembler gemaakte programma's tegelijk, elk op zijn eigen CPU. |
| `tb_control.v` | Testbench voor `control`. |
| `tb_datapath.v` | We spelen zelf "besturingseenheid": we zetten de besturingssignalen per klokcyclus. |
| `tb_isa.v` | Testbench voor `isa`. |
| `tb_programs.v` | Zet een programma klaar, reset de CPU en draai tot HALT (of tot een limiet). |
| `tb_random.v` | Test met willekeurige programma's. Een "instructieset-simulator" (ISS) in de testbench voert hetzelfde programma uit met gewone gehele getallen. |
| `tb_run.v` | Draait een geassembleerd programma op de CPU en toont het eindresultaat. |
| `tb_trace.v` | Een "trace": bij elke uitgevoerde instructie een regel met PC, instructie en registers. |

## Programma's

| Bestand | Wat |
|---|---|
| `add16.asm` | 16-bit optelling: (R2:R1) + (R4:R3) = (R6:R5). Hier 0x01FF + 0x0001 = 0x0200. |
| `calls.asm` | Subroutines met CALL en RET. R7 bevat het terugkeeradres, dus een geneste aanroep moet het bewaren. |
| `gcd.asm` | Grootste gemene deler van 252 en 105 (Euclides met aftrekken). Resultaat in R1 (21). |
| `memcpy.asm` | Kopieert 8 bytes van adres 16 naar adres 48. |
| `mul.asm` | 16-bit product van 200 x 150 met shift-and-add. Resultaat in R5:R4 (0x7530 = 30000). |
| `popcount.asm` | Telt de bits die 1 zijn in R1 (0xB7 heeft er 6). Resultaat in R2. |
| `primes.asm` | Zeef van Eratosthenes voor 2..99. Vlaggen op adres 100+n. R3 = aantal priemgetallen (25). |
| `reverse.asm` | Keert de bits van R1 om (0xB4 -> 0x2D). Resultaat in R2. |
| `sort.asm` | Bubble sort van 8 bytes op adres 16..23 (zonder teken, oplopend). |
| `strlen.asm` | Lengte van een tekst met 0 als einde. De tekst "HELLO" staat op adres 32. |
| `sum.asm` | Som van 1 tot 10. Resultaat in R1 (55). |

## Scripts en tests

| Bestand | Wat |
|---|---|
| `asm.py` | Assembler voor de 8-bit CPU van deze cursus. |
| `run.sh` | Gebruik: bash run.sh programma.asm Assembleert het programma en draait het op de W8-CPU in de simulator. |
| `test_asm.py` | Tests voor de assembler: bekende codes, fouten, labels en negatieve getallen. |

## Overig

| Bestand | Wat |
|---|---|
| `memcpy.dat` |  |
| `sort.dat` |  |
| `strlen.dat` |  |
