# Step 06 — Acceptance and independent adventure reskin

## Entry condition

Complete Step 05 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Prove the complete puzzle and a presentation/data swap without mechanic changes.

## Planned files

These paths are relative to `point-and-click/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `docs/ACCEPTANCE.md`
- `docs/DESIGN.md`
- `README.md`
- `assets/PROVENANCE.md`
- `tests/`
- `presentation/data fixes only as needed`

## Work

1. Run import and behavioral checks, including inventory capacity and invalid dialogue-reference fixtures.
2. Perform the full timed checklist with native mouse input and record completion time, text readability, invalid-action feedback and restart.
3. Copy the project outside the repository without .godot. Change room art, clerk name, oil/pass display names and dialogue text; preserve IDs for this cosmetic reskin.
4. Verify mechanics hashes do not change and the copied puzzle still finishes without any sibling folders.
5. Record asset coverage and license evidence separately from gameplay acceptance. Update exact editing paths and complete only evidenced OpenSpec tasks.

## Completion gate

- [ ] Under-five-minute completion, invalid-action recovery and restart all pass with no errors.
- [ ] Reskinned standalone copy completes the same puzzle; all dialogue remains external.
- [ ] No claim of controller, save/load, extra rooms or unseen final art is added.

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
