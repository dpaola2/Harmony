# Documentation Map

This repo keeps a small set of living docs, each with a clear purpose. Use this map to find or add information without duplicating content.

## Core docs
- `PROJECT_OVERVIEW.md` — why the project exists, constraints, and hardware/software goals.
- `PLAN.md` — roadmap and near-term milestones; keep current sprint items at the top.
- `TASKS.md` — live task queue and in-flight gameplans (per callsign).
- `docs/gameplans/` — archived or long-form gameplans by callsign (move sections here once done or if they get lengthy).
- `AGENTS.md` — roles, responsibilities, and collaboration rules. Update only when roles change.

## Platform & hardware
- `platforms/pc/` — PC simulator code; add a `README.md` here if setup diverges from the root README.
- `platforms/esp32/` — MicroPython adapters for ESP32 targets.
- `hardware/prototype1/README.md` — Prototype 1 wiring, bring-up, and testing (ESP32-S3 DevKitC-1 v1.1).
- `hardware/prototype2/README.md` — Prototype 2 notes (WROVER/audio) when ready.
- `hardware/production/` — production-focused notes and (later) BOM/PCB details.
- `enclosure/` — mechanical/3D-print notes.

## Testing & running
- Root `README.md` — quickstart for macOS dev setup, how to run the PC simulator, and how to run tests.
- Platform-specific run/test steps live in the relevant platform or hardware README (e.g., `hardware/prototype1/README.md` for flashing and device tests).

## How to handle gameplans and tasks
- Active gameplans: keep with their callsigns in `TASKS.md` so they are visible during execution.
- Short-term roadmap: keep in `PLAN.md` and cross-link to detailed gameplan sections in `TASKS.md`.
- Archive: move completed/obsolete task or gameplan sections from `TASKS.md` into `docs/gameplans/<callsign>.md`, noting the callsign and date if helpful.
- Long-form design notes: if a gameplan gets large, place it under `docs/gameplans/<callsign>.md` and link it from `TASKS.md` and `PLAN.md`.

## Cross-linking
- Each doc should include brief “see also” pointers to adjacent docs (e.g., `README.md` → `PLAN.md`, `TASKS.md`, relevant platform README).
- Avoid duplicating content; link instead. Keep summaries at the top of each doc to speed up navigation.
