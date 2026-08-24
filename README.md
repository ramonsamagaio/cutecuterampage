# CuteCute Rampage

A hyper-cute, hyper-violent pixel-art bullet-heaven/action roguelite built in Godot 4.6.

The visual hook is sugary mascot-world pixel art colliding with exaggerated arcade gore. The gameplay target combines Vampire Survivors-style escalation/build addiction with more active Gungeon-like movement and dodging.

## Play the placeholder vertical slice

Open the project in Godot 4.6 and run `scenes/Main.tscn`.

### Controls

- **WASD / arrows**: move
- **Shift**: dash / Perfect Dodge through hostile candy bullets
- **Space**: trigger Special when the pink meter is full
- **Mouse**: aim Strawberry Overdrive while its giant cannon is active
- **SPECIAL ♡ button**: same Special from the HUD

Taffi auto-fires her build so the player can focus on movement, threat reading, dash timing, positioning and upgrade decisions.

## Current gameplay slice

- Taffi `Skeleton2D` / `Bone2D` placeholder rig with mathematical hopping walk cycle
- runtime-generated seamless 32px grass TileSet and bounded chunk streaming
- pixel blood droplets, persistent ground splats, body stains and dismemberment chunks
- chasers, ranged shooters, telegraphed chargers and elite affixes
- escalating adaptive `DANGER` director driven by both time and player level
- Perfect Dodge with invulnerability, combo and Special reward
- nonlinear XP curve and level-up build choices
- **Heart Blaster**, **Cupcake Mortar** and **Love Orbit** weapon families
- legendary weapon evolutions: **Heartstorm**, **Birthday Massacre** and **Halo of Hugs**
- elite reward chests and boss evolution chest loop
- **Cute Meter** momentum system: successful carnage increases damage/XP and progressively adds cute screen feedback; getting hit tears momentum down
- first two-phase boss, **Queen Mallow**, with radial barrages, aimed phase-two fan shots and telegraphed charges
- boss health HUD and reward callouts
- anime-style Taffi Special cut-in
- **Strawberry Overdrive**: 4.25-second mouse-aimed giant pixel cannon with layered HDR beam, glow, strawberries/hearts/stars and continuous sweep damage
- Special damage vaporizes normal hordes but is capped per tick on bosses so aiming the full beam matters

All placeholder art is generated in-engine so final sprites can replace it without rewriting the gameplay architecture.

See `docs/GAME_DESIGN.md`, `docs/DEPTH_PASS_01.md`, `docs/DEPTH_PASS_02.md`, `docs/ART_PIPELINE.md` and `docs/VFX_PIPELINE.md` for the direction and replacement pipeline.
