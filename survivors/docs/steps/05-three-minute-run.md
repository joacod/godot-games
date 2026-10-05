# Step 05 — Spawn pacing, elite and outcomes

## Entry condition

Complete Step 04 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Assemble the complete 180-second slice and tune it against the timed route.

## Planned files

These paths are relative to `survivors/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scripts/spawn_director.gd`
- `scripts/run.gd`
- `scenes/ui/hud.tscn`
- `scenes/ui/result.tscn`
- `data/run.tres`
- `data/enemies/elite_crawler.tres`
- `tests/run_lifecycle_test.gd`

## Work

1. Implement the three spawn phases, population cap and one elite at 120 seconds. Mark safe edge entry when offscreen spawning is impossible.
2. Display HP, XP, level, equipped weapon icons and time. Victory occurs at 180 active seconds if still alive; evaluate lethal damage before victory when both occur in the same physics tick.
3. Stop spawning, attacks and pickups on outcome. Retry reconstructs all run state and does not retain signal connections or delayed callbacks.
4. Tune XP and enemy cadence so a normal completion can unlock all weapons and evolve Spark by 150 seconds. Keep the content count locked.

## Completion gate

- [x] Fast-forward controlled test time across 60/120/180-second boundaries; no duplicate elite or late spawns.
- [x] Pause leaves timer and schedule unchanged; living-enemy cap holds.
- [x] Finish a real 180-second run, then a short loss/retry route, with no errors. Record actual timings and progression.

The timed route above was completed with scripted native input on 2026-10-05.
Physical input and human balance acceptance remain pending; see
[acceptance evidence](../ACCEPTANCE.md).

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
