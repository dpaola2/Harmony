# PCBWay bare-board submission

Dave requested PCBWay submission on October 11, 2026, conditional on the ongoing physical fit test. He selected bare boards and will solder the socket strips himself.

The package is for quotation and engineering review. Fabrication release and payment wait for the fit result. This file does not establish that PCBWay accepted the order; see `submission-status.json` for the observed website state.

| Setting | Value |
| --- | --- |
| Quantity | 5 single boards |
| Designs | 1 |
| Outline | 53.5 × 28.3 mm, with edge notch |
| Layers | 2 |
| Material | FR-4, standard PCBWay TG grade |
| Thickness | 1.6 mm |
| Copper | 1 oz |
| Solder mask / legend | Green / white |
| Finish | Lead-free HASL |
| Track/space quote tier | 6/6 mil; board rule is 0.20 mm minimum spacing |
| Smallest finished hole | 0.8 mm |
| Assembly / stencil | None |
| Impedance / edge plating | None |

`Harmony-Mark7-Carrier-A-Gerbers.zip` contains seven Gerber layers, the Gerber job file, and separate plated/nonplated Excellon drill files. The board has 41 plated holes and eight nonplated holes. There are no SMT parts or vias.

The exported outline was independently parsed at 53.5 × 28.3 mm centerline dimensions. The 0.05 mm plotted stroke adds 0.05 mm to rendered bounds. All drill files share the Gerber absolute origin. The source PCB hash and archive hash are recorded in `package-verification.json`.

The final supplier review increased legend strokes from 0.12 to 0.15 mm to meet PCBWay's published minimum. Text is at least 0.8 mm tall. Electrical and mechanical geometry are unchanged. KiCad DRC and independent net/pin checks pass after this change. Exported copper and legend layers were rendered for visual inspection.

Supplier note:

> Bare PCB only. Harmony Mark7 passive Feather carrier Rev A. Finished board outline is 53.5 x 28.3 mm; preserve the antenna edge notch. PTH and NPTH drill files are separate. Drill dimensions are finished hole sizes. No assembly or stencil. Quote/engineering review only pending customer physical fit test; do not start fabrication before customer release/payment.

Regenerate with `uv run --with gerbonara python ../package_pcbway.py` from this directory, after rebuilding and verifying the PCB. Any changed archive must be uploaded again; never assume the cart updates automatically.

[PCBWay capabilities](https://www.pcbway.com/capabilities.html) supplies the fabrication limits. [Carrier design](../README.md) records the socket choices, revised rear tray, fit instructions, and unresolved physical checks.
