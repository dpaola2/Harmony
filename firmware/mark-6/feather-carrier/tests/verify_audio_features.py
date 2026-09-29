#!/usr/bin/env python3
"""Sanitized queue, volume, repeat and paused-boot audio runtime checks."""
from pathlib import Path
import subprocess
import tempfile
P = Path(__file__).resolve().parents[1]
T = P / 'tests'
with tempfile.TemporaryDirectory(prefix='harmony-audio-features-') as directory:
    tmp = Path(directory)
    flags = ['cc', '-std=gnu11', '-Wall', '-Wextra', '-Werror',
             '-Wno-unused-parameter', '-fsanitize=address,undefined', '-pthread',
             '-I' + str(P / 'main'), '-I' + str(tmp), '-I' + str(T / 'audio_mock')]
    exe = tmp / 'playback'
    subprocess.run(flags + [str(T / 'test_playback.c'), str(P / 'main/playback.c'), '-o', str(exe)], check=True)
    subprocess.run([str(exe)], check=True)
    for name in ['freertos/FreeRTOS.h', 'freertos/task.h', 'freertos/semphr.h',
                 'esp_heap_caps.h', 'esp_log.h', 'esp_timer.h', 'bench_storage.h']:
        f = tmp / name
        f.parent.mkdir(parents=True, exist_ok=True)
        f.write_text('#include "runtime.h"\n')
    for name, ui in [('audio_runtime', False), ('audio_queue_runtime', False), ('audio_ui_runtime', True)]:
        exe = tmp / name
        command = flags + (['-DHARMONY_PLAYER_UI=1'] if ui else [])
        sources = [T / f'test_{name}.c', P / 'main/audio_player.c', P / 'main/playback.c']
        if not ui:
            sources += [P / 'main/album.c', P / 'main/album_metadata.c']
        subprocess.run(command + list(map(str,sources)) + ['-o',str(exe)],check=True)
        subprocess.run([str(exe)],check=True)
        if ui:
            subprocess.run([str(exe),'empty'],check=True)
            subprocess.run([str(exe),'allocation'],check=True)
