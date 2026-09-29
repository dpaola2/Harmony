# Documentation Map

This repo keeps a small set of living docs, each with a clear purpose. Use this map to find or add information without duplicating content.

## September 2026 device proposal

- [Firmware baseline](../firmware/README.md): verified ESP32/SAMD builds, scripts, source pins, and hardware validation limits.
- [Board reconciliation](../hardware/procurement/reconciliation/tangara-interface-bom-reconciliation.md): PCB component inventory and exact battery/display interfaces.

- [Shopping list](../hardware/procurement/README.md): current sources, quantities, costs, and compatibility holds.
- [Implementation plan](Harmony-2026-implementation-plan.md): stages, review decisions, and acceptance tests.

- [Approach reassessment](Harmony-2026-reassessment.md): recommendation against the updated device goals.
- [Technical basis](Harmony-2026-technical-basis.md): options, architecture, sourcing limits, and acceptance criteria.
- [Printable case](../enclosure/harmony-r1/README.md): Tangara-based fit prototype for the Bambu A1.

## Current Mark-7 scope

- [Portable build scope](mark-7-portable-scope.md): adopted September 28 reuse, internal SD access, perfboard assembly, power work and acceptance.

## Current player UI

- [Mark-6 lessons and portable next step](mark-6-lessons-and-portable-next-step.md): battery proof, carrier tradeoffs and proposed Mark-7 purpose.

- [Changelog](../CHANGELOG.md): dated implementation, fixes and validation.
- [Mark-7 visual reference](mark-7-design-reference.md): frozen desktop appearance and capacitive-wheel/battery design direction.

- [Native Feather UI bench](../firmware/mark-6/feather-player-bench/README.md): device music tree, Now Playing, controls, and current limits.

- [Interactive desktop prototype](../platforms/pc/ui/README.md): run the 320 × 480 menu and wheel simulation using the 45-track trial library.
- [Player UI requirements](Harmony-player-ui-requirements.md): Accepted Mark-6 scope (HARMONY-18), covering music navigation, controls, volume, and Bluetooth management on the verified Feather bench.

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
