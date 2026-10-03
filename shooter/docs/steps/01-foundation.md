# Step 01 — Standalone 3D maze and map validation

## Entry condition

Read [the design](../DESIGN.md); no earlier implementation is required.

## Scope

Create the independent 3D project and build the specified grid from validated local data.

## Planned files

These paths are relative to `shooter/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `project.godot`
- `scenes/main.tscn`
- `scenes/run.tscn`
- `scenes/maze.tscn`
- `scripts/maze.gd`
- `scripts/content_loader.gd`
- `data/maze.json`
- `data/player.tres`
- `data/weapon.tres`
- `data/enemies/`
- `data/items/`
- `data/theme.tres`
- `tests/run_tests.gd`
- `README.md`
- `assets/PROVENANCE.md`

## Work

1. Use Godot 4.7.2, GDScript and Compatibility with a 1280×720 default window and scalable HUD.
2. Declare WASD, fire, interact, pause and confirm actions. Create native 3D floor/walls with uniform height and 2 m cells from DESIGN.md.
3. Validate rectangular grid, recognized symbols, exactly one player/key/door/exit, correct actor counts, and walkable entity placements.
4. Check key reachability with the door closed; exit unreachable while closed and reachable while open. Add the exterior backing wall behind the east-edge exit.
5. Use primitive models and materials. Record CraftPix HUD candidates and unresolved directional-enemy coverage; no download is a startup dependency.
6. Create the test runner and retain generated script UIDs.

## Completion gate

- [ ] Import and launch this folder independently with no missing resources.
- [ ] Map tests verify counts, walkability and closed/open-door reachability.
- [ ] Native view shows a properly lit maze, solid perimeter and readable corridor width.

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
