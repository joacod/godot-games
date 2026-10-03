# Step 04 — Guard pursuit and sentry shots

## Entry condition

Complete Step 03 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Add the two specified enemy behaviors and grid path queries without squad behavior.

## Planned files

These paths are relative to `shooter/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scenes/enemies/guard.tscn`
- `scenes/enemies/sentry.tscn`
- `scripts/enemy.gd`
- `scripts/maze.gd`
- `data/enemies/`
- `tests/enemy_test.gd`

## Work

1. Implement IDLE/CHASE/ATTACK/DEAD; guard pursues the last seen player cell, sentry stays in place.
2. Use wall-aware sight and a visible sentry windup. Recheck sight at firing time and cancel occluded attacks.
3. Build AStarGrid2D for XZ, disable diagonal movement, and mark wall/door cells solid after update(). Repath on cell changes or bounded cadence.
4. Make guard contact damage rate-limited. Death disables attacks and blocking collision immediately.
5. Use distinct primitive shapes, scale and labels for the two types; no dependency on directional sprite packs.

## Completion gate

- [ ] Guard routes around corners without diagonal wall cutting; unreachable paths remain safe.
- [ ] Sentry detects, telegraphs and shoots only through clear sight, including occlusion during windup.
- [ ] Both types die and stop damaging; native encounter reads clearly.

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
