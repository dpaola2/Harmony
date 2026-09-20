# Harmony shopping list

**R3 engineering update:** [Current quote package](assembly-quote-r3/README.md) and [independent review](../reviews/harmony-r3/REVIEW.md) include verified power, touch-electrode and jack corrections. All 567 pin connections agree; current board geometry is identified by the R3 manifest. USB connector thickness/edge fit, wheel artwork and one thermal relief remain open under HARMONY-15. Earlier packages below are historical evidence.

**R2 circuit correction:** [Updated quote package](assembly-quote-r2/README.md) incorporates the independently verified schematic/library correction. All 567 electrical pin/net assignments agree with the unchanged PCBs. [R2 review](../reviews/harmony-r2/REVIEW.md) records the remaining manufacturing and power-model findings under HARMONY-15. Use R2 for further engineering review; fabrication remains on hold.

**September 14 assembly quote package:** [Per-board BOMs, placements, fabrication and programming files](assembly-quote/README.md) now reconcile to the routed boards. [Independent review](assembly-verification/REVIEW.md) records the checks and unresolved schematic/PCB discrepancy. Use these per-board BOMs for quote review. Fabrication remains on hold; the immediate circuit follow-up is HARMONY-14.

**September 14 engineering update:** [Board interface and component reconciliation](reconciliation/tangara-interface-bom-reconciliation.md) replaces raw schematic-row counting with a routed-PCB inventory and records battery wiring/charge requirements and the matched display electrical pinout. The schematic audit is not an ordering BOM. [Firmware baseline builds](../../firmware/README.md) now pass; physical fit and supplier requirements remain open. Prices below were observed September 13 and have not been refreshed by this engineering update.

Prepared September 13, 2026, for HARMONY-9. Review draft for one working player, with a proposed second set of electronics as a repair spare. US delivery and USD are assumed. Nothing has been ordered or submitted to a supplier.

The practical route is to quote fully assembled Tangara mainboards and faceplates, then buy the external fittings. The small parts are straightforward; the board assemblies and battery determine whether this is a sensible build. [Implementation plan](../../docs/Harmony-2026-implementation-plan.md).

## What to order, and when

| Item | Installed / proposed purchase | Source and observed price | Availability and release condition |
| --- | --- | --- | --- |
| Tangara mainboard PCBA | 1 / quote 1, 2, and 5 | [PCBWay assembly](https://www.pcbway.com/Order/QuickOrderOnline); price requires quote | No stocked assembled board found. Quote all fitted components, connectors, programming, and inspection. Prefer 2 if the incremental cost is reasonable. |
| Tangara faceplate PCBA | 1 / match mainboard quantity | Same PCBWay quote; [pinned sources](../tangara-reference/README.md) | Include display and haptic mounting. The mainboard and faceplate are separate assemblies, not one orderable module. |
| Protected battery with temperature sensing | 1 / quote sample lot of 5 | [LiPol LP574459, 2,000 mAh](https://www.lithium-polymer-battery.net/lithium-polymer-battery-lp574459-2000mah-3-7v-7-4wh-with-pcm-and-ntc-and-wires/); price requires quote | Candidate only. Vendor lists a five-piece sample minimum; stock, finished pack dimensions, connector, NTC curve, and US shipping are unconfirmed. See battery decision below. |
| Display, bare solder-tail panel | 1 / 2 if supplied separately | [EastRising ER-TFT018-4](https://www.buydisplay.com/1-8-inch-128x160-tft-lcd-display-4-wire-spi-st7735s-soldering-type-fpc), $1.87 each, $3.74 for 2 | Listed in stock. Prefer assembler procurement and mounting. Confirm current drawing against faceplate and case before release. Do not buy an SPI breakout with its own PCB. |
| Haptic motor | 1 / 2 if supplied separately | [Vybronics VC1034B018F at DigiKey](https://www.digikey.com/en/products/detail/vybronics-inc/VC1034B018F/6009914), $2.94 each, $5.88 for 2 | Listed in stock. Upstream BOM names this ERM alternative. Verify physical clearance and set the driver for the chosen motor. Prefer assembler mounting. |
| Board ribbon cable | 1 / 2 | [Samtec FJH-15-R-03.00-4 at DigiKey](https://www.digikey.com/en/products/detail/samtec-inc/FJH-15-R-03-00-4/7254685), $2.60 each, $5.20 for 2 | Listed in stock. Exact upstream option: 15 conductors, 0.5 mm pitch, 76.2 mm length, opposite-side contacts. Confirm tin contact finish from the ordered part drawing. |
| M2 female/female standoffs, 6 mm | 4 / 10 | [Würth 970060244 at DigiKey](https://www.digikey.com/en/products/detail/w%C3%BCrth-elektronik/970060244/9488532), $3.80 for 10 | Listed in stock. Exact upstream part, 4 mm hex body. A 10-pack covers two devices and two spares. |
| M2 × 14 mm countersunk screws | 4 / 20 | [Prime-Line 9120640 at Zoro](https://www.zoro.com/prime-line-machine-screw-metric-flat-head-phillip-drive-m2-04-x-14mm-a2-70-stainless-steel-10pk-9120640/i/G400921384/), $9.58 minimum | $4.79 per 10, sold in multiples of two packs. Listing price verified; stock/dispatch not exposed. DIN 965 Phillips alternative. Test head seating in the coupon before buying more. |
| M2 × 8 mm countersunk screws | 4 / 10 | [Prime-Line 9120618 at HD Supply](https://hdsupplysolutions.com/ProductDisplay?catalogId=10054&categoryId=83006&langId=-1&parent_category_rn=&productId=1897003&storeId=10051&top_category=&urlLangId=-1&urlRequestType=Base), $7.29 per 10 | Sign-in required for availability. Same DIN 965 family. The manufacturer direct listing is out of stock; this is a conditional supplier, not confirmed inventory. |
| Clear screen lens material | 1 lens / 1 sheet | [RJ Speed RJS1502 at Hobby Etc](https://store.hobbyetc.com/parts/view/70596), $4.99 | Orderable listing; no stock count. Clear polycarbonate, 8 × 12 inches, nominal .020 inch (0.508 mm). Cut to 39.6 × 34.4 mm, deburr, and measure thickness before fitting. |
| Storage | 1 / 1, or reuse | [SanDisk SDSDUVQ-064G-GN6IN, 64 GB full-size SDXC at B&H](https://www.bhphotovideo.com/c/product/1945432-REG/sandisk_sdsduvq_064g_gn6in_64gb_ultra_uhs_i_sdxc.html), $23.99 | Listed in stock on the product page. Its older replacement page shows $38.95; use the live product/cart price. Full-size SD fits the socket without an adapter. Validate the chosen filesystem in firmware. |
| USB data/charging cable | 1 / reuse, or 1 | [Adafruit 4474, USB-A to USB-C, 1 m](https://www.adafruit.com/product/4474), $4.95 | Listed in stock. Useful for bench flashing and legacy USB power. Also use an existing C-to-C data cable to verify modern USB-C charging in both orientations. |
| Filament | About 46 g including coupons / reuse at least 150 g | [Bambu PLA Basic](https://us.store.bambulab.com/products/pla-basic-filament), listed **from $19.99/kg** | Color and spool/refill selection change price and stock. One color is enough. Reserve material for reprints; no AMS required. Buy PETG only after the fit print passes. |
| Lens tape and battery retention | Small amount / reuse or one supply pack | Thin electronics repair tape for the lens; removable battery pull-tab adhesive for the pack. Supplier/package selection pending. | **$10–20 planning allowance**, not a verified price. Measure adhesive thickness in the stack. Avoid thick foam behind the lens or a glued-in battery with no removal path. |
| Insulating touch cover | 1 / print 2 | [Included touch-cover STL](../../enclosure/harmony-r1/print/touch-cover.stl) | Print at nominal 0.6 mm. If touch testing fails, quote a copper-free 0.6 mm FR4 cover matching the Harmony circular outline. The older stock cover outline is not assumed to fit. |
| Enclosure and fittings | 1 complete set / print after battery selection | [A1 print package](../../enclosure/harmony-r1/README.md) | Front, back, cover, two button caps, hold slider, SD caddy, battery guides. The existing battery envelope is a reference, not a verified purchased pack. |

The proposed separately purchased display, motor, ribbon, standoffs, screw packs, lens sheet, SD card, and USB cable total **$69.42 before shipping and tax**. That subtotal mixes confirmed-stock and conditional listings as marked above. It excludes both PCBAs, battery, filament, adhesives, tools, and any import charges. If the assembler supplies the two displays and motors, remove $9.62 from the separate shopping basket and include those costs in the PCBA quote instead. Reusing an SD card and USB cable removes another $28.94.

For review, reserve **$600–900 for the prototype effort**, including two board sets, a small battery sample lot, small parts, shipment costs, and one round of rework. This is a spending allowance proposed by the assistant, not a supplier estimate or an approved budget. The actual total is the PCBA quote plus the battery quote plus the selected shopping basket and consumables, with freight/tax added once. Reassess the route if the quotes exceed that allowance before treating purchases as committed.

## Battery decision

The original BOM says “3-pin 2200mAh 604560” and “EcoCell LIP2-001,” but those identifiers do not currently describe the same product. [LIP2-001 now lists a 2,000 mAh 113450 three-wire cell](https://ecocell.com.au/product/lipo-2000-113450-3w/). The [2,200 mAh 604560 is LIP2-200](https://ecocell.com.au/product/lipo-2200-604560/) and has two wires with no thermistor. Neither is a verified direct replacement for this build. Preserve the original BOM as historical source, but do not order its battery line blindly.

The preferred quote candidate is **LP574459 with protection, a 10 kΩ NTC, and a JST-manufactured PHR-3 cable assembly** wired to match Tangara J7. Its advertised **cell** dimensions are 5.7 × 44 × 59 mm. Those are not the maximum finished **pack** dimensions. Protection PCB, seams, adhesive, cable exit, and tolerances may still require a revised cage or deeper rear shell. Ask for the complete dimensioned pack drawing and NTC resistance/temperature table. The vendor says five samples are the minimum when stock is available; out-of-stock production quantities would be unsuitable for this one-off project. [Manufacturer listing](https://www.lithium-polymer-battery.net/lithium-polymer-battery-lp574459-2000mah-3-7v-7-4wh-with-pcm-and-ntc-and-wires/)

If samples are unavailable, a domestic fallback is [Adafruit 2011](https://www.adafruit.com/product/2011), **$12.50, listed in stock**, 2,000 mAh and 60 × 36 × 7 mm. It requires a deeper/revised battery compartment and an engineered temperature-sensing harness; it is not a plug-in substitute. [Semitec 103AT-2](https://www.digikey.com/en/products/detail/semitec-usa-corp/103AT-2/16579059), $0.68, and [Adafruit JST-PH three-pin cable 3893](https://www.adafruit.com/product/3893), $1.25, are available harness candidates. Their charger thresholds, physical mounting, insulation, and pin order need electrical review before use. Leave this fallback out of the initial cart. A fixed resistor in place of a temperature sensor is not the proposed final configuration.

A 2,000 mAh pack with 80% assumed usable capacity requires **80 mA average battery current** for 20 hours of playback. At 100 mA it gives 16 hours under that assumption. We will measure actual runtime; a battery label and Tangara's advertised listening time do not establish Bluetooth endurance.

## What belongs in the board quote

Buy the assemblies as complete boards. Do not separately order chips unless the assembler requests consigned parts. The following checks establish that several important ICs remain obtainable; they do not establish availability of every resistor, connector, or protection part.

| Circuit | Exact source MPN | Supplier evidence |
| --- | --- | --- |
| Bluetooth/audio processor | ESP32-WROVER-E-N16R8 | [DigiKey](https://www.digikey.com/en/products/detail/espressif-systems/ESP32-WROVER-E-N16R8/11613135): active, stock listed, $6.32 at quantity 1 |
| USB/power coprocessor | ATSAMD21E18A-AF | [DigiKey](https://www.digikey.com/en/products/detail/microchip-technology/ATSAMD21E18A-AF/5057222): stock listed, $4.35 at quantity 1 |
| Capacitive wheel | AT42QT2120-MMH | [DigiKey](https://www.digikey.com/en/products/detail/microchip-technology/AT42QT2120-MMH/3608499): stock listed, $1.74 at quantity 1 |
| Wired audio DAC | WM8523GEDT/R | [DigiKey](https://www.digikey.com/en/products/detail/cirrus-logic-inc/WM8523GEDT-R/5036729): stock listed, $2.95 at quantity 1 |
| Headphone amplifier | INA1620RTWR | [DigiKey](https://www.digikey.com/en/products/detail/texas-instruments/INA1620RTWR/9555498): stock listed, $8.79 at quantity 1 |
| Charger and power path | MCP73871-2CCI/ML | Exact part is in the pinned schematic. Assembler must confirm the 4.2 V ordering suffix and availability; no voltage-variant substitution. |

USB-C receptacle USB4510-03-1-A, SD socket DM1AA-SF-PEJ(82), FFC connectors, battery header S3B-PH-K-S(LF)(SN), switches, haptic driver DRV2605LDGST, and every passive/protection part remain in the assembly scope. Preserve RF antenna clearance and original mounting-hole/connector positions. [Schematic audit](schematic-parts-audit.json) is an inspection aid; it is not a manufacturing BOM.

[PCBWay](https://www.pcbway.com/Order/QuickOrderOnline) is the first quote route because Tangara's designer says it built the original production batch. Obtain a comparison from [JLCPCB assembly](https://jlcpcb.com/pcb-assembly) if sourcing or setup charges are unfavorable. The designer specifies **1.6 mm mainboard and faceplate, ENIG**. The pinned mainboard has four copper layers; confirm each board's own stack-up. [Designer production discussion](https://forum.cooltech.zone/printthread.php?tid=227), [May 2026 files and specifications](https://forum.cooltech.zone/showthread.php?pid=1466).

The production attachment linked by the designer returned a login/permission page during retrieval. It has not been obtained or checked against our pinned sources. The RFQ brief identifies the files still needed before an actual quote submission. [Supplier briefs](supplier-briefs.md).

## Tools and reuse

The A1 is confirmed owned. Reuse the Mac, USB charger, C-to-C cable, SD reader, headphones, and SD card where available; ownership of those accessories has not been checked. The Olimex and S3 development boards and the small Adafruit display do not go inside this Tangara-based enclosure. Do not buy the old VS1053 breakout for this plan.

Physical work needs a digital caliper, multimeter, suitable precision screwdriver, fine tweezers, and a small file/deburring tool. A soldering station with flux and magnification is needed only if display/motor/harness work is not included in the assembly order. Borrow tools or inventory what is on hand before buying a bench setup.

Request factory installation of the SAMD bootloader and the compatible application/ESP32 firmware. If programming is excluded, select a supported 3.3 V SWD debugger and the exact header/probe arrangement during the firmware stage. A USB cable alone cannot initialize a blank SAMD. Battery runtime can be tested by elapsed playback; detailed optimization also needs a battery-side current logger. A USB input power meter does not measure battery playback consumption.

## Review record

Evidence is from supplier pages retrieved for this review, not live reservations or checkout quotes. Some search indexes carry older captures; stock counts change, so the list reports stock status rather than pretending counts are reserved. Unit prices exclude shipping, taxes, and possible tariffs. The full landed total remains open until the two custom quotes arrive.

The prose uses the engineering-memo register established in the preceding reassessment. The purchase table carries the detail so the decision can stay short. Final review checks: distinct installed versus purchased quantities, no double-counted PCBA components, no unconfirmed stock labeled available, and no battery/case compatibility claim based only on nominal dimensions.

## Cross-references

- [Implementation plan](../../docs/Harmony-2026-implementation-plan.md)
- [Approach reassessment](../../docs/Harmony-2026-reassessment.md)
- [Case and assembly guide](../../enclosure/harmony-r1/README.md)
- [Electronics sources and license](../tangara-reference/README.md)
- HARMONY-9; HARMONY-8; historical purchase task HARMONY-7
