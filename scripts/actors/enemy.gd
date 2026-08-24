class_name CuteEnemy
extends CharacterBody2D

var enemy_kind := "chick"
var elite := false
var max_health := 12.0
var health := 12.0
var move_speed := 52.0
var attack_cooldown := 0.0
var parts: Array[PixelPart] = []
var visual: Node2D

func _ready() -> void:
	add_to_group("enemy")
	visual = Node2D.new()
	visual.name = "Visual"
	visual.scale = Vector2(3, 3) * (1.2 if elite else 1.0)
	add_child(visual)
	if enemy_kind == "pig":
		max_health = 24.0
		move_speed = 39.0
	else:
		max_health = 12.0
		move_speed = 54.0
	if elite:
		max_health *= 2.5
		move_speed *= 1.12
	health = max_health
	_build_parts()

func _build_parts() -> void:
	var head := PixelPart.new()
	head.part_kind = enemy_kind + "_head"
	head.position = Vector2(0, -3)
	visual.add_child(head)
	parts.append(head)
	var body := PixelPart.new()
	body.part_kind = enemy_kind + "_body"
	body.position = Vector2(0, 2)
	visual.add_child(body)
	parts.append(body)
	var feet := PixelPart.new()
	feet.part_kind = enemy_kind + "_feet"
	feet.position = Vector2(0, 6)
	visual.add_child(feet)
	parts.append(feet)

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var to_player := global_position.direction_to(player.global_position)
	velocity = to_player * move_speed
	move_and_slide()
	if absf(velocity.x) > 0.1:
		visual.scale.x = absf(visual.scale.x) * signf(velocity.x)
	if global_position.distance_squared_to(player.global_position) < 21.0 * 21.0 and attack_cooldown <= 0.0:
		if player.has_method("take_damage"):
			player.take_damage(6.0 if not elite else 10.0)
		attack_cooldown = 0.9

func take_damage(amount: float, hit_direction: Vector2 = Vector2.ZERO, is_critical: bool = false) -> void:
	health -= amount
	if not parts.is_empty():
		var part := parts[randi() % parts.size()]
		part.add_blood_stain(Vector2i(randi_range(-2, 2), randi_range(-2, 2)))
	var blood := get_tree().get_first_node_in_group("blood_system")
	if blood:
		blood.emit_burst(global_position, hit_direction, 7 if is_critical else 4)
	if health <= 0.0:
		_die(hit_direction)

func _die(hit_direction: Vector2) -> void:
	var blood := get_tree().get_first_node_in_group("blood_system")
	if blood:
		blood.emit_burst(global_position, hit_direction, 16 if elite else 11)
		var tint := Color("ffcf4d") if enemy_kind == "chick" else Color("ff9fbd")
		blood.spawn_chunk(global_position + Vector2(0, -8), "head", tint, hit_direction)
		blood.spawn_chunk(global_position, "body", tint, hit_direction.rotated(0.6))
		blood.spawn_chunk(global_position + Vector2(0, 8), "leg", tint, hit_direction.rotated(-0.6))
	var game := get_tree().get_first_node_in_group("game")
	if game:
		game.on_enemy_killed(global_position, 3 if elite else 1)
	queue_free()
