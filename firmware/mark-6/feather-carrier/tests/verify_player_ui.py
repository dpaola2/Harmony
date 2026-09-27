#!/usr/bin/env python3
"""Sanitized native UI and actual concurrent audio-queue behavior checks."""
from pathlib import Path
import subprocess
import tempfile
P = Path(__file__).resolve().parents[1]
T = P / 'tests'
with tempfile.TemporaryDirectory(prefix='harmony-ui-') as directory:
    tmp = Path(directory)
    flags = ['cc', '-std=gnu11', '-Wall', '-Wextra', '-Werror',
             '-Wno-unused-parameter', '-fsanitize=address,undefined', '-pthread',
             '-I' + str(P / 'main'), '-I' + str(tmp), '-I' + str(T / 'audio_mock')]
    exe = tmp / 'ui'
    subprocess.run(flags + [str(T / 'test_player_ui.c'), str(P / 'main/player_ui.c'), '-o', str(exe)], check=True)
    subprocess.run([str(exe)], check=True)
    render = tmp / 'render'
    subprocess.run(flags + [str(T / 'test_ui_render.c'), str(P / 'main/ui_render.c'), '-o', str(render)], check=True)
    subprocess.run([str(render)], check=True)
    for name in ['freertos/FreeRTOS.h', 'freertos/task.h', 'freertos/semphr.h',
                 'esp_heap_caps.h', 'esp_log.h', 'esp_timer.h', 'bench_storage.h']:
        f = tmp / name
        f.parent.mkdir(parents=True, exist_ok=True)
        f.write_text('#include "runtime.h"\n')
    exe = tmp / 'queue'
    subprocess.run(flags + [str(T / 'test_audio_queue_runtime.c'),
        str(P / 'main/audio_player.c'), str(P / 'main/playback.c'), str(P / 'main/album.c'),
        '-o', str(exe)], check=True)
    subprocess.run([str(exe)], check=True)
