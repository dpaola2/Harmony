# Harmony Mark-6 Rev A - prototype manufacturing review

NOT RELEASED FOR FABRICATION OR ASSEMBLY. This package is for design/DFM review.
No order, quantity commitment or supplier communication accompanies it.

## Included

Four copper layers, mask, paste, silk and outline Gerbers; separate plated and
non-plated Excellon drills; exact 36-part carrier BOM; placement CSV including
through-hole sockets; schematic netlist; editable KiCad files; ERC/DRC reports;
power/mechanical notes, assembly-readiness.md, assembly audit, top fabrication
drawing, strict DRC and nine via-in-pad locations. SHA256SUMS.txt identifies this set.
The five test pads, eight mounting holes and three fiducials are bare-board
features, not items to purchase or place. Module/cable purchases are separate.

## Fabrication and assembly requirements

Use four-layer FR-4, 1.6 mm finished nominal thickness, 35 um nominal outer
copper, ENIG, solder mask both sides and white top silkscreen. Copper order:
F.Cu signals/components, In1.Cu ground, In2.Cu ground with two routed nets,
B.Cu signals/ground. No controlled impedance is specified. The fabricator
must return its stackup and thickness tolerance for review.

Minimum routed width/clearance: 0.20/0.20 mm. Copper-to-edge minimum: 0.30 mm.
Minimum plated drill: 0.25 mm at U1 thermal pads; ordinary vias 0.30 mm.
The U1 exposed-pad holes and any vias in SMT pads require resin filling and
copper capping (IPC-4761 Type VII or an agreed equivalent). Tenting alone is
insufficient. Review stencil apertures and exposed-pad voiding with the
assembler. Do not silently omit fill/cap or replace footprints to reduce cost.

The board's antenna cutout is functional. Preserve its profile and the ground
pour exclusion. Do not add copper thieving, rails or assembly tabs beneath the
antenna. Panel tooling and depanelization must be proposed before production.
The concave fork and 6 mm prongs need the fabricator's routing review.

Factory-install every BOM component, including J1/J2 through-hole sockets.
Dave must receive an assembled carrier requiring no soldering. Confirm Samtec
socket mating, tail/drill tolerance, connector part orientation and U1 pin 1
against the drawings. Position CSV uses KiCad millimeters: positive X right,
negative Y downward from the shared absolute origin. Angles are KiCad angles,
not a guarantee of any machine's tape orientation. Review every polarized
part and connector in the supplier's assembly preview.

## Release conditions

CAD presently passes zero ERC violations, zero PCB DRC violations and zero
unconnected nets. Every electrical PCB pad matches the exported schematic.
The strict DRC audit reports one documented U1 component-type warning caused
by its thermal holes; U1 is SMT. See assembly-readiness.md. These checks do
not establish hardware performance or physical assembly fit.

Before authorizing a prototype order, complete assembler DFM/part availability
review, confirm the header/socket mating and resolve procurement/measurement
of Waveshare 29318. The display uses vendor STEP geometry, and USB/SD access
and both cables need a hollow fit check before final housing release. If a
bare carrier is ordered first for learning, that is an explicit prototype
risk decision, not completion of these checks.

No battery is connected. Use the staged current-limited first-power procedure
in power-review.md. Then qualify display/SD/controls during A2DP playback,
reconnection, RF range, supply/thermal behavior and the deferred full album.
