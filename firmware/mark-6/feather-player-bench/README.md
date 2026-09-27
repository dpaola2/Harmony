# Feather player UI bench

This native ESP-IDF build runs the first music-browser UI on the temporary Feather V2 harness. It uses the 45-track trial card and SoundCore 2. The carrier hardware remains unqualified.

Music opens Artists or Albums. Select an artist, album, and song to start that album from the selected song. Back restores the previous highlight and scroll position. Browsing leaves the current queue intact. Playback stops at the album end.

| Control | Action |
| --- | --- |
| Wheel | Browse the current list |
| Center | Enter a menu, play a selected song, or pause/resume Now Playing |
| Top / MENU | Back one level |
| Bottom | Pause/resume the current song |
| Left / right | Previous/next within the current queue |

Volume remains at -24 dB. Use the speaker's volume buttons. Bluetooth and Settings show the current limits. Device selection, pairing management, and volume adjustment follow this first UI version.

The screen uses antialiased Montserrat glyphs, RGB565 colors, and two PSRAM framebuffers. Unchanged views skip rendering. Highlight changes redraw only the affected rows. Eight-row DMA transfers release the shared LCD/SD bus between writes. Input polling has higher priority than drawing. The renderer and navigation are tested on the host. Card access remains read-only. Progress durations use exact path matches against the prepared trial library; unknown files show elapsed time only.

Build with `bash firmware/mark-6/feather-player-bench/build.sh build` from the repository root. Run `python3 firmware/mark-6/feather-carrier/tests/verify_player_ui.py` for navigation, rendering, and concurrent audio-queue tests. The existing carrier verifier covers the driver and audio regressions.

The previous working binary and hashes are saved at `/Users/dave/Downloads/harmony-mark6-backups/pre-ui-20260927/`. This build reuses carrier sources with a separate board/storage adapter and shared-SPI initialization. The production carrier keeps its power-good guard.

Related: [UI requirements](../../../docs/Harmony-player-ui-requirements.md), [desktop prototype](../../../platforms/pc/ui/README.md), Harmony Mark-6: Bluetooth bench player (HARMONY-17).
