# Add survivors

## Why

Provide an independent one-level example that can be copied and reskinned for
future games without changing its mechanics or depending on other projects.
This change records the researched handoff first; implementation is future work.

## What Changes

Movement-only bullet heaven with four weapons, XP, three upgrade choices, one evolution and a three-minute survival run.

Create `survivors/` as its own Godot 4.7 project, with 4.7.2 development checks,
local content data and replaceable visuals. Deliver six bounded implementation
steps with automated and native acceptance gates.

Out of scope: No meta progression, extra biomes, boss marathon or manual aiming/firing.

## Capabilities

### New Capabilities

- `survivors-slice`: Movement-only bullet heaven with four weapons, XP, three upgrade choices, one evolution and a three-minute survival run.

### Modified Capabilities

None. Neither existing game's behavior or requirements change.

## Impact

Runtime work is confined to `survivors/`; planning lives in this OpenSpec change.
No shared launcher, autoload, codebase, runtime dependency or required asset
purchase. Existing `2d-platform/` and `beat-em-up/` remain unchanged.

See [the canonical design](../../../survivors/docs/DESIGN.md) and
[the step index](../../../survivors/docs/STEPS.md).
