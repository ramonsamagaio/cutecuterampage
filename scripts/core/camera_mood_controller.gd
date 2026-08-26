class_name CameraMoodController
extends Node

var _player: CharacterBody2D
var _camera: Camera2D

func _process(delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
		if is_instance_valid(_player):
			_camera = _player.get_node_or_null("Camera2D") as Camera2D
	if not is_instance_valid(_player) or not is_instance_valid(_camera):
		return

	# Small directional look-ahead makes movement feel less camera-locked and reveals more world ahead.
	var v: Vector2 = _player.velocity
	var look: Vector2 = Vector2(
		clampf(v.x * 0.095, -25.0, 25.0),
		clampf(v.y * 0.055, -13.0, 13.0)
	)
	var target_pos: Vector2 = Vector2(0, -20) + look
	_camera.position = _camera.position.lerp(target_pos, minf(1.0, delta * 4.8))

	# Idle framing is intimate; moving opens a hair; the beam gets a subtle cinematic pull-back.
	var speed_ratio: float = clampf(v.length() / 220.0, 0.0, 1.0)
	var target_zoom_value: float = lerpf(1.165, 1.145, speed_ratio)
	var special_value: Variant = _player.get("special_channeling")
	var special: bool = bool(special_value) if special_value != null else false
	if special:
		target_zoom_value = 1.115
	var target_zoom: Vector2 = Vector2.ONE * target_zoom_value
	_camera.zoom = _camera.zoom.lerp(target_zoom, minf(1.0, delta * 2.6))
