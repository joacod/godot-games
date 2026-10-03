# Step 04 — Data dialogue and complete puzzle chain

## Entry condition

Complete Step 03 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Implement the clerk conversation, pass grant and exit rule entirely from content data.

## Planned files

These paths are relative to `point-and-click/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scripts/dialogue.gd`
- `scenes/ui/dialogue_panel.tscn`
- `scripts/dialogue_ui.gd`
- `data/dialogue.json`
- `data/puzzle.json`
- `tests/puzzle_chain_test.gd`

## Work

1. Load the clerk dialogue graph, filter choices by state and display speaker/line/choice text from JSON.
2. Before repair, the clerk hints at oil; after repair, requesting a pass grants it once. Repeated Talk chooses relevant nonduplicating dialogue.
3. Use pass on gate to emit completion once. Block invalid exit attempts with data-authored feedback.
4. Lock scene interaction while dialogue is open; require an explicit choice/cancel instead of allowing room clicks through.
5. Exercise the full chain and plausible wrong action orders with state assertions.

## Completion gate

- [ ] Oil pickup → oil on press → Talk/request pass → pass on gate completes.
- [ ] Early gate attempts, Talk before repair and duplicate requests cannot deadlock or duplicate items.
- [ ] All player-visible dialogue and choice text can be changed in JSON without script edits.

Run the import and test commands in [DESIGN.md](../DESIGN.md), extending
`tests/run_tests.gd` to include this step's behavioral checks. Run the native
launch command for its visual/input checks. Record results and unresolved gaps
in `docs/ACCEPTANCE.md`, including generated `.gd.uid` coverage.

## Boundaries and handoff

Modify only this game and its OpenSpec progress/evidence. Existing games,
sibling new games, engine version and renderer remain untouched. Do not add
later-step mechanics while completing this step. Do not commit, branch, push,
or publish unless separately requested. Report exact files changed, behavior,
commands/results, manual checks, intentionally untouched files and next step.
