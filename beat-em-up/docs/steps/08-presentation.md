# Step 08 — Art, sound and presentation

Status: not started. Prerequisite: Step 07 accepted.

## Outcome

The finished route looks and sounds like one coherent game, with readable combat
and usable menus rather than debug presentation.

## Work

1. Finish selected CraftPix art integration, palette/scale consistency, ground
   anchors, animation timing and scenery. Update asset provenance and mapping.
2. Finalize HUD, health bars, button hints, Controls, focus, prompts and result
   screens. Show information without covering the walkable fight area.
3. Source and record the planned sounds/music; verify rights before import.
   Add Master/Music/SFX volume controls and document pause/music behavior.
4. Add restrained impact effects and optional brief hit pause/shake only if they
   improve readability. Ensure pause/reset clears any global time/camera effects.
5. Remove test-only overlays from normal play while retaining useful test scenes.
   Keep diagnostics available without exposing them in the normal game flow.

## Acceptance

- Visually inspect all combat states, depth overlaps, UI and two window sizes.
- Listen to music/effects during a full fight and menus; no duplicate loops,
  clipping, missing cues or unresponsive volume controls.
- All menus work without mouse input and use clear focus; resume leaks no input.
- No final gameplay animation is silently represented by a debug placeholder.

Exclude new mechanics, cinematic production, custom shaders and publishing.
See [assets](../../ASSETS.md) and [validation](../ACCEPTANCE.md).

## Completion record

Pending: files changed; import/startup commands/results; visual and listening
observations; intentionally untouched files; follow-ups.
