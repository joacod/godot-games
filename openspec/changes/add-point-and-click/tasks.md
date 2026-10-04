# Tasks

Steps 01–04 are complete; Steps 05–06 are pending. Execute only the requested step
and attach evidence before checking tasks. Research completion is not gameplay completion.

## 1. Standalone room and content schema

[Detailed step guide](../../../point-and-click/docs/steps/01-foundation.md)

- [x] 1.1 Configure Compatibility and 640×360 logical viewport with legible text at 1280×720. Set up mouse clicks, cancel and pause actions.
- [x] 1.2 Create the fixed camera and five labeled placeholder hotspots. No avatar movement or pathfinding is required.
- [x] 1.3 Define the small JSON schemas in DESIGN.md, including all line/choice text and failure responses. Validate IDs, references, value types and allowed effect names before play.
- [x] 1.4 Choose one CraftPix interior candidate; inspect actual files only if importing. Keep independent prop visuals and a complete placeholder room, recording candidates versus used assets.
- [x] 1.5 Create the test runner and local commands; retain every generated script UID.
- [x] 1.6 Pass the step completion gate and record automated and native evidence in `point-and-click/docs/ACCEPTANCE.md`.

Step 01 evidence: [acceptance record](../../../point-and-click/docs/ACCEPTANCE.md).

## 2. Look, Use and Talk dispatch

[Detailed step guide](../../../point-and-click/docs/steps/02-hotspots-and-verbs.md)

- [x] 2.1 Add hover names and generous hotspot shapes for oil, press, clerk, noticeboard and gate.
- [x] 2.2 Provide explicit verb selection and dispatch a verb plus target ID to the content rules.
- [x] 2.3 Render data-authored Look descriptions and unsupported-action feedback; scripts contain no dialogue strings.
- [x] 2.4 Set decorative UI mouse filters to ignore; interactive controls consume clicks. Resolve overlapping hotspots deterministically and disable room clicks for modal UI.
- [x] 2.5 Pass the step completion gate and record automated and native evidence in `point-and-click/docs/ACCEPTANCE.md`.

Step 02 evidence: [acceptance record](../../../point-and-click/docs/ACCEPTANCE.md#step-02--2026-10-03).

## 3. Six-slot inventory and atomic item use

[Detailed step guide](../../../point-and-click/docs/steps/03-inventory-and-actions.md)

- [x] 3.1 Store item IDs with a six-item capacity; disallow discarding required items and duplicate unique items.
- [x] 3.2 Picking up oil validates capacity before hiding its hotspot or setting oil_taken.
- [x] 3.3 Select an item to show Use [item] with [target], and support right-click cancellation.
- [x] 3.4 Validate conditions and capacity before applying all effects as one transaction. Repairing the press consumes oil and sets the repaired flag once.
- [x] 3.5 Wrong targets and repeated actions leave state unchanged with authored responses.
- [x] 3.6 Pass the step completion gate and record automated and native evidence in `point-and-click/docs/ACCEPTANCE.md`.

Step 03 evidence: [acceptance record](../../../point-and-click/docs/ACCEPTANCE.md#step-03--2026-10-03).

## 4. Data dialogue and complete puzzle chain

[Detailed step guide](../../../point-and-click/docs/steps/04-dialogue-and-puzzle.md)

- [x] 4.1 Load the clerk dialogue graph, filter choices by state and display speaker/line/choice text from JSON.
- [x] 4.2 Before repair, the clerk hints at oil; after repair, requesting a pass grants it once. Repeated Talk chooses relevant nonduplicating dialogue.
- [x] 4.3 Use pass on gate to emit completion once. Block invalid exit attempts with data-authored feedback.
- [x] 4.4 Lock scene interaction while dialogue is open; require an explicit choice/cancel instead of allowing room clicks through.
- [x] 4.5 Exercise the full chain and plausible wrong action orders with state assertions.
- [x] 4.6 Pass the step completion gate and record automated and native evidence in `point-and-click/docs/ACCEPTANCE.md`.

Step 04 evidence: [acceptance record](../../../point-and-click/docs/ACCEPTANCE.md#step-04--2026-10-04).

## 5. Completion, restart and readable room

[Detailed step guide](../../../point-and-click/docs/steps/05-lifecycle-and-presentation.md)

- [ ] 5.1 Add start, pause/restart and completion presentation, preserving the fixed camera.
- [ ] 5.2 Restart reconstructs room, inventory, puzzle flags and dialogue cursor; no stale selected item or modal remains.
- [ ] 5.3 Use visual state changes for taken oil, repaired press and open gate; labels supplement shapes and color.
- [ ] 5.4 Check full sentences and choices at the target resolution; fit inventory slots and avoid clipping long data text.
- [ ] 5.5 Do not add a loss condition to a puzzle designed to be recoverable. Completion and restart satisfy this game’s terminal flow.
- [ ] 5.6 Pass the step completion gate and record automated and native evidence in `point-and-click/docs/ACCEPTANCE.md`.

## 6. Acceptance and independent adventure reskin

[Detailed step guide](../../../point-and-click/docs/steps/06-acceptance-and-reskin.md)

- [ ] 6.1 Run import and behavioral checks, including inventory capacity and invalid dialogue-reference fixtures.
- [ ] 6.2 Perform the full timed checklist with native mouse input and record completion time, text readability, invalid-action feedback and restart.
- [ ] 6.3 Copy the project outside the repository without .godot. Change room art, clerk name, oil/pass display names and dialogue text; preserve IDs for this cosmetic reskin.
- [ ] 6.4 Verify mechanics hashes do not change and the copied puzzle still finishes without any sibling folders.
- [ ] 6.5 Record asset coverage and license evidence separately from gameplay acceptance. Update exact editing paths and complete only evidenced OpenSpec tasks.
- [ ] 6.6 Pass the step completion gate and record automated and native evidence in `point-and-click/docs/ACCEPTANCE.md`.
