# Mark-6 mechanical review

Dave printed and accepted the 74 x 178 x 28 mm solid size dummy on September 21, 2026. This fixes the outside size for the present design. The dummy establishes pocket fit and thumb reach; it contains no electronics cavity.

`output/mechanical/harmony-mark6-assembly-review.step` places the vendor Feather and ANO solids against the routed carrier. The display is an explicitly assumed 8 mm envelope. Coordinates in the tables are millimeters from the case's upper-left rear corner; Z increases toward the front. The STEP uses Y negative toward the case bottom.

| Item | Z range | Basis |
| --- | --- | --- |
| Rear shell allowance | 0-1.6 | Design assumption |
| Future battery reserve | 1.6-12.1 | 32 x 79 x 10.5 mm reserved, unconnected |
| Carrier | 6.5-8.1 | 1.6 mm PCB |
| Samtec sockets | 8.1-16.61 | 8.51 mm catalog body height |
| Feather PCB bottom | 19.15 | Socket plus assumed 2.54 mm male-header body |
| Feather component maximum | 25.52 | Actual vendor STEP, nominal placement |
| ANO rear PCB surface | 20.1 | 12 mm spacers above carrier |
| ANO control front | 27.47 | Actual vendor STEP |
| Display reserved envelope | 19.3-27.3 | Assumed 8 mm thickness; measure exact display |

At these nominal dimensions the Feather clears a 1.6 mm front wall by 0.88 mm. The battery reservation clears the assumed display envelope by 7.2 mm. The four checked pairs of independent solids have zero intersection volume. These checks omit header insertion tolerances, screws, cable bending and the final shell; they do not establish a finished enclosure fit. Source socket dimensions: [Samtec SSW drawing](https://suddendocs.samtec.com/catalog_english/ssw_th.pdf).

## Cables and access

The display's Eagle file shows its panel on the opposite board side from its electronics. In the viewing orientation, the EYESPI connector is on the left, centered near X12.87/Y41.465. Carrier J3 is at X54/Y52. Use [Adafruit #5239](https://www.adafruit.com/product/5239), the 100 mm, 18-contact EYESPI cable. Reserve the gap behind the display and above the future battery for a loose loop. Keep a provisional bend radius of at least 3 mm; that is a design allowance, not a cable manufacturer's certified minimum. Check physical mating, reach and latch access before making the final housing. Copper faces the connector contacts; the blue stiffener faces outward. Confirm pin 1 to pin 1 with continuity before first power.

Use [Adafruit #4399](https://www.adafruit.com/product/4399), a 50 mm QT-to-QT cable, from J5 to the upper connector of the rotated ANO. Reserve its slack above the controls, away from the antenna. Do not use the loose-wire QT cable. Firmware must rotate directional-button mapping with the board.

The Feather USB-C connector reaches approximately X4.41 from the left case wall. The final shell needs a plug-access recess around Y162; allow the plug's plastic housing as well as the metal connector. The carrier microSD slot faces the right wall near Y24. Its opening is recessed several millimeters from the 74 mm outside width: provide a finger-access pocket reaching the slot so a card can be pressed and ejected. A narrow cosmetic slit would not suffice. These openings are requirements for the functional shell, not features of the accepted solid dummy.

The carrier has a cutout below the radio antenna. Ground pours stop outside the transformed 15 mm antenna halo. The Feather's required header pads and traces remain inside part of that halo, so this is not an all-direction 15 mm clearance claim. Keep screws, cables, battery and other metal away from the antenna end. Test Bluetooth range in the finished plastic case and in the hand. [Espressif layout guidance](https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32/pcb-layout-design.html).

## Remaining physical checks

Measure the exact #5846 display thickness and mounting details, confirm factory header insertion in the SSW sockets, and test cable/USB/SD access in a hollow fit prototype. #5846 was listed out of stock during this review. No alternate display has been substituted. The battery space is reserved for a future redesign; it is not a certified swelling or charging provision.
