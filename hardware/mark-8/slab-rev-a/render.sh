#!/bin/sh
# Top (component side, L1) and bottom (touch side, L4) renders as PNG from KiCad's SVG plot.
# The bottom render is mirrored, so it shows the touch side the way it faces the device front.
set -eu
cd "$(dirname "$0")"
CLI=../../../firmware/toolchains/kicad-8.0.9/KiCad.app/Contents/MacOS/kicad-cli
PCB=harmony-mark8-slab.kicad_pcb
mkdir -p review
$CLI pcb export svg --layers F.Cu,F.Paste,F.Silkscreen,F.Fab,Edge.Cuts --page-size-mode 2 --exclude-drawing-sheet --output review/_top.svg $PCB >/dev/null
$CLI pcb export svg --layers B.Cu,B.Silkscreen,Edge.Cuts --mirror --page-size-mode 2 --exclude-drawing-sheet --output review/_bottom.svg $PCB >/dev/null
$CLI pcb export svg --layers In1.Cu,Edge.Cuts --page-size-mode 2 --exclude-drawing-sheet --output review/_l2.svg $PCB >/dev/null
$CLI pcb export svg --layers In2.Cu,Edge.Cuts --page-size-mode 2 --exclude-drawing-sheet --output review/_l3.svg $PCB >/dev/null
for n in top bottom l2 l3; do
  magick -density 900 -background white "review/_$n.svg" -flatten "review/render-$n.png"
  rm -f "review/_$n.svg"
done
echo "renders: review/render-top.png review/render-bottom.png review/render-l2.png review/render-l3.png"
