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

Step 02 evidence follows below. Step 03 evidence follows below. CraftPix candidates retain their
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
Step 02's gate as complete. Step 03 evidence follows below.

## Step 03 — implemented 2026-10-05

Implemented Spark nearest-living-target projectiles, Halo orbital contact with
per-target windows, Pulse activation-radius hits, and Shard cardinal bursts.
The rack owns targeting and cadence; attack nodes own collision and lifetime.
Normal Start equips rank-1 Spark only. All four weapons are exercised through
`tests/combat_fixture.gd`; no extra controls or later progression are exposed.
Enemy health, hit flash, immediate death/contact disabling, one death signal,
and removal are implemented. Defeat stops the rack and removes attacks; retry
rebuilds the starting loadout and enemy health. An empty arena can still end in
defeat without accessing a freed enemy. Content Resources remain immutable.

Damage rounds fractional rank values up to integer HP. Pulse samples its radius
once on activation, excludes late arrivals, and fades its ring in 0.3 seconds
while retaining its configured lifetime. Halo renews its equipped lifetime while
preserving angle and target cooldowns; an unrenewed orbit expires. Spark misses
consume their shot lifetime; no-target intervals do not accumulate a burst.
Projectiles use enemy-only overlap and a center ray sweep, sharing one hit guard.
Collision layer names document walls 1, player 2, enemies 4, attacks 8, and
reserved pickups 16. Attacks do not scan the player or walls.

### Automated checks

Godot CLI and MCP both reported **4.7.2.stable.official.ed1daf0bf**. Commands
from the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path survivors --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path survivors --script tests/run_tests.gd
/Applications/Godot.app/Contents/MacOS/Godot --path survivors --script tests/run_tests.gd
OPENSPEC_TELEMETRY=0 openspec validate add-survivors --strict --no-interactive
```

Final import exited 0 with no errors. Headless and native suites each reported
**150 passed, 0 failed**, exit 0, with no console errors. The 15-second failure
timeout remains. Tests retain Steps 01–02 checks, isolate their movement/contact
fixture from automatic combat, and add targeting, no-target cadence, all four
behaviors, rank damage, hit-window limits, orbit renewal, radius boundaries,
late pulse entrants, projectile consumption/expiry/sweep, dead/null targets,
enemy flash, death once, stale contact suppression, defeat cleanup, fresh retry,
automatic Spark kills without fire input, and defeat after all enemies are gone.

All **22 scripts** have generated `.gd.uid` companions, including the seven new
runtime/test scripts. Runtime references resolve inside this game. The missing
scene in the negative validation fixture is intentional. OpenSpec strict
validation and `git diff --check` passed. No independent-copy test was repeated;
complete reskin and survival-route evidence remains Step 06.

The first sandboxed import reported macOS certificate/settings access errors;
the final import used normal application-data access. A rack parse error and
cross-weapon damage in an insufficiently isolated Shard test were corrected
before the final runs. The first native capture fixture waited on an undrawn
viewport; explicit rendering fixed it. Final results above exclude those runs.

### Native sample and visual evidence

MCP launched the exact `survivors/` project in Compatibility/OpenGL on Apple M2.
Debug and stop output reported no errors. This establishes native launch, not
combat or physical input acceptance.

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path survivors --script tests/combat_sample.gd
```

The separate native fixture ran for **15 seconds**, equipped all four weapons,
placed high-health crawlers without a spawn director, and drove movement Input
actions. It exited 0 without errors: `ended=false`, final HP **80**, three
captures. Individually inspected viewport PNGs:

- `/private/tmp/survivors-step03-2.08.png`
- `/private/tmp/survivors-step03-6.08.png`
- `/private/tmp/survivors-step03-12.08.png`

Captures show the yellow Spark diamond, violet Halo square, thin green Pulse
ring, cyan directional Shards, contrasting enemies, HP loss, and a visible Keeper
with space to move. Dense crawler labels overlap in the clustered final fixture;
this limits readability of labels, while player and attack shapes remain clear.
The thin unfilled Pulse ring does not cover the player silhouette. These are
scripted native execution and snapshot inspection, not continuous human motion
review, physical keyboard acceptance, controller evidence, or balance proof.
Step 02 physical input/movement-feel acceptance remains pending; full populated
combat readability and the representative mid-run clip remain Step 06 work.

### Files and boundaries

Added four runtime scripts (`weapon_rack.gd`, `projectile.gd`, `orbit_attack.gd`,
`pulse_attack.gd`), three attack scenes (`projectile.tscn`, `orbit.tscn`,
`pulse.tscn`), four replaceable weapon visual scenes, three test/fixture scripts
(`weapons_test.gd`, `combat_fixture.gd`, `combat_sample.gd`), and all seven new
script UIDs. Updated enemy/run scripts and scenes, the existing test runner and
movement fixture, four weapon visual references, theme text, collision layer
names, README, provenance, design/status/evidence, and Step 03 OpenSpec progress.
CraftPix effect listings were researched; no art was downloaded or imported.

Arena geometry, player movement/health implementation, stat values, content
schemas, upgrade Resources, engine/renderer, OpenSpec requirements, other games,
and all later mechanics remain untouched. No XP, upgrades, evolution, spawning,
pause, timer, victory, commit, branch, push, PR, or publication was added.
Step 04 is the next implementation step; it has not been started.
