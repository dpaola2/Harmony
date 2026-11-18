#!/usr/bin/env python3
"""Host checks for firmware/mark-8 (slab bring-up and slab player).

Runs every C host test under address and undefined-behaviour sanitizers,
checks the firmware against the hardware sources (pin map, wheel geometry,
MPR121 values, ST7365P vendor init), renders the 320 x 320 previews to
preview/*.png, checks that both build scripts refuse to flash, and writes
verification.json. No hardware, no flashing, no git writes.

    python3 firmware/mark-8/tests/verify.py
"""
from pathlib import Path
import datetime
import hashlib
import json
import math
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import zlib

M8 = Path(__file__).resolve().parents[1]
FW = M8.parent
REPO = FW.parent
HW = REPO / 'hardware/mark-8/slab-rev-a'
ENC = REPO / 'enclosure/mark-8/slab-rev-a'
SHARED = FW / 'mark-6/feather-carrier/main'
FONT = FW / 'mark-6/components/bench_display'
PREVIEW = M8 / 'preview'
CC = '/usr/bin/cc' if Path('/usr/bin/cc').exists() else shutil.which('cc')
FLAGS = [CC, '-O1', '-std=gnu11', '-Wall', '-Wextra', '-Werror', '-Wno-unused-parameter',
         '-fsanitize=address,undefined', '-fno-sanitize-recover=all', '-pthread']
B = M8 / 'components/slab_board'
T = M8 / 'components/slab_touch'
S = M8 / 'components/st7365p'
P = M8 / 'slab-player/main'
U = M8 / 'slab-bringup/main'
passes, checks, numbers = [], [], {}


def ok(message):
    checks.append(message)
    print('PASS ' + message)


def run_c(tmp, name, sources, includes, defines=(), args=()):
    exe = tmp / name
    cmd = FLAGS + ['-D' + d for d in defines] + ['-I' + str(i) for i in includes] + [str(s) for s in sources]
    subprocess.run(cmd + ['-lm', '-o', str(exe)], check=True)
    out = subprocess.run([str(exe), *map(str, args)], check=True, capture_output=True, text=True).stdout
    for line in out.splitlines():
        if line.startswith('PASS'):
            passes.append(line[5:])
            print(line)
    return out


# ---------------------------------------------------------------- pin map
def table_rows(text, heading):
    section = text.split(heading, 1)[1]
    rows, started = [], False
    for line in section.splitlines()[1:]:
        if line.startswith('|'):
            started = True
            rows.append([c.strip() for c in line.strip().strip('|').split('|')])
        elif started:
            break
    return rows[2:]   # skip the header and the separator


def check_pins():
    header = (B / 'include/slab_pins.h').read_text()
    pins = {name: int(v) for name, v in re.findall(r'#define SLAB_PIN_(\w+)\s+(\d+)', header)}
    readme = (HW / 'README.md').read_text()
    spec = (HW / 'SPEC.md').read_text()
    built = {r[2]: int(r[0]) for r in table_rows(readme, '## ESP32 pin map') if re.fullmatch(r'\d+', r[0])}
    specmap = {r[1]: int(r[0]) for r in table_rows(spec, '### 5.3 ESP32 pin map') if re.fullmatch(r'\d+', r[0])}
    assert len(pins) == 20, pins
    for name, gpio in pins.items():
        assert built.get(name) == gpio, (name, gpio, built.get(name))
        assert specmap.get(name) == gpio, (name, gpio, specmap.get(name))
    missing = set(built) - set(pins) - {'BOOT'}
    assert not missing, missing
    for name in ('LCD_TE', 'TOUCH_IRQ', 'SIDE_BTN', 'VBAT_SENSE', 'VBUS_SENSE'):
        assert pins[name] >= 34, name   # input-only pins carry only inputs
    addrs = {n: int(v, 16) for n, v in re.findall(r'#define SLAB_I2C_ADDR_(\w+)\s+(0x[0-9A-Fa-f]+)', header)}
    for part, key in (('MAX17048', 'MAX17048'), ('MPR121', 'MPR121'), ('DRV2605', 'DRV2605L')):
        line = next(l for l in spec.splitlines() if l.startswith('| U') and part in l)
        assert int(re.search(r'I2C (0x[0-9A-Fa-f]{2})', line)[1], 16) == addrs[key], (part, line)
    vbat = re.search(r'VBAT through (\d+) ?M / (\d+) ?M', spec)
    vbus = re.search(r'VBUS through (\d+) ?k / (\d+) ?k', spec)
    ratio = lambda top, bottom: round((top + bottom) / bottom * 1000)
    assert ratio(int(vbat[1]), int(vbat[2])) == int(re.search(r'SLAB_VBAT_DIVIDER_X1000 (\d+)', header)[1])
    assert ratio(int(vbus[1]), int(vbus[2])) == int(re.search(r'SLAB_VBUS_DIVIDER_X1000 (\d+)', header)[1])
    ok('pin map: all 20 slab_pins.h GPIOs match the hardware README "ESP32 pin map" and SPEC 5.3; every '
       'peripheral net is covered; input-only pins carry inputs; I2C addresses and both dividers match SPEC')


# ---------------------------------------------------------------- wheel geometry
def check_wheel_geometry():
    design = (HW / 'design.py').read_text()
    expr = re.search(r'SECTOR_ANGLES = \{i: ([^}]+) for i in range\(1, 9\)\}', design)[1]
    assert re.fullmatch(r'[\d.\s*()+\-i]+', expr), expr
    sector = {i: eval(expr, {'__builtins__': {}}, {'i': i}) for i in range(1, 9)}
    mapping = re.search(r"part\('E1'.*?\{('C': 'ELE0'.*?)\}", design, re.S)[1]
    pairs = dict(re.findall(r"'(\w)': 'ELE(\d)'", mapping))
    assert pairs['C'] == '0' and all(pairs[str(i)] == str(i) for i in range(1, 9))
    wheel_c = (T / 'wheel.c').read_text()
    fw = [float(v) for v in re.search(r'sector_deg\[WHEEL_ELECTRODES\] = \{([^}]+)\}', wheel_c)[1].split(',')]
    wrap = lambda a: (a + 180.0) % 360.0 - 180.0 if (a + 180.0) % 360.0 else 180.0
    for i in range(1, 9):
        assert abs(wrap(fw[i] - sector[i])) < 1e-6, (i, fw[i], sector[i])
    readme = (HW / 'README.md').read_text()
    centroids = re.search(r'Sector centroid angles \(deg\) \| ([^|]+)\|', readme)[1]
    for e, angle in re.findall(r'(\d) (-?[\d.]+)', centroids):
        assert abs(wrap(float(angle) - fw[int(e)])) < 1.0, (e, angle)
    spec = (HW / 'SPEC.md').read_text()
    assert 'ELE0 = center, ELE1 to ELE8 = ring sectors clockwise from 12 o\'clock as seen from the front' in spec
    clock = {'12': 90.0, '3': 0.0, '6': -90.0, '9': 180.0}
    labels = re.search(r'HOME at the top \(12 o\'clock\), previous at 9 o\'clock, next at 3 o\'clock, play/pause at 6 o\'clock', spec)
    assert labels
    zones = dict((z, float(a)) for a, z in re.findall(r'\{(-?\d+), WHEEL_ZONE_(\w+)\}', wheel_c))
    assert zones == {'HOME': clock['12'], 'PREVIOUS': clock['9'], 'NEXT': clock['3'], 'PLAY': clock['6']}, zones
    params = (ENC / 'params.py').read_text()
    label_r = float(re.search(r'LABEL_R = ([\d.]+)', params)[1])
    ring = tuple(float(v) for v in re.search(r'RING_R = \(([\d.]+), ([\d.]+)\)', design).groups())
    assert ring[0] < label_r < ring[1]
    ok('wheel geometry: ELE1..ELE8 angles equal design.py SECTOR_ANGLES and the README centroids (within 1 degree); '
       'tap zones HOME 12, next 3, play 6, previous 9 o\'clock as SPEC 4; label circle r %.1f lies on the ring' % label_r)


# ---------------------------------------------------------------- MPR121 against README item 4
def check_mpr121(out):
    table = {int(r, 16): int(v, 16) for r, v in re.findall(r'REG 0x([0-9A-F]{2}) 0x([0-9A-F]{2})', out)}
    consts = {k: int(v, 16) for k, v in re.findall(r'(ECR_RUN|ECR_RESUME|ACCR0_KEEP) 0x([0-9A-F]{2})', out)}
    text = (HW / 'README.md').read_text().split('### Firmware for the touch wheel', 1)[1].split('\n## ', 1)[0]
    item4 = re.search(r'\n4\. (.+)', text)[1]
    assert table[0x5B] == int(re.search(r'register 0x5B = 0x([0-9A-F]{2})', item4)[1], 16)
    assert table[0x5C] >> 6 == int(re.search(r'0x5C bits 7:6 = ([01]{2})', item4)[1], 2)
    sfi, esi = re.search(r'0x5D: SFI ([01]{2}), ESI ([01]{3})', item4).groups()
    assert (table[0x5D] >> 3) & 3 == int(sfi, 2) and table[0x5D] & 7 == int(esi, 2)
    regs = {'MHDR': 0x2B, 'NHDR': 0x2C, 'NCLR': 0x2D, 'FDLR': 0x2E, 'MHDF': 0x2F, 'NHDF': 0x30, 'NCLF': 0x31,
            'FDLF': 0x32, 'NHDT': 0x33, 'NCLT': 0x34, 'FDLT': 0x35}
    found = dict(re.findall(r'\b(MHDR|NHDR|NCLR|FDLR|MHDF|NHDF|NCLF|FDLF|NHDT|NCLT|FDLT) 0x([0-9A-F]{2})', item4))
    assert set(found) == set(regs)
    for name, reg in regs.items():
        assert table[reg] == int(found[name], 16), name
    assert table[0x7B] == int(re.search(r'0x7B = 0x([0-9A-F]{2})', item4)[1], 16)
    assert 'its FFI bits equal to those in 0x5C' in item4 and table[0x7B] >> 6 == table[0x5C] >> 6
    for name, reg in (('USL', 0x7D), ('LSL', 0x7E), ('TL', 0x7F)):
        assert table[reg] == int(re.search(name + r' 0x([0-9A-F]{2})', item4)[1], 16), name
    touch, release = map(int, re.search(r'start at touch (\d+) and release (\d+)', text).groups())
    assert all(table[0x41 + 2 * i] == touch and table[0x42 + 2 * i] == release for i in range(9))
    assert consts['ECR_RUN'] >> 6 == (table[0x7B] >> 2) & 3 and consts['ECR_RUN'] & 0xF == 9
    kconfig = (B / 'Kconfig').read_text()
    assert re.search(r'config SLAB_TOUCH_THRESHOLD\n(?:.*\n)*?\s+default (\d+)', kconfig)[1] == str(touch)
    assert re.search(r'config SLAB_RELEASE_THRESHOLD\n(?:.*\n)*?\s+default (\d+)', kconfig)[1] == str(release)
    ok('MPR121 setup equals README item 4: 0x5B 0x22, FFI 18, SFI 6, ESI 16 ms, all 11 AN3944 filter values, '
       '0x7B 0x8B with matching FFI, USL 0xC9, LSL 0x82, TL 0xB5; thresholds %d/%d (item 5); ECR CL = BVA' % (touch, release))


def check_touch_rules():
    src = {p.relative_to(M8).as_posix(): p.read_text() for p in M8.rglob('*.c') if 'build' not in p.parts and 'tests' not in p.parts}
    driver = src['components/st7365p/st7365p.c']
    assert '.spics_io_num = -1' in driver and 'output(SLAB_PIN_LCD_CS, 0)' in driver
    assert not re.search(r'SLAB_PIN_LCD_CS,\s*1', ''.join(src.values()))
    init = (S / 'include/st7365p_init.h').read_text()
    assert not re.search(r'\{0x35,', init), 'tear output must stay off'
    te_users = [f for f, t in src.items() if 'SLAB_PIN_LCD_TE' in t]
    assert te_users == ['components/slab_board/slab_power_seq.c'], te_users
    readers = sorted(f for f, t in src.items() if re.search(r'\bmpr121_read_frame\(', t) and not f.endswith('mpr121.c'))
    assert readers == ['components/slab_touch/slab_wheel.c', 'slab-bringup/main/bringup.c'], readers
    wheel = src['components/slab_touch/slab_wheel.c']
    assert 'GPIO_INTR_NEGEDGE' in wheel and 'CONFIG_SLAB_WHEEL_TRACKING_PERIODS 0' in wheel
    kconfig = (B / 'Kconfig').read_text()
    assert re.search(r'config SLAB_WHEEL_TRACKING_READS\n\s+bool[^\n]*\n\s+default n', kconfig)
    ok('touch-wheel firmware rules: LCD CS has no SPI pin and is only ever driven low; no TE command and GPIO39 '
       'only as an idle input; the player reads the MPR121 only from the TOUCH_IRQ task (tracking reads default off); '
       'only the bring-up noise table polls')


# ---------------------------------------------------------------- ST7365P against the vendor file
def check_st7365p(out):
    vendor, reset_wait, cmd = [], 0, None
    for line in (HW / 'reference/DLC-T2.7DDS1-initial-code.txt').read_text().splitlines():
        if m := re.match(r'\s*Write\(Command\s*,\s*0x([0-9A-Fa-f]+)\)', line):
            vendor.append([int(m[1], 16), [], 0])
        elif m := re.match(r'\s*Write\(Parameter\s*,\s*0x([0-9A-Fa-f]+)\)', line):
            vendor[-1][1].append(int(m[1], 16))
        elif m := re.match(r'\s*Delay\((\d+)\)', line):
            if vendor: vendor[-1][2] += int(m[1])
            else: reset_wait += int(m[1])
    ours = []
    for line in out.splitlines():
        if line.startswith('INIT '):
            parts = line.split()
            ours.append([int(parts[1], 16), [int(x, 16) for x in parts[2:-2]], int(parts[-1])])
    assert int(re.search(r'RESET_WAIT (\d+)', out)[1]) == reset_wait == 120
    assert len(ours) == len(vendor) + 3 and [c[0] for c in ours[len(vendor):]] == [0x2A, 0x2B, 0x2C]
    deviations = []
    for v, o in zip(vendor, ours):
        assert v[0] == o[0] and v[2] == o[2], (v, o)
        if v[1] != o[1]:
            deviations.append('0x%02X %s -> %s' % (v[0], ' '.join('%02X' % x for x in v[1]), ' '.join('%02X' % x for x in o[1])))
    assert deviations == ['0x3A 77 -> 55'], deviations
    assert re.findall(r'SLEEP ([0-9A-F]{2})', out) == ['28', '10']
    numbers['st7365p_init_commands'] = len(vendor)
    ok('ST7365P init equals the vendor file: %d commands in order, every parameter and delay (reset 120, sleep out 120, '
       'F0 69 120), except COLMOD 0x77 -> 0x55 for RGB565 (SPEC 9); then a black fill; sleep is 28, 10' % len(vendor))


# ---------------------------------------------------------------- config consistency
def check_mock_config():
    defaults = {}
    for kfile in (B / 'Kconfig', P / 'Kconfig.projbuild', U / 'Kconfig.projbuild'):
        for chunk in re.split(r'\n\s*(?=config \w+\n)', kfile.read_text()):
            head = re.match(r'config (\w+)\n', chunk)
            m = re.search(r'^\s+default (\S+)', chunk, re.M)
            if head and m: defaults[head[1]] = m[1]
    mock = dict(re.findall(r'#define CONFIG_(\w+) (\S+)', (M8 / 'tests/mock/sdkconfig.h').read_text()))
    for name, value in mock.items():
        assert int(defaults[name], 0) == int(value, 0), (name, defaults[name], value)
    ok('host-test configuration equals the Kconfig defaults (%d values)' % len(mock))


# ---------------------------------------------------------------- previews
def png(path, w, h, rgb):
    raw = b''.join(b'\x00' + rgb[y * w * 3:(y + 1) * w * 3] for y in range(h))
    def chunk(tag, data):
        return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff)
    path.write_bytes(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0)) +
                     chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))


def ppm(path):
    head, rest = path.read_bytes().split(b'\n', 1)
    dims, rest = rest.split(b'\n', 1)
    _, data = rest.split(b'\n', 1)
    w, h = map(int, dims.split())
    assert head == b'P6' and len(data) == w * h * 3
    return w, h, data


def sheet(path, images):
    w = sum(i[0] for i in images) + 12 * (len(images) - 1)
    h = images[0][1]
    rows = []
    for y in range(h):
        line = b''
        for k, (iw, _, data) in enumerate(images):
            if k: line += b'\x50\x50\x50' * 12
            line += data[y * iw * 3:(y + 1) * iw * 3]
        rows.append(line)
    png(path, w, h, b''.join(rows))


def previews(tmp):
    PREVIEW.mkdir(exist_ok=True)
    player = ['player-home', 'player-songs', 'player-now-playing', 'player-settings']
    bringup = ['bringup-screen', 'bringup-results', 'bringup-noise', 'bringup-wheel']
    loaded = {}
    for name in player + bringup:
        loaded[name] = ppm(tmp / (name + '.ppm'))
        w, h, data = loaded[name]
        assert (w, h) == (320, 320)
        png(PREVIEW / (name + '.png'), w, h, data)
    sheet(PREVIEW / 'slab-ui.png', [loaded[n] for n in player])
    sheet(PREVIEW / 'bringup-ui.png', [loaded[n] for n in bringup])
    ok('previews: %d pages at 320 x 320 written to firmware/mark-8/preview (slab-ui.png, bringup-ui.png)' % len(loaded))


# ---------------------------------------------------------------- builds and dependencies
def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build_info():
    info = {}
    for project, name in (('slab-bringup', 'mark8_slab_bringup'), ('slab-player', 'mark8_slab_player')):
        binary = M8 / project / 'build' / (name + '.bin')
        part = 0x300000
        if not binary.exists():
            info[project] = {'built': False}
            continue
        size = binary.stat().st_size
        info[project] = {'built': True, 'app_bytes': size, 'app_sha256': sha(binary), 'factory_partition_bytes': part,
                         'free_bytes': part - size, 'free_percent': round(100 * (part - size) / part, 1),
                         'fits': size <= part}
    return info


def git_dirty(paths):
    out = subprocess.run(['git', '--no-optional-locks', 'status', '--porcelain', '--', *map(str, paths)], cwd=REPO,
                         capture_output=True, text=True).stdout
    return sorted('%s %s' % ('untracked' if line[:2] == '??' else 'modified', line[3:]) for line in out.splitlines() if line[:2].strip())


def main():
    with tempfile.TemporaryDirectory(prefix='mark8-tests-') as d:
        tmp = Path(d)
        mock = M8 / 'tests/mock'
        run_c(tmp, 'power', [M8 / 'tests/test_power.c', B / 'slab_power_seq.c', B / 'slab_backlight_math.c',
              B / 'slab_analog_math.c', B / 'max17048_math.c', B / 'slab_identity.c'], [mock, B / 'include'])
        wheel = run_c(tmp, 'wheel', [M8 / 'tests/test_wheel.c', T / 'wheel.c'], [T / 'include'])
        numbers['wheel_model_status_changes_per_turn'] = int(re.search(r'(\d+) touch status changes', wheel)[1])
        mpr = run_c(tmp, 'mpr121', [M8 / 'tests/test_mpr121.c', T / 'mpr121_regs.c'], [mock, T / 'include'])
        st = run_c(tmp, 'st7365p', [M8 / 'tests/test_st7365p.c', S / 'st7365p.c'], [mock, B / 'include', S / 'include'])
        render = run_c(tmp, 'render', [M8 / 'tests/test_render.c', P / 'slab_render.c', S / 'slab_dirty.c'],
                       [mock, S / 'include', B / 'include', P, SHARED], defines=['PLAYER_UI_ROWS=6'], args=[tmp])
        run_c(tmp, 'bringup', [M8 / 'tests/test_bringup.c', U / 'bringup_ui.c', U / 'gfx.c', U / 'noise_stats.c',
              S / 'slab_dirty.c'], [mock, S / 'include', U, FONT], args=[tmp])
        run_c(tmp, 'controls', [M8 / 'tests/test_controls.c', P / 'controls_map.c', SHARED / 'player_ui.c',
              SHARED / 'player_prefs.c', SHARED / 'album.c', SHARED / 'album_metadata.c'],
              [P, T / 'include', SHARED], defines=['PLAYER_UI_ROWS=6'])
        check_pins()
        check_wheel_geometry()
        check_mpr121(mpr)
        check_touch_rules()
        check_st7365p(st)
        check_mock_config()
        previews(tmp)
    cost = {}
    for name, value, rects in re.findall(r'BYTES (\w+) (\d+) (\d+)', render):
        b = int(value)
        cost[name] = {'bytes': b, 'windows': int(rects), 'ms_at_40MHz': round(b * 8 / 40e6 * 1000, 2),
                      'ms_at_26_7MHz': round(b * 8 / 26.666e6 * 1000, 2), 'ms_at_20MHz': round(b * 8 / 20e6 * 1000, 2)}
        print('DISPLAY %-24s %7d bytes in %s window(s): %5.2f ms at 40 MHz' % (name, b, rects, cost[name]['ms_at_40MHz']))
    numbers['display_update_cost'] = cost
    for project in ('slab-bringup', 'slab-player'):
        blocked = subprocess.run(['bash', str(M8 / project / 'build.sh'), 'flash'], capture_output=True, text=True)
        assert blocked.returncode == 2 and 'cannot flash hardware' in blocked.stderr, project
    ok('both build.sh scripts reject "flash" (exit 2) and accept build actions only')

    shared_files = [SHARED / f for f in ('audio_player.c', 'audio_player.h', 'player_ui.c', 'player_ui.h', 'album.c', 'album.h',
                    'album_metadata.c', 'album_metadata.h', 'player_prefs.c', 'player_prefs.h', 'player_bluetooth.c',
                    'player_bluetooth.h', 'playback.c', 'playback.h', 'player_display.h', 'ui_assets/fonts.h',
                    'ui_assets/trial_durations.h')]
    shared_files += [FW / 'mark-6/components/bench_mp3/mp3_reader.c', FW / 'mark-6/components/bench_mp3/mp3_reader.h',
                     FW / 'mark-6/components/minimp3/minimp3.h', FONT / 'font8x16.h']
    copied_from = [FW / 'mark-7/pocket-player' / f for f in ('main/main.c', 'main/player_display.c', 'main/player_power.c',
                   'main/ui_render.c', 'build.sh', 'partitions.csv', '.gitignore')]
    copied_from.append(FW / 'mark-6/feather-player-bench/components/bench_storage/bench_storage.c')
    own = sorted(p for p in M8.rglob('*') if p.is_file() and not {'build', 'preview', 'mpr121-bench'} & set(p.parts)
                 and p.name not in ('sdkconfig', 'sdkconfig.old', 'verification.json') and '.DS_Store' not in p.name)
    result = {
        'date': datetime.date.today().isoformat(),
        'status': 'PASS host tests and checks; builds as recorded below; no flash, no hardware qualification',
        'esp_idf': '8c750b088c7cd857d079c0eeb495da199b359461 (5.5, firmware/upstream/tangara-fw/lib/esp-idf)',
        'builds': build_info(),
        'host_tests': passes,
        'checks': checks,
        'numbers': numbers,
        'uncommitted_build_dependencies': git_dirty(shared_files),
        'copied_from_uncommitted_working_tree': git_dirty(copied_from),
        'source_sha256': {p.relative_to(REPO).as_posix(): sha(p) for p in own + shared_files},
    }
    (M8 / 'verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print('PASS %d host test programs, %d checks; verification.json written' % (7, len(checks)))


if __name__ == '__main__':
    main()
