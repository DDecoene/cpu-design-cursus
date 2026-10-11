# w8_pipeline

De W8 met een pijplijn van twee trappen, naast de gewone W8 om de uitkomsten te vergelijken.

Hoort bij week 20 van de cursus. Draai de tests met:

```text
python3 test_labs.py w8_pipeline
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `alu.v` | 8-bit (parametrisch) ALU met vlaggen Z, N, C, V. |
| `asm_funcs.vh` | Mini-assembler in Verilog-functies: bouw een instructiewoord uit zijn velden. |
| `control.v` | De besturingseenheid: een controlegeheugen (control store) dat voor elke combinatie van (opcode, stap) een controlewoord oplevert. Stap 0 = ophalen, stap 1 = uitvoeren. |
| `control_p.v` | Besturing voor de gepijplijnde W8: geen stappen meer. In elke cyclus wordt tegelijk de volgende instructie opgehaald (pc_inc, ir_we) en de huidige uitgevoerd. |
| `cpu.v` | De complete CPU: datapath + besturing + geheugens. |
| `cpu_p.v` | De gepijplijnde W8 (twee trappen: ophalen en uitvoeren). Hergebruikt het datapath ongewijzigd. |
| `datapath.v` | Het datapath: PC, instructieregister, registerbestand, ALU, vlaggen. |
| `idecode.v` | Haalt de velden uit een 16-bit instructie. |
| `memories.v` | Instructiegeheugen: 256 woorden van 16 bit, asynchroon lezen, gevuld uit een hex-bestand. |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_compare.v` | Draait hetzelfde programma op de W8 (twee cycli per instructie) en op de gepijplijnde W8P, controleert dat het eindresultaat identiek is en meet de cycli. |
| `tb_pipe_random.v` | Test met willekeurige programma's. Een "instructieset-simulator" (ISS) in de testbench voert hetzelfde programma uit met gewone gehele getallen. |

## Programma's

| Bestand | Wat |
|---|---|
| `calls.asm` | Subroutines met CALL en RET. R7 bevat het terugkeeradres, dus een geneste aanroep moet het bewaren. |
| `gcd.asm` | Grootste gemene deler van 252 en 105 (Euclides met aftrekken). Resultaat in R1 (21). |
| `mul.asm` | 16-bit product van 200 x 150 met shift-and-add. Resultaat in R5:R4 (0x7530 = 30000). |
| `primes.asm` | Zeef van Eratosthenes voor 2..99. Vlaggen op adres 100+n. R3 = aantal priemgetallen (25). |
| `sort.asm` | Bubble sort van 8 bytes op adres 16..23 (zonder teken, oplopend). |
| `sum.asm` | Som van 1 tot 10. Resultaat in R1 (55). |

## Scripts en tests

| Bestand | Wat |
|---|---|
| `asm.py` | Assembler voor de 8-bit CPU van deze cursus. |

## Overig

| Bestand | Wat |
|---|---|
| `sort.dat` |  |
