class_name ScreenMoodFX
extends Control

var _player: Node
var _time: float = 0.0
var _redraw_timer: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(delta: float) -> void:
	_time += delta
	_redraw_timer -= delta
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
	if _redraw_timer <= 0.0:
		_redraw_timer = 1.0 / 12.0
		queue_redraw()

func _draw() -> void:
	if not is_instance_valid(_player):
		return
	var max_hp_value: float = maxf(1.0, float(_player.get("max_hp")))
	var hp_value: float = float(_player.get("hp"))
	var hp_ratio: float = clampf(hp_value / max_hp_value, 0.0, 1.0)
	var special_value: float = clampf(float(_player.get("special_meter")) / 100.0, 0.0, 1.0)
	var combo_value: int = int(_player.get("combo"))

	# Low HP appears as a soft candy-red peripheral pulse, never an opaque red wash.
	if hp_ratio < 0.38:
		var danger: float = (0.38 - hp_ratio) / 0.38
		var heartbeat: float = 0.62 + sin(_time * (5.2 + danger * 2.2)) * 0.22
		_draw_edge_frame(Color(1.0, 0.10, 0.28, danger * heartbeat * 0.16), 22.0)
		_draw_edge_frame(Color(1.0, 0.26, 0.48, danger * heartbeat * 0.08), 40.0)

	# When the special is ready, the corners quietly sparkle so the state is felt before it is read.
	if special_value >= 0.995:
		var ready_pulse: float = 0.55 + sin(_time * 2.8) * 0.25
		_draw_corner_spark(Vector2(22, 22), ready_pulse)
		_draw_corner_spark(Vector2(size.x - 22, 22), ready_pulse)
		_draw_corner_spark(Vector2(22, size.y - 22), ready_pulse * 0.75)
		_draw_corner_spark(Vector2(size.x - 22, size.y - 22), ready_pulse * 0.75)

	# High combo adds a handful of edge streaks instead of another particle system.
	if combo_value >= 20:
		var combo_power: float = clampf(float(combo_value - 20) / 80.0, 0.0, 1.0)
		for i: int in 6:
			var y: float = 80.0 + fmod(float(i * 103) + _time * (24.0 + float(i) * 3.0), maxf(100.0, size.y - 160.0))
			var length: float = 18.0 + combo_power * 28.0
			var c: Color = Color(1.0, 0.72, 0.92, 0.05 + combo_power * 0.08)
			draw_line(Vector2(2, y), Vector2(2 + length, y - 4), c, 2.0, true)
			draw_line(Vector2(size.x - 2, y + 21), Vector2(size.x - 2 - length, y + 17), c, 2.0, true)

func _draw_edge_frame(color: Color, thickness: float) -> void:
	var t: float = maxf(2.0, thickness)
	draw_rect(Rect2(0, 0, size.x, t), color)
	draw_rect(Rect2(0, size.y - t, size.x, t), color)
	draw_rect(Rect2(0, t, t, size.y - t * 2.0), color)
	draw_rect(Rect2(size.x - t, t, t, size.y - t * 2.0), color)

func _draw_corner_spark(p: Vector2, pulse: float) -> void:
	var c: Color = Color(1.15, 0.72, 1.0, pulse * 0.30)
	var r: float = 8.0 + pulse * 4.0
	draw_line(p + Vector2(-r, 0), p + Vector2(r, 0), c, 2.0, true)
	draw_line(p + Vector2(0, -r), p + Vector2(0, r), c, 2.0, true)
	draw_circle(p, 3.0, Color(1.2, 0.92, 1.0, pulse * 0.28))
