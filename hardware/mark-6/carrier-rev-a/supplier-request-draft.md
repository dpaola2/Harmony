# Mark 6 supplier request draft

Prepared for HARMONY-17. This draft has not been sent. The package permits DFM review only; fabrication and assembly remain unreleased.

Subject: DFM and turnkey prototype estimate: Harmony Mark 6, four-layer carrier

Please review the attached `harmony-mark6-rev-a-review.zip` for fabrication and complete assembly. Please provide separate estimates for one, two and five assembled carriers. These quantities are pricing options, not an order commitment.

The carrier contains 36 installed components: 34 SMT parts and two through-hole sockets. Please install both sockets. The customer must not need to solder anything. The Feather, display, controls and cables are separate customer-supplied modules and are excluded from this assembly quote.

Please return:

1. Exact BOM availability, minimum purchase quantities, lead time, assembly cost and unused-part policy. List proposed substitutions separately; none are approved.
2. Your proposed four-layer stackup, finished thickness tolerance, ENIG finish and panel drawing. Preserve the antenna cutout and copper exclusion.
3. Confirmation of resin-filled, copper-capped vias at all nine locations in `via-in-pad.csv`. Tenting alone is insufficient.
4. Review of U1's exposed-pad stencil, thermal holes and inspection process. U1 is SMT despite the documented KiCad classification warning.
5. Confirmation of J1/J2 socket tails, finished-hole tolerance and orientation. Include connector polarity and placement previews for review.
6. Your electrical-test and assembly-inspection coverage, including any fixture or nonrecurring charges. Separate carrier power testing from module testing.

Please identify all fabrication, assembly or sourcing concerns before requesting production approval. Include shipping options, taxes or duties assumptions and quote validity.

The drawing set specifies four-layer FR-4, 1.6 mm nominal thickness, ENIG and 35 µm nominal outer copper. Detailed fabrication requirements and the file manifest are inside the package.

The PCB passes its saved ERC/DRC rules and has no unconnected nets. The strict audit documents one U1 classification warning. Physical module mating and powered qualification remain open. Please do not fabricate or assemble until the final release and quantity are confirmed.
