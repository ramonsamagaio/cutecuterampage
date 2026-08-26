class_name CuteAudioDirector
extends Node

# Runtime placeholder sound design. Every stream is generated once at boot and cached.
# No per-shot sample generation, no one-AudioStreamPlayer-per-enemy, and hard voice limits.
const VOICE_COUNT: int = 12
const MIX_RATE: int = 22050

var _voices: Array[AudioStreamPlayer] = []
var _streams: Dictionary = {}
var _last_play_ms: Dictionary = {}
var _voice_cursor: int = 0
var enabled: bool = true

var _rate_ms: Dictionary = {
	"heart_shot": 52,
	"hit": 48,
	"crit": 70,
	"kill": 72,
	"gore": 90,
	"pickup": 65,
	"melee": 90,
	"chainsaw": 105,
	"boom": 120,
	"laser": 170,
	"magic": 105,
	"heavy": 180,
	"trail": 130,
	"hurt": 180,
	"ready": 700,
	"level": 350,
	"chest": 320,
	"evolve": 900,
	"dodge": 180
}

func _ready() -> void:
	add_to_group("audio")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_streams()
	for i: int in VOICE_COUNT:
		var voice: AudioStreamPlayer = AudioStreamPlayer.new()
		voice.name = "SFXVoice%02d" % i
		voice.volume_db = -8.0
		add_child(voice)
		_voices.append(voice)

func play_event(event_name: String, gain_db: float = 0.0, pitch_jitter: float = 0.04, force: bool = false) -> void:
	if not enabled or not _streams.has(event_name):
		return
	var now: int = Time.get_ticks_msec()
	var min_gap: int = int(_rate_ms.get(event_name, 70))
	if not force and now - int(_last_play_ms.get(event_name, -100000)) < min_gap:
		return
	_last_play_ms[event_name] = now
	var voice: AudioStreamPlayer = _find_voice()
	voice.stream = _streams[event_name] as AudioStream
	voice.volume_db = -8.0 + gain_db
	voice.pitch_scale = randf_range(1.0 - pitch_jitter, 1.0 + pitch_jitter)
	voice.play()

func play_weapon(weapon_id: String, evolved: bool = false) -> void:
	var event_name: String = "magic"
	var gain: float = 0.0
	match weapon_id:
		"ribbon_ripper", "love_letter_opener": event_name = "melee"
		"kawaii_chainsaw": event_name = "chainsaw"
		"sugar_crash", "strawberry_rain", "glitter_bomb": event_name = "boom"
		"bunny_boomerang", "bunny_hopper", "tea_party", "star_tantrum": event_name = "magic"
		"bubblegum_minefield", "honey_hazard", "rainbow_roadkill": event_name = "trail"
		"lollipop_guillotine", "marshmallow_hammer": event_name = "heavy"
		"teddy_drop", "bowling_besties": event_name = "heavy"
		"friendship_laser", "cupid_bad_day": event_name = "laser"
		"kiss_of_death": event_name = "crit"
		_: event_name = "magic"
	if evolved:
		gain += 1.8
	play_event(event_name, gain, 0.055)

func _find_voice() -> AudioStreamPlayer:
	for voice: AudioStreamPlayer in _voices:
		if not voice.playing:
			return voice
	var voice: AudioStreamPlayer = _voices[_voice_cursor % _voices.size()]
	_voice_cursor = (_voice_cursor + 1) % VOICE_COUNT
	voice.stop()
	return voice

func _build_streams() -> void:
	_streams["heart_shot"] = _tone(0.085, 760.0, 1160.0, 0.05, 1.8, 0.18)
	_streams["hit"] = _tone(0.065, 240.0, 110.0, 0.42, 2.7, 0.08)
	_streams["crit"] = _tone(0.13, 980.0, 1680.0, 0.12, 1.9, 0.28)
	_streams["kill"] = _tone(0.11, 190.0, 72.0, 0.58, 2.1, 0.14)
	_streams["gore"] = _tone(0.095, 125.0, 58.0, 0.72, 2.5, 0.05)
	_streams["pickup"] = _tone(0.10, 620.0, 1360.0, 0.02, 1.4, 0.35)
	_streams["melee"] = _tone(0.11, 420.0, 180.0, 0.50, 1.8, 0.08)
	_streams["chainsaw"] = _buzz(0.12, 92.0, 0.30)
	_streams["boom"] = _tone(0.18, 112.0, 42.0, 0.62, 1.8, 0.08)
	_streams["laser"] = _laser(0.22, 290.0, 820.0)
	_streams["magic"] = _tone(0.14, 520.0, 1040.0, 0.09, 1.7, 0.26)
	_streams["heavy"] = _tone(0.21, 88.0, 38.0, 0.48, 1.45, 0.06)
	_streams["trail"] = _tone(0.105, 350.0, 510.0, 0.14, 2.0, 0.22)
	_streams["hurt"] = _tone(0.16, 220.0, 96.0, 0.48, 1.65, 0.05)
	_streams["ready"] = _chime([660.0, 990.0, 1320.0], 0.27)
	_streams["level"] = _chime([523.25, 659.25, 783.99], 0.31)
	_streams["chest"] = _chime([440.0, 659.25, 880.0], 0.34)
	_streams["evolve"] = _chime([523.25, 783.99, 1046.5, 1568.0], 0.58)
	_streams["dodge"] = _tone(0.14, 1150.0, 2100.0, 0.03, 1.45, 0.40)

func _tone(duration: float, start_hz: float, end_hz: float, noise_amount: float, decay_power: float, harmonic: float) -> AudioStreamWAV:
	var sample_count: int = maxi(8, roundi(duration * MIX_RATE))
	var pcm: PackedByteArray = PackedByteArray()
	pcm.resize(sample_count * 2)
	var phase: float = 0.0
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = int(start_hz * 113.0 + end_hz * 17.0 + duration * 10000.0)
	for i: int in sample_count:
		var t: float = float(i) / float(maxi(1, sample_count - 1))
		var hz: float = lerpf(start_hz, end_hz, t)
		phase += TAU * hz / float(MIX_RATE)
		var env: float = pow(maxf(0.0, 1.0 - t), decay_power) * minf(1.0, t * 80.0)
		var wave: float = sin(phase) + sin(phase * 2.02) * harmonic
		wave += rng.randf_range(-1.0, 1.0) * noise_amount
		_write_s16(pcm, i * 2, wave * env * 0.48)
	return _wav(pcm)

func _buzz(duration: float, base_hz: float, noise_amount: float) -> AudioStreamWAV:
	var sample_count: int = roundi(duration * MIX_RATE)
	var pcm: PackedByteArray = PackedByteArray()
	pcm.resize(sample_count * 2)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 77881
	for i: int in sample_count:
		var t: float = float(i) / float(sample_count)
		var env: float = sin(PI * clampf(t * 1.3, 0.0, 1.0)) * (1.0 - t * 0.35)
		var sq: float = 1.0 if sin(TAU * base_hz * float(i) / MIX_RATE) >= 0.0 else -1.0
		var tooth: float = fmod(t * base_hz * 9.0, 1.0) * 2.0 - 1.0
		var wave: float = sq * 0.42 + tooth * 0.25 + rng.randf_range(-1.0, 1.0) * noise_amount
		_write_s16(pcm, i * 2, wave * env * 0.42)
	return _wav(pcm)

func _laser(duration: float, start_hz: float, end_hz: float) -> AudioStreamWAV:
	var sample_count: int = roundi(duration * MIX_RATE)
	var pcm: PackedByteArray = PackedByteArray()
	pcm.resize(sample_count * 2)
	var phase: float = 0.0
	for i: int in sample_count:
		var t: float = float(i) / float(sample_count)
		var hz: float = lerpf(start_hz, end_hz, smoothstep(0.0, 1.0, t))
		phase += TAU * hz / float(MIX_RATE)
		var env: float = sin(PI * t)
		var wave: float = sin(phase) * 0.55 + sin(phase * 0.51) * 0.22 + sin(phase * 2.03) * 0.13
		_write_s16(pcm, i * 2, wave * env * 0.52)
	return _wav(pcm)

func _chime(notes: Array[float], duration: float) -> AudioStreamWAV:
	var sample_count: int = roundi(duration * MIX_RATE)
	var pcm: PackedByteArray = PackedByteArray()
	pcm.resize(sample_count * 2)
	for i: int in sample_count:
		var t: float = float(i) / float(sample_count)
		var wave: float = 0.0
		for n: int in notes.size():
			var start: float = float(n) / float(notes.size()) * 0.36
			var local_t: float = maxf(0.0, t - start)
			var env: float = exp(-local_t * 7.2) if t >= start else 0.0
			wave += sin(TAU * notes[n] * duration * t) * env / float(notes.size())
		_write_s16(pcm, i * 2, wave * 0.72)
	return _wav(pcm)

func _write_s16(bytes: PackedByteArray, offset: int, value: float) -> void:
	var sample: int = clampi(roundi(value * 32767.0), -32768, 32767)
	var encoded: int = sample & 0xFFFF
	bytes[offset] = encoded & 0xFF
	bytes[offset + 1] = (encoded >> 8) & 0xFF

func _wav(pcm: PackedByteArray) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = pcm
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	return stream
