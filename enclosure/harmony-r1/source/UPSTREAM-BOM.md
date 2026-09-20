# Bill of Materials

This is a list of every part needed to assemble one Tangara.

| Component                     | Manufacturer + part number |
|-------------------------------|----------------------------|
| Mainboard PCB                 | See `tangara-mainboard`    | 
| Faceplate PCB                 | See `tangara-faceplate`    |
| Touchwheel cover (0.6mm FR4)  | See `touchwheel-cover`     |
| 15 pos 0.5mm pitch FFC cable  | Samtec FJH-15-R-03.00-4    |
| 4x 6mm M2 standoffs           | Wurth 970060244            |
| 4x 14mm countersunk M2 screws |	Accu SHK-M2-14-V2-A2       |
| 4x 8mm countersunk M2 screws  |	Accu SHK-M2-8-V2-A4        |
| Case top half                 | See `case-v2`              |
| Case bottom half              | See `case-v2`              |
| Switch cover                  | See `case-v2`              |
| 2x Button covers              | See `case-v2`              |
| SD card cover                 | TBD                        |
| 3-pin 2200mAh 604560 LiPo     | EcoCell LIP2-001           |
| Haptic motor                  | TBD                        |

We're currently finalising our production v2 case design, including the SD card
cover. Full sources for these will be available once they're finished.

Notes on selecting alternatives for specific parts are given below.

## Display

The display is considered a part of the faceplate, but there's enough options
for sourcing that it's worth a few notes here.

 - For production, we're using ER-TFT018-4 from EastRising Technology Co.
 - [Adafruit's JFT-1800](https://www.adafruit.com/product/618) panel should also work fine.
 - Most ST7735R / ST7735S displays available on AliExpress should work fine.

## FFC Cable

For all current mainboard and faceplate revisions, we use an FFC connector with
tin plated contacts. You should therefore try to pick an FFC cable that has tin
plated contacts, to avoid corrosion.

Aside from the Samtec cable listed about, you might also consider:

 - Molex 98266-0836
 - GCT 05-15-D-0076-A-4-06-4-T

## Screws

Any 14mm and 8mm countersunk M2 screws will be fine. We've used Torx head for
our production units because we're big nerds, but you can often find hex and
Phillips head screws easily from local suppliers.

## Battery

For the battery, note that a 2-pin cell may be compatible if R1 on the
mainboard PCB is populated with a 10k 0603 resitor. We recommend sourcing a
suitable battery locally, as international shipping of LiPo batteries can be
difficult.

## Haptics

Tangara's haptic motor driver supports both LRA (closed and open-loop) and ERM
haptic motors, so sourcing a compatible motor is very easy. We'll update this
BOM once we've locked in our production motor, but some compatible choices are:

 - Vybronics Inc. VG0832022D (LRA)
 - Vybronics Inc. VC1034B018F (ERM)
 - Adafruit 1201 (ERM)
 - DFRobot FIT0774 (ERM)

