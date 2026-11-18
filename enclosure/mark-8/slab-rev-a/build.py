"""Rebuild everything for the Harmony Mark-8 slab rev A enclosure.

    uv run --with cadquery==2.8.0 --with matplotlib --with trimesh --with rtree \
        --with scipy --with markdown python build.py

Writes step/, print/, renders/, checks/ and ASSEMBLY.html, and refreshes the
generated tables in README.md. The first run reads the 73 MB board STEP once and
caches it in .cache/ (git-ignored).
"""
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import checks  # noqa: E402
import docs  # noqa: E402
import export  # noqa: E402
import model  # noqa: E402
import scenes  # noqa: E402


def main():
    t0 = time.time()

    def log(msg):
        print(f"[{time.time() - t0:6.1f}s] {msg}", flush=True)

    solids, meta = model.build()
    log(f"model: {len(solids)} solids")
    items = {n: (name, src, col) for n, name, src, col in model.ITEMS}

    rows, refs = checks.interference(solids, model.reference_solids())
    clear = checks.clearances(solids)
    dims = checks.dimensions(solids)
    fails = [r for r in rows if r["status"] != "ok"]
    checks.write(os.path.join(HERE, "checks", "interference.json"),
                 {"tolerance_mm3": checks.TOL_VOL, "pairs_checked": checks.STATS.get("pairs_checked"),
                  "pairs_reported": rows, "failures": fails,
                  "reference_solids": refs, "clearances": clear})
    checks.write(os.path.join(HERE, "checks", "dimensions.json"), dims)
    checks.write(os.path.join(HERE, "checks", "fpc-route.json"), meta["fpc"])
    checks.write(os.path.join(HERE, "checks", "battery-fit.json"), {"envelope": meta["battery_fit"], "reference_solids": refs})
    log(f"interference: {len(fails)} failures")

    written, posed = export.export_all(solids, items, HERE)
    log(f"exported {len(written)} files")

    pr = {}
    by = {it["name"]: it["shape"] for it in solids}
    for name, (stem, pose, col) in export.PRINTED.items():
        pr[name] = {"wall": checks.wall_thickness(by[name]),
                    "overhangs": checks.overhangs(by[name], pose)}
    checks.write(os.path.join(HERE, "checks", "printability.json"), pr)
    log("printability done")

    scenes.render_all(solids, meta, os.path.join(HERE, "renders"))
    log("renders done")

    docs.write_all(HERE, solids, meta, rows, refs, clear, dims, pr, checks.STATS)
    log("docs done")
    if fails:
        print("INTERFERENCE FAILURES:")
        for f in fails:
            print("  ", f)
        sys.exit(1)


if __name__ == "__main__":
    main()
