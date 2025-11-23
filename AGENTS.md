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

Doc map: see `docs/README.md` for where plans, tasks, and platform notes live.

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

**When to use this agent:**

* “Implement the state machine for play/pause/next/previous.”
* “Add support for a Settings screen that can toggle shuffle on/off.”
* “Add tests for wrapping behavior when pressing DOWN on the last track.”

---

### 3. PC Simulator Agent

**Purpose:**
Provide a usable, fast feedback loop on a **normal computer** without hardware.

**Responsibilities:**

* Implement `ConsoleScreen` (or simple GUI later) that conforms to `Screen`.

  * Start with a simple “clear + print text” approach.
* Map keyboard input → `ButtonEvent`s:

  * For example: `w/s/a/d` = up/down/left/right, space = select, `p` = play/pause, `q` = back.
* Implement `pc_audio_backend.py`:

  * **Phase 1:** print debug logs (“Playing: Song One”).
  * **Phase 2 (optional):** actually play MP3s via a PC audio library.
* Implement `platforms/pc/main_pc.py` that:

  * Creates test tracks
  * Instantiates `PlayerApp`
  * Loops on user key input

**When to use this agent:**

* “Create a simple console-based UI to exercise the core logic.”
* “Add a nicer text layout for the Library and Now Playing views.”
* “Add a command-line argument to load tracks from a directory on disk.”

---

### 4. ESP32 & Hardware Integration Agent

**Purpose:**
Adapt the core logic to run on real **ESP32 hardware with MicroPython**.

**Responsibilities:**

* Choose and document the specific ESP32 dev board being targeted.
* Implement MicroPython versions of the interfaces:

  * `EspScreen` using specific display drivers (e.g. ST7735, ST7789, SSD1306, etc.)
  * `EspButtons` reading GPIO pins and debouncing into `ButtonEvent`s
  * `EspAudioBackend` that:

    * **Phase 1:** stub (log actions, maybe blink an LED)
    * **Phase 2:** real audio via I2S or Bluetooth A2DP, depending on feasibility
* Implement `platforms/esp32/main_esp32.py` that:

  * Initializes hardware
  * Instantiates `PlayerApp`
  * Runs a main loop reading button events and calling `handle_button`

**Constraints / Notes:**

* Keep MicroPython memory and speed limits in mind.
* Avoid heavy Python stdlib features that aren’t supported in MicroPython.
* Where MicroPython lacks a feature, provide a thin compatibility shim that preserves the `core/` API.

**When to use this agent:**

* “Write a MicroPython driver wrapper that implements Screen for an ST7789 display.”
* “Map 6 GPIO pins to UP/DOWN/LEFT/RIGHT/SELECT/BACK with debouncing.”
* “Create a minimal main loop for ESP32 that calls into `PlayerApp`.”

---

### 5. Testing & Quality Agent

**Purpose:**
Ensure the behavior of the core app logic is well-specified and stable as the project evolves.

**Responsibilities:**

* Design and maintain **pytest** test suites for `core/` modules.
* Define test scenarios for:

  * Library navigation
  * Play/pause behavior
  * Switching between screens
  * Edge conditions (start/end list, no tracks, etc.)
* Keep tests fast and independent of hardware:

  * Use dummy `Screen` and `AudioBackend` implementations.
* Ensure that any change to core logic comes with appropriate test coverage.

**Conventions:**

* Use small dummy classes like:

  ```python
  class DummyScreen(Screen):
      def __init__(self):
          self.calls = []

      def clear(self):
          self.calls.append("clear")

      def draw_text(self, x, y, text):
          self.calls.append(("draw_text", x, y, text))

      def refresh(self):
          self.calls.append("refresh")
  ```
* Favor behavior-driven test names, e.g.:

  * `test_down_moves_selection`
  * `test_play_sets_playing_index`
  * `test_back_from_now_playing_returns_to_library`

**When to use this agent:**

* “Write tests that define how the Now Playing screen should behave.”
* “Add regression test for the bug where selection wraps incorrectly.”
* “Refactor tests to reduce duplication and make intent clearer.”

---

### 6. Enclosure & Hardware-Mechanical Agent (Optional / Later)

**Purpose:**
Translate the working dev board + wiring into a physically usable, 3D-printed MP3 player.

**Responsibilities:**

* Document physical dimensions and port locations of the chosen ESP32 board, display, buttons, and battery.
* Design an enclosure that:

  * Accommodates the final hardware stack
  * Supports tactile buttons in comfortable positions
  * Has adequate ventilation if needed
* Manage iterations of the case as STL or CAD files in `enclosure/`.

**When to use this agent:**

* “Propose a basic front layout resembling an iPod with a ring of buttons.”
* “Adjust case dimensions after we finalize the button placement.”
* “Create a printable test piece to validate button spacing.”

---

## How to Work With These Agents

When asking Codex/agents to help, it’s useful to:

* **Pick a primary agent** based on the task domain and mention it explicitly:

  * “As the **Core App Logic Agent**, refactor `PlayerApp` to support playlists.”
* If overlap is needed, call that out:

  * “As the **Product & Architecture Agent**, propose an interface change; then as the **Core App Logic Agent**, implement it and add tests.”
* Keep tasks **small and concrete**, especially when touching hardware-specific modules:

  * e.g. “Implement a dummy `AudioBackend` for PC that just prints to stdout.”

---

## Initial Milestones (For All Agents)

1. **Milestone 1 – Core + PC Simulator**

   * [ ] `core/` models (`Track`, `PlayerState`, `ButtonEvent`)
   * [ ] `PlayerApp` handling navigation + play/pause
   * [ ] Basic PC console UI with keyboard mapping
   * [ ] Pytest coverage for core logic

2. **Milestone 2 – ESP32 Prototype**

   * [ ] MicroPython port of `core/` (as-is or with minor tweaks)
   * [ ] ESP32 display driver implementing `Screen`
   * [ ] Button GPIO → `ButtonEvent` mapping
   * [ ] Stub `EspAudioBackend`

3. **Milestone 3 – Audio + Usability**

   * [ ] Real audio playback strategy on ESP32 (I2S or Bluetooth)
   * [ ] Improved UI (track metadata, simple progress indicator)
   * [ ] First iteration of enclosure concept

Each agent should align their work with the relevant milestone and ensure changes do not break the **PC simulator** or the **core tests**.
