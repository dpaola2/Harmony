# Harmony Mark-7: portable Bluetooth player

Adopted September 28, 2026. Tracking: Build Mark-7 portable Bluetooth player (HARMONY-19). This scope supersedes the earlier proposal to defer battery power until Mark-8.

Build a carryable player from the electronics that already work. Use a smaller printed enclosure, one rechargeable battery, Bluetooth audio and a secured soldered harness. Preserve Mark-6 as the working reference while preparing the new layout. A custom manufactured carrier is not a prerequisite.

## Scope decisions

| Area | Mark-7 decision |
| --- | --- |
| Processor | Reuse the original ESP32 Feather V2, with Classic Bluetooth A2DP source support. |
| Display and storage | Reuse Waveshare 29318 ST7796S LCD and its onboard microSD slot. |
| SD access | Internal access is sufficient. The case must open and reassemble without damage or desoldering. No external SD opening is required. |
| Controls | Use the proven ANO wheel and buttons for the first portable build. Preserve the capacitive-wheel concept for later exploration. |
| Audio | Bluetooth headphones and the intended car receiver. Omit the TLV320DAC3100 DAC and oval speaker. |
| Interconnect | Short soldered wires and existing perfboard, with retained removable connectors where service requires them. |
| Power | One GlobTek BL2200F9031781S1PCKT pack, subject to charging and whole-system qualification. Do not parallel the two packs. |
| Enclosure | Smaller than the Mark-6 reference if the measured layout permits. Removable screwed cover, component mounts, battery restraint and wire strain relief. |
| USB | Accessible USB-C for firmware and eventual qualified charging. No external SD slot or USB file-transfer feature is required. |
| Appearance | Preserve the cream body, green interface, rounded profile and circular control from the approved web reference. |

The ELEGOO box in IMG_7730 shows double-sided solderable FR4 boards, advertised as 1.6 mm thick with plated holes. Dave owns ample wire, a soldering iron and a multimeter. Exact board dimensions, pitch, pad connectivity and wire gauges still require inspection. The box photograph does not establish those measurements.

## Reuse inventory and purchases

| Item | Evidence and action |
| --- | --- |
| Feather, LCD, ANO wheel and SD | Working USB bench. Keep the current assembly intact until the new layout and wiring schedule are ready. |
| Two GlobTek 2200 mAh packs | DigiKey shipped September 16; FedEx reports delivery September 21 at 14:20. Dave found them. IMG_7727 shows the expected pack and pin label. Use one pack per player. |
| Adafruit #4046 | Three-pin JST-PH mating cable. Dave reports purchase September 28; delivery pending. |
| Adafruit #261 | Two-pin JST-PH Feather cable. Purchased with #4046; delivery pending. |
| Adafruit #4559 | 280-piece heat-shrink assortment. Purchased with the cables; delivery pending. |
| ELEGOO perfboard and wire | Owned. No additional board or general wire order is justified by current evidence. |
| Screws, nuts and 0.5 mm foam | Earlier Amazon order. Check remaining quantities and actual material before buying duplicates. |
| Solder and suitable heating tool | Soldering iron confirmed. Confirm electronics solder, flux and a suitable way to shrink tubing away from the battery. |

The adapter order subtotal was $11.65 before tax and shipping. It is not a complete portable-power solution.

## Power design remains open

The Feather reference schematic specifies MCP73831T-2ACI/OT and a 5.1 kOhm programming resistor. The nominal charge current is about 196 mA. This is a schematic calculation, not a measured result.

The pack specifies 3.7 V nominal, 2200 mAh and 8.14 Wh. Its maximum charge voltage is 4.2 V; 4.1 V is recommended. Its leads are red positive, white temperature sensor and black negative. The retained pack specification gives a 10 kOhm NTC, a 0–45 C charging range and a 22 mA recommended termination current.

The Feather charger regulates nominally to 4.2 V with a stated ±0.75% accuracy and has no battery-temperature input. Its upper regulation bound is therefore about 4.232 V. This does not establish compliance with the pack's stated 4.2 V maximum. The two-wire adapter also does not provide temperature monitoring. Resolve the exact charging arrangement before connecting USB and this battery together.

Evaluate a compatible external charger and a circuit that prevents the Feather charger from charging the pack through another path. Alternatively, assess a vendor-approved battery pairing if this avoids unnecessary power circuitry. Select one complete design before ordering power parts. Do not select a generic charger by connector fit alone.

The power design must cover:

- Full-player current, startup peaks and peripheral voltage across the useful battery range.
- Charge voltage, current, termination, temperature response and USB insertion/removal.
- A real power-off control with measured residual drain. Backlight timeout is not sleep or off.
- A deliberate wake/restart action and paused Bluetooth recovery.
- Battery indication and low-battery shutdown before pack protection trips.
- Safe current measurement. Never place a meter in current mode directly across the pack.

The Feather EN pin disables its main regulator. It does not by itself prove that the separate STEMMA supply and every peripheral are off. A switch in the battery lead also changes charging behavior. Select the switch with the power circuit, not independently.

## Remaining parts, before one consolidated order

1. Select the charger and power-switch arrangement. This determines any additional power module, switch and connectors.
2. Measure the selected perfboard and inventory matching sockets, headers and retained cable connectors.
3. Confirm insulating tape and foam. Copper shielding tape is conductive and cannot replace insulation.
4. Inventory the existing screws and nuts against the new mounting design.
5. Publish exact quantities, part numbers, prices and compatibility notes in one order list.

Flexible wire and polyimide tape were suggested during discussion. Dave then confirmed ample wire. Neither suggestion is an additional confirmed purchase. No power switch, charger, new display, new processor or custom PCB was ordered in this scope discussion.

## Mechanical requirements

Use the actual LCD, wheel, Feather, selected perfboard and battery envelopes. The earlier 74 × 178 × 28 mm case is a reference, not a target. Do not promise a smaller thickness before accounting for existing headers, sockets and cable bends.

Provide a battery pocket separated from solder joints and screw tips. Restrain the pack without compressing its pouch. Provide clearance for the pack, its wires and service removal. Do not place perfboard copper or battery foil against the antenna region.

Mount the LCD through proven supports without stressing the glass. Retain the wheel at the accepted face height and clearance. Preserve those successful fit measurements in the new CAD. Keep short SPI wires and a clear antenna region. Test reception in the closed case while held and carried.

Opening the rear cover must expose the SD slot and battery disconnect. Retain fasteners through repeated service. Existing screws and nuts may suffice; heat-set inserts are not required unless the mounting design benefits from them.

## Software carried forward

Reuse the native ESP-IDF implementation and cream/green renderer. Music browsing, Now Playing, volume, Bluetooth management, playlists, shuffle/repeat and saved preferences remain required. Their implementation and physical acceptance are tracked separately in Complete Mark-6 player UI (HARMONY-18).

Add battery indication, low-battery behavior and accidental-input protection. Define sleep/wake separately from display timeout. Keep restart and reconnection paused. Retain a quiet startup-volume ceiling.

The existing limits remain explicit: 512 tracks, 16 playlists, 512 entries per playlist, MP3 format constraints and bounded name lengths. Current restart restores a track selection, not its elapsed position or an entire prior playlist queue. Custom Bluetooth PIN/passkey entry remains unsupported. Do not promise complete phone-like Bluetooth compatibility.

LCD touch, capacitive wheel integration, integrated speaker, DAC output, new codecs, album artwork and USB mass storage are outside the first portable build. Dave asked for an explanation of LCD touch and explicitly deferred implementation.

## Acceptance sequence

1. Preserve the exact working wiring, firmware sources, flashed-image hashes and rollback instructions.
2. Validate the adapter without the battery attached. Then verify the pack voltage and polarity.
3. Prove battery-only playback on the existing bench before moving the electronics.
4. Qualify the selected charging and power-off circuit, including temperature and USB transitions.
5. Assemble the secured interconnect and repeat display, controls, SD and Bluetooth tests.
6. Print a layout/fit trial, then the serviceable enclosure after the actual parts fit.
7. Run one uninterrupted album while exercising the menus. Record receiver, firmware, resets and underrun counters.
8. Verify pairing, switching, Forget, reconnect and pause behavior with headphones and the intended car receiver while parked.
9. Walk around the block with the assembled player. Check accidental input, audio, antenna performance and mechanical retention.
10. Measure runtime, charging behavior and off drain. Open the case, access the SD, reassemble and repeat a functional check.

No runtime, charging, completed Mark-7 case or portable acceptance result is claimed at scope adoption. Mark-6 hardware expansion stops; its successful evidence and uncompleted acceptance work remain available.

## Sources and cross-references

- [Mark-6 lessons](mark-6-lessons-and-portable-next-step.md) and [bench evidence](../hardware/mark-6/feather-complete-ui-bench-20260927/README.md).
- [UI requirements](Harmony-player-ui-requirements.md) and [approved visual reference](mark-7-design-reference.md).
- [Feather power guide](https://learn.adafruit.com/adafruit-esp32-feather-v2/power-management-2) and [vendor schematic repository](https://github.com/adafruit/Adafruit-ESP32-Feather-V2-PCB).
- [MCP73831 specification](https://www.microchip.com/en-us/product/mcp73831).
- [GlobTek specification](https://spec.globtek.info/spec/pdf/BL2200F9031781S1PCKT); exact Rev A3 retained in the vault's September 15 component-verification directory.
- [September 28 photo evidence](../hardware/mark-7/inventory-20260928/README.md).
