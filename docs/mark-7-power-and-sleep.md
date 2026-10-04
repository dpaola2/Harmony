# Mark-7 power and sleep

Design basis: October 3, 2026. Build Mark-7 portable Bluetooth player (HARMONY-19).

Use Adafruit #328 (2500 mAh) directly with the second Feather ESP32 V2's USB-C charger. Dave wants no separate battery switch. Use the Photo A1099 wheel for controls and eventual sleep/wake. All selected parts are ordered; delivery is pending. Mark-6 stays assembled for demos.

The [Mark-7 firmware](../firmware/mark-7/pocket-player/README.md) now builds with the smaller display and compact UI. It includes an experimental wheel receiver, disabled by default. **Full sleep, button wake, battery indication and low-battery handling are not implemented.** Backlight timeout alone is not full sleep. No runtime or standby duration is claimed.

## Battery and charging

Connect the #328 battery's two-pin JST-PH plug directly to the Feather battery socket. USB-C remains the charging/programming connection. The [Feather power guide](https://learn.adafruit.com/adafruit-esp32-feather-v2/power-management-2) supports Adafruit LiPo batteries and automatic USB/battery changeover. The retained schematic specifies MCP73831T-2ACI/OT and a 5.1 kOhm charge resistor, about 196 mA nominal. A complete charge takes longer than the ideal 12.8-hour capacity/current calculation; actual time remains unmeasured.

The battery drawing specifies a maximum 50.5 × 62.5 × 8.1 mm envelope. Provide wire clearance, insulation, restraint without pouch compression and service access. The charger has no pack-temperature input. Follow the battery vendor's charging conditions. The earlier GlobTek packs and adapter cables remain available for other designs and are not used in this build.

## Photo-wheel wake design

[Gigahawk's reverse-engineering record](https://github.com/Gigahawk/clickwheel_reverse_eng) reports Photo-wheel operation at 3.3 V and a high BTN1 pulse on center or Menu press. Plan BTN1 to A2/GPIO34 with an external 10 kOhm pull-down; GPIO34 has no internal pull resistor. Use active-high RTC wake. Do not use the earlier ANO active-low/pull-up wiring for this wheel.

The reference sleep command stops touch reports while retaining button reports, and a press resumes wheel activity. Sending it needs wheel-clocked host transmission and the documented CFG mode change; the current receiver does neither. Verify command behavior, BTN1 timing and wake-source persistence with our assembly. Keep the wheel powered during sleep. The complete proposed [pin map](../firmware/mark-7/pocket-player/README.md) still needs physical ribbon-to-adapter mapping before power is connected.

## Proposed behavior

A two-second center hold enters sleep; a menu Sleep command offers another entry. Center or Menu can wake through the documented BTN1 signal. These gestures are proposed and not yet validated. Screen timeout remains separate and leaves music playing.

Full sleep should pause playback, stop Bluetooth, save settings and track selection, close SD files and stop peripheral access. Put the display into controller sleep and hold the backlight off. Send the wheel sleep command, release the initiating button, clear stale input and arm wake without creating an immediate wake loop. Consult the installed ESP-IDF sleep API during implementation.

Deep sleep restarts the application. On wake, restore selection and reconnect paused, consuming the opening key. The current player does not restore elapsed position or the full prior queue. Preserve its quiet startup-volume ceiling.

## Measurement and acceptance

The wheel and LCD/SD module stay connected to 3.3 V. Their current must be included in whole-player standby measurements; bare-board figures are insufficient. If peripheral current dominates, evaluate a firmware-controlled supply switch and SPI back-powering. No manual battery switch is planned. Keep the battery plug accessible under the service cover for long storage.

Add voltage monitoring and low-battery sleep after loaded-voltage measurements establish thresholds. Avoid repeated wake attempts near cutoff. Verify battery-only playback, USB insertion/removal, charging during sleep, wake after long idle, no wake loops, paused recovery, charging temperature and total standby current. These operating tests do not repeat the receipt inspections Dave declined.

The [105 × 64 × 26 mm fit shell](../enclosure/mark-7/pocket-rev-b/README.md) is an unpowered geometry prototype. It does not yet provide final battery protection, module retention or USB access. Finish those before powered enclosure tests.

## References

- [Portable scope](mark-7-portable-scope.md)
- [Adafruit #328](https://www.adafruit.com/product/328)
- [Feather schematic](../hardware/mark-6/carrier-rev-a/reference/Adafruit%20ESP32%20Feather%20V2.sch)
- [ESP32 sleep API](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/sleep_modes.html)
- [Mark-6 bench evidence](../hardware/mark-6/feather-complete-ui-bench-20260927/README.md)
