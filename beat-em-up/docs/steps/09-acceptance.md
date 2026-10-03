# Step 09 — Final acceptance and sprite replacement proof

Status: regression and alternate-art proof implemented; final hands-on acceptance
pending. The user authorized progression on 2026-10-02. Step 08 listening and
hands-on acceptance remain pending; progression does not supply that evidence.

## Outcome

A validated one-level game, with accurate play/edit instructions and a demonstrated
way to replace a character's art without rewriting gameplay.

## Work

1. Run the full [acceptance checklist](../ACCEPTANCE.md), engine/import/startup
   checks and implemented regressions. Record the tested revision/working tree.
2. Play from title to victory using keyboard; test a fight and every menu on a
   real controller. Die/retry in each encounter; repeat victory → Play Again.
3. In a duplicate validation scene, swap one actor to another suitable, sourced
   sprite. Change only visual resources, anchors, animation mapping and justified
   timing/shape values. Recheck movement, depth, hits, hurt and death.
4. Keep the primary level's chosen cast. Retain a small swap sample only if useful;
   do not add a runtime selector. Document exactly what the replacement required.
5. Finish README controls, run commands, scene/editing map and limitations;
   finish asset/license records. Resolve in-scope defects found by acceptance.

## Acceptance

- Every required check has honest evidence; pending hardware/manual checks stay
  pending and prevent a claim of full acceptance.
- The alternate art does not require enemy, encounter or damage-rule rewrites.
- A new developer can open, play, tune and replace art using the documentation.
- All in-scope scripts have generated UIDs; no unrelated platformer changes.

Exclude new features, framework extraction, exporting for unrequested platforms,
commits, pushes or publication without separate authorization.

## Completion record

Implemented on 2026-10-02 with **4.7.2.stable.official.ed1daf0bf**, Compatibility
renderer. Final acceptance is **pending**, not complete.

### Tested working tree

Started clean at `5a96ef96434714e53dfb94cad5b38f78839190b8`. All existing
gameplay, frame resources, assets and regression scripts remain at that revision.
Added only this runnable scene/test/UID subset, plus the documentation listed
below. SHA-256 identifies the exact new tested implementation:

```text
07ae6db6e4bf1e1943844ca7883c1e9fc785c592624f8decd8abae08e04e94fe  scenes/sample/art_swap_street.tscn
efd39749c61149e78ae17321d2b860bac9d9c9b70b4d0dd8ee66e6fcd1f06906  tests/art_swap_test.gd
135160b057a28bd933be91dacb8290e260c571d1cfd18bec55d301001f6af4a8  tests/art_swap_test.gd.uid
```

Files changed: new inherited sample scene, `tests/art_swap_test.gd` and its
generated UID, new `docs/EDITING.md`, README, ASSETS, asset provenance, PLAN,
ACCEPTANCE and this step record. No missing script UIDs were found.

### Replacement proof

The sample inherits `scenes/enemies/fight_street.tscn`, retaining its original
owner, player, actors, crowd arbitration, pause and retry. Only the left grunt's
SpriteFrames changes to the existing Cyborg resource and its sprite offset
changes from (-21, -48) to (-14, -48). Its title explains the change. Cyborg is
an alternate character to the seaport grunt, sourced from the already-imported
CraftPix hero pack; no new art/download/license assertion is needed. The primary
route keeps its cast.

No AI, encounter, damage, health, speed, reach or timing edit was required. The
43-check suite exercises the actual inherited scene: unchanged gameplay tuning,
semantic resources, feet/scale, root sorting, movement/facing, tell/contact/
recovery, facing/depth/height misses, hit deduplication, player-authored damage,
hurt, knockdown/get-up, single death/slot release and retry.
[Editing instructions](../EDITING.md) record exact frame mappings, ownership,
Inspector fields and the limits of replacement with other sheets.

### Commands and results

From the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path beat-em-up --quit --log-file /private/tmp/acceptance-import-final.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --quit-after 120 --log-file /private/tmp/acceptance-startup.log
for suite in movement combat enemies level boss props presentation art_swap; do
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script "res://tests/${suite}_test.gd" --log-file "/private/tmp/acceptance-${suite}.log" || exit 1
done
/Applications/Godot.app/Contents/MacOS/Godot --path beat-em-up --script res://tests/presentation_test.gd --log-file /private/tmp/acceptance-presentation-native.log
/Applications/Godot.app/Contents/MacOS/Godot --path beat-em-up --script res://tests/level_test.gd --log-file /private/tmp/acceptance-level-native.log
/Applications/Godot.app/Contents/MacOS/Godot --path beat-em-up --script res://tests/art_swap_test.gd --log-file /private/tmp/acceptance-art-swap-native.log
git diff --check
```

| Suite | Headless result | Native result in this step |
| --- | --- | --- |
| Movement | 48/48 passed | Not run |
| Combat | 58/58 passed | Not run |
| Enemies | 35/35 passed | Not run |
| Level | 33/33 passed | 33/33 passed |
| Boss | 125/125 passed | Not run |
| Props | 36/36 passed | Not run |
| Presentation | 49/49 passed | 49/49 passed |
| Art swap | 43/43 passed | 43/43 passed |

**427 automated checks passed** across eight suites; all exited zero. Import and
startup found no script, scene or resource-loading failures. Headless runs emit
the known macOS certificate diagnostic. Import also cannot save global editor
settings under the sandbox. Accelerated level/boss/props/presentation and startup
report retained ObjectDB/audio resources at shutdown; passing assertions do not
mean those runs are diagnostic-free. Native level, presentation and art-swap
runs exited cleanly with no warnings/errors. Native graphics initially exited
134 inside the sandbox; the successful native checks ran outside it.

Native staged captures used the temporary harness:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path beat-em-up --script /private/tmp/acceptance-swap-render.gd --log-file /private/tmp/acceptance-swap-render.log
```

Inspected the alternate sample at **1280 × 720** and **960 × 540** windows,
with the unchanged 640 × 360 logical viewport. Staged captures cover tell,
contact, recovery, hurt, knockdown, get-up and death; headers and controls fit
and sprites/shadows remain in the ground strip. The harness waits for rendered
frames before capture. These images/harnesses are temporary in `/private/tmp`,
not shipped assets. This is staged pose review, not live animation feel,
controller input, audio listening or a full clear.

### Acceptance audit and remaining observations

| Required area | Evidence available | Final hands-on status |
| --- | --- | --- |
| Boot and menus | Import/startup; native presentation suite, injected menu events | Not run in this step |
| Movement, depth/jump, combat, reactions | Movement/combat/swap suites; prior user acceptance of Steps 02–04 retained | Final route review not run |
| Crowd, route, boss | Enemy/level/boss suites; native level reset suite | Balance/readability playthrough not run |
| Props/food | Props suite; Step 07 progression authorized | Recovery balance not run |
| Pause/reset | Mechanic suites plus native level/presentation suites | Death/retry in every encounter and repeated victory not run by a human |
| Presentation/display | Staged swap poses at both window sizes; Step 08 rendering record retained | Animation feel/live overlaps not run |
| Sound | Native bus/cue tests; prior measured output record retained | Listening, loop seam and mix balance not run |
| Controller | Synthetic menu events in presentation suite | Physical fight/every menu not run; device unknown |
| Full run | Scripted progression/reset checks | Title-to-victory clear, time and Play Again not run by a human |
| Replacement | Real inherited-scene swap; 43 checks; native staged poses | Live alternate-art fight feel not run |

To finish acceptance, record a keyboard title-to-victory run and completion time;
die/retry in the first fight, yard fight and boss arena; repeat victory → Play
Again. Check every menu and a fight on a real controller and name the device.
Listen during ordinary/boss fights and menus, including volume/mute/pause and
loop seam. Play the swap sample to assess feet, depth overlaps and hit timing
in motion. Record any defects and resolve them within this scope. Missing
hardware/listening evidence prevents a claim that the game is fully accepted.

Intentionally untouched: primary level and chosen cast; all gameplay scripts,
frame resources, tuning, waves, main menus/audio implementation, source pixels,
license files, engine/renderer/input configuration, original test scenes and
suites, historical Step 01–08 records, `2d-platform`. No new dependency, runtime
selector, external API call, commit, branch, push, PR, export or publication.
