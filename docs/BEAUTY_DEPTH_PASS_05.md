# Cute Cute Rampage — Beauty / Depth Pass 05

Branch: `feature/beauty-depth-pass-05`
Base: `feature/juice-depth-pass-04`

## Goal

Make the game feel like a tiny living kawaii diorama rather than a flat arena, while respecting the performance guardrails introduced in Pass 04. The rule for this pass is: **more visual hierarchy, atmosphere and authored composition, not simply more spawned objects**.

## World depth

### Authored garden landmarks

Every streamed garden chunk now receives one larger visual landmark chosen deterministically from five types:

- heart-shaped flower bed;
- lily pond with ripples and lily pads;
- pink picnic blanket with tiny sweets;
- stone / mushroom garden;
- fence fragment with candy direction sign.

Some chunks also get a faint curved path ribbon. These are all drawn inside the existing static GardenDressing canvas item, so they add visual identity without gameplay nodes or collision.

### Foreground occlusion

Each chunk now has a separate `GardenForeground` canvas item at a foreground z-layer. It draws only one or two sparse tall clusters:

- tall flowers;
- leaf canopies;
- candy bushes.

Characters can briefly pass behind these elements. This is intentional 2.5D staging and creates a foreground / gameplay / background stack that the old flat lawn did not have.

### Ambient garden magic

A single `WorldAmbience` node follows Taffi and draws at 15 Hz:

- layered pink light pool beneath the action;
- sparse pollen / petals / sparkles;
- a restrained high-Cute magical ring.

This replaces the temptation to spawn dozens of decorative particle nodes.

### Moving canopy light

The single fullscreen world-finish shader now adds two broad, slow sine-based canopy-light fields. The effect is intentionally subtle: the garden light drifts very slowly, breaking uniform illumination without per-object lights or shadow maps.

The finish shader also gets a softer center lift and highlight compression for a more candy-like grade.

## Motion and tactile polish

### Cinematic camera framing

A small camera mood controller now:

- looks slightly ahead in the direction Taffi is moving;
- frames idle moments a little closer;
- opens the camera slightly while moving;
- gives Strawberry Overdrive a restrained cinematic pull-back.

Screen shake still uses `Camera2D.offset`, so the two systems do not fight each other.

### Candy ribbon motion trail

A single `PlayerMotionTrail` canvas item samples Taffi at 30 Hz and draws a very short pink ribbon behind movement. During dash it becomes brighter and wider. No trail sprites are spawned.

### Weapon recoil

The weapon art now has a tiny procedural recoil and flash response. The existing `set_base_weapon()` call made on Heart Blaster shots doubles as a recoil trigger when the weapon has not changed, so the effect costs no new projectile-side nodes or signals.

## Combat readability as beauty

A single pooled `CombatReadabilityFX` canvas item redraws at 12 Hz and provides:

- affix-colored ground rings and orbiting glints for elites;
- a strong charging warning ellipse for chargers;
- a quiet lavender floor cue for regular shooters;
- a larger boss floor ring.

This makes enemy roles easier to parse while also making the battlefield look more authored.

## Screen mood

A lightweight CanvasLayer below the HUD draws contextual screen treatment at 12 Hz:

- soft candy-red peripheral heartbeat below 38% HP;
- corner sparkles when Strawberry Overdrive is ready;
- restrained edge streaks at high combo.

It deliberately avoids fullscreen particle systems.

## HUD / UI

The HUD now has a three-layer composition:

1. world-finish / screen mood below;
2. static candy-console chrome behind the functional HUD;
3. a tiny `HUDShineFX` layer above the functional meters.

The chrome pass adds:

- more dimensional candy-console panels;
- brighter cream portrait framing;
- ribbon detail under the portrait;
- segmented meter guides;
- enamel-style loadout cards and status LEDs;
- cleaner combo / kill badges;
- a stronger special console;
- tiny animated sheen on the real live meters at only 10 Hz.

The old static decor remains below the actual controls so it cannot block labels or buttons.

## Performance philosophy

This pass intentionally avoids undoing Pass 04. The new motion is concentrated in a few pooled canvas items:

- `WorldAmbience`: 15 Hz;
- `CombatReadabilityFX`: 12 Hz;
- `ScreenMoodFX`: 12 Hz;
- `HUDShineFX`: 10 Hz;
- `PlayerMotionTrail`: samples at 30 Hz with only 14 stored points.

Garden landmarks and foreground clusters render statically when chunks are built.

## Runtime validation checklist

1. Launch in Godot 4.6.x and check strict-type / parser errors.
2. Confirm garden chunks show visibly different landmark compositions while walking.
3. Walk behind a tall foreground flower / bush and confirm the occlusion feels intentional rather than obstructive.
4. Check ambient motes remain subtle during a dense fight.
5. Verify camera look-ahead does not feel floaty or nauseating.
6. Dash repeatedly and confirm the ribbon trail clears itself and never grows indefinitely.
7. Confirm Heart Blaster has visible recoil without changing projectile origin / aim behavior.
8. Compare elite, shooter and charger readability at 100+ enemies.
9. Test low HP, full special and 20+ combo screen treatments.
10. Confirm HUD labels and buttons render above the decorative chrome, and meter sheen renders above the live bars.
11. Run the Pass 04 F3 profiler and make sure the new beauty layers do not materially change the dense-fight FPS floor.
12. Screenshot the same early-run view as the previous test for direct before / after art-direction comparison.

## Next art target

After runtime tuning, the biggest visual leap will come from **authored asset variety** rather than more procedural decoration: 3–5 additional enemy silhouettes, larger hero props / buildings, unique biome landmarks, bespoke hit shapes per weapon, and hand-authored environmental set pieces that can become recognizable screenshot moments.
