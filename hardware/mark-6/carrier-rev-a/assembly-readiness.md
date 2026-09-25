# Mark 6 assembly review

Reviewed September 22, 2026 for HARMONY-17. The carrier package is ready for a supplier's DFM review. It is not released for fabrication. The remaining decisions require the physical modules or the assembler's process limits.

The review caught a conflict between the ENIG finish specified in the instructions and the Gerber job file's `None` value. The editable PCB now specifies ENIG, and the regenerated Gerber job agrees. Board routing and electrical nets did not change.

All 36 installed components match the board's values, footprint names, positions, angles and top-side placement. There are 34 SMT components and two through-hole sockets. The five test pads, eight mounting holes and three fiducials are excluded from the assembly BOM. The package now labels assembly method and includes a top fabrication drawing and the nine identified via-in-pad locations.

The saved design rules pass with zero violations and no opens. A second run enables all ignored categories and uses 0.10 mm silkscreen clearance. It reports one warning: KiCad interprets U1's two plated thermal holes as evidence of a through-hole component. U1 is an SMT WSON package; both holes connect exposed pad 9 to ground. The warning is documented rather than changing the part to through-hole assembly. The other previously ignored categories are now enabled in the saved project. Earlier statements implying every DRC category was enabled were too broad.

J1 and J2 have 28 matching Feather coordinates, 1.0 mm holes and 1.7 mm pads. Their 2.64 mm socket tails project about 1.04 mm through the nominal 1.6 mm PCB. This establishes nominal geometry; the assembler must confirm finished-hole tolerance and soldering. [Samtec dimensions](https://suddendocs.samtec.com/catalog_english/ssw_th.pdf). J3 matches the specified 18 contacts at 0.5 mm pitch, bottom contact and 0.3 mm cable thickness. [Hirose part specification](https://www.hirose.com/en/product/p/CL0586-0530-1-55).

| Before release | Evidence needed |
| --- | --- |
| Header and ribbon mating | Dry fit the actual #5900, sockets and Waveshare 29318. Verify ribbon pin 1 continuity and contact orientation with power disconnected. |
| Fabrication process | Supplier accepts the four-layer stack, board thickness tolerance, concave antenna cutout, panel supports and filled/capped vias. |
| Assembly process | Supplier confirms 34 SMT parts, two socket insertions, connector orientation and U1 stencil coverage. No customer soldering. |
| Component sourcing | Supplier confirms exact MPN stock and packaging for the requested prototype quantity. No substitutes are approved. |
| Housing release | Dry fit the new front, cable loops, USB plug and SD access. Permanent display retention remains unfinished. |

After assembly, use the staged first-power procedure in [power-review.md](power-review.md). Supply, display/SD/controls during A2DP, reconnection, RF and the full-album test remain hardware qualifications. Detailed evidence is in [assembly-audit.json](assembly-audit.json) and the [mechanical review](mechanical-review.md).
