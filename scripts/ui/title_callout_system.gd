class_name TitleCalloutSystem
extends Control

const ENTER_TIME: float = 0.16
const HOLD_TIME: float = 0.72
const EXIT_TIME: float = 0.22
const TOTAL_TIME: float = ENTER_TIME + HOLD_TIME + EXIT_TIME
const DRAW_INTERVAL: float = 1.0 / 30.0

var _queue: Array[Dictionary] = []
var _current: Dictionary = {}
var _age: float = 0.0
var _draw_timer: float = 0.0
var _main: Label
var _sub: Label
var _font: Font
var _last_combo_tier: int = 0
var _last_kill_tier: int = 0
var _special_ready_latched: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_to_group("title_callouts")
	_font = ThemeDB.fallback_font

	_main = Label.new()
	_main.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_main.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_main.add_theme_font_size_override("font_size", 39)
	_main.add_theme_constant_override("outline_size", 7)
	_main.add_theme_color_override("font_outline_color", Color("32102d"))
	_main.add_theme_color_override("font_shadow_color", Color(0.10, 0.01, 0.08, 0.72))
	_main.add_theme_constant_override("shadow_offset_x", 4)
	_main.add_theme_constant_override("shadow_offset_y", 5)
	_main.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_main)

	_sub = Label.new()
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_sub.add_theme_font_size_override("font_size", 14)
	_sub.add_theme_constant_override("outline_size", 3)
	_sub.add_theme_color_override("font_outline_color", Color("32102d"))
	_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sub)
	_hide_labels()

func _process(delta: float) -> void:
	if _current.is_empty():
		if not _queue.is_empty():
			_start_next()
		return

	_age += delta
	_draw_timer -= delta
	_update_labels()
	if _draw_timer <= 0.0:
		_draw_timer = DRAW_INTERVAL
		queue_redraw()
	if _age >= TOTAL_TIME:
		_current.clear()
		_hide_labels()
		queue_redraw()

func show_callout(text: String, style: String = "cute", subtitle: String = "", priority: int = 0) -> void:
	if text.is_empty():
		return
	var item: Dictionary = {
		"text": text,
		"style": style,
		"subtitle": subtitle,
		"priority": priority
	}
	if priority >= 8 and not _current.is_empty():
		_queue.push_front(_current)
		_current = item
		_age = 0.0
		_apply_copy()
		return
	if _queue.size() >= 7:
		_queue.pop_back()
	_queue.append(item)

func show_combo_milestone(combo: int) -> void:
	var tier: int = 0
	if combo >= 350: tier = 7
	elif combo >= 220: tier = 6
	elif combo >= 140: tier = 5
	elif combo >= 90: tier = 4
	elif combo >= 55: tier = 3
	elif combo >= 28: tier = 2
	elif combo >= 12: tier = 1
	if tier <= _last_combo_tier:
		if combo < 6:
			_last_combo_tier = 0
		return
	_last_combo_tier = tier
	match tier:
		1: show_callout("CUTE!", "cute", "keep the sugar flowing")
		2: show_callout("SO CUTE!!", "cute", "adorable violence detected")
		3: show_callout("KAWAII RAMPAGE!", "rampage", "LOVE × BULLETS")
		4: show_callout("STRAWBERRY MASSACRE!", "rampage", "the garden is blushing")
		5: show_callout("DARLING DOMINANCE!!", "ultra", "ABSOLUTELY PRECIOUS")
		6: show_callout("LOVE OVERKILL!!!", "ultra", "NO SUCH THING AS TOO MUCH")
		_: show_callout("ULTRA CUTE!!!!!", "ultra", "9999% FRIENDSHIP", 7)

func show_kill_milestone(kills: int) -> void:
	var tier: int = 0
	if kills >= 1000: tier = 6
	elif kills >= 500: tier = 5
	elif kills >= 250: tier = 4
	elif kills >= 100: tier = 3
	elif kills >= 50: tier = 2
	elif kills >= 20: tier = 1
	if tier <= _last_kill_tier:
		return
	_last_kill_tier = tier
	var titles: Array[String] = ["", "SUGAR COATED!", "PRETTY DANGEROUS!", "RED IS CUTE!", "HONEY HAVOC!", "KAWAII KILL KILL!", "EVERYBODY HAPPY ROOM!"]
	show_callout(titles[tier], "kill", "%d LITTLE PROBLEMS SOLVED" % kills)

func update_special_ready(ready: bool) -> void:
	if ready and not _special_ready_latched:
		_special_ready_latched = true
		show_callout("SPECIAL READY! ♡", "special", "STRAWBERRY OVERDRIVE", 5)
	elif not ready:
		_special_ready_latched = false

func reset_combo_latch() -> void:
	_last_combo_tier = 0

func _start_next() -> void:
	if _queue.is_empty():
		return
	_current = _queue.pop_front()
	_age = 0.0
	_apply_copy()
	queue_redraw()

func _apply_copy() -> void:
	_main.text = String(_current.get("text", ""))
	_sub.text = String(_current.get("subtitle", ""))
	var colors: Dictionary = _style_colors(String(_current.get("style", "cute")))
	_main.add_theme_color_override("font_color", colors["text"])
	_sub.add_theme_color_override("font_color", colors["sub"])
	_main.visible = true
	_sub.visible = not _sub.text.is_empty()
	_update_labels()

func _update_labels() -> void:
	if _current.is_empty():
		return
	var w: float = size.x
	var h: float = size.y
	var enter: float = _ease_out_back(clampf(_age / ENTER_TIME, 0.0, 1.0))
	var exit: float = 1.0 - smoothstep(ENTER_TIME + HOLD_TIME, TOTAL_TIME, _age)
	var alpha: float = clampf(minf(enter, exit), 0.0, 1.0)
	var drift: float = maxf(0.0, _age - ENTER_TIME) * 5.0
	var center_y: float = h * 0.19 - drift
	var x_offset: float = lerpf(110.0, 0.0, clampf(enter, 0.0, 1.0))
	var pulse: float = 1.0 + sin(_age * 8.0) * 0.012

	_main.position = Vector2(w * 0.26 + x_offset, center_y - 38)
	_main.size = Vector2(w * 0.48, 68)
	_main.pivot_offset = _main.size * 0.5
	_main.scale = Vector2.ONE * pulse
	_main.modulate.a = alpha

	_sub.position = Vector2(w * 0.31 + x_offset * 0.45, center_y + 27)
	_sub.size = Vector2(w * 0.38, 28)
	_sub.modulate.a = alpha * 0.92

func _hide_labels() -> void:
	_main.visible = false
	_sub.visible = false

func _ease_out_back(t: float) -> float:
	var c1: float = 1.70158
	var c3: float = c1 + 1.0
	var x: float = clampf(t, 0.0, 1.0) - 1.0
	return 1.0 + c3 * x * x * x + c1 * x * x

func _style_colors(style: String) -> Dictionary:
	match style:
		"special": return {"text": Color("fff8bf"), "sub": Color("ff9bcb"), "panel": Color(0.72, 0.04, 0.42, 0.82), "edge": Color("fff3b0")}
		"evolution": return {"text": Color("fff0a5"), "sub": Color("ffd4ed"), "panel": Color(0.42, 0.08, 0.46, 0.88), "edge": Color("ffe682")}
		"chest": return {"text": Color("fff2ac"), "sub": Color("fff1f7"), "panel": Color(0.46, 0.12, 0.37, 0.88), "edge": Color("ffd86b")}
		"boss": return {"text": Color("ffbad4"), "sub": Color("fff0f5"), "panel": Color(0.30, 0.02, 0.12, 0.90), "edge": Color("ff4d82")}
		"perfect": return {"text": Color("dffff8"), "sub": Color("fff7b5"), "panel": Color(0.10, 0.38, 0.39, 0.84), "edge": Color("8ffff0")}
		"ultra": return {"text": Color("fff7b0"), "sub": Color("ffb3d5"), "panel": Color(0.78, 0.02, 0.31, 0.90), "edge": Color("fff0a0")}
		"rampage": return {"text": Color("ff8eb8"), "sub": Color("fff2ad"), "panel": Color(0.48, 0.03, 0.26, 0.88), "edge": Color("ff65a0")}
		"kill": return {"text": Color("ff9abf"), "sub": Color("ffd9e7"), "panel": Color(0.32, 0.025, 0.19, 0.84), "edge": Color("ff5c91")}
		_: return {"text": Color("ff9dca"), "sub": Color("fff2f8"), "panel": Color(0.26, 0.055, 0.24, 0.82), "edge": Color("ff8abb")}

func _draw() -> void:
	if _current.is_empty():
		return
	var enter: float = clampf(_age / ENTER_TIME, 0.0, 1.0)
	var exit: float = 1.0 - smoothstep(ENTER_TIME + HOLD_TIME, TOTAL_TIME, _age)
	var alpha: float = minf(enter, exit)
	var colors: Dictionary = _style_colors(String(_current.get("style", "cute")))
	var panel: Color = colors["panel"]
	panel.a *= alpha
	var edge: Color = colors["edge"]
	edge.a *= alpha
	var w: float = size.x
	var h: float = size.y
	var center: Vector2 = Vector2(w * 0.5, h * 0.20)
	var width: float = w * 0.43 * _ease_out_back(enter)

	# Angled enamel banner, with black under-shadow and bright candy edge.
	var shadow: PackedVector2Array = PackedVector2Array([
		center + Vector2(-width * 0.54, -31), center + Vector2(width * 0.50, -25),
		center + Vector2(width * 0.55, 34), center + Vector2(-width * 0.50, 40)
	])
	draw_colored_polygon(shadow, Color(0.04, 0.005, 0.035, 0.58 * alpha))
	var banner: PackedVector2Array = PackedVector2Array([
		center + Vector2(-width * 0.55, -38), center + Vector2(width * 0.50, -32),
		center + Vector2(width * 0.55, 27), center + Vector2(-width * 0.50, 33)
	])
	draw_colored_polygon(banner, panel)
	draw_polyline(PackedVector2Array([banner[0], banner[1], banner[2], banner[3], banner[0]]), edge, 3.0, true)

	# Tiny speed wings on both sides make even text feedback feel like an arcade event.
	for side: int in [-1, 1]:
		for i: int in 4:
			var y: float = center.y - 23.0 + float(i) * 15.0
			var x0: float = center.x + float(side) * (width * 0.54 + 10.0)
			var length: float = 18.0 + float(i) * 7.0
			draw_line(Vector2(x0, y), Vector2(x0 + float(side) * length, y - float(side) * 1.5), Color(edge.r, edge.g, edge.b, 0.45 * alpha), 2.0, true)

	var sparkle_count: int = 5 if String(_current.get("style", "cute")) in ["ultra", "special", "evolution", "chest"] else 3
	for i: int in sparkle_count:
		var a: float = _age * 1.8 + float(i) * TAU / float(sparkle_count)
		var p: Vector2 = center + Vector2(cos(a) * (width * 0.50 + 38.0), sin(a * 1.3) * 43.0)
		_draw_spark(p, 4.0 + float(i % 2) * 2.0, Color(edge.r, edge.g, edge.b, 0.62 * alpha))

func _draw_spark(p: Vector2, radius: float, color: Color) -> void:
	draw_line(p + Vector2(-radius, 0), p + Vector2(radius, 0), color, 1.7, true)
	draw_line(p + Vector2(0, -radius), p + Vector2(0, radius), color, 1.7, true)
