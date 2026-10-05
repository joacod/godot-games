# Tasks

Step 01 is complete. Step 02 implementation is complete; physical keyboard
and movement-feel acceptance remains pending. Steps 03–04 are implemented with
automated and native fixture evidence. Step 04 physical input and human
attraction/pause/resume acceptance remain pending. Steps 05–06 are pending. See
[acceptance evidence](../../../survivors/docs/ACCEPTANCE.md).
Execute only the requested step and attach evidence
before checking tasks. Research completion is not gameplay completion.

## 1. Standalone arena and content contracts

[Detailed step guide](../../../survivors/docs/steps/01-foundation.md)

- [x] 1.1 Configure Compatibility, 640×360 logical viewport, 1280×720 window, preserved aspect and nearest filtering. Declare movement, confirm, cancel and pause actions.
- [x] 1.2 Create explicit content Resource schemas from DESIGN.md. Validate required IDs, numeric ranges, scene paths and four weapon definitions before starting a run.
- [x] 1.3 Build a bounded arena with contrasting floor, player marker and enemy marker. Put visuals under replaceable children; collision and movement dimensions are independent.
- [x] 1.4 Inspect chosen CraftPix files if acquiring art in this step; record provenance and actual animation mappings. Otherwise record candidate status and retain complete placeholders. No pack or account must be required at runtime.
- [x] 1.5 Create a SceneTree test entry point and document local import, test and launch commands. Record generated UIDs alongside each new script.
- [x] 1.6 Pass the step completion gate and record automated and native evidence in `survivors/docs/ACCEPTANCE.md`.

## 2. Movement, health and a pursuer

[Detailed step guide](../../../survivors/docs/steps/02-movement-and-health.md)

- [x] 2.1 Use normalized Input.get_vector movement, bounded collisions and a camera limited to the arena.
- [x] 2.2 Add a crawler that pursues the player on the open ground plane; share no code with existing games.
- [x] 2.3 Implement health, per-player contact invulnerability, hit flash and death signals. Clamp HP and emit death once.
- [x] 2.4 Provide a minimal defeat panel and full run rebuild for retry; later steps extend reset coverage.
- [ ] 2.5 Pass the step completion gate and record automated and native evidence in `survivors/docs/ACCEPTANCE.md`.

## 3. Four automatic weapons

[Detailed step guide](../../../survivors/docs/steps/03-automatic-weapons.md)

- [x] 3.1 Implement Spark nearest-target shots, Halo orbital contact, Pulse radial damage and Shard cardinal bursts from their data.
- [x] 3.2 Separate targeting/cadence from attack lifetime; delete expired attacks and guard against freed or already dead targets.
- [x] 3.3 Define collision layers for player, enemies, attacks and pickups. Attacks cannot damage the player.
- [x] 3.4 Give each effect a readable shape; hit feedback must leave the player silhouette visible. Use a test-only loadout fixture to exercise all four without adding debug controls to the player flow.
- [x] 3.5 Pass the step completion gate and record automated and native evidence in `survivors/docs/ACCEPTANCE.md`.

## 4. XP, three choices and one evolution

[Detailed step guide](../../../survivors/docs/steps/04-xp-and-evolution.md)

- [x] 4.1 Award gem XP once per enemy death. Attract nearby gems toward the player and collect each once; do not mutate content Resources.
- [x] 4.2 Use data thresholds, preserve excess XP, and queue multiple earned levels. Pause run time, spawning, physics damage and attack cadence while resolving choices.
- [x] 4.3 Offer exactly three distinct effective choices; implement weapon-unlock priority, Lens offer by level 3, Spark rank priority and repeatable fallbacks from DESIGN.md.
- [x] 4.4 Handle either order of rank-3 Spark and Lens. Replace Spark in place with Arc Spark once; clear old attacks as appropriate and preserve other weapon slots.
- [x] 4.5 Consume menu confirmation before resuming. Extend retry to clear XP, choices, ranks, passives and gems.
- [ ] 4.6 Pass the step completion gate and record automated and native evidence in `survivors/docs/ACCEPTANCE.md`.

## 5. Spawn pacing, elite and outcomes

[Detailed step guide](../../../survivors/docs/steps/05-three-minute-run.md)

- [ ] 5.1 Implement the three spawn phases, population cap and one elite at 120 seconds. Mark safe edge entry when offscreen spawning is impossible.
- [ ] 5.2 Display HP, XP, level, equipped weapon icons and time. Victory occurs at 180 active seconds if still alive; evaluate lethal damage before victory when both occur in the same physics tick.
- [ ] 5.3 Stop spawning, attacks and pickups on outcome. Retry reconstructs all run state and does not retain signal connections or delayed callbacks.
- [ ] 5.4 Tune XP and enemy cadence so a normal completion can unlock all weapons and evolve Spark by 150 seconds. Keep the content count locked.
- [ ] 5.5 Pass the step completion gate and record automated and native evidence in `survivors/docs/ACCEPTANCE.md`.

## 6. Acceptance and independent reskin proof

[Detailed step guide](../../../survivors/docs/steps/06-acceptance-and-reskin.md)

- [ ] 6.1 Run all import and behavioral checks; fix only slice defects exposed by them.
- [ ] 6.2 Follow the DESIGN.md acceptance route in a native window. Save a representative 15-second mid-run capture and note whether threats and pickup attraction remain legible.
- [ ] 6.3 Copy the game outside the repository, omit .godot, and change character name, palette, actor visual and a weapon tuning value in data. Confirm unchanged mechanics-script hashes.
- [ ] 6.4 Launch and complete the copy without sibling files. Record separate automated, visual, keyboard and human-balance evidence; no controller claim.
- [ ] 6.5 Update the README copy instructions and actual content paths. Mark OpenSpec tasks complete only when evidence supports them; archive only after the game is accepted.
- [ ] 6.6 Pass the step completion gate and record automated and native evidence in `survivors/docs/ACCEPTANCE.md`.
