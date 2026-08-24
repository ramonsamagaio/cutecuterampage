# Concept Match Pass

Target read from the approved concept: a large readable hero at center, chunky cute enemies, dense garden dressing, candy projectiles/pickups, violent persistent gore, readable damage numbers, and weapons visibly held/aimed by Taffi rather than floating independently.

## Scale
- Taffi runtime visual is forced to 3.0x by `TaffiAimRig` (previous 1.65x).
- Chick/pig runtime visual is 2.05x before elite modifiers.
- Registered Photoshop character layers are never cropped or resampled; the whole canvas is scaled as one registered stack.

## Aim / weapon fit
- `TaffiAimRig` tracks the current auto-fire target and rotates both weapon arm and support arm toward it.
- `TaffiWeaponVisual` now has per-weapon fit profiles plus editor-exposed `fit_offset` and `fit_rotation_degrees`.
- Weapon art is standalone, so its transparent border is trimmed with nearest-neighbour baking. Character layers still preserve their full registered canvas.

## Animation workshop
Open `scenes/debug/AnimationWorkshop.tscn`.
- Taffi is an editable instance with the real Bone2D rig and weapon socket.
- Chicken and pig have explicit pivot nodes and empty AnimationPlayers for hand-keyed walk cycles.
- A weapon rack shows the same runtime fit profiles.

## Gore / impact
- More droplets per hit/kill, larger and more irregular persistent splats, more dismembered art chunks.
- Floating damage numbers bring the combat read closer to the concept.

## Debug explosives
During gameplay:
- `Z`: Strawberry Bomb
- `X`: Cluster Cupcake
- `C`: Strawberry Nuke

These deliberately overdrive blood, area damage and FX so gore density/performance can be tuned quickly.

## World density
Each streamed grass chunk now receives deterministic flowers, mushrooms, pebbles and ground patches. This remains placeholder dressing until the final authored tileset/props pass.
