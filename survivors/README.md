# Last Light Clearing

A standalone Godot Survivors project. **Step 02 is implemented:** move the
Keeper around a bounded arena while one Crawler pursues and damages on contact.
Defeat offers a fresh-health retry. Automatic weapons, XP, upgrades, spawning,
and the three-minute survival objective are future steps. Physical keyboard
and movement-feel acceptance for Step 02 remain pending.

## Run and check

Use **Godot 4.7**, verified with **4.7.2**, and Compatibility rendering. No asset
pack, download, plugin, or sibling project is required. From `survivors/`:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/run_tests.gd
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

Import before tests on a fresh checkout. The test runner returns nonzero for
failures or its 15-second timeout. Godot needs access to its normal macOS
application-data directory; restricted execution can produce `user://` or editor
settings errors unrelated to game content.

Click **Start**, or press Enter/Space on the focused button. **Back to menu** or
Escape removes the arena; Start builds a fresh one. Move with **WASD/arrows**. Contact costs 10 HP, with 0.7 seconds of player
invulnerability and a short silhouette flash. At zero HP, movement and pursuit
stop; **Retry** rebuilds both actors with fresh health and no immunity carried
over. Pause remains a future step.
The window opens at 1280×720 with a 640×360 logical viewport and preserved aspect.

## Content and presentation

| Path | Contract |
| --- | --- |
| `data/characters/keeper.tres` | Stable ID, display name, health, speed, visual scene |
| `data/weapons/*.tres` | Four behavior kinds, three damage ranks, cadence, radius, projectile speed/lifetime, attack visual |
| `data/enemies/*.tres` | Ordinary and elite stats, rewards, names, visual scenes |
| `data/upgrades/*.tres` | Four weapon choices, Lens, repeatable choices, one evolution recipe |
| `data/run.tres` | Content references, duration, spawn phases, cap, XP thresholds, loadout, damage cooldown, pickup radius |
| `data/theme.tres` | Palette, title/menu labels, arena visual, UI Theme, optional music |
| `data/ui_theme.tres` | UI typography and button styles |
| `scenes/visuals/*.tscn` | Replaceable presentation with Node2D roots and no physics nodes |

Movement speed, player HP, crawler speed/contact damage, and player damage
cooldown now come from these Resources. Weapon, XP, and spawn tuning remains
for later steps.
`content_validator.gd` validates all referenced content before constructing a run.
Invalid content leaves the menu open and shows field-specific diagnostics. Scene
paths must be local `res://` `.tscn` files, with a Node2D root and no physics nodes.
IDs are stable references; display names do not select behavior.

Arena art is attached under `Arena/Visual`; actors have their own `Visual`
children. Their collision shapes belong to the actor/arena scenes, outside art.
The foundation uses fixed 960×640 geometry; changing its dimensions requires a
matching geometry edit. The following camera is limited to the fixed arena plus a 64 px presentation
margin, keeping walls and the player visible beside the HUD. The margin does
not change physical boundaries. Collision layers are 1 (walls), 2 (player), and
4 (enemies); the player Hurtbox scans enemies without blocking their motion. Loaded content is not mutated by
menu transitions. Later mutable state belongs to each newly constructed run.

## Copy and reskin

Copy the whole `survivors/` folder, including script `.gd.uid` files, and omit
`.godot/`, `exports/`, and logs. Open the copied `project.godot`, import, and test.
All runtime files are local. Repository-level OpenSpec links are planning aids.

Change text, palette, and local visual paths in the Resources to reskin the
foundation. Keep stable IDs and collision shapes intact. Placeholder artwork is
available without external licensing or download requirements; see
[asset provenance](assets/PROVENANCE.md). A full gameplay reskin proof is Step 06.

See [design](docs/DESIGN.md), [steps](docs/STEPS.md), and
[acceptance evidence](docs/ACCEPTANCE.md). Continue one requested step at a time.
