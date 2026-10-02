# Beat 'Em Up

A single-player, one-level street brawler inspired by Final Fight, in development.
Build a complete, enjoyable game first; make later art swaps straightforward
through ordinary Godot scenes and Inspector values.

**Status: Step 01 foundation implemented; asset adaptations pending review.**
The project opens an automatic street art preview with a hero and an enemy.
It cycles idle, locomotion, and attack animations at fixed ground anchors.
Movement, combat, AI, and menus are not implemented.

## Open and run

Import `project.godot` into Godot **4.7.2**, then press **F5**. The independent
project uses GDScript and the Compatibility renderer. The logical viewport is
640 × 360, displayed in a 1280 × 720 window with nearest filtering and preserved
aspect ratio. Cyan crosses mark feet; the preview advances every 2.4 seconds.

From the repository root on this Mac:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --editor --path beat-em-up
```

Keyboard and controller bindings from the design are configured in Input Map,
with a 0.25 stick deadzone, but the sample does not consume gameplay input.
Close the window to exit. Menu confirmation excludes Space; the future run
owner still needs to implement the release guard described in the design.

## Validate

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path beat-em-up --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --quit-after 120
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --quit-after 780
git diff --check
```

The third command exercises a complete preview cycle. Inspect logs for errors;
headless success does not establish rendering, gameplay, or controller behavior.
See the [Step 01 record](docs/steps/01-foundation.md#completion-record) for results.

## Start here

- [Implementation plan](docs/PLAN.md): scope, order, status, and step boundaries.
- [Game design](docs/DESIGN.md): controls, combat rules, level, and scene ownership.
- [Asset brief](ASSETS.md): CraftPix candidates, required animations, and replacement rules.
- [Acceptance checklist](docs/ACCEPTANCE.md): automated and hands-on validation.

This project does not depend on `2d-platform`. Each later step requires a short
approach review, ends with validation, and stops before the next step.
