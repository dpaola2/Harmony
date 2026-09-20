# GlobTek integration draft

Selected pack: BL2200F9031781S1PCKT. Local R5 draft changes U10 to MCP73871-1CCI/ML. All 459 mainboard pin/net assignments match R4. Reversing the PCB MPN substitution restores the original file exactly. R4 and its supplier submission remain unchanged.

- `mainboard-bom-DRAFT.csv`: complete candidate mainboard BOM; only U10 changes.
- `harness.csv`: connector mapping. Pack 1/2/3 goes to board 3/1/2; never connect straight through.
- `verification.json`: voltage, current, termination, timer and unresolved thermal checks.
- `prepare.py`: reproducible source, BOM and netlist verification.
- `thermal-verification.json`: acceptance limits for testing the actual pack's sensor without waiting for a supplier reply.

Adapter construction basis: JST B3B-PH-K-S header, PHR-3 housing, three SPH-002T-P0.5S contacts and 26 AWG UL1007 leads. Header needs an insulated support and strain relief; this is a wiring specification, not a finished harness. Verify mapping and isolation with the adapter disconnected from battery and board. Verify voltage polarity before connection. Do not use wire color as the sole pin identifier.

Retain the 1 kΩ charge resistor and 10 kΩ termination resistor for initial evaluation. Earlier termination may reduce capacity. The six-hour backup timer is not proof of compliance with the pack's recommended charging duration. Portable charging remains unqualified pending sensor and full-cycle tests.

Sources: GlobTek Rev A3 pack drawing; Microchip DS20002090F; JST PH connector drawing https://www.jst-mfg.com/product/pdf/eng/ePH.pdf. Tracking: HARMONY-9 and HARMONY-15.
