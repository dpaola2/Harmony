# Harmony R3 power and ERC cleanup

Date: 2026-09-14

## Result

KiCad 8.0.9 native ERC reports one intentionally retained error on the R3 mainboard and zero errors on the faceplate. The mainboard changed from 10 errors and 95 warnings to 1 error and 94 warnings. The faceplate changed from 2 errors and 24 warnings to 0 errors and 24 warnings. No ERC exclusions or project-rule suppressions were added.

The machine-readable before/after reports and exported netlists are in this directory:

- `before-mainboard-erc.json` and `after-mainboard-erc.json`
- `before-mainboard-netlist.xml` and `after-mainboard-netlist.xml`
- `before-faceplate-erc.json` and `after-faceplate-erc.json`
- `before-faceplate-netlist.xml` and `after-faceplate-netlist.xml`

## Datasheet-backed symbol corrections

Texas Instruments TPS65133 datasheet SLVSC01A identifies AVIN and PVIN as supply pins, AGND, PGND, GND, and the exposed pad as ground connections, and VPOS and VNEG as converter outputs. The R3 project symbol and the embedded Audio-sheet copy now use `power_in` for supply/ground pins and `power_out` for VPOS/VNEG. SWP and SWN remain bidirectional switch nodes, and EN remains a logic input.

Source: https://www.ti.com/lit/ds/symlink/tps65133.pdf

Texas Instruments INA1620 datasheet SBOS859B states that EN may be driven by a controller GPIO or logic gate, or tied directly to V+. The project symbol and embedded Audio-sheet copy now describe EN as an input rather than a power input. The ±5 V supply pins remain power inputs.

Source: https://www.ti.com/lit/ds/symlink/ina1620.pdf

U16 is populated as TPS22948 even though the inherited library identifier is `TPS22917DBV`. Its FLT pin is physically tied to GND in this design. TI specifies FLT as an open-drain output that pulls low during thermal-shutdown or reverse-current events. The project and embedded symbols retain that `open_collector` electrical type. This intentionally unused, fixed-low status output therefore produces the remaining ERC pin conflict when the same GND net is correctly marked with a power-source flag. The conflict is recorded rather than hidden by changing the IC pin function or adding an ERC exclusion.

Source: https://www.ti.com/lit/ds/symlink/tps22948.pdf

The BMDU JTAG connector GND pins are passive connector contacts rather than power consumers. This removes the false requirement for a local source on that connector while preserving its GND net.

## Power-source proof

- Mainboard VBUS is physically supplied at USB-C receptacle J6, then connects to Q1 source. `#FLG0201` is on that external VBUS net.
- Mainboard `VBUS_SWITCHED` is the Q1 drain rail feeding MCP73871 U10 IN pins 18 and 19 and VPCC pin 2. Since a MOSFET passive pin does not advertise a source to ERC, `#FLG0202` annotates the post-Q1 rail.
- Mainboard GND returns through USB-C J6 and battery connector J7. `#FLG0203` marks that externally established reference.
- Faceplate +3V3 enters through J4 pins 13, 14, and 15; GND returns through J4 pins 1, 5, 7, and 9. `#FLG01` and `#FLG02` annotate these externally supplied rails.

The before/after netlists show the same functional nets for the affected pins. Flags only add ERC power-output annotations.

## Other cleanup

Three bus-entry objects in `peripherals.kicad_sch` had no wire endpoint and produced the three dangling-wire errors. They were removed by UUID; no bus member, label, or wire was removed.

The hierarchical connector that appears as mainboard J2 now has the value `FP Connector`, matching its existing PCB value and naming its faceplate destination from the mainboard perspective. Its pin nets are unchanged.

The remaining mainboard error is the documented TPS22948 FLT-to-GND disposition above. The other 94 mainboard and 24 faceplate findings are warnings. Most are KiCad library-difference warnings inherited from the source design. This pass did not blanket-waive or suppress them.
