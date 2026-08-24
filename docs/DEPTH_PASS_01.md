# CuteCute Rampage — Depth Pass 01

This pass starts turning the prototype from a visual joke into a game that can sustain long runs.

## Strawberry Overdrive becomes a real aimed super

The anime cut-in still pauses the world, but the cannon now stays live for **4.25 seconds** after gameplay resumes. During the beam:

- aim follows the mouse continuously;
- Taffi can still move at 38% speed;
- normal auto-fire and dash are disabled;
- incoming damage is halved, but Taffi is not invincible;
- the beam applies damage every 0.075 s along its current direction, so sweeping the cannon across a horde matters;
- strawberry/heart/star particles emit continuously instead of appearing only at activation.

Kills caused by Strawberry Overdrive do not refill the Special meter while it is active, preventing immediate infinite super loops.

## Skill expression: Perfect Dodge

Dash now has a small true invulnerability window. Hostile candy bullets that pass within the Perfect Dodge radius while Taffi is dashing are erased and award:

- `PERFECT!` feedback;
- +6 combo;
- +9 base Special charge.

This is the first deliberate Gungeon-like layer on top of the Vampire Survivors-style auto-fire loop.

## Enemy roles

The director now mixes three behaviors:

- **Chaser:** the original pressure unit;
- **Shooter:** tries to hold medium range, strafes and fires hostile candy projectiles;
- **Charger:** telegraphs with a pink/red pulse, then commits to a fast straight-line rush.

Shooters begin entering after the opening phase. Chargers arrive later. Their probability climbs with both time and player level.

## Adaptive danger

The director now scales from both elapsed run time and Taffi's level. Enemy health, contact damage, movement speed, population cap, spawn cadence, elite chance and surge size all rise. The HUD shows `DANGER` plus run time so tuning can be evaluated during playtests.

The health curve intentionally rises faster than the old prototype because reaching level 50 without pressure was too easy.

## Progression changes

XP requirements are now mildly nonlinear instead of `5 + level * 4`, so high levels require increasingly meaningful carnage while the opening levels remain quick.

Three additional upgrade paths were added:

- **RIBBON REFLEX:** shorter dash cooldown;
- **PLUSH ARMOR:** multiplicative damage reduction;
- **LOVE BATTERY:** faster Special charge.

Maxed finite upgrades are removed from the level-up choice pool.

## Skeleton warning cleanup

Every Bone2D now has an explicit non-singular rest transform. Automatic bone length/angle calculation is disabled and manual values are supplied. This removes the leaf-bone warnings and the `det == 0` errors caused by the original placeholder skeleton having zero rest transforms.

The VFX script also renames locals that shadowed CanvasItem/built-in names (`material`, `seed`).
