# Survivors asset provenance

All included presentation is original geometric placeholder art created for
this game on 2026-10-05. No external texture, sprite sheet, font, audio, archive
or account download is included. UI uses Godot's built-in font.

## Included presentation

| Local file | Presentation |
| --- | --- |
| `scenes/visuals/keeper.tscn` | Static polygon Keeper with a facing cue; tinted by theme |
| `scenes/visuals/crawler.tscn` | Static crawler silhouette; also used at 1.7× visual scale for the labeled elite |
| `scenes/visuals/floor.tscn` | 960×640 floor/clearing polygons; tinted by theme |
| `scenes/visuals/attack.tscn` | Foundation diamond definition; no attack behavior |
| `scenes/visuals/spark.tscn` | Yellow diamond; also reused by Arc Spark |
| `scenes/visuals/halo.tscn` | Violet square |
| `scenes/visuals/pulse.tscn` | Thin green ring |
| `scenes/visuals/shard.tscn` | Cyan directional dart |
| `scenes/visuals/xp_gem.tscn` | Cyan diamond with a dark border |
| `scenes/arena.tscn` | Visible arena edges, outside replaceable floor art |
| `data/ui_theme.tres`, `scenes/ui/` | Local button styles and Godot Control layouts |
| `scripts/hud.gd` | Geometric weapon symbols |
| `scripts/spawn_director.gd` | Entry-warning crosses/rings |

These visuals have no sprite-frame dimensions or animation mappings. Actor,
attack and pickup collision shapes remain outside replaceable art. Elite
collision size is defined separately from its visual scale.

The verified Copper Marsh copy reuses the existing crawler visual for a cyan
Lantern character; its changes are copied Resources only. Captured PNG/MP4 files
are evidence of the running game, not runtime assets. See
[validation](../docs/ACCEPTANCE.md).

## Importing future art

Look for suitable free or already-owned CraftPix assets before making
replacements. Inspect actual archives and record the source URL, archive name,
used files, dimensions, animation mapping, modifications and applicable license
evidence before import. Keep all used files local to this game and preserve the
collision/visual boundary.

Listing descriptions alone do not establish sheet fit, account entitlement or
permission to redistribute retrievable art in a source project. Preserve the
runnable original presentation while evaluating a pack. The earlier candidate
research is retained in [asset history](../docs/history/PROVENANCE.md); it was
not imported or verified at archive level and is not a runtime requirement.
