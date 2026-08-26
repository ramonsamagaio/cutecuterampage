class_name GameHUD
extends CanvasLayer

var player: TaffiController
var game: Node
var hp_bar: ProgressBar
var xp_bar: ProgressBar
var cute_bar: ProgressBar
var special_bar: ProgressBar
var boss_bar: ProgressBar
var level_label: Label
var cute_label: Label
var combo_label: Label
var kill_label: Label
var danger_label: Label
var weapon_label: Label
var boss_label: Label
var reward_label: Label
var special_status_label: Label
var special_button: Button
var perf_label: Label
var cutin: SpecialCutin
var world_fx: CuteWorldFX
var level_panel: Panel
var level_box: VBoxContainer
var kills: int = 0
var _reward_timer: float = 0.0
var _ui_tick: float = 0.0
var _upgrade_ids: Array[String] = ["sugar_rush", "heart_piercer", "bubblegum_shoes", "strawberry_core", "sprinkles", "ribbon_reflex", "plush_armor", "love_battery", "cupcake_mortar", "love_orbit"]
var _upgrade_names: Dictionary[String, String] = {
	"sugar_rush": "SUGAR RUSH!  Fire faster",
	"heart_piercer": "HEART PIERCER  Heart damage + mastery",
	"bubblegum_shoes": "BUBBLEGUM SHOES  +Speed",
	"strawberry_core": "STRAWBERRY CORE  +HP",
	"sprinkles": "SPRINKLES!  +Heart projectile",
	"ribbon_reflex": "RIBBON REFLEX  Faster dash",
	"plush_armor": "PLUSH ARMOR  Less damage",
	"love_battery": "LOVE BATTERY  Faster Special",
	"cupcake_mortar": "CUPCAKE MORTAR  Lob explosive cupcakes",
	"love_orbit": "LOVE ORBIT  Hearts circle Taffi"
}

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func bind(p: TaffiController, g: Node) -> void:
	player = p
	game = g
	player.level_up_requested.connect(_show_level_up)
	player.special_requested.connect(request_special)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		perf_label.visible = not perf_label.visible

func _build_ui() -> void:
	var root: Control = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	world_fx = CuteWorldFX.new()
	root.add_child(world_fx)

	hp_bar = _make_bar(Vector2(108, 29), Vector2(244, 21), Color("ff4f8f"))
	root.add_child(hp_bar)
	xp_bar = _make_bar(Vector2(108, 57), Vector2(244, 10), Color("8f68ff"))
	root.add_child(xp_bar)
	cute_bar = _make_bar(Vector2(108, 74), Vector2(244, 10), Color("ff8fbe"))
	root.add_child(cute_bar)
	special_bar = _make_bar(Vector2(934, 619), Vector2(310, 18), Color("ff76b1"))
	root.add_child(special_bar)

	level_label = _make_label(Vector2(108, 87), Vector2(244, 23), 16, Color("fff4f8"), HORIZONTAL_ALIGNMENT_LEFT, 2)
	root.add_child(level_label)
	cute_label = _make_label(Vector2(108, 108), Vector2(244, 21), 14, Color("ffa6ca"), HORIZONTAL_ALIGNMENT_LEFT, 2)
	root.add_child(cute_label)
	danger_label = _make_label(Vector2(108, 129), Vector2(244, 21), 14, Color("ff91ad"), HORIZONTAL_ALIGNMENT_LEFT, 2)
	root.add_child(danger_label)

	combo_label = _make_label(Vector2(493, 30), Vector2(294, 52), 26, Color("ff8fbd"), HORIZONTAL_ALIGNMENT_CENTER, 4)
	combo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	root.add_child(combo_label)

	kill_label = _make_label(Vector2(1103, 21), Vector2(142, 32), 18, Color("fff2f7"), HORIZONTAL_ALIGNMENT_CENTER, 3)
	kill_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	root.add_child(kill_label)

	weapon_label = _make_label(Vector2(20, 650), Vector2(690, 30), 15, Color("ffe4ef"), HORIZONTAL_ALIGNMENT_LEFT, 2)
	root.add_child(weapon_label)

	boss_label = _make_label(Vector2(390, 102), Vector2(500, 24), 20, Color("ffd1e2"), HORIZONTAL_ALIGNMENT_CENTER, 3)
	boss_label.visible = false
	root.add_child(boss_label)
	boss_bar = _make_bar(Vector2(390, 130), Vector2(500, 18), Color("e83c76"))
	boss_bar.visible = false
	root.add_child(boss_bar)

	reward_label = _make_label(Vector2(340, 166), Vector2(600, 52), 26, Color("fff0a8"), HORIZONTAL_ALIGNMENT_CENTER, 4)
	reward_label.visible = false
	root.add_child(reward_label)

	special_status_label = _make_label(Vector2(934, 594), Vector2(310, 20), 13, Color("ffd8e8"), HORIZONTAL_ALIGNMENT_CENTER, 2)
	root.add_child(special_status_label)

	special_button = Button.new()
	special_button.text = "SPECIAL ♡"
	special_button.position = Vector2(1000, 649)
	special_button.size = Vector2(240, 43)
	special_button.add_theme_font_size_override("font_size", 20)
	special_button.add_theme_color_override("font_color", Color("fff3f8"))
	special_button.add_theme_color_override("font_hover_color", Color.WHITE)
	special_button.add_theme_stylebox_override("normal", _button_style(Color("52203f"), Color("ff75ad")))
	special_button.add_theme_stylebox_override("hover", _button_style(Color("6b2850"), Color("ff9bc4")))
	special_button.add_theme_stylebox_override("pressed", _button_style(Color("3e1732"), Color("ffbad4")))
	special_button.pressed.connect(request_special)
	root.add_child(special_button)

	perf_label = _make_label(Vector2(948, 76), Vector2(300, 132), 14, Color("e8fff4"), HORIZONTAL_ALIGNMENT_LEFT, 2)
	var perf_style: StyleBoxFlat = StyleBoxFlat.new()
	perf_style.bg_color = Color(0.05, 0.07, 0.08, 0.88)
	perf_style.border_color = Color(0.48, 1.0, 0.74, 0.58)
	perf_style.set_border_width_all(2)
	perf_style.set_corner_radius_all(10)
	perf_style.content_margin_left = 12
	perf_style.content_margin_top = 9
	perf_style.content_margin_right = 12
	perf_style.content_margin_bottom = 9
	perf_label.add_theme_stylebox_override("normal", perf_style)
	perf_label.visible = false
	root.add_child(perf_label)

	cutin = SpecialCutin.new()
	root.add_child(cutin)

	level_panel = Panel.new()
	level_panel.position = Vector2(380, 190)
	level_panel.size = Vector2(520, 340)
	level_panel.add_theme_stylebox_override("panel", _level_panel_style())
	level_panel.visible = false
	root.add_child(level_panel)
	level_box = VBoxContainer.new()
	level_box.position = Vector2(30, 25)
	level_box.size = Vector2(460, 290)
	level_box.add_theme_constant_override("separation", 10)
	level_panel.add_child(level_box)

func _make_label(pos: Vector2, label_size: Vector2, font_size: int, color: Color, alignment: HorizontalAlignment, outline: int) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.size = label_size
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.12, 0.04, 0.12, 0.88))
	label.add_theme_constant_override("outline_size", outline)
	return label

func _make_bar(pos: Vector2, bar_size: Vector2, fill_color: Color) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.position = pos
	bar.size = bar_size
	bar.show_percentage = false
	var background_box: StyleBoxFlat = StyleBoxFlat.new()
	background_box.bg_color = Color("241323")
	background_box.border_color = Color(0.96, 0.56, 0.72, 0.36)
	background_box.set_border_width_all(2)
	background_box.set_corner_radius_all(7)
	var fill_box: StyleBoxFlat = StyleBoxFlat.new()
	fill_box.bg_color = fill_color
	fill_box.border_color = fill_color.lightened(0.22)
	fill_box.set_border_width_all(1)
	fill_box.set_corner_radius_all(7)
	bar.add_theme_stylebox_override("background", background_box)
	bar.add_theme_stylebox_override("fill", fill_box)
	return bar

func _button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(3)
	style.set_corner_radius_all(11)
	style.shadow_color = Color(0.05, 0.01, 0.05, 0.40)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 3)
	return style

func _level_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("36192f")
	style.border_color = Color("ff84b6")
	style.set_border_width_all(4)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0.04, 0.01, 0.04, 0.55)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 5)
	return style

func _process(delta: float) -> void:
	if player == null:
		return
	_reward_timer = maxf(0.0, _reward_timer - delta)
	if _reward_timer <= 0.0:
		reward_label.visible = false
	_ui_tick -= delta
	if _ui_tick > 0.0:
		return
	_ui_tick = 0.05

	hp_bar.max_value = player.max_hp
	hp_bar.value = player.hp
	xp_bar.max_value = player.xp_needed
	xp_bar.value = player.xp
	cute_bar.max_value = 100.0
	cute_bar.value = player.cute_meter
	special_bar.max_value = 100.0
	special_bar.value = player.special_meter
	world_fx.set_meter(player.cute_meter)

	level_label.text = "LV %d    HP %d/%d" % [player.level, roundi(player.hp), roundi(player.max_hp)]
	cute_label.text = "CUTE %03d%%   %s   x%.2f DMG" % [roundi(player.cute_meter), player.get_cute_rank(), player.get_cute_damage_multiplier()]
	combo_label.text = "%s\nCOMBO x%d" % [player.get_combo_caption(), player.combo] if player.combo > 0 else ""
	kill_label.text = "♡  %d" % kills
	weapon_label.text = player.get_weapon_summary()

	var threat: int = int(game.call("get_threat_tier")) if game != null else 1
	var run_time: float = float(game.call("get_run_time")) if game != null else 0.0
	var minutes: int = floori(run_time / 60.0)
	var seconds: int = floori(fmod(run_time, 60.0))
	danger_label.text = "DANGER %02d    %02d:%02d" % [threat, minutes, seconds]
	special_status_label.text = "AIM WITH MOUSE  •  STRAWBERRY BEAM" if player.special_channeling else "STRAWBERRY OVERDRIVE"
	special_button.disabled = not player.can_special() or get_tree().paused

	var boss_ratio: float = float(game.call("get_boss_health_ratio")) if game != null else 0.0
	var boss_active: bool = boss_ratio > 0.0
	boss_bar.visible = boss_active
	boss_label.visible = boss_active
	if boss_active:
		boss_bar.max_value = 1.0
		boss_bar.value = boss_ratio
		boss_label.text = String(game.call("get_boss_name"))

	if perf_label.visible and game != null:
		var stats: Dictionary = game.call("get_perf_snapshot")
		var fps: int = roundi(Performance.get_monitor(Performance.TIME_FPS))
		perf_label.text = "PERF  F3 TO HIDE\nFPS %d   ENEMIES %d\nPLAYER SHOTS %d   ENEMY SHOTS %d\nFX %d   FLYING GORE %d\nGROUND SPLATS %d" % [
			fps,
			int(stats.get("enemies", 0)),
			int(stats.get("player_projectiles", 0)),
			int(stats.get("enemy_projectiles", 0)),
			int(stats.get("cute_fx", 0)),
			int(stats.get("blood_children", 0)),
			int(stats.get("splats", 0))
		]

func on_kill() -> void:
	kills += 1

func show_reward_toast(text: String) -> void:
	reward_label.text = text
	reward_label.visible = true
	_reward_timer = 3.2

func request_special() -> void:
	if player == null or game == null or not player.can_special() or get_tree().paused:
		return
	cutin.play()
	await cutin.finished
	player.consume_special()
	game.call("trigger_special", player.global_position)

func _show_level_up() -> void:
	if player == null:
		return
	get_tree().paused = true
	level_panel.visible = true
	for child: Node in level_box.get_children():
		child.queue_free()
	var title: Label = Label.new()
	title.text = "LEVEL UP! ♡  PICK YOUR SUGAR"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("fff2f7"))
	title.add_theme_color_override("font_outline_color", Color("32152c"))
	title.add_theme_constant_override("outline_size", 3)
	level_box.add_child(title)
	var choices: Array[String] = []
	for upgrade_id: String in _upgrade_ids:
		if player.can_take_upgrade(upgrade_id):
			choices.append(upgrade_id)
	choices.shuffle()
	var option_count: int = mini(3, choices.size())
	for i: int in option_count:
		var id: String = choices[i]
		var button: Button = Button.new()
		button.text = _upgrade_names[id]
		button.custom_minimum_size = Vector2(440, 62)
		button.add_theme_font_size_override("font_size", 17)
		button.add_theme_stylebox_override("normal", _button_style(Color("4a203d"), Color("e96d9e")))
		button.add_theme_stylebox_override("hover", _button_style(Color("65264d"), Color("ff9bc4")))
		button.pressed.connect(_pick_upgrade.bind(id))
		level_box.add_child(button)

func _pick_upgrade(id: String) -> void:
	player.apply_upgrade(id)
	level_panel.visible = false
	get_tree().paused = false
