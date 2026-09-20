# Release holds

These outputs can support supplier pricing. They cannot authorize fabrication, purchasing, assembly, substitution, or production programming.

## Blocking holds

- **LCD1 mechanical identity:** the routed faceplate footprint and electrical 14-pin, 0.8 mm-pitch mapping match the ER-TFT018-4 candidate, so the BOM uses that candidate for pricing. Obtain the archived manufacturer drawing and pass a full-scale mechanical overlay against the faceplate and enclosure before release. The candidate status is preserved in the BOM.
- **Battery LP574459:** obtain maximum finished-pack dimensions including protection PCB, seams and cable exit; protection limits; maximum charge current; 10 kΩ NTC curve; lead construction; PHR-3 contact identity; and a mating-view pin drawing proving J7 order 1 NTC, 2 negative, 3 protected positive. The fitted R39 gives an approximately 1 A charge ceiling. Do not release a pack on nominal cell dimensions alone.
- **DRC and fabrication review:** native exports are quote attachments, not proof that the source is design-rule clean. Resolve or formally disposition every KiCad DRC item and review layer set, outline, holes, slots, stack-up, solder mask, paste, and RF antenna clearance before fabrication approval.
- **Mainboard schematic/PCB parity:** native comparison reports C23 pin 2 on schematic net `-5VA` while the routed PCB assigns it to `GND`. The `-5VA` schematic net also reaches other ground-like pins, but this has not been proven to be a harmless naming difference. Perform a source-circuit review before any net update or fabrication release; do not waive or automatically synchronize it.
- **Rotation and polarity:** validate every supplier placement preview against assembly drawings. No library rotation correction has been guessed or labeled manufacturing-ready.
- **Firmware qualification:** the preserved ESP32, SAMD application, and SAMD bootloader artifacts build and have hashes, but have not run on this assembly. HARMONY-12's ALAC metadata-bounds finding also remains open before qualification.

## Controlled exceptions and clarifications

- Mainboard R1, C17, and C19 remain DNP. R1 must remain open when the battery supplies a real NTC.
- Mainboard J3 and J5 are unpopulated programming interfaces. J5 is a pad footprint needed for initial SAMD SWD programming; it is not a purchasable connector.
- Faceplate SW1, SW2, and SW3 are capacitive copper electrodes, not tactile switches and not purchased components.
- Faceplate J1 and J2 are haptic motor solder pads, not components. Quote one VC1034B018F motor per complete set in the external addendum.
- Faceplate H1-H4, TP1-TP9, logos, and text structures are fabricated PCB features, not assembly line items.
- The touch-wheel cover is an unpopulated insulating mechanical part and is outside both PCBA BOMs. The Harmony enclosure currently uses the printable cover; any 0.6 mm FR4 alternative needs a separate mechanical fabrication review.
