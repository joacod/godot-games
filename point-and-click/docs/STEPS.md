# point-and-click implementation steps

Status: research complete; all implementation steps are pending. Implement one
requested step at a time, in order. Each step depends on the preceding one;
Step 01 depends on [DESIGN.md](DESIGN.md) and the researched content decisions.
Do not mark an implementation checkbox complete for writing this handoff.

[OpenSpec requirements](../../openspec/changes/add-point-and-click/specs/point-and-click-slice/spec.md)
are the behavior contract. [OpenSpec tasks](../../openspec/changes/add-point-and-click/tasks.md)
are the single progress checklist; the guides below contain execution detail.
Repository-level links are planning conveniences and are not needed by a copied
game at runtime. Its DESIGN.md and step guides remain inside the game folder.

| Step | Deliverable |
| --- | --- |
| 01 | [Standalone room and content schema](steps/01-foundation.md) |
| 02 | [Look, Use and Talk dispatch](steps/02-hotspots-and-verbs.md) |
| 03 | [Six-slot inventory and atomic item use](steps/03-inventory-and-actions.md) |
| 04 | [Data dialogue and complete puzzle chain](steps/04-dialogue-and-puzzle.md) |
| 05 | [Completion, restart and readable room](steps/05-lifecycle-and-presentation.md) |
| 06 | [Acceptance and independent adventure reskin](steps/06-acceptance-and-reskin.md) |
