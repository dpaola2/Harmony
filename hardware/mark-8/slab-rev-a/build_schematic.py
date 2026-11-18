"""Generate the Mark-8 slab schematic, symbol library and project files from design.py.

One A2 sheet, grouped by block. Components connect through net labels on short wire stubs.
All symbol pins are passive: the schematic documents connectivity; drivers are checked in the
README power and pin-map tables, not by ERC pin typing.
"""
import json
import uuid
from design import *

ROOT = str(uuid.uuid5(uuid.NAMESPACE_URL, 'harmony/mark8/slab/a'))
G = 1.27


def uid(text):
    return str(uuid.uuid5(uuid.UUID(ROOT), text))


def q(text):
    return json.dumps(str(text))


def n(value):
    return ('%.4f' % value).rstrip('0').rstrip('.')


def snap(value):
    return round(value / G) * G


def eff(size=1.27, extra=''):
    return '(effects (font (size %s %s)) %s)' % (n(size), n(size), extra)


SYMBOLS = {}   # name -> dict(text, pins{num: (x, y, angle)}, box(x0,y0,x1,y1) symbol coords, ref)


def pin(num, name, x, y, angle, length=2.54, hide_name=False):
    return ('(pin passive line (at %s %s %d) (length %s) (name %s %s) (number %s %s))'
            % (n(x), n(y), angle, n(length), q(name), eff(1.0), q(num), eff(1.0)))


def define(name, ref, graphics, pins, box, hide_pin_names=False):
    pins_txt = ''.join(pin(*p_) for p_ in pins)
    opts = '(pin_names (offset 0.508)%s)' % (' hide' if hide_pin_names else '')
    numbers = '(pin_numbers hide)' if hide_pin_names else ''
    text = ('(symbol %s %s %s (in_bom yes) (on_board yes)\n'
            '  (property "Reference" %s (at 0 %s 0) %s)\n'
            '  (property "Value" %s (at 0 %s 0) %s)\n'
            '  (property "Footprint" "" (at 0 0 0) %s)\n'
            '  (property "Datasheet" "" (at 0 0 0) %s)\n'
            '  (symbol %s %s)\n  (symbol %s %s))'
            % (q(name), opts, numbers, q(ref), n(box[3] + 2.54), eff(), q(name), n(box[1] - 2.54), eff(),
               eff(1.27, '(hide yes)'), eff(1.27, '(hide yes)'), q(name + '_0_1'), graphics,
               q(name + '_1_1'), pins_txt))
    SYMBOLS[name] = dict(text=text, pins={p_[0]: (p_[2], p_[3], p_[4], p_[5] if len(p_) > 5 else 2.54) for p_ in pins},
                         box=box, ref=ref)


def rect(x0, y0, x1, y1, fill='background'):
    return ('(rectangle (start %s %s) (end %s %s) (stroke (width 0.254) (type default)) (fill (type %s)))'
            % (n(x0), n(y0), n(x1), n(y1), fill))


def poly(points, width=0.254, fill='none'):
    return ('(polyline (pts %s) (stroke (width %s) (type default)) (fill (type %s)))'
            % (' '.join('(xy %s %s)' % (n(x), n(y)) for x, y in points), n(width), fill))


def box(name, ref, left, right):
    """Box symbol: left/right = [(number, pin name)]; pins every 2.54, ends on the 1.27 grid."""
    rows = max(len(left), len(right))
    top = G * (rows + 1)
    chars = max([len(nm) for _, nm in left] + [0]) + max([len(nm) for _, nm in right] + [0])
    half = max(5.08, round((chars * 0.85 + 4) / 2 / 2.54) * 2.54)
    pins = []
    for i, (num, nm) in enumerate(left):
        pins.append((num, nm, -half - 2.54, top - 2.54 * (i + 1), 0))
    for i, (num, nm) in enumerate(right):
        pins.append((num, nm, half + 2.54, top - 2.54 * (i + 1), 180))
    define(name, ref, rect(-half, -top, half, top), pins, (-half, -top, half, top))


# Small symbols
define('R', 'R', rect(-1.016, -2.54, 1.016, 2.54, 'none'),
       [('1', '~', 0, 3.81, 270, 1.27), ('2', '~', 0, -3.81, 90, 1.27)], (-1.016, -2.54, 1.016, 2.54), True)
define('C', 'C', poly([(-2.032, 0.635), (2.032, 0.635)], 0.4) + poly([(-2.032, -0.635), (2.032, -0.635)], 0.4),
       [('1', '~', 0, 3.81, 270, 3.175), ('2', '~', 0, -3.81, 90, 3.175)], (-2.032, -1.27, 2.032, 1.27), True)
define('D', 'D', poly([(-1.27, 1.27), (-1.27, -1.27), (1.27, 0), (-1.27, 1.27)], 0.254, 'outline') +
       poly([(1.27, 1.27), (1.27, -1.27)]),
       [('2', 'A', -3.81, 0, 0, 2.54), ('1', 'K', 3.81, 0, 180, 2.54)], (-1.27, -1.27, 1.27, 1.27), True)
define('LED', 'LED', poly([(-1.27, 1.27), (-1.27, -1.27), (1.27, 0), (-1.27, 1.27)], 0.254, 'outline') +
       poly([(1.27, 1.27), (1.27, -1.27)]) + poly([(0, 1.524), (0.762, 2.286)]) + poly([(0.762, 1.524), (1.524, 2.286)]),
       [('1', 'A', -3.81, 0, 0, 2.54), ('2', 'K', 3.81, 0, 180, 2.54)], (-1.27, -1.27, 1.27, 2.286), True)
for kind in ('NMOS', 'PMOS'):
    g = poly([(-1.27, -1.905), (-1.27, 1.905)]) + poly([(-0.635, -2.032), (-0.635, 2.032)]) + \
        poly([(-0.635, 1.27), (1.27, 1.27), (1.27, 2.54)]) + poly([(-0.635, -1.27), (1.27, -1.27), (1.27, -2.54)]) + \
        poly([(-0.635, 0), (1.27, 0), (1.27, -1.27)])
    if kind == 'NMOS':
        pins = [('1', 'G', -3.81, 0, 0, 2.54), ('3', 'D', 1.27, 3.81, 270, 1.27), ('2', 'S', 1.27, -3.81, 90, 1.27)]
    else:
        pins = [('1', 'G', -3.81, 0, 0, 2.54), ('2', 'S', 1.27, 3.81, 270, 1.27), ('3', 'D', 1.27, -3.81, 90, 1.27)]
    define(kind, 'Q', g + '(text %s (at 2.54 0 0) %s)' % (q('N' if kind == 'NMOS' else 'P'), eff(1.0)), pins,
           (-1.27, -2.54, 1.27, 2.54), True)
define('SW', 'SW', poly([(-1.27, 0), (1.27, 1.016)]) + poly([(0, 1.016), (0, 2.032)]),
       [('1', '1', -3.81, 0, 0, 2.54), ('2', '2', 3.81, 0, 180, 2.54)], (-1.27, -0.5, 1.27, 2.032), True)
define('TP', 'TP', '(circle (center 0 1.016) (radius 0.762) (stroke (width 0.254) (type default)) (fill (type none)))',
       [('1', '1', 0, -1.27, 90, 1.524)], (-0.762, 0, 0.762, 1.778), True)
define('PAD', 'M', rect(-1.27, 0.254, 1.27, 1.778),
       [('1', '1', 0, -1.27, 90, 1.524)], (-1.27, 0, 1.27, 1.778), True)


box('ESP32_PICO_MINI_02', 'U',
    [('3', '3V3'), ('8', 'EN'), ('23', 'IO0'), ('31', 'TXD0/IO1'), ('30', 'RXD0/IO3'), ('18', 'IO14'),
     ('17', 'IO27'), ('16', 'IO26'), ('13', 'IO33'), ('12', 'IO32'), ('24', 'IO4'), ('7', 'I39'),
     ('19', 'IO12'), ('5', 'I37'), ('25', 'NC'), ('32', 'NC')],
    [('29', 'IO5'), ('33', 'IO19'), ('35', 'IO21'), ('15', 'IO25'), ('21', 'IO15'), ('34', 'IO22'),
     ('26', 'IO20'), ('9', 'I34'), ('6', 'I38'), ('20', 'IO13'), ('22', 'IO2'), ('10', 'I35'), ('4', 'I36'),
     ('27', 'IO7'), ('28', 'IO8')] + [(str(k), 'GND') for k in [1, 2, 11, 14] + list(range(36, 54))])
box('CH9102F', 'U', [('7', 'VDD5'), ('8', 'VBUS'), ('6', 'V3'), ('5', 'VIO'), ('3', 'UD+'), ('4', 'UD-'),
                     ('2', 'GND'), ('25', 'EP')],
    [('20', 'RXD'), ('21', 'TXD'), ('23', 'DTR'), ('19', 'RTS'), ('9', 'RST'), ('18', 'CTS'), ('22', 'DSR'),
     ('1', 'RI'), ('24', 'DCD'), ('10', 'ACT'), ('15', 'SUSP#'), ('17', 'SUSP'), ('11', 'GPIO3'), ('12', 'GPIO2'),
     ('13', 'GPIO1'), ('14', 'GPIO0'), ('16', 'GPIO4')])
box('USB_C', 'J', [('A4B9', 'VBUS'), ('B4A9', 'VBUS'), ('A6', 'D+'), ('B6', 'D+'), ('A7', 'D-'), ('B7', 'D-'),
                   ('A5', 'CC1'), ('B5', 'CC2')],
    [('A8', 'SBU1'), ('B8', 'SBU2'), ('A1B12', 'GND'), ('B1A12', 'GND'), ('1', 'SHIELD'), ('2', 'SHIELD'),
     ('3', 'SHIELD'), ('4', 'SHIELD')])
box('USBLC6', 'U', [('1', 'I/O1'), ('3', 'I/O2'), ('5', 'VBUS')], [('6', 'I/O1'), ('4', 'I/O2'), ('2', 'GND')])
box('UMH3N', 'Q', [('2', 'B1'), ('1', 'E1'), ('6', 'C1')], [('5', 'B2'), ('4', 'E2'), ('3', 'C2')])
box('MCP73831', 'U', [('4', 'VDD'), ('5', 'PROG'), ('2', 'VSS')], [('3', 'VBAT'), ('1', 'STAT')])
box('RT9080', 'U', [('1', 'VIN'), ('3', 'EN'), ('2', 'GND')], [('5', 'VOUT'), ('4', 'NC')])
box('MAX17048', 'U', [('2', 'CELL'), ('3', 'VDD'), ('1', 'CTG'), ('6', 'QSTRT'), ('4', 'GND'), ('9', 'EP')],
    [('8', 'SDA'), ('7', 'SCL'), ('5', 'ALRT')])
box('MPR121', 'U', [('20', 'VDD'), ('5', 'VREG'), ('7', 'REXT'), ('4', 'ADDR'), ('3', 'SDA'), ('2', 'SCL'),
                    ('1', 'IRQ'), ('6', 'VSS')],
    [('8', 'ELE0'), ('9', 'ELE1'), ('10', 'ELE2'), ('11', 'ELE3'), ('12', 'ELE4'), ('13', 'ELE5'), ('14', 'ELE6'),
     ('15', 'ELE7'), ('16', 'ELE8'), ('17', 'ELE9'), ('18', 'ELE10'), ('19', 'ELE11')])
box('WHEEL', 'E', [('C', 'CENTRE')], [(str(i), 'SECTOR%d' % i) for i in range(1, 9)])
box('DRV2605L', 'U', [('10', 'VDD'), ('6', 'VDD/NC'), ('1', 'REG'), ('5', 'EN'), ('4', 'IN/TRIG'), ('8', 'GND')],
    [('3', 'SDA'), ('2', 'SCL'), ('7', 'OUT+'), ('9', 'OUT-')])
box('FPC15', 'J', [(str(i), nm) for i, nm in enumerate(['LEDK', 'GND', 'FMARK', 'SDA', 'SCLK', 'RS', 'CS', 'RESET'], 1)],
    [(str(i), nm) for i, nm in enumerate(['IOVCC', 'VCC', 'VCC', 'GND', 'GND', 'LEDA', 'LEDA'], 9)] +
    [('16', 'MOUNT'), ('17', 'MOUNT')])
box('MICROSD', 'J', [('1', 'DAT2'), ('2', 'DAT3/CS'), ('3', 'CMD'), ('4', 'VDD'), ('5', 'CLK'), ('6', 'VSS'),
                     ('7', 'DAT0'), ('8', 'DAT1')],
    [('11', 'CD_A'), ('9', 'CD_B'), ('10', 'SHELL'), ('12', 'SHELL'), ('13', 'SHELL'), ('14', 'SHELL')])
box('BATT', 'J', [('2', '+'), ('1', '-')], [('3', 'MOUNT'), ('4', 'MOUNT')])
box('BUZZER', 'BZ', [('1', '+'), ('2', '-')], [('3', 'NC')])
box('SW3', 'SW', [('2', 'COM'), ('1', 'NO1')], [('3', 'NO2'), ('4', 'MOUNT'), ('5', 'MOUNT')])

BLOCKS = [
    ('usb', 'USB-C, ESD, USB SERIAL, AUTO-RESET', (15, 30)),
    ('mcu', 'PROCESSOR, BOOT/RESET, SENSE, SIDE BUTTON', (15, 150)),
    ('power', 'BATTERY, CHARGER, LOAD SHARING, 3V3, FUEL GAUGE', (205, 30)),
    ('screen', 'SCREEN CONNECTOR, BACKLIGHT, PERIPHERAL POWER', (205, 150)),
    ('storage', 'MICROSD (SPI)', (205, 245)),
    ('touch', 'TOUCH WHEEL (MPR121 + 9 ELECTRODES ON L4)', (400, 30)),
    ('haptic', 'HAPTICS, CLICK BUZZER', (400, 150)),
    ('test', 'TEST PADS (L1, NOT ASSEMBLED)', (400, 290)),
]
BLOCK_W = {'usb': 185, 'mcu': 185, 'power': 190, 'screen': 190, 'storage': 190, 'touch': 185,
           'haptic': 185, 'test': 185}

items = []
placed = {}


def text(content, x, y, size=1.27, bold=False):
    extra = '(justify left top)' + (' bold' if False else '')
    items.append('(text %s (exclude_from_sim no) (at %s %s 0) %s (uuid %s))'
                 % (q(content), n(x), n(y), eff(size, '(justify left top)'), q(uid('t' + content + n(x) + n(y)))))


def label(net, x, y, side):
    just = 'right' if side == 'left' else 'left'
    items.append('(label %s (at %s %s 0) %s (uuid %s))'
                 % (q(net), n(x), n(y), eff(1.0, '(justify %s bottom)' % just), q(uid('l%s%s%s' % (net, n(x), n(y))))))


def wire(x0, y0, x1, y1):
    items.append('(wire (pts (xy %s %s) (xy %s %s)) (stroke (width 0) (type default)) (uuid %s))'
                 % (n(x0), n(y0), n(x1), n(y1), q(uid('w%s%s%s%s' % (n(x0), n(y0), n(x1), n(y1))))))


def place_symbol(prt, x, y):
    s = SYMBOLS[prt['sym']]
    x, y = snap(x), snap(y)
    fp = (LIBNAME + ':' + prt['fp']) if prt['fp'] else ''
    props = '(property "Reference" %s (at %s %s 0) %s)' % (q(prt['ref']), n(x + s['box'][2] + 1.0), n(y - s['box'][3] - 1.5), eff(1.27, '(justify left)'))
    props += '(property "Value" %s (at %s %s 0) %s)' % (q(prt['value']), n(x + s['box'][2] + 1.0), n(y - s['box'][3]), eff(1.0, '(justify left)'))
    props += '(property "Footprint" %s (at %s %s 0) %s)' % (q(fp), n(x), n(y), eff(1.27, '(hide yes)'))
    props += '(property "Datasheet" "" (at %s %s 0) %s)' % (n(x), n(y), eff(1.27, '(hide yes)'))
    props += '(property "LCSC" %s (at %s %s 0) %s)' % (q(prt['lcsc']), n(x), n(y), eff(1.27, '(hide yes)'))
    props += '(property "MPN" %s (at %s %s 0) %s)' % (q(prt['mpn']), n(x), n(y), eff(1.27, '(hide yes)'))
    bom = 'yes' if prt['bom'] else 'no'
    items.append('(symbol (lib_id %s) (at %s %s 0) (unit 1) (exclude_from_sim no) (in_bom %s) (on_board yes) (dnp no) (uuid %s) %s '
                 '(instances (project %s (path %s (reference %s) (unit 1)))))'
                 % (q(LIBNAME + ':' + prt['sym']), n(x), n(y), bom, q(uid(prt['ref'])), props, q(NAME), q('/' + ROOT), q(prt['ref'])))
    assert set(prt['pins']) == set(s['pins']), (prt['ref'], set(prt['pins']) ^ set(s['pins']))
    for num, (px, py, ang, ln) in s['pins'].items():
        sx, sy = x + px, y - py
        net = prt['pins'][num]
        if net is None:
            items.append('(no_connect (at %s %s) (uuid %s))' % (n(sx), n(sy), q(uid(prt['ref'] + num + 'nc'))))
            continue
        if ang == 0:
            ex, ey, side = sx - 2.54, sy, 'left'
        elif ang == 180:
            ex, ey, side = sx + 2.54, sy, 'right'
        elif ang == 270:
            ex, ey, side = sx, sy - 2.54, 'right'
        else:
            ex, ey, side = sx, sy + 2.54, 'right'
        wire(sx, sy, ex, ey)
        label(net, ex, ey, side)
    placed[prt['ref']] = (x, y)


def footprint_extent(prt):
    """Width/height a symbol plus its labels needs on the sheet (mm)."""
    s = SYMBOLS[prt['sym']]
    x0, y0, x1, y1 = s['box']
    lab = max([len(nt) for nt in prt['pins'].values() if nt] + [3]) * 1.05 + 4
    xs = [px for px, py, a, l in s['pins'].values()]
    ys = [py for px, py, a, l in s['pins'].values()]
    left = min(x0, min(xs)) - (lab if any(a == 0 for _, _, a, _ in s['pins'].values()) else 0)
    right = max(x1, max(xs)) + lab + 10
    top = max(y1, max(ys)) + 6
    bot = min(y0, min(ys)) - 4
    return left, right, top, bot


for key, title, (bx, by) in BLOCKS:
    members = [prt for prt in PARTS if prt['block'] == key]
    text(title, bx, by - 8, 2.0)
    x, y, row_h = bx, by, 0
    for prt in members:
        left, right, top, bot = footprint_extent(prt)
        w, h = right - left, top - bot
        if x + w > bx + BLOCK_W[key] and x > bx:
            x, y, row_h = bx, y + row_h + 4, 0
        place_symbol(prt, x - left, y + top)
        x += w + 2
        row_h = max(row_h, h)

text('HARMONY MARK-8 SLAB / REV A / generated by build_schematic.py from design.py - do not hand-edit', 15, 12, 2.5)
notes = ('Device coordinates and placement: design.py. Pin map: SPEC.md 5.3.\n'
         'J4 polarity: pin 2 = +, pin 1 = -, silkscreen + and - beside the pads.\n'
         'Q2 reverse-battery PMOS, Q3 load sharing (off while VBUS is present), D1 VBUS to VSYS.\n'
         'U2 VDD5 from VBUS, VIO from 3V3 (WCH dual-supply scheme): no battery current, no back-feed.\n'
         'SD pull-ups go to 3V3_PERIPH; SD_CD pull-up goes to 3V3 (GPIO15 is a strapping pin).\n'
         'E1 electrodes: copper zones on L4 (B.Cu) drawn by build_pcb.py; E1 pads are their plated connections.')
text(notes, 400, 330, 1.27)

lib_text = '\n'.join(s['text'].replace('(symbol %s' % q(nm), '(symbol %s' % q(nm), 1) for nm, s in SYMBOLS.items())
cache = '\n'.join(s['text'].replace('(symbol %s' % q(nm), '(symbol %s' % q(LIBNAME + ':' + nm), 1) for nm, s in SYMBOLS.items())
sch = ('(kicad_sch (version 20231120) (generator "eeschema") (generator_version "8.0") (uuid %s) (paper "A2")\n'
       '(title_block (title "Harmony Mark-8 slab") (date "2026-11-17") (rev "A") (company "Harmony")'
       ' (comment 1 "Generated from design.py"))\n(lib_symbols %s)\n%s\n'
       '(sheet_instances (path "/" (page "1"))))\n') % (q(ROOT), cache, '\n'.join(items))
(HERE / (NAME + '.kicad_sch')).write_text(sch)
(LIBDIR / (LIBNAME + '.kicad_sym')).write_text('(kicad_symbol_lib (version 20231120) (generator "kicad_symbol_editor") (generator_version "8.0")\n'
                                              + lib_text + ')\n')
(HERE / 'sym-lib-table').write_text('(sym_lib_table\n  (version 7)\n  (lib (name "%s")(type "KiCad")(uri "${KIPRJMOD}/lib/%s.kicad_sym")(options "")(descr "Mark-8 slab symbols"))\n)\n' % (LIBNAME, LIBNAME))
print('schematic:', len(placed), 'symbols placed')
