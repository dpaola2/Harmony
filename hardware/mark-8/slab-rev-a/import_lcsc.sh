#!/bin/sh
# Re-import the LCSC/EasyEDA symbols, footprints and STEP models into lib/easyeda (network).
# make_lib.py turns these into lib/Harmony8.pretty + lib/Harmony8.3dshapes with corrected model
# transforms. Only needed when a part changes; the project library is committed.
set -eu
cd "$(dirname "$0")"
mkdir -p lib/easyeda
for id in C2980306 C2858418 C62892 C424093 C841192 C2682616 C91322 C527464 C7519 C165948 \
          C2889267 C114218 C54582899 C110293 C720477 C94598 C15127 C20917 C8598 C2286; do
  uv run --quiet --with easyeda2kicad easyeda2kicad --full --overwrite --lcsc_id=$id --output lib/easyeda/lcsc
done
