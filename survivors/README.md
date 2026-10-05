# Last Light Clearing

A standalone top-down survival game: move the Keeper through a clearing while
four automatic weapons repel enemies. Collect XP, choose upgrades, evolve
Spark into Arc Spark, and survive three minutes. One elite arrives at two
minutes; defeat and Retry start a fresh attempt.

The six implementation steps are complete. Manual acceptance was confirmed by
the user on 2026-10-05; see [validation and acceptance](docs/ACCEPTANCE.md).

## Play

Use **Godot 4.7**, developed and checked with **4.7.2**, and the configured
Compatibility renderer. Import this folder's `project.godot` in the Godot
Project Manager, open it, and press **F5**. No asset pack, plugin, account or
sibling game is required.

| Action | Controls |
| --- | --- |
| Move | WASD or arrow keys |
| Choose an upgrade or menu item | Mouse, or arrows then Enter/Space |
| Pause / resume | Escape or P |
| Start, Retry, Back to menu | On-screen buttons |

Movement alone fires equipped weapons; there is no aim or fire button. Upgrade
choices pause the action until confirmation is released. Select an upgrade
before opening manual pause. Victory requires surviving 180 active seconds;
paused time does not count. Retry resets health, XP, upgrades, enemies and time.
The logical viewport is 640×360, displayed in a 1280×720 window.

## Maintain and reuse

- [Design and editing](docs/DESIGN.md): current rules, script responsibilities,
  content paths, collision boundaries and the copy/reskin procedure.
- [Validation and acceptance](docs/ACCEPTANCE.md): regression commands, native
  fixtures, capture instructions and the latest evidence.
- [Asset provenance](assets/PROVENANCE.md): included presentation and requirements
  for future art imports.
- [Implementation history](docs/history/README.md): original plans, step guides,
  detailed verification records and unused asset research.

Copy the entire game folder, including script `.gd.uid` files, to reuse it.
Omit `.godot/`, exports and logs; import and test the copy before changing it.
All runtime resources are local to this project.
