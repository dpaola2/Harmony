# Mark-5 driver sources

These are the unmodified files used in the successful September 19 bench tests.
The host loader supplies explicit `micropython` and `const` imports when loading
the display driver into RAM. Upstream license files are included here.

| Files | Upstream | Commit |
|---|---|---|
| `sdcard.py`, `LICENSE-vs1053` | https://github.com/peterhinch/micropython-vs1053 | `ead5ed9b0c28cef5445a512cb1a35e71dfb7299d` |
| `st7789py.py`, `vga1_8x16.py`, `LICENSE-st7789` | https://github.com/russhughes/st7789py_mpy | `7265925bd0c092e8105200d18b2dba9dfbc12c27` |

The VS1053 control and playback code is in `../mark5_player.py`. Only the SD
driver from the VS1053 repository is loaded by `tools/run_mark5.py`.
