class_name HUDConceptDecor
extends Control

var _head: Texture2D
var _ear_l: Texture2D
var _ear_r: Texture2D
var _bow: Texture2D
var _font: Font
var _time: float = 0.0
var _tick: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = -100
	_font = ThemeDB.fallback_font
	_head = CutoutArtPart.make_small_texture("res://assets/Taffi/Cabeca.png", Vector2i(66, 60))
	_ear_l = CutoutArtPart.make_small_texture("res://assets/Taffi/Ore1.png", Vector2i(21, 45))
	_ear_r = CutoutArtPart.make_small_texture("res://assets/Taffi/Ore2.png", Vector2i(21, 45))
	_bow = CutoutArtPart.make_small_texture("res://assets/Taffi/Laco.png", Vector2i(31, 25))
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	_tick -= delta
	if _tick <= 0.0:
		_tick = 0.16
		queue_redraw()

func _draw() -> void:
	# TOP LEFT: chunky authored arcade frame, deliberately square/cut instead of generic rounded UI.
	var stats_rect: Rect2 = Rect2(8, 10, 360, 151)
	_draw_pixel_frame(stats_rect, Color("241122"), Color("ff69a0"), Color("fff3f8"), 4)
	# Tiny raised header lip.
	draw_rect(Rect2(22, 16, 332, 5), Color("ff78aa"))
	draw_rect(Rect2(28, 17, 210, 2), Color(1.0, 0.90, 0.96, 0.72))

	# Portrait cartridge with a white enamel face and pink side rails.
	var portrait_rect: Rect2 = Rect2(18, 22, 80, 112)
	_draw_pixel_frame(portrait_rect, Color("fff0f6"), Color("ff84b4"), Color("40122f"), 3)
	draw_circle(Vector2(58, 85), 31.0, Color(1.0, 0.62, 0.82, 0.10))
	_draw_centered(_ear_l, Vector2(42, 48))
	_draw_centered(_ear_r, Vector2(70, 48))
	_draw_centered(_head, Vector2(59, 88))
	_draw_centered(_bow, Vector2(39, 65))
	_draw_ribbon(Vector2(58, 128))

	# Bar bays and tiny pixel separators. Functional ProgressBars sit on top.
	_draw_bar_bay(Rect2(104, 25, 252, 29), Color("ff5a91"))
	_draw_bar_bay(Rect2(104, 54, 252, 16), Color("72d8ff"))
	_draw_bar_bay(Rect2(104, 71, 252, 16), Color("ff8fbd"))
	for i: int in 8:
		var x: float = 113.0 + float(i) * 29.0
		draw_rect(Rect2(x, 77, 1, 5), Color(1.0, 0.91, 0.96, 0.20))

	# Pixel screws / candy LEDs make the panel feel like a toy device.
	for p: Vector2 in [Vector2(16, 18), Vector2(359, 18), Vector2(16, 153), Vector2(359, 153)]:
		draw_rect(Rect2(p, Vector2(3, 3)), Color("fff0a5"))

	# TOP CENTER: scoreboard canopy behind combo text.
	var combo_rect: Rect2 = Rect2(478, 18, 326, 77)
	_draw_pixel_frame(combo_rect, Color(0.095, 0.025, 0.085, 0.88), Color("f078aa"), Color(1.0, 0.90, 0.96, 0.82), 3)
	draw_rect(Rect2(496, 24, 290, 3), Color("ff8fbd"))
	draw_rect(Rect2(516, 28, 250, 1), Color(1.0, 0.84, 0.92, 0.30))
	_draw_spark(Vector2(493, 55), 5.0, Color("ff9fc7"))
	_draw_spark(Vector2(788, 55), 5.0, Color("fff0a3"))

	# TOP RIGHT: compact kill/currency style cartridge.
	var kill_rect: Rect2 = Rect2(1090, 14, 166, 49)
	_draw_pixel_frame(kill_rect, Color(0.10, 0.03, 0.09, 0.90), Color("f083ad"), Color("fff0f6"), 2)
	_draw_heart(Vector2(1110, 38), 0.75, Color("ff75aa"))
	draw_rect(Rect2(1130, 27, 104, 2), Color(1.0, 0.84, 0.92, 0.16))

	# BOTTOM RIGHT: the special is a large piece of hero UI, not a generic panel.
	var special_rect: Rect2 = Rect2(900, 552, 366, 157)
	_draw_pixel_frame(special_rect, Color("241023"), Color("ff68a0"), Color("fff1f7"), 4)
	# clipped/cut header band
	draw_rect(Rect2(918, 564, 330, 8), Color("4f1d42"))
	draw_rect(Rect2(926, 566, 314, 3), Color("ff9fc4"))
	_draw_text(Vector2(1026, 585), "STRAWBERRY OVERDRIVE", 11, Color("fff1f7"))
	_draw_heart(Vector2(1239, 574), 0.72, Color("ff77ac"))

	# Meter shell behind the real special ProgressBar.
	var meter_rect: Rect2 = Rect2(928, 613, 322, 30)
	_draw_pixel_frame(meter_rect, Color("1a0b1a"), Color("f579aa"), Color("fff1f7"), 2)
	for i: int in 10:
		var x: float = 940.0 + float(i) * 30.0
		draw_rect(Rect2(x, 619, 2, 18), Color(1.0, 0.89, 0.95, 0.15))

	# Hero button well. The actual Button is drawn over this.
	_draw_pixel_frame(Rect2(990, 644, 258, 54), Color("421a38"), Color("fa76a9"), Color("fff1f7"), 2)
	var ready_pulse: float = 0.18 + (sin(_time * 3.2) * 0.5 + 0.5) * 0.10
	draw_rect(Rect2(998, 650, 242, 3), Color(1.0, 0.80, 0.90, ready_pulse))
	_draw_spark(Vector2(889, 575), 7.0, Color("ffacd0"))
	_draw_spark(Vector2(1260, 545), 8.0, Color("fff0a3"))

	# Tiny bottom-left game-state anchor, like the resource/readout modules in the concept.
	_draw_pixel_frame(Rect2(10, 635, 188, 39), Color(0.10, 0.03, 0.09, 0.86), Color("ee78a7"), Color(1.0, 0.90, 0.95, 0.68), 2)
	draw_circle(Vector2(27, 654), 5.0, Color("ff78ad"))
	draw_circle(Vector2(27, 654), 2.2, Color("fff2f8"))
	_draw_text(Vector2(39, 659), "RAMPAGE STATUS", 10, Color("ffc1d8"))

func _draw_pixel_frame(rect: Rect2, fill: Color, edge: Color, outer: Color, thickness: int) -> void:
	var t: float = float(maxi(1, thickness))
	# hard offset shadow
	draw_rect(Rect2(rect.position + Vector2(5, 6), rect.size), Color(0.025, 0.002, 0.022, 0.58))
	# nested pixels
	draw_rect(rect, Color("31102d"))
	draw_rect(Rect2(rect.position + Vector2(t, t), rect.size - Vector2(t * 2.0, t * 2.0)), outer)
	draw_rect(Rect2(rect.position + Vector2(t + 2.0, t + 2.0), rect.size - Vector2((t + 2.0) * 2.0, (t + 2.0) * 2.0)), edge)
	draw_rect(Rect2(rect.position + Vector2(t + 4.0, t + 4.0), rect.size - Vector2((t + 4.0) * 2.0, (t + 4.0) * 2.0)), fill)
	# corner cuts, which are the important bit for the hand-pixel UI read.
	var cut: float = 6.0
	var bg: Color = Color(0.0, 0.0, 0.0, 0.0)
	# We cannot erase Canvas draw calls; repaint using the panel's surrounding dark shadow tone.
	var bite: Color = Color(0.035, 0.006, 0.032, 0.94)
	draw_rect(Rect2(rect.position, Vector2(cut, cut)), bite)
	draw_rect(Rect2(Vector2(rect.end.x - cut, rect.position.y), Vector2(cut, cut)), bite)
	draw_rect(Rect2(Vector2(rect.position.x, rect.end.y - cut), Vector2(cut, cut)), bite)
	draw_rect(Rect2(rect.end - Vector2(cut, cut), Vector2(cut, cut)), bite)

func _draw_bar_bay(rect: Rect2, accent: Color) -> void:
	draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size), Color(0.03, 0.005, 0.03, 0.48))
	draw_rect(rect, Color("fff1f7"))
	draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), Color("421630"))
	draw_rect(Rect2(rect.position + Vector2(4, 4), Vector2(rect.size.x - 8, 2)), Color(accent.r, accent.g, accent.b, 0.42))

func _draw_centered(texture: Texture2D, center: Vector2) -> void:
	if texture == null:
		return
	var s: Vector2 = texture.get_size()
	draw_texture(texture, center - s * 0.5)

func _draw_spark(center: Vector2, radius: float, color: Color) -> void:
	draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), color, 1.8, true)
	draw_line(center + Vector2(0, -radius), center + Vector2(0, radius), color, 1.8, true)
	draw_circle(center, 1.8, color)

func _draw_heart(center: Vector2, scale_value: float, color: Color) -> void:
	var r: float = 5.0 * scale_value
	draw_circle(center + Vector2(-4, -2) * scale_value, r, color)
	draw_circle(center + Vector2(4, -2) * scale_value, r, color)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8, 0) * scale_value,
		center + Vector2(8, 0) * scale_value,
		center + Vector2(0, 10) * scale_value
	]), color)

func _draw_ribbon(center: Vector2) -> void:
	var pink: Color = Color("ff7fae")
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22, -3), center + Vector2(-7, -7), center + Vector2(-7, 7), center + Vector2(-22, 3)
	]), pink.darkened(0.08))
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(22, -3), center + Vector2(7, -7), center + Vector2(7, 7), center + Vector2(22, 3)
	]), pink.darkened(0.08))
	draw_rect(Rect2(center + Vector2(-10, -6), Vector2(20, 12)), pink)
	draw_rect(Rect2(center + Vector2(-8, -4), Vector2(16, 2)), Color(1.0, 0.78, 0.88, 0.40))

func _draw_text(pos: Vector2, text: String, font_size: int, color: Color) -> void:
	if _font == null:
		return
	draw_string(_font, pos + Vector2(2, 2), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.06, 0.005, 0.05, color.a * 0.82))
	draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
