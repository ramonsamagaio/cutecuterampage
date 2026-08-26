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

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = -100
	_head = CutoutArtPart.make_small_texture("res://assets/Taffi/Cabeca.png", Vector2i(62, 56))
	_ear_l = CutoutArtPart.make_small_texture("res://assets/Taffi/Ore1.png", Vector2i(20, 43))
	_ear_r = CutoutArtPart.make_small_texture("res://assets/Taffi/Ore2.png", Vector2i(20, 43))
	_bow = CutoutArtPart.make_small_texture("res://assets/Taffi/Laco.png", Vector2i(30, 24))
	_weapon_icons = [
		CutoutArtPart.make_small_texture("res://assets/weapons/arma_heart.png", Vector2i(38, 27)),
		CutoutArtPart.make_small_texture("res://assets/weapons/arma_star.png", Vector2i(38, 27)),
		CutoutArtPart.make_small_texture("res://assets/weapons/ama_cupcake.png", Vector2i(38, 27)),
		CutoutArtPart.make_small_texture("res://assets/weapons/arma_arco.png", Vector2i(35, 31)),
		CutoutArtPart.make_small_texture("res://assets/fx/MorangoFull.png", Vector2i(28, 28))
	]
	_main_style = _make_style(Color("32172f"), Color("ff76ad"), 14, 4, Color(0.08, 0.03, 0.08, 0.48), 8)
	_portrait_style = _make_style(Color("fff0f6"), Color("ff8cba"), 12, 3, Color(0.08, 0.03, 0.08, 0.34), 5)
	_slot_style = _make_style(Color("35162f"), Color("f58ab6"), 10, 3, Color(0.06, 0.02, 0.06, 0.34), 5)
	_special_style = _make_style(Color("30152e"), Color("ff78b3"), 15, 4, Color(0.06, 0.02, 0.06, 0.46), 8)
	_pill_style = _make_style(Color(0.18, 0.07, 0.17, 0.90), Color("ff95be"), 18, 2, Color(0.04, 0.01, 0.04, 0.34), 4)
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
	style.shadow_offset = Vector2(0, 3)
	return style

func _draw() -> void:
	# Compact candy-console silhouette. The controls rendered by hud.gd sit over these.
	draw_style_box(_main_style, Rect2(14, 12, 360, 148))
	draw_style_box(_portrait_style, Rect2(22, 20, 78, 112))
	draw_rect(Rect2(108, 20, 250, 3), Color("ffc6dc"))
	draw_rect(Rect2(108, 151, 210, 3), Color(1.0, 0.46, 0.68, 0.24))

	# Portrait is assembled from the actual Taffi art, not a separate approximation.
	_draw_centered(_ear_l, Vector2(45, 48))
	_draw_centered(_ear_r, Vector2(72, 48))
	_draw_centered(_head, Vector2(61, 87))
	_draw_centered(_bow, Vector2(42, 65))

	# Loadout cards are intentionally separated from the stats block for cleaner hierarchy.
	for i: int in 5:
		var slot_pos: Vector2 = Vector2(18.0 + float(i) * 55.0, 170.0)
		draw_style_box(_slot_style, Rect2(slot_pos, Vector2(49, 49)))
		if i < _weapon_icons.size():
			_draw_centered(_weapon_icons[i], slot_pos + Vector2(24.5, 24.5))
		if i == 0:
			draw_rect(Rect2(slot_pos + Vector2(8, 43), Vector2(33, 3)), Color("ff6fa8"))

	# Combo and kill counters get small floating pills instead of large opaque boxes.
	draw_style_box(_pill_style, Rect2(493, 24, 294, 64))
	draw_style_box(_pill_style, Rect2(1096, 16, 156, 44))

	# Special area keeps the toy-console shape but uses more breathing room and hierarchy.
	draw_style_box(_special_style, Rect2(914, 566, 350, 140))
	draw_rect(Rect2(934, 584, 310, 4), Color("ffd0e2"))
	draw_rect(Rect2(934, 590, 160, 2), Color(1.0, 0.45, 0.70, 0.38))
	_draw_heart(Vector2(1237, 586), 0.82)
	_draw_spark(Vector2(898, 581), Color("ffacd0"))
	_draw_spark(Vector2(1262, 550), Color("fff0a3"))

func _draw_centered(texture: Texture2D, center: Vector2) -> void:
	if texture == null:
		return
	var s: Vector2 = texture.get_size()
	draw_texture(texture, center - s * 0.5)

func _draw_spark(center: Vector2, color: Color) -> void:
	draw_circle(center, 2.2, color)
	draw_line(center + Vector2(-7, 0), center + Vector2(7, 0), color, 2.0, true)
	draw_line(center + Vector2(0, -7), center + Vector2(0, 7), color, 2.0, true)

func _draw_heart(center: Vector2, alpha: float) -> void:
	var c: Color = Color(1.0, 0.42, 0.67, alpha)
	draw_circle(center + Vector2(-4, -2), 5.0, c)
	draw_circle(center + Vector2(4, -2), 5.0, c)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8, 0), center + Vector2(8, 0), center + Vector2(0, 10)
	]), c)
