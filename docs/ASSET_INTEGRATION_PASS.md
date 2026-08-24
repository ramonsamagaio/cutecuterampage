# CuteCute Rampage — provisional art integration pass

This pass intentionally uses the large separated source graphics already committed under `assets/` instead of waiting for final hand-cleaned pixel art.

## Runtime pixel treatment

`CutoutArtPart` trims transparent margins, downsamples the visible source graphic with nearest-neighbor sampling to a deliberately tiny target size, caches the resulting texture and renders with nearest filtering. The source PNGs stay untouched. This makes the current large artwork read much closer to real pixel art in-game while remaining disposable/provisional.

## Taffi

The placeholder geometry in the Skeleton2D has been replaced with the separated Taffi graphics: head, body, two ears, bow, back hand, weapon arm and two legs. The existing mathematical hop/bounce rig still drives them. The held weapon is now art-driven too: Heart gun normally, Star gun when Love Orbit is active, Bow after Heartstorm evolution, Cupcake launcher briefly when the mortar fires, and Waterjet art for Strawberry Overdrive.

## Enemies and gore

Chick and pig placeholders now assemble from the separated enemy graphics. Their limbs bob/swing while moving. Hits add persistent blood marks directly to the individual cutout pieces. Death now throws several of the real visible body-part graphics as spinning, blood-stained chunks instead of only generic rectangles, while retaining the bounded pixel-blood ground splat system.

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

The Strawberry Overdrive keeps the shader/glow beam but now uses the uploaded Waterjet weapon graphic as its provisional giant cannon and the uploaded FX graphics as GPU particle textures.
