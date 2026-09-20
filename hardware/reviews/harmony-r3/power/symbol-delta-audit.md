# R3 symbol delta and residual library-warning audit

Date: 2026-09-14

This is a read-only comparison of the corrected project-local definitions in `tangara-mainboard/symbols.kicad_sym` against the copies embedded in the R3 schematic sheets. The comparison extracted each complete S-expression, normalized whitespace and only the expected embedded `symbols:` prefix, and compared the resulting content. Pin tables were independently extracted and compared by pin number, name, and electrical type.

## Corrected symbol copies

| Intended part | KiCad library ID | Embedded sheet | Full normalized definition | SHA-256 prefix | Electrical pin types |
|---|---|---|---|---|---|
| INA1620 | `INA1620` | `audio.kicad_sch` | Identical | `94e33e0dfa5acc82` | EN input; V+, V-, GND, EP power input; amplifier inputs input; amplifier outputs output; resistor terminals passive; NC no-connect |
| TPS65133 | `TPS65135RTER` | `audio.kicad_sch` | Identical | `f9405977530ec93e` | AVIN, PVIN, AGND, PGND, GND, EXP power input; VPOS and VNEG power output; EN input; SWP and SWN bidirectional |
| WM8523 | `WM8523` | `audio.kicad_sch` | Identical | `1f26300042c2f33d` | AVDD, LINEVDD, AGND, LINEGND power input; DACDAT, MCLK, SCLK, mute/mode pins input; BCLK, LRCLK, SDA, SDOUT/DEEMPH bidirectional; analog/charge-pump/status outputs output |
| PCA8575BS | `PCA8575BS` | `peripherals.kicad_sch` | Identical | `17efdfc779d9d9cb` | IO0_0 through IO1_7 and SDA bidirectional; SCL and address pins input; INT open collector; VDD, VSS, EP power input |
| TPS22948 | `TPS22917DBV` | `peripherals.kicad_sch` | Identical | `964feaf978523612` | IN and GND power input; ON input; FLT open collector; OUT power output; NC no-connect |
| BMDU JTAG connector | `BMDU` | `tangara-mainboard.kicad_sch` | Identical | `afff7dc3b32ef9b1` | vRef power input; GND contacts 3 and 5 passive; TMS, TCK, TDO, UART_TX, nRst output; TDI and UART_RX input |

The BMDU device is a physical JTAG/debug connector (`J3`, value `JTAG`, DNP), not a powered module. Passive GND contacts therefore describe connector contacts correctly. Its vRef remains a power input because the target supplies the debugger's voltage reference.

## Residual `lib_symbol_issues`

The final native ERC reports contain exactly 89 mainboard and 22 faceplate `lib_symbol_issues`. Every one says the embedded symbol “has been modified in library”; none is a library-not-found warning.

Mainboard:

| Library symbol | Count | Affected references |
|---|---:|---|
| GND | 60 | #PWR01, #PWR0102, #PWR0103, #PWR0105, #PWR0109, #PWR011, #PWR0110, #PWR0117, #PWR0119, #PWR012, #PWR0121, #PWR0122, #PWR013, #PWR014, #PWR015, #PWR016, #PWR017, #PWR018, #PWR020, #PWR0201, #PWR0202, #PWR0203, #PWR0204, #PWR0206, #PWR0208, #PWR0209, #PWR021, #PWR0210, #PWR0211, #PWR0213, #PWR0214, #PWR023, #PWR024, #PWR025, #PWR028, #PWR029, #PWR030, #PWR031, #PWR032, #PWR033, #PWR034, #PWR035, #PWR036, #PWR037, #PWR038, #PWR039, #PWR0402, #PWR0404, #PWR0407, #PWR0409, #PWR0410, #PWR0412, #PWR0413, #PWR0415, #PWR0417, #PWR043, #PWR054, #PWR055, #PWR06, #PWR09 |
| +3V3 | 24 | #PWR010, #PWR0101, #PWR0108, #PWR0111, #PWR0112, #PWR0113, #PWR0115, #PWR0118, #PWR0120, #PWR0125, #PWR0205, #PWR0217, #PWR026, #PWR03, #PWR04, #PWR0403, #PWR0406, #PWR0408, #PWR041, #PWR0411, #PWR0416, #PWR05, #PWR056, #PWR08 |
| +5VA | 2 | #PWR019, #PWR027 |
| -5VA | 2 | #PWR02, #PWR022 |
| SW_SPDT | 1 | SW1 |

Faceplate:

| Library symbol | Count | Affected references |
|---|---:|---|
| GND | 13 | #PWR010, #PWR0102, #PWR0106, #PWR0108, #PWR012, #PWR016, #PWR017, #PWR018, #PWR02, #PWR05, #PWR06, #PWR07, #PWR09 |
| +3V3 | 9 | #PWR01, #PWR0101, #PWR0107, #PWR0109, #PWR011, #PWR013, #PWR03, #PWR04, #PWR08 |

These 111 findings are library-difference warnings limited to standard power symbols plus mainboard SW1. They do not implicate any of the six audited project-local symbols above. No library refresh, exclusion, or circuit mutation was performed during this follow-up.
