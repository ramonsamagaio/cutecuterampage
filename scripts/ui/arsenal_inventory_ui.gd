class_name ArsenalInventoryUI
extends Control

const SLOT_W: float = 88.0
const SLOT_H: float = 31.0
const SLOT_GAP: float = 3.0
const COMPACT_X: float = 308.0
const COMPACT_Y: float = 618.0

var _arsenal: ArsenalController
var _detail_open: bool = false
var _redraw_tick: float = 0.0
var _font: Font
var _time: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_font = ThemeDB.fallback_font
	call_deferred("_bind_arsenal")

func _bind_arsenal() -> void:
	_arsenal = get_tree().get_first_node_in_group("arsenal") as ArsenalController
	if is_instance_valid(_arsenal) and not _arsenal.loadout_changed.is_connected(_on_loadout_changed):
		_arsenal.loadout_changed.connect(_on_loadout_changed)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_I or event.keycode == KEY_TAB):
		_detail_open = not _detail_open
		queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	if not is_instance_valid(_arsenal):
		_bind_arsenal()
		return
	_redraw_tick -= delta
	if _redraw_tick <= 0.0:
		_redraw_tick = 0.16 if _detail_open else 0.24
		queue_redraw()

func _on_loadout_changed() -> void:
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(_arsenal):
		return
	_draw_compact_strip()
	if _detail_open:
		_draw_detail_panel()

func _ordered_keys(dict: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for key: Variant in dict.keys():
		out.append(String(key))
	return out

func _draw_compact_strip() -> void:
	var weapons: Array[String] = _ordered_keys(_arsenal.weapons)
	var charms: Array[String] = _ordered_keys(_arsenal.passives)
	var panel: Rect2 = Rect2(COMPACT_X - 74, COMPACT_Y - 30, 636, 99)
	_draw_pixel_panel(panel, Color(0.085, 0.025, 0.08, 0.90), Color("ff8fbd"), Color("fff0f7"), 3)

	var pulse: float = 0.58 + sin(_time * 3.0) * 0.22
	_draw_text(Vector2(COMPACT_X - 58, COMPACT_Y - 12), "WEAPONS", 10, Color("ff8fbd"))
	_draw_text(Vector2(COMPACT_X - 58, COMPACT_Y + 23), "CHARMS", 10, Color("c8a5ff"))
	_draw_text(Vector2(COMPACT_X + 414, COMPACT_Y - 14), "[I / TAB] ARSENAL", 10, Color(1.0, 0.78, 0.90, 0.68 + pulse * 0.24))

	for i: int in ArsenalCatalog.MAX_WEAPON_SLOTS:
		var pos: Vector2 = Vector2(COMPACT_X + float(i) * (SLOT_W + SLOT_GAP), COMPACT_Y)
		var occupied: bool = i < weapons.size()
		_draw_compact_slot(Rect2(pos, Vector2(SLOT_W, SLOT_H)), true, occupied)
		if occupied:
			_draw_compact_item(weapons[i], pos, true)
		else:
			_draw_empty_slot_number(pos, i + 1)

	for i: int in ArsenalCatalog.MAX_PASSIVE_SLOTS:
		var pos: Vector2 = Vector2(COMPACT_X + float(i) * (SLOT_W + SLOT_GAP), COMPACT_Y + 35.0)
		var occupied: bool = i < charms.size()
		_draw_compact_slot(Rect2(pos, Vector2(SLOT_W, SLOT_H)), false, occupied)
		if occupied:
			_draw_compact_item(charms[i], pos, false)
		else:
			_draw_empty_slot_number(pos, i + 1)

func _draw_compact_slot(rect: Rect2, weapon: bool, occupied: bool) -> void:
	var fill: Color = Color("32152d") if weapon else Color("21152f")
	var edge: Color = Color("f36fa3") if weapon else Color("9f80e8")
	if not occupied:
		fill.a = 0.55
		edge.a = 0.30
	# Chunky 1px/2px nested borders read much closer to authored pixel UI than runtime rounded boxes.
	draw_rect(Rect2(rect.position + Vector2(2, 3), rect.size), Color(0.03, 0.005, 0.025, 0.55))
	draw_rect(rect, Color("30102b"))
	draw_rect(Rect2(rect.position + Vector2(1, 1), rect.size - Vector2(2, 2)), Color("fff1f7"))
	draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), edge)
	draw_rect(Rect2(rect.position + Vector2(5, 5), rect.size - Vector2(10, 10)), fill)
	# Pixel-cut corners.
	draw_rect(Rect2(rect.position, Vector2(4, 4)), Color(0.085, 0.025, 0.08, 0.90))
	draw_rect(Rect2(rect.end - Vector2(4, 4), Vector2(4, 4)), Color(0.085, 0.025, 0.08, 0.90))

func _draw_compact_item(id: String, pos: Vector2, weapon: bool) -> void:
	var data: Dictionary = ArsenalCatalog.get_weapon(id) if weapon else ArsenalCatalog.get_passive(id)
	var level_value: int = int(_arsenal.weapons.get(id, 0)) if weapon else int(_arsenal.passives.get(id, 0))
	var evolved: bool = weapon and bool(_arsenal.evolved.get(id, false))
	var icon_center: Vector2 = pos + Vector2(17, 15.5)
	_draw_item_icon(id, icon_center, weapon, evolved)
	var name_text: String = String(data.get("name", id)).to_upper()
	if name_text.length() > 9:
		name_text = name_text.left(9)
	_draw_text(pos + Vector2(31, 13), name_text, 8, Color("fff3f8") if not evolved else Color("fff0a3"))
	_draw_text(pos + Vector2(31, 24), "LV %d" % level_value, 8, Color("ff90b8") if weapon else Color("c5a9ff"))
	if evolved:
		_draw_spark(pos + Vector2(80, 8), 3.0, Color("fff0a3"))

func _draw_empty_slot_number(pos: Vector2, number: int) -> void:
	_draw_text(pos + Vector2(39, 20), str(number), 9, Color(1.0, 0.85, 0.92, 0.25))

func _draw_detail_panel() -> void:
	var rect: Rect2 = Rect2(244, 100, 792, 500)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.005, 0.03, 0.42))
	_draw_pixel_panel(rect, Color(0.06, 0.015, 0.06, 0.975), Color("ff78ac"), Color("fff3f8"), 5)

	# Header with exaggerated arcade title treatment.
	_draw_text(Vector2(278, 144), "CUTE CUTE ARSENAL", 27, Color("fff3f8"), 3)
	_draw_text(Vector2(280, 166), "BUILD YOUR PERFECT LITTLE DISASTER ♡", 11, Color("ff9bc2"))
	_draw_text(Vector2(876, 140), "[I / TAB] CLOSE", 11, Color("ffd0e2"))

	var weapon_header: Rect2 = Rect2(276, 190, 350, 34)
	var charm_header: Rect2 = Rect2(654, 190, 350, 34)
	_draw_pixel_panel(weapon_header, Color("3d1734"), Color("ff71a4"), Color("fff1f7"), 2)
	_draw_pixel_panel(charm_header, Color("261a43"), Color("a888ef"), Color("f2ebff"), 2)
	_draw_text(Vector2(292, 213), "♡ WEAPONS  6 SLOTS", 14, Color("ff9bc3"))
	_draw_text(Vector2(670, 213), "✦ CHARMS  6 SLOTS", 14, Color("c9b4ff"))

	var weapon_ids: Array[String] = _ordered_keys(_arsenal.weapons)
	var charm_ids: Array[String] = _ordered_keys(_arsenal.passives)
	for i: int in ArsenalCatalog.MAX_WEAPON_SLOTS:
		_draw_detail_row(Vector2(276, 236 + float(i) * 55.0), i, weapon_ids, true)
	for i: int in ArsenalCatalog.MAX_PASSIVE_SLOTS:
		_draw_detail_row(Vector2(654, 236 + float(i) * 55.0), i, charm_ids, false)

	_draw_text(Vector2(278, 581), "EVOLUTION: WEAPON LV 8 + MATCHING CHARM + BOX  ♡   PICNIC PICKUPS MAY EXCEED CHARM LIMIT LATER", 10, Color(1.0, 0.78, 0.88, 0.78))

func _draw_detail_row(pos: Vector2, index: int, ids: Array[String], weapon: bool) -> void:
	var occupied: bool = index < ids.size()
	var row_rect: Rect2 = Rect2(pos, Vector2(350, 48))
	var fill: Color = Color(0.20, 0.065, 0.17, 0.92) if weapon else Color(0.12, 0.08, 0.20, 0.92)
	var edge: Color = Color("ef76a4") if weapon else Color("a285ec")
	if not occupied:
		fill.a = 0.32
		edge.a = 0.18
	_draw_pixel_panel(row_rect, fill, edge, Color(1.0, 0.90, 0.95, 0.52), 2)
	if not occupied:
		_draw_text(pos + Vector2(157, 29), "EMPTY %d" % (index + 1), 10, Color(1.0, 0.86, 0.92, 0.24))
		return

	var id: String = ids[index]
	var data: Dictionary = ArsenalCatalog.get_weapon(id) if weapon else ArsenalCatalog.get_passive(id)
	var level_value: int = int(_arsenal.weapons.get(id, 0)) if weapon else int(_arsenal.passives.get(id, 0))
	var evolved: bool = weapon and bool(_arsenal.evolved.get(id, false))
	_draw_item_icon(id, pos + Vector2(27, 24), weapon, evolved, 1.35)
	var display_name: String = String(data.get("evolution", "")) if evolved else String(data.get("name", id))
	_draw_text(pos + Vector2(54, 18), display_name.to_upper(), 11, Color("fff1f7") if not evolved else Color("fff0a1"))
	_draw_level_pips(pos + Vector2(54, 24), level_value, ArsenalCatalog.MAX_WEAPON_LEVEL if weapon else ArsenalCatalog.MAX_PASSIVE_LEVEL, Color("ff6fa7") if weapon else Color("aa89ef"))
	if weapon:
		var passive_id: String = String(data.get("passive", ""))
		var passive_data: Dictionary = ArsenalCatalog.get_passive(passive_id)
		var hint: String = "EVOLVE + %s" % String(passive_data.get("name", passive_id)).to_upper()
		_draw_text(pos + Vector2(54, 43), hint, 8, Color(1.0, 0.67, 0.81, 0.70))
	else:
		var desc: String = String(data.get("description", ""))
		if desc.length() > 38:
			desc = desc.left(38) + "…"
		_draw_text(pos + Vector2(54, 43), desc, 8, Color(0.88, 0.82, 0.95, 0.68))

func _draw_pixel_panel(rect: Rect2, fill: Color, edge: Color, outer: Color, border: int) -> void:
	var b: float = float(maxi(1, border))
	draw_rect(Rect2(rect.position + Vector2(5, 6), rect.size), Color(0.02, 0.003, 0.02, 0.58))
	draw_rect(rect, Color("2a0d27"))
	draw_rect(Rect2(rect.position + Vector2(b, b), rect.size - Vector2(b * 2.0, b * 2.0)), outer)
	draw_rect(Rect2(rect.position + Vector2(b + 2.0, b + 2.0), rect.size - Vector2((b + 2.0) * 2.0, (b + 2.0) * 2.0)), edge)
	draw_rect(Rect2(rect.position + Vector2(b + 4.0, b + 4.0), rect.size - Vector2((b + 4.0) * 2.0, (b + 4.0) * 2.0)), fill)
	# Square corner bites make the frame feel hand-pixeled.
	var bite: Vector2 = Vector2(6, 6)
	draw_rect(Rect2(rect.position, bite), Color(0.03, 0.005, 0.03, 0.95))
	draw_rect(Rect2(Vector2(rect.end.x - bite.x, rect.position.y), bite), Color(0.03, 0.005, 0.03, 0.95))
	draw_rect(Rect2(Vector2(rect.position.x, rect.end.y - bite.y), bite), Color(0.03, 0.005, 0.03, 0.95))
	draw_rect(Rect2(rect.end - bite, bite), Color(0.03, 0.005, 0.03, 0.95))

func _draw_text(pos: Vector2, text: String, font_size: int, color: Color, shadow: int = 1) -> void:
	if _font == null:
		return
	if shadow > 0:
		draw_string(_font, pos + Vector2(float(shadow), float(shadow)), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.05, 0.005, 0.04, color.a * 0.82))
	draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw_level_pips(origin: Vector2, value: int, maximum: int, color: Color) -> void:
	for i: int in maximum:
		var c: Color = color if i < value else Color(color.r, color.g, color.b, 0.16)
		draw_rect(Rect2(origin + Vector2(float(i) * 14.0, 0), Vector2(10, 4)), c)

func _draw_item_icon(id: String, center: Vector2, weapon: bool, evolved: bool, scale_value: float = 1.0) -> void:
	var pink: Color = Color("ff72aa") if not evolved else Color("fff09b")
	var pale: Color = Color("fff1f7")
	var purple: Color = Color("b49aff")
	var dark: Color = Color("35102e")
	var s: float = scale_value
	var p: Vector2 = center

	if not weapon:
		match id:
			"strawberry_core":
				_draw_heart_icon(p, 6.0 * s, pink)
				draw_circle(p + Vector2(0, -5) * s, 1.4 * s, Color("77ba62"))
			"sugar_rush":
				_draw_bolt(p, s, Color("fff09b"))
			"bigger_bow", "lucky_ribbon":
				_draw_bow(p, s, pink)
			"extra_sprinkles":
				for i: int in 6:
					var a: float = TAU * float(i) / 6.0
					draw_circle(p + Vector2.RIGHT.rotated(a) * 6.0 * s, 1.5 * s, pink if i % 2 == 0 else purple)
			"fast_delivery":
				draw_line(p + Vector2(-7, -3) * s, p + Vector2(6, -3) * s, pale, 2.0 * s)
				draw_line(p + Vector2(-7, 3) * s, p + Vector2(6, 3) * s, pale, 2.0 * s)
				draw_colored_polygon(PackedVector2Array([p + Vector2(6, -6) * s, p + Vector2(11, 0) * s, p + Vector2(6, 6) * s]), pink)
			"long_lasting_love":
				draw_arc(p + Vector2(-4, 0) * s, 4.0 * s, 0.4, TAU - 0.4, 12, pink, 2.0 * s)
				draw_arc(p + Vector2(4, 0) * s, 4.0 * s, PI + 0.4, PI * 3.0 - 0.4, 12, pink, 2.0 * s)
			"bubblegum_shoes":
				draw_rect(Rect2(p + Vector2(-8, 0) * s, Vector2(12, 5) * s), pink)
				draw_rect(Rect2(p + Vector2(1, -5) * s, Vector2(5, 8) * s), pale)
			"plush_armor":
				var shield: PackedVector2Array = PackedVector2Array([p + Vector2(-7, -7) * s, p + Vector2(7, -7) * s, p + Vector2(6, 3) * s, p + Vector2(0, 9) * s, p + Vector2(-6, 3) * s])
				draw_colored_polygon(shield, purple)
				_draw_heart_icon(p + Vector2(0, -1) * s, 3.0 * s, pale)
			"honey_heart":
				_draw_heart_icon(p, 6.0 * s, Color("ffc85c"))
				for i: int in 3:
					draw_circle(p + Vector2(float(i - 1) * 4.0, 0) * s, 1.0 * s, dark)
			"charm_bracelet":
				draw_arc(p, 8.0 * s, 0.0, TAU, 18, purple, 2.5 * s)
				for i: int in 4:
					var a: float = TAU * float(i) / 4.0
					draw_circle(p + Vector2.RIGHT.rotated(a) * 8.0 * s, 2.2 * s, pink)
			_:
				draw_circle(p, 7.0 * s, purple)
				_draw_spark(p, 4.0 * s, pale)
		return

	match id:
		"heart_blaster":
			_draw_heart_icon(p, 7.0 * s, pink)
			draw_rect(Rect2(p + Vector2(5, -2) * s, Vector2(8, 4) * s), pale)
		"ribbon_ripper":
			draw_line(p + Vector2(-9, 7) * s, p + Vector2(9, -7) * s, pink, 4.0 * s)
			draw_line(p + Vector2(-8, 4) * s, p + Vector2(8, -10) * s, pale, 1.4 * s)
		"kawaii_chainsaw":
			draw_rect(Rect2(p + Vector2(-9, -4) * s, Vector2(15, 8) * s), pink)
			for i: int in 5:
				var x: float = -8.0 + float(i) * 3.5
				draw_colored_polygon(PackedVector2Array([p + Vector2(x, 4) * s, p + Vector2(x + 2, 8) * s, p + Vector2(x + 3, 4) * s]), pale)
			draw_rect(Rect2(p + Vector2(5, -2) * s, Vector2(7, 4) * s), dark)
		"sugar_crash":
			draw_arc(p, 9.0 * s, 0.0, TAU, 20, pink, 2.5 * s)
			draw_arc(p, 4.0 * s, 0.0, TAU, 16, pale, 2.0 * s)
		"strawberry_rain":
			for i: int in 3:
				var q: Vector2 = p + Vector2(float(i - 1) * 6.0, float((i % 2) * 4 - 3)) * s
				draw_circle(q, 3.3 * s, pink)
				draw_line(q + Vector2(0, -3) * s, q + Vector2(1, -6) * s, Color("75b766"), 1.5 * s)
		"bunny_boomerang":
			draw_arc(p, 8.0 * s, -1.2, 1.2, 12, pink, 4.0 * s)
			draw_line(p + Vector2(2, -7) * s, p + Vector2(-3, -10) * s, pale, 2.0 * s)
		"bubblegum_minefield":
			for q: Vector2 in [Vector2(-5, 2), Vector2(3, 4), Vector2(1, -4)]:
				draw_circle(p + q * s, 4.5 * s, pink)
				draw_circle(p + q * s + Vector2(-1, -1) * s, 1.2 * s, pale)
		"lollipop_guillotine":
			draw_circle(p + Vector2(0, -3) * s, 6.0 * s, pink)
			draw_arc(p + Vector2(0, -3) * s, 3.8 * s, 0.0, TAU * 0.8, 14, pale, 1.5 * s)
			draw_line(p + Vector2(3, 3) * s, p + Vector2(9, 10) * s, pale, 2.0 * s)
		"teddy_drop":
			draw_circle(p + Vector2(-5, -5) * s, 3.5 * s, pink)
			draw_circle(p + Vector2(5, -5) * s, 3.5 * s, pink)
			draw_circle(p, 7.0 * s, Color("d99b79"))
			draw_circle(p + Vector2(-2, -1) * s, 1.0 * s, dark)
			draw_circle(p + Vector2(2, -1) * s, 1.0 * s, dark)
		"friendship_laser":
			draw_line(p + Vector2(-10, 0) * s, p + Vector2(11, 0) * s, pink, 6.0 * s)
			draw_line(p + Vector2(-8, 0) * s, p + Vector2(11, 0) * s, pale, 2.0 * s)
			_draw_spark(p + Vector2(9, 0) * s, 4.0 * s, pale)
		"star_tantrum":
			_draw_star(p, 8.0 * s, 3.5 * s, Color("ffd967"))
		"cupcake_mortar":
			draw_rect(Rect2(p + Vector2(-6, 1) * s, Vector2(12, 7) * s), Color("ffb1cc"))
			draw_circle(p + Vector2(0, -2) * s, 7.0 * s, pale)
			draw_circle(p + Vector2(2, -7) * s, 2.0 * s, pink)
		"love_orbit":
			draw_arc(p, 9.0 * s, 0.0, TAU, 20, purple, 1.5 * s)
			_draw_heart_icon(p + Vector2(8, 0) * s, 3.2 * s, pink)
			_draw_heart_icon(p + Vector2(-8, 0) * s, 3.2 * s, pink)
		_:
			_draw_star(p, 7.0 * s, 3.2 * s, pink)

func _draw_heart_icon(p: Vector2, radius: float, color: Color) -> void:
	var r: float = radius * 0.56
	draw_circle(p + Vector2(-r * 0.72, -r * 0.30), r, color)
	draw_circle(p + Vector2(r * 0.72, -r * 0.30), r, color)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-radius, -radius * 0.05), p + Vector2(radius, -radius * 0.05), p + Vector2(0, radius)]), color)

func _draw_bow(p: Vector2, s: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([p + Vector2(-2, 0) * s, p + Vector2(-10, -6) * s, p + Vector2(-9, 6) * s]), color)
	draw_colored_polygon(PackedVector2Array([p + Vector2(2, 0) * s, p + Vector2(10, -6) * s, p + Vector2(9, 6) * s]), color)
	draw_circle(p, 3.2 * s, Color("fff1f7"))

func _draw_bolt(p: Vector2, s: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([p + Vector2(-2, -10) * s, p + Vector2(6, -10) * s, p + Vector2(2, -2) * s, p + Vector2(8, -2) * s, p + Vector2(-5, 11) * s, p + Vector2(-1, 2) * s, p + Vector2(-7, 2) * s]), color)

func _draw_star(p: Vector2, outer: float, inner: float, color: Color) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in 10:
		var a: float = -PI * 0.5 + float(i) * PI / 5.0
		var r: float = outer if i % 2 == 0 else inner
		pts.append(p + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, color)

func _draw_spark(p: Vector2, radius: float, color: Color) -> void:
	draw_line(p + Vector2(-radius, 0), p + Vector2(radius, 0), color, 1.5)
	draw_line(p + Vector2(0, -radius), p + Vector2(0, radius), color, 1.5)
