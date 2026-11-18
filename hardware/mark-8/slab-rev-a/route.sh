#!/bin/sh
# Two-phase Freerouting run (see export_dsn.py): switching signals, then DC nets.
# Usage: ./route.sh [passes-S] [passes-P]
#
# Phase S is sensitive to the router's cost settings: one setting can leave an SPI line with no way
# across the wheel while another routes everything. So phase S runs with a short list of settings and
# keeps the first result that leaves no switching net open (the USB pair is hand-routed whole, and
# Freerouting sometimes reports it open). If none is clean, it keeps the best one.
set -eu
cd "$(dirname "$0")"
K=../../../firmware/toolchains/kicad-8.0.9/KiCad.app/Contents
PY=$K/Frameworks/Python.framework/Versions/3.9/bin/python3
JAVA=${JAVA:-/opt/homebrew/opt/openjdk/bin/java}      # Freerouting 2.4.1 needs Java 25 or newer
FR=../../../firmware/toolchains/freerouting/freerouting-2.4.1.jar
FRARGS="--gui.enabled=false --usage_and_diagnostic_data.disable_analytics=true"
mkdir -p review
$PY export_dsn.py S 2>&1 | grep -v "leak\|Debug"
open_nets() {   # switching nets a phase-S log leaves open
  grep -A30 "could not be routed" "$1" | grep -v WARN | grep "Net '" | sed "s/.*Net '\([^']*\)'.*/\1/" \
    | grep -v -E '^(GND|ELE[0-9]+|USB_DP|USB_DN)$' | tr '\n' ' ' || true
}
best=""; bestn=999
for opt in "--router.scoring.via_costs=100" "--router.scoring.via_costs=50" "--router.scoring.via_costs=120" \
           "--router.scoring.via_costs=200" "--router.scoring.via_costs=70" "--router.scoring.via_costs=85" \
           "--router.scoring.via_costs=60" "--router.scoring.via_costs=150" "--router.scoring.via_costs=40" \
           "--router.scoring.via_costs=100 --router.scoring.start_ripup_costs=50" \
           "--router.scoring.via_costs=70 --router.scoring.start_ripup_costs=200"; do
  $JAVA -Djava.awt.headless=true -jar $FR $FRARGS $opt -de routing-s.dsn -do review/_s.ses -mp "${1:-40}" \
    > review/_s.log 2>&1
  left=$(open_nets review/_s.log); n=$(echo $left | wc -w | tr -d ' ')
  echo "phase S $opt: open [$left]"
  if [ "$n" -lt "$bestn" ]; then
    bestn=$n; best=$opt; cp review/_s.ses routing-s.ses; cp review/_s.log review/freerouting-s.log
  fi
  [ "$n" = "0" ] && break
done
rm -f review/_s.ses review/_s.log
echo "phase S kept: $best ($bestn switching nets open)"
$PY import_ses.py routing-s.ses 2>&1 | grep -v "leak\|Debug"
$PY export_dsn.py P 2>&1 | grep -v "leak\|Debug"
$JAVA -Djava.awt.headless=true -jar $FR $FRARGS -de routing-p.dsn -do routing-p.ses -mp "${2:-60}" > review/freerouting-p.log 2>&1
grep -A40 "could not be routed" review/freerouting-p.log | grep -v WARN | head -40 || true
$PY import_ses.py routing-p.ses 2>&1 | grep -v "leak\|Debug"
