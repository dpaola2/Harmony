"""Every enclosure dimension in one place. Device coordinates (SPEC 1), mm.

Values marked JSON come from hardware/mark-8/slab-rev-a/mechanical-interface.json
at import time, so the case follows the board if the board file changes.
"""
import math

import sources

MI = sources.mech()

# ---------------------------------------------------------------- body (SPEC 2)
BODY_W = 58.6
BODY_H = 103.5
T = 9.5
# SPEC 2 says plan corner R6.5. The screen's top corners then sit 0.63 from the
# outer surface, which leaves no printable wall around a screen pocket. R5.5 is
# the smallest change that leaves 0.8 at those corners (see README).
CORNER_R = 5.5
EDGE_ROUND = 1.0
WALL = 1.6
SKIN = 1.0
SPLIT_Z = -8.3               # back plate inner face, shell rear end
BACK_T = 1.2
X_OUT = BODY_W / 2           # 29.3
Y_OUT = BODY_H / 2           # 51.75
X_IN = X_OUT - WALL          # 27.7
Y_IN = Y_OUT - WALL          # 50.15
INNER_R = CORNER_R - WALL    # 3.9

# ---------------------------------------------------------------- board (JSON)
BOARD = MI["board"]
Z_TOUCH = BOARD["z_touch_side"]          # -1.0
Z_COMP = BOARD["z_component_side"]       # -1.8
BOSSES = [(-24.7, -47.15), (24.7, -47.15), (-24.7, 47.15), (24.7, 47.15)]
BOTTOM_BOSSES = BOSSES[:2]
TOP_BOSSES = BOSSES[2:]

# Heat-set insert: M2 x 3 long, 3.2 OD knurl (SPEC 10).
INSERT_OD = 3.2
INSERT_L = 3.0
INSERT_HOLE_D = 3.0          # 0.2 under the knurl OD
BOSS_D = INSERT_HOLE_D + 2 * 1.2   # 5.4, 1.2 wall
PAD_H = 0.6                  # screw pad on the back plate inner face
BOSS_END_Z = SPLIT_Z + PAD_H  # -7.7, shell boss end face = insert face
INSERT_HOLE_DEPTH = 3.6       # hole bottom at -4.1
TOP_BOSS_TOP_Z = -3.6         # 0.45 below the screen back (-3.15)
SCREW_HOLE_D = 2.4
CBORE_D = 4.2
CBORE_DEPTH = 1.1             # head seat at z -8.4, 0.7 of plastic under the head

# ---------------------------------------------------------------- screen (SPEC 3)
SCR_X = 26.68
SCR_Y0, SCR_Y1 = -7.84, 49.65
SCR_Z0, SCR_Z1 = -3.15, -1.0
AA_X = 24.48
AA_Y0, AA_Y1 = -1.51, 47.45
WIN_MARGIN = 0.3
WIN_R = 1.5
WIN_CHAMFER = 0.4
SCR_CLEAR = 0.15              # pocket clearance per side
SCR_POCKET_R = 0.3
SCR_LIP_Z = -2.1              # bottom locating lips stop here (rim is z -1.0 to -2.11), 0.3 above the battery plug

# ---------------------------------------------------------------- wheel (SPEC 4)
WHEEL = MI["wheel"]
WC = tuple(WHEEL["centre"])   # (0, -27.75)
DISC_R = WHEEL["disc_diameter"] / 2   # 17.0
DISC_T = 1.0
DISC_GAP = 0.15
FLANGE_R = 18.5
FLANGE_T = 0.4
RECESS_R = FLANGE_R + DISC_GAP        # 18.65
KEY_ANGLE = 45.0              # deg, measured from +X toward +Y (upper right)
KEY_R0, KEY_R1 = FLANGE_R, FLANGE_R + 1.0
KEY_W = 3.0
LABEL_R = 12.2                # label circle, middle of the ring electrodes
DEBOSS = 0.4

# ---------------------------------------------------------------- protrusions
PROT = MI["touch_side_protrusions"]
RELIEF_GROW = 0.5             # per side
RELIEF_DEPTH = 0.5

# ---------------------------------------------------------------- USB-C (JSON)
USB = MI["usb_c"]
USB_ZC = USB["z_centre_line"]           # -3.46
USB_FACE_Y = USB["mating_face_y"]       # -50.4
USB_OPEN_W, USB_OPEN_H, USB_OPEN_R = 9.3, 3.6, 1.0
# Overmold pocket: USB Type-C overmold limit 12.35 x 6.5, centred on the plug axis.
# Its top would cut the 1.0 front edge round and leave a feather edge, so the
# pocket runs out through the round (a port recess in the bottom edge).
USB_POCKET_W, USB_POCKET_R = 12.6, 2.0
USB_POCKET_ZBOT = USB_ZC - 3.3            # -6.76
USB_POCKET_DEPTH = 0.9        # overmold can reach y -50.85, 0.45 from the receptacle face

# ---------------------------------------------------------------- microSD (JSON)
SD = MI["microsd"]
SD_X0, SD_X1 = SD["card_slot_x_range"]
SD_ZC = SD["card_plane_z"]
SD_SLOT_W = (SD_X1 - SD_X0) + 0.4      # 11.4
# MECH-5: the JSON card plane comes from a vendor model 0.21 taller than the
# Hirose drawing (1.68). From the drawing, a 1.0 card under the cover sits
# about z -2.38 to -3.38; the model puts it at z -2.64 to -3.64. The slot is
# 1.8 tall on the old centre line (z -2.24 to -4.04) and covers both; at 0.2
# layers it prints as z -2.2 to -4.0.
SD_SLOT_H = 1.8
SD_CARD_T = 1.0
SD_CARD_DRAWING_Z = (-2.38, -3.38)     # card faces from the drawing estimate (review MECH-5)
SD_CHAMFER = 0.3
SD_LEAD_EXT_X = 0.45                   # lead-in starts this far outside the scallop floor, in X
SD_LEAD_EXT_Z = 0.8                    # and in Z, so it starts inside the scallop for the taller slot
SD_SCALLOP_R = 3.0
SD_SCALLOP_DEPTH = 0.9
SD_SCALLOP_X = (SD_X0 - 1.0, SD_X1 + 1.0)

# ---------------------------------------------------------------- side button
SB = MI["side_button"]
SB_TIP = tuple(SB["actuator_tip"])     # (27.46, -15.6, -3.5)
CAP_REST_GAP = 0.12
CAP_Z_H = 2.6                 # cap height in z, centred on the actuator
CAP_STEM_W = 4.0              # along y
CAP_HEAD_W = 5.6
CAP_FLANGE_W = 6.8
CAP_FLANGE_T = 0.6              # ears; the middle part in front of SW1 is 0.4
CAP_FLANGE_MID_T = 0.4
CAP_EAR_DY = 2.6                 # ears start here (SW1 body and tabs reach |dy| 2.4)
CAP_CUP_W = 2.4               # actuator is 2.0
CAP_PROUD = 0.5
CAP_HEAD_T = 0.7
CAP_STOP = 0.42               # gap 0.12 + switch travel 0.2 + 0.1 for print tolerance
CAP_CLEAR = 0.15
CAP_POCKET_DEPTH = 0.55       # outer pocket in the wall

# ---------------------------------------------------------------- locating pins
HOLES = MI["locating_holes"]
PIN_D = 1.45
PIN_TIP_Z = -2.4              # 0.6 past the component side
PIN_CHAMFER = 0.35

# ---------------------------------------------------------------- press posts
PADS = MI["press_pads"]
POST_TIP_D = 3.0
POST_BASE_D = 4.4
POST_TIP_Z = Z_COMP + 0.1     # -1.7: 0.1 interference with the pad
POST_NECK_Z = -4.0
POST_CONE_Z = -5.0

# ---------------------------------------------------------------- back plate details
LIP_W, LIP_H, LIP_GAP = 0.8, 0.8, 0.15

# ---------------------------------------------------------------- bottom wall standoffs (MECH-6)
# Three small standoffs on the inner face of the bottom wall close the 0.55 gap
# to the board's bottom edge (y -49.6) to 0.1, so a USB-C pull is taken by the
# wall, not only by the two pins. Away from the J1 opening (|x| < 4.65), the
# card slot (x -19.4 to -8.0), the bottom bosses and the parts at the edge.
STANDOFF_X = (-20.9, 13.5, 20.9)
STANDOFF_W = 1.6               # along x
STANDOFF_GAP = 0.1             # to the board edge
STANDOFF_Z1 = -2.2             # 0.4 past the board's component side
STANDOFF_CHAMFER = 0.3         # on the back edge, guides the board edge on the tilt-in
BOARD_Y0 = -49.6               # board bottom edge (JSON outline)

# ---------------------------------------------------------------- JLC frame tabs (board README Decision 10)
# Mouse-bite tabs, device coordinates; a cut on the hole line leaves a nub up to
# 0.35 proud, which the builder files flush. (edge, along-edge range)
FRAME_TABS = [("left", (-17.9, -13.1)), ("top", (22.1, 26.1)), ("right", (-45.4, -40.6))]
TAB_NUB_MAX = 0.35
BZ = MI["buzzer"]
LED = MI["charge_led"]
LED_HOLE_D = 1.0
LED_X = -5.83                  # 0.07 right of the LED centre, centres the tube between J3 and J1
# MECH-2: the tube passes between J3 (x max -7.195, down to z -3.69) and J1
# (x min -4.47, down to z -5.06). The neck beside them is 1.9 OD (0.41 to
# each), the base below J1 stays 2.3 OD for strength, the hole stays 1.0.
LED_TUBE_OD = 2.3              # base, from the plate to LED_NECK_Z
LED_NECK_OD = 1.9
LED_NECK_Z = -5.5              # 0.44 below the J1 shell
LED_TIP_CHAMFER = 0.15         # outer edge of the tip, so a misplaced tube slides off J1 or J3
LED_TUBE_TOP = -2.9            # LED top is -2.5
MOTOR_C = (-20.0, -39.5)
MOTOR_D, MOTOR_H = 10.0, 2.7
MOTOR_POCKET_D, MOTOR_POCKET_DEPTH = 10.4, 0.3   # shallow round seat marks the spot

# ---------------------------------------------------------------- battery
BAT_POCKET_Y0 = -3.5           # cable bay below this line
BAT_TOP_Z = -3.15              # screen back
# MECH-3: 0.2 to 0.5 foam between the pack and the screen back. The model uses
# the thick end, 0.5. The screen is 2.15 +-0.10 thick (DLC drawing), so the
# largest pack is 5.15 - 0.5 - 0.1 = 4.55.
BAT_FOAM = 0.5
SCR_T_TOL = 0.10
BAT_FOAM_W, BAT_FOAM_L = 35.0, 45.0
BAT_MAX = (52.0, 54.0, 4.8)
BAT_404050 = (40.0, 50.0, 4.0)
BAT_403450 = (34.0, 50.0, 4.0)
RIB_H, RIB_W, RIB_GAP = 1.2, 0.8, 0.3

# ---------------------------------------------------------------- FPC (SPEC 3.1 + STEP)
FPC = MI["screen_connector"]
FPC_T = 0.2
FPC_TAIL_W = 4.8
J2_XC = FPC["slot_mouth_x"]    # -2.238
J2_YC = FPC["slot_centre_line_y"]   # -39.0
J2_ZC = FPC["fpc_entry_z"]     # -2.2
FPC_INSERT = 1.3               # insertion depth into FH35C, from the mouth
FPC_GAP = 0.02                 # FPC floats 0.02 above the plate in the model
FOLD_RI = 0.2                  # inner radius of the 180 degree fold
TAIL_CHANNEL_DEPTH = 0.3
TAIL_CHANNEL_W = 5.4


def rad(a):
    return math.radians(a)
