# Step 01 — Standalone room and content schema

## Entry condition

Read [the design](../DESIGN.md); no earlier implementation is required.

## Scope

Create the independent project, static stage and validated JSON content definitions.

## Planned files

These paths are relative to `point-and-click/` and now exist. The independent
placeholder visual scenes live under `scenes/visuals/`.

- `project.godot`
- `scenes/main.tscn`
- `scenes/room.tscn`
- `scripts/main.gd`
- `scripts/content_loader.gd`
- `data/room.json`
- `data/items.json`
- `data/dialogue.json`
- `data/puzzle.json`
- `data/theme.tres`
- `tests/run_tests.gd`
- `README.md`
- `assets/PROVENANCE.md`

## Work

1. Configure Compatibility and 640×360 logical viewport with legible text at 1280×720. Set up mouse clicks, cancel and pause actions.
2. Create the fixed camera and five labeled placeholder hotspots. No avatar movement or pathfinding is required.
3. Define the small JSON schemas in DESIGN.md, including all line/choice text and failure responses. Validate IDs, references, value types and allowed effect names before play.
4. Choose one CraftPix interior candidate; inspect actual files only if importing. Keep independent prop visuals and a complete placeholder room, recording candidates versus used assets.
5. Create the test runner and local commands; retain every generated script UID.

## Completion gate

- [x] Launch this game folder alone and display a readable static room.
- [x] Malformed JSON, unknown effects, missing dialogue targets and duplicate IDs produce actionable validation failures.
- [x] Confirm room framing and UI text in a native window.

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

## Recorded result

Completed 2026-10-03; see [acceptance evidence](../ACCEPTANCE.md).
126 headless checks and 128 native checks passed. Step 02 remains pending.

The subsequent label bounds correction adds two regression checks; current
totals are 128 headless and 130 native checks. The acceptance record preserves
the original foundation results separately from this correction.
