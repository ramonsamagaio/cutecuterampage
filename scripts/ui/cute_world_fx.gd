class_name CuteWorldFX
extends Control

var meter: float = 0.0
var _time: float = 0.0
var _draw_timer: float = 0.0
var _dirty: bool = true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func set_meter(value: float) -> void:
	var next_value: float = clampf(value, 0.0, 100.0)
	if absf(next_value - meter) >= 0.45:
		meter = next_value
		_dirty = true

func _process(delta: float) -> void:
	_time += delta
	_draw_timer -= delta
	if _draw_timer <= 0.0 and (_dirty or meter >= 25.0):
		_draw_timer = 1.0 / 15.0
		_dirty = false
		queue_redraw()

func _draw() -> void:
	var intensity: float = meter / 100.0
	if intensity <= 0.01:
		return
	var overlay_alpha: float = maxf(0.0, intensity - 0.34) * 0.040
	draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.16, 0.45, overlay_alpha))

	var sparkle_count: int = floori(intensity * 8.0)
	for i: int in sparkle_count:
		var x_seed: int = (i * 173 + 91) % 997
		var y_seed: int = (i * 311 + 47) % 983
		var x: float = float(x_seed) / 997.0 * size.x
		var y: float = float(y_seed) / 983.0 * size.y
		var pulse: float = 0.58 + sin(_time * 3.2 + float(i) * 1.7) * 0.30
		var alpha: float = intensity * pulse * 0.48
		var p: Vector2 = Vector2(x, y)
		draw_circle(p, 2.0 + intensity * 1.5, Color(1.0, 0.88, 0.97, alpha * 0.48))
		draw_line(p + Vector2(-5, 0), p + Vector2(5, 0), Color(1.0, 0.92, 0.98, alpha), 1.5, true)
		draw_line(p + Vector2(0, -5), p + Vector2(0, 5), Color(1.0, 0.92, 0.98, alpha), 1.5, true)

	if meter >= 76.0:
		var corner_alpha: float = (meter - 76.0) / 24.0 * 0.42
		_draw_corner_heart(Vector2(36, size.y - 40), corner_alpha)
		_draw_corner_heart(Vector2(size.x - 36, size.y - 40), corner_alpha)

func _draw_corner_heart(p: Vector2, alpha: float) -> void:
	var c: Color = Color(1.0, 0.35, 0.65, alpha)
	draw_circle(p + Vector2(-6, -2), 7.0, c)
	draw_circle(p + Vector2(6, -2), 7.0, c)
	draw_colored_polygon(PackedVector2Array([
		p + Vector2(-12, 0), p + Vector2(12, 0), p + Vector2(0, 16)
	]), c)
