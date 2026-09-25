# Mark-6 display probe

HARMONY-17. Reuses the Adafruit #4383 ST7789 display from Mark-5, as Dave
requested on September 21. Build with `bash build.sh build`.

The MAC-guarded native driver uses software SPI with 2us half-cycle delays:
SCK14, MOSI13, TFTCS26,
DC33 and RST32. Vin connects to USB-derived 5 V and GND to GND. Local LIT and
SDCS jumpers connect to the display's own 3V output; MISO is unconnected.
GPIO21/22 remain available for the incoming I2C controls. SD uses SPI3.

This probe only initializes and draws the display. The initial native SPI2
version drew text, a border and labeled RGB bars, but Dave reported a blank
screen. Display Vin and regulator voltages were reported normal.

The first software-SPI white test also remained blank. The recovered successful
Mark-5 script is retained in `hardware/mark-5/reference-scripts/`.

The recovered white diagnostic enabled `CONFIG_BENCH_DISPLAY_SOFT_SPI` and
reproduced that script's hard/software reset, minimal initialization and
uninterrupted chip-select during the white fill of 240 x 320 controller pixels.
Dave confirmed a solid white screen. The current probe uses the same sequence
for normal landscape drawing, holding CS through each rectangle, and displays
text, a border and RGB bars for the next visual check.
The first attempt used the normal driver's full init and released CS per row;
those were differences from the successful historical test. A successful draw
log requires Dave's visual confirmation before it counts as a pass. No SD or
Bluetooth test runs. The pattern function remains available for the next
geometry/color check.

The shared driver retains the recovered minimal initialization, BGR setting,
landscape rotation and offsets. The font and original full initialization table
were converted from the retained Mark-5 sources; licenses and source hashes
are in `bench_display`. The full table is retained as history and is no longer
used by the driver.
