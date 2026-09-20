# Harmony: build the player you want to carry

September 13, 2026. Proposed direction, tracked in HARMONY-8. Dave confirmed an iPod-style capacitive ring and a Bambu A1. Twenty hours of Bluetooth playback is a provisional target; he has not specified a runtime number.

I recommend building Harmony on Tangara's open electronics and firmware, then making the enclosure and interface our own. Tangara already combines the hardware this project needs. Keeping its board layout gives us a case we can design against actual connector positions and mounting holes. The first Harmony case is in [enclosure/harmony-r1](../enclosure/harmony-r1/README.md).

The previous plan optimized for hearing a song through wired headphones. It deferred Bluetooth, the wheel, battery operation, and the enclosure. Those are now the product. A VS1053 breakout would advance the old milestone while leaving the Bluetooth decoding and transmission path unresolved. I would stop buying toward that milestone.

The current Harmony2 code is a useful UI experiment: both audio backends only print messages. The existing test suite passes (9 passed, 2 skipped), but it does not demonstrate playback. There is no working audio implementation to migrate. Preserve the simulator and its navigation ideas; let native firmware handle decoding, buffers, Bluetooth, and power.

Tangara is a close match: ESP32-WROVER, a capacitive wheel with haptics, USB-C, removable storage, and open PCB and firmware sources. It also has a wired headphone output. Its 1.8-inch 160×128 display is a compromise against a newer, sharper screen. Replacing that display immediately would require a different faceplate and driver work. [Manufacturer overview](https://cooltech.zone/tangara/)

This choice still needs a hardware trial. The advertised 20-hour listening figure does not establish 20 hours over Bluetooth, and users have reported pocket dropouts. Test the headphones Dave will use before investing in a custom PCB revision. Retail units are currently marked unavailable; the practical route is assembled PCBs or an available donor. The designer also reports possible discontinued BOM parts. [Product listing](https://www.crowdsupply.com/cool-tech-zone/tangara), [pocket reception report](https://forum.cooltech.zone/showthread.php?action=lastpost&tid=188), [designer's manufacturing notes](https://forum.cooltech.zone/showthread.php?pid=1466)

An original electronics design remains a reasonable second choice if authorship of the circuit itself matters more than reaching a carryable player. It would use a Classic-Bluetooth ESP32, native audio firmware, a dedicated touch controller, and a charger with power-path management. That requires a new schematic, PCB, and bring-up cycle. Tangara gives us a working reference for all of those decisions.

[Technical comparison, architecture, battery calculations, and build acceptance](Harmony-2026-technical-basis.md).

[Complete case and printing guide](../enclosure/harmony-r1/README.md). The CAD is a fit prototype; physical fit and playback performance remain unverified.

[Current parts sourcing and costs](../hardware/procurement/README.md). [Implementation plan for review](Harmony-2026-implementation-plan.md).
