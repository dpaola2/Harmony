from pathlib import Path
import subprocess
import tempfile
p=Path(__file__).resolve().parents[1]
shared=p.parent/'feather-carrier'
with tempfile.TemporaryDirectory() as td:
    tmp=Path(td)
    for name in ['esp_err.h','driver/gpio.h','driver/spi_master.h','esp_attr.h','esp_log.h',
                 'esp_rom_sys.h','sdkconfig.h','freertos/FreeRTOS.h','freertos/task.h',
                 'esp_mac.h','esp_flash.h','esp_psram.h']:
        f=tmp/name;f.parent.mkdir(parents=True,exist_ok=True)
        f.write_text('#include "mock_idf.h"\nbool esp_psram_is_initialized(void);\n')
    for name,sources in {
        'board':[p/'tests/test_board.c',p/'components/carrier_board/bench_board.c'],
        'display':[shared/'tests/test_display.c',shared/'components/bench_display/bench_display.c'],
    }.items():
        exe=tmp/name
        includes=[tmp,p/'components/carrier_board',shared/'tests',shared/'components/carrier_board',shared/'components/bench_display']
        subprocess.run(['cc','-std=gnu11','-Wall','-Wextra','-Werror','-Wno-unused-parameter',
            '-fsanitize=address,undefined',*['-I'+str(i) for i in includes],
            *map(str,sources),'-o',str(exe)],check=True)
        subprocess.run([str(exe)],check=True)
