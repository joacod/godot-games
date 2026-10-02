# Step 07 — Breakable prop and health recovery

Status: implemented, pending manual validation. Prerequisite: Step 06 accepted
by the user for progression on 2026-10-02.

## Outcome

A breakable on the route drops food that restores health, adding a deliberate
recovery opportunity without changing the game loop.

## Work

1. Add one breakable type using the existing damage path, ground depth checks,
   a broken state and one deterministic food drop.
2. Keep props nonblocking to movement so this step does not introduce navigation
   requirements. Place the recovery prop on the connecting stretch.
3. Add grounded proximity pickup, health clamping and one collection event.
   At full health, leave food unconsumed. Dead or airborne players cannot collect.
4. Reset props and food with the run. Tune damage, enemy counts and food recovery
   through playtesting; record final values and completion time.

## Acceptance

- A prop breaks and drops once even if several hit events coincide.
- Food heals once, cannot exceed max health, and requires ground/depth proximity.
- Retry restores the original prop and removes drops from the previous run.
- The complete level remains fair with the intended recovery opportunity.

Exclude inventory, randomized loot, score, weapons and new prop families.
See [assets](../../ASSETS.md) and [validation](../ACCEPTANCE.md).

## Completion record

Implemented on 2026-10-02 with Godot **4.7.2.stable.official.ed1daf0bf**,
Compatibility renderer. **Pending recovery/balance manual acceptance.**

Behavior and current tuning:

- One nonblocking crate at (1280, 278), between the first and second fights.
  It has 20 HP; two opening punches (10 HP each) break it. The existing player
  strike registry and facing/reach/depth/height checks apply. Its enemy team
  prevents enemy strikes from destroying the recovery opportunity.
- Broken state hides the crate and its hint, shows fallen planks, and drops
  food once at (1312, 278). The broken flag is set before spawning or signalling,
  preventing duplicate drops from simultaneous or reentrant damage events.
- Food restores up to 30 HP, with X proximity ≤22 px and depth difference ≤12 px.
  Full health, nonpositive recovery, death, airborne height, and jump initiation
  reject collection without consuming food. Health clamps at the player's maximum.
  The pickup guards before health/collection signals so callbacks cannot collect
  it twice. A successful pickup hides and removes it; pause/result menus freeze it.
- Retry/Play Again use the existing whole-street replacement, restoring the crate
  and removing old food/debris. Main Menu removes them with the run.
- Enemy counts, damage, attack timings and route length remain unchanged.
  These are implementation values, **not final playtest balance**. Full-route
  completion time has not been measured; the 5–8 minute target remains unverified.

Files changed:

- New `scenes/props/breakable.gd`, `food.gd`, their `.gd.uid` files and scenes:
  one receiver, broken visual, deterministic food and proximity collection.
- `scenes/player/player.gd`: bounded health restoration with one health signal.
- `scenes/level/street.gd` / `.tscn`: place the crate and assign its player target.
- `assets/props/crate.png`, `food.png` and generated imports;
  `assets/licenses/food.txt`, provenance and asset brief: exact CraftPix source records.
- New `tests/props_test.gd` and `.gd.uid`; `tests/boss_test.gd` compares receiver
  count before/after repeated entry, accounting for the new prop without weakening
  its duplicate-entry check.
- README, plan, acceptance checklist, this record and Step 06's progression status.

Verification from the repository root:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path beat-em-up --quit --log-file /private/tmp/props-import-final.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --quit-after 120 --log-file /private/tmp/props-startup.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/movement_test.gd --log-file /private/tmp/props-movement.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/combat_test.gd --log-file /private/tmp/props-combat.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/enemies_test.gd --log-file /private/tmp/props-enemies.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/level_test.gd --log-file /private/tmp/props-level.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/boss_test.gd --log-file /private/tmp/props-boss.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/props_test.gd --log-file /private/tmp/props-test.log
git diff --check
```

Results: movement **48/48**, combat **58/58**, enemies **35/35**, level **33/33**,
boss **125/125**, props **36/36**; **335 checks passed**. Startup and imports exited
zero without scene/resource/script errors. Headless runs report the macOS
`get_system_ca_certificates` diagnostic; editor import also cannot save global
editor settings under the sandbox. All three new script UIDs were generated.

Prop tests exercise the real scenes and combat path: facing/reach/depth/height
misses, windup versus active damage, per-strike deduplication, enemy filtering,
one break/drop under reentrant callbacks, full-health retention, proximity,
jump initiation/airborne/dead rejection, clamped restoration and one collection/
health event. They cover pause/resume, Retry after pause/death, Play Again,
and Main Menu cleanup. These automated events do not establish hardware support.

Native staged rendering used a temporary SceneTree harness:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path beat-em-up --fixed-fps 60 --script /private/tmp/props-render.gd --log-file /private/tmp/props-render.log
```

The initial sandboxed native launch exited 134; rerunning outside the sandbox
succeeded with native OpenGL. Inspected intact crate/hint, broken planks/food,
hero at another depth, and collected food with HUD changing 60→90 HP.
Scale, anchor and labels are readable at 640 × 360; food/debris sort under the
hero when its feet are nearer. This is **staged rendering, not a full playthrough
or balance test**. Images are temporary `/private/tmp/props-*.png`, not shipped assets.

Intentionally untouched: shared combat receiver, ordinary enemy/boss behavior,
encounter waves/counts, run/menu owner, input map, engine/renderer, earlier test
scenes, `2d-platform`, and Steps 08–09. No inventory, random loot, new prop family,
sound, dependency, commit, branch, push, PR or publication.

Remaining hands-on checks: clear the full route using recovery; verify crate/food
readability and nonblocking movement, retain food at full health, collect after
damage, pause/retry while food is available, and record completion time/fairness.
Keyboard and physical controller input need actual play observations; audio
remains for presentation. Adjust recovery or encounter tuning only from that
feedback. Step 08 has not started.
