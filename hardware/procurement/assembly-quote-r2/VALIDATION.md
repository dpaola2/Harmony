# R2 package validation

Codex independently reran native KiCad 8.0.9 checks on both boards after Sol froze the correction. All 567 electrical pin/net assignments agree with the routed PCB, including the repaired -5VA/GND separation. Both PCB hashes are unchanged from the original source.

Mainboard ERC is 10 errors/95 warnings; DRC is 38 errors/45 warnings; parity has 10 non-net warnings. Faceplate ERC is 2/24; DRC is 6/13; parity has 9 non-net warnings. No rule findings were waived. See the [independent review](../../reviews/harmony-r2/REVIEW.md) and its complete finding register.

The BOM and placement files are regenerated from the unchanged boards. Programming images retain the prior build hashes. The generator records all derived source files in its manifest, so the upstream commit alone is not presented as the identity of the corrected schematic.

These checks do not constitute fabrication, assembly, battery/display fit, or firmware qualification approval.
