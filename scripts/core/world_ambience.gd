class_name WorldAmbience
extends Node2D

const MOTE_COUNT: int = 22
const REDRAW_INTERVAL: float = 1.0 / 15.0

var _player: Node2D
var _time: float = 0.0
var _redraw_timer: float = 0.0
var _mote_seed: Array[Vector2] = []
var _mote_phase: Array[float] = []

func _ready() -> void:
	z_as_relative = false
	z_index = -2
	for i: int in MOTE_COUNT:
		var angle: float = TAU * float(i) / float(MOTE_COUNT) + sin(float(i) * 1.73) * 0.52
		var radius: float = 105.0 + float((i * 83) % 420)
		_mote_seed.append(Vector2.RIGHT.rotated(angle) * radius)
		_mote_phase.append(float((i * 137) % 100) * 0.071)

func _process(delta: float) -> void:
	_time += delta
	_redraw_timer -= delta
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if is_instance_valid(_player):
		global_position = _player.global_position
	if _redraw_timer <= 0.0:
		_redraw_timer = REDRAW_INTERVAL
		queue_redraw()

func _cute_amount() -> float:
	if not is_instance_valid(_player):
		return 0.0
	var value: Variant = _player.get("cute_meter")
	if value is float:
		return clampf(value as float, 0.0, 100.0)
	return 0.0

func _draw() -> void:
	if not is_instance_valid(_player):
		return
	var cute: float = _cute_amount() / 100.0
	var pulse: float = 0.5 + sin(_time * 2.4) * 0.5

	# A cheap layered light pool grounds Taffi and gives the center of combat a soft focal point.
	draw_circle(Vector2(0, 10), 72.0 + cute * 16.0, Color(1.15, 0.42, 0.72, 0.025 + cute * 0.025))
	draw_circle(Vector2(0, 10), 48.0 + cute * 10.0, Color(1.35, 0.66, 0.93, 0.035 + cute * 0.035))
	draw_circle(Vector2(0, 10), 27.0, Color(1.6, 0.88, 1.0, 0.035 + pulse * 0.018))

	# Sparse floating pollen/petals are drawn by one CanvasItem instead of many particle nodes.
	for i: int in MOTE_COUNT:
		var base: Vector2 = _mote_seed[i]
		var phase: float = _mote_phase[i]
		var drift: Vector2 = Vector2(
			sin(_time * 0.72 + phase) * (13.0 + float(i % 4) * 2.0),
			cos(_time * 0.54 + phase * 1.37) * (9.0 + float(i % 3) * 2.0)
		)
		var p: Vector2 = base + drift
		var twinkle: float = 0.35 + sin(_time * 2.0 + phase * 2.2) * 0.22
		var alpha: float = clampf(0.11 + twinkle * 0.16 + cute * 0.09, 0.06, 0.34)
		match i % 4:
			0:
				draw_circle(p, 1.6 + cute * 0.5, Color(1.45, 0.86, 1.0, alpha))
			1:
				draw_circle(p, 1.4, Color(1.35, 1.05, 0.42, alpha * 0.90))
			2:
				_draw_spark(p, 3.0 + cute * 1.5, Color(1.35, 0.74, 1.0, alpha))
			_:
				_draw_petal(p, Color(1.25, 0.55, 0.76, alpha * 0.86))

	# High Cute meter gets a restrained magical ring. It reads as reward without flooding the screen.
	if cute >= 0.62:
		var ring_alpha: float = (cute - 0.62) / 0.38
		var ring_radius: float = 98.0 + sin(_time * 1.8) * 3.0
		_draw_ring(ring_radius, Color(1.45, 0.56, 1.0, ring_alpha * 0.14))
		for i: int in 4:
			var a: float = _time * 0.52 + TAU * float(i) / 4.0
			_draw_spark(Vector2.RIGHT.rotated(a) * ring_radius, 4.0, Color(1.55, 0.88, 1.0, ring_alpha * 0.42))

func _draw_spark(center: Vector2, radius: float, color: Color) -> void:
	draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), color, 1.3)
	draw_line(center + Vector2(0, -radius), center + Vector2(0, radius), color, 1.3)

func _draw_petal(center: Vector2, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-2.5, 0.0),
		center + Vector2(0.0, -3.5),
		center + Vector2(2.5, 0.0),
		center + Vector2(0.0, 2.0)
	]), color)

func _draw_ring(radius: float, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in 33:
		var angle: float = TAU * float(i) / 32.0
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius * 0.44) + Vector2(0, 12))
	draw_polyline(points, color, 2.0, true)
