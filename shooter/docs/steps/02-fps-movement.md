# Step 02 — WASD, mouse look and pause capture

## Entry condition

Complete Step 01 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Add first-person movement, camera and reliable mouse ownership.

## Planned files

These paths are relative to `shooter/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scenes/player.tscn`
- `scripts/player_movement.gd`
- `scripts/mouse_look.gd`
- `scenes/ui/pause.tscn`
- `tests/player_input_test.gd`

## Work

1. Use CharacterBody3D and a collision capsule with comfortable clearance inside 2 m cells.
2. Apply mouse yaw and clamped pitch; keep horizontal movement on XZ with no jump/crouch.
3. Capture mouse on explicit start/resume; Escape, focus loss and result menus release it.
4. Normalize movement, block wall penetration and keep the camera inside its body clearances.
5. Consume resume click so later weapon logic cannot treat it as fire.

## Completion gate

- [ ] Player moves and looks naturally; diagonals do not accelerate movement.
- [ ] Walls/corners block movement and camera does not clip through them.
- [ ] Escape and focus changes release mouse; explicit resume restores it without an extra action.

Run the import and test commands in [DESIGN.md](../DESIGN.md), extending
`tests/run_tests.gd` to include this step's behavioral checks. Run the native
launch command for its visual/input checks. Record results and unresolved gaps
in `docs/ACCEPTANCE.md`, including generated `.gd.uid` coverage.

## Boundaries and handoff

Modify only this game and its OpenSpec progress/evidence. Existing games,
sibling new games, engine version and renderer remain untouched. Do not add
later-step mechanics while completing this step. Do not commit, branch, push,
or publish unless separately requested. Report exact files changed, behavior,
commands/results, manual checks, intentionally untouched files and next step.
