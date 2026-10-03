# point-and-click slice requirements

## Purpose

Fixed-room adventure with three verbs, bounded inventory, external dialogue and one recoverable puzzle chain. The game is a standalone, reskinnable one-level example.

## ADDED Requirements

### Requirement: Fixed-room adventure

The game SHALL provide one fixed-camera location with Look, Use and Talk hotspot interactions and no action combat.

#### Scenario: Discoverable scene

- **WHEN** the player hovers the oil, press, clerk, noticeboard and gate
- **THEN** each hotspot has a readable name and Look response

#### Scenario: Unsupported action

- **WHEN** the player selects Talk or Use on an unsupported target
- **THEN** authored feedback appears without changing puzzle state

### Requirement: Bounded inventory

Inventory SHALL hold at most six items, allow selection and cancellation, and prevent loss of required items from invalid actions.

#### Scenario: Wrong target

- **WHEN** oil is used on the clerk
- **THEN** oil remains in inventory and explanatory feedback appears

#### Scenario: Full inventory

- **WHEN** the player attempts a pickup while six slots are occupied
- **THEN** the pickup remains available and no pickup flag is set

#### Scenario: Cancel selection

- **WHEN** the player right-clicks after selecting an item
- **THEN** selection clears without using or discarding the item

### Requirement: One puzzle chain

Completion SHALL require collecting oil, using it on the press, talking to the clerk for a pass, and using the pass on the exit gate.

#### Scenario: Complete chain

- **WHEN** the player performs the required actions in order
- **THEN** the press repairs, oil is consumed once, one pass is granted, and the gate completes the level

#### Scenario: Early exit

- **WHEN** the player uses the gate without a pass
- **THEN** the room remains playable and the gate provides a clue

#### Scenario: Repeat rewards

- **WHEN** the player talks to the clerk repeatedly after receiving the pass
- **THEN** no duplicate pass is granted

### Requirement: External dialogue and rules

Dialogue, choice text, conditions and puzzle responses SHALL be external content data. Invalid content SHALL report the offending file or ID before play.

#### Scenario: Text replacement

- **WHEN** dialogue text is changed without editing mechanics scripts
- **THEN** the new text appears in the same functioning puzzle

#### Scenario: Broken dialogue reference

- **WHEN** a choice refers to a nonexistent dialogue node
- **THEN** content validation explains the invalid reference instead of starting a broken puzzle

### Requirement: Safe interaction ordering

Invalid actions SHALL preserve progress and required-item availability. Modal UI SHALL prevent clicks from activating underlying room hotspots.

#### Scenario: Click through prevention

- **WHEN** the player clicks a dialogue choice over a room hotspot
- **THEN** only the dialogue choice is handled

#### Scenario: Capacity-safe reward

- **WHEN** a dialogue reward would exceed inventory capacity
- **THEN** the item and reward flag remain uncommitted and the player can retry

#### Scenario: Recoverable order

- **WHEN** the player talks or inspects the exit before finding oil
- **THEN** the next clue remains available and the puzzle can still be completed

### Requirement: Completion and restart

The adventure SHALL finish without a forced loss state and SHALL offer restart that restores all initial puzzle, inventory and dialogue state.

#### Scenario: Restart partway or after completion

- **WHEN** the player restarts with a repaired press or completed gate
- **THEN** oil is available, press is unrepaired, pass is absent and initial dialogue is restored

#### Scenario: Timed route

- **WHEN** a player follows the visible clues
- **THEN** the complete route can be played in under five minutes

### Requirement: Independent runnable copy

The complete `point-and-click/` folder SHALL launch and run in Godot 4.7 without sibling projects, required asset downloads or repository-level runtime resources.

#### Scenario: Isolated copy

- **WHEN** the implemented point-and-click folder is copied outside the repository without its generated cache
- **THEN** it imports, launches and reaches its intended completion state with no missing resources or console errors

### Requirement: Data and visual reskin

Names, text, tuning and presentation SHALL be replaceable through local data or visual scenes without editing mechanics scripts.

#### Scenario: Cosmetic swap

- **WHEN** the documented reskin fields and visual scenes are changed in an isolated copy
- **THEN** the game uses the new presentation and preserves its mechanic contracts with unchanged mechanics scripts
