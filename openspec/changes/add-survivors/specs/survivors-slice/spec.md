# survivors slice requirements

## Purpose

Movement-only bullet heaven with four weapons, XP, three upgrade choices, one evolution and a three-minute survival run. The game is a standalone, reskinnable one-level example.

## ADDED Requirements

### Requirement: Movement-only combat

The game SHALL provide one top-down player character whose gameplay input is movement; four base weapons SHALL attack automatically.

#### Scenario: Movement without firing input

- **WHEN** the player moves near enemies without pressing any attack button
- **THEN** equipped weapons attack at their configured cadence

#### Scenario: Four base weapons

- **WHEN** Spark, Halo, Pulse and Shard are equipped
- **THEN** nearest-target shots, orbit damage, radial pulses and cardinal bursts remain distinguishable

### Requirement: Bounded survival run

The game SHALL contain one map, one ordinary enemy type, one elite variant and a 180-second active-play survival objective.

#### Scenario: Timed success

- **WHEN** a living player reaches 180 active seconds
- **THEN** victory is shown and combat stops

#### Scenario: Elite timing

- **WHEN** active time crosses 120 seconds
- **THEN** exactly one elite spawns with a distinct silhouette and label

#### Scenario: Simultaneous death and timeout

- **WHEN** lethal damage and the deadline occur in the same physics tick
- **THEN** defeat takes precedence

### Requirement: XP and magnet

Defeated enemies SHALL grant XP gems once, and nearby gems SHALL visibly move toward the player before collection.

#### Scenario: Single collection

- **WHEN** a magnetized gem reaches the player
- **THEN** its XP is awarded once and the gem is removed

#### Scenario: Accumulated levels

- **WHEN** one collection crosses multiple level thresholds
- **THEN** excess XP is preserved and each earned level is resolved in sequence

### Requirement: Three upgrade choices

Each level-up SHALL offer exactly three distinct eligible choices and apply exactly one selected choice. Offers SHALL support reaching all four weapons and the evolution during a normal run.

#### Scenario: Paused decision

- **WHEN** a level-up panel opens
- **THEN** time, attacks, spawning and damage stop while the choice UI remains usable

#### Scenario: Exhausted ordinary upgrades

- **WHEN** all weapon ranks and Lens are acquired
- **THEN** three effective distinct repeatable upgrades remain available

#### Scenario: Guided progression

- **WHEN** the player chooses the offered weapon and evolution prerequisites
- **THEN** all four weapons and the evolution are reachable before the run ends

### Requirement: Single evolution

Rank-3 Spark plus Lens SHALL evolve into Arc Spark once, replacing Spark without consuming another equipped weapon slot.

#### Scenario: Either order

- **WHEN** the player obtains the second prerequisite in either order
- **THEN** Spark evolves immediately once and other equipped weapons are unchanged

#### Scenario: Chain limit

- **WHEN** an evolved shot hits clustered enemies
- **THEN** it hits at most three distinct targets and does not repeatedly strike one target

### Requirement: Readable feedback

The game SHALL communicate damage, pickups and elite threat while keeping the player and escape space readable.

#### Scenario: Mid-run clip

- **WHEN** a representative 15-second mid-run clip is reviewed
- **THEN** the reviewer can locate the player, identify enemies and attacks, see hit and pickup feedback, and identify an escape lane

### Requirement: Defeat and full retry

Zero health SHALL end the run; retry SHALL restore initial health, timer, loadout and progression and remove previous enemies, attacks and gems.

#### Scenario: Fresh attempt

- **WHEN** the player retries after defeat or victory
- **THEN** the new run contains no old ranks, passives, enemies, gems or delayed spawns

### Requirement: Independent runnable copy

The complete `survivors/` folder SHALL launch and run in Godot 4.7 without sibling projects, required asset downloads or repository-level runtime resources.

#### Scenario: Isolated copy

- **WHEN** the implemented survivors folder is copied outside the repository without its generated cache
- **THEN** it imports, launches and reaches its intended completion state with no missing resources or console errors

### Requirement: Data and visual reskin

Names, text, tuning and presentation SHALL be replaceable through local data or visual scenes without editing mechanics scripts.

#### Scenario: Cosmetic swap

- **WHEN** the documented reskin fields and visual scenes are changed in an isolated copy
- **THEN** the game uses the new presentation and preserves its mechanic contracts with unchanged mechanics scripts
