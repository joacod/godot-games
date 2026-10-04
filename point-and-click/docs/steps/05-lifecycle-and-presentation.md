# Step 05 — Completion, restart and readable room

## Entry condition

Complete Step 04 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Finish menus, clean restart, hints and presentation for the timed adventure slice.

## Planned files

These paths are relative to `point-and-click/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scripts/main.gd`
- `scenes/ui/menus.tscn`
- `scripts/menu_ui.gd`
- `scenes/room.tscn`
- `tests/restart_test.gd`

## Work

1. Add start, pause/restart and completion presentation, preserving the fixed camera.
2. Restart reconstructs room, inventory, puzzle flags and dialogue cursor; no stale selected item or modal remains.
3. Use visual state changes for taken oil, repaired press and open gate; labels supplement shapes and color.
4. Check full sentences and choices at the target resolution; fit inventory slots and avoid clipping long data text.
5. Do not add a loss condition to a puzzle designed to be recoverable. Completion and restart satisfy this game’s terminal flow.

## Completion gate

- [x] Restart at initial, mid-puzzle, dialogue-open and complete states returns the same fresh puzzle.
- [ ] A new player can follow hints and finish in two to four minutes.
- [x] Wrong actions and rapid repeated clicks produce no console errors or accidental transitions.

Run the import and test commands in [DESIGN.md](../DESIGN.md), extending
`tests/run_tests.gd` to include this step's behavioral checks. Run the native
launch command for its visual/input checks. Record results and unresolved gaps
in `docs/ACCEPTANCE.md`, including generated `.gd.uid` coverage.

Implementation and automated/native evidence are recorded in
[ACCEPTANCE.md](../ACCEPTANCE.md#step-05--2026-10-04). The new-player timing gate
remains unchecked until a human playthrough is recorded.

## Boundaries and handoff

Modify only this game and its OpenSpec progress/evidence. Existing games,
sibling new games, engine version and renderer remain untouched. Do not add
later-step mechanics while completing this step. Do not commit, branch, push,
or publish unless separately requested. Report exact files changed, behavior,
commands/results, manual checks, intentionally untouched files and next step.
