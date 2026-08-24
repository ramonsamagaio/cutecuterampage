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
var cutin: SpecialCutin
var world_fx: CuteWorldFX
var level_panel: Panel
var level_box: VBoxContainer
var kills: int = 0
var _reward_timer: float = 0.0
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
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func bind(p: TaffiController, g: Node) -> void:
	player = p
	game = g
	player.level_up_requested.connect(_show_level_up)
	player.special_requested.connect(request_special)

func _build_ui() -> void:
	var root: Control = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	world_fx = CuteWorldFX.new()
	root.add_child(world_fx)

	hp_bar = _make_bar(Vector2(24, 24), Vector2(260, 22), Color("ff4f8f"))
	root.add_child(hp_bar)
	xp_bar = _make_bar(Vector2(24, 52), Vector2(260, 12), Color("9564ff"))
	root.add_child(xp_bar)
	cute_bar = _make_bar(Vector2(24, 70), Vector2(260, 12), Color("ff83b8"))
	root.add_child(cute_bar)
	special_bar = _make_bar(Vector2(955, 610), Vector2(292, 18), Color("ff76b1"))
	root.add_child(special_bar)

	level_label = Label.new()
	level_label.position = Vector2(24, 88)
	level_label.add_theme_font_size_override("font_size", 18)
	root.add_child(level_label)

	cute_label = Label.new()
	cute_label.position = Vector2(24, 116)
	cute_label.add_theme_font_size_override("font_size", 17)
	cute_label.add_theme_color_override("font_color", Color("ff93bd"))
	root.add_child(cute_label)

	danger_label = Label.new()
	danger_label.position = Vector2(24, 142)
	danger_label.add_theme_font_size_override("font_size", 17)
	danger_label.add_theme_color_override("font_color", Color("ff8ba9"))
	root.add_child(danger_label)

	combo_label = Label.new()
	combo_label.position = Vector2(500, 38)
	combo_label.size = Vector2(360, 60)
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.add_theme_font_size_override("font_size", 30)
	combo_label.add_theme_color_override("font_color", Color("ff8fbd"))
	root.add_child(combo_label)

	kill_label = Label.new()
	kill_label.position = Vector2(1090, 24)
	kill_label.add_theme_font_size_override("font_size", 18)
	root.add_child(kill_label)

	weapon_label = Label.new()
	weapon_label.position = Vector2(24, 670)
	weapon_label.size = Vector2(880, 30)
	weapon_label.add_theme_font_size_override("font_size", 16)
	weapon_label.add_theme_color_override("font_color", Color("ffe0ee"))
	root.add_child(weapon_label)

	boss_label = Label.new()
	boss_label.position = Vector2(390, 104)
	boss_label.size = Vector2(500, 24)
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.add_theme_font_size_override("font_size", 20)
	boss_label.add_theme_color_override("font_color", Color("ffd1e2"))
	boss_label.visible = false
	root.add_child(boss_label)
	boss_bar = _make_bar(Vector2(390, 132), Vector2(500, 18), Color("e83c76"))
	boss_bar.visible = false
	root.add_child(boss_bar)

	reward_label = Label.new()
	reward_label.position = Vector2(340, 168)
	reward_label.size = Vector2(600, 52)
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_label.add_theme_font_size_override("font_size", 26)
	reward_label.add_theme_color_override("font_color", Color("fff0a8"))
	reward_label.visible = false
	root.add_child(reward_label)

	special_status_label = Label.new()
	special_status_label.position = Vector2(955, 582)
	special_status_label.size = Vector2(292, 24)
	special_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	special_status_label.add_theme_font_size_override("font_size", 15)
	special_status_label.add_theme_color_override("font_color", Color("ffd8e8"))
	root.add_child(special_status_label)

	special_button = Button.new()
	special_button.text = "SPECIAL ♡"
	special_button.position = Vector2(1030, 640)
	special_button.size = Vector2(215, 54)
	special_button.add_theme_font_size_override("font_size", 22)
	special_button.pressed.connect(request_special)
	root.add_child(special_button)

	cutin = SpecialCutin.new()
	root.add_child(cutin)

	level_panel = Panel.new()
	level_panel.position = Vector2(380, 190)
	level_panel.size = Vector2(520, 340)
	level_panel.visible = false
	root.add_child(level_panel)
	level_box = VBoxContainer.new()
	level_box.position = Vector2(30, 25)
	level_box.size = Vector2(460, 290)
	level_panel.add_child(level_box)

func _make_bar(pos: Vector2, bar_size: Vector2, fill_color: Color) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.position = pos
	bar.size = bar_size
	bar.show_percentage = false
	var background_box: StyleBoxFlat = StyleBoxFlat.new()
	background_box.bg_color = Color("31182b")
	background_box.corner_radius_top_left = 5
	background_box.corner_radius_top_right = 5
	background_box.corner_radius_bottom_left = 5
	background_box.corner_radius_bottom_right = 5
	var fill_box: StyleBoxFlat = StyleBoxFlat.new()
	fill_box.bg_color = fill_color
	fill_box.corner_radius_top_left = 5
	fill_box.corner_radius_top_right = 5
	fill_box.corner_radius_bottom_left = 5
	fill_box.corner_radius_bottom_right = 5
	bar.add_theme_stylebox_override("background", background_box)
	bar.add_theme_stylebox_override("fill", fill_box)
	return bar

func _process(delta: float) -> void:
	if player == null:
		return
	_reward_timer = maxf(0.0, _reward_timer - delta)
	if _reward_timer <= 0.0:
		reward_label.visible = false

	hp_bar.max_value = player.max_hp
	hp_bar.value = player.hp
	xp_bar.max_value = player.xp_needed
	xp_bar.value = player.xp
	cute_bar.max_value = 100.0
	cute_bar.value = player.cute_meter
	special_bar.max_value = 100.0
	special_bar.value = player.special_meter
	world_fx.set_meter(player.cute_meter)

	level_label.text = "LV %d   HP %d/%d" % [player.level, roundi(player.hp), roundi(player.max_hp)]
	cute_label.text = "CUTE %03d%%  %s  x%.2f DMG" % [roundi(player.cute_meter), player.get_cute_rank(), player.get_cute_damage_multiplier()]
	combo_label.text = "%s\nCOMBO x%d" % [player.get_combo_caption(), player.combo] if player.combo > 0 else ""
	kill_label.text = "♡ %d" % kills
	weapon_label.text = player.get_weapon_summary()

	var threat: int = int(game.call("get_threat_tier")) if game != null else 1
	var run_time: float = float(game.call("get_run_time")) if game != null else 0.0
	var minutes: int = floori(run_time / 60.0)
	var seconds: int = floori(fmod(run_time, 60.0))
	danger_label.text = "DANGER %02d   %02d:%02d" % [threat, minutes, seconds]
	special_status_label.text = "AIM WITH MOUSE • STRAWBERRY BEAM" if player.special_channeling else "STRAWBERRY OVERDRIVE"
	special_button.disabled = not player.can_special() or get_tree().paused

	var boss_ratio: float = float(game.call("get_boss_health_ratio")) if game != null else 0.0
	var boss_active: bool = boss_ratio > 0.0
	boss_bar.visible = boss_active
	boss_label.visible = boss_active
	if boss_active:
		boss_bar.max_value = 1.0
		boss_bar.value = boss_ratio
		boss_label.text = String(game.call("get_boss_name"))

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
	title.text = "LEVEL UP! ♡ Pick your sugar"
	title.add_theme_font_size_override("font_size", 24)
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
		button.pressed.connect(_pick_upgrade.bind(id))
		level_box.add_child(button)

func _pick_upgrade(id: String) -> void:
	player.apply_upgrade(id)
	level_panel.visible = false
	get_tree().paused = false
