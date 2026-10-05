# Step 03 — Four automatic weapons

Historical snapshot from implementation on 2026-10-05. Pending items and
future-tense statements below describe that stage. See the
[current acceptance record](../../ACCEPTANCE.md) for final status.

## Entry condition

Complete Step 02 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Implement and verify all four attack behaviors and death handling, using a test loadout before the progression system exists.

## Planned files

These paths are relative to `survivors/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scripts/weapon_rack.gd`
- `scripts/projectile.gd`
- `scripts/orbit_attack.gd`
- `scripts/pulse_attack.gd`
- `scenes/attacks/`
- `data/weapons/`
- `tests/weapons_test.gd`

## Work

1. Implement Spark nearest-target shots, Halo orbital contact, Pulse radial damage and Shard cardinal bursts from their data.
2. Separate targeting/cadence from attack lifetime; delete expired attacks and guard against freed or already dead targets.
3. Define collision layers for player, enemies, attacks and pickups. Attacks cannot damage the player.
4. Give each effect a readable shape; hit feedback must leave the player silhouette visible. Use a test-only loadout fixture to exercise all four without adding debug controls to the player flow.

## Completion gate

- [ ] Each weapon damages the intended targets at the configured cadence, including no-target behavior.
- [ ] One target receives at most one damage event per intended hit window; dead enemies are removed once.
- [ ] Run a 15-second native combat sample and check distinct attacks and readable player position.

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
