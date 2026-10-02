# Step 04 — Enemies and crowd combat

Status: not started. Prerequisite: Step 03 accepted.

## Outcome

A small live fight against grunts and a bruiser is winnable and losable with
readable attacks, manageable crowd pressure and a working reset.

## Work

1. Replace dummy behavior with a grunt that approaches, aligns, winds up,
   strikes and recovers. Add the slower, tougher bruiser variant.
2. Apply the existing damage/reaction rules to both. Telegraph attacks before
   activation and preserve committed facing; body overlap causes no damage.
3. Add simple separation and encounter-owned attack slots with a maximum of two
   commitments. Waiting enemies reposition without attacking offscreen.
4. Add provisional death/retry UI for this test fight; clean every enemy, slot
   and pending timer on reset. Test interruption and death slot release.

## Acceptance

- Both types can reach the hero across the unobstructed street without jitter or
  permanent stacking; their different timing is recognizable.
- Moving out of depth or behind a committed strike avoids damage.
- The player can defeat a mixed group and can die; retry restores the fight.
- An interrupted/dead enemy never reserves a slot forever; pause freezes all AI.

Exclude navigation systems, ranged enemies, new levels and a boss.
See [design](../DESIGN.md#enemies-and-encounters) and [validation](../ACCEPTANCE.md).

## Completion record

Pending: files changed; regression commands/results; mixed-fight observations;
balance values; intentionally untouched files; follow-ups.
