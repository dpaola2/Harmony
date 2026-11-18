"""Harmony Mark-8 "slab" revision A: the single design source for every build script.

All positions here are DEVICE coordinates in millimetres (SPEC.md section 1): origin at the
centre of the body outline on the front face, +X right seen from the front, +Y toward the
screen, +Z out of the front face. KiCad shows the component side, so KiCad X and Y are
mirrored. `to_kicad` and `to_device` are the only place that transform lives.

Runs under KiCad's bundled Python 3.9 and under uv's Python 3.12: standard library only.
"""
from pathlib import Path
import math

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
NAME = 'harmony-mark8-slab'
KICAD = REPO / 'firmware/toolchains/kicad-8.0.9/KiCad.app/Contents'
LIBNAME = 'Harmony8'
LIBDIR = HERE / 'lib'

# --- Coordinate transform (SPEC 1) --------------------------------------------------------
X0, Y0 = 150.0, 70.0          # KiCad position of the device origin


def to_kicad(dx, dy):
    """Device (x, y) -> KiCad board (x, y) in mm."""
    return (X0 - dx, Y0 - dy)


def to_device(kx, ky):
    """KiCad board (x, y) in mm -> device (x, y)."""
    return (-(kx - X0), -(ky - Y0))


def device_dir(kicad_orientation_deg, local_dir):
    """Device-frame unit vector of a footprint-local direction for a top-side footprint.
    KiCad rotates footprints counter-clockwise on screen (y down): local (x, y) maps to
    (x cos t + y sin t, -x sin t + y cos t); the device frame then negates both axes."""
    t = math.radians(kicad_orientation_deg)
    x, y = local_dir
    kx, ky = x * math.cos(t) + y * math.sin(t), -x * math.sin(t) + y * math.cos(t)
    return (-kx, -ky)


def local_to_device(origin, kicad_orientation_deg, local_xy):
    """Device position of a footprint-local point for a footprint placed at device `origin`."""
    ex = device_dir(kicad_orientation_deg, (1, 0))
    ey = device_dir(kicad_orientation_deg, (0, 1))
    return (origin[0] + local_xy[0] * ex[0] + local_xy[1] * ey[0],
            origin[1] + local_xy[0] * ex[1] + local_xy[1] * ey[1])


# --- Body, board and zones (SPEC 2, 3.1, 4, 6) --------------------------------------------
BOARD_T = 0.8
Z_TOUCH = -1.0                 # L4 against the back of the front skin
Z_COMP = Z_TOUCH - BOARD_T     # component surface, -1.8
Z_BACKPLATE = -8.3
BOSSES = [(-24.7, -47.15), (24.7, -47.15), (-24.7, 47.15), (24.7, 47.15)]
BOSS_CLEAR = 2.9
BOARD_X = (-27.2, 27.2)
BOARD_Y = (-49.6, -10.0)
BOARD_CORNER_R = 1.0           # small outer corner radius at the two top corners


def board_outline(step_deg=5.0):
    """Closed device-coordinate polygon of the board edge (arcs sampled at step_deg).
    Bottom corners are cut by circles of radius BOSS_CLEAR about the two lower bosses."""
    x0, x1 = BOARD_X
    y0, y1 = BOARD_Y
    r = BOSS_CLEAR
    rc = BOARD_CORNER_R

    def arc(cx, cy, rad, a0, a1):
        n = max(2, int(abs(a1 - a0) / step_deg) + 1)
        return [(cx + rad * math.cos(math.radians(a0 + (a1 - a0) * i / (n - 1))),
                 cy + rad * math.sin(math.radians(a0 + (a1 - a0) * i / (n - 1)))) for i in range(n)]
    bx, by = BOSSES[0]
    bx2, by2 = BOSSES[1]
    # Angles where each boss circle meets the board's side and bottom edges.
    aL = math.degrees(math.atan2(math.sqrt(r * r - (x0 - bx) ** 2), x0 - bx))        # ~149.5
    aB = math.degrees(math.atan2(y0 - by, math.sqrt(r * r - (y0 - by) ** 2)))        # ~-57.7
    aB2 = math.degrees(math.atan2(y0 - by2, -math.sqrt(r * r - (y0 - by2) ** 2)))    # ~-122.3
    aR2 = math.degrees(math.atan2(math.sqrt(r * r - (x1 - bx2) ** 2), x1 - bx2)) - 360  # ~-329.5
    pts = []
    pts += arc(x0 + rc, y1 - rc, rc, 90, 180)        # top-left corner, counter-clockwise
    pts += arc(bx, by, r, aL, aB)                    # left notch, concave, clockwise
    pts += arc(bx2, by2, r, aB2, aR2)                # right notch, concave, clockwise
    pts += arc(x1 - rc, y1 - rc, rc, 0, 90)          # top-right corner
    # de-duplicate consecutive points
    out = []
    for p in pts:
        if not out or math.hypot(p[0] - out[-1][0], p[1] - out[-1][1]) > 1e-6:
            out.append((round(p[0], 4), round(p[1], 4)))
    return out


WHEEL_C = (0.0, -27.75)
WHEEL_DISC_D = 34.0
RING_R = (7.8, 16.6)
CENTER_R = 7.0
ELECTRODE_GAP = 0.4
TOOTH_COUNT = 3                # sawtooth teeth per sector boundary
TOOTH_AMPLITUDE = 0.9          # tangential half-amplitude in mm
WHEEL_KEEPOUT_R = RING_R[1] + 0.5   # 17.1: electrode disc plus 0.5; see DISC_L3_NETS
L4_POUR_CLEAR_R = 17.6         # L4 GND pour stays outside this radius
HATCH_R = 17.6                 # L2 25 percent hatch inside this radius
HATCH_WIDTH, HATCH_GAP = 0.2, 1.3   # (1.3/1.5)^2 = 0.751 open -> 24.9 percent copper

# FPC zones (SPEC 3.1)
DIVE_ZONE = ((-14.0, 19.0), (-10.0, -7.8))
RUN_ZONES = [((-13.7, 18.5), (-18.8, -10.0)),   # wide section
             ((-13.7, -6.7), (-44.0, -18.6)),   # vertical leg
             ((-13.5, 27.2), (-47.0, -37.0))]   # tail band
# Screen connector J2: slot mouth x_c and slot centre line y_c (see README "Changes")
J2_XC, J2_YC = -2.2, -39.0
RAMP_ZONE = ((J2_XC, J2_XC + 18.0), (J2_YC - 3.0, J2_YC + 3.0))

# Antenna: U1 antenna end on the right edge. Copper keep-out on every layer.
U1_ORIGIN = (16.2, -29.3)      # pad-centre origin of the EasyEDA footprint, KiCad 90 deg
ANTENNA_REGION = ((21.8, 27.2), (U1_ORIGIN[1] - 6.6, U1_ORIGIN[1] + 6.6))
ANTENNA_KEEPOUT = ((21.8, 27.2), (U1_ORIGIN[1] - 8.6, U1_ORIGIN[1] + 7.5))

# Height limits from the component surface (SPEC 6)
H_GENERAL, H_RUN, H_RAMP = 5.6, 4.9, 0.6

# Mechanical-only board features (device coordinates)
LOCATING_HOLES = [(-12.0, -11.4), (24.6, -40.6)]   # NPTH 1.6, front skin pins
LOCATING_HOLE_D = 1.6
PRESS_PADS = [(-24.9, -33.0), (-3.6, -30.7), (6.2, -31.0), (6.8, -21.4)]
PRESS_PAD_D = 4.0
MOTOR_PADS = {'M1': ('MOTOR_P', (-22.2, -40.9)), 'M2': ('MOTOR_N', (-22.2, -43.2))}

# --- Parts --------------------------------------------------------------------------------
# Footprint names are in the project library Harmony8.pretty (built by make_lib.py).
R0402, C0402 = 'R_0402_1005Metric', 'C_0402_1005Metric'
R0603, C0603 = 'R_0603_1608Metric', 'C_0603_1608Metric'
R0805, C0805 = 'R_0805_2012Metric', 'C_0805_2012Metric'
R1206 = 'R_1206_3216Metric'

# LCSC numbers for JLC basic passives (checked 2026-11-17, see jlcpcb/stock.json)
RES = {('5.1k', R0402): 'C25905', ('1k', R0402): 'C11702', ('10k', R0402): 'C25744',
       ('100k', R0402): 'C25741', ('100R', R0402): 'C25076', ('1M', R0402): 'C26083',
       ('4.7k', R0402): 'C25900', ('2.7k', R0603): 'C13167', ('75k', R0603): 'C23242',
       ('150k', R0603): 'C22807', ('33R', R0805): 'C17634', ('10R', R1206): 'C17903'}
CAP = {('100nF', C0402): 'C1525', ('1uF', C0402): 'C52923', ('4.7uF', C0603): 'C19666',
       ('10uF', C0603): 'C19702', ('22uF', C0603): 'C59461', ('10uF', C0805): 'C15850',
       ('22uF', C0805): 'C45783'}

PARTS = []   # dicts: ref, sym, value, fp, lcsc, pins{pad: net}, pos (device), rot (KiCad deg), block


def part(ref, sym, value, fp, lcsc, pins, pos, rot, block, bom=True, mpn=''):
    PARTS.append(dict(ref=ref, sym=sym, value=value, fp=fp, lcsc=lcsc, pins=pins,
                      pos=pos, rot=rot, block=block, bom=bom, mpn=mpn))


def R(ref, value, fp, a, b, pos, rot, block):
    part(ref, 'R', value, fp, RES[(value, fp)], {'1': a, '2': b}, pos, rot, block)


def C(ref, value, fp, a, b, pos, rot, block):
    part(ref, 'C', value, fp, CAP[(value, fp)], {'1': a, '2': b}, pos, rot, block)


GND = 'GND'

# ---- USB-C, ESD, USB-serial, auto-reset (bottom right) ----
usb = {'A1B12': GND, 'B1A12': GND, 'A4B9': 'VBUS', 'B4A9': 'VBUS', 'A5': 'CC1', 'B5': 'CC2',
       'A6': 'USB_DP', 'B6': 'USB_DP', 'A7': 'USB_DN', 'B7': 'USB_DN', 'A8': None, 'B8': None,
       '1': GND, '2': GND, '3': GND, '4': GND}
part('J1', 'USB_C', 'TYPE-C-31-M-12', 'USB-C_HRO_TYPE-C-31-M-12', 'C165948', usb,
     (0.0, -50.4 + 4.93), 0, 'usb', mpn='HRO TYPE-C-31-M-12')
R('R1', '5.1k', R0402, 'CC1', GND, (5.05, -48.1), 90, 'usb')
R('R2', '5.1k', R0402, 'CC2', GND, (-5.35, -47.9), 90, 'usb')
C('C1', '10uF', C0805, 'VBUS', GND, (-5.6, -44.2), 90, 'usb')
part('U8', 'USBLC6', 'USBLC6-2SC6', 'SOT-23-6', 'C7519',
     {'1': 'USB_DN', '6': 'USB_DN', '3': 'USB_DP', '4': 'USB_DP', '2': GND, '5': 'VBUS'},
     (7.9, -44.4), 90, 'usb', mpn='STMicro USBLC6-2SC6')
part('U2', 'CH9102F', 'CH9102F', 'QFN-24_4x4_P0.5_EP2.5', 'C2858418',
     {'1': None, '2': GND, '3': 'USB_DP', '4': 'USB_DN', '5': '3V3', '6': 'U2_V3', '7': 'VBUS',
      '8': 'VBUS', '9': None, '10': None, '11': None, '12': None, '13': None, '14': None,
      '15': None, '16': None, '17': None, '18': None, '19': 'RTS', '20': 'U2_RXD', '21': 'U2_TXD',
      '22': None, '23': 'DTR', '24': None, '25': GND},
     (13.2, -45.2), 0, 'usb', mpn='WCH CH9102F')
C('C2', '100nF', C0402, 'U2_V3', GND, (10.2, -47.9), 0, 'usb')
C('C3', '100nF', C0402, '3V3', GND, (16.2, -47.6), 90, 'usb')
C('C25', '100nF', C0402, 'VBUS', GND, (10.2, -42.6), 0, 'usb')
R('R3', '1k', R0402, 'U0TXD', 'U2_RXD', (17.0, -42.4), 0, 'usb')
R('R4', '1k', R0402, 'U2_TXD', 'U0RXD', (17.0, -43.6), 0, 'usb')
# UMH3N: Tr1 = E1 pin1, B1 pin2, C1 pin6; Tr2 = E2 pin4, B2 pin5, C2 pin3 (CJ datasheet).
part('Q1', 'UMH3N', 'UMH3N', 'SOT-363', 'C62892',
     {'2': 'DTR', '1': 'RTS', '6': 'ESP_EN', '5': 'RTS', '4': 'DTR', '3': 'BOOT'},
     (19.2, -45.4), 90, 'usb', mpn='UMH3N dual DTC143T')
part('LED1', 'LED', 'Red', 'LED_0603_EasyEDA', 'C2286', {'1': 'LED_A', '2': 'CHG_STAT'},
     (16.0, -48.3), 0, 'power', mpn='KENTO KT-0603R')
R('R8', '1k', R0402, 'VBUS', 'LED_A', (13.2, -48.6), 0, 'power')

# ---- Screen connector, backlight and peripheral power (bottom centre) ----
fpc = {'1': 'LCD_LEDK', '2': GND, '3': 'LCD_TE', '4': 'LCD_MOSI', '5': 'LCD_SCK', '6': 'LCD_DC',
       '7': 'LCD_CS', '8': 'LCD_RST', '9': '3V3_PERIPH', '10': '3V3_PERIPH', '11': '3V3_PERIPH',
       '12': GND, '13': GND, '14': 'LCD_LEDA', '15': 'LCD_LEDA', '16': GND, '17': GND}
part('J2', 'FPC15', 'FH35C-15S-0.3SHW(50)', 'FH35C-15S-0.3SHW', 'C2889267', fpc,
     (J2_XC - 1.71, J2_YC), 270, 'screen', mpn='Hirose FH35C-15S-0.3SHW(50)')
C('C19', '10uF', C0603, '3V3_PERIPH', GND, (-5.5, -33.4), 90, 'screen')
C('C20', '100nF', C0402, '3V3_PERIPH', GND, (-3.4, -34.4), 0, 'screen')
part('Q5', 'NMOS', 'AO3400A', 'SOT-23_AO3400A', 'C20917', {'1': 'BL_GATE', '2': GND, '3': 'LCD_LEDK'},
     (1.4, -33.6), 90, 'screen', mpn='AOS AO3400A')
R('R15', '100R', R0402, 'LCD_BL', 'BL_GATE', (4.0, -33.0), 90, 'screen')
R('R16', '100k', R0402, 'BL_GATE', GND, (4.0, -35.2), 90, 'screen')
R('R17', '10R', R1206, 'VSYS', 'LCD_LEDA', (-10.0, -22.5), 90, 'screen')
part('Q4', 'PMOS', 'AO3401A', 'SOT-23_AO3401A', 'C15127', {'1': 'PERIPH_GATE', '2': '3V3', '3': '3V3_PERIPH'},
     (-11.8, -16.6), 0, 'screen', mpn='AOS AO3401A')
R('R13', '100k', R0402, '3V3', 'PERIPH_GATE', (-14.4, -15.0), 0, 'screen')
R('R14', '10k', R0402, 'PERIPH_EN_N', 'PERIPH_GATE', (-14.4, -16.4), 0, 'screen')
C('C18', '100nF', C0402, 'PERIPH_GATE', '3V3', (-14.4, -17.8), 0, 'screen')

# ---- microSD (bottom left) ----
sd = {'1': 'SD_DAT2', '2': 'SD_CS', '3': 'SD_MOSI', '4': '3V3_PERIPH', '5': 'SD_SCK', '6': GND,
      '7': 'SD_MISO', '8': 'SD_DAT1', '9': GND, '11': 'SD_CD', '10': GND, '12': GND, '13': GND,
      '14': GND}
part('J3', 'MICROSD', 'DM3AT-SF-PEJM5', 'DM3AT-SF-PEJM5', 'C114218', sd,
     (-13.7 - 0.35, -49.1 + 8.31), 0, 'storage', mpn='Hirose DM3AT-SF-PEJM5')
C('C21', '10uF', C0603, '3V3_PERIPH', GND, (-8.6, -30.9), 0, 'storage')
C('C22', '100nF', C0402, '3V3_PERIPH', GND, (-11.3, -31.6), 0, 'storage')
R('R21', '10k', R0402, '3V3_PERIPH', 'SD_MISO', (-13.6, -31.6), 0, 'storage')
R('R22', '10k', R0402, '3V3_PERIPH', 'SD_CS', (-13.6, -30.4), 0, 'storage')
R('R23', '10k', R0402, '3V3_PERIPH', 'SD_DAT1', (-11.3, -30.4), 0, 'storage')
R('R24', '10k', R0402, '3V3_PERIPH', 'SD_DAT2', (-11.3, -29.2), 0, 'storage')
R('R25', '100k', R0402, '3V3', 'SD_CD', (-13.6, -29.2), 0, 'storage')

# ---- Processor ----
esp = {str(n): GND for n in [1, 2, 11, 14] + list(range(36, 54))}
esp.update({'3': '3V3', '4': 'VBUS_SENSE', '5': None, '6': 'SIDE_BTN', '7': 'LCD_TE', '8': 'ESP_EN',
            '9': 'TOUCH_IRQ', '10': 'VBAT_SENSE', '12': 'LCD_RST', '13': 'LCD_DC', '15': 'SD_CS',
            '16': 'LCD_CS', '17': 'LCD_MOSI', '18': 'LCD_SCK', '19': None, '20': 'PERIPH_EN_N',
            '21': 'SD_CD', '22': 'BUZZER', '23': 'BOOT', '24': 'LCD_BL', '25': None, '26': 'I2C_SCL',
            '27': 'GPIO7', '28': 'GPIO8', '29': 'SD_SCK', '30': 'U0RXD', '31': 'U0TXD', '32': None,
            '33': 'SD_MOSI', '34': 'I2C_SDA', '35': 'SD_MISO'})
part('U1', 'ESP32_PICO_MINI_02', 'ESP32-PICO-MINI-02-N8R2', 'ESP32-PICO-MINI-02', 'C2980306', esp,
     U1_ORIGIN, 90, 'mcu', mpn='Espressif ESP32-PICO-MINI-02-N8R2')
C('C5', '22uF', C0603, '3V3', GND, (19.4, -37.0), 0, 'mcu')
C('C6', '100nF', C0402, '3V3', GND, (17.6, -37.0), 90, 'mcu')
R('R5', '10k', R0402, '3V3', 'ESP_EN', (13.1, -38.0), 90, 'mcu')
C('C4', '1uF', C0402, 'ESP_EN', GND, (14.3, -38.0), 90, 'mcu')
R('R6', '10k', R0402, '3V3', 'BOOT', (12.4, -20.2), 0, 'mcu')
part('SW2', 'SW', 'BOOT', 'SW_TS-1088', 'C720477', {'1': 'BOOT', '2': GND}, (20.4, -13.4), 90, 'mcu',
     mpn='XKB TS-1088-AR02016')
part('SW3', 'SW', 'RESET', 'SW_TS-1088', 'C720477', {'1': 'ESP_EN', '2': GND}, (16.8, -13.4), 90, 'mcu',
     mpn='XKB TS-1088-AR02016')
R('R29', '100k', R0402, 'VBUS', 'VBUS_SENSE', (20.6, -40.0), 0, 'mcu')
R('R30', '150k', R0603, 'VBUS_SENSE', GND, (20.4, -41.6), 0, 'mcu')
R('R27', '1M', R0402, 'VBAT', 'VBAT_SENSE', (15.6, -37.9), 90, 'mcu')
R('R28', '1M', R0402, 'VBAT_SENSE', GND, (16.8, -40.5), 0, 'mcu')
C('C24', '100nF', C0402, 'VBAT_SENSE', GND, (16.8, -39.4), 0, 'mcu')
R('R31', '4.7k', R0402, '3V3', 'I2C_SDA', (16.6, -19.4), 0, 'mcu')
R('R32', '4.7k', R0402, '3V3', 'I2C_SCL', (14.6, -19.4), 0, 'mcu')

# ---- Power: battery, charger, load sharing, 3V3, fuel gauge (left) ----
part('J4', 'BATT', 'S2B-PH-SM4-TB', 'JST_PH_S2B-PH-SM4-TB', 'C54582899',
     {'1': GND, '2': 'BAT_P', '3': None, '4': None}, (-21.0, -14.93), 180, 'power',
     mpn='XYECONN XY-S2B-PH-SM4-TB (JST PH 2.0 side entry)')
part('Q2', 'PMOS', 'AO3401A', 'SOT-23_AO3401A', 'C15127', {'1': GND, '2': 'VBAT', '3': 'BAT_P'},
     (-15.2, -21.2), 0, 'power', mpn='AOS AO3401A')
C('C8', '10uF', C0603, 'VBAT', GND, (-15.4, -24.0), 90, 'power')
part('U3', 'MCP73831', 'MCP73831T-2ACI/OT', 'SOT-23-5_MCP73831', 'C424093',
     {'1': 'CHG_STAT', '2': GND, '3': 'VBAT', '4': 'VBUS', '5': 'CHG_PROG'},
     (-21.6, -22.4), 0, 'power', mpn='Microchip MCP73831T-2ACI/OT')
C('C7', '4.7uF', C0603, 'VBUS', GND, (-24.5, -21.8), 90, 'power')
R('R7', '2.7k', R0603, 'CHG_PROG', GND, (-18.6, -21.4), 90, 'power')
part('Q3', 'PMOS', 'AO3401A', 'SOT-23_AO3401A', 'C15127', {'1': 'VBUS', '2': 'VSYS', '3': 'VBAT'},
     (-17.6, -25.4), 270, 'power', mpn='AOS AO3401A')
R('R9', '100k', R0402, 'VBUS', GND, (-20.4, -25.0), 90, 'power')
part('D1', 'D', 'B5819W SL', 'SOD-123_B5819W', 'C8598', {'1': 'VSYS', '2': 'VBUS'},
     (-21.0, -27.6), 180, 'power', mpn='CJ B5819W SL')
C('C9', '22uF', C0805, 'VSYS', GND, (-25.6, -26.4), 90, 'power')
part('U4', 'RT9080', 'RT9080-33GJ5', 'TSOT-23-5_RT9080', 'C841192',
     {'1': 'VSYS', '2': GND, '3': 'VSYS', '4': None, '5': '3V3'}, (-19.0, -31.4), 180, 'power',
     mpn='Richtek RT9080-33GJ5')
C('C10', '1uF', C0402, 'VSYS', GND, (-16.6, -31.6), 90, 'power')
C('C11', '1uF', C0402, '3V3', GND, (-21.6, -31.6), 90, 'power')
part('U5', 'MAX17048', 'MAX17048G+T10', 'TDFN-8_2x2_P0.5_EP', 'C2682616',
     {'1': GND, '2': 'VBAT', '3': 'VBAT', '4': GND, '5': None, '6': GND, '7': 'I2C_SCL', '8': 'I2C_SDA',
      '9': GND}, (-25.0, -33.4), 90, 'power', mpn='Analog MAX17048G+T10')
C('C12', '1uF', C0402, 'VBAT', GND, (-23.0, -33.6), 90, 'power')

# ---- Touch wheel controller (centre) ----
mpr = {'1': 'TOUCH_IRQ', '2': 'I2C_SCL', '3': 'I2C_SDA', '4': '3V3', '5': 'MPR_VREG', '6': GND,
       '7': 'MPR_REXT', '8': 'ELE0', '9': 'ELE1', '10': 'ELE2', '11': 'ELE3', '12': 'ELE4',
       '13': 'ELE5', '14': 'ELE6', '15': 'ELE7', '16': 'ELE8', '17': None, '18': None, '19': None,
       '20': '3V3'}
part('U6', 'MPR121', 'MPR121QR2', 'QFN-20_3x3_P0.4', 'C91322', mpr, (0.0, -25.4), 0, 'touch',
     mpn='NXP MPR121QR2')
C('C13', '100nF', C0402, '3V3', GND, (-2.6, -23.4), 0, 'touch')
C('C14', '100nF', C0402, 'MPR_VREG', GND, (2.6, -23.4), 0, 'touch')
R('R10', '75k', R0603, 'MPR_REXT', GND, (2.8, -25.6), 90, 'touch')
R('R11', '10k', R0402, '3V3', 'TOUCH_IRQ', (-2.7, -26.6), 90, 'touch')
part('E1', 'WHEEL', 'Touch wheel', 'TouchWheel', '',
     {'C': 'ELE0', '1': 'ELE1', '2': 'ELE2', '3': 'ELE3', '4': 'ELE4', '5': 'ELE5', '6': 'ELE6',
      '7': 'ELE7', '8': 'ELE8'}, WHEEL_C, 0, 'touch', bom=False)

# ---- Haptics, buzzer, side button (top right / left) ----
part('U7', 'DRV2605L', 'DRV2605LDGSR', 'VSSOP-10_DRV2605L', 'C527464',
     {'1': 'HAPTIC_REG', '2': 'I2C_SCL', '3': 'I2C_SDA', '4': GND, '5': 'HAPTIC_EN', '6': 'VSYS',
      '7': 'MOTOR_P', '8': GND, '9': 'MOTOR_N', '10': 'VSYS'}, (-24.4, -37.6), 0, 'haptic',
     mpn='TI DRV2605LDGSR')
C('C15', '1uF', C0402, 'VSYS', GND, (-22.4, -35.4), 0, 'haptic')
C('C16', '100nF', C0402, 'VSYS', GND, (-22.4, -36.6), 0, 'haptic')
C('C17', '1uF', C0402, 'HAPTIC_REG', GND, (-26.2, -35.4), 90, 'haptic')
R('R12', '10k', R0402, '3V3', 'HAPTIC_EN', (-22.4, -40.0), 0, 'haptic')
part('M1', 'PAD', 'M+', 'MotorPad_2.0x1.5', '', {'1': 'MOTOR_P'}, MOTOR_PADS['M1'][1], 0, 'haptic', bom=False)
part('M2', 'PAD', 'M-', 'MotorPad_2.0x1.5', '', {'1': 'MOTOR_N'}, MOTOR_PADS['M2'][1], 0, 'haptic', bom=False)
part('BZ1', 'BUZZER', 'MLT-5020', 'Buzzer_MLT-5020', 'C94598', {'1': 'BZ_P', '2': 'BZ_N', '3': None},
     (7.6, -21.0), 0, 'haptic', mpn='Huawha MLT-5020')
part('D2', 'D', 'B5819W SL', 'SOD-123_B5819W', 'C8598', {'1': 'BZ_P', '2': 'BZ_N'}, (7.6, -17.0), 0,
     'haptic', mpn='CJ B5819W SL')
R('R18', '33R', R0805, 'VSYS', 'BZ_P', (3.4, -16.6), 0, 'haptic')
part('Q6', 'NMOS', 'AO3400A', 'SOT-23_AO3400A', 'C20917', {'1': 'BZ_GATE', '2': GND, '3': 'BZ_N'},
     (11.6, -21.6), 180, 'haptic', mpn='AOS AO3400A')
R('R19', '100R', R0402, 'BUZZER', 'BZ_GATE', (12.0, -24.6), 90, 'haptic')
R('R20', '100k', R0402, 'BZ_GATE', GND, (13.0, -24.6), 90, 'haptic')
part('SW1', 'SW3', 'SIDE', 'SW_SKRTLAE010', 'C110293', {'1': GND, '2': 'SIDE_BTN', '3': GND, '4': GND, '5': GND},
     (25.48, -15.6), 270, 'mcu', mpn='Alps SKRTLAE010')
R('R26', '100k', R0402, '3V3', 'SIDE_BTN', (22.2, -18.0), 0, 'mcu')
C('C23', '100nF', C0402, 'SIDE_BTN', GND, (22.2, -19.2), 0, 'mcu')

# ---- Test pads (L1, not assembled) ----
TESTPADS = [('TP1', '3V3', (-18.0, -34.6)), ('TP2', 'VSYS', (-16.2, -34.6)), ('TP3', 'VBAT', (-14.4, -34.6)),
            ('TP4', GND, (-27.0 + 1.0, -30.2)), ('TP5', 'U0TXD', (21.0, -43.2)),
            ('TP6', 'U0RXD', (20.0, -48.0)), ('TP7', 'GPIO7', (9.9, -13.0)), ('TP8', 'GPIO8', (9.9, -11.3)),
            ('TP9', 'I2C_SDA', (18.6, -19.4)), ('TP10', 'I2C_SCL', (12.4, -18.4))]
for ref, net, pos in TESTPADS:
    part(ref, 'TP', net, 'TestPoint_Pad_D1.0mm', '', {'1': net}, pos, 0, 'test', bom=False)

# ---- Electrode connection points (plated pads in E1) ----
# One per electrode, inside its sector and clear of the parts placed behind the wheel.
SECTOR_ANGLES = {i: 90.0 - 45.0 * (i - 1) for i in range(1, 9)}   # device math angles, CW from 12


def _polar(r, a):
    return (round(WHEEL_C[0] + r * math.cos(math.radians(a)), 3), round(WHEEL_C[1] + r * math.sin(math.radians(a)), 3))


ELECTRODE_VIAS = {'C': (0.6, -27.65),   # under U6, between its pad rows (no exposed pad)
                   '1': _polar(9.0, 90), '2': _polar(14.0, 40), '3': (8.1, -29.2),
                  '4': _polar(9.0, -45), '5': _polar(9.0, -90), '6': (-7.2, -31.9), '7': _polar(12.5, 180),
                  '8': _polar(12.0, 140)}

# GND stitching vias inside the wheel (the only foreign vias allowed there; electrodes clear them)
WHEEL_GND_VIAS = []

# ---- Placement: device (x, y) and KiCad orientation for every part (overrides the defaults above)
PLACE = {
    # USB-C, ESD, USB serial (bottom centre/right). U8 channel 1 = D-, channel 2 = D+ (no crossing).
    'J1': (0.0, -45.47, 0), 'U8': (7.0, -45.6, 270), 'U2': (11.9, -45.6, 90), 'C3': (8.0, -42.75, 0),
    'C2': (10.0, -42.65, 180), 'C25': (14.7, -42.7, 180), 'Q1': (16.6, -45.4, 0), 'R1': (10.5, -48.9, 0),
    'R3': (18.6, -46.4, 90), 'R4': (19.75, -46.4, 270), 'C1': (6.9, -48.5, 0),
    'R2': (-5.9, -43.6, 90), 'R8': (-5.9, -45.7, 90), 'LED1': (-5.9, -48.0, 90),
    # processor support below U1 (right of the ramp) and its strip above U1
    'C5': (18.6, -37.0, 0), 'C6': (20.9, -37.0, 90), 'R5': (16.5, -37.2, 90), 'C4': (16.5, -39.3, 90),
    'R27': (17.7, -39.3, 90), 'R28': (18.9, -39.3, 90), 'C24': (20.1, -39.3, 90), 'R29': (21.3, -39.3, 90),
    'R30': (19.6, -41.4, 0), 'R6': (12.6, -20.2, 0),
    # top right: side button, buzzer driver, I2C pull-ups
    'SW1': (25.48, -15.6, 270), 'SW2': (20.2, -13.5, 90), 'SW3': (20.2, -19.6, 90),
    'R26': (22.6, -13.2, 90), 'C23': (22.6, -15.4, 90), 'R31': (24.4, -19.3, 0), 'R32': (24.4, -20.5, 0),
    # behind the wheel (L1 only; GND through stitching vias)
    'BZ1': (-3.6, -21.6, 0), 'D2': (2.12, -20.3, 0), 'R18': (2.2, -22.5, 0), 'Q6': (7.2, -25.3, 0), 'R19': (9.6, -25.6, 90), 'R20': (7.2, -27.6, 0),
    'C14': (2.2, -24.9, 180), 'U6': (0.6, -27.4, 180), 'C13': (-2.2, -26.6, 90),
    'R11': (-2.4, -25.0, 0), 'R10': (3.6, -27.4, 270), 'Q5': (8.7, -34.7, 90), 'R15': (9.9, -37.5, 90),
    'R16': (10.9, -37.5, 90), 'C19': (-1.2, -33.6, 0), 'C20': (-0.9, -35.25, 0),
    # FPC leg area (parts up to 4.9 tall allowed)
    'Q4': (-11.9, -21.2, 0), 'R13': (-11.9, -23.8, 0), 'R14': (-11.9, -25.1, 0), 'C18': (-11.9, -26.4, 180),
    'R17': (-8.6, -26.4, 90),
    # microSD pull-ups and decoupling, one row above the J3 contacts
    # Pull-ups turned so the signal pin faces its J3 contact and the supply pin faces away; each supply pin
    # drops to an L3 bus through its own via (build_pcb.py), because the SD lines pass between the parts on L1.
    'R24': (-16.4, -31.3, 270), 'R22': (-15.3, -31.3, 270), 'C22': (-14.2, -31.3, 90), 'C21': (-12.8, -31.0, 90),
    'R21': (-11.2, -31.3, 270), 'R23': (-10.1, -31.3, 270), 'R25': (-9.0, -31.3, 270),
    # left column: battery, charger, load sharing, 3V3, fuel gauge
    'U3': (-24.6, -21.9, 0), 'Q2': (-19.8, -21.9, 0), 'C8': (-15.6, -21.4, 90), 'C7': (-25.4, -25.4, 90),
    'R7': (-23.0, -25.4, 90), 'Q3': (-19.8, -25.6, 0), 'R9': (-17.2, -23.9, 90), 'D1': (-15.6, -27.6, 0),
    'C9': (-19.8, -28.6, 0), 'U4': (-24.6, -29.0, 0), 'C10': (-22.3, -28.6, 90), 'C11': (-22.3, -30.8, 90),
    'U5': (-19.8, -31.2, 0), 'C12': (-17.7, -31.2, 270),
    # left strip: haptic driver and motor pads
    'U7': (-25.2, -38.7, 0), 'R12': (-22.6, -36.4, 90), 'C17': (-22.6, -38.4, 90), 'C15': (-25.9, -42.6, 0),
    'C16': (-23.9, -42.6, 0), 'M1': (-22.2, -40.9, 90), 'M2': (-22.2, -43.2, 90),
    # test pads
    'TP1': (-15.4, -11.4, 0), 'TP2': (-15.4, -13.6, 0), 'TP3': (-15.4, -15.8, 0), 'TP4': (-15.4, -18.0, 0),
    'TP5': (17.0, -48.5, 0), 'TP6': (19.2, -48.5, 0), 'TP7': (14.8, -21.0, 0), 'TP8': (16.9, -21.0, 0),
    'TP9': (12.5, -15.4, 0), 'TP10': (14.7, -15.4, 0),
}
for _p in PARTS:
    if _p['ref'] in PLACE:
        _x, _y, _r = PLACE[_p['ref']]
        _p['pos'], _p['rot'] = (_x, _y), _r

# L3 lies about 0.1 mm behind the L4 electrodes with no ground between them, so a track there couples
# into the electrode above it (about 0.5 pF per 10 mm of 0.15 mm track) and every edge on it can shift
# an MPR121 reading by as much as a touch (NXP AN3863: other signals on the far side of the ground
# layer). Inside the electrode disc plus 0.5 mm (WHEEL_KEEPOUT_R) only these nets may run on L3 or
# place vias: supplies, DC levels and lines that are static while the MPR121 scans (straps, reset,
# enables, card detect, the side button, the touch interrupt, the charge status, sense dividers).
DISC_L3_NETS = ['GND', 'VBUS', 'VSYS', 'VBAT', 'BAT_P', '3V3', '3V3_PERIPH', 'LCD_LEDA', 'LCD_RST',
                'PERIPH_EN_N', 'PERIPH_GATE', 'SD_CD', 'SIDE_BTN', 'TOUCH_IRQ', 'BOOT', 'ESP_EN', 'CHG_STAT',
                'VBAT_SENSE', 'VBUS_SENSE']
# The electrode lines may use L3 too (SPEC 6: "route the electrode traces on L3 or L1"); a via on an
# electrode line is one more connection point of that line.
WHEEL_TOLERANT_NETS = DISC_L3_NETS + ['ELE%d' % i for i in range(9)]
# Every other net (SPI, I2C, the screen's DC/CS/TE, the card's CS, buzzer, backlight PWM and LEDK, UART,
# USB) crosses the disc on L1 only, behind the L2 hatch, or goes around it. Freerouting phase S routes
# those nets first with the disc as a keep-out on L3 and for vias; phase P then routes PHASE_A_NETS.
PHASE_A_NETS = WHEEL_TOLERANT_NETS
# Nets that must have no L3 track inside the disc (the list checked by verify.py; it is a subset of
# the nets above that are not in WHEEL_TOLERANT_NETS).
# The touch review allows up to three slow nets a short L3 crossing near the disc edge (r > 14). The
# routers and verify.py support it through this list; no net uses it so far (README, "Touch wheel").
DISC_EDGE_CROSS_NETS = []
DISC_EDGE_CROSS_R = 14.0
DISC_EDGE_CROSS_MAX_MM = 3.0
# Step C of the touch-wheel re-route (2026-11-17): the checked routing in routing-final.json predates the
# touch review, and the re-route to the full rule (steps A and B) did not close. These listed nets keep
# their L3 track and vias inside r 17.1 as accepted exceptions. Each cap is the measured value of that
# routing (L3 mm inside r 17.1, vias centred inside r 17.1), so a later re-route can only lower it;
# verify.py fails on any increase and on any other listed net on L3 there.
DISC_L3_ACCEPTED = {'I2C_SDA': (36.31, 2), 'LCD_DC': (23.06, 6), 'LCD_TE': (22.90, 4), 'SD_CS': (12.75, 10),
                    'LCD_CS': (11.85, 2), 'I2C_SCL': (7.03, 2), 'BZ_GATE': (4.08, 3)}
# VBUS from J1 to D1 and to U3 VIN (step C): accepted with a 0.2 mm bottleneck. The caps are the
# measured length of track narrower than 0.4 mm on the path with the least such track, by layer and width,
# after widening in place (no L3 track at 0.2 mm is left on these paths). Pin neck-downs are not counted.
VBUS_PATH_ACCEPTED = {'min_width': 0.2, 'max_mm': {'L1 0.20': 9.58, 'L1 0.30': 22.67, 'L3 0.30': 13.89}}
DISC_L3_FORBIDDEN = ['I2C_SDA', 'I2C_SCL', 'LCD_DC', 'LCD_CS', 'LCD_TE', 'SD_CS', 'BZ_GATE', 'LCD_SCK',
                     'LCD_MOSI', 'SD_SCK', 'SD_MOSI', 'SD_MISO', 'LCD_BL', 'LCD_LEDK']

# Nets with a wider class
POWER_NETS = ['VBUS', 'VSYS', 'VBAT', 'BAT_P', '3V3', '3V3_PERIPH', 'LCD_LEDA', 'LCD_LEDK', GND]
USB_NETS = ['USB_DP', 'USB_DN']


def part_by_ref(ref):
    for p in PARTS:
        if p['ref'] == ref:
            return p
    raise KeyError(ref)


def all_nets():
    s = set()
    for p in PARTS:
        for n in p['pins'].values():
            if n:
                s.add(n)
    return sorted(s)


if __name__ == '__main__':
    import json
    nets = {}
    for p in PARTS:
        for pad, n in p['pins'].items():
            if n:
                nets.setdefault(n, []).append(p['ref'] + '.' + pad)
    single = {n: v for n, v in nets.items() if len(v) < 2}
    print(len(PARTS), 'parts', len(nets), 'nets; single-pin nets:', single)
    print('outline points', len(board_outline()))
