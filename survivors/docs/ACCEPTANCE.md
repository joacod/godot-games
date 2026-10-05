# Survivors acceptance evidence

## Step 01 — completed 2026-10-05

Standalone arena and content contracts are implemented. Later gameplay steps
remain pending. Verification used Godot **4.7.2.stable.official.ed1daf0bf** and
Compatibility/OpenGL on macOS (Apple M2). Both the CLI and Godot MCP reported the
same engine version.

## Automated evidence

Commands from the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --path survivors --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path survivors --script tests/run_tests.gd
```

- Import: exit 0, no errors with normal Godot application-data access.
- Tests: **72 passed, 0 failed**, exit 0, no console errors on the final run.
- Negative fixtures reject missing/outside visual paths, visuals owning physics,
  empty IDs, duplicate weapon IDs, missing definitions, invalid numbers, missing
  ranks, invalid starting loadout, enemy ordering, upgrade references/recipe,
  and malformed spawn phases. Fixtures deep-copy external Resources.
- Integration checks cover Start blocking invalid content with a visible
  actionable diagnostic, one arena per Start, static markers, data-driven labels,
  visual/collision separation, physical collision against each wall, menu return,
  fresh arena construction, and unchanged loaded content.
- All seven required input actions have events. This establishes configuration,
  not future movement or pause behavior.
- All 11 `.gd` scripts have generated `.gd.uid` companions. Static inspection
  found no missing runtime `res://` references and no sibling runtime imports.
- `OPENSPEC_TELEMETRY=0 openspec validate add-survivors --strict --no-interactive`
  passed. Local Markdown links and `git diff --check` passed.

The initial sandboxed import reported denied writes to Godot application data
and editor settings. Re-running with normal application-data access removed
those errors. During implementation, fixture duplication, indentation, and
duplicate signal connection issues were corrected; final results above are from
the corrected files. The runner has an explicit 15-second failure timeout.

## Native and input evidence

Godot MCP launched the exact `survivors/` project. Computer use inspected its
native window and exercised its controls:

- Focused Start opens the arena with Enter.
- Mouse Start opens the same arena; mouse Back to menu restores the menu.
- Escape returns to the menu; starting again rebuilds the arena.
- Final native view shows a contrasting floor, all four edges, distinct Keeper
  and Crawler silhouettes and labels, and readable header/footer without overlap.
- MCP debug output and final stop output contained no errors for the corrected
  project. MCP logs and native screenshot inspection are separate evidence.

These are agent-operated native checks. No human gameplay, movement feel,
controller, combat readability, audio listening, or balance acceptance is claimed.

## Independent copy evidence

The entire game folder was copied outside the repository without `.godot/`,
exports, or logs. The temporary project contained no sibling game or OpenSpec
folder:

```text
/var/folders/l1/llh3yrws3q9gmq_bq9cp_klm0000gn/T/survivors-step01-f_klqpn4/survivors
```

Commands:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /var/folders/l1/llh3yrws3q9gmq_bq9cp_klm0000gn/T/survivors-step01-f_klqpn4/survivors --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /var/folders/l1/llh3yrws3q9gmq_bq9cp_klm0000gn/T/survivors-step01-f_klqpn4/survivors --script tests/run_tests.gd
```

Clean import exited 0 without errors; tests reported **72 passed, 0 failed** and
exited 0. MCP launched that exact copy, and native Enter opened its correctly
rendered arena. No asset download was required. This proves foundation isolation;
the complete survival route and independent reskin proof remain Step 06 work.

## Files and boundaries

Added inside this game:

- `.gitignore`, `project.godot`, and `README.md`.
- `scenes/main.tscn`, `scenes/run.tscn`, `scenes/arena.tscn`.
- `scenes/visuals/keeper.tscn`, `crawler.tscn`, `floor.tscn`, `attack.tscn`.
- `scripts/main.gd`, `scripts/run.gd` and their UIDs.
- `scripts/content/character_data.gd`, `weapon_data.gd`, `enemy_data.gd`,
  `upgrade_data.gd`, `spawn_phase_data.gd`, `run_data.gd`, `theme_data.gd`,
  `content_validator.gd` and their UIDs.
- `data/characters/keeper.tres`; `data/weapons/spark.tres`, `halo.tres`,
  `pulse.tres`, `shard.tres`; `data/enemies/crawler.tres`, `elite_crawler.tres`.
- `data/upgrades/spark.tres`, `halo.tres`, `pulse.tres`, `shard.tres`, `lens.tres`,
  `recovery.tres`, `power.tres`, `reach.tres`, `arc_spark.tres`.
- `data/run.tres`, `data/theme.tres`, `data/ui_theme.tres`.
- `tests/run_tests.gd` and its UID; `assets/PROVENANCE.md`; this evidence file.

Updated the Step index and design status, plus only Step 01 checkboxes in
`openspec/changes/add-survivors/tasks.md`. Existing games, sibling plans, root
configuration, OpenSpec requirements, and detailed future step guides remain
untouched. No branch, commit, push, PR, or publication was performed.

## Remaining work

Step 02 evidence follows below. Step 03 adds automatic weapons and has not
been started. CraftPix candidates retain their
previous researched status; no archives, entitlements, animation mapping, or
source-template redistribution rights were verified in Step 01.


## Step 02 — implementation 2026-10-05, input acceptance pending

Implemented normalized WASD/arrow movement, bounded physical collision, a
following camera, one manually placed pursuer, health/contact invulnerability,
a short hit flash, death-once signals, and defeat/retry. Health and immunity live
on each player's Health node, never on the loaded content Resource. Enemy
motion and player input stop at defeat. Retry removes the old run and rebuilds
actors, health, immunity, visuals, and signal connections.

The camera limits include a 64 px presentation margin beyond the 960×640
arena. Native edge renders initially exposed clipped actors and HUD overlap;
this margin makes the walls visible and keeps the player clear of the HUD.
Physics boundaries remain unchanged. The crawler label is above its silhouette
so contact does not merge the two labels. Existing placeholders are retained;
no new art, download, account access, or external service was used.

### Automated checks

Godot CLI and MCP both reported **4.7.2.stable.official.ed1daf0bf**. Commands
from the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path survivors --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path survivors --script tests/run_tests.gd
/Applications/Godot.app/Contents/MacOS/Godot --path survivors --script tests/run_tests.gd
```

Final import: exit 0, no errors. Final headless and native suites each report
**106 passed, 0 failed**, exit 0, with no console errors. OpenSpec strict
validation, changed-document local links, and `git diff --check` also pass.
Coverage retains the Step 01 content/transition/physical-wall checks, replacing only its
static-player expectation and the physics-scene negative fixture after actors
became instanced scenes. Step 02 exercises actual Input actions and physics:

- Cardinal/diagonal speed equality and stopping after release.
- Held movement against all four walls and bounded camera center at each edge.
- Pursuit distance reduction and content-driven speeds.
- Persistent overlap: first hit, no hit before cooldown, another hit afterward,
  and no damage after leaving contact. Additional hits share player immunity.
- Visible HP updates, flash start/end, rejection of nonpositive damage, lethal
  clamping, one death and one outcome, and rejection of damage after death.
- Frozen actors after defeat, focused Retry, new run identity, fresh health and
  immunity, restored positions, freed prior run, menu return, immutable content.

The initial sandboxed import exited 0 but reported macOS certificate/settings
access errors. Import with normal application-data access removed those errors.
All 15 game/test scripts have generated `.gd.uid` companions, including the four
new scripts. The suite keeps its 15-second failure timeout.

### Native rendering and MCP evidence

MCP launched the exact `survivors/` project with Compatibility/OpenGL on Apple
M2. Its debug and stop output reported no errors. Computer use inspected the
native menu, but key attempts did not advance it and clicks failed with
`noWindowsAvailable`, including after reconnecting and a direct CLI launch.
Physical Start, movement, and Retry input are therefore **not verified**.

A temporary native SceneTree fixture loaded the real Main scene, started it,
drove Input actions near all four edges, exercised contact damage and lethal
health, then emitted the real Retry button signal. It rendered viewport PNGs
for arena, four edges, hit, defeat, and retry, inspected individually. Corrected
renders show contrasting silhouettes, visible walls, distinct actor labels,
a white hit flash with HP loss, readable defeat buttons, and a fresh 100/100 HP
run after retry. The fixture uses explicit rendering for static scenes and is
outside the game; it adds no debug controls or dependencies.

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path survivors --script /private/tmp/survivors_step02_visual.gd
```

Final fixture: exit 0, lethal damage accepted, no console errors. Temporary
captures are `/private/tmp/survivors-step02-{arena,left,right,top,bottom,hit,defeat,retry}.png`.
These are automated native renders and visual inspection, not physical keyboard,
controller, human movement-feel, balance, or playthrough evidence. The final
Step 02 acceptance task stays unchecked until keyboard movement/camera edges,
contact readability in motion, defeat, and keyboard/mouse retry are checked in
a native window. No independent-copy check was repeated for this step.

### Files and boundaries

Added `scenes/player.tscn`, `scenes/enemy.tscn`, `scripts/player_movement.gd`,
`scripts/enemy.gd`, `scripts/health.gd`, `tests/movement_health_test.gd`, and all
four script UID companions. Updated `scenes/run.tscn`, `scenes/main.tscn`,
`scripts/run.gd`, `scripts/main.gd`, `data/theme.tres`, `tests/run_tests.gd`,
`README.md`, `docs/DESIGN.md`, `docs/STEPS.md`, this evidence, and only Step 02
progress in OpenSpec tasks. Editor indentation changes in the in-scope
`main.gd` were retained.

Arena geometry, existing visual assets, content schemas, stat Resources,
engine/renderer configuration, OpenSpec requirements, other games, and all
later-step mechanics remain untouched. No branch, commit, push, PR, or
publication occurred. Finish native physical input acceptance before treating
Step 02's gate as complete; Step 03 remains unstarted.
