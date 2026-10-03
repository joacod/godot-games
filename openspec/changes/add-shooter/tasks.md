# Tasks

Implementation is pending. Execute only the requested step and attach evidence
before checking tasks. Research completion is not gameplay completion.

## 1. Standalone 3D maze and map validation

[Detailed step guide](../../../shooter/docs/steps/01-foundation.md)

- [ ] 1.1 Use Godot 4.7.2, GDScript and Compatibility with a 1280×720 default window and scalable HUD.
- [ ] 1.2 Declare WASD, fire, interact, pause and confirm actions. Create native 3D floor/walls with uniform height and 2 m cells from DESIGN.md.
- [ ] 1.3 Validate rectangular grid, recognized symbols, exactly one player/key/door/exit, correct actor counts, and walkable entity placements.
- [ ] 1.4 Check key reachability with the door closed; exit unreachable while closed and reachable while open. Add the exterior backing wall behind the east-edge exit.
- [ ] 1.5 Use primitive models and materials. Record CraftPix HUD candidates and unresolved directional-enemy coverage; no download is a startup dependency.
- [ ] 1.6 Create the test runner and retain generated script UIDs.
- [ ] 1.7 Pass the step completion gate and record automated and native evidence in `shooter/docs/ACCEPTANCE.md`.

## 2. WASD, mouse look and pause capture

[Detailed step guide](../../../shooter/docs/steps/02-fps-movement.md)

- [ ] 2.1 Use CharacterBody3D and a collision capsule with comfortable clearance inside 2 m cells.
- [ ] 2.2 Apply mouse yaw and clamped pitch; keep horizontal movement on XZ with no jump/crouch.
- [ ] 2.3 Capture mouse on explicit start/resume; Escape, focus loss and result menus release it.
- [ ] 2.4 Normalize movement, block wall penetration and keep the camera inside its body clearances.
- [ ] 2.5 Consume resume click so later weapon logic cannot treat it as fire.
- [ ] 2.6 Pass the step completion gate and record automated and native evidence in `shooter/docs/ACCEPTANCE.md`.

## 3. Hitscan combat, damage and death

[Detailed step guide](../../../shooter/docs/steps/03-hitscan-and-health.md)

- [ ] 3.1 Fire from camera aim using a refreshed ray, fixed cooldown and unlimited ammunition.
- [ ] 3.2 Define world/door/actor collision masks and exclude the shooter. Resolve only the first obstruction within range.
- [ ] 3.3 Implement clamped HP, one death event, visible hit feedback and basic defeat/retry.
- [ ] 3.4 Add crosshair and HP HUD; optional CraftPix icon only if inspected and recorded, never as a 3D viewmodel substitute.
- [ ] 3.5 Pass the step completion gate and record automated and native evidence in `shooter/docs/ACCEPTANCE.md`.

## 4. Guard pursuit and sentry shots

[Detailed step guide](../../../shooter/docs/steps/04-two-enemy-types.md)

- [ ] 4.1 Implement IDLE/CHASE/ATTACK/DEAD; guard pursues the last seen player cell, sentry stays in place.
- [ ] 4.2 Use wall-aware sight and a visible sentry windup. Recheck sight at firing time and cancel occluded attacks.
- [ ] 4.3 Build AStarGrid2D for XZ, disable diagonal movement, and mark wall/door cells solid after update(). Repath on cell changes or bounded cadence.
- [ ] 4.4 Make guard contact damage rate-limited. Death disables attacks and blocking collision immediately.
- [ ] 4.5 Use distinct primitive shapes, scale and labels for the two types; no dependency on directional sprite packs.
- [ ] 4.6 Pass the step completion gate and record automated and native evidence in `shooter/docs/ACCEPTANCE.md`.

## 5. Key, health, locked door and complete route

[Detailed step guide](../../../shooter/docs/steps/05-key-door-and-exit.md)

- [ ] 5.1 Collect key once; E at the aimed nearby door produces locked feedback without it and opens permanently with it.
- [ ] 5.2 Keep door collision and pathfinding solidity in agreement throughout opening, then clear both together.
- [ ] 5.3 Health pickups clamp at maximum and remain unused while healthy.
- [ ] 5.4 Gate the exit by door-open state; show victory on entry. Resolve lethal damage before victory if both occur in one physics tick.
- [ ] 5.5 Retry restores maze occupancy, player pose, health, key, pickups, all six enemies, weapon cooldown and mouse/menu state.
- [ ] 5.6 Pass the step completion gate and record automated and native evidence in `shooter/docs/ACCEPTANCE.md`.

## 6. Acceptance and standalone bunker reskin

[Detailed step guide](../../../shooter/docs/steps/06-acceptance-and-reskin.md)

- [ ] 6.1 Run the import and behavioral suite and follow the native under-five-minute route.
- [ ] 6.2 Verify mouse capture, aim, corners, hit feedback, both enemy tells and no damage through walls with real input.
- [ ] 6.3 Copy the game outside the repository without .godot. Change wall materials, enemy visual child scenes, item names and weapon tuning through data.
- [ ] 6.4 Compare mechanics-script hashes, import the copy and finish its level without sibling folders.
- [ ] 6.5 Record win and death/retry logs, actual completion time and human balance gaps. Finalize copy/edit guidance; mark only evidenced tasks complete.
- [ ] 6.6 Pass the step completion gate and record automated and native evidence in `shooter/docs/ACCEPTANCE.md`.
