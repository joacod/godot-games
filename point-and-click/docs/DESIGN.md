# Point-and-click — The Closed Gate

## Core loop

Explore one fixed castle gatehouse screen with Look, Use, and Talk. Inspect a
jammed stamp press, pick up an oil flask, use it on the press, then talk to the
clerk to receive a stamped pass. Use the pass on the gate to finish. Descriptions
and dialogue supply the clues; wrong combinations explain the problem without
consuming progress. Inventory stays small and every action is mouse driven.

## Slice and exclusions

- One location, one fixed camera, one NPC, five named hotspots, one puzzle chain.
- Hotspots: oil flask, stamp press, clerk, noticeboard, exit gate.
- Three explicit verb buttons: Look / Use / Talk. At most six inventory slots;
  this puzzle uses only two item IDs and at most one item held at a time.
- Inventory selection changes Use to “Use [item] with …”; right-click cancels.
- Dialogue choices, restart, and a completion screen. No loss state or dead ends.
- No combat, free movement controls, scrolling camera, platforming, timers,
  branching endings, save/load, voice acting, or general adventure authoring tool.

## Puzzle and interaction contract

Working theme: **The Closed Gate**, a lightly comic administrative obstacle.
The screen is a static illustrated stage; a player avatar and pathfinding are
not necessary. Present hotspots over scenery, not as an action-game map.
Use a 640×360 logical viewport with text UI legible at a 1280×720 window.

| Action | Preconditions | Result |
| --- | --- | --- |
| Look at noticeboard | None | Explains that only stamped passes open the gate |
| Talk to clerk | Press not repaired | Clerk identifies the stuck press and suggests oil |
| Use oil flask hotspot | Flask not taken | Add `oil`, hide pickup, set `oil_taken` |
| Use `oil` on press | Own `oil`, press not repaired | Consume oil and set `press_repaired` atomically |
| Talk to clerk, choose request pass | Press repaired, pass not granted | Grant `pass`, set `pass_granted` once |
| Use `pass` on gate | Own pass | Set `complete`; show result screen |
| Any invalid combination | Preconditions unmet | Contextual data-driven response; no inventory/flag mutation |

All hotspots support Look. Unsupported Use/Talk gives an authored response.
Repeated clerk conversations cannot duplicate the pass; repeated press or exit
clicks cannot consume twice. A full inventory rejects additions without removing
the source or setting completion flags. Restart clears all flags and inventory.
No required item can be discarded. The clerk provides the next relevant hint
on repeat Talk, so the player cannot become stuck from action ordering.

## Scene tree and script responsibilities

```text
Main (Node; start/run/completion transitions)
├── Room (Node2D; fixed composition)
│   ├── Background (Sprite2D or replaceable visual scene)
│   ├── Camera2D (fixed position and zoom)
│   ├── Props (Node2D; visual packed scenes)
│   └── Hotspots (Node2D)
│       └── Hotspot (Area2D + CollisionPolygon2D; ID and interaction signal)
├── PuzzleState (Node; flags and atomic action application)
├── Interaction (Node; verb, selected item, hotspot dispatch)
├── Inventory (Node; IDs, capacity, change signal)
├── Dialogue (Node; data conditions and conversation state)
└── UI (CanvasLayer)
    ├── Verbs (Control)
    ├── InventoryBar (Control; six slots)
    ├── Description (Label)
    ├── DialoguePanel (Control)
    └── Menus (Control)
```

Hotspots report IDs only. Interaction resolves data rules; PuzzleState validates
and applies their effects. Inventory owns capacity, Dialogue owns conversation
progress, and UI renders their signals. Avoid scripts per prop containing
special-case puzzle strings. Use a closed set of effects: set flag, grant item,
consume item, show text, start dialogue, finish.

## External data

Use project-local JSON loaded with `FileAccess` and `JSON.parse()` and validated
before play. Content errors name the file and offending ID in a visible error
panel rather than leaving a partially playable puzzle.

| Local content | Externalized fields |
| --- | --- |
| `data/room.json` | Room ID, background scene path, hotspot IDs, names, polygons, visual paths |
| `data/items.json` | Stable IDs, names, descriptions, icon scene paths; inventory cap remains six |
| `data/dialogue.json` | Speaker IDs, all lines, choice labels, conditions, next-node IDs, effects |
| `data/puzzle.json` | Verb/item/target rules, conditions, effects, initial flags, failure responses |
| `data/theme.tres` | Fonts, label palette and UI text metadata; visual bindings live in JSON |

Dialogue node shape: `id`, `speaker_id`, `text`, `choices`; a choice has `text`,
`requires`, `effects`, and optional `next_id`. Conditions use known flag/item
IDs only. Validate missing nodes, duplicate IDs, unknown effects, item refs,
and the initial node. No embedded script evaluation or arbitrary expressions.

A reskin changes room composition, NPC/prop scenes, item art, lines, and rules
within this schema. Preserve IDs for a cosmetic swap; update all references
together for a new puzzle. Leave verb dispatch, inventory, condition/effect
handling, and dialogue presentation scripts untouched.

## Implemented content schema (Step 01)

`scripts/content_loader.gd` loads the four JSON files before the room is built.
Objects reject missing fields, incorrect types and unknown keys. All strings
must be nonempty except a rule's `item_id`, where `""` means no selected item.
Array entry IDs must be unique within each collection. JSON roots are objects;
malformed JSON errors report the file and parser line. Validation errors report
the JSON filename, owning ID and field/reference problem. Invalid content is
never exposed to the room as a partially loaded bundle.

| File/object | Required fields |
| --- | --- |
| Room | `id` string, `background_scene` string, `hotspots` array |
| Hotspot | `id`, `name`, `visual_scene` strings; `position`, `polygon` arrays |
| Items root | `items` array |
| Item | `id`, `name`, `description`, `icon_scene` strings |
| Dialogue root | `initial_node_id` string, `speakers`, `nodes` arrays |
| Speaker | `id`, `name` strings |
| Dialogue node | `id`, `speaker_id`, `text` strings; `choices` array |
| Choice | `text` string, `requires`, `effects` arrays; optional `next_id` string |
| Puzzle root | `initial_flags`, `failure_responses` objects; `rules` array |
| Rule | `id`, `verb`, `target_id`, `item_id`, `failure_text` strings; `requires`, `effects` arrays |

Scene paths must be local `res://` `.tscn` resources, without `..` traversal,
and have a `Node2D` root. `position` is `[x, y]` in logical room coordinates;
`polygon` contains at least three local `[x, y]` vertices, with finite numeric
coordinates and a nondegenerate triangulatable area. Visuals and hitboxes use
the same position, but their geometry is independent. The camera is centered
at `(320, 180)`; authored room content occupies the stage between UI bands.

`initial_flags` maps nonempty flag IDs to booleans. Conditions have exactly one
of these shapes, with known IDs; an empty `requires` array is unconditional:

```json
{"flag": "press_repaired", "value": true}
{"item": "oil", "owned": true}
```

These are alternative object shapes, not one combined JSON document.
The closed effect set accepts only these fields:

| Effect `type` | Other fields |
| --- | --- |
| `set_flag` | `flag_id` string referring to an initial flag; `value` boolean |
| `grant_item`, `consume_item` | `item_id` string referring to an item |
| `show_text` | `text` string |
| `start_dialogue` | `node_id` string referring to a dialogue node |
| `finish` | None |

Rules allow only `look`, `use`, `talk`; targets reference room hotspot IDs.
Choices and initial dialogue references must resolve to nodes; each node must
reference a speaker and offer at least one explicit choice. Choices without
`next_id` end the conversation. `failure_responses` requires exactly `look`,
`use`, `talk`, `capacity`, each containing authored text. Empty effects are
allowed for a choice; no expressions or scripts are evaluated.

The shipped JSON contains the intended puzzle chain and text. Step 01 validates
these definitions; Step 02 executes unconditional, text-only rules with no
selected item. Conditions, item/flag changes and dialogue remain deferred.
`data/theme.tres` is a native Theme: font sizing and Label colors are ordinary
Theme properties, and `title`, `subtitle`, `foundation_note`, `content_error`
metadata hold foundation UI text. Step 02 adds `verb_look`, `verb_use`,
`verb_talk`, and `interaction_hint` for interaction UI text. Godot imports this
resource; it is outside the JSON validator. Visual scene bindings live in room/item JSON.

## Godot APIs and pitfalls

Hotspots use `Area2D` collision polygons. Step 02 centrally hit-tests their
authored polygons in room-definition order and dispatches through
`_unhandled_input`, so GUI controls consume clicks before room dispatch and
overlap priority does not depend on physics picking. Use `Control`,
`Button`, containers, and `CanvasLayer` for verbs/inventory/dialogue.
[Control mouse filtering](https://docs.godotengine.org/en/stable/classes/class_control.html)
requires deliberate configuration: decorative overlays ignore input; interactive
UI consumes clicks. Otherwise clicking a dialogue choice can activate the
hotspot underneath. Disable scene interaction while dialogue is modal.

Validate JSON types and references before mutating state. Apply consume/grant
and flag changes as one successful action, after capacity/precondition checks,
to prevent duplicate rewards and softlocks from repeated clicks.

## CraftPix candidates and gaps

[Free Castle Interior Pixel Game Backgrounds](https://craftpix.net/freebies/free-castle-interior-pixel-game-backgrounds/)
lists four 576×324 PNG/PSD backgrounds. Choose one interior as a fixed backdrop;
no parallax or extra screens are required. Its listing does not establish
separate clickable props, a suitable clerk, or inventory icons. Use labeled
placeholder props and a clerk portrait/silhouette; keep hotspot geometry
independent of the background image. Inspect cropping and text contrast before
selecting final art. Request transparent pixel PNGs for oil, press, pass, clerk,
and gate if later seeking a coherent CraftPix companion set.

## Acceptance route — under five minutes

- [ ] Start, hover hotspots, read their names, and use Look on noticeboard and press.
- [ ] Talk before repairing; receive the oil clue. Attempt the gate; remain in the room.
- [ ] Collect oil; attempt oil on clerk; see feedback and retain it.
- [ ] Use oil on press; oil disappears once and press visibly changes.
- [ ] Talk and request pass; receive one pass. Repeating Talk grants no duplicate.
- [ ] Use pass on gate; see completion, with the route taking two to four minutes.
- [ ] Restart; restore the oil pickup, original press, flags, inventory, and dialogue.
- [ ] No combat, camera movement, hidden pixel hunting, softlock, or console error.

## Project boundary and status

Research handoff dated 2026-10-03. Steps 01–02 implement the fixed room,
validated content schema, hover names and Look/Use/Talk feedback. Inventory and
the puzzle chain remain prospective. See
[acceptance evidence](ACCEPTANCE.md) for completed foundation checks and gaps.
Use Godot 4.7, verified locally as 4.7.2, GDScript, and Compatibility rendering.
Each game owns its `project.godot`, scenes, scripts, data, assets, and
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

Run these implemented foundation commands from this game's folder:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script tests/run_tests.gd
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

The test runner validates content boundaries, static startup and Step 02
interaction through `tests/interaction_test.gd`, including injected viewport
mouse events, click-through prevention and modal locking. Extend it with
behavior checks when implementing later steps.
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

See [the step index](STEPS.md) and [OpenSpec tasks](../../openspec/changes/add-point-and-click/tasks.md).
