# Cute Cute Rampage — Performance + Visual Pass 04

Branch: `feature/juice-depth-pass-04`
Base: `feature/juice-depth-pass-03`

## Why this pass exists

The previous juice pass made combat denser and prettier, but it also exposed scaling problems once the screen filled with enemies, shots, gore and UI feedback. This pass treats visual quality and performance as the same design problem: spend CPU/GPU budget on effects the player can actually read, and stop spending it on invisible repeated work.

## Confirmed duplicate-gore bug

The suspicion that one enemy could throw multiple heads/body sets because several shots landed together was correct.

`CuteEnemy.take_damage()` could enter `_die()` more than once before Godot processed `queue_free()`. With multishot/piercing/rapid fire, several projectiles could hit the same already-dead enemy in one frame. Each call repeated the death burst, body chunks, XP and kill feedback.

Fix:

- `_dying` guard is set before `_die()` starts;
- additional hits are ignored once death begins;
- boss death has the same protection.

This should make flying body-part count correlate with actual kills again, not with how many projectiles overlap the corpse during its final frame.

## Main CPU hotspot: projectile × enemy scans

The largest structural cost was player projectile collision. Every active projectile scanned the complete `enemy` group every frame. With 150 enemies and 100 shots, that can become roughly 15,000 distance tests per frame before counting orbit weapons, explosions, targeting and VFX.

A spatial hash/grid (`EnemySpatialIndex`) now indexes enemies in 144 px cells. Projectiles, Love Orbit, cupcake explosions, debug explosions, nearest-target search and the Strawberry beam ask only for nearby cells.

This changes the hot path from broad `shots × all enemies` work toward small local candidate sets.

## Runtime budgets

Hard/soft budgets now prevent runaway object populations:

- player projectiles: max 220;
- hostile projectiles: max 260;
- transient cute FX: max 110;
- flying blood/body children: max 170;
- permanent ground splats: max 650 instead of 1800;
- XP orbs: max 140, with excess XP collected automatically;
- damage-number labels: bounded population;
- regular enemy population: capped lower, while enemy power scaling carries more of the late-run difficulty.

These are safety rails, not targets. Most runs should stay comfortably below them.

## Gore optimization

Gore keeps the violent-cute identity but no longer grows without restraint:

- duplicate death emissions fixed;
- normal enemy death body parts reduced to a deliberate four-piece burst, elites up to six;
- art chunks use a single `Sprite2D` rather than a nested cutout hierarchy;
- flying chunks live for less time;
- droplet amount dynamically drops when the flying-gore budget is busy;
- ground blood redraw is batched at a maximum of 12 Hz rather than redrawing the entire decal collection for every new droplet;
- splats still have pools, streaks, smears and satellite drops, so reduced quantity should not mean reduced variety.

## Other hidden costs removed

- enemy director no longer allocates the complete enemy group every frame just to count it;
- enemies cache player/game/blood references instead of repeatedly searching SceneTree groups;
- hostile bullets cache the player;
- Love Orbit uses local spatial queries and redraws at 30 Hz;
- Cute Meter fullscreen FX redraws at 15 Hz;
- HUD text/value refresh is 20 Hz instead of every rendered frame;
- XP orbs no longer redraw their geometry every frame;
- cupcake mortar only redraws during its short explosion animation;
- weapon visual stops rebaking/reassigning the same cached texture every shot.

## Visual quality changes

### Character/readability

- Taffi is larger again (`AimRig` 3.78) and camera zoom is 1.14.
- High-resolution cutout art now uses linear filtering.
- Small cached art uses Lanczos downsampling rather than nearest-neighbour reduction.
- Weapons are slightly larger and smoother.

### Projectiles

Player shots remain large and highly readable, but the expensive per-projectile animated pulse was removed. Their visual energy now comes from:

- cached illustration sprite;
- static soft HDR halo;
- directional trail;
- bloom from values above normal display range.

Enemy bullets use the same philosophy: clean silhouette, halo and trail, no per-frame cosmetic pulse.

### World finish shader

A single fullscreen `world_finish.gdshader` applies subtle:

- saturation shaping;
- contrast;
- pastel lift;
- vignette.

This is deliberately one cheap presentation layer rather than many individual shaders on hundreds of objects. HUD layers render above it.

### Environment

The grass now has eight calm procedural tile variants rather than four. The garden dressing adds static layered garden islands, rounded soil/value patches, softer flowers, stones, mushrooms, grass and bushes. Larger shape hierarchy should make the arena feel authored instead of like a flat green debug field without introducing extra gameplay nodes.

### HUD/UI

The HUD chrome was rebuilt around a clearer candy-console hierarchy:

- rounded panels with real border/shadow depth;
- Taffi portrait assembled from the actual character art;
- cleaner loadout cards;
- dedicated combo and kill pills;
- stronger readable text outlines;
- cleaner special console and level-up cards;
- static decorative UI is separated from functional controls.

## Built-in profiling overlay

Press **F3** during a run to toggle a lightweight debug panel showing:

- FPS;
- enemy count;
- player projectile count;
- hostile projectile count;
- transient FX count;
- flying gore children;
- ground splat count.

This is intentionally player-visible during development so future visual passes can be tuned from real runtime evidence instead of guesses.

## Expected biggest wins

In order of likely impact:

1. spatial projectile collision instead of scanning every enemy per shot per frame;
2. duplicate death/gore guard;
3. bounded gore and batched blood redraw;
4. capped projectile/FX/XP populations;
5. fewer SceneTree group allocations/lookups;
6. throttled full-screen/UI redraws.

## Runtime validation needed

This environment does not have a Godot executable, so this branch still requires a Godot 4.6.x smoke/performance test before merge.

Test plan:

1. Launch a clean run and check parser/strict-type errors.
2. Hold a dense fight until 100+ enemies are active.
3. Toggle F3 and record FPS plus the six live counters before and after the first visible hitch.
4. Confirm one enemy death produces one set of body chunks even when multishot/piercing hits it simultaneously.
5. Verify boss and normal enemies are still targetable/hittable after spatial indexing.
6. Verify Love Orbit still hits enemies across its entire ring.
7. Stress multishot + high fire-rate + Love Orbit + cupcake together.
8. Verify XP still arrives when the orb population hits its cap.
9. Check that the fullscreen finish affects the world but not the HUD.
10. Compare readability of Taffi, weapons and projectiles against the previous screenshot.
11. Check the new garden islands never create collision.
12. Use F3 to decide whether the next budget reduction should target enemies, shots, gore or transient FX rather than guessing.

## Next polish target after runtime tuning

Once this pass is stable, the next high-value visual work is authored weapon personality rather than simply adding more particles: distinct recoil, hit-stop for heavy impacts, directional flash shapes, enemy death variants, stronger elite telegraphs, richer props/landmarks and event-specific screen treatment.
