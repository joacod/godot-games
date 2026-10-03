# survivors design decisions

## Context

The researched, canonical game design is
[docs/DESIGN.md](../../../survivors/docs/DESIGN.md). It contains the core loop,
scene tree, data contracts, CraftPix candidates, API sources, scope limits,
reskin boundaries and under-five-minute acceptance route. Keep those details
there to avoid divergent copies. Research is complete; gameplay is pending.

## Goals / Non-Goals

Goal: Movement-only bullet heaven with four weapons, XP, three upgrade choices, one evolution and a three-minute survival run.

Non-goals: No meta progression, extra biomes, boss marathon or manual aiming/firing. No cross-game runtime sharing.

## Decisions

Use 2D physics and separate weapon behaviors; prioritize readable effects and deterministic evolution access.

Use Godot 4.7.2 for development verification and Compatibility rendering.
Choose focused scripts, local data and replaceable visual packed scenes;
copying a game must require no repository-level runtime files. CraftPix is a
researched art source, with full placeholders when candidate coverage or
redistribution rights are not established.

## Risks / Trade-offs

Crowd and choice pacing need native playtesting; cap enemies and keep fallback upgrades effective.

Catalog descriptions do not prove sheet fit or actual gameplay appearance.
Record asset inspection and acceptance separately. A headless pass cannot
establish feel, physical input or human completion time.

## Delivery

Follow [tasks.md](tasks.md) and the six linked guides one requested step at a
time. Proposed requirements stay under this change until implementation and
acceptance are complete; no archive or baseline spec promotion during research.
