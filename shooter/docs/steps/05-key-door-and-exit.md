# Step 05 — Key, health, locked door and complete route

## Entry condition

Complete Step 04 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Complete the objective route, pickups, terminal states and full retry reset.

## Planned files

These paths are relative to `shooter/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scenes/locked_door.tscn`
- `scripts/locked_door.gd`
- `scenes/pickup.tscn`
- `scripts/pickup.gd`
- `scenes/exit.tscn`
- `scripts/run.gd`
- `tests/objective_lifecycle_test.gd`

## Work

1. Collect key once; E at the aimed nearby door produces locked feedback without it and opens permanently with it.
2. Keep door collision and pathfinding solidity in agreement throughout opening, then clear both together.
3. Health pickups clamp at maximum and remain unused while healthy.
4. Gate the exit by door-open state; show victory on entry. Resolve lethal damage before victory if both occur in one physics tick.
5. Retry restores maze occupancy, player pose, health, key, pickups, all six enemies, weapon cooldown and mouse/menu state.

## Completion gate

- [ ] Cannot interact from across the maze, open without key or bypass the door.
- [ ] Health at maximum does not waste a pickup; injured pickup heals correctly once.
- [ ] Full route and separate short death/retry pass without errors; opened door becomes navigable to guards.

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
