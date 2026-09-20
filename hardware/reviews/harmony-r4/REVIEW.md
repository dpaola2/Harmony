# Harmony R4 review

**Use the unmodified current Tangara boards for the first build.** R4 restores upstream jack geometry and filled copper. The production archive corroborates the original jack, USB and display footprint geometry. We have no measured failure that justifies keeping R3's physical departures. The later upstream connector replacement remains necessary to the chosen reference revision.

## Verified

- Both R4 PCB files are byte-identical to public Tangara commit `9853b4a1dc8a0e3ea3ec75450522e42df12eaa52`.
- Native pcbnew inventory and fresh schematic netlists agree on 459 mainboard and 108 faceplate pin/net assignments. Neither board has unconnected items.
- R3's schematic corrections remain. No circuit topology, firmware, battery harness or enclosure change was made.
- Quote-only MPN overrides complete U12 as `BD91N01NUX-E2`, U4 as `TLV75533PDBVR`, and U5 as `PE1605C4A6_R1_00001`, with manufacturer sources. These do not authorize purchasing.

## Decisions on prior holds

| Finding | R4 disposition |
|---|---|
| J1 slot size, two small annuli and cutout | Restore upstream geometry. The archived factory files show the same original features. Ask PCBWay to accept these exact finished tolerances; retain the finding until CAM review. |
| USB drawing versus 1.6 mm board | Preserve the upstream connector/geometry. Designer specifies 1.6 mm boards; production pads, drills and edge geometry corroborate it. Treat it as a documented fabrication detail, not a mandate to redesign. |
| Touch copper and guard refill | Restore the upstream board and fills. Native zero-gap errors compare an electrode's netted pad with its own unnetted artwork. The measured inter-electrode gaps remain about 0.28–0.29 mm and isolated. CAM etching review and physical calibration through our printed cover remain necessary. |
| U15 one-spoke warning introduced by refill | Restored upstream fill removes that new finding; no starved-thermal finding is reported on R4. |
| FLT open-drain output tied to ground | Retain production connection and accurate pin type. ERC flags the source-flag conflict. The output is unused; do not change production wiring simply to suppress ERC. |
| Library/type/silkscreen warnings | Retained in native reports. Do not update footprints or refills automatically. CAM may propose necessary changes for explicit review. |

## Native reports

| Board | ERC errors / warnings | DRC errors / warnings | Parity warnings | Unconnected |
|---|---:|---:|---:|---:|
| Mainboard | 1 / 94 | 38 / 45 | 9 | 0 |
| Faceplate | 0 / 24 | 6 / 13 | 9 | 0 |

Restoring the source restores its DRC findings. Counts are not a quality score. No rule or exclusion was weakened. The complete register includes native records and review categories; supplier acceptance remains pending for fabrication tolerances. This is not a claim of hardware qualification or an approved fabrication release.

## Evidence

- [Native connectivity](connectivity-verification.json), [read-only check run](native-check-run.json), [finding register](finding-dispositions.json)
- [Production archive comparison](/Users/dave/projects/assistant/05-projects/mp3-player/deliverables/2026-09-15-component-verification/production-archive/README.md)
- [Current quote package](../../procurement/assembly-quote-r4/README.md)

HARMONY-15 owns engineering review; HARMONY-9 owns sourcing. PCBWay showed no reply to the sent R3 request when checked September 15 around 11:41 EDT. R4 has not been submitted. Actual price, quantity, substitutions, CAM acceptance, assembly/programming scope, battery and case fit remain to be settled before a purchase/release decision.
