# Unsent vendor questions

These messages are drafts for review. They have not been sent and do not authorize a quote, purchase, fabrication, or customization order.

## EastRising / BuyDisplay: ER-TFT018-4 drawing request

Subject: ER-TFT018-4 controlled drawing and FPC dimensions for prototype fit review

We are evaluating the bare solder-tail ER-TFT018-4 for a small prototype using its 14-contact, 0.8 mm-pitch, 4-wire SPI interface. Before we release the faceplate or enclosure, please send the current controlled mechanical drawing and identify its revision and date.

Please include maximum overall width, height, and thickness; active-area location; glass and polarizer outline; FPC datum and centerline; FPC width, thickness, stiffener geometry and thickness; exposed-contact length; contact numbering viewed from the contact side; bend/keep-out limits; tail-to-glass transition geometry; component or adhesive protrusions; and dimensional tolerances. Please also confirm whether the published electrical drawing remains valid for the currently shipped ER-TFT018-4, with pins 1 and 14 no-connect, pins 10 and 11 logic supply, and ST7735S controller.

Please identify packaging and minimum order quantity for assembler procurement, and state whether production units have any mechanically distinct supplier or revision variants under the same order code. We will not approve a substitute or breakout-board module.

## LiPol Battery Co.: LP574459 finished-pack and harness request

Subject: LP574459 five-sample feasibility and three-wire harness specification

Please confirm whether five LP574459 samples can be supplied to Pennsylvania, USA as a finished protected single-cell pack with a cell-mounted 10 kΩ NTC and a JST-manufactured PHR-3 housing. We need a review drawing and electrical specification before ordering.

Please provide maximum finished thickness, width, and length including protection PCB, seams, tape, wire attachment, strain relief, and cable exit; cell and finished-pack tolerances; lead length and wire gauge; JST contact part number and crimp specification; protection thresholds and continuous/peak discharge limits; maximum continuous and recommended charge current; charge temperature range; NTC resistance at 25 °C, beta or full resistance/temperature table, tolerance, and physical attachment to the cell; UN38.3 report reference and shipping documentation for the exact finished pack; sample price, customization charge, lead time, and shipping method.

The mating board header is JST S3B-PH-K-S(LF)(SN). Please provide a mating-view harness drawing that explicitly assigns PHR-3 circuit 1 to NTC, circuit 2 to cell negative and thermistor return, and circuit 3 to protected cell positive. Wire colors are secondary to circuit numbering. The charger is a 4.2 V MCP73871 design with an approximately 1 A configured ceiling, so please state whether this exact finished pack permits 1 A continuous charging. If it does not, state the maximum permitted current. Do not build the harness until we approve the drawing.

## PCBA supplier: quote clarifications

Subject: Tangara mainboard and faceplate quote review questions

Please quote the attached package at one, two, and five complete electronics sets and answer the following before any order is released:

1. Can you procure every BOM line exactly as listed, and separately flag unavailable, end-of-life, long-lead, minimum-order, or customer-consigned lines?
2. Can you procure and hand-solder the bare ER-TFT018-4 FPC after its controlled drawing is approved, and attach one VC1034B018F motor to faceplate pads J1/J2?
3. Can you program and verify both processors using the draft instructions, including initial 3.3 V SWD programming and 8 KiB BOOTPROT verification for the blank ATSAMD21E18A-AF?
4. What layer stack-up and tolerances do you propose for the four-layer mainboard and two-layer faceplate at nominal 1.6 mm? The source file has no explicit copper-finish setting. Please price ENIG as the requested finish and identify the applicable finish specification and thickness.
5. Which Gerber/drill/placement files did you import, and what file-parser or rotation corrections did your preview apply? Please return annotated top and bottom placement previews before release.
6. Which DFM, AOI, electrical, programming, and functional tests can you perform? Please break out fixture, tooling, panelization, setup, unused-board, and non-recurring charges.
7. Please return your approved working BOM and final placement record, and do not make substitutions or footprint changes without written approval.

The source currently reports unresolved DRC/ERC findings. This request is suitable for pricing and DFM feedback only. Do not fabricate or procure material from it.
