# Cute Cute Rampage — Juice / Depth Pass 03

Branch: `feature/juice-depth-pass-03`

## Goal

Push the current vertical slice away from a flat prototype read and toward a denser, more tactile arcade feel. This pass focuses on scale/readability, impact feedback, garden depth, gore variation and slightly higher combat pressure.

## Presentation changes

- Taffi is ~15% larger through the live AimRig scale.
- Camera zoom is now 1.10, bringing the whole combat field closer without scaling the HUD.
- Taffi and enemies now have grounding shadows so they sit in the world instead of floating on the lawn.
- Enemy art scale increased from 2.05 to 2.36.
- Love Orbit hearts increased from 8/11 px to 15/20 px and use a wider orbit.
- Player and enemy projectiles are substantially larger, with pulse animation and glow for better readability.

## Combat feel

- Base chick HP increased from 12 to 26.
- Base pig HP increased from 30 to 52.
- Hits now apply directional knockback, with stronger impulses on critical hits.
- Enemy contact, normal hits, crits, kills, elite kills, explosions, boss events and the special can trigger camera shake at different strengths.
- Added hit flash to enemies.
- Death chunks travel farther and more body pieces can separate on death.
- Volatile elite death burst increased from 10 to 12 radial shots.

## VFX / lighting

- World glow/bloom strengthened and HDR threshold lowered so bright pink/gold FX bloom more visibly.
- Cute FX are pushed above 1.0 RGB where appropriate so they actually feed HDR glow.
- Muzzle, impact, crit, kill, heart, strawberry, power-up and puff effects were enlarged.
- Active cute-FX budget increased from 140 to 180.

## Blood / debris

- Flying blood now has multiple silhouettes: square drops, long arterial flecks, fat beads and split tissue-like flecks.
- Blood uses more shade variation and occasional larger droplets.
- Death bursts and ground stains are denser.
- Ground blood now supports multiple shapes: irregular cross splats, streaks, pools and smears with satellite droplets.
- Large kills throw peripheral splats farther from the body to create a visible spray fringe.

## Environment depth

Garden chunks now add several visual layers instead of only tiny flowers/pebbles:

- larger bushes with contact shadows;
- grass tufts;
- flower clusters;
- more flowers, pebbles and mushrooms;
- larger low-opacity terrain-value patches;
- tiny contact shadows/outline cues on props.

The dressing remains non-blocking so it adds depth without changing traversal.

## Difficulty pacing

- First surge starts sooner.
- Threat tier ramps faster.
- Boss arrival moved from 150 s to 125 s.
- Higher maximum enemy population.
- Faster baseline spawn cadence and larger surge bursts.
- Shooter and charger archetypes enter earlier.
- Elite chance and long-run enemy power scaling increased slightly.

## Runtime validation checklist

This environment cannot boot the Godot project directly, so run this pass in Godot 4.6.3 before merging:

1. Start a clean run and confirm no strict-type/parser errors.
2. Verify Taffi is visibly larger but HUD composition is unchanged.
3. Confirm Love Orbit hearts read clearly at gameplay zoom and collision feels fair.
4. Confirm player/enemy projectile sizes improve readability without obscuring Taffi.
5. Check normal hit, crit, kill, elite kill and cupcake camera shake strengths for nausea/overlap.
6. Confirm knockback never pushes enemies into permanent velocity or collision oddities.
7. Run at least to level 20 and check the new enemy HP/spawn curve.
8. Stress-test 150–250 enemies and watch FX/blood cost.
9. Confirm garden bushes/flowers never interfere with gameplay collision.
10. Test Strawberry Overdrive and boss death with the stronger bloom/shake stack.

## Next likely pass

After runtime tuning, the next high-value polish layer is per-weapon hit personality: micro hit-stop on heavy attacks, short directional light flashes, distinct muzzle/recoil behavior, enemy death archetypes, richer elite telegraphs and contextual world reactions to big attacks.
