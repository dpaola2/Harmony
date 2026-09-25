#!/usr/bin/env python3
"""Host behavior tests plus independent carrier/vendor GPIO cross-check."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import tempfile
import xml.etree.ElementTree as ET

P = Path(__file__).resolve().parents[1]
C = P.parents[2] / 'hardware/mark-6/carrier-rev-a'
tests = P / 'tests'
board = P / 'components/carrier_board'
display = P / 'components/bench_display'
results = []
with tempfile.TemporaryDirectory(prefix='harmony-carrier-tests-') as tmp:
    tmp = Path(tmp)
    for name in ['esp_err.h', 'driver/gpio.h', 'driver/spi_master.h', 'esp_attr.h',
                 'esp_log.h', 'esp_rom_sys.h', 'sdkconfig.h', 'freertos/FreeRTOS.h',
                 'freertos/task.h', 'esp_mac.h', 'esp_flash.h', 'esp_psram.h']:
        f = tmp / name
        f.parent.mkdir(parents=True, exist_ok=True)
        f.write_text('#include "mock_idf.h"\n')
    for name, sources in {
        'playback': [P / 'main/playback.c'],
        'album': [P / 'main/album.c'],
        'input': [P / 'main/input_filter.c'],
        'policy': [board / 'carrier_policy.c'],
        'board': [board / 'carrier_policy.c', board / 'carrier_board.c'],
        'display': [display / 'bench_display.c'],
    }.items():
        exe = tmp / name
        subprocess.run(['cc', '-std=gnu11', '-Wall', '-Wextra', '-Werror',
                        '-Wno-unused-parameter', '-fsanitize=address,undefined',
                        '-I'+str(P / 'main'), '-I'+str(tmp), '-I'+str(tests), '-I'+str(board), '-I'+str(display),
                        str(tests / f'test_{name}.c'), *map(str, sources), '-o', str(exe)], check=True)
        result = subprocess.check_output([str(exe)], text=True).strip()
        print(result)
        results.append(result)

# Execute the actual audio task/callback adapter with pthread-backed RTOS mocks.
# Synthetic decoded frames isolate queue/control behavior from codec correctness.
with tempfile.TemporaryDirectory(prefix='harmony-audio-runtime-') as tmp:
    tmp = Path(tmp)
    for name in ['freertos/FreeRTOS.h', 'freertos/task.h', 'freertos/semphr.h',
                 'esp_heap_caps.h', 'esp_log.h', 'esp_timer.h', 'bench_storage.h']:
        f = tmp / name
        f.parent.mkdir(parents=True, exist_ok=True)
        f.write_text('#include "runtime.h"\n')
    exe = tmp / 'audio-runtime'
    subprocess.run(['cc', '-std=gnu11', '-Wall', '-Wextra', '-Werror',
                    '-Wno-unused-parameter', '-fsanitize=address,undefined', '-pthread',
                    '-I'+str(tmp), '-I'+str(tests / 'audio_mock'), '-I'+str(P / 'main'),
                    str(tests / 'test_audio_runtime.c'), str(P / 'main/audio_player.c'),
                    str(P / 'main/playback.c'), str(P / 'main/album.c'), '-o', str(exe)], check=True)
    result = subprocess.check_output([str(exe)], text=True).strip()
    print(result)
    results.append(result)

# Compile the unchanged state-handler bodies from main.c against event stubs.
# This exercises handler ordering without simulating the Bluetooth stack or RF.
main_source = (P / 'main/main.c').read_text()
functions = []
for name in ['bt_app_av_sm_hdlr', 'bt_app_av_state_unconnected_hdlr',
             'bt_app_av_state_connecting_hdlr', 'bt_app_av_media_proc',
             'bt_app_av_state_connected_hdlr', 'bt_app_av_state_disconnecting_hdlr']:
    match = re.search(r'static void '+name+r'\([^;]*?\)\n\{', main_source)
    assert match, name
    start = match.start()
    at = match.end()
    depth = 1
    while depth:
        if main_source[at] == '{': depth += 1
        if main_source[at] == '}': depth -= 1
        at += 1
    functions.append(main_source[start:at])
with tempfile.TemporaryDirectory(prefix='harmony-bt-handlers-') as tmp:
    tmp = Path(tmp)
    source = tmp / 'bt.c'
    enums = main_source[main_source.index('enum {'):main_source.index('/*********************************')]
    declarations = '\n'.join(f[:f.index('\n{')]+';' for f in functions)
    source.write_text((tests / 'test_bluetooth.inc').read_text()+'\n'+enums+'\n'+
                      declarations+'\n'+'\n'.join(functions)+'\n'+
                      (tests / 'test_bluetooth_main.inc').read_text())
    exe = tmp / 'bt'
    subprocess.run(['cc', '-std=gnu11', '-Wall', '-Wextra', '-Werror',
                    '-Wno-unused-variable', '-Wno-unused-but-set-variable',
                    '-fsanitize=address,undefined', '-I'+str(P / 'main'),
                    str(source), '-o', str(exe)], check=True)
    result = subprocess.check_output([str(exe)], text=True).strip()
    print(result)
    results.append(result)

# Derive MCU GPIO numbers from the vendor's actual schematic nets, then follow
# each carrier socket net to its firmware constant. No duplicate pin-map table.
root = ET.parse(C / 'reference/Adafruit ESP32 Feather V2.sch').getroot()
vendor = {}
for net in root.findall('.//schematic/sheets/sheet/nets/net'):
    refs = [x.attrib for x in net.findall('.//pinref')]
    mcu = [x for x in refs if x['part'] == 'X3' and re.match(r'IO?\d+', x['pin'])]
    if not mcu:
        continue
    gpio = int(re.match(r'IO?(\d+)', mcu[0]['pin'])[1])
    for pin in refs:
        if pin['part'] in ['JP1', 'JP3']:
            vendor[(pin['part'], pin['pin'])] = gpio
constants = {name: int(value) for name, value in
             re.findall(r'#define CARRIER_(\w+) (\d+)', (board / 'carrier_pins.h').read_text())}
connections = json.loads((C / 'connections.json').read_text())
checked = []
for component in connections['components']:
    if component['ref'] not in ['J1', 'J2']:
        continue
    for pin, net in component['nets'].items():
        name = 'PG' if net == 'PERIPH_PG' else (net or '').removesuffix('_MCU')
        if name not in constants:
            continue
        header = 'JP1' if component['ref'] == 'J1' else 'JP3'
        assert constants[name] == vendor[(header, pin)], (name, pin)
        checked.append(name)
assert set(checked) == set(constants) and len(set(constants.values())) == 13
assert not {12, 15} & set(constants.values())
results.append('PASS all 13 GPIOs traced through carrier socket nets to vendor MCU pins')
print(results[-1])

for lock in ['hx8357-source.json', 'seesaw-source.json']:
    data = json.loads((P / 'reference' / lock).read_text())
    entries = data['files']
    if isinstance(entries, dict):
        entries = [dict(value, file=Path(key).name) for key, value in entries.items()]
    for entry in entries:
        assert hashlib.sha256((P / 'reference' / entry['file']).read_bytes()).hexdigest() == entry['sha256']

config = (P / 'sdkconfig').read_text()
waveshare = json.loads((P / 'reference/waveshare-source.json').read_text())
assert hashlib.sha256((P / 'reference' / waveshare['file']).read_bytes()).hexdigest() == waveshare['sha256']
# Compare every table command, parameter and delay with the retained source record.
table = (display / 'st7796_init.h').read_text()
actual_steps = []
for cmd, count, delay, values in re.findall(r'\{(0x[0-9a-f]+), (\d+), (\d+), \{([^}]*)\}\}', table):
    data = [int(v.strip(), 0) for v in values.split(',')][:int(count)]
    actual_steps.append({'cmd':int(cmd,0), 'data':data, 'delay_ms':int(delay)})
assert actual_steps == waveshare['init_steps']
results.append('PASS Waveshare ST7796S vendor initialization: all 18 commands, parameters and delays')
print(results[-1])
for key in ['CONFIG_BTDM_CTRL_MODE_BR_EDR_ONLY=y', 'CONFIG_BT_A2DP_ENABLE=y',
            'CONFIG_ESPTOOLPY_FLASHSIZE_8MB=y', 'CONFIG_SPIRAM=y',
            'CONFIG_CARRIER_EXPECTED_MAC=""', 'CONFIG_FREERTOS_HZ=1000',
            'CONFIG_FATFS_LFN_HEAP=y', 'CONFIG_FATFS_API_ENCODING_UTF_8=y']:
    assert key in config, key
description = json.loads((P / 'build/project_description.json').read_text())
assert description['target'] == 'esp32'
for name in ['bench_display', 'bench_storage', 'carrier_board']:
    assert str(P / 'components' / name) in description['build_component_paths']
assert 'CONFIG_BENCH_DISPLAY_SOFT_SPI=y' not in config
blocked = subprocess.run(['bash', str(P / 'build.sh'), 'flash'], capture_output=True, text=True)
assert blocked.returncode == 2 and 'cannot flash hardware' in blocked.stderr
results.append('PASS pinned references, native ESP32 build config, isolated components, flash-command rejection')
print(results[-1])

inputs = [f for folder in ['main', 'components', 'tests'] for f in (P / folder).rglob('*') if f.is_file()]
inputs += [P / n for n in ['CMakeLists.txt', 'sdkconfig', 'sdkconfig.defaults', 'partitions.csv', 'build.sh']]
report = {'date': '2026-09-22', 'status': 'PASS compile and host tests only; not flashed or hardware-qualified',
          'checks': results, 'pin_count': len(checked),
          'app_bytes': (P / 'build/mark6_feather_carrier.bin').stat().st_size,
          'app_sha256': hashlib.sha256((P / 'build/mark6_feather_carrier.bin').read_bytes()).hexdigest(),
          'source_hashes': {str(f.relative_to(P)): hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted(inputs)}}
(P / 'verification.json').write_text(json.dumps(report, indent=2) + '\n')
