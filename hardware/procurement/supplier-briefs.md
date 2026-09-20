# Harmony supplier briefs

HARMONY-9. Drafts for review, prepared September 13, 2026. Neither brief has been sent. These describe quote scope; they do not authorize fabrication or component substitutions.

## Board assembly quote

Please quote 1, 2, and 5 complete sets of Tangara electronics. Each set contains one mainboard and one faceplate. Quote the two board types separately, showing bare-board minimums, assembled quantities, unused boards, setup charges, component costs, final assembly, programming, testing, and shipping to the Pittsburgh, Pennsylvania area, USA.

The starting reference is Cool Tech Zone's open hardware at `https://codeberg.org/cool-tech-zone/tangara-hw`, commit `9853b4a1dc8a0e3ea3ec75450522e42df12eaa52`. Mainboard and faceplate are nominally 1.6 mm with ENIG. Preserve each board's copper stack-up and dimensions; the reference mainboard has four copper layers. Retain original antenna clearance, mounting holes, and connector positions. Please flag every unavailable component and proposed substitute, with its datasheet and footprint difference, before purchase or assembly.

Please include procurement and final attachment of the EastRising ER-TFT018-4 bare display and Vybronics VC1034B018F ERM motor, or list any consigned parts required. Include all connectors, through-hole work, switches, and the specified DNP population. Use a three-wire protected LiPo configuration with real NTC sensing; the battery-emulation resistor R1 remains unpopulated. Battery charge-current settings must be reconciled with the selected pack before release.

Please quote SAMD bootloader installation through SWD, SAMD application and ESP32 flashing, and functional inspection. The final programming package will include verified binaries, hashes, addresses, and expected checks. If you cannot perform programming or display/motor attachment, identify that clearly rather than treating those operations as included.

Requested test scope: optical inspection, solder/short inspection, startup and USB enumeration, display, SD access, controls, haptics, wired output, and Bluetooth playback using the supplied test procedure. Battery charging and NTC behavior require the selected pack or an agreed test fixture. Please identify fixture/setup costs and any test you cannot perform. Return the approved final BOM and placement records with the assemblies.

Before this draft can become a submitted fabrication request, Codex must reconcile the actual BOM/placement files, generate or retrieve matching Gerbers/drills, review ERC/DRC, freeze the firmware pair, and attach display/battery drawings. The designer's linked production ZIP currently requires forum access; the local schematic source is available, but that ZIP has not been authenticated or inspected. Do not describe the current reference snapshot as fabrication-approved.

Primary route: [PCBWay](https://www.pcbway.com/Order/QuickOrderOnline). Comparison route: [JLCPCB](https://jlcpcb.com/pcb-assembly). No supplier account or contact information has been submitted.

## Battery sample quote

Please confirm whether five LP574459 samples are currently available, including protection circuitry, a 10 kΩ NTC, and a JST-manufactured PHR-3 three-position connector. Please quote sample cost, harness customization, lead time, and lawful shipment to Pennsylvania, USA. This is a one-device prototype; a production MOQ in the thousands is not suitable.

Please supply a drawing showing maximum finished pack thickness, width, and length, including the protection board, seams, tape, and cable exit; available lead lengths; the connector mating-view pin assignment; NTC resistance at 25°C and its resistance/temperature curve; charge/discharge limits; protection thresholds; and shipping test documentation for the exact pack. The advertised 5.7 × 44 × 59 mm cell dimensions are insufficient to establish enclosure fit.

The pack is for a 4.2 V charge-voltage, single-cell MCP73871 system. Connector pin order must match the supplied Tangara J7 drawing; do not assume that a three-pin JST-PH connector uses a universal polarity. Please provide a proposed harness drawing for review before manufacture. The final case will be fitted to the reviewed finished-pack dimensions and its required clearance.

Candidate source: [LiPol LP574459](https://www.lithium-polymer-battery.net/lithium-polymer-battery-lp574459-2000mah-3-7v-7-4wh-with-pcm-and-ntc-and-wires/). If stocked samples are unavailable, report that rather than quoting a mass-production run as the only option.

## Cross-references

- [Shopping list](README.md)
- [Implementation plan](../../docs/Harmony-2026-implementation-plan.md)
- [Pinned electronics](../tangara-reference/README.md)
- HARMONY-9; HARMONY-8
