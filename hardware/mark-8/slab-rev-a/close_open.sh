#!/bin/sh
# Repair loop: delete what DRC objects to, route every open connection with maze.py, stitch GND,
# until DRC reports no copper errors and nothing unconnected (at most ROUNDS rounds, default 6).
# The board of the best round (no errors, fewest unconnected) is kept: a rescue round can leave more open.
set -eu
set -o pipefail 2>/dev/null || true
cd "$(dirname "$0")"
K=../../../firmware/toolchains/kicad-8.0.9/KiCad.app/Contents
PY=$K/Frameworks/Python.framework/Versions/3.9/bin/python3
CLI=$K/MacOS/kicad-cli
quiet() { grep -v "leak of type\|Debug: Adding duplicate" || true; }
mkdir -p review
count() {
  $CLI pcb drc --format json --severity-all --output review/_open.json harmony-mark8-slab.kicad_pcb >/dev/null
  python3 -c "
import json; d = json.load(open('review/_open.json'))
e = [v for v in d['violations'] if v['severity'] == 'error']
print(len(d['unconnected_items']), len(e))"
}
prev=""; same=0; rescue=0; ripall=0; best=999
for round in $(seq 1 "${ROUNDS:-6}"); do
  $PY drc_clean.py --dangling-closed 2>&1 | quiet | tail -3
  set -- $(count)
  echo "round $round: $1 unconnected, $2 errors"
  if [ "$2" = "0" ] && [ "$1" -lt "$best" ]; then best=$1; cp harmony-mark8-slab.kicad_pcb review/_best.kicad_pcb; fi
  [ "$1" = "0" ] && [ "$2" = "0" ] && break
  # When two rounds in a row change nothing, run a rescue round: the few connections left may push any
  # routed copper aside (never a hand route); the next ordinary rounds route the displaced copper again.
  if [ "$1 $2" = "$prev" ]; then same=$((same + 1)); else same=0; fi
  prev="$1 $2"; ripall=0
  if [ "$same" -ge 1 ]; then
    [ "$rescue" -ge "${RESCUES:-4}" ] && break
    rescue=$((rescue + 1)); same=0; prev=""
    # the first two rescue rounds move only DC and static copper (it can use L3 and vias anywhere, so it
    # finds a new path easily); later ones may move any routed copper
    if [ "$rescue" -le 2 ]; then ripall=dc; else ripall=1; fi
    echo "rescue round $rescue ($ripall)"
  fi
  rm -f review/_dump.json review/_routes.json
  RIP_ALL=$ripall $PY route_dump.py review/_open.json review/_dump.json 2>&1 | quiet
  norip=1; [ "$ripall" != "0" ] && norip=0
  MAZE_NORIP=$norip uv run --quiet --with numpy --with scipy --with matplotlib python maze.py review/_dump.json review/_routes.json
  $PY apply_routes.py review/_routes.json 2>&1 | quiet
  $PY fixups.py 2>&1 | quiet | grep -v "^   "
done
set -- $(count)
if [ "$best" -lt 999 ] && { [ "$2" != "0" ] || [ "$1" -gt "$best" ]; }; then
  cp review/_best.kicad_pcb harmony-mark8-slab.kicad_pcb
  echo "kept the best round: $best unconnected"
  set -- $(count)
fi
if [ "$1" = "0" ]; then
  $PY drc_clean.py --dangling 2>&1 | quiet | tail -1
  set -- $(count)
fi
echo "after repair: $1 unconnected, $2 errors"
rm -f review/_open.json review/_dump.json review/_routes.json review/_gnd_orphans.json review/_best.kicad_pcb
