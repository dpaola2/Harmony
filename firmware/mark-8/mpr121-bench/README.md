# MPR121 standalone bench

Target: spare Feather ESP32 V2, MAC `14:33:5c:99:1a:28`, formerly Mark-6. The application refuses peripheral initialization on other MAC addresses.

Connections: MPR121 to Feather through the recovered QT cable. No battery or electrode leads are required for the initial sensor check. QT power uses GPIO2 high, SDA GPIO22 and SCL GPIO20, matching the existing Feather board configuration.

Build: `bash build.sh`. The build helper does not flash. The hardware session uses esptool separately after identifying the board and saving the affected flash region.

Serial: 115200 baud. The application checks the reset register, verifies electrode-enable readback, and reports TOUCH/RELEASE transitions for twelve electrodes. A one-second SAMPLE line contains filtered, baseline and baseline-minus-filtered values for E0–E4. Initial thresholds are 12 touch and 6 release; they are bench defaults, not final coupon calibration.

The application enables no radio, filesystem or music playback. INT is unused. Reset with fingers clear of the electrodes to reinitialize the sensor.

Register defaults follow the Adafruit MPR121 driver. Attribution is retained in ADAFRUIT-NOTICE.txt. The test does not prove through-plastic sensitivity until actual pads and coupons are tested.

Hardware logs and the original flash-prefix backup are in `hardware/mark-8/mpr121-bench-20261107/`. The backup covers address 0 through 0x4FFFF, including every sector overwritten by this test. It is not a full-chip backup. Restore that prefix at address 0 while the rest of the chip remains unchanged. Do not erase the whole chip during restore.

## Filter candidate v2

The original 1.6 mm hold trial produced no touch events while the baseline followed the falling signal. A resting-sample retest produced four pairs during the requested five-tap test. Candidate v2 changes only the falling baseline coefficients: NHD_F 5 to 1, NCL_F 1 to 32, FDL_F 0 to 16. Thresholds remain 12/6, with the same acquisition and debounce settings. This implements the slower falling-filter approach described in [NXP AN3891, case 5](https://www.nxp.com/docs/en/application-note/AN3891.pdf). The numerical coefficients are experimental, not vendor-qualified values for this enclosure.

V2 adds device timestamps to events and samples every 100 ms for better hold-duration analysis. It reads back all three changed registers on startup. Physical taps and holds must still validate this candidate; a successful flash does not establish touch reliability.
