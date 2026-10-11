# t8_naar_silicium

De T8 als kleine chip voor Tiny Tapeout: de kern, het ROM en scripts die de omvang berekenen.

Hoort bij week 26 van de cursus. Draai de tests met:

```text
python3 test_labs.py t8_naar_silicium
```

## Ontwerp (Verilog)

| Bestand | Wat |
|---|---|
| `rom_t8.v` | Gegenereerd door mkrom.py. Niet met de hand aanpassen. |
| `t8_core.v` | De kern van de T8, met instelbare breedte van de programmateller (PCW) en van het geheugenadres (AW). |
| `tt_t8.v` | Het toplevel voor Tiny Tapeout: de T8 als kleine chip. De poortnamen volgen de afspraak van het project. |
| `tta.v` | T8: een transport-triggered architecture. De enige instructie is MOVE: bron -> bestemming. |

## Testbenches

| Bestand | Wat |
|---|---|
| `tb_core_equiv.v` | De parametriseerbare kern (met PCW = 8, AW = 8) moet exact de machine uit week 19 zijn. |
| `tb_tt_t8.v` | De chip: het Fibonacci-programma draait en de uitgangspennen tonen de rij. |

## Programma's

| Bestand | Wat |
|---|---|
| `chip.tta` | Het programma in de chip: de rij van Fibonacci (modulo 256) op de uitgangspennen, een getal per zes klokcycli. |

## Scripts en tests

| Bestand | Wat |
|---|---|
| `chip_size.sh` | Schat de grootte van de chip: Yosys zet het ontwerp om in eenvoudige poorten en flipflops, zoals voor een echte chip. |
| `core_size.py` | Schat de grootte van de programmeerbare T8-kern (zonder programma): de instructie is een ingang van de chip, |
| `mkrom.py` | Maakt van een T8-programma (.hex van tta_asm.py) een synthetiseerbaar ROM-module in Verilog. |
| `test_mkrom.py` | Het gegenereerde ROM moet precies de woorden van het programma bevatten; en het mag niet groter zijn dan het adresbereik. |
| `tta_asm.py` | Assembler voor de transport-triggered architecture T8. |
