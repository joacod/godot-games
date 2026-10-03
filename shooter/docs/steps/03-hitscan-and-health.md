# Step 03 — Hitscan combat, damage and death

## Entry condition

Complete Step 02 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Implement the blaster and reusable local health behavior against stationary damage fixtures.

## Planned files

These paths are relative to `shooter/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scripts/weapon.gd`
- `scripts/health.gd`
- `scenes/ui/hud.tscn`
- `data/weapon.tres`
- `tests/hitscan_health_test.gd`

## Work

1. Fire from camera aim using a refreshed ray, fixed cooldown and unlimited ammunition.
2. Define world/door/actor collision masks and exclude the shooter. Resolve only the first obstruction within range.
3. Implement clamped HP, one death event, visible hit feedback and basic defeat/retry.
4. Add crosshair and HP HUD; optional CraftPix icon only if inspected and recorded, never as a 3D viewmodel substitute.

## Completion gate

- [ ] An exposed target takes configured damage; a target behind wall or door does not.
- [ ] Held fire respects cooldown and empty shots cause no error.
- [ ] Lethal damage emits one outcome, disables fire and retry restores HP.

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
