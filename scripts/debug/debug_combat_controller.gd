class_name DebugCombatController
extends Node

var _game_node: Node
var _blood_node: Node

func _ready() -> void:
	_game_node = get_tree().get_first_node_in_group("game")
	_blood_node = get_tree().get_first_node_in_group("blood_system")

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_Z:
		_launch("bomb")
	elif key_event.keycode == KEY_X:
		_launch("cluster")
	elif key_event.keycode == KEY_C:
		_launch("nuke")

func _launch(mode: String) -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	var root: Node = get_tree().current_scene
	if player == null or root == null:
		return
	var explosive: DebugExplosive = DebugExplosive.new()
	root.add_child(explosive)
	explosive.detonated.connect(_detonate)
	explosive.configure(player.global_position, player.get_global_mouse_position(), mode)

func _detonate(center: Vector2, mode: String) -> void:
	var radius: float = 145.0
	var damage: float = 52.0
	var blood_amount: int = 42
	if mode == "cluster":
		radius = 118.0
		damage = 38.0
		blood_amount = 34
	elif mode == "nuke":
		radius = 245.0
		damage = 9999.0
		blood_amount = 78
	_damage_area(center, radius, damage)
	if _blood_node == null or not is_instance_valid(_blood_node):
		_blood_node = get_tree().get_first_node_in_group("blood_system")
	if _blood_node != null:
		var burst_each: int = maxi(4, floori(float(blood_amount) / 8.0))
		for i: int in 8:
			_blood_node.call("emit_burst", center, Vector2.RIGHT.rotated(TAU * float(i) / 8.0), burst_each)
		_blood_node.call("add_massive_splat", center, 18 if mode == "nuke" else 11, Color("99072d"))
	if _game_node == null or not is_instance_valid(_game_node):
		_game_node = get_tree().get_first_node_in_group("game")
	if _game_node != null:
		_game_node.call("spawn_cute_fx", center, "impact", Vector2.ZERO, 2.2 if mode == "nuke" else 1.5)
		_game_node.call("spawn_cute_fx", center, "puff", Vector2.ZERO, 2.0 if mode == "nuke" else 1.4)
		_game_node.call("spawn_cute_fx", center + Vector2(18, -16), "strawberry", Vector2.UP, 1.5)
		_game_node.call("spawn_cute_fx", center + Vector2(-20, -10), "crit", Vector2.ZERO, 1.35)
		_game_node.call("add_screen_shake", 11.0 if mode == "nuke" else 6.5, 0.25 if mode == "nuke" else 0.16)
	if mode == "cluster":
		for i: int in 6:
			var sub_center: Vector2 = center + Vector2.RIGHT.rotated(TAU * float(i) / 6.0) * 72.0
			_damage_area(sub_center, 72.0, 22.0)
			if _blood_node != null:
				_blood_node.call("emit_burst", sub_center, sub_center.direction_to(center) * -1.0, 12)
				_blood_node.call("add_massive_splat", sub_center, 6, Color("a30a32"))

func _damage_area(center: Vector2, radius: float, damage: float) -> void:
	if _game_node == null or not is_instance_valid(_game_node):
		_game_node = get_tree().get_first_node_in_group("game")
	if _game_node == null:
		return
	var target_value: Variant = _game_node.call("get_enemies_near", center, radius)
	if not (target_value is Array):
		return
	var targets: Array = target_value as Array
	for entry: Variant in targets:
		var enemy: Node2D = entry as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var distance: float = center.distance_to(enemy.global_position)
		var falloff: float = lerpf(1.0, 0.58, clampf(distance / maxf(radius, 1.0), 0.0, 1.0))
		enemy.call("take_damage", damage * falloff, center.direction_to(enemy.global_position), distance < radius * 0.45)
