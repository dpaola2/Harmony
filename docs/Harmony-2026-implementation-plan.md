# Harmony 2026 roadmap

Reconciled September 16, 2026. WCP `HARMONY/harmony-2026-implementation-plan-md` owns the current roadmap; work-item status and next actions live in HARMONY. This replaces the September 13 proposal as the working sequence. Dated delivery packages remain historical evidence.

## Where we are

We are at the quote and manufacturing-review stage, before ordering the first Tangara-based prototype boards. The design package and firmware builds are complete. Dave reports the full R1 front/back print succeeded and the pieces fit very nicely. No complete Harmony player has been assembled or qualified. The battery has been purchased and the revised rear case is printing; a battery is not required for initial USB-powered board bring-up.

The current device uses Tangara reference electronics/native ESP32 and SAMD firmware, a capacitive ring, Bluetooth audio, USB-C and a Bambu A1 enclosure. The MicroPython simulator remains historical work and a navigation reference. The earlier breadboard/VS1053 sequence is superseded.

## Milestones

| Milestone | State on September 16 | Evidence or remaining condition |
| --- | --- | --- |
| 1. Select foundation and prepare enclosure | Complete for prototype preparation | Tangara basis selected; R1 CAD/print package checked; Dave accepted the printed seam coupons. This does not establish whole-device fit. [[HARMONY-8]], [[HARMONY-10]]. |
| 2. Prove firmware builds | Complete on the build side | ESP32/SAMD applications and bootloader built; 11 programming images and hashes recorded. No hardware playback qualification. [[HARMONY-11]]. |
| 3. Reconcile boards and prepare quote files | Complete for quote submission | All 567 pin/net assignments reconcile. R4 restores the pinned upstream routed boards. BOM, placements, manufacturing files and programming package verified and uploaded. [[HARMONY-13]], [[HARMONY-14]]. |
| 4. Review manufacturing response and landed cost | Waiting on PCBWay | Final component-inclusive quote, manufacturing acceptance, substitutions, assembly/programming/test scope and freight remain open. No purchase or fabrication release. [[HARMONY-15]], [[HARMONY-9]]. |
| 5. Select and qualify battery | GlobTek selected for prototype integration; qualification open | BL2200F9031781S1PCKT, 2200 mAh, $16.52 each at DigiKey. Revised cage/back, harness mapping and local 4.1 V charger/BOM draft prepared. Temperature-cutoff and charge-cycle qualification remain. Purchased September 16 per Dave; portable charging remains unqualified. [[HARMONY-9]], [[HARMONY-15]]. |
| 6. Order and receive prototype boards | Not started | Requires satisfactory milestone 4 review and Dave's approval of the actual order total. Requested two assembled mainboards and two faceplates, with five bare boards each due to the supplier minimum. |
| 7. Bring up electronics on USB | Waiting on assembled boards | Inspect, verify power, program, test SD/display/ring/buttons/haptics, then wired and Bluetooth playback. Battery selection does not gate this milestone. |
| 8. Integrate battery and final enclosure | R1 shell fit successful; revised back printing | Dave confirmed September 16 that the pieces fit very nicely. Dave reports the revised rear case is printing. GlobTek fit plate includes the 6 mm deeper back, tray and dummy; tray/dummy printing has not been reported. Reuse R1 front. CAD checks pass. Final populated-board, display and battery fit, retention, charging and pocket radio performance remain pending. |
| 9. Customize and qualify the finished player | Later | Harmony UI after baseline playback works; measured runtime, reconnect/resume, filesystem recovery, final assembly and restore documentation. |

Milestones overlap. Stage count is not a percentage of completion: fabrication, debugging and physical qualification still carry substantial uncertainty.

## Done

- Tangara production archive obtained and compared with current public sources; obsolete assumptions about required board redesign corrected.
- R4 routed boards restored to the upstream baseline; schematic corrections and complete ordering codes retained. The inherited 239 design findings remain documented for manufacturing review, not represented as a clean DRC report.
- Exact R4 quote uploaded to PCBWay on September 15 at 12:24 EDT. Mainboard W1170583AS3P1 / T-3P2W1170583A; faceplate W1170583AS1Y3 / T-1Y4W1170583A.
- Display drawing recovered and conditional CAD comparison completed. Actual display/lens/flex fit still needs physical confirmation.
- Both battery inquiries sent at approximately 16:15 EDT. Source-history investigation and Jauch adaptation calculations documented.
- Firmware build evidence, print package, accepted coupon observation and prototype test sequence saved.

## Waiting and blocked dependencies

**Board release:** Last cart observation September 16 at 16:55 EDT: both bare boards Pass/Payment, both assemblies Being reviewed, components unpriced. Ivy's September 16 email says PCBWay does not perform a DFM review; do not treat the quote audit as broad design validation. A complete component-inclusive quote and scoped manufacturing response remain pending. The review window runs approximately through September 17. Reconcile battery-related charger changes before assembly release.

**Battery-powered completion:** GlobTek BL2200F9031781S1PCKT is selected as the prototype integration target under Dave's instruction to choose an affordable stocked pack. September 16 observation: 286 at $16.52 each; two $33.04. Prepared cart estimate was $48.14 including ground freight and tariff; final paid total/quantity are unverified. Selection ends the default search for an exact Tangara pack. Mechanical adaptation, connector mapping and same-footprint 4.1 V U10 draft are prepared locally. R5 draft preserves all 459 mainboard nets and board geometry. The new target still needs a built harness and verified physical charging behavior. Its 10 kΩ NTC curve/tolerance remains unknown, so portable charging is not qualified. A physical characterization and cutoff-test procedure is saved; this can be checked with actual hardware without waiting for a supplier reply. Battery purchased September 16 per Dave; final paid amount and delivery unverified. Submitted PCBWay package unchanged. LiPol's $300 five-pack quote and follow-up remain secondary evidence.

**Physical validation:** boards have not been ordered or received. We cannot claim actual playback, charging, runtime, assembled enclosure fit or pocket Bluetooth performance from builds and CAD alone.

**ALAC:** [[HARMONY-12]] tracks a source-level metadata-bounds concern. It blocks ALAC qualification, not MP3-only initial bring-up. No device crash has been reproduced.

## Next actions, in order

1. Resolve the next supplier-facing step: carry the prepared U10 4.1 V substitution into PCBWay's assembly quote before approval. It is still local and unsent; prepare a concrete quote-change message for Dave's send authorization. Continue the existing four-hour quote/reply monitor. Assess any PCBWay questions and battery specifications against the saved R4 package. Notify Dave when there is a meaningful change or a concrete decision.
2. Dry-fit the revised GlobTek back/tray with the printed dummy, then actual hardware. Verify NTC and charging behavior when the pack/board are available. Before hardware arrives, prepare the small MP3 acceptance library, test-result recording and bench-equipment checklist. Investigate the ALAC boundary issue separately if ALAC is included in the qualification scope; preserve the proven baseline.
3. When the quote arrives, reconcile component stock, substitutions, manual display/motor assembly, programming, testing, quantity and combined freight. Include the prepared U10 substitution in the assembly quote review. Present the actual total and remaining risks for Dave's purchase decision.
4. After approved boards arrive, perform USB-only bring-up. Continue GlobTek integration independently; do not delay USB-only electrical tests for battery qualification.
5. Qualify the chosen pack, fit the full enclosure, then customize the interface and run the final use tests.

Dave has no immediate action from this roadmap review. His next expected decision is the actual board order/cost, while we await the purchased battery (shipment and delivery date unverified). Tools on hand and intended headphones will be needed for the physical test setup.

## Scope and acceptance corrections

Long battery life is a user requirement. The earlier 20-hour Bluetooth figure and $600–900 allowance were assistant planning proposals, not adopted numeric acceptance or spending limits. Measure runtime with the selected pack and agree the target before final qualification. An available half-capacity test pack does not silently change the intended device requirement.

Retain the original display, upstream board layout and firmware through initial acceptance. Track the selected GlobTek's charger/harness adaptation explicitly against submitted R4; retain the Jauch assessment as a historical fallback. Battery purchase is reported by Dave. Board purchases, paid engineering and manufacturing release have not occurred. Prior authorization covered the recorded quote uploads and two battery inquiries.

## Evidence and related work

- [[HARMONY-9]]: sourcing, battery selection and quote coordination.
- [[HARMONY-15]]: R4 manufacturing review and release criteria.
- [[HARMONY-8]], [[HARMONY-10]]: enclosure design and accepted coupon experiment.
- [[HARMONY-11]], [[HARMONY-12]]: built firmware baseline and ALAC follow-up.
- [[HARMONY-13]], [[HARMONY-14]]: completed quote-package preparation and schematic reconciliation.
- Vault project hub: `/Users/dave/projects/assistant/05-projects/mp3-player/_index.md`.
- R4 quote evidence: `/Users/dave/projects/assistant/05-projects/mp3-player/deliverables/2026-09-15-pcbway-r4/README.md`.
- Battery and test evidence: `/Users/dave/projects/assistant/05-projects/mp3-player/deliverables/2026-09-15-component-verification/README.md`.

