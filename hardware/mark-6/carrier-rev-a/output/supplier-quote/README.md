# Harmony Mark 6 carrier, Rev A: DFM and quote package

September 26, 2026. Review and pricing only. Fabrication and assembly require a separate written production release.

Quote complete carriers with all 36 BOM components installed. Include the 34 SMT parts and both through-hole sockets. External modules and enclosure parts are outside the quote. Use the exact MPNs; submit substitutions for approval.

## Fabrication requirements

Use four-layer FR-4, 1.6 mm nominal finished thickness, ENIG and 35 micrometers nominal outer copper. Use solder mask on both sides and white top silkscreen. Propose the mask color, stackup and thickness tolerance with the quote. No controlled impedance is specified.

The outline centerline spans 66.2 by 169.0 mm. The Gerber job reports 66.25 by 169.05 mm including the 0.05 mm outline stroke. Use the Edge.Cuts profile as the routing reference. Preserve the concave antenna cutout and its narrow prongs. Propose panel supports and depanelization before production. Keep panel tabs and copper thieving outside the antenna reservation.

Copper order: F.Cu signals/components, In1.Cu ground, In2.Cu ground with two routed nets, B.Cu signals/ground. Minimum routed width and clearance are 0.20 mm. Minimum copper-to-edge clearance is 0.30 mm. Ordinary vias use 0.30 mm drills. U1 has two 0.25 mm plated thermal holes in its exposed pad.

Resin-fill and copper-cap the nine locations in `via-in-pad.csv`, including U1's two thermal holes. Use IPC-4761 Type VII or propose an equivalent for review. Tenting alone does not meet this requirement. Review stencil coverage and solder voiding at U1's exposed pad.

## Assembly requirements

`assembly-bom.csv` contains 15 exact MPN groups covering 36 installed parts. `assembly-positions.csv` includes all 36 placements. Test pads, mounting holes and fiducials are bare-board features, not assembly parts. Return the assembly preview with connector orientation and U1 pin 1 visible. Propose the solder alloy and inspection coverage.

J1 and J2 are Samtec SSW-116-01-G-S and SSW-112-01-G-S sockets. Their specified body height is 8.51 mm. Their 2.64 mm tails project approximately 1.04 mm through the nominal board thickness. Confirm finished 1.0 mm hole tolerance, soldering and mating with the factory-headered Adafruit Feather V2 #5900. Both sockets must arrive installed.

J3 is Hirose FH12-18S-0.5SH(55): 18 contacts, 0.5 mm pitch, bottom contact, for 0.3 mm cable. Preserve its exact orientation and pin 1. J4 is the dedicated microSD socket. J5 connects the ANO controls. Install all three connectors.

The placement CSV uses KiCad coordinates in millimeters: positive X right, negative Y down from the shared absolute origin. The CSV angles are KiCad angles, not feeder rotations. The via inventory uses PCB coordinates: positive X right and positive Y down. Review these conventions before converting the files for assembly.

## Current physical status

The customer has the Feather #5900, Waveshare 29318 display and ANO #6310 controls. The enclosure revision B uses four 14 mm control spacers. The customer reports an even shell seam, flat LCD seating, aligned retainers and aligned carrier-gauge mounting holes. The wheel coupon fit is accepted.

The gauge is printed plastic. It does not verify electrical sockets or a populated carrier. Final padded retention, fastener fit, cable routing and header mating remain open. The supplied LCD ribbon has same-face contacts; its end-to-end mapping to J3 remains unverified. External modules, cables, spacers and screws are customer-installed after carrier acceptance.

## Verification and release

Fresh ERC and saved-rule DRC pass with zero reported violations and zero opens. A strict DRC run enables the suppressed component-type rule. It reports one U1 warning because the SMT footprint includes two plated thermal holes. U1 remains an SMT WSON component.

Source hashes match the saved electrical and assembly audits: 122 electrical pads, 28 Feather mating coordinates and 36 placements. These checks do not establish hardware performance. `package-verification.json` records the scope. `SHA256SUMS.txt` identifies the included files.

Please return DFM findings, exact component availability, panel and placement previews, and itemized prices. Separate bare-board electrical testing, assembly inspection and any optional powered test. Propose fixtures and charges before testing; this package does not authorize a supplier functional test with external modules.

Resolve supplier findings and the remaining customer mating checks before production release. The customer will perform staged carrier power checks and integrated playback qualification after delivery.
