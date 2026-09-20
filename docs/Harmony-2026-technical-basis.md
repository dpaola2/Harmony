# Harmony 2026 technical basis

Supporting design analysis for [the reassessment](Harmony-2026-reassessment.md). HARMONY-8, September 13, 2026.

## Alternatives against this brief

| Approach | Benefit | Cost against the goal | Recommendation |
| --- | --- | --- | --- |
| Continue MicroPython and VS1053 | Reuses the June plan and owned boards | Bluetooth still needs native integration; multiple breakouts make packaging harder | Keep as a bench experiment |
| Original ESP32 PCB and ESP-IDF firmware | Maximum control over the circuit, screen, and dimensions | Must solve audio, wheel, power, RF, assembly, and firmware together | Reserve for a later revision |
| Tangara electronics with Harmony case and UI | Existing complete hardware interfaces and playback firmware | Lower-resolution screen; procurement and Bluetooth tests remain | Preferred first carryable build |
| Linux single-board computer | Familiar software and USB integration | More boot, shutdown, and power-management work for this pocket device | Poor fit for this brief |
| Modified original iPod | Original industrial design and click wheel | Donor dependence and repair constraints; less control over firmware/hardware | Only if the original iPod experience outweighs building Harmony |

## Device architecture

The original `PROJECT_OVERVIEW.md` also contains audio and power shortcuts that should not carry into a build. MAX98357A is a Class-D speaker amplifier, and PCM5102A supplies line output; neither is a general replacement for a headphone driver. The ESP32 plan must name an actual software decoder. LiPo charging, power-path management, cell protection, and voltage regulation are separate requirements. [Analog Devices MAX98357A](https://www.analog.com/en/products/max98357a.html), [TI on PCM5102A output](https://e2e.ti.com/support/audio-group/audio/f/audio-forum/760761/pcm5102-driving-the-hardware-io-pins), [Microchip MCP73871](https://www.microchip.com/en-us/product/mcp73871)

The proposed build preserves Tangara's mainboard, faceplate, and interconnect. MP3 files are decoded to PCM; the Bluetooth path encodes and sends audio to headphones as an A2DP source. A receiver-only Bluetooth module would not meet this requirement. SBC is the baseline codec; aptX, AAC transmission, and LE Audio are not promised. The original ESP32 supports Classic Bluetooth. The owned ESP32-S3 cannot replace it for this native A2DP path. [Espressif Classic Bluetooth documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/bluetooth/classic_bt.html), [Tangara specifications](https://www.crowdsupply.com/cool-tech-zone/tangara)

Tangara uses an ATSAMD21 for USB and power supervision, and an MCP73871 charger in the pinned schematic. Retain the complete power circuit, its battery temperature input, and load sharing. A USB-C socket on a TP4056 module is not an equivalent design. A protected, correctly wired three-wire battery is the preferred fit. The printed cage is matched to the upstream batch-1 battery envelope; a capacity label alone is insufficient to select a replacement. [Electronic design](https://cooltech.zone/tangara/docs/electronic-design/), local pinned source: `hardware/tangara-reference/tangara-mainboard/power.kicad_sch`.

The touch wheel and center use capacitive sensing through an insulating cover. The side controls are physical switches. This differs from the mechanical click of an original iPod; haptics provide feedback. It avoids inventing an unsupported center-button mechanism. Keep the existing AT42QT2120 electrode geometry and calibrate the printed cover against it. [Touchwheel design](https://cooltech.zone/tangara/blog/2024-02-07-touchwheel/)

Music transfer starts with removable SD storage. Current checked-out firmware also exposes USB storage and explicitly requires SAMD21 firmware version 3 or newer. The older website still describes that as future work. Verify both firmware versions together before relying on it; never permit the player and computer to write the filesystem simultaneously. Local evidence: Tangara firmware commit `c092c5aae83aac241b3756b15d8b9dad9ed2c3fd`, `lua/settings.lua`, USB Storage section.

## Battery acceptance

Runtime is measured at the battery during playback. For a 2200 mAh cell with an assumed 80% usable capacity, 20 hours requires an average battery current of at most 88 mA. At 100 mA the same assumption yields 17.6 hours; at 150 mA, 11.7 hours. These are planning calculations, not measurements or predictions. Measuring current on the 3.3 V rail instead requires accounting for voltage conversion and efficiency.

Use MP3 playback, screen off after navigation, Wi-Fi disabled, a fixed headphone volume, and the final SD card. Log elapsed runtime and disconnects through battery shutdown. Run a separate screen-on test. Measure standby at the assembled device, including the charger and touch controller. Preserve safe low-battery shutdown; deep sleep is not a mode for continuous playback.

## Build sequence and acceptance

1. Print the small seam-fit pair and touch cover on the A1. Confirm mating clearance, screw access, and feel. Then print both complete shells and fittings.
2. Get a current quote for Tangara mainboard and faceplate assembly. Reconcile BOM substitutions with the schematic and case, including connector footprints. Have the factory mount the display and haptic motor or explicitly quote their final assembly. The source snapshot is a reference, not a submitted order.
3. Bring up the assembled boards in the original electrical configuration. Flash the SAMD bootloader through SWD, load its application, and then flash the ESP32 through the supported USB path. Follow upstream instructions and pin both firmware versions.
4. Play a full album over Bluetooth while browsing. Test pause, resume, skip, reconnect, volume, low battery, and missing SD. Test a 30-minute walk with the player in each pocket. Repeat against the car receiver if driving remains a use case.
5. Run the battery test and tune the wheel through the finished cover. Close the case only after checking the battery, ribbon cable, side buttons, USB-C access, and SD caddy without forcing any part.
6. Customize Harmony's theme and navigation after the hardware passes. Keep firmware changes separate from the reference baseline so playback regressions are attributable.

The delivered CAD is a complete enclosure fit prototype. Physical fit, print tolerances, touch sensitivity, battery runtime, and Bluetooth reliability remain unverified. It is not a validated device or a new production PCB design.

## Cross-references

- [Printable case, assembly notes, and attribution](../enclosure/harmony-r1/README.md)
- [Pinned electronics reference](../hardware/tangara-reference/README.md)
- Vault: `05-projects/mp3-player/JTBD-and-MVP.md` (historical June scope)
- WCP: HARMONY-8; prior MVP HARMONY-1
