# Step 09 — Final acceptance and sprite replacement proof

Status: not started. Prerequisite: Step 08 accepted.

## Outcome

A validated one-level game, with accurate play/edit instructions and a demonstrated
way to replace a character's art without rewriting gameplay.

## Work

1. Run the full [acceptance checklist](../ACCEPTANCE.md), engine/import/startup
   checks and implemented regressions. Record the tested revision/working tree.
2. Play from title to victory using keyboard; test a fight and every menu on a
   real controller. Die/retry in each encounter; repeat victory → Play Again.
3. In a duplicate validation scene, swap one actor to another suitable, sourced
   sprite. Change only visual resources, anchors, animation mapping and justified
   timing/shape values. Recheck movement, depth, hits, hurt and death.
4. Keep the primary level's chosen cast. Retain a small swap sample only if useful;
   do not add a runtime selector. Document exactly what the replacement required.
5. Finish README controls, run commands, scene/editing map and limitations;
   finish asset/license records. Resolve in-scope defects found by acceptance.

## Acceptance

- Every required check has honest evidence; pending hardware/manual checks stay
  pending and prevent a claim of full acceptance.
- The alternate art does not require enemy, encounter or damage-rule rewrites.
- A new developer can open, play, tune and replace art using the documentation.
- All in-scope scripts have generated UIDs; no unrelated platformer changes.

Exclude new features, framework extraction, exporting for unrequested platforms,
commits, pushes or publication without separate authorization.

## Completion record

Pending: files changed; engine and revision; commands/results; full playthrough,
controller/device and audio observations; swap evidence; limitations; intentionally
untouched files; follow-ups.
