class_name ArsenalInventoryUI
extends Control

var _arsenal: ArsenalController
var _detail_open: bool = false
var _redraw_tick: float = 0.0
var _font: Font
var _panel_style: StyleBoxFlat
var _detail_style: StyleBoxFlat
var _weapon_style: StyleBoxFlat
var _weapon_empty_style: StyleBoxFlat
var _passive_style: StyleBoxFlat
var _passive_empty_style: StyleBoxFlat

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_font = ThemeDB.fallback_font
	_panel_style = _make_style(Color(0.12, 0.045, 0.12, 0.88), Color(1.0, 0.47, 0.69, 0.48), 12, 2)
	_detail_style = _make_style(Color(0.075, 0.025, 0.075, 0.965), Color(1.0, 0.50, 0.72, 0.88), 20, 3)
	_weapon_style = _make_style(Color(0.20, 0.07, 0.18, 0.94), Color(1.0, 0.46, 0.69, 0.70), 7, 2)
	_weapon_empty_style = _make_style(Color(0.20, 0.07, 0.18, 0.42), Color(1.0, 0.46, 0.69, 0.24), 7, 2)
	_passive_style = _make_style(Color(0.13, 0.08, 0.22, 0.94), Color(0.73, 0.58, 1.0, 0.70), 7, 2)
	_passive_empty_style = _make_style(Color(0.13, 0.08, 0.22, 0.42), Color(0.73, 0.58, 1.0, 0.24), 7, 2)
	call_deferred("_bind_arsenal")

func _make_style(fill: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	return style

func _bind_arsenal() -> void:
	_arsenal = get_tree().get_first_node_in_group("arsenal") as ArsenalController
	if is_instance_valid(_arsenal) and not _arsenal.loadout_changed.is_connected(_on_loadout_changed):
		_arsenal.loadout_changed.connect(_on_loadout_changed)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_I:
		_detail_open = not _detail_open
		queue_redraw()

func _process(delta: float) -> void:
	if not is_instance_valid(_arsenal):
		_bind_arsenal()
		return
	_redraw_tick -= delta
	if _redraw_tick <= 0.0:
		_redraw_tick = 0.20
		queue_redraw()

func _on_loadout_changed() -> void:
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(_arsenal):
		return
	_draw_compact_strip()
	if _detail_open:
		_draw_detail_panel()

func _draw_compact_strip() -> void:
	var base: Vector2 = Vector2(338, 645)
	var panel_rect: Rect2 = Rect2(base + Vector2(-12, -10), Vector2(556, 72))
	draw_style_box(_panel_style, panel_rect)
	draw_string(_font, base + Vector2(0, -15), "ARSENAL   [I] DETAILS", HORIZONTAL_ALIGNMENT_LEFT, 240, 12, Color(1.0, 0.78, 0.88, 0.88))

	var weapon_ids: Array[String] = []
	for key: Variant in _arsenal.weapons.keys():
		weapon_ids.append(String(key))
	var passive_ids: Array[String] = []
	for key: Variant in _arsenal.passives.keys():
		passive_ids.append(String(key))

	for i: int in ArsenalCatalog.MAX_WEAPON_SLOTS:
		var pos: Vector2 = base + Vector2(float(i) * 44.0, 0)
		var occupied: bool = i < weapon_ids.size()
		draw_style_box(_weapon_style if occupied else _weapon_empty_style, Rect2(pos, Vector2(38, 29)))
		if occupied:
			var id: String = weapon_ids[i]
			var data: Dictionary = ArsenalCatalog.get_weapon(id)
			var is_evolved: bool = bool(_arsenal.evolved.get(id, false))
			_draw_slot_text(pos, String(data.get("short", "?")), int(_arsenal.weapons[id]), is_evolved)
		else:
			draw_string(_font, pos + Vector2(13, 20), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, 20, 10, Color(1.0, 0.88, 0.94, 0.28))

	for i: int in ArsenalCatalog.MAX_PASSIVE_SLOTS:
		var pos: Vector2 = base + Vector2(float(i) * 44.0 + 276.0, 0)
		var occupied: bool = i < passive_ids.size()
		draw_style_box(_passive_style if occupied else _passive_empty_style, Rect2(pos, Vector2(38, 29)))
		if occupied:
			var id: String = passive_ids[i]
			var data: Dictionary = ArsenalCatalog.get_passive(id)
			_draw_slot_text(pos, String(data.get("short", "?")), int(_arsenal.passives[id]), false)
		else:
			draw_string(_font, pos + Vector2(13, 20), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, 20, 10, Color(0.86, 0.80, 1.0, 0.25))

func _draw_slot_text(pos: Vector2, short_name: String, level_value: int, is_evolved: bool) -> void:
	var main_color: Color = Color(1.0, 0.88, 0.95, 1.0) if not is_evolved else Color(1.0, 0.90, 0.42, 1.0)
	draw_string(_font, pos + Vector2(5, 13), short_name, HORIZONTAL_ALIGNMENT_LEFT, 30, 10, main_color)
	draw_string(_font, pos + Vector2(5, 25), "L%d" % level_value, HORIZONTAL_ALIGNMENT_LEFT, 26, 9, Color(1.0, 0.65, 0.82, 0.92))
	if is_evolved:
		draw_circle(pos + Vector2(33, 6), 2.6, Color(1.0, 0.88, 0.30, 0.95))

func _draw_detail_panel() -> void:
	var rect: Rect2 = Rect2(270, 128, 740, 458)
	draw_style_box(_detail_style, rect)
	draw_string(_font, Vector2(300, 164), "CUTE CUTE ARSENAL", HORIZONTAL_ALIGNMENT_LEFT, 330, 26, Color(1.0, 0.84, 0.93, 1.0))
	draw_string(_font, Vector2(790, 159), "[I] CLOSE", HORIZONTAL_ALIGNMENT_LEFT, 160, 13, Color(1.0, 0.66, 0.80, 0.78))
	draw_string(_font, Vector2(300, 188), "6 weapons + 6 charms • max weapon Lv 8 • charm Lv 5", HORIZONTAL_ALIGNMENT_LEFT, 620, 13, Color(0.92, 0.74, 0.90, 0.78))

	draw_string(_font, Vector2(300, 225), "WEAPONS", HORIZONTAL_ALIGNMENT_LEFT, 240, 16, Color(1.0, 0.54, 0.76, 1.0))
	draw_string(_font, Vector2(660, 225), "CHARMS", HORIZONTAL_ALIGNMENT_LEFT, 240, 16, Color(0.77, 0.65, 1.0, 1.0))

	var row: int = 0
	for key: Variant in _arsenal.weapons.keys():
		if row >= ArsenalCatalog.MAX_WEAPON_SLOTS:
			break
		var id: String = String(key)
		var data: Dictionary = ArsenalCatalog.get_weapon(id)
		var y: float = 258.0 + float(row) * 49.0
		var is_evolved: bool = bool(_arsenal.evolved.get(id, false))
		var name_text: String = String(data.get("evolution", "")) if is_evolved else String(data.get("name", id))
		draw_string(_font, Vector2(300, y), name_text, HORIZONTAL_ALIGNMENT_LEFT, 330, 14, Color(1.0, 0.91, 0.96, 1.0))
		_draw_level_pips(Vector2(300, y + 10), int(_arsenal.weapons[id]), ArsenalCatalog.MAX_WEAPON_LEVEL, Color(1.0, 0.42, 0.67, 0.9))
		var passive_id: String = String(data.get("passive", ""))
		var passive_data: Dictionary = ArsenalCatalog.get_passive(passive_id)
		var evo_hint: String = "EVOLVE: %s" % String(passive_data.get("name", passive_id))
		draw_string(_font, Vector2(300, y + 31), evo_hint, HORIZONTAL_ALIGNMENT_LEFT, 330, 10, Color(1.0, 0.66, 0.80, 0.64))
		row += 1

	row = 0
	for key: Variant in _arsenal.passives.keys():
		if row >= ArsenalCatalog.MAX_PASSIVE_SLOTS:
			break
		var id: String = String(key)
		var data: Dictionary = ArsenalCatalog.get_passive(id)
		var y: float = 258.0 + float(row) * 49.0
		draw_string(_font, Vector2(660, y), String(data.get("name", id)), HORIZONTAL_ALIGNMENT_LEFT, 300, 14, Color(0.94, 0.88, 1.0, 1.0))
		_draw_level_pips(Vector2(660, y + 10), int(_arsenal.passives[id]), ArsenalCatalog.MAX_PASSIVE_LEVEL, Color(0.70, 0.52, 1.0, 0.9))
		draw_string(_font, Vector2(660, y + 31), String(data.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, 300, 10, Color(0.86, 0.79, 0.94, 0.68))
		row += 1

func _draw_level_pips(origin: Vector2, value: int, maximum: int, color: Color) -> void:
	for i: int in maximum:
		var c: Color = color if i < value else Color(color.r, color.g, color.b, 0.18)
		draw_rect(Rect2(origin + Vector2(float(i) * 15.0, 0), Vector2(11, 4)), c)
