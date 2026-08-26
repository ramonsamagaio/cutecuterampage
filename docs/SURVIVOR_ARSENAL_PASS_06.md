# Cute Cute Rampage — Survivor Arsenal Pass 06

Branch: `feature/arsenal-survivor-pass-06`
Base: `feature/beauty-depth-pass-05`

## Goal

Push Cute Cute Rampage from "one cute character with a few attacks" into a real run-building survivor game, while keeping the screen prettier and the runtime lighter.

The design reference is the *structure* that makes Vampire Survivors readable and addictive, not its names/art/IP. All Cute Cute Rampage weapons, evolutions and charm names below are original.

---

## What was researched from Vampire Survivors

### The core character / weapon relationship

The classic Vampire Survivors structure is:

- the player chooses a character;
- each character starts with a particular weapon and has a character bonus/trait;
- weapons attack automatically;
- during the run, level-ups offer additional weapons and passive items from a broader shared pool;
- therefore the character defines the **start and bias of the run**, not the entire attack list.

That is the model adopted here.

**Cute Cute Rampage rule:** Taffi starts with Heart Blaster. Future characters can start with their own signature weapon/stat identity, but unlocked weapons come from a shared arsenal unless explicitly tagged as character-exclusive later.

### Inventory structure

The classic Vampire Survivors run has a very strong, legible build constraint:

- 6 weapon slots;
- 6 passive slots;
- weapons commonly level to 8;
- passives commonly level to 5;
- level-up choices can either add a new item or level an owned item;
- once slots are full, the build naturally becomes about upgrading what is already owned.

Cute Cute Rampage now mirrors that basic six-by-six language:

- **6 WEAPONS**
- **6 CHARMS** (our name for passives)
- weapon max: **Lv 8**
- charm max: **Lv 5**

The HUD has a compact always-visible strip and **I** opens a detailed build view.

### Evolutions

The recognizable Vampire Survivors loop is: max a weapon, hold its matching passive, then use an evolution-capable treasure chest to transform the weapon into a much stronger form. Most classic recipes keep the passive in the build.

Cute Cute Rampage uses:

**Weapon Lv 8 + required Charm Lv 1+ + evolution-capable chest = EVOLUTION**

Legendary/boss chests can evolve immediately when a recipe is ready. Regular elite chests become evolution-capable after 90 seconds in the current prototype. This timing is intentionally ours and can be balanced later.

### Attack diversity

Official poncle material now describes Vampire Survivors arsenals ranging across punches, rockets, magic, swords, shields, projectiles, elemental magic, glyphs, whips and special techniques. The useful lesson is not any one weapon: **each weapon should alter the geometry of the player's safe space.**

So our weapon families deliberately include:

- nearest-target projectile;
- directional melee arc;
- persistent close melee;
- radial area pulse;
- delayed targeted area;
- returning projectile;
- persistent floor hazard;
- annular melee sweep;
- delayed heavy impact;
- sweeping beam;
- radial travelling projectiles;
- lobbed explosive;
- orbiting contact weapon.

This gives builds different movement patterns instead of only changing DPS numbers.

### Sources used for the design research

- poncle, official Operation Guns FAQ: classic VS gameplay, characters, weapons and classic evolution method. https://poncle.games/operation-guns
- poncle, official Emerald Diorama FAQ: examples of weapon breadth (punches, rockets, magic, swords) and Glimmer attack variation. https://poncle.games/emerald-diorama-faq
- poncle, official Ode to Castlevania FAQ: examples of swords, shields, projectiles, elemental magic, glyphs and whips in the same survivor framework. https://poncle.games/ode-to-castlevania-faq
- poncle, official Adventures FAQ: limited arsenals, merchants and run-specific progression variations. https://poncle.games/adventures-faq
- Wikipedia gameplay summary: character-specific starting weapons/bonuses, automatic attacks, level-up weapon/passive choices, six weapon + six power-up structure, chests and evolved weapons. https://en.wikipedia.org/wiki/Vampire_Survivors
- Steam community explanations were used only as a secondary sanity check for the long-standing 6 weapon / 6 passive and evolution loop.

---

# Cute Cute Rampage Arsenal v0.6

## Existing / signature families

### HEART BLASTER
**Family:** auto-aim projectile  
**Owner:** Taffi signature start weapon  
**Fantasy:** cute heart bullets kiss the nearest enemy at irresponsible velocity.  
**Evolution Charm:** Extra Sprinkles  
**Evolution:** **HEARTSTORM DELUXE ♡**  
**Evolution direction:** more projectiles, stronger piercing, faster cadence and the existing Heartstorm behavior.

### CUPCAKE MORTAR
**Family:** lobbed targeted AoE  
**Evolution Charm:** Bigger Bow  
**Evolution:** **BIRTHDAY MASSACRE**  
**Fantasy:** larger cupcake impacts, stronger secondary stars and larger dessert explosions.

### LOVE ORBIT
**Family:** orbit/contact  
**Evolution Charm:** Charm Bracelet  
**Evolution:** **PLANETARY CRUSH ♡**  
**Fantasy:** larger orbital hearts, more bodies in the ring, stronger grinding contact zone.

---

# New attack families implemented with procedural placeholder visuals

## RIBBON RIPPER
**Family:** directional melee arc  
**Behavior:** a broad satin slash in Taffi's facing direction.  
**Build behavior:** rewards deliberately facing into a crowd instead of only kiting away.  
**Charm:** Lucky Ribbon  
**Evolution:** **LOVE HURTS ♡**  
**Evolution behavior:** mirrored follow-up slash behind Taffi, giving near-360 coverage while preserving the melee rhythm.

## KAWAII CHAINSAW
**Family:** persistent close melee  
**Behavior:** rapid short-range damage in a forward semicircle.  
**Build behavior:** turns close-range danger into a resource; pairs well with armor/movement.  
**Charm:** Plush Armor  
**Evolution:** **FRIENDSHIP FOREVER!!!**  
**Evolution behavior:** becomes a full circular buzz zone around Taffi.

## SUGAR CRASH
**Family:** centered AoE pulse  
**Behavior:** periodic expanding candy shockwave.  
**Build behavior:** creates a rhythmic "get surrounded, then pop the room" cadence.  
**Charm:** Strawberry Core  
**Evolution:** **SUGAR SUPERNOVA**  
**Evolution behavior:** much wider ring and stronger burst damage.

## STRAWBERRY RAIN
**Family:** delayed targeted AoE  
**Behavior:** marks enemies/positions, then drops strawberry impacts from above.  
**Build behavior:** creates temporal zoning and rewards moving enemies through marked areas.  
**Charm:** Bigger Bow  
**Evolution:** **STRAWBERRY MONSOON**  
**Evolution behavior:** more simultaneous marks, larger impact coverage.

## BUNNY BOOMERANG
**Family:** returning projectile  
**Behavior:** bunny blades fly outward then curve back to Taffi through the horde.  
**Build behavior:** return path rewards repositioning after the throw.  
**Charm:** Fast Delivery  
**Evolution:** **BUNNY MÖBIUS**  
**Evolution behavior:** more returning blades and denser paths.

## BUBBLEGUM MINEFIELD
**Family:** persistent floor hazard  
**Behavior:** Taffi leaves sticky pink damage zones behind her movement path.  
**Build behavior:** turns kiting routes into damage and makes movement itself part of the build.  
**Charm:** Long-Lasting Love  
**Evolution:** **BUBBLEGUM BLACK HOLE**  
**Evolution behavior:** larger, longer-lived zones and stronger repeated damage.

## LOLLIPOP GUILLOTINE
**Family:** annular melee ring  
**Behavior:** a giant candy blade sweeps the donut-shaped space around Taffi.  
**Build behavior:** strong mid-close spacing, intentionally leaves a small inner geometry before evolution.  
**Charm:** Plush Armor  
**Evolution:** **CANDY CRESCENT**  
**Evolution behavior:** ring gets stronger and the inner dead zone is also damaged.

## TEDDY DROP
**Family:** slow heavy targeted AoE  
**Behavior:** a giant teddy telegraph falls onto a priority target with a large impact.  
**Build behavior:** low-frequency high-satisfaction attack for deleting dense packs/elites.  
**Charm:** Honey Heart  
**Evolution:** **BEAR HUG EXTINCTION**  
**Evolution behavior:** triple teddy impacts around the target.

## FRIENDSHIP LASER
**Family:** sweeping beam  
**Behavior:** short-lived beam sweeps across the horde from the current target direction.  
**Build behavior:** lane-clearing geometry; player movement changes how the sweep intersects enemies.  
**Charm:** Sugar Rush  
**Evolution:** **BESTIES FOREVER BEAM**  
**Evolution behavior:** wider beam plus a shorter rear beam for a huge cross-lane moment.

## STAR TANTRUM
**Family:** radial travelling projectiles  
**Behavior:** stars burst outward in every direction and continue moving through the garden.  
**Build behavior:** excellent anti-surround weapon without replacing directional attacks.  
**Charm:** Charm Bracelet  
**Evolution:** **SUPERSTAR MELTDOWN**  
**Evolution behavior:** much denser radial burst.

---

# Charms / passive items

## STRAWBERRY CORE
+10% Might per level. Also directly increases Taffi's base damage when acquired.

## SUGAR RUSH
Reduces cooldowns across the Arsenal. Also slightly improves Heart Blaster fire interval.

## BIGGER BOW
Increases attack Area.

## EXTRA SPRINKLES
Adds Amount to compatible attacks. At selected levels it also adds Heart Blaster multishot.

## FAST DELIVERY
Increases moving projectile speed.

## LONG-LASTING LOVE
Increases duration of persistent attacks, mines and beams.

## BUBBLEGUM SHOES
Adds movement speed.

## PLUSH ARMOR
Reduces damage taken.

## HONEY HEART
Adds max HP and heals the new HP immediately.

## LUCKY RIBBON
Increases critical-hit chance for Arsenal attacks and is intended to influence future loot/chest quality.

## CHARM BRACELET
Evolution catalyst for orbit/radial families. It is reserved for stronger knockback/orbit interactions as those systems are expanded.

---

# Character philosophy

## Taffi
- starts with Heart Blaster;
- identity: ranged heart gunner, Cute Meter, Strawberry Overdrive;
- shared arsenal access during the run.

## Future character template

Every future character should define:

1. **Signature starting weapon** — the first slot is never empty.
2. **One stat identity** — e.g. Area, Cooldown, Movement, Armor, Luck, Amount.
3. **One behavioral quirk** — e.g. melee attacks double-hit after a dash, floor hazards grow while standing still, projectiles gain speed while moving.
4. Shared access to the unlocked arsenal unless the weapon is intentionally marked exclusive.

Possible future original examples only, no code yet:

- **Mimi** — starts Kawaii Chainsaw; close-range damage and armor bias.
- **Poffi** — starts Teddy Drop; Area and heavy-hit bias.
- **Bibi** — starts Bunny Boomerang; projectile speed and movement bias.
- **Mallow** — starts Sugar Crash; pulse/Area bias.

Names are placeholders until character direction is approved.

---

# Performance architecture

The most important constraint of this pass: **more weapon variety must not mean more Node spam.**

The new attacks are concentrated inside one `ArsenalController` CanvasItem.

### No new Node per Ribbon slash
One draw token + local spatial damage query.

### No new Node per Sugar Crash
One timed ring visual + one local spatial query.

### Strawberry Rain / Teddy Drop
Small capped arrays of telegraph records. No scene instances for each falling object.

### Boomerang / Star Tantrum
Tiny capped arrays of moving tokens drawn by one CanvasItem. They use the existing enemy spatial index instead of scanning every enemy.

### Bubblegum Minefield
Maximum 18 floor zones. Damage checks run at ~4.3 Hz, not every frame.

### Friendship Laser
One beam record. Damage ticks at a fixed cadence and uses local spatial candidates.

### Visual redraw
The Arsenal CanvasItem redraws at 30 Hz even if the game renders faster.

### Hard caps
- transient arsenal flashes: 48
- boomerangs: 18
- stars: 26
- bubblegum zones: 18
- Strawberry Rain marks: 14
- Teddy Drop marks: 9

These add to the existing Pass 04 budgets rather than replacing them.

---

# Treasure chest behavior

`RewardChest` now routes through the Arsenal when available.

Priority:

1. If an evolution recipe is valid and the chest is evolution-capable → evolve.
2. Otherwise upgrade one owned non-max weapon/charm.
3. If everything owned is maxed → heal + Cute Meter refill.

This means chests now participate in the run build instead of being only a standalone bonus event.

---

# UI

### Always visible
Compact bottom-center build strip:

- six weapon boxes;
- six charm boxes;
- level number in every occupied slot;
- evolved weapon indicator.

### Detailed inventory
Press **I** to open/close the detailed arsenal view.

It shows:

- all equipped weapons;
- level pips;
- evolved name when evolved;
- the matching evolution charm;
- all equipped charms and their level pips.

### Level-up cards
Level-up now asks the Arsenal for three legal choices.

A card clearly says:

- WEAPON or CHARM;
- item name;
- NEW or current level → next level;
- one-line behavior description.

Once a weapon/passive row is full, new items of that category stop entering the choice pool but owned items can continue leveling.

---

# Art handoff

All new attacks currently use procedural placeholder graphics by design. This lets gameplay geometry be tested before spending time on final sprites.

When bespoke art arrives, preserve the gameplay shape and replace only the renderer:

- Ribbon Ripper → ribbon/knife swipe sprite or trail;
- Kawaii Chainsaw → chainsaw weapon sprite + short saw trail;
- Sugar Crash → candy shockwave atlas/VFX;
- Strawberry Rain → falling strawberry sprites + impact decal;
- Bunny Boomerang → bunny-shaped blade sprite;
- Bubblegum Minefield → bubble puddle decal;
- Lollipop Guillotine → giant lollipop blade;
- Teddy Drop → giant plush sprite / squash impact;
- Friendship Laser → beam shader art pass;
- Star Tantrum → authored star sprites.

Do not turn these into hundreds of individual CPU-heavy nodes unless profiling proves it is safe. Prefer MultiMesh, GPU particles, one CanvasItem, pooled scenes or shaders.

---

# Runtime validation checklist

This environment cannot run Godot, so this pass needs a local Godot 4.6.x smoke test.

1. Start a run: Heart Blaster must occupy weapon slot 1.
2. Level up: three Arsenal cards should appear.
3. Pick a new weapon: it should appear in the six-slot strip and begin auto-attacking.
4. Verify each new attack family one at a time.
5. Press I: detailed inventory must open and close.
6. Fill six weapons and verify no seventh new weapon is offered.
7. Fill six charms and verify no seventh new charm is offered.
8. Level a weapon to 8, obtain its required charm, then open a boss/legendary chest and verify evolution.
9. Check Cupcake Mortar and Love Orbit still work when acquired through the Arsenal.
10. Stress 100+ enemies with several new weapons simultaneously.
11. Press F3 and watch **ARSENAL TOKENS** plus existing projectile/gore counters.
12. Compare FPS against Beauty Pass 05 at similar enemy counts.
13. Check that the new bottom-center inventory does not overlap the Special console at 1280×720.
14. Check level-up button wrapping/readability.
15. Check for strict typing/parser errors before merging.

---

# Next systems after this pass is stable

1. Character select + per-character signature weapon/bonus data.
2. Reroll / Skip / Banish on the level-up screen.
3. Unlock table / Collection screen between runs.
4. Evolution recipe discovery screen that reveals recipes only after first discovery.
5. Treasure chest presentation sequence with 1 / 3 / 5 reward jackpots.
6. Stage pickup charms that can exceed the normal six charm selection cap.
7. Arcanas-equivalent system with original Cute Cute Rampage identity, probably **LOVE LETTERS**, that modify whole attack families rather than simply adding stats.
8. Limit-break style post-max upgrades for endless/high-level runs.
