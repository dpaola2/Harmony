# AGENTS.md – MP3 Player Project

This file describes the agents, their responsibilities, and how they should collaborate on the **Offline MP3 Player** project.

The goal:  
> A small, offline MP3 player with an iPod-style interface, tactile buttons (no touch), a simple screen, and Bluetooth audio output for use while walking and driving.  

Core constraints:

- **Core logic in Python**, portable between:
  - A **PC simulator** (normal Python)
  - The **device** (MicroPython on ESP32)
- Hardware platform: **ESP32** with built-in Bluetooth (able to *stream* audio, not just receive).
- Case: **3D-printed** enclosure once hardware & UX are stable.

---

## Global Project Conventions

All agents should follow these rules:

1. **Separation of Concerns**
   - Keep **core app logic** (state, navigation, playlist, playback control) independent of any specific hardware.
   - Hardware-specific code lives under `platforms/<target>/` and must wrap the core logic via small interfaces.

2. **Directory Structure (target)**
   - `core/` – hardware-agnostic app logic
     - `player_app.py` – main state machine & input handling
     - `models.py` – `Track`, `PlayerState`, enums like `ButtonEvent`
     - `interfaces.py` – `Screen`, `AudioBackend`, `InputSource` interfaces
   - `platforms/pc/` – PC simulator implementation
     - `console_screen.py`
     - `keyboard_input.py`
     - `pc_audio_backend.py` (stub or real)
     - `main_pc.py`
   - `platforms/esp32/` – MicroPython implementation
     - `esp_screen.py`
     - `esp_buttons.py`
     - `esp_audio_backend.py`
     - `main_esp32.py`
   - `hardware/` – notes on boards, pinouts, wiring, and later PCB
   - `enclosure/` – 3D models, measurements, and notes
   - `tests/` – pytest unit tests for `core/`

3. **Language & Style**
   - Python 3.11+ style for PC side; MicroPython-compatible subset for ESP32 side.
   - Use **type hints** in `core/` where reasonable.
   - Prefer **small, testable functions** over large, monolithic ones.

4. **Testing**
   - `tests/` targets only `core/` modules.
   - Tests focus on:
     - Navigation (library, now playing, settings)
     - Button behavior
     - Playback state transitions
     - Edge cases (start/end of list, play/pause transitions, etc.)
   - Run tests locally: `source .venv/bin/activate && pytest`
   - Run PC simulator (after implemented): `source .venv/bin/activate && python -m platforms.pc.main_pc`
   - PC simulator controls (console): `w/s` up/down, `a` left, `d` right, `space`/Enter select, `p` play/pause, `b/q` back, `x` quit. Uses dummy tracks + print-only audio.
   - Optional `--music-dir` for simulator uses folder convention `Artist/Album/Track.ext` with simple filename parsing; no tag reading.
   - Volume controls: `+`/`=` volume up, `-` volume down (clamped 0–100, forwarded to audio backend).

---

## Agents

### 1. Product & Architecture Agent

**Purpose:**  
Own the high-level design and keep the system coherent and simple.

**Responsibilities:**

- Maintain an up-to-date mental model of:
  - Screens: **Library**, **Now Playing**, **Settings** (and future ones)
  - Navigation model: which buttons do what on each screen
  - Data model: `Track`, `Playlist`, `PlayerState`
- Define/maintain **interfaces** used across the project:
  - `Screen`, `AudioBackend`, `InputSource` (or equivalent)
- Ensure changes keep the **PC simulator** and **ESP32** implementations aligned.
- Spot over-engineering and push for **simple, shippable** solutions.

**When to use this agent:**

- “Design a clean interface for the display that can work on both PC and ESP32.”
- “Refactor the project structure to keep core logic hardware-agnostic.”
- “Propose a navigation flow for library ↔ now playing ↔ settings.”

---

### 2. Core App Logic Agent

**Purpose:**  
Implement and evolve the **hardware-agnostic** application logic.

**Responsibilities:**

- Implement `PlayerApp` (or equivalent) that:
  - Holds `PlayerState`
  - Handles `ButtonEvent`s
  - Chooses which screen to render
  - Calls `Screen` and `AudioBackend` but never touches GPIO or hardware directly
- Implement domain models:
  - `Track`, `PlayerState`, `ButtonEvent`, screen identifiers, etc.
- Ensure the core logic runs **unchanged** on both:
  - `platforms/pc/main_pc.py`
  - `platforms/esp32/main_esp32.py`
- Add or update **unit tests** under `tests/` when behavior changes.

**Conventions:**

- `PlayerApp` should accept injected dependencies:
  ```python
  class PlayerApp:
      def __init__(self, state: PlayerState, screen: Screen, audio_backend: AudioBackend):
          ...
  ```
- Button inputs should be modeled as enums or small value types, never as raw keys or pin numbers.
- Core app must not import any platforms.* modules.
