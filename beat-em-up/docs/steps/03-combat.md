# Step 03 — Player combat and damage

Status: not started. Prerequisite: Step 02 accepted.

## Outcome

The hero can perform a three-hit combo and an air attack against a damageable
dummy, and react correctly to a controlled incoming strike.

## Work

1. Implement [combat rules](../DESIGN.md#combat-rules): windup/active/recovery,
   input buffering, committed facing, depth/height eligibility and per-strike hits.
2. Add health, hurt, interruption, bounded knockback, knockdown, get-up protection,
   invulnerability and death. Use one small damage interface, not an ability system.
3. Implement the jump attack and safe hurt/landing cancellation. Connect sprite
   timing to authored strike windows; record actual values and animation mapping.
4. Add a dummy and controlled incoming attack in a test scene, health readout and
   minimal hit feedback. Include meaningful deterministic combat regressions.

## Acceptance

- A strike hits multiple eligible targets once each and misses behind, outside
  depth tolerance, outside its active window, and at incompatible jump heights.
- Fast presses advance at most three strikes; holding does not auto-loop; expired
  input resets the combo. Hurt, death and reset clear queued attacks.
- Finisher knockdown and protected get-up work; no repeated ground-hit stun lock.
- Pause/resume in every attack phase and reset while hurt produce a clean state.
- Record focused regression command and visual timing checks separately.

Exclude enemy decisions, live encounter sequencing and special moves.
See [validation](../ACCEPTANCE.md).

## Completion record

Pending: files changed; combat tuning; regression commands/results; visual
observations; intentionally untouched files; follow-ups.
