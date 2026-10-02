# Asset brief and candidate sources

**Status: shortlist only, researched 2026-10-02.** No assets have been downloaded,
licensed for this repository, imported, or visually tested. Product descriptions
are evidence of candidates, not proof that an archive meets every animation need.

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
