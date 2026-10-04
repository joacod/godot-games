# point-and-click design decisions

## Context

The researched, canonical game design is
[docs/DESIGN.md](../../../point-and-click/docs/DESIGN.md). It contains the core loop,
scene tree, data contracts, asset provenance links, scope limits and reskin
boundaries. Keep those details there to avoid divergent copies. Implementation
and user-reported human acceptance are complete as of 2026-10-04. See
[acceptance evidence](../../../point-and-click/docs/ACCEPTANCE.md) for timing limitations.

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

All six steps in [tasks.md](tasks.md) are complete. The game docs now contain
run/editing guidance and concise acceptance history; completed step guides were
removed. The requirements remain here as the behavior contract. This cleanup
does not archive the OpenSpec change or promote a baseline spec.
