#!/usr/bin/env python3
from pathlib import Path
import subprocess, tempfile
P=Path(__file__).resolve().parents[1]; SHARED=P.parents[1]/'mark-6/feather-carrier'
OUT=P/'preview';OUT.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix='mark7-tests-') as d:
    flags=['cc','-std=gnu11','-Wall','-Wextra','-Werror','-Wno-unused-parameter','-fsanitize=address,undefined','-pthread','-DPLAYER_UI_ROWS=4','-I'+str(P/'main'),'-I'+str(SHARED/'main')]
    groups={'wheel':[P/'tests/test_wheel.c',P/'main/wheel_protocol.c'],
      'ui':[P/'tests/test_ui.c',*[SHARED/'main'/f for f in ('player_ui.c','player_prefs.c','album.c','album_metadata.c')]],
      'render':[P/'tests/test_render.c',P/'main/ui_render.c']}
    for name, sources in groups.items():
        exe=Path(d)/name;subprocess.run(flags+list(map(str,sources))+['-o',str(exe)],check=True)
        args=[str(OUT/'now-playing.ppm'),str(OUT/'music.ppm')] if name=='render' else []
        subprocess.run([str(exe)]+args,check=True)

    tmp=Path(d)
    for name in ['esp_err.h','driver/gpio.h','driver/spi_master.h','esp_attr.h','esp_log.h','esp_rom_sys.h','sdkconfig.h','freertos/FreeRTOS.h','freertos/task.h']:
        f=tmp/name;f.parent.mkdir(parents=True,exist_ok=True);f.write_text('#include "mock_idf.h"\n')
    for shared in [False, True]:
        exe=tmp/('display-shared' if shared else 'display')
        extra=['-DTEST_SHARED_BUS'] if shared else []
        subprocess.run(flags+extra+['-I'+str(tmp),'-I'+str(SHARED/'tests'),'-I'+str(SHARED/'components/bench_display'),'-I'+str(P/'components/carrier_board'),'-I'+str(P/'components/bench_display'),str(P/'tests/test_display.c'),str(P/'components/bench_display/display.c'),'-o',str(exe)],check=True)
        subprocess.run([str(exe)],check=True)
    blocked=subprocess.run(['bash',str(P/'build.sh'),'flash'],capture_output=True,text=True)
    assert blocked.returncode==2 and 'cannot flash hardware' in blocked.stderr
    print('PASS preparation script rejects flash')
