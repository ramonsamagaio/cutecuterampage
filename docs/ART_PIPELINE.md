# CuteCute Rampage - Pixel Art / Rig Pipeline

## Pixel rules

- native 32px-style design language;
- no smoothing or antialiasing;
- nearest filtering;
- integer-coordinate animation whenever practical;
- no automatic palette shifts;
- transparent source assets;
- rigid cutout parts instead of mesh deformation for tiny characters.

## Taffi Skeleton2D

The placeholder rig is already represented in `scenes/actors/Taffi.tscn`:

```text
Taffi
├── Visual
│   └── Skeleton2D
│       └── HipRoot
│           ├── Torso
│           │   ├── Head
│           │   │   ├── EarL
│           │   │   ├── EarR
│           │   │   └── Bow
│           │   ├── ArmBack
│           │   └── ArmWeapon
│           │       └── WeaponSocket
│           ├── LegL
│           └── LegR
└── Camera2D
```

The weapon arm stays comparatively stable; the back arm swings. Hop motion comes from hip/root integer bob plus opposite leg phase. Head, ears and bow trail very slightly for secondary motion.

## Real art replacement

When final Taffi art is ready, export these transparent layers on the same source canvas and at exactly the same scale:

- `head.png`
- `ear_L.png`
- `ear_R.png`
- `bow.png`
- `torso_dress.png`
- `arm_back.png`
- `arm_weapon.png` including the flexed hand
- `leg_L.png`
- `leg_R.png`

Leave 2-3 hidden pixels of overlap at joints. Do not crop every piece to a different canvas. Replace each placeholder `PixelPart` child with a `Sprite2D`; keep the Bone2D hierarchy and pivots. The `WeaponSocket` remains the common attachment point for every gun.

## World tiles

The runtime placeholder atlas contains four 32x32 grass variants. Decorative pixels are kept away from tile borders so the base remains seamless. `ChunkStreamer` uses 16x16-tile chunks and keeps a 5x5 neighborhood around Taffi, constructing only one new chunk per frame.

Final art should keep the same modular categories used in the OATHWAKE approach: base ground, variations, transitions, edges/corners, overlay flowers/scatter, and props. The current runtime atlas can be replaced with a real TileSet atlas without changing chunk logic.

## Gore language

Blood stays visibly pixelated. Hits may add blood squares directly onto rigid body parts. Death detaches simplified head/body/leg chunks which already carry stains, while droplets become bounded persistent ground splats. The intended feeling is arcade gore: bright, legible, exaggerated, never photographic.
