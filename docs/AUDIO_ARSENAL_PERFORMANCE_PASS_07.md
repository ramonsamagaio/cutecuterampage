# Cute Cute Rampage — Audio / Arsenal / Performance Pass 07

Branch: `feature/audio-arsenal-performance-pass-07`
Base: `feature/arsenal-survivor-pass-06`

## Goal

Make the prototype feel substantially more alive and varied while lowering the cost of dense late-run combat. This pass adds audible feedback, expands the shared weapon pool from 13 to 23 families, and removes several recurring allocations / redraws that were invisible to the player.

The temporary art and sound are intentionally replaceable. The gameplay geometry should survive asset replacement.

---

## Audio architecture

### Lightweight runtime placeholders

`CuteAudioDirector` synthesizes a small set of short mono 22.05 kHz placeholder sounds once at startup. It does **not** generate samples during combat.

There are only **12 pooled AudioStreamPlayer voices** for the whole SFX mix. If every voice is occupied, the director reuses a voice instead of allocating another node.

Every event has a minimum repeat interval, so 100 simultaneous hits cannot become 100 simultaneous sounds.

Current sound events:

- Heart Blaster shot
- hit / crit
- kill / gore accent
- XP pickup
- melee slash
- chainsaw buzz accent
- explosion
- laser
- magic attack
- heavy impact
- persistent trail / hazard
- player hurt
- Special ready
- level up
- chest
- evolution
- Perfect Dodge

`GameplayAudioBridge` samples gameplay state at ~22 Hz instead of adding an audio component to every projectile/enemy. New Arsenal attacks call the audio director directly at their low-frequency fire event.

### Replacing the placeholder sounds

Put a `.wav` or `.ogg` in `assets/audio/sfx/` with the correct event name. `AssetAudioDirector` automatically prefers the real asset and falls back to the generated sound when a file does not exist.

See `assets/audio/sfx/README.md`.

This means sound replacement is incremental: one polished sound can be added without needing the rest of the audio pack.

---

## Arsenal size

Pass 06: **13 weapon families**.

Pass 07: **23 weapon families** in the level-up pool.

The six-weapon run limit is unchanged. More catalog entries therefore increase run variety without increasing the number of simultaneously equipped systems.

### Existing 13

1. Heart Blaster
2. Ribbon Ripper
3. Kawaii Chainsaw
4. Sugar Crash
5. Strawberry Rain
6. Bunny Boomerang
7. Bubblegum Minefield
8. Lollipop Guillotine
9. Teddy Drop
10. Friendship Laser
11. Star Tantrum
12. Cupcake Mortar
13. Love Orbit

### Ten new runtime weapons

#### LOVE LETTER OPENER → DIVORCE PAPERS
Two crossing close-range scissor arcs. Evolution also cuts a forward lane.

#### HONEY HAZARD → STICKY SITUATION
Persistent honey damage zones. Reuses the already-capped persistent hazard pool.

#### BOWLING FOR BESTIES → FRIENDSHIP STRIKE!!!
A smiling ball rolls through enemies and grows as it connects. It is the only new family in this pass with a dedicated moving-token array, capped at six balls.

#### BUNNY HOPPER → HOPSCOTCH HOMICIDE
Instant chain attack that hops between different nearby enemies. No projectile nodes are spawned.

#### TEA PARTY → TABLE FOR EVERYONE
Rotating radial volleys. Reuses the existing lightweight Star token pool.

#### CUPID'S BAD DAY → LOVE IS CANCELLED
Several diagonal damage lanes rake through the arena at once.

#### GLITTER BOMB → TOO FABULOUS TO LIVE
Delayed targeted explosion. Reuses the existing delayed heavy-impact pool. Evolution produces a cluster of impacts.

#### MARSHMALLOW HAMMER → BONK EVER AFTER
Slow front-loaded melee smash with large area, screen shake and heavy damage.

#### KISS OF DEATH → FRENCH KISS FINALE
Targets the healthiest nearby enemy and adds a current-HP-based chunk to the hit. Useful as an elite / boss pressure weapon.

#### RAINBOW ROADKILL → TASTE THE RAINBOW
Taffi leaves damaging rainbow-space behind her movement. Reuses the persistent hazard pool, so movement becomes attack geometry without adding a new node type.

---

# Performance audit 07

## 1. Catalog allocations in the Arsenal hot loop — FIXED

The base `ArsenalController` requests weapon data for each equipped non-legacy weapon during its normal update loop.

Previously `ArsenalCatalog.get_weapon()` used `duplicate(true)`. That meant immutable catalog dictionaries were being deeply copied repeatedly during combat.

Pass 07 returns the immutable catalog dictionary directly.

**Player-visible loss:** none.

## 2. Inventory UI allocations and redraw — FIXED

The detailed Arsenal UI previously queued a redraw every 0.20 seconds even when nothing changed. Its rounded panels also created new `StyleBoxFlat` resources inside `_draw()`.

Pass 07:

- redraws only when the loadout changes or the player presses `I`;
- caches panel/slot StyleBoxes once in `_ready()`;
- keeps the compact 6+6 inventory visible.

Also, Pass 06 had the inventory script but the Main scene did not actually instantiate it. Pass 07 wires it into `Main.tscn`.

**Player-visible loss:** none. The feature is actually more complete now.

## 3. Heart projectile collision frequency — REDUCED

Heart projectiles previously performed a spatial-index query every rendered frame.

Pass 07 checks collision at about **41.7 Hz** (`0.024 s`) with an initial randomized offset so hundreds of projectiles do not all query on the same frame.

At current projectile speeds / hit radii this remains frequent enough to preserve reliable hits while lowering query pressure.

**Player-visible loss:** intended to be none; smoke-test fast Heartstorm builds.

## 4. Duplicate projectile hit FX — REDUCED

Enemy damage already drives the shared hit-feedback system. The projectile itself was also spawning another impact FX node on every collision.

Pass 07 keeps the extra crit flash, but only samples normal projectile impact FX at 18%.

This does **not** reduce damage feedback, knockback or the enemy hit flash. It removes duplicate transient-node creation in the densest possible path.

## 5. Love Orbit redundant updates — FIXED

Taffi syncs Love Orbit every physics frame. The orbit's `update_stats()` previously called `queue_redraw()` even when level/evolution had not changed.

Pass 07 makes the update idempotent. If stats are identical it exits immediately.

Orbit collision also precomputes orb positions once per damage tick instead of recomputing all trigonometry for every enemy × every orb.

**Player-visible loss:** none.

## 6. Nearest-target allocation — FIXED

`EnemySpatialIndex.get_nearest()` previously called `get_nearby()`, which built an array of all enemies in the search radius and then iterated that array again to find the nearest target.

Pass 07 scans the relevant spatial buckets directly and returns the nearest enemy without creating the temporary nearby array.

This matters because auto-targeting is used constantly by Heart Blaster and several Arsenal families.

## 7. Blood / flying gore pressure — TIGHTENED

The game should still become gloriously red, but late-run moving gore is more expensive than static ground blood.

Pass 07 changes:

- ground splat cap: 650 → **560**;
- flying gore child cap: 170 → **130**;
- blood redraw cadence: 12 Hz → **10 Hz**;
- bursts automatically reduce droplet count once the moving-gore population gets high.

The varied splat shapes, streaks, smears, satellite droplets and body chunks remain.

The design principle is: **prefer a dense bloody history on the floor over 170 independently moving objects.**

---

# Performance architecture of the ten new weapons

The important constraint was not to turn 10 new attack names into 10 new forests of Nodes.

The new controller reuses existing systems:

- Honey Hazard → `_mines`
- Rainbow Roadkill → `_mines`
- Tea Party → `_stars`
- Glitter Bomb → `_drops`
- Love Letter Opener / Bunny Hopper / Cupid / Hammer → immediate spatial-index damage + transient pooled drawing
- Bowling For Besties → only dedicated new token array, hard cap **6**

The run still equips at most six weapons, so adding catalog variety does not mean all 23 systems execute at once.

---

# Remaining likely hotspots if a 100+ enemy run still falls below target FPS

These are deliberately **not** aggressively changed yet because they require more architectural work or could alter feel.

### A. Heart Blaster still uses one Node2D per projectile
Current hard cap is 220.

If F3 shows `PLAYER SHOTS` climbing during a slowdown, the next major optimization should be a projectile pool or a single-manager token renderer similar to the Arsenal Controller.

### B. CuteFX still creates transient Nodes
The cap is 110 and normal projectile duplication has now been reduced substantially. If `FX` is the number that spikes with frame time, make CuteFX a fixed pool next.

### C. Ground blood redraw still redraws the active splat history
Lower cadence/cap helps, but the long-term ideal is chunk-baked blood or texture stamping so old splats stop participating in redraw work.

### D. Enemy rendering / animation
With projectile and gore pressure lower, a very large enemy count may become the next dominant cost. Do not reduce enemy count or animation quality blindly. Profile it first.

---

# Test checklist

Use Godot 4.6.x and keep F3 visible during the heavy part of the run.

1. Confirm the project parses with `ArsenalControllerPlus`, `AssetAudioDirector` and `GameplayAudioBridge`.
2. Level until several of the ten new weapons appear.
3. Check all ten for damage, visuals and no red console errors.
4. Press `I`; confirm compact inventory + detailed inventory work.
5. Confirm generated SFX can be heard without any audio assets in the repo.
6. Add one test `assets/audio/sfx/heart_shot.wav`; restart and confirm it replaces only that placeholder.
7. Stress test 100+ enemies with a high-fire-rate Heart Blaster build.
8. Compare FPS / frame pacing with F3 values for Player Shots, FX, Flying Gore, Ground Splats and Arsenal Tokens.
9. Test Love Orbit at high level and confirm its visual still animates smoothly.
10. Test heavy overlapping attacks: Kawaii Chainsaw + Tea Party + Honey Hazard + Glitter Bomb + Rainbow Roadkill + Heart Blaster.

## Important

This environment cannot run the Godot 4.6.x editor/runtime, so the pass remains a draft until the parser and runtime smoke test is completed locally.
