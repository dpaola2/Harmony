# Draft supplier assembly and quote notes

Please quote one, two, and five complete Tangara electronics sets from the attached pinned-source derivatives. Each set contains one mainboard and one faceplate. Break out bare-board fabrication, assembly setup, component procurement, through-hole/manual work, display and haptic attachment, programming, inspection, unused boards, freight, and taxes. Return separate pricing for each board type and each complete-set quantity.

Use the per-board BOM quantities as the installed quantity authority. Keep all rows in the DNP and non-purchased structures file out of procurement and placement. Do not substitute any part without a part number, datasheet, availability, price, footprint comparison, and written approval. Keep the mainboard ESP32 antenna clearance free of copper and assembly material.

The faceplate display is ER-TFT018-4 for quote comparison only. Its electrical mapping is confirmed, but its mechanical release is on hold. Please state whether you can procure and solder the bare FPC panel after drawing approval. Do not quote an ST7735 breakout board. Attach one VC1034B018F motor to faceplate pads J1/J2; those pad references are not additional components.

Quote ENIG and nominal 1.6 mm finished thickness. Preserve the native four-layer mainboard and two-layer faceplate stack-ups. Report your proposed stack-up, controlled dimensions and tolerances, surface finish specification, solder-mask color, legend color, panelization, coupons/tooling rails, impedance assumptions, via treatment, and any departures from the source before release.

Programming is a separately priced operation pending final approval of `PROGRAMMING-NOTES-DRAFT.md`. A blank ATSAMD21E18A-AF requires the raw Tangara bootloader through 3.3 V SWD, BOOTPROT set for 8 KiB, application installation, and verification. ESP32 programming uses seven address-specific images. Do not program from filenames alone; verify every supplied hash and approved instruction revision.

Requested inspection and functional-test pricing: AOI/visual inspection, shorts and rails, USB enumeration in both Type-C orientations, display output, SD read/write, wheel and center-button input, side buttons, haptics, wired audio, Bluetooth pairing/playback/reconnect, SAMD firmware version, shutdown, and charge-state behavior. Battery/NTC and charge-current tests remain fixture-dependent until the pack is approved. List excluded tests and fixture costs explicitly.

This draft is for review and has not been sent.
