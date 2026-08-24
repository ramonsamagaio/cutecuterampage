# CuteCute Rampage - VFX Pipeline

## Taffi Special: Strawberry Overdrive

The special is now a directional giant-cannon beam instead of a radial screen-clear.

### Runtime stack

```text
Taffi WeaponSocket
└── TaffiStrawberryOverdrive (Node2D)
    ├── BackGlow      (Line2D + additive canvas shader)
    ├── PinkBody      (Line2D + additive canvas shader)
    ├── WhiteCore     (Line2D + additive canvas shader)
    ├── HotCore       (Line2D + additive canvas shader)
    ├── Strawberries  (GPUParticles2D)
    ├── Hearts        (GPUParticles2D)
    └── Stars         (GPUParticles2D)
```

The current cannon body is a rigid pixel placeholder drawn in code. Replace it later with the approved giant cannon sprite without changing the beam system.

## Beam look

Four stacked `Line2D` layers create a readable anime beam:

- 112 px translucent hot-pink outer glow;
- 72 px saturated pink body;
- 31 px pale/white energy core;
- 9 px overbright white hot core.

The shader in `shaders/strawberry_beam.gdshader` uses additive blending, overbright HDR colors, time-based shimmer and scrolling energy ripples. The VFX script pulses line width during the 0.92 s lifetime so the beam snaps open, throbs, then collapses.

## Glow

`project.godot` uses the Mobile renderer with `rendering/viewport/hdr_2d=true`. `main.gd` creates one `WorldEnvironment` with glow enabled. The beam shader and particle self-modulate values can exceed 1.0, which gives the special selective 2D bloom instead of blurring the entire pixel-art scene.

If a very low-end target later needs a fallback, keep the same Line2D layers and disable HDR/glow; the beam remains readable because the core silhouette does not depend on bloom.

## Kawaii beam debris

Three GPU emitters currently generate runtime placeholder pixel textures:

- strawberry chunks: 26 particles, 0.82 s lifetime, slight downward gravity;
- hearts: 34 particles, 0.68 s lifetime;
- stars/sparkles: 46 particles, 0.54 s lifetime.

All emitters run at a fixed 30 FPS with interpolation disabled so the motion sits better beside pixel art. Final separated sprites can replace the generated textures directly.

## Damage volume

The visual beam and gameplay hit region share the same direction and length (1180 px). Damage uses a long widening strip rather than a circle, so the player gets a genuine proton-cannon fantasy: aim toward the nearest threat, erase everything downrange, and let the normal enemy death pipeline create pixel blood, body stains and dismemberment.

## Art rule

Do not make this VFX photorealistic. The hierarchy is:

1. strong pixel silhouette;
2. saturated flat colors;
3. overbright core;
4. bloom/glow;
5. recognizable strawberry/heart/star debris.

Glow is seasoning, not the drawing.
