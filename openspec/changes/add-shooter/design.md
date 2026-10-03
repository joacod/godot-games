# shooter design decisions

## Context

The researched, canonical game design is
[docs/DESIGN.md](../../../shooter/docs/DESIGN.md). It contains the core loop,
scene tree, data contracts, CraftPix candidates, API sources, scope limits,
reskin boundaries and under-five-minute acceptance route. Keep those details
there to avoid divergent copies. Research is complete; gameplay is pending.

## Goals / Non-Goals

Goal: Native 3D grid maze with hitscan, two enemy types, one key and locked door, health and an exit.

Non-goals: No ADS, reload minigame, squad AI, vehicles, vertical levels or custom raycasting renderer. No cross-game runtime sharing.

## Decisions

Use Godot 3D collision and rays with a 2D grid path model mapped to XZ; primitive visuals keep it self-contained.

Use Godot 4.7.2 for development verification and Compatibility rendering.
Choose focused scripts, local data and replaceable visual packed scenes;
copying a game must require no repository-level runtime files. CraftPix is a
researched art source, with full placeholders when candidate coverage or
redistribution rights are not established.

## Risks / Trade-offs

Door collision/path occupancy and shot occlusion must agree; directional CraftPix FPS art is not established.

Catalog descriptions do not prove sheet fit or actual gameplay appearance.
Record asset inspection and acceptance separately. A headless pass cannot
establish feel, physical input or human completion time.

## Delivery

Follow [tasks.md](tasks.md) and the six linked guides one requested step at a
time. Proposed requirements stay under this change until implementation and
acceptance are complete; no archive or baseline spec promotion during research.
