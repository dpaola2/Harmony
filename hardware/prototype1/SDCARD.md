Here is a clean, self-contained **hardware documentation file** for a generic SPI SD-card reader module.
It assumes a common 6-pin breakout (CS, SCK, MOSI, MISO, VCC, GND) with no other markings — the typical low-cost modules used for ESP32, Arduino, STM32, etc.

You can drop this directly into your repo as
`/docs/hardware/sd-card-module.md`.

---

# SD Card Module (SPI)

### **Generic 6-pin SD Card Reader / MicroSD Adapter**

**Pins:** `CS`, `SCK`, `MOSI`, `MISO`, `VCC`, `GND`
**Interface:** SPI
**Card Type:** microSD (FAT16/FAT32; often supports SDHC depending on module)
**Voltage:** Typically **3.3 V logic** (but see “Important Notes” below)

---

## Overview

This is a generic SPI-based microSD card module used to provide filesystem storage to microcontrollers.
It exposes the SD card through a 6-pin header that maps directly to a standard 4-wire SPI bus.

These modules are suitable for:

* Logging data
* Loading configuration files
* Storing images, audio files, or metadata
* Playback buffers for MP3/WAV/FLAC (depending on library/firmware)
* Filesystem use (FATFS, Arduino SD library, ESP-IDF SDMMC/SPI driver, MicroPython’s `uos` + SDCard driver)

---

## Pinout

The module exposes the minimum SPI pins required to communicate with an SD card.

| Pin      | Name                 | Description                                             |
| -------- | -------------------- | ------------------------------------------------------- |
| **CS**   | Chip Select          | Active-LOW. Selects this SD card device on the SPI bus. |
| **SCK**  | Serial Clock         | SPI clock signal provided by the MCU.                   |
| **MOSI** | Master Out, Slave In | Data line from MCU → SD card.                           |
| **MISO** | Master In, Slave Out | Data line from SD card → MCU.                           |
| **VCC**  | Power Supply         | Typically **3.3 V** (see warnings below).               |
| **GND**  | Ground               | Common ground with MCU.                                 |

**Note:**
Some SD modules include a regulator + level shifters.
Others are *bare* 3.3 V modules and are **not 5 V tolerant**.

---

## Electrical Characteristics

| Parameter           | Value                                          |
| ------------------- | ---------------------------------------------- |
| Logic voltage       | **3.3 V** (many modules are *not* 5 V-safe)    |
| Supply voltage      | 3.3 V nominal                                  |
| Recommended current | ~50–100 mA (depending on card type)            |
| SPI clock           | 1–25 MHz typical; up to 40+ MHz on modern MCUs |

### Power Consumption by SD card

* Idle: **0.2–2 mA**
* Access: **20–100 mA** (varies greatly by card brand + size)
* High-speed read bursts: **100–200 mA** possible

**Important:**
If your MCU’s 3.3 V regulator can't supply ~200 mA peak, use an external supply.

---

## Features

* Standard 6-pin SPI interface
* Supports common microSD cards (1–32 GB for FAT32, sometimes larger with FATFS)
* Can be used as a lightweight filesystem
* Compatible with FAT16/FAT32 by default
* Works with embedded firmware stacks:

  * **ESP32 / ESP32-S3:** ESP-IDF `sdspi_host` + FATFS
  * **Arduino:** SD / SdFat libraries
  * **MicroPython:** `machine.SDCard` + `uos.mount()`
  * **STM32:** HAL SDIO/SPI + FatFS

---

## Typical Use Cases

* Local storage for **audio files** (MP3, WAV, FLAC)
* Saving and loading **cover art images**
* Config / settings persistence
* Logging sensor or debug data
* Caching assets for displays (e.g., fonts, icons, bitmaps)

---

## SPI Protocol Overview

SD cards support two main modes:

1. **SDIO (4-bit)**
2. **SPI (1-bit)** ← your module uses this mode.

SPI mode command flow:

1. MCU initializes SPI at low speed (~100–400 kHz).
2. Send CMD0 (go idle).
3. Send CMD8, check compatible voltage.
4. Initialize card with ACMD41 loop.
5. Switch to higher-speed SPI (10–40 MHz).
6. Mount FAT filesystem (FATFS, SdFat, etc.).

Most libraries handle all of this automatically.

---

## Board Layout & Physical Notes

* Typically uses a **push-push** microSD socket.
* 6-pin header is in a single row, 0.1″ spacing, breadboard-friendly.
* PCB often includes:

  * Unlabeled **3.3 V LDO regulator** (AMS1117 or similar) on some variants
  * **Voltage dividers** on SPI lines (for 5 V boards)
  * Or no level shifting at all (3.3 V only)

---

## Important Notes & Caveats

### 1. **Your module might NOT be 5 V tolerant**

Since yours has **only 6 pins and no markings**, it is likely the “minimal” kind with:

* **no regulator**
* **no level shifting**
* **3.3 V logic only**

This means:

> **VCC must be 3.3 V**
> **All SPI lines must be 3.3 V**

This is perfect for ESP32 / ESP32-S3.

---

### 2. SD cards can be noisy (electrically)

During high-speed access, cards draw bursts of current.
Symptoms of power instability:

* Random disconnects
* File corruption
* Initialization failures
* Screen flickering or audio decoding glitches

**Mitigation:**
Use a short wire harness and a stable 3.3 V supply.

---

### 3. SPI speeds vary by card quality

Some cheap SD cards fail above 16 MHz.
Brand-name cards (Samsung, SanDisk) typically work at 40 MHz+.

---

### 4. Must initialize with slow SPI first

All libraries handle this automatically.
In low-level implementations, start at 100–400 kHz, then speed up.

---

### 5. Filesystem recommendations

| Capacity | Format                               |
| -------- | ------------------------------------ |
| ≤ 2 GB   | FAT16                                |
| 4–32 GB  | FAT32                                |
| > 32 GB  | exFAT (if your firmware supports it) |

ESP-IDF FATFS supports FAT32 by default; exFAT requires extra components.

---

## Compatible Software Stacks

### **ESP32 / ESP32-S3 (your environment likely)**

* ESP-IDF:

  * `sdspi_host_init()`
  * `esp_vfs_fat_sdspi_mount()`

* Arduino (ESP32 core):

  * `SD.begin(CS)`

* MicroPython:

  ```python
  import machine, uos
  sd = machine.SDCard(slot=2, sck=..., mosi=..., miso=..., cs=...)
  uos.mount(sd, "/sd")
  ```

---

## Mechanical Dimensions (Typical)

| Property      | Value                              |
| ------------- | ---------------------------------- |
| Module width  | ~24–25 mm                          |
| Module length | ~30–32 mm                          |
| PCB thickness | 1.0–1.2 mm                         |
| Header type   | Single-row, 6-pin, 2.54 mm spacing |

(This varies slightly by vendor.)

---

## Where This Component Fits in Your MP3 Player Project

* Stores audio files (MP3/WAV)
* Stores album art for display
* Provides persistent state/logging (e.g., resume track position)
* Suitable for high-speed reads required by buffered playback
* Works natively with ESP32’s DMA-capable SPI driver
