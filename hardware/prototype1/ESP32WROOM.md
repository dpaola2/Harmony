Here you go — the **direct PDF**, plus cleaned-up **pinout diagrams** and **the important electrical notes** you’ll need for your MP3-player prototype.

---

# 📄 **Direct PDF Download (Official Espressif)**

**ESP32-S3-DevKitC-1 v1.1 User Guide (PDF):**
👉 [https://docs.espressif.com/_/downloads/esp-dev-kits/en/latest/esp32s3/esp32-s3-devkitc-1/pdf/ESP32-S3-DevKitC-1_User_Guide_v1.1.pdf](https://docs.espressif.com/_/downloads/esp-dev-kits/en/latest/esp32s3/esp32-s3-devkitc-1/pdf/ESP32-S3-DevKitC-1_User_Guide_v1.1.pdf)

This is the exact board revision you have.

---

# 🧭 **Pinout Diagram (Clean + Accurate for v1.1)**

### **Left Header**

* **3V3**
* **EN**
* **IO4**
* **IO5**
* **IO6**
* **IO7**
* **IO15**
* **IO16**
* **IO17**
* **IO18**
* **IO8**
* **IO3**
* **IO46** *(input only!)*
* **5V**
* **GND**

### **Right Header**

* **3V3**
* **GND**
* **IO1**
* **IO2**
* **IO42**
* **IO41**
* **IO40**
* **IO39**
* **IO38**
* **IO37**
* **IO36**
* **IO35**
* **IO0**
* **IO48**
* **5V**

If you'd like, I can generate a *labeled wiring diagram* showing where to connect your **ST7789 display**, **buttons**, **rotary encoder**, or **audio circuitry**.

---

# ⚠️ Electrical Notes You Should Not Ignore

### **1. IO46 is input-only**

You cannot use it for SPI, I²C, or any output.

---

### **2. Default USB-Serial uses IO19 / IO20**

* **IO19 = USB D–**
* **IO20 = USB D+**

Do **not** reuse them unless you disable the USB-CDC/JTAG functionality.

---

### **3. Boot mode pins**

* **IO0 = strapping pin**
  Pulling it LOW during boot = enter bootloader
  If you use IO0 for buttons, make sure they’re *normally pulled-up*.

* **IO46 = strapping pin (input only)**
  Don’t pull it low accidentally.

---

### **4. Power for displays**

The ST7789 displays typically draw:

* ~40–70mA backlight
* 10–15mA logic

Your DevKitC’s 3V3 regulator can supply ~600mA, so you are fine powering the display directly from the board.

---

# 📚 Additional Official Docs

### Datasheet for ESP32-S3:

[https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf](https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf)

### Hardware Design Guidelines:

[https://www.espressif.com/sites/default/files/documentation/esp32-s3_hardware_design_guidelines_en.pdf](https://www.espressif.com/sites/default/files/documentation/esp32-s3_hardware_design_guidelines_en.pdf)

### Technical Reference Manual (S3):

[https://www.espressif.com/sites/default/files/documentation/esp32-s3_technical_reference_manual_en.pdf](https://www.espressif.com/sites/default/files/documentation/esp32-s3_technical_reference_manual_en.pdf)

---
