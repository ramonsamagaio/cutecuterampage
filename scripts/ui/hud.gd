class_name GameHUD
extends CanvasLayer

var player
var game
var hp_bar: ProgressBar
var xp_bar: ProgressBar
var special_bar: ProgressBar
var level_label: Label
var combo_label: Label
var kill_label: Label
var special_button: Button
var cutin: SpecialCutin
var level_panel: Panel
var level_box: VBoxContainer
var kills := 0
var _upgrade_ids := ["sugar_rush", "heart_piercer", "bubblegum_shoes", "strawberry_core", "sprinkles"]
var _upgrade_names := {
	"sugar_rush": "SUGAR RUSH!  Fire faster",
	"heart_piercer": "HEART PIERCER  +Damage",
	"bubblegum_shoes": "BUBBLEGUM SHOES  +Speed",
	"strawberry_core": "STRAWBERRY CORE  +HP",
	"sprinkles": "SPRINKLES!  +Projectile"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func bind(p, g) -> void:
	player = p
	game = g
	player.level_up_requested.connect(_show_level_up)
	player.special_requested.connect(request_special)

func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	hp_bar = _make_bar(Vector2(24, 24), Vector2(260, 22), Color("ff4f8f"))
	root.add_child(hp_bar)
	xp_bar = _make_bar(Vector2(24, 52), Vector2(260, 14), Color("9564ff"))
	root.add_child(xp_bar)
	special_bar = _make_bar(Vector2(955, 610), Vector2(292, 18), Color("ff76b1"))
	root.add_child(special_bar)

	level_label = Label.new()
	level_label.position = Vector2(24, 72)
	level_label.add_theme_font_size_override("font_size", 18)
	root.add_child(level_label)
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
	level_panel.position = Vector2(380, 205)
	level_panel.size = Vector2(520, 310)
	level_panel.visible = false
	root.add_child(level_panel)
	level_box = VBoxContainer.new()
	level_box.position = Vector2(30, 25)
	level_box.size = Vector2(460, 260)
	level_panel.add_child(level_box)

func _make_bar(pos: Vector2, bar_size: Vector2, fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.size = bar_size
	bar.show_percentage = false
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("31182b")
	bg.corner_radius_top_left = 5
	bg.corner_radius_top_right = 5
	bg.corner_radius_bottom_left = 5
	bg.corner_radius_bottom_right = 5
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = 5
	fill.corner_radius_top_right = 5
	fill.corner_radius_bottom_left = 5
	fill.corner_radius_bottom_right = 5
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)
	return bar

func _process(_delta: float) -> void:
	if player == null:
		return
	hp_bar.max_value = player.max_hp
	hp_bar.value = player.hp
	xp_bar.max_value = player.xp_needed
	xp_bar.value = player.xp
	special_bar.max_value = 100.0
	special_bar.value = player.special_meter
	level_label.text = "LV %d   HP %d/%d" % [player.level, roundi(player.hp), roundi(player.max_hp)]
	combo_label.text = "%s\nCOMBO x%d" % [player.get_combo_caption(), player.combo] if player.combo > 0 else ""
	kill_label.text = "♡ %d" % kills
	special_button.disabled = not player.can_special() or get_tree().paused

func on_kill() -> void:
	kills += 1

func request_special() -> void:
	if player == null or game == null or not player.can_special() or get_tree().paused:
		return
	cutin.play()
	await cutin.finished
	player.consume_special()
	game.trigger_special(player.global_position)

func _show_level_up() -> void:
	if player == null:
		return
	get_tree().paused = true
	level_panel.visible = true
	for child in level_box.get_children():
		child.queue_free()
	var title := Label.new()
	title.text = "LEVEL UP! ♡ Pick your sugar"
	title.add_theme_font_size_override("font_size", 24)
	level_box.add_child(title)
	var choices := _upgrade_ids.duplicate()
	choices.shuffle()
	for i in 3:
		var id: String = choices[i]
		var button := Button.new()
		button.text = _upgrade_names[id]
		button.custom_minimum_size = Vector2(440, 58)
		button.pressed.connect(_pick_upgrade.bind(id))
		level_box.add_child(button)

func _pick_upgrade(id: String) -> void:
	player.apply_upgrade(id)
	level_panel.visible = false
	get_tree().paused = false
