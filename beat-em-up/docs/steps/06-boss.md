# Step 06 — Boss and complete game loop

Status: accepted by user for progression. Prerequisite: Step 05 accepted.

## Outcome

The whole level can be won or lost, retried, and played again without stale state.

## Work

1. Add one boss with the designed sweep and straight charge: distinct tells,
   committed attack paths, arena-safe motion, and punishable recovery.
2. Implement boss health/HUD and non-interruptible committed attacks. Keep normal
   damage rules except for the explicit knockdown/interrupt exceptions.
3. Wire final arena entry, boss defeat and victory. Cancel active attacks on
   death; show results only once. Player death wins simultaneous-death arbitration.
4. Finish functional title, Controls, pause, Game Over and victory flows with
   keyboard/controller focus. Prevent confirm input from leaking into gameplay.
5. Add result/reset regressions and test transitions during each boss phase.

## Acceptance

- Both boss attacks can be intentionally avoided and punished; neither crosses
  arena bounds. Damage remains aligned with the visible tell and strike.
- Clear from title to victory; deliberately lose to the boss and retry from the
  level start. Play Again resets everything.
- Pause, Main Menu and Retry during windup, attack and recovery leave no attack,
  timer, camera lock, pause state, or duplicate result behind.

Exclude extra bosses, phases, adds, rewards and save data.
See [design](../DESIGN.md) and [validation](../ACCEPTANCE.md).

## Boss tuning and animation mapping

Toxic Enforcer has 240 HP, moves at 65 px/s, and alternates sweep/charge. The boss
uses the shared receiver/hit rules and team filtering. Positive damage during a
committed tell, active attack, or recovery reduces HP and flashes the sprite,
without knockback, knockdown, or timer interruption. Approach can be interrupted
by ordinary hurt. Lethal damage always follows shared cancellation and single-death
signalling. Keeping recovery intact prevents a hit from shortening the opening.

| Attack | Windup / active / recovery (seconds) | Damage | Reach / depth / height (pixels) | Movement |
| --- | --- | --- | --- | --- |
| Sweep | 0.55 / 0.12 / 0.9 | 18 | 72 / 14 / 8 | Stationary; locks facing |
| Charge | 0.85 / up to 1.2 / 1.1 | 24, knockdown | 40 / 14 / 8 | 310 px/s; fixed facing/depth; stops at arena edge |

Yellow ground markings show the threatened lane during windup. Labels distinguish
SWEEP/CHARGE and OPEN recovery. Each strike keeps one hit registry; body contact
is harmless. Values are editable in the boss Inspector. Charge integrates only
the active part of a physics tick and retains its full recovery when it reaches
a boundary early.

All boss frames are `Rect2(i * 96, 0, 96, 96)`, displayed at 2× with
`offset = Vector2(-48, -96)` under the separate Visual child. Sprite feet and
shadow stay at the ground root; Y sorting uses that root.

| Semantic animation | Sheet size | Frames / mapping | Playback |
| --- | --- | --- | --- |
| Idle | 384 × 96 | 0–3 | 8 FPS, looping |
| Move / active charge | 576 × 96 | 0–5 | 8 FPS, looping |
| Sweep | 576 × 96 | Tell 0–2; contact 3; recovery 5 | Held by attack phase |
| Charge prepare / recovery | 192 × 96 | Tell 0; recovery 1 | Held by attack phase |
| Hurt | 192 × 96 | 0–1 | Shared 0.24 s reaction |
| Death (`fall`) | 576 × 96 | 0–5, intact fall | 0.9 s; last pose held |

The final arena is X=2180–2720, Y=242–312. Entry at X=2240 locks the player and
camera (X=2450), spawning one boss at (2660, 278). The route/backdrop extends to
cover this 540-pixel arena. Existing ordinary encounters retain their authored
bounds and waves. Victory waits for the boss's death sequence, emits once, and
pauses the finished run. Player death prevents victory, including both orders of
simultaneous deaths. Retry/Play Again replace the whole street with a new instance;
Main Menu removes it. Menu confirmation requires release before gameplay input.

## Completion record

Implemented on 2026-10-02 with Godot **4.7.2.stable.official.ed1daf0bf**,
Compatibility renderer. Accepted by the user for progression on 2026-10-02
when confirming Step 07. Detailed hands-on observations were not supplied;
the remaining checks below still need recorded evidence.

Files changed:

- New `scenes/enemies/boss.gd` and `.gd.uid`, `boss.tscn`, `boss_frames.tres`:
  two-attack state machine, damage exceptions, tells, and death completion signal.
- Six unchanged source PNGs and generated `.import` files in `assets/boss/`;
  `assets/licenses/boss.txt` and `assets/PROVENANCE.md`: imported subset/source record.
- `scenes/level/street.gd` / `.tscn`: final arena entry, camera/bounds, boss spawn,
  death cancellation and victory; one more repeated backdrop/road segment.
- `scenes/ui/run.gd`: boss HP, guarded result transition, Victory/Play Again.
- New `tests/boss_test.gd` and `.gd.uid`; `tests/level_test.gd` now checks the
  implemented boss entrance instead of the old sealed endpoint.
- README, plan, asset brief, and acceptance checklist record the new milestone.

Verification from the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path beat-em-up --quit --log-file /private/tmp/boss-import-final.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --quit-after 120 --log-file /private/tmp/boss-startup.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/movement_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/combat_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/enemies_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/level_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/boss_test.gd
git diff --check
```

Results: movement **48/48**, combat **58/58**, enemies **35/35**, level **33/33**,
boss **125/125**; **299 checks passed**. Headless startup exited zero; imports,
scenes, and scripts loaded without script/resource errors. Headless logs report
macOS `get_system_ca_certificates`; editor import also cannot save the global
editor settings under the sandbox. Imports and both new UIDs were generated.
Native staged rendering ran outside the sandbox without those diagnostics.

Boss regressions exercise real scenes: safe one-time entry, attack alternation,
facing/depth commitment, wall-overlap attack initiation, damage without interruption/knockdown, one hit per strike,
depth/height/facing rejection, charge stops at both arena edges, and real player
finisher damage in both recovery windows. They cover boss death, hero death, pause,
resume, Retry and Main Menu in both attacks' windup/active/recovery; corpse pause,
simultaneous-death precedence in both orders, one result, and controller-confirm
Play Again with input-release gating. Earlier keyboard/controller menu regressions
remain passing. Synthetic events do not establish physical controller support.

Native staged rendering used a temporary SceneTree harness:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path beat-em-up --fixed-fps 60 --script /private/tmp/boss-render.gd --log-file /private/tmp/boss-render.log
```

Inspected native OpenGL frames for sweep and charge windup/active/recovery, death,
Victory, and Game Over. Boss silhouette is larger than the hero; feet/shadow are
anchored; labels, lane marking, arena gates, both HP values and result focus are
readable at the logical 640 × 360 viewport. This harness stages positions and
phases and is **not a hands-on clear or balance playtest**. Images are temporary
`/private/tmp/boss-*.png` files, not shipped gameplay assets.

Intentionally untouched: player/shared combat scripts, ordinary enemy logic and
waves, earlier test scenes, project version/renderer/input map, `2d-platform`,
and Steps 07–09. No extra boss phase, adds, prop, pickup, sound, save, dependency,
commit, branch, push, PR, or publication.

Remaining hands-on checks: title-to-victory clear; intentionally evade and punish
both attacks; die to the boss and Retry; Play Again; pause/resume and Main Menu
in actual combat; resized display and real controller (record device). Health,
attack timing and route duration need playtest feedback. Step 07's implementation
and pending recovery/balance acceptance are recorded in [Step 07](07-props.md).
