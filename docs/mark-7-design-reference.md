# Harmony Mark-7 visual reference

Saved September 27, 2026, at Dave's request. The approved desktop prototype is preserved by the annotated tag `mark7-visual-reference-20260927`, pointing to commit `1a3990b`.

[Browse the preserved source](https://github.com/dpaola2/Harmony/tree/mark7-visual-reference-20260927/platforms/pc/ui).

Preserve the warm cream body, rounded enclosure, large portrait screen, dark green typography and highlights, restrained Now Playing record graphic, and smooth recessed circular wheel with a center control. Dave particularly likes the device's visual appearance and sees a capacitive wheel working well with battery integration in Mark-7.

This is an adopted visual reference and a hardware exploration direction. Wheel sensing, dimensions, internal layout, battery fit, charging and runtime still need design and physical qualification. The current Mark-6 uses its mechanical ANO wheel and USB-powered Feather bench.

## Reproduce the reference

From the Harmony repository, create a separate checkout of the tag:

```sh
git worktree add --detach ../Harmony-mark7-reference mark7-visual-reference-20260927
cd ../Harmony-mark7-reference
python3 -m platforms.pc.ui_server --help
```

Run `python3 -m platforms.pc.ui_server` and open `http://127.0.0.1:8766` when that port is free. The source includes the 45-track metadata fixture. It includes no music audio. Playback and Bluetooth outcomes are simulated. See the prototype README for controls.

## Sources and scope

- Dave's September 27 feedback: “I actually really like the visual of what you have in the web prototype. make sure we save that for mark 7. looks like a capacative wheel, and it would go well with the battery etc.”
- [Prototype source and controls](../platforms/pc/ui/README.md).
- [Full Mark-6 UI requirements](Harmony-player-ui-requirements.md), Complete Mark-6 player UI (HARMONY-18), under Harmony Mark-6: Bluetooth bench player (HARMONY-17).

All adopted UI functionality remains in Mark-6. This reference reserves the physical visual direction for Mark-7; it does not move unfinished Mark-6 features to a later version.
