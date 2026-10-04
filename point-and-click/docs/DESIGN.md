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

Theme: **The Closed Gate**, a lightly comic administrative obstacle.
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
Main (Node; start/playing/pause/complete transitions)
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
    ├── Description (scrollable RichTextLabel)
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

## Content schema

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

The shipped JSON contains the puzzle chain and text. All six effects execute
only after conditions and final inventory validity pass. Dialogue and completion signals are emitted after the transaction
commits; completion emits once per run. Runtime flags and item
IDs are separate from immutable content definitions.
`data/theme.tres` supplies font sizing, Label colors and UI text metadata.
Keys include `title`, `subtitle`, `foundation_note`, `content_error`,
`verb_look`, `verb_use`, `verb_talk`, `interaction_hint`, `item_prompt`,
`item_target`, `press_repaired`, `dialogue_cancel`, `gate_open` and `menu_`
labels/instructions. `item_prompt` has two `%s` placeholders for item and target.
Godot imports this native Theme; it is outside the JSON validator.
Visual scene bindings live in room/item JSON.

## Godot APIs and pitfalls

Hotspots use `Area2D` collision polygons. Interaction centrally hit-tests their
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

## Presentation and acceptance

All visuals are project-authored placeholder polygons. See
[asset provenance](../assets/PROVENANCE.md) for coverage, the researched CraftPix
candidate and the evidence needed before importing replacement art.
The game was accepted after the user's human playtest on 2026-10-04;
[acceptance evidence](ACCEPTANCE.md) separates user-reported results from
headless, native-input and standalone-copy checks.

## Copy and reskin contract

Copy this entire game folder to a new location, including `project.godot`,
`scenes/`, `scripts/`, script `.gd.uid` files, `data/`, `assets/`, `docs/`, and
`tests/`. Omit generated `.godot/`, export builds, and local
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

## Verification

Run the import, behavioral and optional native-capture commands in the
[README](../README.md#validate). The runner covers content validation, input,
inventory, puzzle/dialogue transactions, lifecycle, restart and long text.
Headless checks establish behavior; inspect native output and play the game
separately to establish rendering, input and clue readability. Repeat the
puzzle and restart in a standalone copy after changing presentation.

## Inventory and atomic actions

`Inventory` owns known, unique item IDs with a capacity of six. There is no player
command to discard an item. `PuzzleState` stages flag and item changes on copies,
rejects unmet conditions, duplicate rewards, missing consumables and invalid final
inventory, then commits both stores before publishing change signals. Failed
actions leave flags, selection, inventory and pickup availability unchanged.
`Interaction` selects items, matches verb/item/target rules and clears selection
on right-click, explicit verb selection or consumption. Dialogue and completion effects use the same transaction; failed
actions cannot open a conversation or emit completion.

`scenes/ui/inventory_bar.tscn` and `scripts/inventory_ui.gd` render six text buttons
from item names, with description tooltips and selected-slot highlighting. The
selected-item prompt uses the hovered target name. Empty slots still occupy the
bar and consume GUI input. The press ram moves upward and its label says repaired;
oil's visual, label and hit region hide together after a successful pickup. Oil,
press and clerk positions in `data/room.json` leave space for the extra UI row;
hotspot polygon sizes and the fixed camera are unchanged. No art is imported.

## Dialogue and completion

`scripts/dialogue.gd` indexes the validated dialogue nodes and speaker names.
A room rule's `start_dialogue` effect selects the node appropriate to the puzzle
state. Only choices whose `requires` conditions pass are displayed; the same
conditions are checked again when a choice is committed. A successful choice
follows `next_id`, opens an effect's dialogue target, or closes the conversation.
A failed reward leaves the current node available, with authored feedback inside
the panel, so a capacity failure can be retried without committing reward flags.

`scenes/ui/dialogue_panel.tscn` and `scripts/dialogue_ui.gd` show JSON speaker,
line and choice text in a scrollable modal panel. The whole overlay consumes
mouse input; `Interaction.modal_open` also blocks direct room dispatch, verb
changes and item selection. Explicit choices, the leave button, right-click or
Escape end a conversation. `dialogue_cancel` in `data/theme.tres` supplies the
leave button label. No scripts contain player-visible conversation text.

The clerk gives an oil clue before repair, offers a pass afterward, and returns
the issued-pass reminder on repeat Talk. The reward atomically grants one pass
and sets `pass_granted`. Using that pass on the gate sets `complete` and emits
`PuzzleState.finished` once after committed state is visible to observers.
The gate's success and repeat responses come from `data/puzzle.json`.
Completion opens the gate and offers restart.

## Lifecycle and readable presentation

`scripts/main.gd` owns start, playing, pause and complete states. The menu scene
and `scripts/menu_ui.gd` render labels from `data/theme.tres` and emit user intent.
Start, pause and completion lock room dispatch. A visible Pause button remains
available above dialogue; pause hides the conversation without clearing its
cursor, disables its cancel input, and resume restores its panel and modal lock.
Escape cancels an item or conversation first, pauses idle gameplay, and resumes
from pause. Right-click retains its item/dialogue cancellation behavior.

Restart instantiates the same main scene, detaches the old run, updates the
SceneTree current scene when applicable, and immediately starts the new run.
Content is loaded afresh and runtime nodes, signal connections, feedback,
selection and dialogue cursor are rebuilt. Immutable content resources are not
used as mutable run state. Repeated restart requests on the old run are ignored.

Completion clears item selection, hides the gate bars and crossbar, changes its
label to open, locks room interaction and shows a restart screen. Existing oil
and press visual changes remain intact. The gate panel is placed beside the
completion screen so the open shape remains visible. The fixed camera, recoverable
puzzle and lack of a loss condition are unchanged.

Feedback uses a bounded scrollable RichTextLabel. Inventory names and the item
prompt stay within their allotted widths with ellipses and full hover tooltips.
Dialogue already wraps its lines and choices in a ScrollContainer; long text
fixtures verify that choices remain reachable and actionable after scrolling.
Menu titles, instructions and button labels are editable theme metadata with
`menu_` keys; `gate_open` supplies the completion label. No artwork is imported.

`tests/restart_test.gd` covers startup blocking, Escape precedence, pause/resume
with dialogue, restart from initial/oil-selected/repaired/dialogue-open/completed
states, completing every rebuilt run, repeat terminal actions and long text.

## Reskin verification and editing paths

`tests/create_reskin_copy.py` creates a standalone temporary cosmetic variant,
compares all runtime script/UID hashes and scene hashes except the changed
backdrop, and checks unchanged content IDs, geometry, conditions and effects.
The same 352 behavioral checks run on shipped and reskinned data; native capture
runs add fifteen checks. Display-name assertions use the loaded definitions.
The modal-backdrop fixture clicks below choices so a wrapped clue does not turn
its intended blocked room click into a valid dialogue choice.

| Edit | Exact path and contract |
| --- | --- |
| Backdrop | `scenes/visuals/background.tscn`; `Node2D` root, fixed framing |
| Hotspot labels | `data/room.json`, `hotspots[].name`; preserve IDs, positions and polygons |
| Item labels/tooltips | `data/items.json`, `items[].name` and `.description`; preserve IDs |
| Speaker and dialogue | `data/dialogue.json`, `speakers[].name`, `nodes[].text`, `choices[].text`; preserve graph, references, conditions and effects |
| Action feedback | `data/puzzle.json`, text/failure responses; preserve rules and flags |
| UI text and colors | `data/theme.tres`, Theme properties and metadata |
| Project/window name | `project.godot`, `application/config/name` |

Prop art remains independent of hitboxes. Preserve the press `Shape4` ram and
gate `Shape1`–`Shape5` attachment nodes used for repaired/open visual states,
or change their bindings as an explicit mechanics change. The verified copy
changes only the backdrop palette and external display data;
[acceptance evidence](ACCEPTANCE.md#standalone-reskin) records the copy checks.
