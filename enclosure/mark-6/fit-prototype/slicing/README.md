# Mark 6 prepared A1 plates

Open either project in Bambu Studio. These are locally sliced projects for the Bambu Lab A1, 0.4 mm nozzle, Bambu PLA Basic and Textured PEI Plate. They contain model geometry, settings and G-code. Confirm those choices against the installed hardware and loaded spool before printing. Preparation did not send a printer job or alter the active Studio project.

| Plate | Contents | Estimate |
| --- | --- | --- |
| [Shells](shells/harmony-mark6-shells-a1.3mf) | One tray and one front, both flat | 83.9 minutes, 64.74 g |
| [Optional fit pieces](gauges/harmony-mark6-gauges-a1.3mf) | One carrier gauge and four 12 mm ANO spacers | 32.5 minutes, 14.80 g |

Settings: 0.20 mm layers, four wall loops, five top/bottom layers, 15% gyroid, supports off, brim off and print by layer. The first two layers form the 0.4 mm display bezel. From layer three, the larger rear recess is open. The tray's card opening includes a roughly 20 mm bridge; inspect that area on the printed part. The small spacers need good bed adhesion.

Both plates fit the 256 mm bed without model scaling. Exported project G-code matches the separately saved G-code byte for byte. Bambu Studio returned success and no plate-level slicing warnings. Its log also notes unspecified filament color and an unused tree-support default; support remains disabled. Estimates include the slicer's startup allowance, not a measured print duration.

The [shell path preview](shells/toolpath-review.png) shows Z0.2, 0.4, 0.6 and 15.4 mm. The [fit-piece preview](gauges/toolpath-review.png) shows the gauge and all four spacers. These plots use deposited straight and arc paths from the exported G-code. Results and hashes are in [verification.json](verification.json).

Rebuild from the parent directory with `python3 prepare_slicing.py`, then `uv run --with matplotlib python verify_slicing.py`. The script uses an isolated temporary settings directory and the installed Bambu Studio profiles. Physical assembly instructions remain in the [fit-prototype README](../README.md).
