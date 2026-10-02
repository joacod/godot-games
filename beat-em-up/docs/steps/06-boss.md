# Step 06 — Boss and complete game loop

Status: not started. Prerequisite: Step 05 accepted.

## Outcome

The whole level can be won or lost, retried, and played again without stale state.

## Work

1. Add one boss with the designed sweep and straight charge: distinct tells,
   committed attack paths, arena-safe motion, and punishable recovery.
2. Implement boss health/HUD and non-interruptible committed attacks. Keep normal
   damage rules except for the explicit knockdown/interrupt exceptions.
3. Wire final arena entry, boss defeat and victory. Cancel active attacks on
   death; show results only once. Player death wins simultaneous-death arbitration.
4. Finish functional title, Controls, pause, Game Over and victory flows with
   keyboard/controller focus. Prevent confirm input from leaking into gameplay.
5. Add result/reset regressions and test transitions during each boss phase.

## Acceptance

- Both boss attacks can be intentionally avoided and punished; neither crosses
  arena bounds. Damage remains aligned with the visible tell and strike.
- Clear from title to victory; deliberately lose to the boss and retry from the
  level start. Play Again resets everything.
- Pause, Main Menu and Retry during windup, attack and recovery leave no attack,
  timer, camera lock, pause state, or duplicate result behind.

Exclude extra bosses, phases, adds, rewards and save data.
See [design](../DESIGN.md) and [validation](../ACCEPTANCE.md).

## Completion record

Pending: files changed; complete-loop observations; regression commands/results;
intentionally untouched files; follow-ups.
