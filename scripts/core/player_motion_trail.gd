class_name PlayerMotionTrail
extends Node2D

const SAMPLE_INTERVAL: float = 1.0 / 30.0
const MAX_POINTS: int = 14

var _player: Node2D
var _sample_timer: float = 0.0
var _points: Array[Vector2] = []
var _last_position: Vector2 = Vector2.ZERO
var _dash_glow: float = 0.0

func _ready() -> void:
	z_as_relative = false
	z_index = 2

func _process(delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if is_instance_valid(_player):
			_last_position = _player.global_position
	if not is_instance_valid(_player):
		return

	var dashing: bool = false
	if _player.has_method("is_dashing"):
		dashing = bool(_player.call("is_dashing"))
	_dash_glow = move_toward(_dash_glow, 1.0 if dashing else 0.0, delta * (12.0 if dashing else 5.0))

	_sample_timer -= delta
	if _sample_timer <= 0.0:
		_sample_timer = SAMPLE_INTERVAL
		var current: Vector2 = _player.global_position
		if current.distance_squared_to(_last_position) >= 18.0:
			_points.append(current)
			_last_position = current
			while _points.size() > MAX_POINTS:
				_points.pop_front()
		elif _points.size() > 2 and not dashing:
			_points.pop_front()
		queue_redraw()

func _draw() -> void:
	if _points.size() < 2:
		return
	var count: int = _points.size()
	for i: int in range(1, count):
		var t: float = float(i) / float(maxi(1, count - 1))
		var alpha: float = lerpf(0.015, 0.11 + _dash_glow * 0.15, t)
		var width: float = lerpf(1.5, 5.0 + _dash_glow * 4.0, t)
		var tint: Color = Color(1.35, 0.36 + t * 0.28, 0.88, alpha)
		draw_line(_points[i - 1], _points[i], tint, width, true)
	if _dash_glow > 0.18:
		for i: int in range(0, count, 3):
			var p: Vector2 = _points[i]
			var a: float = _dash_glow * (0.12 + float(i) / float(count) * 0.18)
			draw_circle(p, 2.0 + _dash_glow * 1.4, Color(1.55, 0.82, 1.0, a))
