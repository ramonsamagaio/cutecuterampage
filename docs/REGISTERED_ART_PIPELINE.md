# Registered provisional art pipeline

The separated Taffi/chicken/pig PNGs are exported on a common canvas per character. That shared canvas is the registration system: if every layer is drawn at the same origin and same scale, the character assembles exactly as in Photoshop.

Rules for the current provisional pass:

- never crop transparent margins from character-part PNGs;
- never bake/downsample the PNG pixels at runtime;
- load the original texture and scale the Sprite2D only;
- use nearest filtering;
- every part belonging to the same character uses the same registered canvas size;
- at rest, every layer resolves to the same registered canvas center;
- animation changes transforms around the registration, not the source pixels.

Taffi keeps the existing Bone2D rig. Each registered layer is offset by the inverse of its bone rest-position chain, so all source canvases line up at rest while the bones can still animate the parts.

Chicken and pig currently prioritize exact assembly: all registered layers share the same origin. Their provisional walk uses tiny pixel-like translations and whole-body bounce rather than rotating each full registered canvas around its center.

Final hand-cleaned pixel art can replace these sources later without changing combat/gameplay architecture.
