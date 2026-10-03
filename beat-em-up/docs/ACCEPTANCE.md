# Validation and final acceptance

Step 01 import/startup and sample checks are recorded in its
[completion record](steps/01-foundation.md#completion-record). Step 02 movement
regressions and rendered observations are in its
[completion record](steps/02-movement.md#completion-record); the user accepted
Step 02 after manual testing on 2026-10-02. Step 03 combat
regressions and rendered observations are recorded in its
[completion record](steps/03-combat.md#completion-record); the user also reported
manual testing and accepted Step 03 on 2026-10-02. No controller model or detailed
device results were supplied. Step 04 automated regressions and native rendered observations are recorded in
its [completion record](steps/04-enemies.md#completion-record); the user confirmed manual testing
and accepted Step 04 on 2026-10-02. No detailed device results were supplied;
physical controller acceptance remains pending. Step 05 automated wave/reset/menu checks and native staged rendering are recorded
in its [completion record](steps/05-level.md#completion-record). The user reported
manual testing and accepted Step 05 on 2026-10-02. No detailed route, display, or
device observations were supplied; physical controller acceptance remains pending. Step 06 boss/completion regressions and staged native rendering are recorded in
its [completion record](steps/06-boss.md#completion-record). The user accepted
Step 06 for progression on 2026-10-02 without detailed hands-on observations.
Step 07 recovery regressions and staged native rendering are recorded in its
[completion record](steps/07-props.md#completion-record); the user accepted Step 07 for progression without detailed recovery/balance
results. Step 08 presentation checks, staged native art review and audio-output
measurements are in its [completion record](steps/08-presentation.md#completion-record).
Listening quality and final hands-on presentation acceptance remain pending.
A full hands-on clear,
boss balance, and physical controller results remain pending. The remaining gameplay and final acceptance checks
below remain pending. Keep automated results separate from visual, input, controller,
and audio observations. A missing controller leaves controller acceptance pending.

## Engine and startup

Use Godot 4.7.2 for development checks. Verify the binary before any project
operation. From the repository root, after Step 01 creates the project:

```sh
godot --version
godot --headless --editor --path beat-em-up --quit
godot --headless --path beat-em-up --quit-after 120
git diff --check
```

On this repository's macOS setup, the expected binary location is
`/Applications/Godot.app/Contents/MacOS/Godot`; verify its existence and version
before substituting it for `godot`. Inspect logs for script, resource, and scene
errors even if the process exits zero. Check new scripts have generated `.gd.uid`
files. A headless check establishes loading, not successful gameplay or rendering.

Step 02 adds a focused SceneTree regression script, without an external test
runner. Run it with `--fixed-fps 60 --script res://tests/movement_test.gd` and the
same binary, `--headless`, and `--path beat-em-up` flags as above. Add small
deterministic Godot tests as relevant mechanics arrive; document their actual
commands in the owning step.
Do not invent a passing suite or add an external test dependency by default.

## Focused automated regressions

- Step 03: facing/depth/height rejection, one hit per target per strike, combo
  buffer expiry, airborne attack cancellation, health clamping, single death event.
- Step 04: attack-slot release after interruption/death and bounded crowd commitments.
- Step 05: wave clear includes queued spawns; duplicate death cannot open gates
  early; retriggering entry cannot duplicate a wave; reset restores initial state.
- Step 06: boss attack cancellation on death, one result transition, simultaneous
  player/boss death precedence, complete retry after pause/death/victory.
- Step 07: one break/drop/collection, full-health clamp, no pickup by dead/airborne
  player or through a different depth lane.
- Step 08: keyboard/controller menu events, actual bus volume/mute values, one cue
  per accepted damage/pickup, pause/effect lifetime and Retry sound/effect cleanup.
  Run `--script res://tests/presentation_test.gd` with the same flags. Synthetic
  events and output measurements do not establish physical controller support
  or listening quality.

## Manual checks

| Area | Required observation |
| --- | --- |
| Boot and menus | F5 reaches title; mouse-free focus and Controls work; Play starts cleanly |
| Movement | All directions, equal diagonal speed, stick deadzone, correct facing and bounds |
| Depth and jump | Feet/shadow stay grounded, sorting follows ground depth, jump cannot bypass gates |
| Combat | Three deliberate combo strikes; jump attack; correct misses by depth/height/facing |
| Reactions | Clear hit/hurt/knockdown feedback; no repeated damage per strike or permanent stun |
| Crowd | Enemies approach and telegraph fairly; no attack from offscreen or overlapping spawn |
| Route | Both encounters lock/unlock once; no skipped, stuck, or inaccessible enemy |
| Boss | Both attacks are readable and avoidable; recovery can be punished; defeat ends run |
| Props/food | Prop breaks once; food heals once; visual and ground positions match |
| Pause | Movement, jump, attacks, AI, waves and timers freeze; resume leaks no confirm input |
| Reset | Retry/Main Menu/Play Again reset health, actors, props, gates, camera, UI and time effects |
| Presentation | No broken imports, clipped HUD, invisible tells, foot sliding or mismatched hit timing |
| Sound | Listen to effects/music, volume balance, pause behavior and absence of duplicate loops |
| Display | Test 1280 × 720 and a resized window; controls and fight area remain readable |
| Controller | Complete a fight and every menu flow using a real controller; record device |
| Full run | Clear from title to victory, then play again; deliberately die and retry in each encounter |
| Replacement | Alternate sprite works with unchanged gameplay logic; record needed art/timing edits |

## Evidence and completion record

Each step file has a record to fill with date, engine version, changed files,
commands/results, manual observations, unresolved issues, and intentional exclusions.
Final acceptance must name the tested revision or exact working tree, controller,
display sizes, playthrough result, and remaining limitations. Mark checks as passed,
failed, or not run. Fix blockers within the requested step or explicitly propose
a follow-up; do not claim the game is finished while required checks are pending.
