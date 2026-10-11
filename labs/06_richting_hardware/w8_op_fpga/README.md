# w8_op_fpga

De W8F op een FPGA-bord: toplevel, synthese-scripts, gate-level simulatie en een UART-programma. Achtervoegsel `_f` betekent: de FPGA-versie (W8F), `_i`: met interrupts.

Hoort bij week 23-24 van de cursus. Draai de tests met:

```text
python3 test_labs.py w8_op_fpga
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `alu.v` | 8-bit (parametrisch) ALU met vlaggen Z, N, C, V. |
| `control_f.v` | Besturing voor de FPGA-vriendelijke W8F. Zelfde controlegeheugen als control_i, maar het datageheugen geeft zijn gegevens pas een klokperiode na het adres (blok-RAM). |
| `control_i.v` | De besturingseenheid: een controlegeheugen (control store) dat voor elke combinatie van (opcode, stap) een controlewoord oplevert. Stap 0 = ophalen, stap 1 = uitvoeren. |
| `cpu_f.v` | W8F: de FPGA-vriendelijke W8I. Datageheugen in blok-RAM, LD kost 3 cycli. |
| `cpu_i.v` | W8 met apparaten en interrupts. |
| `datapath_i.v` | Het datapath: PC, instructieregister, registerbestand, ALU, vlaggen. |
| `fpga_top.v` | Het toplevel voor een FPGA-bord: klok, een resetknop, LED's en een seriële poort. |
| `fpga_top_f.v` | Het toplevel voor een FPGA-bord: klok, een resetknop, LED's en een seriële poort. |
| `fpga_top_small.v` | Dezelfde FPGA-top, maar met een kleine "klok" zodat de gate-level simulatie van de netlijst snel is. |
| `idecode.v` | Haalt de velden uit een 16-bit instructie. |
| `memories.v` | Instructiegeheugen: 256 woorden van 16 bit, asynchroon lezen, gevuld uit een hex-bestand. |
| `memories_f.v` | Datageheugen met synchrone uitlezing: de data verschijnt een klokperiode na het adres. |
| `mmio.v` | Het datageheugen met apparaten (memory-mapped I/O). |
| `mmio_f.v` | Het datageheugen met apparaten (memory-mapped I/O). |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_blink_f.v` | Testbench voor `blink_f`. |
| `tb_f_compare.v` | Dezelfde programma's op W8I (asynchroon RAM) en W8F (blok-RAM, LD in 3 cycli): het resultaat moet identiek zijn, en W8F mag precies één cyclus per uitgevoerde LD langer … |
| `tb_fpga_top_f.v` | Test van het toplevel met een kleine "klok" zodat de simulatie snel is: 16 klokcycli per UART-bit. |
| `tb_gate.v` | Test van het toplevel met een kleine "klok" zodat de simulatie snel is: 16 klokcycli per UART-bit. |
| `tb_irq_f.v` | Test van interrupts en apparaten: timer, UART met polling, UART met interrupt. |

## Programma's

| Bestand | Wat |
|---|---|
| `blink.asm` | Knipperlicht: de timer-interrupt wisselt bit 0 van de GPIO-uitgang (een LED). De hoofdlus doet niets. |
| `calls.asm` | Subroutines met CALL en RET. R7 bevat het terugkeeradres, dus een geneste aanroep moet het bewaren. |
| `gcd.asm` | Grootste gemene deler van 252 en 105 (Euclides met aftrekken). Resultaat in R1 (21). |
| `hello.asm` | Zegt "W8 OK" via de UART en laat daarna een LED knipperen met de timer. |
| `mul.asm` | 16-bit product van 200 x 150 met shift-and-add. Resultaat in R5:R4 (0x7530 = 30000). |
| `primes.asm` | Zeef van Eratosthenes voor 2..99. Vlaggen op adres 100+n. R3 = aantal priemgetallen (25). |
| `sort.asm` | Bubble sort van 8 bytes op adres 16..23 (zonder teken, oplopend). |
| `sum.asm` | Som van 1 tot 10. Resultaat in R1 (55). |
| `timer.asm` | Een timer-interrupt tijdens een rekenlus. R6 is gereserveerd voor de interruptroutine. |
| `timer_uit.asm` | Dezelfde rekenlus, zonder timer: de referentie. Het resultaat moet gelijk zijn aan dat van timer.asm. |
| `uart.asm` | Verzend "HI" via de UART en lees het terug (de testbench sluit de zender aan op de ontvanger). |
| `uart_irq.asm` | Ontvang bytes via een interrupt. De routine zet elke ontvangen byte in een buffer vanaf 0x30 en telt op adres 0x21. De hoofdlus wacht tot er 3 bytes binnen zijn. |

## Scripts en tests

| Bestand | Wat |
|---|---|
| `asm.py` | Assembler voor de 8-bit CPU van deze cursus. |
| `fpga_flow.sh` | Synthese, plaatsen en routeren, en een bitstream voor een iCE40-FPGA, met de open-source tools. |
| `gatesim.sh` | Gate-level simulatie: de testbench draait op de door Yosys gesynthetiseerde netlijst (LUT's, flipflops, blok-RAM) in plaats van op je Verilog. |

## Overig

| Bestand | Wat |
|---|---|
| `hello.dat` |  |
| `sort.dat` |  |
