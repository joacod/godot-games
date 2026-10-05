# Last Light Clearing

A standalone Godot Survivors project. **Step 05 is implemented:** survive
180 active seconds against three waves and one elite at 120 seconds. Movement
alone fires your equipped weapons. Collect XP, choose upgrades, and combine
rank-3 Spark with Lens to evolve Arc Spark. Pause and upgrade menus freeze the
run; victory or defeat stops combat, and Retry builds a fresh attempt.
Physical input, human feel/balance, and Step 06 acceptance/reskin remain pending.

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

Click **Start**, or press Enter/Space on the focused button. **Back to menu**
removes the arena; Start builds a fresh one. Move with **WASD/arrows**. Ordinary
contact costs 10 HP and elite contact costs 20 HP, with 0.7 seconds of player
invulnerability and a short silhouette flash. At zero HP, movement and pursuit
stop; **Retry** rebuilds the run with fresh health and no immunity carried over. Retry also resets XP, choices, ranks, Lens, modifiers, shield and gems.
Upgrade panels freeze movement, damage and attacks; choose with mouse or arrows
and confirm with Enter/Space. Action resumes after confirmation is released.
Press **Escape or P** to pause; choose Resume or press Escape/P again to
continue. During upgrade choices, select an upgrade first. Back to menu abandons
the attempt. Victory appears at 3:00 if alive; lethal damage on that tick wins
over timeout. The HUD shows HP/shield, XP, level, weapon icons/ranks and time.
The window opens at 1280×720 with a 640×360 logical viewport and preserved aspect.

For all four weapons, run the test-only 15-second native combat fixture:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tests/combat_sample.gd
```

It uses scripted movement and manually placed high-health crawlers, writes three
viewport captures to `/private/tmp/survivors-step03-*.png`, and exits. Normal
Start has no debug controls or extra weapons. These older fixtures isolate their
supplied enemies from the spawn director.

To inspect progression with supplied XP and manually placed enemies, run:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tests/progression_sample.gd
```

It captures gem attraction, two choice panels, Arc Spark, shield and retry to
`/private/tmp/survivors-step04-*.png`, uses injected Enter events, and exits.
For the full native route using normal stats, drops and scripted movement/menu
inputs, run:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --script tests/run_sample.gd
```

It runs 180 active seconds, checks all weapons and evolution by 150 seconds,
then deliberately moves into enemies for loss/retry. Add `-- --panels` to the
command for a short controlled pause/elite/edge-warning visual fixture.
Viewport captures go to
`/private/tmp/survivors-step05-*.png`. This establishes scripted native execution;
physical input and human feel/balance remain separate acceptance checks.

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

Run duration, spawn phases, cap and elite timing use `data/run.tres`.
Movement speed, player HP, crawler speed/contact damage, and player damage
cooldown now come from these Resources. Weapon damage ranks, cadence, radius, projectile speed, lifetime, and visual
scene also drive combat. Fractional damage rounds up to integer HP. XP costs,
rewards, Lens, repeatable modifiers and the evolution recipe also use data.
Recovery heals before adding leftover healing to shield; Power adds 5% of each
weapon's rank-1 damage per choice; Reach adds pickup radius without a cap.
Arc Spark inherits rank-3 damage/cadence and flies toward up to three distinct
targets per shot. The existing 1.0/0.65/0.4-second spawn cadences and XP thresholds remain in data.
Ordinary living enemies are capped at 60; dead enemies free slots. Missed slots
at the cap are discarded. Spawn positions prefer offscreen arena edges at least
160 px away; when the arena is fully visible, a yellow cross/ring warns for
0.7 seconds before entry. Pending ordinary entries reserve cap slots. The elite
appears once at 120 active seconds, independently of the ordinary cap. If its
entry is visible, it remains harmless during the 0.7-second warning.
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
4 (enemies), 8 (attacks), and 16 (pickups); the player Hurtbox scans enemies without blocking their motion. Attacks scan only enemy layer 4. Enemy health is fresh per instance; death disables
contact immediately and removes the enemy once. Halo renews its equipped orbit
without resetting target hit windows; Pulse samples its radius once, then fades.
Projectile and effect scenes own their hitboxes, with replaceable art under Visual.
Loaded content is not mutated by
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
