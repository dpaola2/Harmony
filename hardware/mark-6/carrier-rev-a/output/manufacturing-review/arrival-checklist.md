# Mark 6 arrival and release checklist

Dave has received the printed shells, carrier gauge and spacers. The PiShop Waveshare display has shipped. Physical fit remains unconfirmed.

The next useful hardware step is an unpowered dry fit. The carrier still needs supplier DFM review and an assembled-board order.

## Parts status

| Part | Recorded status | Remaining check |
| --- | --- | --- |
| Tray, front, gauge, four spacers | Received, reported by Dave | Inspect and dry fit |
| Waveshare 29318 display | Shipped, reported by Dave | Delivery and dimensions |
| Factory-headered Feather #5900 | Four remain in the live DigiKey cart; no order confirmation found | Checkout; one board is needed per player |
| Assembled ANO #6310 | DigiKey order 101731437 shipped September 21 | Physical receipt |
| Display FPC ribbon | PiShop lists one FPC cable in the display package | Check length, contacts, thickness and pin mapping before use |
| EYESPI #5239, 100 mm | No order found; optional replacement for the included ribbon | Buy only if the supplied cable fails the fit or mapping check |
| QT-to-QT #4210, 100 mm | Adafruit order 3747879 shipped September 21 | UPS email estimates September 24; check slack in the case |
| QT-to-QT #4399, 50 mm | Original preferred length; no order found | Optional if the shipped 100 mm cable cannot fit cleanly |
| M2.5 mounting screws | No purchase confirmed | Select lengths after measuring the actual stack |
| USB-C data cable and 5 V supply with at least 1 A available | On-hand status unconfirmed | Verify before programming and power qualification |
| SD card and SoundCore 2 | Previously used for the successful WROVER audio test | Reuse; qualify with the new carrier |
| Assembled Rev A carrier | Review package prepared; no new order | Supplier DFM, quantity decision and order |

September 22 audit: checked personal Gmail and the live Chrome carts. DigiKey holds four #5900 boards at $20.95 each. The displayed cart total is $97.83 with the selected shipping and tax. Adafruit's cart is empty. The checked orders contain no Feather #5900, EYESPI #5239 or 50 mm QT #4399.

The ANO purchase also contains shielding tape. The Adafruit shipment contains the 100 mm QT-to-QT cable and a separate 150 mm cable with loose female sockets. Use the QT-to-QT cable for the carrier. The loose-socket cable does not replace it. The shipped DAC, touch sensor, speaker and tactile buttons are not required for this Bluetooth carrier build.

Sources: [DigiKey ANO order](https://mail.google.com/mail/u/?authuser=dpaola2%40gmail.com#all/1a0bf05c8bc45b8b), [DigiKey shipment](https://mail.google.com/mail/u/?authuser=dpaola2%40gmail.com#all/1a0c3ca4353e7999), [Adafruit order](https://mail.google.com/mail/u/?authuser=dpaola2%40gmail.com#all/1a0bf0708ab6afb2), [UPS estimate](https://mail.google.com/mail/u/?authuser=dpaola2%40gmail.com#all/1a0c6a3fab32fd09), [PiShop package contents](https://www.pishop.us/product/3-5inch-capacitive-touch-display-320-480-ips-2tpd/), [QT cable specification](https://www.adafruit.com/product/4210).

## Dry fit before power

1. Remove loose print strands. Check the thin display bezel and the bridged SD opening.
2. Seat the carrier gauge on the tray posts. Check every hole and the antenna cutout without forcing the parts.
3. Fit the front to the tray. Check the lip and seam; use temporary tape for this prototype.
4. Place the delivered display in its recess. Check the visible area, thickness and cable-latch access.
5. Position the ANO with the four 12 mm spacers. Check center, ring movement and the upper cable connector.
6. Compare the actual Feather header height with the mechanical stack. Verify socket mating when the specified sockets are available.
7. Check USB plug clearance, SD removal and both cable routes. Keep cables clear of the antenna and mounting posts.
8. Record interference, loose fits and measured gaps before revising the case.

The front has no permanent display retainer. Keep the display supported during the dry fit. Final retention and screw lengths follow these measurements.

Before first power, verify ribbon pin 1 continuity with both ends disconnected from powered hardware. Then use [power-review.md](power-review.md) for staged carrier testing. The printed gauge cannot verify electrical connections.

## Firmware qualification after assembly

The updated [firmware](../../../firmware/mark-6/feather-carrier/README.md) builds and has host tests. Its empty MAC setting blocks application peripheral startup. Hardware qualification remains open.

1. Identify the replacement Feather and record its station MAC, flash size and PSRAM.
2. Complete carrier power checks, then commission that specific Feather.
3. Run the display-only pattern. Confirm colors, text, edges and orientation visually.
4. Check raw ANO inputs. Confirm the configured rotation and wheel direction before testing actions.
5. Play the known Higher fixture to SoundCore 2. Record current, temperature, underruns and mutex-contention silence.
6. Test browse, select, pause, previous and next during display updates.
7. Turn the speaker off and on. Confirm reconnection retains the track and the user's pause state.
8. Run the full prepared album. Compare decoded frame counts, ordering and final stop behavior with the expected files.

Also test an absent file, unsupported format and speaker absence. Save firmware hashes, serial logs and listening observations with HARMONY-17. A build or host test does not establish a physical pass.
