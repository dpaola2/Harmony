# Second Feather identified for Mark-7

October 4, 2026 · Build Mark-7 portable Bluetooth player (HARMONY-19).

Dave connected an unused Feather ESP32 V2 alone over USB, with no display or other peripherals. The read-only esptool checks identify ESP32-PICO-V3-02 revision 3.1, base/STA MAC **14:33:5c:98:58:88**, 40 MHz crystal, and **8 MB flash** (manufacturer 0x20, device 0x4017). The chip reports embedded PSRAM; its capacity and memory test have not been verified on this board.

The USB serial port in this session was `/dev/cu.usbserial-5B1E0646811`. Recheck the MAC before any future flash; port names alone are not an identity check. Mark-6's recorded MAC is `14:33:5c:99:1a:28`, a different board. No flash or eFuse write was performed. Both identity commands reset the spare board afterward.

The local Mark-7 sdkconfig now selects this MAC and display-only mode, with experimental wheel input disabled. `sdkconfig.board` records those settings; generic project defaults remain uncommissioned. The display-only image is for the first screen test after wiring the arriving #4311, not a peripheral test performed today.

- [Identity record](identity.json)
- [Successful build record](build.json) and [build log](build.log)
- [Mark-7 firmware and pin map](../../../firmware/mark-7/pocket-player/README.md)
- [Power and sleep design](../../../docs/mark-7-power-and-sleep.md)

Next: connect the arriving display to this Feather, flash the display-only image after rechecking identity, and verify the color pattern and orientation. SD, wheel, battery and sleep tests follow. Keep the Mark-6 demo assembled.
