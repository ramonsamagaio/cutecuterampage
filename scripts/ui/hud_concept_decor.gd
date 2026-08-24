class_name HUDConceptDecor
extends Control

var _head: Texture2D
var _ear_l: Texture2D
var _ear_r: Texture2D
var _bow: Texture2D
var _weapon_icons: Array[Texture2D] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = -100
	_head = CutoutArtPart.make_small_texture("res://assets/Taffi/Cabeca.png", Vector2i(58, 52))
	_ear_l = CutoutArtPart.make_small_texture("res://assets/Taffi/Ore1.png", Vector2i(18, 38))
	_ear_r = CutoutArtPart.make_small_texture("res://assets/Taffi/Ore2.png", Vector2i(18, 38))
	_bow = CutoutArtPart.make_small_texture("res://assets/Taffi/Laco.png", Vector2i(27, 21))
	_weapon_icons = [
		CutoutArtPart.make_small_texture("res://assets/weapons/arma_heart.png", Vector2i(34, 24)),
		CutoutArtPart.make_small_texture("res://assets/weapons/arma_star.png", Vector2i(34, 24)),
		CutoutArtPart.make_small_texture("res://assets/weapons/ama_cupcake.png", Vector2i(34, 24)),
		CutoutArtPart.make_small_texture("res://assets/weapons/arma_arco.png", Vector2i(32, 28)),
		CutoutArtPart.make_small_texture("res://assets/fx/MorangoFull.png", Vector2i(25, 25))
	]
	queue_redraw()

func _draw() -> void:
	# Chunky toy-like frame behind the existing functional HUD.
	_draw_panel(Rect2(12, 10, 362, 158), Color("2b1730"), Color("4a2442"), Color("ff70ad"))
	draw_rect(Rect2(18, 16, 268, 8), Color("ff9cc4"))

	# Character portrait, assembled from the actual Taffi art.
	_draw_panel(Rect2(292, 18, 72, 82), Color("26152d"), Color("f6b2cf"), Color("fff2f8"))
	_draw_centered(_ear_l, Vector2(315, 39))
	_draw_centered(_ear_r, Vector2(342, 39))
	_draw_centered(_head, Vector2(329, 66))
	_draw_centered(_bow, Vector2(309, 48))

	# Five tactile equipment slots, like the concept's loadout strip.
	for i: int in 5:
		var slot_pos: Vector2 = Vector2(20.0 + float(i) * 52.0, 176.0)
		_draw_panel(Rect2(slot_pos, Vector2(46, 46)), Color("28172e"), Color("48213e"), Color("f58bb5"))
		if i < _weapon_icons.size():
			_draw_centered(_weapon_icons[i], slot_pos + Vector2(23, 23))

	# Special/Rampage area gets a strong candy-console silhouette.
	_draw_panel(Rect2(925, 566, 337, 140), Color("28162e"), Color("45203d"), Color("ff78b3"))
	draw_rect(Rect2(942, 584, 303, 6), Color("ffc1da"))
	_draw_bone_cap(Vector2(939, 617))
	_draw_bone_cap(Vector2(1248, 617))

	# Small corner bolts/sparkles keep the HUD playful without adding text clutter.
	_draw_spark(Vector2(382, 28), Color("fff2a8"))
	_draw_spark(Vector2(906, 582), Color("ff9fc8"))
	_draw_spark(Vector2(1264, 550), Color("fff2a8"))

func _draw_panel(rect: Rect2, outline: Color, fill: Color, accent: Color) -> void:
	draw_rect(rect, outline)
	draw_rect(rect.grow(-4.0), fill)
	draw_rect(Rect2(rect.position + Vector2(5, 5), Vector2(rect.size.x - 10, 3)), accent)

func _draw_centered(texture: Texture2D, center: Vector2) -> void:
	if texture == null:
		return
	var s: Vector2 = texture.get_size()
	draw_texture(texture, center - s * 0.5)

func _draw_bone_cap(center: Vector2) -> void:
	var c: Color = Color("ffe4ef")
	draw_rect(Rect2(center + Vector2(-10, -3), Vector2(20, 6)), c)
	draw_circle(center + Vector2(-10, -5), 5.0, c)
	draw_circle(center + Vector2(-10, 5), 5.0, c)
	draw_circle(center + Vector2(10, -5), 5.0, c)
	draw_circle(center + Vector2(10, 5), 5.0, c)

func _draw_spark(center: Vector2, color: Color) -> void:
	draw_rect(Rect2(center + Vector2(-6, -1), Vector2(12, 2)), color)
	draw_rect(Rect2(center + Vector2(-1, -6), Vector2(2, 12)), color)
