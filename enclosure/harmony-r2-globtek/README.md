# Harmony R2 GlobTek fit prototype

Print `print/harmony-globtek-fit.3mf` at 100% scale. It contains the new back, battery tray and a solid battery-size dummy. Reuse the R1 front that already fits. The plate contains geometry, not printer settings or G-code.

The back is 6 mm deeper, giving a nominal 29.2 mm assembled body thickness. Its upper seam and port geometry are preserved. Rear screw seats move down 6 mm, so fastening needs correspondingly longer screws of the original type; verify engagement before tightening.

The tray allows a 78 × 31 × 9.3 mm battery body. The separate clearance envelope is 79 × 32 × 10.5 mm. This is provisional clearance, not a manufacturer-qualified swelling allowance. Try the printed dummy first. Actual pack, electronics, wiring, padding and tray/pack retention still need dry fitting. Do not squeeze the battery to close the case.

`validation.json` records zero modeled part/clearance intersections, valid solids, watertight meshes and A1 bed bounds. Electronics are not included in these interference checks. The original R1 files are preserved.

Build with `uv run --with cadquery==2.8.0 --with trimesh python build.py`. Source geometry and licensing come from `../harmony-r1/source/`; derived from Cool Tech Zone Tangara under CERN-OHL-S-2.0. `sha256.json` records output hashes.
