class_name GameplayAudioBridge
extends Node

const POLL_INTERVAL: float = 0.045

var _audio: CuteAudioDirector
var _player: TaffiController
var _game: Node
var _hud: Node
var _tick: float = 0.0
var _last_hp: float = -1.0
var _last_xp: int = -1
var _last_level: int = -1
var _last_kills: int = 0
var _last_projectiles: int = 0
var _special_was_ready: bool = false
var _dodge_was_active: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_bind")

func _bind() -> void:
	_audio = get_tree().get_first_node_in_group("audio") as CuteAudioDirector
	_player = get_tree().get_first_node_in_group("player") as TaffiController
	_game = get_tree().get_first_node_in_group("game")
	if _game != null:
		_hud = _game.get_node_or_null("HUD")
	if is_instance_valid(_player):
		_last_hp = _player.hp
		_last_xp = _player.xp
		_last_level = _player.level
		_special_was_ready = _player.special_meter >= 99.5
	if _hud != null:
		_last_kills = int(_hud.get("kills"))
	if _game != null:
		_last_projectiles = int(_game.get("_active_player_projectiles"))

func _process(delta: float) -> void:
	_tick -= delta
	if _tick > 0.0:
		return
	_tick = POLL_INTERVAL
	if not is_instance_valid(_audio) or not is_instance_valid(_player) or _game == null:
		_bind()
		return

	var hp_now: float = _player.hp
	if _last_hp >= 0.0 and hp_now < _last_hp - 0.1:
		_audio.play_event("hurt", 1.0, 0.055)
	_last_hp = hp_now

	var level_now: int = _player.level
	if _last_level >= 0 and level_now > _last_level:
		_audio.play_event("level", 2.0, 0.0, true)
	_last_level = level_now

	var xp_now: int = _player.xp
	if _last_xp >= 0 and xp_now > _last_xp and level_now == _last_level:
		_audio.play_event("pickup", -2.5, 0.065)
	_last_xp = xp_now

	var projectiles_now: int = int(_game.get("_active_player_projectiles"))
	if projectiles_now > _last_projectiles:
		_audio.play_event("heart_shot", -4.0, 0.075)
	_last_projectiles = projectiles_now

	if _hud != null:
		var kills_now: int = int(_hud.get("kills"))
		if kills_now > _last_kills:
			var burst: int = kills_now - _last_kills
			_audio.play_event("kill", minf(3.0, float(burst) * 0.35), 0.10)
			if burst >= 4:
				_audio.play_event("gore", -1.0, 0.08)
		_last_kills = kills_now

	var ready_now: bool = _player.special_meter >= 99.5
	if ready_now and not _special_was_ready:
		_audio.play_event("ready", 1.4, 0.0, true)
	_special_was_ready = ready_now

	var dodge_active: bool = float(_player.get("_perfect_dodge_flash")) > 0.0
	if dodge_active and not _dodge_was_active:
		_audio.play_event("dodge", 1.8, 0.025)
	_dodge_was_active = dodge_active
