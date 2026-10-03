# Add shooter

## Why

Provide an independent one-level example that can be copied and reskinned for
future games without changing its mechanics or depending on other projects.
This change records the researched handoff first; implementation is future work.

## What Changes

Native 3D grid maze with hitscan, two enemy types, one key and locked door, health and an exit.

Create `shooter/` as its own Godot 4.7 project, with 4.7.2 development checks,
local content data and replaceable visuals. Deliver six bounded implementation
steps with automated and native acceptance gates.

Out of scope: No ADS, reload minigame, squad AI, vehicles, vertical levels or custom raycasting renderer.

## Capabilities

### New Capabilities

- `shooter-slice`: Native 3D grid maze with hitscan, two enemy types, one key and locked door, health and an exit.

### Modified Capabilities

None. Neither existing game's behavior or requirements change.

## Impact

Runtime work is confined to `shooter/`; planning lives in this OpenSpec change.
No shared launcher, autoload, codebase, runtime dependency or required asset
purchase. Existing `2d-platform/` and `beat-em-up/` remain unchanged.

See [the canonical design](../../../shooter/docs/DESIGN.md) and
[the step index](../../../shooter/docs/STEPS.md).
