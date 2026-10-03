# Add point-and-click

## Why

Provide an independent one-level example that can be copied and reskinned for
future games without changing its mechanics or depending on other projects.
This change records the researched handoff first; implementation is future work.

## What Changes

Fixed-room adventure with three verbs, bounded inventory, external dialogue and one recoverable puzzle chain.

Create `point-and-click/` as its own Godot 4.7 project, with 4.7.2 development checks,
local content data and replaceable visuals. Deliver six bounded implementation
steps with automated and native acceptance gates.

Out of scope: No combat, camera scrolling, avatar pathfinding, save system or branching endings.

## Capabilities

### New Capabilities

- `point-and-click-slice`: Fixed-room adventure with three verbs, bounded inventory, external dialogue and one recoverable puzzle chain.

### Modified Capabilities

None. Neither existing game's behavior or requirements change.

## Impact

Runtime work is confined to `point-and-click/`; planning lives in this OpenSpec change.
No shared launcher, autoload, codebase, runtime dependency or required asset
purchase. Existing `2d-platform/` and `beat-em-up/` remain unchanged.

See [the canonical design](../../../point-and-click/docs/DESIGN.md) and
[the step index](../../../point-and-click/docs/STEPS.md).
