# Survivors validation and acceptance

All six implementation steps are complete. On 2026-10-05, the user confirmed
“yes manual check is done” after being asked about movement, upgrades,
pause/resume, readability, a win and loss/retry. This closes the prior human
acceptance gates as **user-reported evidence**. No independently measured human
completion time or controller verification is claimed.

## Recorded baseline

Implementation checks used Godot **4.7.2.stable.official.ed1daf0bf** and
Compatibility/OpenGL on macOS, Apple M2.

| Evidence | Result recorded on 2026-10-05 |
| --- | --- |
| Source headless and native regression suites | 252 passed, 0 failed each |
| Isolated reskin headless suite | 252 passed, 0 failed |
| Original native scripted route | Win at 180 active seconds / 182.88 wall seconds; loss at 19.20 s; fresh retry |
| Reskin native scripted route | Win at 180 active seconds / 182.86 wall seconds; loss at 18.50 s; fresh retry |
| Progression in original / reskin | All weapons at 15.67 / 15.58 s; Arc Spark at 33.75 / 34.12 s; one elite each |
| Independent reskin hashes | 23 runtime scripts, their 23 UIDs and 22 scenes unchanged; exactly three Resource files changed |
| Native reskin clip | 1280×720, 30 fps, 450 frames, 15 seconds; sampled wall span 14.977 s, maximum gap 46 ms |
| Script UID coverage | 34 GDScript files with UID companions |
| MCP copy startup/debug | No errors; startup at the menu only |
| Manual acceptance | User confirmed complete |

Native routes use scripted movement, injected menu confirmation, normal stats
and earned XP. They establish lifecycle/progression and rendering behavior;
human acceptance comes from the user's confirmation. Temporal sample inspection
observed effects crossing character labels and the HUD; those observations remain
in history and were not treated as independent continuous-readability proof.

Detailed logs, milestone records, fixture limitations and early resolved errors
are preserved in [implementation evidence](history/ACCEPTANCE.md). Temporary
captures and manifests referenced there may be cleaned from the machine; use
the commands below to regenerate them. These baseline checks preceded the
current documentation cleanup; they were not rerun for Markdown-only edits.

## Regression checks

From `survivors/`:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/run_tests.gd
```

Import first on a fresh checkout. The runner exits nonzero for failed checks or
its 15-second timeout. Coverage includes content validation, movement/walls,
pursuit/contact damage, weapons/lifetimes, XP/queued choices, evolution in either
order, pause/confirmation release, spawn cap/timing/warnings, outcome precedence,
retry and reskin Resource propagation. Godot needs normal application-data
access; certificate, `user://` or editor-settings denial can be sandbox issues.

Run the same suite with native rendering when changing scenes, art or UI:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tests/run_tests.gd
```

## Native fixtures

From `survivors/`, launch one fixture at a time:

| Script passed to `--script` | What it checks/shows |
| --- | --- |
| `tests/combat_sample.gd` | 15-second four-weapon sample; scripted movement and supplied high-health enemies |
| `tests/progression_sample.gd` | Supplied XP/enemies; attraction, choices, evolution, shield and retry |
| `tests/run_sample.gd` | Normal-content 180-second scripted win, deliberate-contact loss and retry |
| `tests/run_sample.gd -- --panels` | Short controlled pause, elite and visible-entry warning sample |

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tests/run_sample.gd
```

Combat/progression fixtures isolate their supplied enemies from normal spawning.
Their stills use `/private/tmp/survivors-step03-*` and `step04-*`; the run fixture
uses `step05-*`. Those names identify fixture origins, not incomplete features.
Fixtures do not add debug controls to normal Start.

### Mid-run capture

Use a **new absolute evidence directory**:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tests/acceptance_sample.gd -- --evidence-dir=/private/tmp/survivors-acceptance-example
ffmpeg -nostdin -n -framerate 30 -i /private/tmp/survivors-acceptance-example/frames/%04d.png -frames:v 450 -c:v libx264 -pix_fmt yuv420p -movflags +faststart /private/tmp/survivors-acceptance-example/mid-run.mp4
```

The fixture saves 450 viewport PNGs around 90 active seconds, measured wall
sampling timestamps in `clip-timestamps.json`, and route/result/retry stills.
The encoded constant-frame-rate clip includes any short upgrade pauses and has
no audio. Inspect sampling timestamps when assessing recording timing.
FFmpeg is only needed for encoding; it is not a game dependency.

### Independent copy check

Use Python 3.9+ and a **new absolute destination outside the repository**:

```sh
python3 tests/prepare_reskin.py /private/tmp/survivors-reskin-example
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /private/tmp/survivors-reskin-example --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /private/tmp/survivors-reskin-example --script tests/run_tests.gd
/Applications/Godot.app/Contents/MacOS/Godot --path /private/tmp/survivors-reskin-example --script tests/run_sample.gd
```

The helper refuses existing destinations and symlinks. It omits generated caches,
exports and logs, changes only the three documented Resources, and writes
`<destination-name>-manifest.json` beside the copy. Rehash copied source files
after import/play when recording a new proof. Runtime resources must remain
local; the existing proof did not deny filesystem access to the original repo.

## Manual regression route

Repeat after changes to input, UI, visuals or balance:

1. Start, move with WASD/arrows and observe automatic Spark, hits and XP attraction.
2. Choose from three upgrades, acquire all four weapons and Lens, then evolve Spark.
3. Pause with Escape/P and resume; check time, enemies, damage and weapons freeze.
4. Observe the elite at two minutes and survive to three active minutes; aim to
   finish within five minutes including choices.
5. On a separate short run, lose and Retry; check fresh HP, XP, timer and enemies.
6. Assess continuous player/threat/pickup readability and balance, including
   labels/HUD when attacks pass across them. Record the result and any measured
   timings separately from scripted checks.

Controller support is outside this game. Historical OpenSpec requirements and
completed progress are retained at repository level; see
[the task record](../../openspec/changes/add-survivors/tasks.md).
