# point-and-click design decisions

## Context

The researched, canonical game design is
[docs/DESIGN.md](../../../point-and-click/docs/DESIGN.md). It contains the core loop,
scene tree, data contracts, CraftPix candidates, API sources, scope limits,
reskin boundaries and under-five-minute acceptance route. Keep those details
there to avoid divergent copies. Research is complete; gameplay is pending.

## Goals / Non-Goals

Goal: Fixed-room adventure with three verbs, bounded inventory, external dialogue and one recoverable puzzle chain.

Non-goals: No combat, camera scrolling, avatar pathfinding, save system or branching endings. No cross-game runtime sharing.

## Decisions

Use a fixed illustrated stage and small JSON rule/dialogue data; apply inventory and flag effects atomically.

Use Godot 4.7.2 for development verification and Compatibility rendering.
Choose focused scripts, local data and replaceable visual packed scenes;
copying a game must require no repository-level runtime files. CraftPix is a
researched art source, with full placeholders when candidate coverage or
redistribution rights are not established.

## Risks / Trade-offs

Layered UI can swallow or leak input, and action ordering can softlock a puzzle; test both explicitly.

Catalog descriptions do not prove sheet fit or actual gameplay appearance.
Record asset inspection and acceptance separately. A headless pass cannot
establish feel, physical input or human completion time.

## Delivery

Follow [tasks.md](tasks.md) and the six linked guides one requested step at a
time. Proposed requirements stay under this change until implementation and
acceptance are complete; no archive or baseline spec promotion during research.
