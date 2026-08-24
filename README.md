# CuteCute Rampage

A hyper-cute, hyper-violent pixel-art bullet-heaven/action roguelite built in Godot 4.6.

The visual hook is sugary mascot-world pixel art colliding with exaggerated arcade gore. The gameplay target combines Vampire Survivors-style escalation/build addiction with more active Gungeon-like movement and dodging.

## Play the placeholder vertical slice

Open the project in Godot 4.6 and run `scenes/Main.tscn` (it is already configured as the main scene).

### Controls

- **WASD / arrows**: move
- **Shift**: dash
- **Space**: trigger Special when the pink meter is full
- **SPECIAL ♡ button**: same Special from the HUD

Taffi auto-fires at the nearest enemy for now so the first slice can focus on movement, dodging, horde pressure and build choices.

## Already scaffolded

- Taffi `Skeleton2D` / `Bone2D` placeholder rig with a mathematical hopping walk cycle
- separate ears, bow, weapon arm and `WeaponSocket`
- runtime-generated seamless 32px grass TileSet
- 16x16 tile chunk streaming, one new chunk per frame
- auto-fire, dash, XP, level-up choices and multishot/damage/fire-rate/speed/HP upgrades
- escalating chick/pig hordes and periodic surges
- heart projectile placeholders
- pixel blood droplets and persistent bounded ground splats
- blood that can stain enemy body parts before death
- dismembered head/body/leg chunks carrying blood stains
- CUTE / KAWAII / SUGAR RUSH / STRAWBERRY JUICE combo language
- Special meter charged by kills
- anime-style Taffi cut-in that pauses the game and fills the screen with action lines
- **Strawberry Overdrive**: giant directional pixel cannon, four-layer pink/white HDR beam, additive shader ripple, real 2D glow and GPU strawberry/heart/star particles
- beam damage uses a long widening kill corridor, so enemies downrange explode through the normal blood + dismemberment system

All placeholder art is generated in-engine so the real pixel assets can replace it without rewriting gameplay systems.

See `docs/GAME_DESIGN.md`, `docs/ART_PIPELINE.md` and `docs/VFX_PIPELINE.md` for the direction and replacement pipeline.
