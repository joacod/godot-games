# Step 01 — Standalone arena and content contracts

## Entry condition

Read [the design](../DESIGN.md); no earlier implementation is required.

## Scope

Create the independent Godot project, a start menu and bounded placeholder arena, with project-local data definitions and no gameplay progression.

## Planned files

These paths are relative to `survivors/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `project.godot`
- `scenes/main.tscn`
- `scenes/run.tscn`
- `scenes/arena.tscn`
- `scripts/main.gd`
- `scripts/content/*.gd`
- `data/characters/`
- `data/weapons/`
- `data/enemies/`
- `data/run.tres`
- `data/theme.tres`
- `tests/run_tests.gd`
- `README.md`
- `assets/PROVENANCE.md`

## Work

1. Configure Compatibility, 640×360 logical viewport, 1280×720 window, preserved aspect and nearest filtering. Declare movement, confirm, cancel and pause actions.
2. Create explicit content Resource schemas from DESIGN.md. Validate required IDs, numeric ranges, scene paths and four weapon definitions before starting a run.
3. Build a bounded arena with contrasting floor, player marker and enemy marker. Put visuals under replaceable children; collision and movement dimensions are independent.
4. Inspect chosen CraftPix files if acquiring art in this step; record provenance and actual animation mappings. Otherwise record candidate status and retain complete placeholders. No pack or account must be required at runtime.
5. Create a SceneTree test entry point and document local import, test and launch commands. Record generated UIDs alongside each new script.

## Completion gate

- [ ] Import and launch this folder by itself without errors; Start opens one arena.
- [ ] Data validation rejects a missing visual path or duplicate weapon ID with an actionable message.
- [ ] Verify floor, boundaries and labels in a native window; no combat or spawning is needed yet.

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
