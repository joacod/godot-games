# Step 07 — Breakable prop and health recovery

Status: not started. Prerequisite: Step 06 accepted.

## Outcome

A breakable on the route drops food that restores health, adding a deliberate
recovery opportunity without changing the game loop.

## Work

1. Add one breakable type using the existing damage path, ground depth checks,
   a broken state and one deterministic food drop.
2. Keep props nonblocking to movement so this step does not introduce navigation
   requirements. Place the recovery prop on the connecting stretch.
3. Add grounded proximity pickup, health clamping and one collection event.
   At full health, leave food unconsumed. Dead or airborne players cannot collect.
4. Reset props and food with the run. Tune damage, enemy counts and food recovery
   through playtesting; record final values and completion time.

## Acceptance

- A prop breaks and drops once even if several hit events coincide.
- Food heals once, cannot exceed max health, and requires ground/depth proximity.
- Retry restores the original prop and removes drops from the previous run.
- The complete level remains fair with the intended recovery opportunity.

Exclude inventory, randomized loot, score, weapons and new prop families.
See [assets](../../ASSETS.md) and [validation](../ACCEPTANCE.md).

## Completion record

Pending: files changed; regression commands/results; recovery/balance observations;
intentionally untouched files; follow-ups.
