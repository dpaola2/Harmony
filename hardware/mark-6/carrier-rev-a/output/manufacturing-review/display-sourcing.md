# Mark 6 display selection: Waveshare 29318

Selected September 22, 2026 after Dave authorized replacing the unavailable Adafruit #5846. Use **Waveshare 29318, 3.5inch Capacitive Touch LCD**, with ST7796S display controller. The Feather #5900, physical controls, USB-first power and separate carrier SD bus stay adopted.

[PiShop.us lists the exact Waveshare 29318 in stock for $24.95](https://www.pishop.us/product/3-5inch-capacitive-touch-display-320-480-ips-2tpd/), checked on the product page September 22. Its shop SKU is 1850-1. [Waveshare lists it for $18.99](https://www.waveshare.com/3.5inch-capacitive-touch-lcd.htm), with an enabled Add to Cart button verified in Chrome. Prefer the US source for this build. Stock is a current listing, not a reservation or a delivery guarantee. No purchase was made.

## Compatibility checked

The [vendor specification and wiki](https://www.waveshare.com/wiki/3.5inch_Capacitive_Touch_LCD) specify 320 × 480 pixels, IPS, 3.3 V/5 V supply and logic, and an 18-contact 0.5 mm FFC connector. Factory-fitted connectors preserve Dave's no-soldering assembly. Use the 18-pin connector; leave the 15-pin cable, touch interface and display-side SD socket unused. The carrier's dedicated SD socket still uses SPI3; the display uses SPI2.

The vendor schematic agrees with the existing J3 assignments: pin 1 VCC, 2 backlight, 3 GND, 4 SCLK, 5 MOSI, 7 DC, 8 reset, 9 display select, 10 unused SD select. Pin 6 MISO and pins 11–18 are unused by the carrier. Internal touch-reset connections do not change any used J3 signal. There is no carrier electrical-net change. Continue using the planned 100 mm 18-contact cable with pin 1 mapped to pin 1; verify contact engagement and end-to-end continuity on the physical cable before power. Connector pitch alone does not establish correct insertion.

The vendor reports about 63 mA at 3.3 V, which fits within the retained 450 mA total peripheral allowance. This is a vendor typical figure, not a measured peak or a reason to reduce the supply budget. Its onboard ME6217 regulator and TXS0108E level translator require the same 3.3 V logic/supply pairing used here. Backlight is active-high through a transistor. Signal timing, rail behavior and Bluetooth playback under refresh load still need physical qualification.

## Mechanical and firmware changes

The glass envelope is 61.00 × 92.44 mm; the PCB is 55.16 × 83.44 mm. The vendor STEP spans 61.011 × 92.447 × 10.550 mm including rear connectors. The published side drawing says 10.31 mm, so CAD uses the larger STEP geometry. The module sits with its glass at Z27.3 and deepest rear feature at Z16.750, leaving 4.650 mm above the reserved battery volume. The FFC connector center is approximately X37.01/Y20.32 in the case frame. Actual fit, cable bends and final retention remain unverified.

The prototype front uses the new glass envelope and 48.96 × 73.44 mm active area. The 74 × 178 × 28 mm outside dimensions remain. Its thin bezel is still a sacrificial fit part; the print does not permanently retain the display.

The native firmware now uses the vendor's ST7796S initialization sequence, RGB565 format and portrait BGR orientation. The old HX8357 driver is retained as a reference. Neither driver selection nor a successful SPI write proves that the physical display works. Supplier files and hashes are under `reference/waveshare-29318/`; the source demo was inspected, not run or flashed.

The current [carrier review](README.md), [hollow fit files](../../../enclosure/mark-6/fit-prototype/README.md) and [firmware](../../../firmware/mark-6/feather-carrier/README.md) use Waveshare 29318. HARMONY-17 owns the remaining hardware qualification.

---

## Historical #5846 search, superseded by the selection above


Checked September 22, 2026 for HARMONY-17. That search found no verified ready-to-ship source for the former Adafruit #5846 selection. The earlier description, “out of stock,” understated the supply problem. Do not release the carrier or permanent display mount on the assumption this module can be replenished.

| Source | Observed status | Interpretation |
|---|---|---|
| [Adafruit #5846](https://www.adafruit.com/product/5846) | $39.95, out of stock | No stock or delivery commitment |
| [DigiKey](https://www.digikey.com/en/products/detail/adafruit-industries-llc/5846/22162364) | Discontinued at DigiKey; zero stock | Not a purchasable replenishment source |
| [Mouser](https://www.mouser.com/en/ProductDetail/Adafruit/5846?qs=mELouGlnn3cZvPZIWGzzIQ%3D%3D) | End of life; unavailable in the displayed region | Reinforces the lifecycle problem |
| [Opencircuit](https://opencircuit.shop/product/adafruit-3.5-inch-tft-320x480-capacitive-touch) | Exact #5846; €55.25 including displayed Dutch VAT; external warehouse, 10–12 days | A lead only. Warehouse quantity and US delivery were not confirmed |
| [Little Bird](https://littlebirdelectronics.com.au/products/adafruit-3-5-tft-320x480-with-capacitive-touch-breakout-board?collection=displays-user-interface) | Indexed availability/lead-time text conflicts with out-of-stock text | No verified stock |

In a [manufacturer forum discussion](https://forums.adafruit.com/viewtopic.php?t=216085), Adafruit staff said in January 2025 that the original display manufacturer had gone out of business. A March reply described a replacement using a different ST controller because the HX chip was unavailable, requiring firmware changes. These statements were available in indexed forum results; direct forum access returned HTTP 403. No orderable replacement SKU was established in this search.

Opencircuit's [shipping information](https://opencircuit.shop/orderinginformation) describes international service but did not establish a United States delivery option for this item. No cart checkout, payment or supplier message was made.

At the time of that search, CAD and firmware were tied to the original #5846 HX8357D module. The removable prototype front can be revised after choosing a stocked display. A replacement needs its own controller, power, connector pinout, envelope and mounting checks; a 3.5-inch diagonal alone does not make it compatible. The no-hand-soldering requirement remains in force.

Related: [carrier review](README.md), [hollow prototype](../../../enclosure/mark-6/fit-prototype/README.md), and [Feather firmware](../../../firmware/mark-6/feather-carrier/README.md).
