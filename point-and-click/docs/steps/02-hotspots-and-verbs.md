# Step 02 — Look, Use and Talk dispatch

Status: complete. See [acceptance evidence](../ACCEPTANCE.md#step-02--2026-10-03).

## Entry condition

Complete Step 01 and retain its passing checks. Read [the design](../DESIGN.md).

## Scope

Implement mouse interaction and visible feedback without advancing the puzzle chain yet.

## Planned files

These paths are relative to `point-and-click/` and are implementation targets, not files
claimed to exist yet. Follow the established paths from earlier steps if refined.

- `scenes/hotspot.tscn`
- `scripts/hotspot.gd`
- `scripts/interaction.gd`
- `scenes/ui/verbs.tscn`
- `scripts/interaction_ui.gd`
- `tests/interaction_test.gd`

## Work

1. Add hover names and generous hotspot shapes for oil, press, clerk, noticeboard and gate.
2. Provide explicit verb selection and dispatch a verb plus target ID to the content rules.
3. Render data-authored Look descriptions and unsupported-action feedback; scripts contain no dialogue strings.
4. Set decorative UI mouse filters to ignore; interactive controls consume clicks. Resolve overlapping hotspots deterministically and disable room clicks for modal UI.

## Completion gate

- [x] Every hotspot supports Look; unsupported Talk/Use returns feedback without state change.
- [x] Clicking a verb or overlay never also activates scenery underneath.
- [x] All five hotspots can be found without pixel hunting or camera movement.

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
