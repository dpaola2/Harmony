#!/bin/sh
set -eu
cd "$(dirname "$0")"
repo=$(cd ../../.. && pwd)
kicad="$repo/firmware/toolchains/kicad-8.0.9/KiCad.app/Contents"
kcli="$kicad/MacOS/kicad-cli"
kpython="$kicad/Frameworks/Python.framework/Versions/3.9/bin/python3"
name=harmony-mark7-carrier
python3 build_schematic.py
"$kcli" sch export netlist --format kicadxml --output netlist.xml "$name.kicad_sch"
"$kpython" build_pcb.py
"$kcli" sch erc --format json --output erc.json "$name.kicad_sch"
"$kcli" pcb drc --format json --output drc.json "$name.kicad_pcb"
"$kpython" verify.py
mkdir -p review
"$kcli" sch export pdf --output review/schematic.pdf "$name.kicad_sch"
"$kcli" pcb export svg --layers F.Silkscreen,Edge.Cuts --page-size-mode 2 --output review/silkscreen.svg "$name.kicad_pcb"
uv run --with cadquery==2.8.0 --with trimesh --with scipy --with networkx --with lxml python build_mechanical.py
uv run --with trimesh --with scipy --with networkx --with lxml python prepare_print.py
uv run --with cadquery==2.8.0 python render.py
