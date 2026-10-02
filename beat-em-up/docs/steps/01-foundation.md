# Step 01 — Foundation and asset fit

Status: foundation implemented; final asset-fit acceptance pending. Implementation
was authorized with “go” on 2026-10-02. Proposed animation adaptations still need
review; Step 02 has not started.

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

Date: 2026-10-02. Evidence applies to this uncommitted working tree.

### Files and behavior

- Added `project.godot`, `main.tscn`, and `.gitignore` for an independent
  Compatibility project with the planned viewport, filtering, aspect, Input Map,
  and a 0.25 movement-stick deadzone.
- Added `scenes/sample/hero.tscn`, `enemy.tscn`, their `SpriteFrames` resources,
  and `street_sample.gd` plus its Godot-generated `.gd.uid`. The timer cycles
  preview poses every 2.4 seconds; neither actor moves or deals damage.
- Added nine used PNGs, their Godot import descriptors, three supplied license
  pointer files, and [asset provenance](../../assets/PROVENANCE.md).
- Updated README, ASSETS, PLAN, and the shared acceptance introduction to
  describe the actual project and distinguish foundation evidence from gameplay.

### Engine and automated results

Verified engine: `4.7.2.stable.official.ed1daf0bf`. Commands run from the repository
root, using `/Applications/Godot.app/Contents/MacOS/Godot`:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --version
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --path beat-em-up --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --quit-after 120
/Applications/Godot.app/Contents/MacOS/Godot --headless --path beat-em-up --fixed-fps 60 --quit-after 780
git diff --check
```

All passed. Import and runtime logs were checked for script/resource errors.
The 780-frame check covers all five preview phases and the return to idle.
The initial sandboxed import reported application-data/editor-settings write
errors; the approved rerun with normal Godot data-directory access succeeded.
The project configuration was not changed to work around the sandbox.

A temporary, session-only GDScript check also passed: all 13 configured actions
exist with keyboard/controller events, movement deadzone is 0.25, aspect is
`keep`, renderer is `gl_compatibility`, and every atlas rectangle fits its source
sheet. This is not a maintained gameplay test suite. Local Markdown file targets
and the new script's UID were checked successfully.

### Visual observations

Launched with `Godot --path beat-em-up` at the configured 1280 × 720 size and
inspected the live window through computer use. The runtime reported OpenGL
Compatibility on Apple M2. The final backdrop, two distinct silhouettes, foot
crosses, shadows, and preview captions were visible; attack poses were observed.
No clipped actors or oversized foreground props remain in the sample. Actors
retain fixed ground anchors while their visual poses change.

The original flattened background had a hydrant/crates too large relative to the
actors. The final composite omits those props and the front wall, retaining the
rear industrial wall and road. This visual sample establishes a useful starting
scale, not final-level composition or moving depth-sort acceptance.

Resized-window, physical keyboard/controller, jump/sorting, gameplay playtest,
and audio listening checks: **not run**. Gameplay and audio do not exist yet.

### Remaining asset decisions

Imported Biker and seaport enemy 1 after examining their actual animation sheets.
The unarmed hero samples are punch, double punch, and kick; the energy-weapon
sheet is excluded. Dedicated air attack/get-up and a second suitable standing
melee silhouette are missing from the inspected sample packs. The factory boss
and extra-animation archives have not been inspected; their product pages alone
are insufficient to accept their coverage.

The [asset brief](../../ASSETS.md#step-01-decisions-and-gaps) records the proposed
frame adaptations and the remaining cast review. These require resolution before
Step 02, so this step is not marked fully accepted. No gameplay requirement was
removed to conceal an animation gap.

### Intentionally untouched

`2d-platform`, repository/skill instructions, `docs/DESIGN.md`, and Steps 02–09
remain unchanged. No movement, combat, AI, menus, framework, dependency, or
engine plugin was added. No branch, commit, push, PR, purchase, or publication.
