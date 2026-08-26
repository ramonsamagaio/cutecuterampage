class_name HUDShineFX
extends Control

var _player: Node
var _time: float = 0.0
var _tick: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(delta: float) -> void:
	_time += delta
	_tick -= delta
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
	if _tick <= 0.0:
		_tick = 0.10
		queue_redraw()

func _draw() -> void:
	# Slim highlights travel across the real functional meters, while the heavier chrome stays static below.
	var hp_x: float = 110.0 + fmod(_time * 42.0, 238.0)
	draw_line(Vector2(hp_x, 31), Vector2(hp_x + 8, 47), Color(1.35, 1.0, 1.25, 0.28), 2.0, true)
	var xp_x: float = 110.0 + fmod(_time * 31.0 + 62.0, 238.0)
	draw_line(Vector2(xp_x, 58), Vector2(xp_x + 5, 65), Color(1.25, 0.95, 1.35, 0.20), 1.5, true)
	var cute_x: float = 110.0 + fmod(_time * 27.0 + 118.0, 238.0)
	draw_line(Vector2(cute_x, 75), Vector2(cute_x + 5, 82), Color(1.30, 0.98, 1.18, 0.20), 1.5, true)
	var special_x: float = 938.0 + fmod(_time * 55.0, 300.0)
	draw_line(Vector2(special_x, 620), Vector2(special_x + 10, 634), Color(1.5, 1.04, 1.32, 0.26), 2.0, true)

	if is_instance_valid(_player):
		var special: float = clampf(float(_player.get("special_meter")), 0.0, 100.0)
		if special >= 99.5:
			var pulse: float = 0.55 + sin(_time * 3.0) * 0.25
			draw_arc(Vector2(1089, 636), 154.0, PI + 0.08, TAU - 0.08, 28, Color(1.35, 0.48, 0.90, pulse * 0.16), 3.0, true)
			_draw_spark(Vector2(1248, 617), 6.0 + pulse * 3.0, Color(1.5, 0.90, 1.20, pulse * 0.42))

func _draw_spark(p: Vector2, radius: float, color: Color) -> void:
	draw_line(p + Vector2(-radius, 0), p + Vector2(radius, 0), color, 1.8, true)
	draw_line(p + Vector2(0, -radius), p + Vector2(0, radius), color, 1.8, true)
