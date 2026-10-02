# Step 05 — One level and encounter progression

Status: not started. Prerequisite: Step 04 accepted.

## Outcome

The hero can cross the planned street, clear two encounters and reach the sealed
boss entrance. The boss itself is the next step.

## Work

1. Author the [level route](../DESIGN.md#enemies-and-encounters) in one scene using
   explicit spawn markers and encounter triggers. Retain simple walkable geometry.
2. Implement safe-entry gate closure, camera locks, scheduled waves and live-enemy
   tracking. Open gates only after both queued and living enemies are exhausted.
3. Add forward prompts and readable boundaries. Prevent triggers from repeating
   and ensure enemies spawn within a reachable visible fighting area, away from the hero.
4. Introduce the level's run owner, minimal title, HUD and pause/death/retry flow.
   Retry reloads the entire run. Replace test-only reset controls with menu actions.
5. Add wave and reset regressions; keep the boss entrance visibly unfinished
   rather than claiming a complete game.

## Acceptance

- Both fights lock and unlock once; pending second waves prevent early opening.
- Jumping or backtracking cannot skip/retrigger a fight or escape a locked arena.
- No live enemy can be stranded outside the accessible area.
- Retry from either encounter resets all state; Main Menu → Play starts cleanly.
- Death and pause prevent new wave spawns until an appropriate fresh run/resume.

Exclude boss logic, props, checkpoints and final menu styling.
See [validation](../ACCEPTANCE.md).

## Completion record

Pending: files changed; route walkthrough; wave/reset commands/results; intentionally
untouched files; follow-ups.
