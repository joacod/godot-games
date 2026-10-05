# Survivors — one arena, three minutes

## Core loop

Move a lone ward keeper around a small top-down clearing while four automatic
weapons repel approaching creatures. Defeated enemies leave XP gems; moving
near them pulls them toward the player. Level-ups pause the action and offer
three upgrades, building toward one weapon evolution. Read enemy silhouettes,
keep an escape lane open, defeat or avoid the elite, and survive 180 seconds.
Health reaching zero loses the run; retry starts a clean arena.

## Slice and exclusions

- One character, one bounded arena, one ordinary enemy type and one elite variant.
- Four base weapons, one passive, one evolution, XP, exactly three choices per level-up.
- WASD/arrows for movement; mouse or keyboard for menus. No aim or fire controls.
- Start, pause, victory, defeat, and retry. Gameplay timer excludes menu pauses.
- No meta progression, saves, multiple biomes, boss marathon, quests, procedural
  maps, manual attacks, multiplayer, or unlock economy.

## Content and balance proposal

Working theme: **Last Light Clearing**. Names and numbers below are initial
tuning decisions, not measured balance. Use a 640×360 logical viewport and an
approximately 960×640 arena with following camera and bounded edges.

| Content | Initial behavior |
| --- | --- |
| Keeper | 100 HP, 150 px/s, clear outline and facing cue |
| Spark (weapon A) | Auto-target nearest living enemy every 0.7 s; 10 damage |
| Halo | Orbiting contact effect, 6 damage per target per 0.5 s |
| Pulse | Local radial hit every 2 s, 14 damage |
| Shard | Four cardinal projectiles every 1.4 s, 8 damage each |
| Lens (passive B) | Increases pickup radius from 48 to 80 px |
| Arc Spark (evolution) | Replaces rank-3 Spark when Lens is owned; chains to at most 3 distinct targets |
| Crawler | 20 HP, 45 px/s, 10 contact damage; player damage cooldown 0.7 s |
| Elite crawler | One spawn at 120 s, 240 HP, 38 px/s, 20 contact damage; larger outline and label |

Start with rank-1 Spark. Halo, Pulse, and Shard are available as level-up
unlocks, not additional characters or pickups. Base weapons have three ranks;
rank upgrades change values in data. Lens has one rank. Evaluate evolution
immediately after a relevant upgrade, in either acquisition order, once only;
it replaces Spark in its slot and is not a fifth equipped weapon.

Each level-up offers three distinct eligible choices. Prioritize at least one
unowned weapon while any remain; offer Lens by level 3 and prioritize Spark
rank upgrades until evolution is possible. Fill exhausted pools with three
distinct repeatable choices: Recovery (heal 20 HP, converting unused healing
to an additive damage-absorbing shield), Power (+5% base weapon damage), and
Reach (+8 px pickup radius). Shield, Power and Reach have no upgrade cap in
this three-minute slice, so each remains effective even at full health. These
are run modifiers, not additional equipped weapons or passive item types. Filter
no-effect choices. Never show duplicates or an unavailable rank. Queue multiple
levels and resolve one panel at a time. Aim for evolution by 90–150 seconds
without requiring lucky random choices; validate and adjust XP pacing.

Initial spawn schedule: 0–60 s one crawler each 1.0 s; 60–120 s each 0.65 s;
120–180 s each 0.4 s; cap ordinary living enemies at 60. Spawn outside the
camera view where arena bounds allow and never on the player; use marked edge
entry otherwise. No navigation maze is needed. XP starts at 5 per crawler;
thresholds, elite reward, gem merge behavior, and population cap are data.
Start at level 1 with the next level costing 10 XP; each later threshold costs
5 XP more than the previous one. Keep threshold values in `data/run.tres` and
preserve overflow. The elite drops 50 XP. Initially use one gem per kill with
no merge behavior; add merging only if measured gem counts justify it.
Ranks 2 and 3 initially multiply base damage by 1.25 and 1.5 respectively;
store the resulting per-rank values in each weapon Resource. Arc Spark inherits
rank-3 damage and cadence and adds its chain behavior. These values must be
tuned against the normal route rather than accepted from a fast-forward test.

A 15-second mid-run clip should show player, enemies, projectile directions,
hit flashes, HP loss, gem attraction, and an open movement lane. Avoid flashes
covering the player or permanent full-screen effects.

## Scene tree and script responsibilities

```text
Main (Node; menu/run transitions)
├── Run (Node2D; timer, outcome)
│   ├── Arena (Node2D; TileMapLayer or placeholder floor, boundary bodies)
│   ├── Player (CharacterBody2D; movement only)
│   │   ├── CollisionShape2D
│   │   ├── Visual (Node2D; replaceable packed scene)
│   │   ├── Hurtbox (Area2D)
│   │   ├── Magnet (Area2D)
│   │   ├── WeaponRack (Node; weapon cadence and targeting)
│   │   └── Camera2D
│   ├── Enemies (Node2D; enemy scene instances)
│   ├── Attacks (Node2D; projectile/effect scene instances)
│   ├── Gems (Node2D)
│   └── SpawnDirector (Node; schedule only)
└── UI (CanvasLayer)
    ├── HUD (Control)
    ├── UpgradeMenu (Control; processes during pause)
    └── Menus (Control; start/pause/result)
```

Separate scripts own movement, enemy pursuit, damage/health, attack lifetime,
gem attraction, XP/choices, spawn schedule, run outcome, and UI. Use signals
for damage, death, XP, and outcome; one death grants XP once. The run owns
mutable HP, elapsed time, ranks, and acquired passives.

## External data

| Local content | Externalized fields |
| --- | --- |
| `data/characters/*.tres` | ID, name, HP, speed, visual PackedScene |
| `data/weapons/*.tres` | ID, behavior kind, rank values, cadence, damage, radius, attack scene |
| `data/upgrades/*.tres` | Choice text/icon, eligibility, modifier, caps, evolution recipe |
| `data/enemies/*.tres` | HP, speed, damage, XP, visual scene, elite marker |
| `data/run.tres` | 180 s duration, spawn schedule, cap, thresholds, starting loadout |
| `data/theme.tres` | Palette, UI labels, optional audio, arena visual scene |

Behavior kinds are a small closed set (nearest shot, orbit, pulse, cardinal
burst); names never select behavior. Reskin these resources and `Visual`
scenes. Leave movement, damage, targeting, XP, and outcome scripts untouched.

## Godot APIs and pitfalls

Use `CharacterBody2D.move_and_slide()`, `Input.get_vector()`, `Area2D` signals,
`Timer`, `PackedScene.instantiate()`, and `CanvasLayer`.
[Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html)
overlap information updates with physics; do not assume a newly spawned
attack immediately has a fresh overlap list. Use signals and per-target hit
cooldowns; disable dead targets before awarding XP.

[SceneTree pause and process modes](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html)
must freeze spawning, attacks, damage, and run time while the upgrade UI still
accepts input. Unpausing must not trigger gameplay with the menu-confirm event.

## CraftPix candidates and gaps

Primary candidate: [Free Island Adventure Pixel Top-Down Minigame Kit](https://craftpix.net/freebies/free-island-adventure-pixel-top-down-minigame-kit/).
Its listing includes island tiles, animated heroes/creatures, and UI. Select
one hero and one creature only; derive the elite's visual distinction from
scale, outline, and label, while keeping its stats separate. This is a coherent
candidate for the arena and actors, pending actual sheet inspection.

Alternative enemy candidate: [Free Slime Mobs Pixel Art Top-Down Sprite Pack](https://craftpix.net/freebies/free-slime-mobs-pixel-art-top-down-sprite-pack/),
listed as PNG/PSD with movement, hurt, and death animations. Do not mix it in
unless scale and palette fit. No verified weapon-effects or XP-gem coverage;
use small geometric effects and labeled gems as the runnable baseline.

## Acceptance route — under five minutes

- [ ] Start in under 10 s; movement alone fires Spark and keeps the player readable.
- [ ] During the first minute, kill, see hit feedback, attract XP, and select one of exactly three choices.
- [ ] Open pause/upgrade UI: timer, spawning, damage, and weapons stop; resume cleanly.
- [ ] Acquire all four weapons and Lens, upgrade Spark, and see exactly one evolution replacing Spark.
- [ ] See the elite at 120 s and win at 180 s of active play; defeat is not required for victory.
- [ ] Total route including concise upgrade choices finishes under five minutes.
- [ ] On a separate short run, stand in danger, lose, and retry with fresh HP, XP, timer, and enemies.
- [ ] Record a 15 s mid-run clip and assess readability manually; no console errors in either route.

## Project boundary and status

Research handoff dated 2026-10-03. Steps 01–03 were implemented on
2026-10-05; Step 02 physical keyboard and movement-feel acceptance is pending. See [acceptance evidence](ACCEPTANCE.md). This document describes
the complete future slice; later gameplay steps and full playable acceptance remain pending.
Use Godot 4.7, verified locally as 4.7.2, GDScript, and Compatibility rendering.
Each game owns its eventual `project.godot`, scenes, scripts, data, assets, and
checks. No shared launcher, autoload, source imports, symlinks, or sibling-game
resources. OpenSpec at the repository root is planning tooling only.

## Copy and reskin contract

Copy this entire game folder to a new location, including `project.godot`,
`scenes/`, `scripts/`, script `.gd.uid` files, `data/`, `assets/`, `docs/`, and
`tests/` once implemented. Omit generated `.godot/`, export builds, and local
logs. OpenSpec and all sibling folders are unnecessary to run the copy.
All runtime references must resolve within the copied project's `res://`.

Change the project display name, data values, text, and visual packed scenes.
Preserve stable content IDs, data schemas, signal contracts, collision layers,
and the documented visual attachment points. Replacing art must not change
hitboxes, interaction regions, or mechanics scripts. A new mechanic is a code
change; a new theme using existing mechanics is not.

Keep immutable content Resources separate from mutable run state. Reset runtime
state by rebuilding the run, not by mutating loaded content assets. Use focused
scripts for input, rules, content loading, actor behavior, and UI; do not create
an all-purpose controller or a reusable framework spanning these games.
Godot [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
and packed scenes provide the local data/presentation boundary.

## Asset research policy

Candidate product descriptions were checked on 2026-10-03. Archives, exact
frame layouts, account entitlements, and in-engine appearance are not verified.
Before import, record source URL, archive name, used files, frame dimensions,
animation mapping, modifications, and license evidence in `assets/PROVENANCE.md`.
Use only the files needed by this game, stored inside this game.

CraftPix's [license page](https://craftpix.net/file-licenses/) distinguishes
use in games from distribution of retrievable artwork and templates. Do not
assume a free download or account subscription grants unrestricted template
redistribution. Keep a complete placeholder presentation available; verify the
applicable terms before including art in a distributed source template.
No purchase, account access, download, or asset inclusion occurred in this handoff.

## Verification and evidence

These are future implementation commands, run from this game's folder:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/run_tests.gd
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

The test runner exists and covers content contracts, movement, pursuit, health,
defeat, retry, four automatic weapons, attack cleanup, and enemy death. Extend it for each later step.
Test observable behavior and boundary cases, not merely node existence.
Record engine version, commands, results, and remaining gaps in
`docs/ACCEPTANCE.md`. Separately record native rendering/input and a timed human
playthrough. Capture console output through win, invalid actions or loss, and
restart; require no errors. Headless success does not prove visual clarity,
feel, physical input, or balance. Controller support is outside this slice.
Repeat launch and the completion route from a copy outside this repository,
with no sibling projects available. Keep all acceptance items unchecked until
that evidence exists.

## Implementation steps

See [the step index](STEPS.md) and [OpenSpec tasks](../../openspec/changes/add-survivors/tasks.md).
