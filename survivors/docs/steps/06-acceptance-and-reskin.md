# Step 06 — Acceptance and independent reskin proof

## Entry condition

Complete Step 05 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Close all checklist items, document evidence, and demonstrate a data/visual-only reskin in an isolated copy.

## Files in scope

These paths are relative to `survivors/`. The original gameplay Resources and
visual scenes remain unchanged; reskin mutations happen only in the copy.

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

- [ ] Complete human win route in under five minutes including menus; short loss/retry route passes. Scripted native routes passed; human completion remains pending.
- [x] Isolated copy imports, runs, and finishes with new presentation and unchanged mechanics.
- [x] No unresolved console errors or unverified acceptance items are silently labeled passed.

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

## Repeatable evidence tooling

`tests/prepare_reskin.py` prepares a new isolated copy, changes only three
Resources and writes a sibling SHA-256 manifest. `tests/reskin_test.gd` is part
of the standard test runner and checks loaded presentation, collision
boundaries, live weapon lifetime and retry. `tests/acceptance_sample.gd` extends
the normal-content scripted route with 450 native viewport frames around
90 active seconds, route stills and measured capture timestamps. See
[the README](../../README.md) for exact preparation, launch and encoding commands.

Automated and scripted native evidence does not close physical keyboard, human
movement/attraction/pause feel, balance or full human readability acceptance.
Keep final completion and the prior human gates unchecked until that evidence
is supplied; do not archive the change yet.
