# CuteCute Rampage — provisional art integration pass

This pass intentionally uses the large separated source graphics already committed under `assets/` instead of waiting for final hand-cleaned pixel art.

## Runtime treatment

The separated Taffi/chicken/pig PNGs are registered exports: every body-part layer belonging to a character keeps the same transparent source canvas. When those images are superimposed at the same origin, they assemble exactly as authored in Photoshop.

The runtime now preserves that registration. `CutoutArtPart` loads the original PNG, never crops its transparent margins and never bakes/downsamples its pixels. It only scales the Sprite2D with nearest filtering. Taffi's Bone2D child art uses inverse rest-chain offsets so every registered canvas overlaps correctly at rest while the skeleton can still animate. Enemy layers stay on the same origin and use tiny pixel-like translations plus whole-body bounce.

## Taffi

The Skeleton2D uses the separated Taffi graphics: head, body, two ears, bow, back hand, weapon arm and two legs. Every Taffi layer uses the same registered display canvas. The held weapon is art-driven too: Heart gun normally, Star gun when Love Orbit is active, Bow after Heartstorm evolution, Cupcake launcher briefly when the mortar fires, and Waterjet art for Strawberry Overdrive.

## Enemies and gore

Chicken and pig are assembled from their registered separated graphics. Hits add blood marks to individual cutout pieces. Death throws several real body-part graphics as spinning blood-stained chunks while retaining the bounded pixel-blood ground splat system.

## FX mapping

- `ImpactoRosa` — normal projectile hits / cupcake impact
- `BrilhoDourado` — critical hits, boss death, reward punctuation
- `BrilhoRosa` — muzzle flashes and beam sparkles
- `PufffRosa` — enemy death / area explosions
- `CoracaoAlado` — Heartstorm projectile, reward/kill accents, evolved orbit
- `CoracaoRosaCheio` — basic heart projectile and beam hearts
- `CoracaoRosaMoldura` — normal Love Orbit and power-up feedback
- `Estrela` — evolved cupcake star ring and beam stars
- `MorangoFull`, `MorangoHaf` — high-Cute kill accents and Strawberry Overdrive debris

FX and particle textures are also kept as original PNGs. Their displayed size is controlled by node/particle scale instead of generating smaller image copies.
