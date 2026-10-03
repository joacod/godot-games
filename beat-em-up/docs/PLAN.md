# Implementation plan

## Goal and scope

Deliver one complete street-brawler level: title → street fights → boss → victory,
with death, pause, retry, keyboard, and controller support. Target roughly 5–8
minutes for a successful first clear; tune from playtests rather than expanding
the level to hit a duration.

Initial creative direction is an urban pixel-art street leading into an industrial
yard. This is a planning default, subject to the Step 01 asset review. Gameplay
does not depend on cyberpunk names, outfits, or story.

Included: one hero; movement horizontally and across street depth; facing; jump;
three-hit ground combo; jump attack; health, hurt, knockback, knockdown and recovery;
two ordinary melee enemy behaviors; staged encounters; one boss with two attacks;
one breakable prop and a health pickup; HUD; sound; menus and a complete reset loop.

Deferred: co-op/networking, grabs/throws, weapons, special moves, blocking/dodging,
character selection, branching levels, progression, saves, score systems, lives or
continues, procedural content, mod support, runtime skins, a template generator,
editor plugins, publishing, and additional platforms. These are deliberate scope
cuts, not claims that the game reproduces every Final Fight mechanic.

## Sequence and status

Step 01's free-asset adaptations are approved for continued implementation;
their final visual fit remains pending in the owning mechanics. Step 02 is
accepted after user-reported manual testing. Step 03 is also accepted after
user-reported manual testing. Step 04 is accepted after user-reported manual testing.
Step 05 is accepted after user-reported manual testing. Step 06 is accepted by
the user for progression; detailed hands-on results were not supplied. Step 07
is accepted by the user for progression; recovery/balance hands-on results were
not supplied. Step 08 is implemented, pending listening and manual validation.
Step 09 is **not started**.
Steps depend on the preceding step. They can be requested individually, but are not independent
implementations.

| Step | Deliverable | Playable milestone |
| --- | --- | --- |
| [01 — Foundation and asset fit](steps/01-foundation.md) | Implemented; free-asset adaptations approved, final art fit pending | Street sample boots; see validation record |
| [02 — Movement and depth](steps/02-movement.md) | Accepted after user-reported manual testing | Bounded movement/jump test street; see validation record |
| [03 — Combat](steps/03-combat.md) | Accepted after user-reported manual testing | Combo and jump-attack a dummy; see validation record |
| [04 — Enemies](steps/04-enemies.md) | Accepted after user-reported manual testing | Mixed fight with two grunts and one bruiser |
| [05 — Level and encounters](steps/05-level.md) | Accepted after user-reported manual testing | Clear the street to the boss entrance |
| [06 — Boss and completion](steps/06-boss.md) | Accepted by user for progression | Boss and complete result/reset loop; see validation record |
| [07 — Props and recovery](steps/07-props.md) | Accepted by user for progression | Breakable and food on connecting stretch; balance playtest pending |
| [08 — Presentation](steps/08-presentation.md) | Implemented; listening/manual validation pending | Art, sound, menus and feedback integrated; see validation record |
| [09 — Acceptance and art swap](steps/09-acceptance.md) | Full regression and replacement proof | Verified game with practical editing notes |

## How to implement a step

1. Read the repository guidance, this plan, the selected step, and its referenced
   design/assets/acceptance sections. Inspect the current project before proposing edits.
2. Confirm dependencies and their evidence. Explain the bounded approach and obtain
   confirmation before implementing a non-trivial feature, as required by repository guidance.
3. Implement only the selected step. Use small scenes and explicit state; extract
   shared code only when actual duplication justifies it.
4. Run relevant checks and record commands, results, and manual gaps in the step's
   completion record. Include Godot-generated `.gd.uid` files with new scripts.
5. Update the row's status to implemented/pending manual validation or complete as
   appropriate. Do not call an unplayed milestone verified. Stop before the next step.

No commits, branches, pushes, purchases, or publication are authorized by this plan.

## Completion rule

The game is done when [acceptance](ACCEPTANCE.md) passes, including a real full
playthrough, retry/reset checks, controller input, audio listening, and a small
art-replacement exercise. A successful headless launch alone is insufficient.

If asset animation gaps or playtests challenge the design, record the concrete
problem and propose the smallest adjustment. Do not silently add mechanics or
turn this into a generalized engine.
