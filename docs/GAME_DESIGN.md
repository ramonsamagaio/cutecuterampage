# CuteCute Rampage - Vertical Slice Design

## North star

The hook is not merely "cute characters with guns." The hook must live in every layer: sugary mascot art, adorable UI language, bright chiptune/denpa energy, and aggressively exaggerated pixel gore. The violence is cartoon spectacle, not realism. The game should still be worth playing after the joke is familiar.

## Gameplay DNA

- **Vampire Survivors:** escalating density, power fantasy, build multiplication, readable pickup cadence.
- **Enter the Gungeon:** active movement, danger positioning, dash/perfect-dodge skill expression, satisfying projectile language.
- **Brotato-style readability:** short upgrade decisions and immediately legible stat changes.
- **CuteCute identity:** Cute Meter, combo callouts, anime Special cut-ins, candy/heart/star projectiles, mascot dismemberment, persistent pixel blood.

Default combat is auto-fire toward the nearest threat so the player can focus on movement and build decisions. The dash and later perfect-dodge rewards add active mastery without turning the game into a twin-stick requirement.

## Addiction cadence

Aim to give the player a meaningful stimulus every 20-40 seconds: level, chest, evolution, surge, mini-boss, combo milestone, Cute Meter threshold, or special-ready state.

Current bootstrap already contains:

1. escalating enemy director and periodic surges;
2. XP pickup and level-up choices;
3. multishot/damage/fire-rate/speed/HP upgrades;
4. combo labels: CUTE!, KAWAII!, SUGAR RUSH!, STRAWBERRY JUICE!;
5. Special meter charged by kills;
6. Taffi cut-in that hard-pauses the world, then detonates a screen-scale kill burst;
7. persistent ground blood, body stains, and dismemberment chunks.

## Next gameplay milestones

- perfect dodge window + reward multiplier;
- 5 genuinely distinct starter weapons;
- weapon evolution recipes;
- elite telegraphs and first boss;
- chest reward burst;
- Cute Meter visual escalation that makes the world *more adorable* as carnage rises;
- 15-20 minute first complete run;
- meta unlocks / sticker book after the run is fun enough by itself.

## Performance rule

Never recreate the OATHWAKE loading problem. World chunks are intentionally streamed one per frame. Enemy/gore counts have caps. Persistent blood is rendered by a bounded decal list rather than thousands of permanent nodes.
