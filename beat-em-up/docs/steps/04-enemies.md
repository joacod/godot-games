# Step 04 — Enemies and crowd combat

Status: accepted after user-reported manual testing. Prerequisite: Step 03 accepted.

## Outcome

A small live fight against grunts and a bruiser is winnable and losable with
readable attacks, manageable crowd pressure and a working reset.

## Work

1. Replace dummy behavior with a grunt that approaches, aligns, winds up,
   strikes and recovers. Add the slower, tougher bruiser variant.
2. Apply the existing damage/reaction rules to both. Telegraph attacks before
   activation and preserve committed facing; body overlap causes no damage.
3. Add simple separation and encounter-owned attack slots with a maximum of two
   commitments. Waiting enemies reposition without attacking offscreen.
4. Add provisional death/retry UI for this test fight; clean every enemy, slot
   and pending timer on reset. Test interruption and death slot release.

## Acceptance

- Both types can reach the hero across the unobstructed street without jitter or
  permanent stacking; their different timing is recognizable.
- Moving out of depth or behind a committed strike avoids damage.
- The player can defeat a mixed group and can die; retry restores the fight.
- An interrupted/dead enemy never reserves a slot forever; pause freezes all AI.

Exclude navigation systems, ranged enemies, new levels and a boss.
See [design](../DESIGN.md#enemies-and-encounters) and [validation](../ACCEPTANCE.md).

## Completion record

Date: 2026-10-02. Godot 4.7.2.stable.official.ed1daf0bf; Compatibility renderer.
Evidence applies to the Step 04 implementation. User approved implementation and
confirmed manual testing on 2026-10-02; Step 04 is accepted. No detailed device
results were supplied.

### Files and behavior

- Added `scenes/enemies/enemy.gd`, grunt/bruiser scenes and frame resources,
  `fight_street.gd`/`.tscn`, with generated script UIDs. Ordinary AI approaches
  assigned positions around the hero, aligns depth, telegraphs, strikes and
  recovers. Soft separation settles nearby actors; facing is committed through
  each strike. The existing receiver controls hurt, knockdown/get-up and death.
- Fight owner has three fixed actors and at most two attack slots. Recovery,
  hurt, death, outcome and retry release reservations. Offscreen actors cannot
  start commitments. Waiting enemies use separate depth lanes. No contact damage.
- Added provisional cleared/defeated prompts; R/Back resets every actor, health,
  position, reaction, queued strike, hit registry, cooldown, slots, camera and UI.
  Pause uses the existing pausable actor tree; there are no deferred spawn timers.
- `main.tscn` now opens the mixed fight. Added five Cyborg PNGs/import descriptors
  under `assets/bruiser/`; provenance records unchanged source pixels/mappings.
- Added `tests/enemies_test.gd` and UID. Movement/combat regression scripts now
  explicitly open their original test streets instead of the changing main scene.
- Updated README, PLAN, ACCEPTANCE, ASSETS and provenance. Preserved player combat,
  shared receiver, dummy/movement/sample scenes, engine configuration, existing
  art and all other games. No dependency, purchase, branch, commit or push.

### Initial tuning

| Type | Health | Speed (px/s) | Windup / active / recovery (s) | Damage |
| --- | --- | --- | --- | --- |
| Grunt ×2 | 60 | 85 | 0.4 / 0.1 / 0.4 | 12 |
| Bruiser ×1 | 100 | 55 | 0.65 / 0.12 / 0.65 | 22 + knockdown |

Both: 60 px reach, 14 px depth tolerance, 8 px height band, 0.4 s post-strike
or interrupted cooldown, 30 px/s hurt knockback, no ordinary hurt invulnerability.
Shared down/get-up protection remains. Hero stays at 100 health. Slot ownership
includes windup, active and recovery. New attacks require a visible ground anchor
within camera center ±280 px. Assigned offsets are (-38,0), (38,-12), (38,12);
preferred sides switch at street endpoints; waiting depth offsets are ±24 px. Soft separation radius is 24 px, settling below
2 px steering distance. Values are provisional pending a real mixed-fight playtest.

### Verification

From repository root, binary is `/Applications/Godot.app/Contents/MacOS/Godot`:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path beat-em-up --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --quit-after 120
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/movement_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/combat_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --script res://tests/enemies_test.gd
git diff --check
```

- Movement: 48 passed, 0 failed. Combat: 58 passed, 0 failed.
- Enemies: 35 passed, 0 failed. Includes two-slot bound, interruption/death/recovery
  release, offscreen rejection, facing/depth misses, no contact damage, paused AI,
  clean retry, player-authored damage clearing the mixed group, all three enemies
  approaching/getting attack opportunities, separated ground positions, and an
  idle hero losing to live AI. The scripted victory does not prove human balance.
- Import and headless startup: no script/resource/scene errors. Headless macOS
  certificate diagnostic persists. Sandboxed editor cannot save global settings;
  project assets and UIDs generated successfully. Explicit temporary log paths
  avoid restricted user-log writes.
- Native rendering: sandboxed renderer exited 134; rerun outside the sandbox
  successfully used OpenGL/Compatibility on Apple M2. A temporary capture script
  saved startup and 3-second crowd frames under `/private/tmp/fight-*.png`.
  Inspected actual 640 × 360 viewport pixels: distinct armored bruiser and grunts,
  grounded shadows/anchors, unclipped health/controls, crowd with two commitments
  and visible incoming damage. These are rendered observations, not live input
  or physical-controller playtests.

### Remaining acceptance and exclusions

The user confirmed manual testing and accepted the mixed-fight milestone.
Detailed observations for individual tell/contact/get-up presentation, street-edge
evasion, pause/death/retry, resized-window readability and a physical controller
were not supplied. These specific checks remain unrecorded for final acceptance;
no controller hardware support is claimed. No audio changes.
Step 05 route/waves/gates, boss, props, final menus and presentation remain untouched.
