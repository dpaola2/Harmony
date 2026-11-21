#!/bin/sh
# Rebuild the Mark-8 slab board package from design.py.
#   ./rebuild.sh             restore the checked routing from routing-final.json (exact, a few minutes)
#   ROUTE=loop ./rebuild.sh  replay routing-s.ses and routing-p.ses, then run the repair loop (about an hour)
#   ROUTE=1 ./rebuild.sh     route again with Freerouting first (results vary from run to run)
#   STOCK=1 ./rebuild.sh     also re-query JLCPCB stock (network)
# ROUTE=loop and ROUTE=1 save their result to routing-final.json.
set -eu
cd "$(dirname "$0")"
K=../../../firmware/toolchains/kicad-8.0.9/KiCad.app/Contents
PY=$K/Frameworks/Python.framework/Versions/3.9/bin/python3
CLI=$K/MacOS/kicad-cli
NAME=harmony-mark8-slab
quiet() { grep -v "leak of type\|Debug: Adding duplicate" || true; }

echo "== libraries, schematic, netlist, ERC"
$PY make_lib.py 2>&1 | quiet
python3 build_schematic.py
$CLI sch export netlist --format kicadxml --output netlist.xml $NAME.kicad_sch >/dev/null
$CLI sch erc --format json --severity-all --output erc.json $NAME.kicad_sch >/dev/null
mkdir -p review
$CLI sch export pdf --output review/schematic.pdf $NAME.kicad_sch >/dev/null

echo "== placement, zones, hand routes"
$PY build_pcb.py 2>&1 | quiet
[ -f lib/model_geometry.json ] || uv run --quiet --with cadquery==2.8.0 python measure_models.py

echo "== routing"
ROUTE=${ROUTE:-0}
[ -f routing-final.json ] || [ "$ROUTE" != "0" ] || ROUTE=loop
$PY late_routes.py 2>&1 | quiet                     # late hand routes, fixed before any router runs
if [ "$ROUTE" = "0" ]; then
  $PY finish_pcb.py 2>&1 | quiet                    # L1 and L3 ground pours
  $PY routing_snapshot.py restore 2>&1 | quiet
  $PY review_fixes.py 2>&1 | quiet                  # layout fixes of the 2026-11-21 pre-order review
else
  if [ "$ROUTE" = "1" ] || [ ! -f routing-p.ses ]; then
    ./route.sh
  else
    $PY import_ses.py routing-s.ses 2>&1 | quiet
    $PY import_ses.py routing-p.ses 2>&1 | quiet
  fi
  $PY strip_wheel_violations.py 2>&1 | quiet
  $PY finish_pcb.py 2>&1 | quiet
  $PY fixups.py 2>&1 | quiet | grep -v "^   "
  ROUNDS=16 ./close_open.sh
  $PY routing_snapshot.py save 2>&1 | quiet
fi

echo "== DRC and verification"
$PY refill.py 2>&1 | quiet
$CLI pcb drc --format json --severity-all --output drc.json $NAME.kicad_pcb >/dev/null
$CLI pcb drc --format report --severity-all --output review/drc.rpt $NAME.kicad_pcb >/dev/null
$PY verify.py 2>&1 | quiet | tail -25

echo "== 3D, renders, JLCPCB package"
mkdir -p jlcpcb
$CLI pcb export step --subst-models --force --output jlcpcb/$NAME.step $NAME.kicad_pcb >/dev/null
uv run --quiet --with cadquery==2.8.0 python export_3d.py
./render.sh
[ "${STOCK:-0}" = "1" ] && python3 -I check_stock.py
$PY package_jlc.py 2>&1 | quiet
echo "done"
