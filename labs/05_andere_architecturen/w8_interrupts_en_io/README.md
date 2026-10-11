# w8_interrupts_en_io

De W8 met apparaten (UART, timer) en interrupts, met voorbeeldprogramma's. Achtervoegsel `_i` betekent: met interrupts.

Hoort bij week 22 van de cursus. Draai de tests met:

```text
python3 test_labs.py w8_interrupts_en_io
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `alu.v` | 8-bit (parametrisch) ALU met vlaggen Z, N, C, V. |
| `asm_funcs.vh` | Mini-assembler in Verilog-functies: bouw een instructiewoord uit zijn velden. |
| `control_i.v` | De besturingseenheid: een controlegeheugen (control store) dat voor elke combinatie van (opcode, stap) een controlewoord oplevert. Stap 0 = ophalen, stap 1 = uitvoeren. |
| `cpu_i.v` | W8 met apparaten en interrupts. |
| `datapath_i.v` | Het datapath: PC, instructieregister, registerbestand, ALU, vlaggen. |
| `fpga_top.v` | Het toplevel voor een FPGA-bord: klok, een resetknop, LED's en een seriële poort. |
| `idecode.v` | Haalt de velden uit een 16-bit instructie. |
| `memories.v` | Instructiegeheugen: 256 woorden van 16 bit, asynchroon lezen, gevuld uit een hex-bestand. |
| `mmio.v` | Het datageheugen met apparaten (memory-mapped I/O). |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_blink.v` | Testbench voor `blink`. |
| `tb_fpga_top.v` | Test van het toplevel met een kleine "klok" zodat de simulatie snel is: 16 klokcycli per UART-bit. |
| `tb_irq.v` | Test van interrupts en apparaten: timer, UART met polling, UART met interrupt. |

## Programma's

| Bestand | Wat |
|---|---|
| `blink.asm` | Knipperlicht: de timer-interrupt wisselt bit 0 van de GPIO-uitgang (een LED). De hoofdlus doet niets. |
| `hello.asm` | Zegt "W8 OK" via de UART en laat daarna een LED knipperen met de timer. |
| `timer.asm` | Een timer-interrupt tijdens een rekenlus. R6 is gereserveerd voor de interruptroutine. |
| `timer_uit.asm` | Dezelfde rekenlus, zonder timer: de referentie. Het resultaat moet gelijk zijn aan dat van timer.asm. |
| `uart.asm` | Verzend "HI" via de UART en lees het terug (de testbench sluit de zender aan op de ontvanger). |
| `uart_irq.asm` | Ontvang bytes via een interrupt. De routine zet elke ontvangen byte in een buffer vanaf 0x30 en telt op adres 0x21. De hoofdlus wacht tot er 3 bytes binnen zijn. |

## Scripts en tests

| Bestand | Wat |
|---|---|
| `asm.py` | Assembler voor de 8-bit CPU van deze cursus. |
| `fpga_flow.sh` | Synthese, plaatsen en routeren, en een bitstream voor een iCE40-FPGA, met de open-source tools. |

## Overig

| Bestand | Wat |
|---|---|
| `hello.dat` |  |
