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

Step 02 adds movement, a following bounded camera, pursuit, health, damage, and
minimal defeat/retry. It has not been started. CraftPix candidates retain their
previous researched status; no archives, entitlements, animation mapping, or
source-template redistribution rights were verified in Step 01.
