# Harmony R3 engineering review

R3 corrects the remaining power-source model, makes the touch electrodes visible to KiCad's net checker, and repairs the audio-jack footprint. All 567 schematic/PCB pin connections agree with R2. Both boards report zero unconnected items; this is not hardware qualification. Fabrication remains on hold for the specific issues below.

Sol handled the schematic work; a second subagent reviewed touch geometry and independently checked the root's jack correction. Root rejected a proposed passive type for TPS22948's open-drain FLT pin, restored the manufacturer type, reran native KiCad 8.0.9, checked bounded geometry changes, and independently reconciled the quote package.

| Native check | R2 mainboard | R3 mainboard | R2 faceplate | R3 faceplate |
|---|---:|---:|---:|---:|
| ERC errors / warnings | 10 / 95 | 1 / 94 | 2 / 24 | 0 / 24 |
| DRC errors / warnings | 38 / 45 | 22 / 43 | 6 / 13 | 0 / 13 |
| Non-net parity warnings | 10 | 9 | 9 | 9 |
| Unconnected PCB items | 0 | 0 | 0 | 0 |

The [complete register](finding-dispositions.json) retains all 215 remaining native findings. No project rules or exclusions changed. Independent wheel measurements are also retained because native DRC omits those graphic-to-graphic gaps.

## Confirmed changes

- TPS65133 supply/ground/output and INA1620 enable pin types now match their functions. Flags identify verified USB, switched-USB and ground sources, plus connector-supplied faceplate rails. Three unused bus entries were removed; J2's label now matches the PCB. Six corrected project symbols match their embedded copies. [Power review](power/REVIEW.md), [symbol audit](power/symbol-delta-audit.md).
- Five touch shapes now carry their actual nets. Their copper contours are exactly preserved, with Gerber equivalence verified before refill. A native GND refill increases guard clearance from 0.254499 to 0.500499 mm. SW1's plated touch pad has the correct footprint type. [Physical evidence](physical/handoff.json).
- J1 now uses the manufacturer's eight 1.10 × 0.70 mm slots and 10.10 mm cutout. Two copper lands were resized and offset to maintain clearance and annulus. All hole centres remain fixed. Native reimport proves the reusable library matches the board, including masks and edge geometry. Nominal minimum annuli are 0.150 mm, or 0.1632 mm for pins 2 and 6. Finished tolerances still require supplier review. [Independent jack review](physical/jack-review.json).

Root verified unchanged pad centres, tracks, vias and unrelated footprints. Only J1 pad/cutout geometry, explicit electrode net metadata, footprint attributes and native zone fills changed on the boards. The [source patch](r2-to-r3.patch) and [native reconciliation](independent-native-verification.json) identify the changes. R1 case CAD and accepted fit clearances remain unchanged.

## Release holds

**USB fit comes first.** GCT's A1 drawing specifies a recommended 0.80 mm PCB; this mainboard's stack-up totals 1.60252 mm. The 1.60 mm figure in the connector title describes its mounting offset, not PCB thickness. Twelve J6 pads also end at the routed cutout. Obtain a section/sample fit check and explicit fabrication tolerance acceptance, or revise the connector footprint. This review does not establish incompatibility, but it does establish an unresolved discrepancy. [Archived primary drawing](sources/USB4510-03-1-A.pdf).

**Wheel geometry needs an engineering decision.** The three pair gaps are 0.282097, 0.291368 and 0.292112 mm against a 0.5 mm netclass. They are isolated, not shorted. The retained sliver warning belongs to the Pin 3 electrode polygon. CAM review must address etching, and the prototype must establish touch performance through the printed cover. The reported dangling LED_ENABLE via is intentional TP7 plated test access and is preserved.

**Mainboard refill exposes a thermal-relief finding.** U15 pad 39 has one B.Cu spoke where two are configured. Native connectivity still passes. Review the multilayer ground connection and reflow needs before a local correction or specific acceptance.

The remaining ERC error is the unused FLT output tied to GND and conflicting with its source flag; a warning also concerns WM8523 SDOUT/DEEMPH on that net. Manufacturer pin types remain intact. Library warnings comprise 110 standard power-symbol differences plus SW1; the six corrected custom models match. Mixed plated/SMT metadata, anonymous artwork references, other footprint-library differences and clipped/small silkscreen remain individually registered for review, not silently refreshed.

The [R3 quote package](../../procurement/assembly-quote-r3/README.md) passes independent manifest, BOM, placement and firmware-image reconciliation: 92 mainboard plus 19 faceplate fitted components; 59 excluded structures; 11 unchanged programming images. [DFM questions](../../procurement/assembly-quote-r3/DFM-QUESTIONS-DRAFT.md) are drafted and unsent. Battery/display dimensions and physical firmware/runtime tests remain separate holds. No order, supplier submission or full-case print is justified by these checks alone.
