# Step 06 — Acceptance and standalone bunker reskin

## Entry condition

Complete Step 05 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Prove timed completion, collision/AI behavior and independent visual/data replacement.

## Planned files

These paths are relative to `shooter/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `docs/ACCEPTANCE.md`
- `docs/DESIGN.md`
- `README.md`
- `assets/PROVENANCE.md`
- `tests/`
- `theme/content tuning fixes as needed`

## Work

1. Run the import and behavioral suite and follow the native under-five-minute route.
2. Verify mouse capture, aim, corners, hit feedback, both enemy tells and no damage through walls with real input.
3. Copy the game outside the repository without .godot. Change wall materials, enemy visual child scenes, item names and weapon tuning through data.
4. Compare mechanics-script hashes, import the copy and finish its level without sibling folders.
5. Record win and death/retry logs, actual completion time and human balance gaps. Finalize copy/edit guidance; mark only evidenced tasks complete.

## Completion gate

- [ ] Complete in under five minutes and pass short loss/retry with no console errors.
- [ ] Copied reskin preserves collision, line of sight, key gating and completion without mechanics edits.
- [ ] Documentation distinguishes native input/playtesting from automated evidence.

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
