"""Build every solid of the assembly, in device coordinates.

Item numbers are the ones used in the diagrams and in ASSEMBLY.md.
"""
import cadquery as cq

import extras
import fpc
import parts
import params as P
import sources

# number, name, source, colour (r, g, b)
ITEMS = [
    (1, "Front shell", "Printed", (0.86, 0.85, 0.82)),
    (2, "Wheel disc", "Printed, black", (0.12, 0.12, 0.13)),
    (3, "Side button cap", "Printed", (0.80, 0.79, 0.76)),
    (4, "Heat-set insert M2 x 3, 3.2 OD (4)", "Bought", (0.80, 0.62, 0.25)),
    (5, "Screen DLC-T2.7DDS#1", "DigiKey", (0.10, 0.12, 0.16)),
    (6, "Screen FPC (part of 5), shown folded", "DigiKey (with 5)", (0.85, 0.55, 0.15)),
    (7, "Main board, assembled", "JLCPCB", (0.10, 0.35, 0.20)),
    (8, "LiPo pack 404050, JST PH", "Bought", (0.62, 0.66, 0.72)),
    (9, "Vibration motor LCM1027A2445F (optional)", "LCSC C2759984", (0.55, 0.55, 0.58)),
    (10, "Back plate", "Printed", (0.84, 0.83, 0.80)),
    (11, "Screw M2 x 4 button head (4)", "Bought", (0.25, 0.25, 0.27)),
]
ITEM = {n: (name, src, col) for n, name, src, col in ITEMS}


def build():
    """Return (solids, meta). solids: list of dicts with keys
    name, item, shape, group ('printed', 'board', 'screen', ...)."""
    out = []

    def add(name, item, shape, group):
        out.append({"name": name, "item": item, "shape": shape, "group": group})

    shell = parts.front_shell()
    disc = parts.wheel_disc()
    cap = parts.button_cap()
    plate = parts.back_plate()
    add("front shell", 1, shell, "printed")
    add("wheel disc", 2, disc, "printed")
    add("button cap", 3, cap, "printed")
    add("back plate", 10, plate, "printed")
    for i, s in enumerate(extras.inserts()):
        add(f"insert {i + 1}", 4, s, "hardware")
    for i, s in enumerate(extras.screws()):
        add(f"screw {i + 1}", 11, s, "hardware")

    screen = sources.screen_solids()
    for k, s in extras.screen_parts(screen).items():
        add(f"screen {k}", 5, s, "screen")
    fsol, frep = fpc.build(screen)
    for k, s in fsol.items():
        add(k, 6, s, "fpc")

    for p in sources.board_parts():
        add("board " + p["ref"], 7, p["shape"], "board")
    for i, s in enumerate(extras.protrusions()):
        add(f"board J1 leg {i + 1} (touch side)", 7, s, "board")

    add("battery 404050", 8, extras.battery(P.BAT_404050, "404050"), "battery")
    add("battery foam", 8, extras.foam(), "foam")
    plug, wires = extras.battery_plug()
    add("battery plug PHR-2", 8, plug, "battery")
    add("battery wires", 8, wires, "battery")
    add("motor", 9, extras.motor(), "motor")

    meta = {"fpc": frep, "battery_fit": extras.largest_battery()}
    return out, meta


def reference_solids():
    """Solids that are checked but are not part of the build: the largest
    battery that fits, the SPEC 52 x 54 x 4.8 block and the 403450 pack."""
    fit = extras.largest_battery()
    return [
        ("battery largest, full width", extras.battery(fit["wide"], "wide")),
        ("battery largest, narrow", extras.battery(fit["narrow"], "narrow")),
        ("battery 403450", extras.battery(P.BAT_403450, "403450")),
        ("battery SPEC 52 x 54 x 4.8 block", extras.battery(P.BAT_MAX, "spec")),
    ]
