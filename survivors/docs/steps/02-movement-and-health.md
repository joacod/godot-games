# Step 02 — Movement, health and a pursuer

## Entry condition

Complete Step 01 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Add movement and damage against one manually placed crawler; keep automatic spawning and XP out of this step.

## Planned files

These paths are relative to `survivors/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scenes/player.tscn`
- `scenes/enemy.tscn`
- `scripts/player_movement.gd`
- `scripts/enemy.gd`
- `scripts/health.gd`
- `scripts/run.gd`
- `tests/movement_health_test.gd`

## Work

1. Use normalized Input.get_vector movement, bounded collisions and a camera limited to the arena.
2. Add a crawler that pursues the player on the open ground plane; share no code with existing games.
3. Implement health, per-player contact invulnerability, hit flash and death signals. Clamp HP and emit death once.
4. Provide a minimal defeat panel and full run rebuild for retry; later steps extend reset coverage.

## Completion gate

- [ ] Diagonal movement is not faster; player cannot cross boundaries.
- [ ] Continuous contact respects the damage interval and death happens once.
- [ ] Native movement, camera edges, hit readability and fresh-health retry work.

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
