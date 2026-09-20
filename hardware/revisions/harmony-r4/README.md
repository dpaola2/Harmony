# Harmony R4: Tangara source boards

R4 uses both routed PCBs from Tangara commit `9853b4a1dc8a0e3ea3ec75450522e42df12eaa52` without modification. It retains R3's schematic pin-type, hidden-pad net and label corrections. All 567 numbered pad/net assignments match the schematics. Local footprint files come from the pinned public reference.

This revision restores the upstream audio-jack slots, lands and cutout, and upstream copper fills. R3's physical jack changes and touch/thermal refill changes are withdrawn from this proposed build. The later upstream G-Switch connector and button geometry remain.

The original June 2024 factory exports provide manufacturing evidence; R4 is based on the later August 2025 public revision and is not an exact copy of that old factory package. Full order codes are documented in the quote BOM overrides, leaving CAD files intact.

[Review](../../reviews/harmony-r4/REVIEW.md), [quote package](../../procurement/assembly-quote-r4/README.md). Engineering/quote review only; no fabrication release. Keep the upstream CERN-OHL-S-2.0 license. R1 enclosure CAD and all earlier packages remain unchanged.
