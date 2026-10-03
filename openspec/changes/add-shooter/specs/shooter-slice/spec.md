# shooter slice requirements

## Purpose

Native 3D grid maze with hitscan, two enemy types, one key and locked door, health and an exit. The game is a standalone, reskinnable one-level example.

## ADDED Requirements

### Requirement: Simple first-person maze

The game SHALL provide one flat native-3D grid maze with WASD movement, mouse look and a single hitscan weapon.

#### Scenario: Basic control

- **WHEN** the player starts and moves, looks and fires
- **THEN** movement stays on the floor, walls block passage and shots follow camera aim

#### Scenario: Mouse release

- **WHEN** the player pauses or the window loses focus
- **THEN** gameplay stops and the mouse is released

#### Scenario: Resume click

- **WHEN** the player explicitly resumes from a menu
- **THEN** mouse capture returns without firing a shot from that click

### Requirement: Two enemy behaviors

The game SHALL contain chasing guards and stationary shooting sentries that detect with line of sight, attack and die.

#### Scenario: Guard chase

- **WHEN** a guard sees the player across connected corridors
- **THEN** it follows a wall-respecting route and attacks only within contact range

#### Scenario: Sentry attack

- **WHEN** a sentry detects an unobstructed player
- **THEN** it telegraphs its shot then fires if sight remains clear

#### Scenario: Death

- **WHEN** an enemy receives lethal damage
- **THEN** it stops attacking and no longer blocks movement

### Requirement: Occluded hitscan

World walls and closed doors SHALL block player shots, enemy sight and sentry shots.

#### Scenario: Blocked player shot

- **WHEN** the player fires toward an enemy behind a wall or closed door
- **THEN** the obstruction takes the ray and the enemy takes no damage

#### Scenario: Occluded windup

- **WHEN** the player moves behind cover during a sentry windup
- **THEN** the pending shot does not damage the player through cover

### Requirement: Key and locked door

Exactly one key SHALL unlock the single locked door, which SHALL gate the only route to the exit.

#### Scenario: Before key

- **WHEN** the player interacts with the door without owning the key
- **THEN** the door remains blocking and shows a locked message

#### Scenario: Valid unlock

- **WHEN** the player owns the key and interacts while aiming at the door within 1.5 meters
- **THEN** the door opens permanently and becomes traversable

#### Scenario: Maze topology

- **WHEN** the level is loaded with the door closed
- **THEN** the key is reachable and the exit is not; opening the door makes the exit reachable

### Requirement: Health and outcomes

Health pickups SHALL heal up to maximum without being consumed at full health. Zero health SHALL lose; entering the unlocked exit SHALL win.

#### Scenario: Healthy pickup

- **WHEN** a full-health player touches a health pickup
- **THEN** it remains available

#### Scenario: Injured pickup

- **WHEN** an injured player touches a health pickup
- **THEN** health increases by the configured amount up to maximum and the pickup is consumed once

#### Scenario: Outcome tie

- **WHEN** lethal damage and exit entry occur in one physics tick
- **THEN** defeat takes precedence

### Requirement: Fresh retry and short route

Retry SHALL restore the maze, player pose, enemies, health, pickups, key and locked door. A successful route SHALL be playable in under five minutes.

#### Scenario: Retry

- **WHEN** the player retries after dying with the key or after winning
- **THEN** a fresh level starts with no retained key, dead enemies, open door or missing pickups

#### Scenario: Timed success

- **WHEN** the player fights both types, collects the key and opens the door
- **THEN** the exit can be reached in under five minutes

### Requirement: Independent runnable copy

The complete `shooter/` folder SHALL launch and run in Godot 4.7 without sibling projects, required asset downloads or repository-level runtime resources.

#### Scenario: Isolated copy

- **WHEN** the implemented shooter folder is copied outside the repository without its generated cache
- **THEN** it imports, launches and reaches its intended completion state with no missing resources or console errors

### Requirement: Data and visual reskin

Names, text, tuning and presentation SHALL be replaceable through local data or visual scenes without editing mechanics scripts.

#### Scenario: Cosmetic swap

- **WHEN** the documented reskin fields and visual scenes are changed in an isolated copy
- **THEN** the game uses the new presentation and preserves its mechanic contracts with unchanged mechanics scripts
