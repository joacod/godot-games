# Step 06 — Acceptance and independent reskin proof

## Entry condition

Complete Step 05 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Close all checklist items, document evidence, and demonstrate a data/visual-only reskin in an isolated copy.

## Planned files

These paths are relative to `survivors/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `docs/ACCEPTANCE.md`
- `docs/DESIGN.md`
- `README.md`
- `assets/PROVENANCE.md`
- `tests/`
- `data/ and visual scenes only if tuning fixes are necessary`

## Work

1. Run all import and behavioral checks; fix only slice defects exposed by them.
2. Follow the DESIGN.md acceptance route in a native window. Save a representative 15-second mid-run capture and note whether threats and pickup attraction remain legible.
3. Copy the game outside the repository, omit .godot, and change character name, palette, actor visual and a weapon tuning value in data. Confirm unchanged mechanics-script hashes.
4. Launch and complete the copy without sibling files. Record separate automated, visual, keyboard and human-balance evidence; no controller claim.
5. Update the README copy instructions and actual content paths. Mark OpenSpec tasks complete only when evidence supports them; archive only after the game is accepted.

## Completion gate

- [ ] Complete win route in under five minutes including menus; short loss/retry route passes.
- [ ] Isolated copy imports, runs, and finishes with new presentation and unchanged mechanics.
- [ ] No unresolved console errors or unverified acceptance items are silently labeled passed.

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
