class_name RewardChest
extends Node2D

var legendary: bool = false
var reward_count: int = 1
var _opened: bool = false
var _bob_time: float = 0.0
var _draw_timer: float = 0.0
var _label_font: Font

func _ready() -> void:
	add_to_group("reward_chest")
	z_index = 20
	_label_font = ThemeDB.fallback_font
	queue_redraw()

func _process(delta: float) -> void:
	if _opened:
		return
	_bob_time += delta
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		var distance: float = global_position.distance_to(player.global_position)
		if distance < 170.0:
			var pull: float = clampf((170.0 - distance) / 170.0, 0.0, 1.0)
			global_position += global_position.direction_to(player.global_position) * delta * 58.0 * pull
		if distance <= 38.0:
			_open()

	_draw_timer -= delta
	if _draw_timer <= 0.0:
		_draw_timer = 1.0 / 30.0
		queue_redraw()

func _open() -> void:
	if _opened:
		return
	_opened = true
	var game_node: Node = get_tree().get_first_node_in_group("game")
	if game_node != null:
		game_node.call("claim_reward_chest", global_position, legendary, reward_count)
	queue_free()

func get_tier_name() -> String:
	if reward_count >= 5 or legendary:
		return "OMG!!! BOX"
	if reward_count >= 3:
		return "PARTY BOX"
	return "SWEET BOX"

func _draw() -> void:
	var bob: float = sin(_bob_time * 4.0) * 2.4
	var breathe: float = 1.0 + sin(_bob_time * 3.1) * 0.035
	var p: Vector2 = Vector2(0.0, bob)
	var ink: Color = Color("2b1730")
	var pink: Color = Color("f04d91")
	var pale: Color = Color("ffd5e5")
	var gold: Color = Color("ffd95f")
	var shine: Color = Color("fff8c9")
	var aura: Color = Color(1.0, 0.25, 0.64, 0.12)
	if reward_count >= 3:
		pink = Color("e754c8")
		aura = Color(0.82, 0.32, 1.0, 0.15)
	if reward_count >= 5 or legendary:
		pink = Color("ff5b93")
		aura = Color(1.0, 0.76, 0.22, 0.18)

	# Cheap layered aura replaces a particle emitter while still making the box impossible to miss.
	draw_circle(p + Vector2(0, 2), 38.0 * breathe, aura)
	draw_circle(p + Vector2(0, 2), 29.0 * breathe, Color(aura.r, aura.g, aura.b, aura.a * 0.72))
	draw_circle(p + Vector2(0, 17), 20.0, Color(0.08, 0.03, 0.08, 0.24))

	var scale_value: float = 1.0 + (0.08 if reward_count >= 3 else 0.0) + (0.08 if reward_count >= 5 or legendary else 0.0)
	draw_set_transform(p, 0.0, Vector2.ONE * scale_value)
	draw_rect(Rect2(Vector2(-20, -11), Vector2(40, 27)), ink)
	draw_rect(Rect2(Vector2(-17, -8), Vector2(34, 21)), pink)
	draw_rect(Rect2(Vector2(-20, -16), Vector2(40, 11)), ink)
	draw_rect(Rect2(Vector2(-17, -13), Vector2(34, 7)), pale)
	draw_rect(Rect2(Vector2(-5, -7), Vector2(10, 14)), gold)
	draw_rect(Rect2(Vector2(-2, -4), Vector2(4, 5)), shine)
	# Pixel highlights and corner bands.
	draw_rect(Rect2(Vector2(-14, -10), Vector2(14, 2)), Color(1.0, 0.87, 0.94, 0.34))
	draw_rect(Rect2(Vector2(9, -10), Vector2(5, 2)), Color(1.0, 0.92, 0.96, 0.48))
	if reward_count >= 3:
		draw_rect(Rect2(Vector2(-19, 5), Vector2(4, 7)), gold)
		draw_rect(Rect2(Vector2(15, 5), Vector2(4, 7)), gold)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var sparkle_count: int = 4 if reward_count == 1 else (7 if reward_count == 3 else 10)
	for i: int in sparkle_count:
		var a: float = _bob_time * (0.65 + float(i % 3) * 0.11) + TAU * float(i) / float(sparkle_count)
		var radius: float = 30.0 + float(i % 3) * 8.0
		var q: Vector2 = p + Vector2(cos(a) * radius, sin(a) * radius * 0.64)
		_draw_spark(q, 3.0 + float(i % 2) * 1.5, shine if i % 2 == 0 else pale)

	if _label_font != null:
		var name: String = get_tier_name()
		var label_pos: Vector2 = p + Vector2(-38 - float(name.length()) * 1.7, -39)
		draw_string(_label_font, label_pos + Vector2(2, 2), name, HORIZONTAL_ALIGNMENT_CENTER, 94, 11, Color(0.12, 0.02, 0.10, 0.82))
		draw_string(_label_font, label_pos, name, HORIZONTAL_ALIGNMENT_CENTER, 94, 11, shine)

func _draw_spark(p: Vector2, radius: float, color: Color) -> void:
	draw_line(p + Vector2(-radius, 0), p + Vector2(radius, 0), color, 1.5, true)
	draw_line(p + Vector2(0, -radius), p + Vector2(0, radius), color, 1.5, true)
