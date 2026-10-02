# Step 05 — One level and encounter progression

Status: accepted after user-reported manual testing. Prerequisite: Step 04 accepted.

## Outcome

The hero can cross the planned street, clear two encounters and reach the sealed
boss entrance. The boss itself is the next step.

## Work

1. Author the [level route](../DESIGN.md#enemies-and-encounters) in one scene using
   explicit spawn markers and encounter triggers. Retain simple walkable geometry.
2. Implement safe-entry gate closure, camera locks, scheduled waves and live-enemy
   tracking. Open gates only after both queued and living enemies are exhausted.
3. Add forward prompts and readable boundaries. Prevent triggers from repeating
   and ensure enemies spawn within a reachable visible fighting area, away from the hero.
4. Introduce the level's run owner, minimal title, HUD and pause/death/retry flow.
   Retry reloads the entire run. Replace test-only reset controls with menu actions.
5. Add wave and reset regressions; keep the boss entrance visibly unfinished
   rather than claiming a complete game.

## Acceptance

- Both fights lock and unlock once; pending second waves prevent early opening.
- Jumping or backtracking cannot skip/retrigger a fight or escape a locked arena.
- No live enemy can be stranded outside the accessible area.
- Retry from either encounter resets all state; Main Menu → Play starts cleanly.
- Death and pause prevent new wave spawns until an appropriate fresh run/resume.

Exclude boss logic, props, checkpoints and final menu styling.
See [validation](../ACCEPTANCE.md).

## Completion record

Implemented on 2026-10-02 with Godot **4.7.2.stable.official.ed1daf0bf**,
Compatibility renderer. No new assets.

### Files and behavior

- `main.tscn` now boots `scenes/ui/run.gd`, the title/run/menu owner. Title has
  Play/Controls/Quit; pause has Resume/Retry/Main Menu/Quit; death has
  Retry/Main Menu/Quit. Menu buttons activate on press and focus the first action.
  Gameplay requires input release after Play/resume, including south-button confirmation.
- `scenes/level/street.tscn` and `street.gd` author a 2560-unit street using the
  existing mirrored backdrop, explicit encounter nodes and spawn markers. Ground
  bounds are X=48–2464, Y=242–312. Gates are movement clamps independent of jump
  height, with amber lines drawn above scenery. The boss endpoint has a red boundary
  and an explicit sealed/Step 06 prompt; it is not a victory transition.
- `scenes/level/encounter.gd` owns one-shot entry, wave delay, living-instance IDs,
  clear signals, and a maximum of two attack commitments. Defeat removes a living
  ID immediately; corpses do not block clear and duplicate signals do nothing.
  Spawn markers are sorted by distance from the hero, keeping each wave separated
  and inside the visible, reachable arena. The paused scene inherits no always-on
  processing from the run owner: the entire street explicitly uses pausable processing.
- `tests/level_test.gd` and its generated UID cover safe airborne entry, both gate
  clamps, retrigger rejection, camera locks, separated spawns, queued waves,
  duplicate defeat signals, pause/death spawn blocking, whole-run retry from both
  encounters, Main Menu/Play cleanup, keyboard navigation and synthetic controller
  confirmation without a leaked jump. All new scripts have tracked-in-scope UID files.
- Updated `README.md`, `docs/PLAN.md`, and `docs/ACCEPTANCE.md` to describe the
  accepted milestone and retain pending final acceptance checks.

### Route and wave tuning

| Section | Bounds / entry | Population and progression |
| --- | --- | --- |
| Entrance | Start X=160 | No enemies; movement/combo/jump prompt |
| First fight | X=480–1020; trigger at X=540; camera X=750 | Two grunts; unlock after both defeat signals |
| Connector | Between fights | GO prompt; free forward/backward travel through cleared arena |
| Yard approach | X=1560–2100; trigger at X=1620; camera X=1830 | Two grunts, then one grunt and one bruiser after a 1.2-second delay |
| Boss entrance | Prompt at X≥2300; endpoint X=2464 | Sealed, unfinished; pause/retry/Main Menu remain available |

Each arena's depth is Y=242–312. Entry happens 60 units beyond its rear gate;
markers sit 60/100/440/480 units from its left edge, with separate depth lanes.
A pending wave retains the active arena and its camera lock. Cleared encounters
cannot restart after backtracking. Retry discards the complete scene and creates
new hero, camera, enemies, wave state and gates; no checkpoints are introduced.

### Verification

From the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path beat-em-up --log-file /tmp/beat-import.log --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --log-file /tmp/beat-startup.log --quit-after 120
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --log-file /tmp/beat-level.log --fixed-fps 60 --script res://tests/level_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --log-file /tmp/beat-movement.log --fixed-fps 60 --script res://tests/movement_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --log-file /tmp/beat-combat.log --fixed-fps 60 --script res://tests/combat_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --log-file /tmp/beat-enemies.log --fixed-fps 60 --script res://tests/enemies_test.gd
git diff --check
```

Results: level **33 passed, 0 failed**; movement **48 passed, 0 failed**;
combat **58 passed, 0 failed**; enemies **35 passed, 0 failed**. Import and title
startup pass with no script/resource errors. Headless runs emit the macOS
`get_system_ca_certificates` diagnostic. Restricted editor import also reports
that it cannot save settings outside the workspace; the import completes.
Using `/tmp` log paths avoids restricted `user://` log writes.

Native Compatibility/OpenGL rendering was captured with a temporary SceneTree
harness and `RenderingServer.frame_post_draw`, then PNG pixels were inspected for
title, Controls, entrance, first locked fight, pause, yard, mixed wave, sealed
endpoint, and Game Over. Gates and HUD are visible; opaque menu panels and focus
outlines are readable. Captures used staged actor positions and forced defeats,
not a human fight walkthrough or physical controller acceptance. Captures used the default
1280 × 720 window and 640 × 360 logical viewport; resized-window manual acceptance
remains pending.

### Intentionally untouched and follow-ups

Existing actor movement/combat/AI scripts, enemy and dummy scenes, earlier test
streets and regressions, input map, renderer, asset files and provenance are
unchanged. Boss logic, props, pickups, sound, final presentation and checkpoints
remain excluded. This step uses the already-approved free art; no replacement
art or new asset acquisition was needed.

The user reported manual testing and accepted Step 05 on 2026-10-02. No detailed
route, display, or device observations were supplied. Physical controller and
resized-window acceptance remain pending in final validation; do not infer a
controller model or specific playtest observations from this report. Stop before
Step 06.
