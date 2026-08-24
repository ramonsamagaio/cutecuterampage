class_name CuteWorldFX
extends Control

var meter: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func set_meter(value: float) -> void:
	meter = clampf(value, 0.0, 100.0)
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	if meter >= 25.0:
		queue_redraw()

func _draw() -> void:
	var intensity: float = meter / 100.0
	if intensity <= 0.01:
		return
	var overlay_alpha: float = maxf(0.0, intensity - 0.28) * 0.055
	draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.18, 0.48, overlay_alpha))

	var sparkle_count: int = floori(intensity * 12.0)
	for i: int in sparkle_count:
		var x_seed: int = (i * 173 + 91) % 997
		var y_seed: int = (i * 311 + 47) % 983
		var x: float = float(x_seed) / 997.0 * size.x
		var y: float = float(y_seed) / 983.0 * size.y
		var pulse: float = 0.55 + sin(_time * 3.8 + float(i) * 1.7) * 0.35
		var alpha: float = intensity * pulse * 0.55
		var p: Vector2 = Vector2(x, y)
		draw_rect(Rect2(p + Vector2(-5, -1), Vector2(10, 2)), Color(1.0, 0.9, 0.98, alpha))
		draw_rect(Rect2(p + Vector2(-1, -5), Vector2(2, 10)), Color(1.0, 0.9, 0.98, alpha))

	if meter >= 72.0:
		var corner_alpha: float = (meter - 72.0) / 28.0 * 0.55
		_draw_corner_heart(Vector2(34, size.y - 38), corner_alpha)
		_draw_corner_heart(Vector2(size.x - 34, size.y - 38), corner_alpha)

func _draw_corner_heart(p: Vector2, alpha: float) -> void:
	var c: Color = Color(1.0, 0.35, 0.65, alpha)
	draw_rect(Rect2(p + Vector2(-12, -8), Vector2(9, 9)), c)
	draw_rect(Rect2(p + Vector2(3, -8), Vector2(9, 9)), c)
	draw_rect(Rect2(p + Vector2(-15, 0), Vector2(30, 8)), c)
	draw_rect(Rect2(p + Vector2(-10, 8), Vector2(20, 7)), c)
	draw_rect(Rect2(p + Vector2(-4, 15), Vector2(8, 6)), c)
