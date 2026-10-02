# Step 01 — Foundation and asset fit

Status: not started. Prerequisite: approval to implement this step.

## Outcome

An independent Godot project boots into a representative street sample with a
hero, an enemy, and scenery at a coherent scale. No gameplay is required yet.

## Work

1. Review [design](../DESIGN.md) and [asset candidates](../../ASSETS.md). Confirm
   Godot 4.7.2 before project operations; use GDScript and Compatibility rendering.
2. Inspect candidate archives through available account access. Check animation
   coverage before committing to the cast; present gaps and proposed adaptations.
3. Create `project.godot` and a minimal entry/sample scene. Use a proposed
   640 × 360 logical viewport, 1280 × 720 window, nearest texture filtering, and
   preserved aspect ratio. Verify these choices against the chosen artwork.
4. Configure the planned Input Map. Import only the sample's used assets and
   license records; record exact dimensions, animations, anchors and provenance.
5. Display sample idle/movement/attack animations, depth anchors and a usable
   street floor. Update README with real opening and validation instructions.

## Acceptance

- Editor import and headless startup succeed without script/resource errors.
- A visual review confirms compatible scale, perspective, feet anchors and clear
  silhouettes. Required animation gaps have an explicit resolution before Step 02.
- No dependence on the platformer, downloaded engine plugins, or new framework.

Exclude movement logic, combat, AI and menus. See [shared checks](../ACCEPTANCE.md).

## Completion record

Pending: files changed; engine/version; commands/results; visual observations;
asset decisions; unresolved gaps; intentionally untouched files.
