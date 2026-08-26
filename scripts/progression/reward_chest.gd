class_name RewardChest
extends Node2D

var legendary: bool = true
var _opened: bool = false
var _bob_time: float = 0.0
var _draw_tick: float = 0.0
var _player: Node2D

func _ready() -> void:
	add_to_group("reward_chest")
	z_index = 20
	_player = get_tree().get_first_node_in_group("player") as Node2D
	queue_redraw()

func _process(delta: float) -> void:
	if _opened:
		return
	_bob_time += delta
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null:
		return
	var distance: float = global_position.distance_to(_player.global_position)
	if distance < 130.0:
		var pull: float = clampf((130.0 - distance) / 130.0, 0.0, 1.0)
		global_position += global_position.direction_to(_player.global_position) * delta * 42.0 * pull
	if distance <= 34.0:
		_open()
		return
	_draw_tick -= delta
	if _draw_tick <= 0.0:
		_draw_tick = 1.0 / 24.0
		queue_redraw()

func _open() -> void:
	if _opened:
		return
	_opened = true
	var arsenal: Node = get_tree().get_first_node_in_group("arsenal")
	if arsenal != null and arsenal.has_method("open_chest"):
		arsenal.call("open_chest", legendary)
	else:
		var game_node: Node = get_tree().get_first_node_in_group("game")
		if game_node != null:
			game_node.call("claim_reward_chest", global_position, legendary)
	queue_free()

func _draw() -> void:
	var bob: float = sin(_bob_time * 4.0) * 2.0
	var p: Vector2 = Vector2(0.0, bob)
	var ink: Color = Color("2b1730")
	var pink: Color = Color("f04d91")
	var pale: Color = Color("ffd5e5")
	var gold: Color = Color("ffd95f")
	var shine: Color = Color("fff8c9")
	draw_rect(Rect2(p + Vector2(-18, -10), Vector2(36, 24)), ink)
	draw_rect(Rect2(p + Vector2(-15, -7), Vector2(30, 18)), pink)
	draw_rect(Rect2(p + Vector2(-18, -14), Vector2(36, 10)), ink)
	draw_rect(Rect2(p + Vector2(-15, -11), Vector2(30, 6)), pale)
	draw_rect(Rect2(p + Vector2(-4, -6), Vector2(8, 12)), gold)
	draw_rect(Rect2(p + Vector2(-1, -3), Vector2(2, 4)), shine)
	if legendary:
		var sparkle_offsets: Array[Vector2] = [Vector2(-27, -20), Vector2(25, -16), Vector2(-29, 8), Vector2(27, 12)]
		for offset: Vector2 in sparkle_offsets:
			draw_rect(Rect2(p + offset + Vector2(-4, -1), Vector2(8, 2)), shine)
			draw_rect(Rect2(p + offset + Vector2(-1, -4), Vector2(2, 8)), shine)
