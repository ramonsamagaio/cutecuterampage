class_name SugarBoss
extends CharacterBody2D

var boss_name: String = "QUEEN MALLOW"
var max_health: float = 1200.0
var health: float = 1200.0
var move_speed: float = 62.0
var contact_damage: float = 18.0
var power_scale: float = 1.0

var _attack_timer: float = 1.8
var _contact_cooldown: float = 0.0
var _dash_windup: float = 0.0
var _dash_active: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO
var _orbit_sign: float = 1.0
var _phase: int = 1

func configure(scale_value: float) -> void:
	power_scale = maxf(1.0, scale_value)

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")
	max_health *= power_scale
	contact_damage *= 1.0 + (power_scale - 1.0) * 0.16
	move_speed *= 1.0 + minf(0.22, (power_scale - 1.0) * 0.025)
	health = max_health
	_orbit_sign = -1.0 if randf() < 0.5 else 1.0
	z_index = 14
	queue_redraw()

func _physics_process(delta: float) -> void:
	_contact_cooldown = maxf(0.0, _contact_cooldown - delta)
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	_phase = 2 if health <= max_health * 0.52 else 1
	var to_player: Vector2 = global_position.direction_to(player.global_position)
	var distance: float = global_position.distance_to(player.global_position)

	if _dash_active > 0.0:
		_dash_active -= delta
		velocity = _dash_direction * move_speed * (5.0 if _phase == 2 else 4.2)
	elif _dash_windup > 0.0:
		_dash_windup -= delta
		velocity = Vector2.ZERO
		queue_redraw()
		if _dash_windup <= 0.0:
			_dash_direction = to_player
			_dash_active = 0.52
	else:
		var radial: Vector2 = to_player
		var tangent: Vector2 = to_player.rotated(PI * 0.5 * _orbit_sign)
		if distance > 310.0:
			velocity = radial * move_speed
		elif distance < 190.0:
			velocity = -radial * move_speed * 0.82 + tangent * move_speed * 0.35
		else:
			velocity = tangent * move_speed * 0.72

		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_choose_attack(to_player)

	move_and_slide()
	if distance < 54.0 and _contact_cooldown <= 0.0:
		player.call("take_damage", contact_damage)
		_contact_cooldown = 0.72
	queue_redraw()

func _choose_attack(to_player: Vector2) -> void:
	var roll: float = randf()
	if roll < (0.42 if _phase == 1 else 0.32):
		_fire_ring(to_player)
		_attack_timer = 2.1 if _phase == 1 else 1.45
	else:
		_dash_windup = 0.62 if _phase == 1 else 0.42
		_attack_timer = 2.7 if _phase == 1 else 1.9

func _fire_ring(to_player: Vector2) -> void:
	var game_node: Node = get_tree().get_first_node_in_group("game")
	if game_node == null:
		return
	var bullet_count: int = 12 if _phase == 1 else 18
	var speed: float = 205.0 if _phase == 1 else 245.0
	var offset_angle: float = to_player.angle() * 0.18
	for i: int in bullet_count:
		var angle: float = TAU * float(i) / float(bullet_count) + offset_angle
		game_node.call("spawn_enemy_projectile", global_position, Vector2.RIGHT.rotated(angle), contact_damage * 0.48, speed)
	if _phase == 2:
		for i: int in 5:
			var fan_angle: float = to_player.angle() + (float(i) - 2.0) * 0.15
			game_node.call("spawn_enemy_projectile", global_position, Vector2.RIGHT.rotated(fan_angle), contact_damage * 0.55, speed * 1.12)

func take_damage(amount: float, hit_direction: Vector2 = Vector2.ZERO, is_critical: bool = false) -> void:
	# Screen-clear attacks should feel enormous without deleting a boss in a single tick.
	var applied_damage: float = amount
	if amount >= 1000.0:
		applied_damage = 24.0 * power_scale
	health = maxf(0.0, health - applied_damage)
	var blood_node: Node = get_tree().get_first_node_in_group("blood_system")
	if blood_node != null:
		blood_node.call("emit_burst", global_position + hit_direction * 12.0, hit_direction, 6 if is_critical else 3)
	if health <= 0.0:
		_die(hit_direction)

func _die(hit_direction: Vector2) -> void:
	var blood_node: Node = get_tree().get_first_node_in_group("blood_system")
	if blood_node != null:
		blood_node.call("emit_burst", global_position, hit_direction, 44)
		for i: int in 7:
			var chunk_dir: Vector2 = Vector2.RIGHT.rotated(TAU * float(i) / 7.0)
			blood_node.call("spawn_chunk", global_position + chunk_dir * 18.0, "body", Color("ffd2e2"), chunk_dir)
	var game_node: Node = get_tree().get_first_node_in_group("game")
	if game_node != null:
		game_node.call("on_boss_defeated", global_position, boss_name)
	queue_free()

func get_health_ratio() -> float:
	if max_health <= 0.0:
		return 0.0
	return clampf(health / max_health, 0.0, 1.0)

func get_display_name() -> String:
	return boss_name

func _draw() -> void:
	var pulse: float = 0.0
	if _dash_windup > 0.0:
		pulse = 0.5 + sin(float(Time.get_ticks_msec()) * 0.035) * 0.5
	var ink: Color = Color("32182f")
	var white: Color = Color("fff6f2")
	var pink: Color = Color("ff86b2")
	var hot: Color = Color("ee3f82")
	var gold: Color = Color("ffd65f")
	var eye: Color = Color("221523")
	var warning: Color = Color(1.5, 0.20, 0.42, pulse * 0.32)
	if pulse > 0.02:
		draw_circle(Vector2.ZERO, 58.0 + pulse * 18.0, warning)

	draw_circle(Vector2.ZERO, 45.0, ink)
	draw_circle(Vector2.ZERO, 40.0, white)
	draw_rect(Rect2(-34, -42, 20, 23), ink)
	draw_rect(Rect2(14, -42, 20, 23), ink)
	draw_rect(Rect2(-31, -39, 15, 20), white)
	draw_rect(Rect2(16, -39, 15, 20), white)
	draw_rect(Rect2(-24, -35, 7, 11), pink)
	draw_rect(Rect2(18, -35, 7, 11), pink)
	draw_rect(Rect2(-22, -7, 8, 10), eye)
	draw_rect(Rect2(14, -7, 8, 10), eye)
	draw_rect(Rect2(-4, 5, 8, 5), hot)
	draw_rect(Rect2(-23, 12, 13, 7), pink)
	draw_rect(Rect2(10, 12, 13, 7), pink)
	draw_rect(Rect2(-24, -60, 48, 12), ink)
	draw_rect(Rect2(-21, -57, 42, 8), gold)
	draw_rect(Rect2(-20, -69, 9, 14), gold)
	draw_rect(Rect2(-4, -74, 9, 19), gold)
	draw_rect(Rect2(12, -69, 9, 14), gold)
	if _phase == 2:
		draw_rect(Rect2(-46, 36, 92, 5), hot)
