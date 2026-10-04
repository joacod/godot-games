# Step 03 — Six-slot inventory and atomic item use

## Entry condition

Complete Step 02 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Add item selection, pickup and conditional use, including the oil/press state transition.

## Planned files

These paths are relative to `point-and-click/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scripts/inventory.gd`
- `scripts/puzzle_state.gd`
- `scenes/ui/inventory_bar.tscn`
- `scripts/inventory_ui.gd`
- `data/puzzle.json`
- `tests/inventory_actions_test.gd`

## Work

1. Store item IDs with a six-item capacity; disallow discarding required items and duplicate unique items.
2. Picking up oil validates capacity before hiding its hotspot or setting oil_taken.
3. Select an item to show Use [item] with [target], and support right-click cancellation.
4. Validate conditions and capacity before applying all effects as one transaction. Repairing the press consumes oil and sets the repaired flag once.
5. Wrong targets and repeated actions leave state unchanged with authored responses.

## Completion gate

- [x] Full inventory fixture leaves a pickup available; item count never exceeds six.
- [x] Oil on clerk does not consume oil; oil on press consumes exactly once and changes presentation.
- [x] Cancel restores normal verb interaction; UI clicks do not leak to the room.

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


## Evidence — 2026-10-03

Complete. Import passed; headless checks passed 211/211 and native captures
passed 215/215. Agent native mouse checks cover pickup, wrong-target retention,
right-click cancellation, repair and repeated-use feedback. See
[acceptance evidence](../ACCEPTANCE.md#step-03--2026-10-03) for boundaries and commands.
