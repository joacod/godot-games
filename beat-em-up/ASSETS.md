# Asset brief and candidate sources

**Status: Step 06 imports Toxic Enforcer from the reviewed free boss pack, 2026-10-02.** Biker, seaport enemy 1, and a
street backdrop are in the project. The acquisition record and exact sample
mapping are in [asset provenance](assets/PROVENANCE.md). Other entries below
remain candidates, not verified animation coverage.

## Step 01 decisions and gaps

- Biker supplies idle/run, an unarmed punch (`attack1`), a double punch
  (`attack2`), and a kick (misleadingly named `punch`). The source `attack3`
  contains an energy weapon and is excluded. The sample displays the unmodified
  double-punch sheet; it is not yet a one-strike combo implementation.
- Seaport enemy 1 supplies idle/walk and a melee attack. Other entries include
  ranged characters, drones, and a robot dog; this archive does not establish
  two standing melee silhouettes. Step 04 uses the armored Cyborg from the already-acquired hero pack as the bruiser.
- Both inspected actor archives have hurt/death, but no dedicated get-up.
  Biker has jump poses but no dedicated air attack. Approved direction for later
  mechanics: trim the second punch into one strike; use the kick as
  the finisher and air attack; use non-disintegrating death/fall frames for
  knockdown and reverse the fall into recovery. Validate these visually when
  implementing the owning mechanics. These are approved adaptations, implemented in Step 03 and inspected as
  rendered poses. The user accepted Step 03 after manual testing; no detailed
  device results were supplied.
- The free extra-animation and factory-boss archives were inspected before Step
  02. Extra motions provide walk and airborne fall/landing poses, but no dedicated
  air attack or get-up. Toxic Enforcer has readable melee punches, running poses,
  and a non-disintegrating death; punch/run are proposed sweep/charge mappings.
  The already-downloaded Cyborg has an armored silhouette and an unarmed punch,
  making it a bruiser candidate. Step 04 imports Cyborg; Step 06 imports Toxic Enforcer for the boss;
  scale, attack/recovery presentation, and final cast fit remain to be validated
  in Steps 04/06. No paid pack is selected.
- The street sample composites City1 Bright sky, buildings, rear wall and road,
  omitting oversized foreground props and the obscuring front wall. A mirrored
  road strip extends the floor. This is a single sample, not a verified tiling
  level. Its illustrative ground band is Y=238–316; bounds arrive in Step 02.

On 2026-10-02 the user chose to keep the free assets already available and make
adjustments for missing motions later. This resolves the asset decision needed
to proceed with Step 02; complete cast and adaptation acceptance remain pending
in the owning mechanics. Step 02 imports only the original Biker jump sheet and
uses its poses for ascent/apex/descent; it retains the existing locomotion sheet.

## Direction and shortlist

Start with a cohesive urban pixel-art style. Prefer free CraftPix assets or packs
already available through the user's account. Review actual animation sheets in
Step 01 before settling on character scale and combat presentation.

| Need | Candidate | What still needs checking |
| --- | --- | --- |
| Hero | [Free 3 Cyberpunk Characters](https://craftpix.net/freebies/free-3-cyberpunk-characters-pixel-art/) | Listed with 12 animations per character; verify unarmed attacks, jump and reactions |
| Extra hero motion | [Free Extra Animations for Cyberpunk Characters](https://craftpix.net/freebies/free-extra-animations-for-cyberpunk-characters/) | Optional supplement; verify matching character, anchor and dimensions |
| Ordinary enemies | [Free Pixel Enemies for Seaport](https://craftpix.net/freebies/free-pixel-enemies-character-pack-for-seaport-location/) | Choose two readable melee silhouettes; check attack and knockdown coverage |
| Boss | [Free Factory Boss Enemies](https://craftpix.net/freebies/free-factory-boss-enemies-asset-pack-for-cyberpunk/) | Toxic Enforcer candidate; verify animations can communicate sweep and charge |
| Scenery | [Free Pixel Art Street Backgrounds](https://craftpix.net/freebies/free-pixel-art-street-2d-backgrounds/) | Layered backgrounds; confirm usable ground depth, seams and scale |
| Ground and props | [Free Seaport Tileset](https://craftpix.net/freebies/free-seaport-tileset-32x32-pixel-art-for-platformer/) | Platformer art may need careful layout for a broad brawler street |

Do not force a shallow side-scrolling background to serve as the entire walkable
plane. Evaluate a street/yard floor separately. Pixel density, perspective, actor
height, and palette must work together; matching the genre tag is not enough.

## Required coverage

- Hero: idle, locomotion, three readable combo strikes, jump/fall, air attack,
  hurt, knockdown/get-up, and death.
- Ordinary enemies: idle, locomotion, tell/attack/recovery, hurt, knockdown/get-up,
  and death. Bruiser must be visually distinguishable without color alone.
- Boss: idle/movement, readable sweep and charge phases, hurt feedback, death.
- World: background layers, broad ground surface, arena boundaries, one breakable
  prop with broken state, one recognizable food pickup, small impact effect.
- UI/audio: legible font, health presentation, attack/hit/hurt/break/pickup/menu
  sounds, and one music loop. These have no selected source yet; search CraftPix
  first and record any remaining sourcing gap before adding another source.

An asset with three attack sheets is not necessarily three unarmed strikes.
If a required animation is missing, report the exact gap and propose either a
better pack or a clearly described animation adaptation for review. Temporary
debug shapes may support mechanic checks, but cannot satisfy final art acceptance.
Do not create replacement artwork before reviewing suitable CraftPix options.

## Acquisition and provenance

Use the user's logged-in browser for free or already-owned downloads when
available. Do not purchase a pack without explicit authorization. If access is
unavailable, provide the user the product link and exact files/animations needed.

For each imported pack record product URL, title/author, acquisition date, archive
name, included files, local destinations, modifications, and the license supplied
with that download. Consult the [CraftPix license page](https://craftpix.net/file-licenses/)
and the archive's terms at acquisition; licensing has not been verified by this
plan. Import only used assets and required license records, not whole promotional
or engine-specific bundles. Do not copy assets from `2d-platform` by assumption.

## Replacement contract to implement and verify

Keep feet anchored at the actor root, visuals under a separate child, and a
consistent facing convention. Map source animations to semantic gameplay names.
Record each sheet's dimensions, frame rectangles/count, frame rate, looping,
scale, and foot offset after import. Record active hit windows separately.

Changing art must not require changing enemy decisions, encounter sequencing,
damage rules, or menu flow. Different proportions can require explicit offsets,
collision footprints, reach, and animation timing adjustments; a swap is not
promised to be a filename replacement. Step 09 will prove and document this with
one real alternate character using a duplicate validation scene.

Step 03 imports only Biker and seaport enemy 1 hurt/death sheets from the original
archives. Gameplay trims the second punch, maps the kick to finisher/air attack,
and selects intact fall frames with reverse recovery. See the exact frame mapping
and phase timing in [Step 03](docs/steps/03-combat.md#combat-tuning-and-animation-mapping).
No new pack, replacement artwork, paid asset, or extra-animation import was needed.

Step 04 imports Cyborg idle/run/attack1/hurt/death as the bruiser. Its armored
silhouette differs from the seaport grunts without recoloring. The punch uses
source frame 4 for contact; fall uses intact frames 0–3 and reverse recovery.
The user accepted Step 04 after manual testing. Detailed motion/device observations
were not supplied; final cast and art-replacement acceptance remain in Step 09.

Step 06 imports only Toxic Enforcer Idle/Run/Attack/Prepare/Hurt/Death. The punch
maps to sweep (contact frame 3); Prepare maps to a stationary charge tell, Run to
its straight active movement, and intact Death frames to defeat. The 96 × 96
frames display at 2×, with foot offset (-48, -96). Native staged rendering was
inspected; attack readability, balance, and final cast acceptance remain pending
hands-on play. No new pack, paid asset, replacement artwork, or other boss was added.
See [Step 06](docs/steps/06-boss.md#boss-tuning-and-animation-mapping).
