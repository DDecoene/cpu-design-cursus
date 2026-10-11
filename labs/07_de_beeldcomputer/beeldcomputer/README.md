# beeldcomputer

De beeldcomputer, gesimuleerd: VGA-generator, framebuffer, SPI, een model van een SD-kaart en de bootcode van de W8F. De testbenches schrijven beelden naar `build/` in de hoofdmap. Achtervoegsel `_v` betekent: met video, `_b`: met video en SPI.

Hoort bij week 27-30 van de cursus. Draai de tests met:

```text
python3 test_labs.py beeldcomputer
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `alu.v` | 8-bit (parametrisch) ALU met vlaggen Z, N, C, V. |
| `beeld_top.v` | De complete beeldcomputer: CPU, SPI naar de SD-kaart, framebuffer en VGA-uitgang. |
| `beeld_v.v` | CPU en beeld aan elkaar: de W8F met het framebuffer en de VGA-uitgang. Twee klokken: clk voor de CPU, pclk voor het beeld. |
| `control_f.v` | Besturing voor de FPGA-vriendelijke W8F. Zelfde controlegeheugen als control_i, maar het datageheugen geeft zijn gegevens pas een klokperiode na het adres (blok-RAM). |
| `cpu_b.v` | W8F: de FPGA-vriendelijke W8I. Datageheugen in blok-RAM, LD kost 3 cycli. |
| `cpu_v.v` | W8F: de FPGA-vriendelijke W8I. Datageheugen in blok-RAM, LD kost 3 cycli. |
| `datapath_i.v` | Het datapath: PC, instructieregister, registerbestand, ALU, vlaggen. |
| `fb_ram.v` | Het framebuffer: 9600 bytes, twee pixels per byte, met twee klokken. |
| `idecode.v` | Haalt de velden uit een 16-bit instructie. |
| `memories.v` | Instructiegeheugen: 256 woorden van 16 bit, asynchroon lezen, gevuld uit een hex-bestand. |
| `memories_f.v` | Datageheugen met synchrone uitlezing: de data verschijnt een klokperiode na het adres. |
| `mmio_b.v` | De geheugenkaart met video en SPI: mmio_v met de SPI-poort op 0xFC tot 0xFF erbij. |
| `mmio_f.v` | Het datageheugen met apparaten (memory-mapped I/O). |
| `mmio_v.v` | De geheugenkaart van W8F met de videoregisters erbij. |
| `reset_sync.v` | Een reset die asynchroon begint en synchroon eindigt: twee flipflops (week 6). Elk klokdomein krijgt er een. |
| `sd_model.v` | Een SD-kaart in SPI-modus, alleen voor simulatie. |
| `spi_io.v` | De registers van de SPI-poort, zoals de CPU ze ziet (adressen 0xFC tot en met 0xFE): 0xFC  SPI_DATA    schrijven: begin een overdracht van dit byte; lezen: het laatst … |
| `spi_master.v` | SPI-master, modus 0: de klok is in rust laag, de data wordt op de stijgende flank gelezen en na de dalende flank veranderd. |
| `vga_bars.v` | Testbeeld: een witte rand, acht kleurbalken en een grijsverloop. |
| `vga_mon.v` | Een virtuele monitor, alleen voor simulatie. |
| `vga_sync.v` | De tijdbasis van een VGA-beeld: twee tellers die pixels en lijnen tellen. |
| `vga_testbeeld.v` | Het eerste complete beeld: tijdbasis plus testbeeld, met uitgangsregisters. |
| `video_io.v` | De registers van het beeld, zoals de CPU ze ziet (adressen 0xF8 tot en met 0xFB): 0xF8  FB_LO      laag byte van het byteadres in het framebuffer (lezen en schrijven) … |
| `video_out.v` | Van framebuffer naar VGA-pinnen. Het scherm is 160 x 120 blokken van 4 x 4 pixels, elk blok met een van 16 kleuren. |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_beeld_top.v` | De hele beeldcomputer: een SD-kaartmodel met het demobeeld, het bootprogramma op de CPU, en de virtuele monitor. |
| `tb_beeld_v.v` | De hele keten: de CPU voert kleurbalken.asm uit, schrijft de balken in het framebuffer, en we kijken met de virtuele monitor wat er op het scherm staat. |
| `tb_spi.v` | Test van de SPI-master: bitvolgorde, klok in rust laag, 8 pulsen per byte, snelheid en het negeren van een schrijfactie tijdens een overdracht. |
| `tb_spi_cpu.v` | De CPU stuurt de SPI-poort aan (MISO verbonden met MOSI) en meldt via de GPIO hoeveel bytes goed terugkwamen. |
| `tb_vga_sync.v` | Controleert de VGA-timing met losse tellers die de getallen uit de specificatie letterlijk gebruiken. |
| `tb_vga_testbeeld.v` | Het testbeeld bekijken met de virtuele monitor en elke pixel van het eerste volledige beeld controleren. |
| `tb_video_io.v` | De videoregisters via de buslijnen van de CPU: adres instellen, auto-increment, grens bij 9600 en de vblank-status. |
| `tb_video_out.v` | Schrijft een patroon rechtstreeks in het framebuffer (zonder CPU) en controleert elke pixel van het scherm. |

## Programma's

| Bestand | Wat |
|---|---|
| `boot.asm` | Het bootprogramma van de beeldcomputer: start de SD-kaart op, lees 19 blokken van 512 bytes en zet ze in het framebuffer. |
| `kleurbalken.asm` | Vult het hele scherm met 16 verticale balken, een per palletkleur, en meldt dat het klaar is. |
| `spi_test.asm` | Test van de SPI-poort met een lus: de testbench verbindt MISO met MOSI, dus elk verzonden byte moet terugkomen. |

## Scripts en tests

| Bestand | Wat |
|---|---|
| `asm.py` | Assembler voor de 8-bit CPU van deze cursus. |
| `mkbeeld.py` | Maakt het beeld voor de beeldcomputer: 160 x 120 pixels, 16 kleuren, twee pixels per byte (de linker in de hoge nibble). |
| `ppm2png.py` | Zet een binaire PPM (P6) om naar PNG, zodat je het beeld uit de simulatie in een gewone viewer kunt openen. Alleen standaardbibliotheek. |
| `test_mkbeeld.py` | Test van mkbeeld.py: dezelfde palette als de hardware, de omzetting heen en terug, de demo en de PPM-invoer. |
| `test_ppm2png.py` | Test van ppm2png.py: een klein PPM-bestand omzetten en de PNG weer uitpakken. |

## Overig

| Bestand | Wat |
|---|---|
| `boot.dat` |  |
| `sd.img` |  |
