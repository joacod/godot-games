# Survivors design and editing

Last Light Clearing is one bounded arena, one player, one ordinary enemy type,
one elite variant, four automatic weapons, XP upgrades and one evolution.
It has start, pause, victory, defeat and retry menus. There are no saves, meta
progression, manual attacks, procedural maps or cross-game runtime dependencies.

## Rules and content

The values below describe the shipped Resources. Human acceptance is recorded
in [ACCEPTANCE.md](ACCEPTANCE.md); future tuning should retain a playable full
route and run the regression checks.

| Content | Behavior |
| --- | --- |
| Keeper | 100 HP, 150 px/s; normalized movement |
| Spark | Nearest living target; 0.7 s cadence; damage 10 / 12.5 / 15 |
| Halo | Radius 36; orbit contact; 0.5 s per-target hit window; damage 6 / 7.5 / 9 |
| Pulse | Radius 72; one radial hit per activation every 2 s; damage 14 / 17.5 / 21 |
| Shard | Four cardinal projectiles every 1.4 s; damage 8 / 10 / 12 |
| Lens | Pickup radius increases from 48 to 80 px; existing Reach bonuses remain |
| Arc Spark | Rank-3 Spark plus Lens; replaces Spark once and chains to at most three distinct targets |
| Crawler | 20 HP, 45 px/s, 10 contact damage, 5 XP |
| Elite crawler | Once at 120 s; 240 HP, 38 px/s, 20 contact damage, 50 XP; larger visual and label |

Fractional damage rounds up to integer HP. Contact damage shares the player's
0.7-second invulnerability window and produces a short hit flash. Shield absorbs
damage before HP. Health reaching zero ends the run once.

### Upgrades and XP

The starting loadout is rank-1 Spark. Other weapons unlock through choices;
all base weapons have three ranks and Lens can be acquired once. Every level
panel offers exactly three distinct effective choices. Priority is one unowned
weapon, Lens from level 3 when unowned, then eligible Spark ranks and remaining
choices. After those are exhausted, repeatable choices remain effective:

- Recovery heals 20 HP and converts unused healing into shield.
- Power adds 5% of each weapon's rank-1 damage per selection.
- Reach adds 8 px pickup radius per selection.

These modifiers have no cap within the three-minute game. XP starts at a cost
of 10, then each next level costs 5 more. Excess XP is preserved and earned
panels queue in order. Action remains paused across queued choices and resumes
only after the confirmation input is released.

One gem drops per enemy death. Within pickup radius it starts moving toward the
player at 240 px/s, retains attraction if the player moves away, and collects
once within 12 px. Spark evolves immediately when rank 3 and Lens are both
owned, in either acquisition order. Evolution preserves the original loadout
slot, rank/cadence and other weapons; old Spark projectiles are cleared.

### Spawning and outcomes

| Active time | Ordinary spawn interval |
| --- | --- |
| 0–60 s | 1.0 s |
| 60–120 s | 0.65 s |
| 120–180 s | 0.4 s |

Living ordinary enemies and pending ordinary entries share a cap of 60.
Skipped spawn slots are discarded. Entries prefer offscreen arena edges at
least 160 px from the player. Visible entry uses a 0.7-second cross/ring warning;
the elite is harmless and invulnerable until its warning ends. The single elite
spawn is independent of the ordinary cap.

Upgrade panels and manual pause freeze active time, movement, damage, spawning,
attacks and pickups. A living player wins at 180 seconds. Lethal contact on the
same physics tick takes precedence over victory. Outcomes stop combat and
pending spawns/drops/pickups. Retry or a new Start constructs a fresh run rather
than mutating loaded Resources.

## Editing locations

| Path | Responsibility |
| --- | --- |
| `data/characters/keeper.tres` | Character ID, name, HP, speed and visual scene |
| `data/weapons/*.tres` | Behavior kind, rank damage, cadence, radius, projectile speed/lifetime and attack visual |
| `data/enemies/*.tres` | HP, speed, contact damage, XP, elite flag and visual |
| `data/upgrades/*.tres` | Choice text, eligibility, modifiers, ranks and evolution recipe |
| `data/run.tres` | Duration, spawn phases/cap, XP costs, starting loadout, contact cooldown and pickup radius |
| `data/theme.tres` | Palette, menu labels, arena visual path and UI Theme |
| `data/ui_theme.tres` | UI styling |
| `scenes/visuals/*.tscn` | Replaceable art with Node2D roots and no physics nodes |
| `scenes/arena.tscn`, `scenes/player.tscn`, `scenes/enemy.tscn`, `scenes/attacks/`, `scenes/xp_gem.tscn` | Physical geometry and collision contracts |

`content_validator.gd` checks content before Start. Missing or invalid content
leaves the menu open with field-specific diagnostics. Scene paths must be local
`res://` `.tscn` files. Stable IDs and behavior enums choose mechanics; display
names do not. The optional `music` field in the theme schema is not played by
the current game.

### Runtime ownership

`scenes/main.tscn` is the entry point. `main.gd` owns menu/run transitions,
pause and upgrade panels. Each `scenes/run.tscn` instance owns fresh mutable
state and contains Arena, Player, Enemies, Attacks, Gems, XP, Upgrades and
SpawnDirector. The player's WeaponRack owns equipped weapons and cadence.

| Scripts under `scripts/` | Responsibility |
| --- | --- |
| `player_movement.gd`, `enemy.gd`, `health.gd` | Movement, pursuit, health/contact damage and death |
| `weapon_rack.gd` | Targeting, cadence, ranks and evolution slot state |
| `projectile.gd`, `orbit_attack.gd`, `pulse_attack.gd` | Attack lifetime, collision and per-target hit rules |
| `xp_gem.gd`, `xp_progression.gd`, `upgrade_choices.gd` | Attraction/collection, XP queue and upgrade effects |
| `spawn_director.gd`, `run.gd` | Spawn scheduling, active timer and outcome |
| `hud.gd`, `upgrade_menu.gd`, `main.gd` | Display and menu input |
| `content/*.gd` | Resource schemas and validation |

Area overlap information updates with physics. Projectile sweeps and overlaps
share one hit guard; dead enemies disable contact immediately. Gem drops are
deferred out of physics callbacks. Paused/outcome state rejects delayed damage
and collection. Preserve these boundaries when extending the game.

### Geometry and layers

The arena has fixed 960×640 physical geometry. The following camera includes a
64 px presentation margin; it does not enlarge the arena. Changing `arena_size`
alone does not change walls. Keep matching scene geometry when changing bounds.

| Layer bit | Role |
| --- | --- |
| 1 | Walls |
| 2 | Player |
| 4 | Enemies |
| 8 | Attacks |
| 16 | Pickups |

The player blocks against walls; its Hurtbox scans enemies without blocking
their movement. Attacks scan only enemies. Art attaches below `Arena/Visual`
and actor/attack `Visual` children; collisions stay outside those children.

## Copy and reskin

Copy the whole game, including `project.godot`, scenes, scripts, `.gd.uid` files,
data, assets, tests and docs. Omit `.godot/`, exports, logs and Python caches.
Import and run tests before editing. Sibling games and repository-level OpenSpec
files are not required at runtime.

Change labels, palette, stat values and local visual paths in Resources; replace
visual packed scenes when needed. Preserve stable IDs, schemas, signal contracts,
collision layers/shapes and attachment points. Keep immutable content separate
from per-run state. New mechanics need code changes; presentation and existing
stat tuning do not.

`tests/prepare_reskin.py` provides a repeatable example from the base game. It
requires Python 3.9+, a new absolute destination outside the repository, and no
source symlinks. It changes exactly three copied Resources: character name and
existing actor visual, theme title/palette, and Spark lifetime 3.0 → 3.2 s.
It writes a sibling SHA-256 manifest and verifies all other file hashes remain
identical, including runtime scripts, UIDs and scenes. This example was verified
through a native win, loss and retry; see [the commands](ACCEPTANCE.md#independent-copy-check).

Regression fixtures assume the base damage/cadence balance. Deliberate tuning
changes may require updating the relevant behavioral expectations, while keeping
boundary and reset checks. Record any imported art in
[asset provenance](../assets/PROVENANCE.md) before adding it.
