#!/usr/bin/env python3
"""Draait alle labtests: assembleert .asm-, .fs- en .tta-bestanden, compileert en draait elke tb_*.v
met Icarus Verilog en draait test_*.py. Controleert ook dat elke include="..." in src/**/*.md bestaat.
Een lab slaagt als er geen FAIL in de output staat en er minstens één PASS in voorkomt.
Gebruik: ./test_labs.py                      (alles)
         ./test_labs.py 04 w8_cpu            (week_04 en w8_cpu)
         ./test_labs.py 07_de_beeldcomputer  (alle labs van een fase)"""
import re, sys, subprocess, pathlib, glob
root = pathlib.Path(__file__).parent
labs = root / "labs"

# elke include="..." in src/**/*.md moet naar een bestaand bestand in labs/ wijzen
inc = re.compile(r'include="([^"]+)"')
for md in sorted(glob.glob(str(root / "src" / "**" / "*.md"), recursive=True)):
    for path in inc.findall(pathlib.Path(md).read_text()):
        if not (labs / path).is_file():
            print(f"ONTBREEKT labs/{path} (uit {pathlib.Path(md).name})"); sys.exit(1)

def lab_mappen():
    """(fasemap, labmap) voor elke labmap, in cursusvolgorde."""
    for fase in sorted(p for p in labs.iterdir() if p.is_dir()):
        for d in sorted(p for p in fase.iterdir() if p.is_dir() and p.name != "__pycache__"):
            yield fase, d

bad = 0
only = sys.argv[1:]
bekend = {n for fase, d in lab_mappen() for n in (fase.name, d.name)}
bekend |= {d.name[5:] for fase, d in lab_mappen() if d.name.startswith("week_")}
onbekend = [o for o in only if o not in bekend]
if onbekend:
    print(f"Onbekende selectie: {', '.join(onbekend)}. Kies een labmap, een fasemap of een weeknummer (04).")
    sys.exit(1)

def selected(fase, d):
    return not only or any(o in (d.name, fase.name) or d.name == f"week_{o}" for o in only)

for fase, d in lab_mappen():
    if not selected(fase, d): continue
    if (d / "asm.py").exists():
        for a in sorted(d.glob("*.asm")):
            r = subprocess.run(["python3", "asm.py", a.name], capture_output=True, text=True, cwd=d)
            if r.returncode:
                print(f"ASM-FOUT {d.name}/{a.name}\n{r.stderr}"); bad += 1
    if (d / "forth.py").exists():
        for a in sorted(d.glob("*.fs")):
            r = subprocess.run(["python3", "forth.py", a.name], capture_output=True, text=True, cwd=d)
            if r.returncode:
                print(f"FORTH-FOUT {d.name}/{a.name}\n{r.stderr}"); bad += 1
    if (d / "tta_asm.py").exists():
        for a in sorted(d.glob("*.tta")):
            r = subprocess.run(["python3", "tta_asm.py", a.name], capture_output=True, text=True, cwd=d)
            if r.returncode:
                print(f"TTA-ASM-FOUT {d.name}/{a.name}\n{r.stderr}"); bad += 1
    for t in sorted(d.glob("test_*.py")):
        r = subprocess.run(["python3", t.name], capture_output=True, text=True, cwd=d)
        ok = r.returncode == 0 and "PASS" in r.stdout
        print(("ok   " if ok else "FOUT ") + f"{d.name}/{t.name}")
        if not ok: print(r.stdout[-800:], r.stderr[-600:]); bad += 1
    srcs = [f for f in d.glob("*.v") if not f.name.startswith("tb_")]
    for tb in sorted(d.glob("tb_*.v")):
        exe = root / "build" / f"{d.name}_{tb.stem}.vvp"
        exe.parent.mkdir(exist_ok=True)
        c = subprocess.run(["iverilog", "-g2012", "-I", str(d), "-o", str(exe), str(tb), *map(str, srcs)],
                           capture_output=True, text=True, cwd=d)
        if c.returncode:
            print(f"COMPILE-FOUT {d.name}/{tb.name}\n{c.stderr}"); bad += 1; continue
        try:
            r = subprocess.run(["vvp", str(exe)], capture_output=True, text=True, cwd=d, timeout=120)
        except subprocess.TimeoutExpired:
            print(f"TIMEOUT {d.name}/{tb.name}"); bad += 1; continue
        ok = "FAIL" not in r.stdout and "PASS" in r.stdout and r.returncode == 0
        print(("ok   " if ok else "FOUT ") + f"{d.name}/{tb.name}")
        if not ok: print(r.stdout[-800:], r.stderr[-400:]); bad += 1
sys.exit(1 if bad else 0)
