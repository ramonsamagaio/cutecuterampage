class_name AssetAudioDirector
extends CuteAudioDirector

# Drop a real .wav or .ogg with one of these event names into assets/audio/sfx/.
# The procedural placeholder remains the fallback, so art/audio can be replaced incrementally.
const REPLACEABLE_EVENTS: Array[String] = [
	"heart_shot", "hit", "crit", "kill", "gore", "pickup",
	"melee", "chainsaw", "boom", "laser", "magic", "heavy", "trail",
	"hurt", "ready", "level", "chest", "evolve", "dodge"
]

func _ready() -> void:
	super._ready()
	_load_optional_assets()

func _load_optional_assets() -> void:
	for event_name: String in REPLACEABLE_EVENTS:
		var wav_path: String = "res://assets/audio/sfx/%s.wav" % event_name
		var ogg_path: String = "res://assets/audio/sfx/%s.ogg" % event_name
		var path: String = ""
		if ResourceLoader.exists(wav_path):
			path = wav_path
		elif ResourceLoader.exists(ogg_path):
			path = ogg_path
		if path.is_empty():
			continue
		var resource: Resource = load(path)
		if resource is AudioStream:
			_streams[event_name] = resource as AudioStream
