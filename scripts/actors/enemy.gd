class_name CuteEnemy
extends CharacterBody2D

var enemy_kind: String = "chick"
var archetype: String = "chaser"
var elite: bool = false
var power_scale: float = 1.0
var max_health: float = 12.0
var health: float = 12.0
var move_speed: float = 52.0
var contact_damage: float = 6.0
var attack_cooldown: float = 0.0
var xp_reward: int = 1
var parts: Array[PixelPart] = []
var visual: Node2D

var _shoot_timer: float = 1.0
var _charge_cooldown: float = 2.0
var _charge_windup: float = 0.0
var _charge_active: float = 0.0
var _charge_direction: Vector2 = Vector2.ZERO
var _strafe_sign: float = 1.0
var _base_modulate: Color = Color.WHITE

func _ready() -> void:
	add_to_group("enemy")
	visual = Node2D.new()
	visual.name = "Visual"
	visual.scale = Vector2(3.0, 3.0) * (1.2 if elite else 1.0)
	add_child(visual)

	if enemy_kind == "pig":
		max_health = 30.0
		move_speed = 41.0
		contact_damage = 8.0
		xp_reward = 2
	else:
		max_health = 12.0
		move_speed = 56.0
		contact_damage = 5.5
		xp_reward = 1

	match archetype:
		"shooter":
			max_health *= 0.82
			move_speed *= 0.86
			xp_reward += 1
			_base_modulate = Color(0.96, 0.88, 1.0, 1.0)
			_shoot_timer = randf_range(0.45, 1.25)
		"charger":
			max_health *= 1.35
			move_speed *= 0.96
			contact_damage *= 1.20
			xp_reward += 1
			_charge_cooldown = randf_range(1.0, 2.4)
		_:
			_base_modulate = Color.WHITE

	max_health *= power_scale
	contact_damage *= 1.0 + maxf(0.0, power_scale - 1.0) * 0.24
	move_speed *= 1.0 + minf(0.30, maxf(0.0, power_scale - 1.0) * 0.025)
	if elite:
		max_health *= 2.8
		move_speed *= 1.12
		contact_damage *= 1.45
		xp_reward *= 3
	health = max_health
	visual.modulate = _base_modulate
	_strafe_sign = -1.0 if randf() < 0.5 else 1.0
	_build_parts()

func _build_parts() -> void:
	var head: PixelPart = PixelPart.new()
	head.part_kind = enemy_kind + "_head"
	head.position = Vector2(0, -3)
	visual.add_child(head)
	parts.append(head)
	var body: PixelPart = PixelPart.new()
	body.part_kind = enemy_kind + "_body"
	body.position = Vector2(0, 2)
	visual.add_child(body)
	parts.append(body)
	var feet: PixelPart = PixelPart.new()
	feet.part_kind = enemy_kind + "_feet"
	feet.position = Vector2(0, 6)
	visual.add_child(feet)
	parts.append(feet)

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	var player_node: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player_node == null:
		return
	var to_player: Vector2 = global_position.direction_to(player_node.global_position)
	var distance: float = global_position.distance_to(player_node.global_position)

	match archetype:
		"shooter": _move_shooter(delta, to_player, distance)
		"charger": _move_charger(delta, to_player, distance)
		_: velocity = to_player * move_speed

	move_and_slide()
	if absf(velocity.x) > 0.1:
		visual.scale.x = absf(visual.scale.x) * signf(velocity.x)

	if distance < 21.0 and attack_cooldown <= 0.0:
		var impact_multiplier: float = 1.55 if archetype == "charger" and _charge_active > 0.0 else 1.0
		player_node.call("take_damage", contact_damage * impact_multiplier)
		attack_cooldown = 0.9

func _move_shooter(delta: float, to_player: Vector2, distance: float) -> void:
	visual.modulate = _base_modulate
	if distance > 295.0:
		velocity = to_player * move_speed
	elif distance < 175.0:
		velocity = -to_player * move_speed * 0.82
	else:
		velocity = to_player.rotated(PI * 0.5 * _strafe_sign) * move_speed * 0.58

	_shoot_timer -= delta
	if _shoot_timer <= 0.0 and distance < 570.0:
		var game_node: Node = get_tree().get_first_node_in_group("game")
		if game_node != null:
			var projectile_damage: float = contact_damage * 0.72
			var projectile_speed: float = 185.0 + minf(125.0, maxf(0.0, power_scale - 1.0) * 10.0)
			game_node.call("spawn_enemy_projectile", global_position, to_player, projectile_damage, projectile_speed)
		var cadence: float = maxf(0.72, 1.58 - minf(0.62, power_scale * 0.055))
		_shoot_timer = cadence + randf_range(-0.12, 0.18)

func _move_charger(delta: float, to_player: Vector2, distance: float) -> void:
	if _charge_active > 0.0:
		_charge_active -= delta
		velocity = _charge_direction * move_speed * 3.35
		visual.modulate = Color(1.0, 0.56, 0.68, 1.0)
		return
	if _charge_windup > 0.0:
		_charge_windup -= delta
		velocity = Vector2.ZERO
		var pulse: float = 0.72 + sin(float(Time.get_ticks_msec()) * 0.028) * 0.20
		visual.modulate = Color(1.0, pulse, pulse, 1.0)
		if _charge_windup <= 0.0:
			_charge_direction = to_player
			_charge_active = 0.56
		return

	visual.modulate = _base_modulate
	_charge_cooldown -= delta
	velocity = to_player * move_speed
	if _charge_cooldown <= 0.0 and distance < 460.0:
		_charge_windup = 0.46
		_charge_cooldown = maxf(1.55, 3.25 - minf(1.4, power_scale * 0.06))

func take_damage(amount: float, hit_direction: Vector2 = Vector2.ZERO, is_critical: bool = false) -> void:
	health -= amount
	if not parts.is_empty():
		var part: PixelPart = parts[randi() % parts.size()]
		part.add_blood_stain(Vector2i(randi_range(-2, 2), randi_range(-2, 2)))
	var blood_node: Node = get_tree().get_first_node_in_group("blood_system")
	if blood_node != null:
		blood_node.call("emit_burst", global_position, hit_direction, 7 if is_critical else 4)
	if health <= 0.0:
		_die(hit_direction)

func _die(hit_direction: Vector2) -> void:
	var blood_node: Node = get_tree().get_first_node_in_group("blood_system")
	if blood_node != null:
		blood_node.call("emit_burst", global_position, hit_direction, 16 if elite else 11)
		var tint: Color = Color("ffcf4d") if enemy_kind == "chick" else Color("ff9fbd")
		blood_node.call("spawn_chunk", global_position + Vector2(0, -8), "head", tint, hit_direction)
		blood_node.call("spawn_chunk", global_position, "body", tint, hit_direction.rotated(0.6))
		blood_node.call("spawn_chunk", global_position + Vector2(0, 8), "leg", tint, hit_direction.rotated(-0.6))
	var game_node: Node = get_tree().get_first_node_in_group("game")
	if game_node != null:
		game_node.call("on_enemy_killed", global_position, xp_reward)
	queue_free()
