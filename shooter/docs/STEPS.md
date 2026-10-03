# shooter implementation steps

Status: research complete; all implementation steps are pending. Implement one
requested step at a time, in order. Each step depends on the preceding one;
Step 01 depends on [DESIGN.md](DESIGN.md) and the researched content decisions.
Do not mark an implementation checkbox complete for writing this handoff.

[OpenSpec requirements](../../openspec/changes/add-shooter/specs/shooter-slice/spec.md)
are the behavior contract. [OpenSpec tasks](../../openspec/changes/add-shooter/tasks.md)
are the single progress checklist; the guides below contain execution detail.
Repository-level links are planning conveniences and are not needed by a copied
game at runtime. Its DESIGN.md and step guides remain inside the game folder.

| Step | Deliverable |
| --- | --- |
| 01 | [Standalone 3D maze and map validation](steps/01-foundation.md) |
| 02 | [WASD, mouse look and pause capture](steps/02-fps-movement.md) |
| 03 | [Hitscan combat, damage and death](steps/03-hitscan-and-health.md) |
| 04 | [Guard pursuit and sentry shots](steps/04-two-enemy-types.md) |
| 05 | [Key, health, locked door and complete route](steps/05-key-door-and-exit.md) |
| 06 | [Acceptance and standalone bunker reskin](steps/06-acceptance-and-reskin.md) |
