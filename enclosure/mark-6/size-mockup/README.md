# Mark-6 size mockup

September 21, 2026. HARMONY-17. Placement revision B.

The solid dummy is **74 x 178 x 28 mm**. Use it to judge pocket fit, grip and
thumb reach before fixing the carrier outline. It has a recessed screen guide
and wheel guide. It does not hold electronics, reproduce button travel or
predict the finished player's weight. The 28 mm depth remains an assumption.

Open [the 3MF](print/harmony-mark6-size-74x178x28.3mf) or
[the STL](print/harmony-mark6-size-74x178x28.stl) in Bambu Studio. The 3MF contains
geometry only. Use millimeters and 100% scale, with the flat back on the bed
and recessed face up. A starting point for a size check is PLA, 0.2 mm layers,
two walls and 10% infill. Supports are unnecessary for this geometry. Check
the slicer's dimensions read 74 x 178 x 28 mm before printing. No printer job
has been submitted.

The layout retains the 3.5-inch display and factory-headered Feather #5900.
Turning the ANO board 90 degrees and using the actual vendor antenna rectangle
reduces the earlier 190 mm study by 12 mm. The antenna clearance is still a
layout reservation: socket copper, housing effects and final radio range need
review. The proposed carrier cutout, cable bends, mounting hardware and complete
component stack have not been modeled.

The CAD and mesh checks cover one valid connected solid, watertight/winding
properties, the requested dimensions, a flat bed at Z=0, and a geometry-only
3MF export/import round trip. Results and delivered-file hashes are in
[validation.json](validation.json). These checks do not establish physical fit.

Rebuild from this directory:

```sh
uv run --with cadquery==2.8.0 --with trimesh --with matplotlib --with networkx --with lxml python build.py
```

The PDF and model use the same
[mechanical layout source](../../../hardware/mark-6/carrier-rev-a/mechanical_layout.py).
See the [carrier design record](../../../hardware/mark-6/carrier-rev-a/README.md)
and [print-scale study](../../../hardware/mark-6/carrier-rev-a/output/pdf/placement-study.pdf)
for board dimensions, radio reservations and source provenance. The editable
solid is [STEP format](cad/harmony-mark6-size.step).
