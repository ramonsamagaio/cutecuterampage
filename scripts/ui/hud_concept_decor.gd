class_name HUDConceptDecor
extends Control

var _head: Texture2D
var _ear_l: Texture2D
var _ear_r: Texture2D
var _bow: Texture2D
var _weapon_icons: Array[Texture2D] = []
var _main_style: StyleBoxFlat
var _portrait_style: StyleBoxFlat
var _slot_style: StyleBoxFlat
var _special_style: StyleBoxFlat
var _pill_style: StyleBoxFlat
var _badge_style: StyleBoxFlat

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = -100
	_head = CutoutArtPart.make_small_texture("res://assets/Taffi/Cabeca.png", Vector2i(66, 60))
	_ear_l = CutoutArtPart.make_small_texture("res://assets/Taffi/Ore1.png", Vector2i(21, 45))
	_ear_r = CutoutArtPart.make_small_texture("res://assets/Taffi/Ore2.png", Vector2i(21, 45))
	_bow = CutoutArtPart.make_small_texture("res://assets/Taffi/Laco.png", Vector2i(31, 25))
	_weapon_icons = [
		CutoutArtPart.make_small_texture("res://assets/weapons/arma_heart.png", Vector2i(40, 29)),
		CutoutArtPart.make_small_texture("res://assets/weapons/arma_star.png", Vector2i(40, 29)),
		CutoutArtPart.make_small_texture("res://assets/weapons/ama_cupcake.png", Vector2i(40, 29)),
		CutoutArtPart.make_small_texture("res://assets/weapons/arma_arco.png", Vector2i(37, 33)),
		CutoutArtPart.make_small_texture("res://assets/fx/MorangoFull.png", Vector2i(30, 30))
	]
	_main_style = _make_style(Color("2c142b"), Color("ff6fa8"), 16, 4, Color(0.05, 0.01, 0.05, 0.55), 10)
	_portrait_style = _make_style(Color("fff1f6"), Color("ff91bd"), 14, 3, Color(0.08, 0.03, 0.08, 0.34), 6)
	_slot_style = _make_style(Color("30142d"), Color("ef80ad"), 11, 3, Color(0.06, 0.02, 0.06, 0.36), 5)
	_special_style = _make_style(Color("2b132b"), Color("ff72ae"), 17, 4, Color(0.05, 0.01, 0.05, 0.52), 10)
	_pill_style = _make_style(Color(0.15, 0.05, 0.15, 0.88), Color("ff9cc4"), 20, 2, Color(0.04, 0.01, 0.04, 0.34), 5)
	_badge_style = _make_style(Color("5b2448"), Color("ffc1da"), 10, 2, Color(0.04, 0.01, 0.04, 0.24), 3)
	queue_redraw()

func _make_style(bg: Color, border: Color, radius: int, border_width: int, shadow: Color, shadow_size: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = shadow
	style.shadow_size = shadow_size
	style.shadow_offset = Vector2(0, 4)
	return style

func _draw() -> void:
	# Stats console. Layered highlights make it read like a physical candy toy instead of a flat rectangle.
	draw_style_box(_main_style, Rect2(14, 12, 360, 148))
	draw_rect(Rect2(27, 20, 332, 3), Color("ffd2e4"))
	draw_rect(Rect2(28, 25, 328, 1), Color(1.0, 0.65, 0.80, 0.20))
	draw_arc(Vector2(355, 30), 8.0, PI, PI * 1.52, 10, Color(1.0, 0.72, 0.85, 0.40), 2.0, true)

	# Portrait frame is intentionally creamy/bright, giving Taffi a strong focal anchor.
	draw_style_box(_portrait_style, Rect2(22, 20, 78, 112))
	draw_circle(Vector2(61, 84), 31.0, Color(1.0, 0.68, 0.82, 0.10))
	_draw_centered(_ear_l, Vector2(45, 47))
	_draw_centered(_ear_r, Vector2(73, 47))
	_draw_centered(_head, Vector2(62, 87))
	_draw_centered(_bow, Vector2(42, 64))
	_draw_ribbon(Vector2(61, 127))

	# Fine separators align the functional bars without boxing every line of information.
	draw_rect(Rect2(108, 51, 246, 1), Color(1.0, 0.56, 0.73, 0.18))
	draw_rect(Rect2(108, 69, 246, 1), Color(1.0, 0.56, 0.73, 0.13))
	draw_rect(Rect2(108, 86, 246, 1), Color(1.0, 0.56, 0.73, 0.10))
	for i: int in 8:
		var x: float = 112.0 + float(i) * 30.0
		draw_rect(Rect2(x, 77, 1, 5), Color(1.0, 0.78, 0.88, 0.18))

	# Loadout strip, with a tiny status light under each card and a selected-slot glow.
	for i: int in 5:
		var slot_pos: Vector2 = Vector2(18.0 + float(i) * 55.0, 170.0)
		draw_style_box(_slot_style, Rect2(slot_pos, Vector2(49, 49)))
		draw_rect(Rect2(slot_pos + Vector2(7, 5), Vector2(35, 2)), Color(1.0, 0.72, 0.84, 0.22))
		if i < _weapon_icons.size():
			_draw_centered(_weapon_icons[i], slot_pos + Vector2(24.5, 24.5))
		var led: Color = Color("ff78ad") if i == 0 else Color(0.98, 0.68, 0.80, 0.24)
		draw_circle(slot_pos + Vector2(24.5, 45.0), 2.1, led)
		if i == 0:
			draw_arc(slot_pos + Vector2(24.5, 24.5), 20.0, 0.2, PI * 1.8, 18, Color(1.35, 0.42, 0.78, 0.28), 2.0, true)

	# Combo and kill counters float like enamel badges.
	draw_style_box(_pill_style, Rect2(493, 24, 294, 64))
	draw_rect(Rect2(510, 31, 260, 2), Color(1.0, 0.72, 0.84, 0.20))
	_draw_spark(Vector2(509, 55), Color("ff9fc7"), 5.0)
	_draw_spark(Vector2(771, 55), Color("fff0a3"), 4.0)
	draw_style_box(_pill_style, Rect2(1096, 16, 156, 44))
	_draw_heart(Vector2(1114, 38), 0.72, 0.70)

	# Special console is deliberately oversized and toy-like. Meter ticks make charge progress easier to parse.
	draw_style_box(_special_style, Rect2(914, 566, 350, 140))
	draw_rect(Rect2(934, 582, 310, 4), Color("ffd0e2"))
	draw_rect(Rect2(934, 589, 190, 2), Color(1.0, 0.45, 0.70, 0.34))
	for i: int in 10:
		var x: float = 940.0 + float(i) * 30.0
		draw_rect(Rect2(x, 619, 2, 17), Color(1.0, 0.82, 0.90, 0.15))
	_draw_heart(Vector2(1237, 585), 0.86, 0.95)
	_draw_spark(Vector2(898, 581), Color("ffacd0"), 7.0)
	_draw_spark(Vector2(1262, 550), Color("fff0a3"), 7.0)

	# Small enamel badge under the loadout gives the lower-left information a designed anchor.
	draw_style_box(_badge_style, Rect2(18, 636, 188, 31))
	draw_circle(Vector2(32, 651), 4.5, Color("ff78ad"))
	draw_circle(Vector2(32, 651), 2.0, Color("fff2f8"))

func _draw_centered(texture: Texture2D, center: Vector2) -> void:
	if texture == null:
		return
	var s: Vector2 = texture.get_size()
	draw_texture(texture, center - s * 0.5)

func _draw_spark(center: Vector2, color: Color, radius: float = 7.0) -> void:
	draw_circle(center, 1.8, color)
	draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), color, 1.8, true)
	draw_line(center + Vector2(0, -radius), center + Vector2(0, radius), color, 1.8, true)

func _draw_heart(center: Vector2, size_scale: float, alpha: float) -> void:
	var c: Color = Color(1.0, 0.42, 0.67, alpha)
	var r: float = 5.0 * size_scale
	draw_circle(center + Vector2(-4, -2) * size_scale, r, c)
	draw_circle(center + Vector2(4, -2) * size_scale, r, c)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8, 0) * size_scale,
		center + Vector2(8, 0) * size_scale,
		center + Vector2(0, 10) * size_scale
	]), c)

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
