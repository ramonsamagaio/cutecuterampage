# Survivor Systems Deep Research → Cute Cute Rampage Adaptation

This note records deeper Vampire Survivors research that should guide future Cute Cute Rampage systems without copying its IP, names or art.

## 1. Level-up pool is more sophisticated than pure random

Vampire Survivors level-ups normally pause the run and offer 3 or sometimes 4 unique choices. Eligible items are weighted by rarity, maxed items disappear from the pool, new items stop appearing once the relevant six-slot row is full, and Luck can influence parts of the selection behavior.

### Cute Cute Rampage adaptation

Current Pass 06 implements the hard structure first:

- three unique choices;
- no maxed items;
- no seventh new weapon/charm;
- owned items can keep leveling;
- Lucky Ribbon already exists as the future hook for weighted choice quality.

**Next implementation:** use each catalog item's `rarity` value to make common utility items appear more often and weird build-defining weapons appear less often. Lucky Ribbon should slightly bias toward owned items / rarer items rather than simply producing raw critical chance.

## 2. Reroll / Skip / Banish are build-control mechanics

Vampire Survivors has three important choice-control tools:

- **Reroll:** discard the current choices and roll a new set.
- **Skip:** leave the level-up without choosing an item.
- **Banish:** remove an item from future level-up offerings for the rest of the run.

These mechanics are important because a six-by-six inventory means bad choices have long-term consequences. They make the player feel responsible for shaping the build rather than being trapped by RNG.

### Cute Cute Rampage names

- **AGAIN! ♡** = Reroll
- **NO THANKS!** = Skip
- **EW! NEVER AGAIN!** = Banish

Suggested starting run budget:

- AGAIN! ♡ ×3
- NO THANKS! ×2
- EW! NEVER AGAIN! ×2

Future meta upgrades can increase these counts.

## 3. Arcanas are not normal passive items

Vampire Survivors' Arcana system applies high-impact rule changes to a build. In a standard Arcana-enabled run the player normally gets one at the start, then special opportunities later in the run. They can modify whole weapon groups, explosions, healing, empty slots, movement behavior, etc.

This is strategically different from a passive like +Area or +Cooldown.

### Cute Cute Rampage equivalent: LOVE LETTERS 💌

A Love Letter should change a rule, not merely add +10% to a stat.

Proposed structure:

- choose 1 Love Letter at the beginning of a run once unlocked;
- special miniboss at ~10:00 drops a Love Letter Envelope;
- another at ~20:00;
- normal target: 3 Love Letters per run;
- they do **not** consume weapon or charm slots.

### First original Love Letter ideas

#### 💌 TOO MUCH LOVE
Every melee hit emits a tiny heart shockwave. The fewer ranged weapons equipped, the larger the shockwave.

#### 💌 PRETTY WHEN ANGRY
Critical hits paint a temporary pink damage zone on the floor.

#### 💌 NEVER STOP SMILING
While moving continuously, Cooldown improves gradually. Standing still resets the bonus.

#### 💌 FRIENDSHIP IS VIOLENCE
Knockback against one enemy lightly bumps nearby enemies, creating tiny chain reactions.

#### 💌 STRAWBERRY WEATHER
Every 20 kills, a miniature Strawberry Rain burst occurs automatically around Taffi.

#### 💌 ONE TRUE LOVE
For every empty weapon slot, the equipped weapons gain Might + Area. This enables powerful one-weapon challenge builds.

#### 💌 CUTE FROM EVERY ANGLE
Directional/melee attacks echo once in the opposite direction at reduced strength.

#### 💌 SUGAR HIGH
Picking up XP while at high Cute Meter briefly increases movement and attack speed.

#### 💌 RED IS MY FAVORITE COLOR
Ground blood subtly increases damage dealt by melee attacks while Taffi stands near it. This ties the gore system into gameplay.

## 4. Limit Break solves the "everything is maxed" problem

Vampire Survivors can replace the late-game gold/heal-only level-up state with Limit Break, allowing maxed weapons to receive small stat increases beyond their normal cap.

### Cute Cute Rampage equivalent: RAMPAGE OVERFLOW

Unlockable late-run system.

Once all currently equipped weapons and charms are maxed:

- level-up stops offering normal arsenal cards;
- instead offer tiny upgrades to individual weapons;
- examples: +Might, +Area, +Speed, +Duration, +Amount, +Crit;
- each weapon has sensible caps for every stat except Might;
- UI should make these cards much faster to read than normal level-up cards.

This is important for the user's stated goal of very long/high-level runs.

## 5. Stage items can break the normal passive-slot limit

A powerful part of Vampire Survivors route planning is that passive items found physically on a stage can be collected after the normal passive row is full, allowing builds to exceed the standard six selected passives.

### Cute Cute Rampage adaptation: PICNIC PICKUPS

Some handcrafted garden landmarks can contain fixed charms.

Rule:

- level-up selection is capped at 6 Charms;
- physical Picnic Pickups on the map can be collected even after those 6 are full;
- they appear in an extra row in the detailed Arsenal view;
- this rewards exploration and turns landmarks into gameplay instead of pure decoration.

Example placement ideas:

- Honey Heart beside a picnic blanket;
- Bigger Bow near a giant gift box;
- Bubblegum Shoes near a playground;
- Lucky Ribbon at a tiny wishing fountain.

## 6. Candybox-style player agency is useful

Vampire Survivors has special rewards that allow direct selection from a larger weapon pool instead of receiving a normal random upgrade.

### Cute Cute Rampage equivalent: DARLING GIFT BOX 🎁

Very rare chest reward.

On pickup:

- opens the full unlocked weapon catalog;
- player chooses one legal weapon directly;
- if weapon slots are full, only owned weapons may be selected for a level;
- a legendary version can directly choose an evolution-ready weapon.

## 7. Treasure chests are also pacing events

Vampire Survivors treasure chests are not merely inventory updates. Their presentation gives the run punctuated celebration beats, and rare multi-reward chests create jackpot moments.

### Cute Cute Rampage chest tiers

#### SWEET BOX
1 reward.

#### PARTY BOX
3 reward rolls.

#### OMG!!! BOX
5 reward rolls + ridiculous short animation.

Keep these sequences short enough that frequent chests do not become annoying.

## 8. The deepest lesson: weapons are geometry

The useful design principle from studying the huge Vampire Survivors weapon catalog is not "more bullets". Strong weapons define different regions of safety and different movement behaviors.

Cute Cute Rampage should keep asking:

**What shape does this weapon make the player care about?**

Examples already in Pass 06:

- Ribbon Ripper → facing cone.
- Kawaii Chainsaw → danger becomes safety at point-blank range.
- Sugar Crash → timing-based circle.
- Strawberry Rain → delayed map zones.
- Bunny Boomerang → outward path + returning path.
- Bubblegum Minefield → movement history becomes damage.
- Lollipop Guillotine → annular spacing.
- Teddy Drop → heavy delayed target zone.
- Friendship Laser → lane.
- Star Tantrum → anti-surround radial pattern.

Future weapon ideas should preferably introduce a **new geometry or timing rule** before introducing a new sprite.

## 9. Additional original attack backlog

These are designed but not runtime-implemented in Pass 06 yet.

### LOVE LETTER OPENER
Melee scissors snap shut on the closest enemy in front. Evolution: **DIVORCE PAPERS** — giant crossing scissors repeatedly cut a lane.

### HONEY HAZARD
Slow honey puddles reduce enemy speed and deal low damage. Evolution: **STICKY SITUATION** — puddles connect into webs.

### BOWLING FOR BESTIES
A giant cute ball rolls forward, grows as it hits enemies, then explodes. Evolution: **FRIENDSHIP STRIKE!!!**

### BUNNY HOPPER
A projectile jumps from enemy to enemy rather than flying normally. Evolution: **HOPSCOTCH HOMICIDE**.

### TEA PARTY
Periodically spawns three teacups around Taffi; each cup fires in a different fixed direction before disappearing. Evolution: **TABLE FOR EVERYONE**.

### CUPID'S BAD DAY
Arrows fall in a straight diagonal rain across the screen. Evolution: **LOVE IS CANCELLED**.

### GLITTER BOMB
A slow projectile sticks to an enemy and explodes when enough nearby enemies gather. Evolution: **TOO FABULOUS TO LIVE**.

### MARSHMALLOW HAMMER
Huge slow melee overhead smash with tiny attack rate and enormous knockback. Evolution: **BONK EVER AFTER**.

### KISS OF DEATH
A slow heart seeks the healthiest enemy on screen and deals damage based on its current HP. Evolution: **FRENCH KISS FINALE**.

### RAINBOW ROADKILL
A short rainbow lane appears behind Taffi while dashing and damages enemies crossing it. Evolution: **TASTE THE RAINBOW**.

## 10. Research sources

- Vampire Survivors Wiki, Level up: 3/4 choices, six-slot restrictions, rarity weighting, Skip/Reroll, Limit Break behavior.
- Vampire Survivors Wiki, Reroll.
- Vampire Survivors Wiki, Banish.
- Vampire Survivors Wiki, Arcanas: normal three-Arcana run structure and rule-changing modifiers.
- Vampire Survivors Wiki, Limit Break: post-max weapon stat upgrades.
- poncle official Operation Guns, Emerald Diorama and Ode to Castlevania FAQs for breadth of weapons and evolution framework.

Research date: 2026-08-25.
