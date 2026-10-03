# Step 04 — XP, three choices and one evolution

## Entry condition

Complete Step 03 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Add gems, pickup magnet, level-up UI, upgrade eligibility and the Spark/Lens evolution.

## Planned files

These paths are relative to `survivors/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scripts/xp_progression.gd`
- `scripts/xp_gem.gd`
- `scripts/upgrade_choices.gd`
- `scenes/xp_gem.tscn`
- `scenes/ui/upgrade_menu.tscn`
- `data/upgrades/`
- `tests/progression_test.gd`

## Work

1. Award gem XP once per enemy death. Attract nearby gems toward the player and collect each once; do not mutate content Resources.
2. Use data thresholds, preserve excess XP, and queue multiple earned levels. Pause run time, spawning, physics damage and attack cadence while resolving choices.
3. Offer exactly three distinct effective choices; implement weapon-unlock priority, Lens offer by level 3, Spark rank priority and repeatable fallbacks from DESIGN.md.
4. Handle either order of rank-3 Spark and Lens. Replace Spark in place with Arc Spark once; clear old attacks as appropriate and preserve other weapon slots.
5. Consume menu confirmation before resuming. Extend retry to clear XP, choices, ranks, passives and gems.

## Completion gate

- [ ] Threshold boundary and multi-level grants preserve XP; each panel applies exactly one choice.
- [ ] Test exhausted ranks, Lens owned, full HP and an existing shield: Recovery, Power and Reach remain three effective distinct options.
- [ ] Both acquisition orders evolve once; chains cannot strike one enemy repeatedly in a single shot.
- [ ] Native gem attraction and pause/resume feel clear, with no damage during a choice.

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
