# Mark-6 lessons and the portable next step

September 27, 2026. Working recommendation following Dave's request to collect lessons, reconsider the Mark-6 carrier expense, and test battery operation before making Mark-7 compact. Hardware scope changes below are proposals; no battery wiring, charging test, carrier purchase or supplier cancellation occurred.

## September 28 adoption

Dave adopted [Mark-7 as the portable Bluetooth build](mark-7-portable-scope.md). Stop expanding Mark-6 hardware and preserve it as the working reference. Existing software acceptance carries forward. The ELEGOO perfboard, ample wire, soldering iron and multimeter are owned. SD access through a removable cover is sufficient. The speaker and DAC are excluded from the first portable build.

The battery and connector photos are retained in [inventory evidence](../hardware/mark-7/inventory-20260928/README.md). Dave reports the adapter cables and heat shrink purchased. Charging remains unqualified. The Feather charger has no battery-temperature input, and its voltage tolerance requires comparison against the pack maximum.

## Recommended sequence

Use Mark-6 to prove battery operation on the electronics that already play music. Use Mark-7 to package that working system into a smaller, secured enclosure for walking and car use. Preserve the current firmware, wiring records, enclosure work and approved web appearance. A new electronics architecture is not a prerequisite.

The Mark-6 carrier is optional for the demonstrated temporary-harness player. Keep its design available, but do not purchase it merely to tidy this bench. Revisit whether a small carrier is useful after the portable layout and power system are defined.

## What we learned

| Evidence | Lesson for the next build |
| --- | --- |
| Feather V2, LCD-slot SD and ANO controls work through a temporary harness | A manufactured carrier is not required to test the actual player behavior. Short secured wiring can remain a valid prototype assembly. |
| SD and LCD share SPI at 4 MHz; the integrated playback capture has no underrun/contention bytes | Separate buses are not required for this demonstrated workload. Keep bus access bounded and repeat load/endurance tests before making broader claims. |
| Original center input was missed during expensive drawing; priority/cache/partial redraw corrected it | Input scheduling and render work matter as much as the visual design. The final build also polls faster after observing short clicks miss the original cadence. |
| Existing RGB565 renderer reproduces the cream/green design with local fonts | Reuse the visual language and native renderer. Browser smoothness is not a hardware performance guarantee. Full-screen updates still take roughly 1.4 seconds on this bench. |
| Library, decoder, UI and Bluetooth are separate modules with host checks | Carry this software into the next case. Avoid rewriting proven playback to obtain a different exterior. |
| Loose fit checks established board/bezel/support alignment | Fit does not establish a carry-ready assembly. Retain boards, insulate exposed contacts, provide strain relief and preserve antenna clearance. |
| Purchased battery and earlier Tangara power work predate the Feather architecture | Recheck compatibility against the actual Feather and peripheral load. A purchased battery is useful inventory, not proof of a compatible charging system. |

## Why the designed carrier is more than cable cleanup

The existing carrier provides sockets and fixed interconnects, a separate SD socket/bus, a peripheral 3.3 V supply and power-good checks. It was designed for USB-only operation. It would require its own powered bring-up and firmware/pin-map qualification; a tidy board does not automatically improve an already working audio path or solve battery integration.

A wired Mark-6 could be enclosed if modules and connectors are mechanically retained, conductors are insulated, cables cannot pull on contacts, and the assembly closes without pressure on components or battery. That is an assembly task, not permission to pack loose jumper wiring under the lid. A fixture or simple printed bracket can be useful before buying a full PCB.

Source: [carrier design](../hardware/mark-6/carrier-rev-a/README.md), [power review](../hardware/mark-6/carrier-rev-a/power-review.md), [current bench](../firmware/mark-6/feather-player-bench/README.md).

## Battery proof on Mark-6

The Feather supports a single-cell Li-ion/LiPo input, onboard charging and USB/battery switchover. Its enable input controls the main 3.3 V regulator, while STEMMA QT uses a separately controlled supply. These board functions are a starting point, not a measurement of the complete player's power behavior. [Adafruit power guide](https://learn.adafruit.com/adafruit-esp32-feather-v2/power-management-2).

The retained GlobTek BL2200F9031781S1PCKT record specifies 3.7 V nominal, 2200 mAh, a three-wire connector and a temperature sensor. Its stated maximum charge voltage is 4.2 V, with 4.1 V recommended. Earlier Tangara charger/harness proposals must not be transferred unchanged to the Feather. Check the received pack, polarity, harness, charger current/termination and temperature arrangement before connection. [Manufacturer specification](https://spec.globtek.info/spec/?id=01t3a000005RUyzAAG&rohs_cert=1); retained exact drawing and selection record are in the vault's September 15 component-verification directory.

Proposed sequence:

1. Review the exact pack and Feather charging circuit; define a compatible harness or a simpler compatible pack choice. Do not purchase duplicate electronics by default.
2. Measure the whole player's current with display on, display off, paused and playing over Bluetooth. Check startup and peripheral rail behavior on battery.
3. Verify charging, battery temperature, charge termination and USB insertion/removal during playback under a supervised bench test.
4. Add battery indication, low-battery behavior and a practical power/wake control. Measure actual standby/off drain; do not infer it from the ESP32 chip specification.
5. Run a full album and measured runtime trial before setting the final battery space. Use the intended headphones and car receiver separately; the SoundCore result does not qualify every receiver.

An external USB power bank could supply an early mobile experiment, but it would not qualify an internal pack, charging or standby design.

## Sleep and wake are separate behaviors

| State | Intended behavior | Current implementation |
| --- | --- | --- |
| Screen off while playing | Backlight off; audio continues; first control input wakes the screen | Implemented display timeout, awaiting complete physical acceptance |
| Paused standby | Reduce system/peripheral draw; wake through a defined control | Not implemented or measured |
| Off | Low drain, deliberate power-on, retained preferences | Power-control design and measurement still needed |

ESP32 deep sleep drops the Bluetooth link, so wake needs boot/reconnect and paused restoration. A control read only through a polled I2C device does not by itself provide a wake source while the CPU is asleep. Select a wake-capable connection and verify the full board/peripheral behavior. [Espressif sleep documentation](https://docs.espressif.com/projects/esp-idf/en/v5.3/esp32/api-reference/system/sleep_modes.html).

## Mark-7 purpose

Build a secured, battery-powered player that Dave can take around the block and use with an intended car receiver. Reuse the Feather, display, SD, working software and whichever controls have passed qualification. The [approved visual reference](mark-7-design-reference.md) supplies the appearance and capacitive-wheel direction. The existing mechanical wheel can serve the first portable trial if capacitive sensing is still under development.

The display/module dimensions set a lower bound on case size; no smaller dimensions are promised before layout. Place the actual battery and connectors, retain service access and antenna clearance, then decide whether wiring, a small interconnect board or a revised carrier best serves that layout.

## Evidence and unfinished acceptance

The complete UI implementation, source hashes and short hardware captures are in [the bench record](../hardware/mark-6/feather-complete-ui-bench-20260927/). [Requirements](Harmony-player-ui-requirements.md) retain the distinction between implemented software and physical acceptance. Full-album endurance, second-receiver pairing, power-loss/reconnect coverage, battery and carry tests remain open.

Tracking: Complete Mark-6 player UI (HARMONY-18), under Harmony Mark-6: Bluetooth bench player (HARMONY-17). Do not mark these acceptance items passed solely because the next hardware direction is attractive.
