# Cute Cute Rampage SFX drop-in folder

Pass 07 generates lightweight placeholder SFX at runtime so the prototype is audible immediately.

To replace any placeholder, put a `.wav` or `.ogg` in this folder using the exact event name below. No code change is needed; real files automatically override the procedural fallback on startup.

- `heart_shot`
- `hit`
- `crit`
- `kill`
- `gore`
- `pickup`
- `melee`
- `chainsaw`
- `boom`
- `laser`
- `magic`
- `heavy`
- `trail`
- `hurt`
- `ready`
- `level`
- `chest`
- `evolve`
- `dodge`

Examples:

- `assets/audio/sfx/chainsaw.wav`
- `assets/audio/sfx/evolve.ogg`
- `assets/audio/sfx/heart_shot.wav`

Keep one-shots short and leave headroom. The runtime SFX director has a 12-voice pool and per-event rate limiting so dense survivor combat does not create hundreds of simultaneous AudioStreamPlayers.
