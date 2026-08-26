# Cute Cute Rampage — Super Darling Presentation Pass 07

Branch: `feature/super-darling-presentation-pass-07`
Base gameplay/progression pass: `feature/arsenal-survivor-pass-06`

## Goal

Turn the current playable survivor prototype into something that already reads like a deliberately art-directed game in screenshots and motion.

The visual north star is the existing Cute Cute Rampage concept art:

- chunky candy-pink arcade HUD
- strong white/dark outlines
- highly readable character and weapon silhouettes
- extreme cute-vs-gore contrast
- large, legible combat projectiles
- celebratory title cards and combo feedback
- a dense but coherent garden diorama
- anime/fighting-game spectacle for the Strawberry Overdrive

The pass also has a hard second goal: **beauty must stay cheaper than spawning hundreds of extra objects.** Most new presentation work is therefore a small number of pooled or persistent CanvasItems, procedural draw calls, one lightweight lighting rig, three GPU particle emitters on the special beam, and capped update frequencies.

---

# 1. Anime / fighting-game Strawberry Overdrive cut-in

`SpecialCutin` was rebuilt from a rectangular portrait card into an actual super-move presentation.

Current sequence:

1. gameplay freezes briefly;
2. a dark translucent cinematic veil appears;
3. a white/pink flash hits;
4. a large diagonal magenta band slices across the screen;
5. manga-style motion lines stream behind the portrait;
6. Taffi enters extremely fast from off-screen using cubic ease-out;
7. after the entrance she drifts only a few pixels, giving the classic super-portrait feel;
8. sparse hearts and star flares orbit the composition;
9. `STRAWBERRY OVERDRIVE!!!` appears as the hero title;
10. the cut-in clears and the four-second aimable beam begins.

The cut-in uses the registered original Taffi layers (`Corpo`, `Cabeca`, ears, bow, arm, hand) on the same canvas. This is intentional: it preserves the original art registration instead of constructing a disconnected arm from independently cropped pieces.

The special cannon is then composited over the registered hand with a tuned grip/rotation.

### Copy

- `♡ TAFFI SUPER MOVE ♡`
- `STRAWBERRY OVERDRIVE!!!`
- `LOVE • SUGAR • MAXIMUM FIREPOWER`

---

# 2. Strawberry beam 2.0

The Overdrive beam is now a layered volume, not one glowing line.

Five persistent Line2D layers:

1. Outer Bloom
2. Ribbon Aura
3. Pink Body
4. White Core
5. Hot Core

The shared shader adds:

- longitudinal energy waves
- edge warping
- two procedural ribbon strands
- flow/flicker
- sparse procedural spark cells
- bright inner-core lift
- HDR additive output

The VFX node adds:

- animated muzzle corona
- concentric charge rings
- travelling energy motes rendered by one CanvasItem
- beam-end corona
- heart/star/strawberry GPU particles

### Performance change

The previous special beam used five GPU particle emitters totalling roughly 196 configured particles.

Pass 07 uses three emitters totalling 78 configured particles:

- 24 hearts
- 32 stars
- 22 strawberry sparks

The missing visual density is recovered with the beam shader and a tiny procedural CanvasItem layer instead of more particle nodes.

Damage ticks also run at 0.085 s rather than every render frame.

---

# 3. Friendship Laser polish

The normal arsenal `FRIENDSHIP LASER` now has a dedicated presentation overlay without replacing its existing damage implementation.

One persistent CanvasItem reads the active laser state and draws:

- oversized outer aura
- second bloom shell
- saturated body
- hot inner core
- white-hot center
- travelling side motes
- launch corona
- endpoint corona

It redraws at 30 Hz and creates no per-laser child scenes.

---

# 4. Hand-pixeled HUD chrome

The decorative HUD chrome was rebuilt away from generic rounded UI boxes.

The new look uses nested rectangular borders and deliberate pixel corner cuts:

- dark purple/black outer ink
- cream-white enamel border
- bright pink inner rail
- deep candy panel fill
- square highlight bars
- hard offset shadows
- tiny screws / candy LEDs

This is used for:

- player portrait/stats console
- HP/XP/Cute bar bays
- combo marquee
- kill counter
- special console
- special meter frame
- special button well
- lower-left status cartridge

The real functional controls remain separate on top of this chrome, so visual drawing cannot break gameplay interaction.

---

# 5. Arsenal inventory is now visible and readable

The always-visible inventory is now a true 6 + 6 build strip instead of a tiny shorthand row.

## Compact view

Two rows:

- WEAPONS — six slots
- CHARMS — six slots

Each occupied slot shows:

- a procedural icon
- short item name
- level
- evolution sparkle when applicable

The compact frame is hand-drawn with nested pixel borders.

`I` or `TAB` opens the full Arsenal screen.

## Detailed view

The detailed screen shows:

- `CUTE CUTE ARSENAL`
- six weapon rows
- six charm rows
- item icons
- levels / level pips
- evolved name when applicable
- evolution recipe hint for each weapon
- empty slots clearly visible

Current weapon icon language is procedural so the system remains useful before final sprites exist. Every current attack has a readable little symbol rather than a two-letter placeholder.

---

# 6. Title / callout system

A persistent `TitleCalloutSystem` now handles arcade feedback as an actual layer of game feel.

Presentation:

- angled enamel banner
- thick outlined title
- subtitle
- overshoot entrance
- slight drift
- side speed wings
- sparse sparkles
- style presets for cute, rampage, ultra, kill, special, perfect, boss, chest and evolution

## Combo milestones

- 12 — `CUTE!`
- 28 — `SO CUTE!!`
- 55 — `KAWAII RAMPAGE!`
- 90 — `STRAWBERRY MASSACRE!`
- 140 — `DARLING DOMINANCE!!`
- 220 — `LOVE OVERKILL!!!`
- 350 — `ULTRA CUTE!!!!!`

## Kill milestones

- 20 — `SUGAR COATED!`
- 50 — `PRETTY DANGEROUS!`
- 100 — `RED IS CUTE!`
- 250 — `HONEY HAVOC!`
- 500 — `KAWAII KILL KILL!`
- 1000 — `EVERYBODY HAPPY ROOM!`

## Other occasions

- `PERFECT DODGE!`
- `SPECIAL READY! ♡`
- `STRAWBERRY OVERDRIVE!`
- `NEW WEAPON!`
- `WEAPON UP!`
- `NEW CHARM!`
- `CHARM UP!`
- `SWEET BOX!`
- `PARTY BOX!!`
- `OMG!!! BOX!!!`
- `EVOLUTION!!!`
- `BOSS INCOMING!`

The system has a small queue and priority support so major events can interrupt minor flavor copy.

---

# 7. Reward boxes are now an actual game event

RewardChest now has three presentation tiers.

## SWEET BOX

1 reward roll.

The first run now guarantees one early so the player learns the mechanic.

## PARTY BOX

3 reward rolls.

A second guaranteed milestone introduces the jackpot idea, and later kill milestones / elites can create more.

## OMG!!! BOX

5 reward rolls.

Boss reward tier. The first roll may evolve an eligible weapon; subsequent rolls continue upgrading the build.

### Chest visuals

- aura
- bobbing
- scale differences by tier
- palette changes
- more sparkles at higher tiers
- visible tier label above the box
- magnetic attraction to the player

### Survivor integration

Boxes now route through `ArsenalController.open_chest()` so they actually participate in the 6-weapon / 6-charm / evolution system rather than only touching the older legacy Taffi upgrades.

---

# 8. Lighting and depth

A lightweight `KawaiiLightingRig` adds the first real-time 2D light pass.

It contains only:

- one CanvasModulate
- one broad pink PointLight2D
- one smaller warm/hot PointLight2D

Both lights follow Taffi as one rig rather than creating lights on every bullet.

The light intensity reacts slowly to:

- Cute Meter
- Special Meter
- Strawberry Overdrive channeling

The ambient modulation also warms slightly at high Cute Meter.

This intentionally follows Godot's standard 2D-lighting model while staying far cheaper than per-projectile lighting.

Research reference:
- Godot 4 2D lights and shadows: https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html

---

# 9. Arm / weapon presentation

TaffiAimRig now treats Strawberry Overdrive as a visibly supported two-handed cannon pose:

- wider allowed special aim angle
- faster special aim response
- support arm follows the cannon much more closely
- support-arm bias reduced during the special

The Overdrive cannon is also larger and has a re-tuned pivot/offset.

---

# 10. Performance discipline

Pass 07 does not return to the uncontrolled-node approach that caused early performance problems.

### Persistent lightweight renderers

- TitleCalloutSystem — max 30 Hz only while active
- ArsenalInventoryUI — 4–6 Hz redraw depending on state
- KawaiiLightingRig — 20 Hz state updates
- FriendshipLaserPolish — 30 Hz
- Strawberry beam procedural layer — 30 Hz

### Special beam

- 5 Line2D layers
- only 3 GPUParticles2D emitters / 78 configured particles
- no light per particle
- no node per sparkle/mote

### UI

Most of the new pixel chrome is authored through CanvasItem draw calls.

The inventory no longer allocates a StyleBox for every slot on every redraw.

### Existing budgets retained

Pass 04's projectile, enemy-projectile, gore, XP and Cute FX budgets remain the underlying safety rails.

---

# Test plan before merge

Requires Godot 4.6.x runtime validation.

## Parser / smoke

- project opens without red parser errors
- Main scene starts
- lighting rig creates without renderer errors
- TitleCalloutSystem creates with HUD

## HUD

- top-left live bars align with new chrome
- combo text fits the marquee
- special button aligns with its new frame
- 6 + 6 compact inventory fits 1280×720
- `I` and `TAB` open/close Arsenal detail panel
- no HUD element blocks mouse input

## Rewards

- kill 18 produces SWEET BOX
- kill 65 produces PARTY BOX
- elite boxes still appear
- boss creates OMG!!! BOX
- 1/3/5 reward rolls actually update Arsenal levels/evolutions

## Titles

- combo milestone titles do not repeat every frame
- kill milestone titles trigger once
- Perfect Dodge triggers title once per dodge event
- Special Ready triggers once when meter becomes full
- chest/evolution/boss titles have proper priority

## Strawberry Overdrive

- portrait comes in fast and eases correctly
- no rectangle card remains
- arm/hand/cannon visually connect
- aim works for ~4 seconds
- beam remains attached to weapon socket
- beam follows mouse smoothly
- bloom/core remain readable on light and dark scenery
- GPU particle amount stays stable

## Performance

Use F3 with 100+ enemies and a busy build.

Specifically compare:

- idle FPS before/after Pass 07
- Friendship Laser active
- Strawberry Overdrive active
- PARTY / OMG reward presentation
- high gore count
- inventory detailed panel open

If the presentation costs more than the recovered performance margin, first reduce beam particle counts and callout redraw cadence before cutting the visual design itself.
