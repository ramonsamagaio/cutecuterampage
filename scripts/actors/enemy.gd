class_name CuteEnemy
extends CharacterBody2D

var enemy_kind: String = "chick"
var archetype: String = "chaser"
var elite: bool = false
var elite_affix: String = ""
var power_scale: float = 1.0
var max_health: float = 26.0
var health: float = 26.0
var move_speed: float = 56.0
var contact_damage: float = 6.0
var attack_cooldown: float = 0.0
var xp_reward: int = 1
var parts: Array[CutoutArtPart] = []
var visual: Node2D

var _shoot_timer: float = 1.0
var _charge_cooldown: float = 2.0
var _charge_windup: float = 0.0
var _charge_active: float = 0.0
var _charge_direction: Vector2 = Vector2.ZERO
var _strafe_sign: float = 1.0
var _base_modulate: Color = Color.WHITE
var _anim_phase: float = 0.0
var _head_art: CutoutArtPart
var _arm_l: CutoutArtPart
var _arm_r: CutoutArtPart
var _leg_l: CutoutArtPart
var _leg_r: CutoutArtPart
var _tail_art: CutoutArtPart
var _knockback_velocity: Vector2 = Vector2.ZERO
var _hit_flash: float = 0.0
var _dying: bool = false
var _game_node: Node
var _player_node: Node2D
var _blood_node: Node

const REGISTERED_ENEMY_CANVAS: Vector2 = Vector2(36.0, 41.0)
const BASE_VISUAL_SCALE: float = 2.36

func _ready() -> void:
	add_to_group("enemy")
	_game_node = get_tree().get_first_node_in_group("game")
	_player_node = get_tree().get_first_node_in_group("player") as Node2D
	_blood_node = get_tree().get_first_node_in_group("blood_system")
	if _game_node != null:
		_game_node.call("register_enemy", self)
	_build_shadow()
	visual = Node2D.new()
	visual.name = "Visual"
	visual.scale = Vector2(BASE_VISUAL_SCALE, BASE_VISUAL_SCALE) * (1.22 if elite else 1.0)
	add_child(visual)

	if enemy_kind == "pig":
		max_health = 52.0
		move_speed = 45.0
		contact_damage = 9.0
		xp_reward = 2
	else:
		max_health = 26.0
		move_speed = 61.0
		contact_damage = 6.2
		xp_reward = 1

	match archetype:
		"shooter":
			max_health *= 0.88
			move_speed *= 0.88
			xp_reward += 1
			_base_modulate = Color(0.96, 0.88, 1.0, 1.0)
			_shoot_timer = randf_range(0.40, 1.05)
		"charger":
			max_health *= 1.38
			move_speed *= 0.98
			contact_damage *= 1.24
			xp_reward += 1
			_charge_cooldown = randf_range(0.9, 2.1)
		_:
			_base_modulate = Color.WHITE

	max_health *= power_scale
	contact_damage *= 1.0 + maxf(0.0, power_scale - 1.0) * 0.27
	move_speed *= 1.0 + minf(0.34, maxf(0.0, power_scale - 1.0) * 0.028)
	if elite:
		max_health *= 2.8
		move_speed *= 1.12
		contact_damage *= 1.45
		xp_reward *= 3
		_apply_elite_affix()
	health = max_health
	visual.modulate = _base_modulate
	_strafe_sign = -1.0 if randf() < 0.5 else 1.0
	_build_parts()

func _exit_tree() -> void:
	if _game_node != null and is_instance_valid(_game_node):
		_game_node.call("unregister_enemy", self)

func _build_shadow() -> void:
	var shadow: Polygon2D = Polygon2D.new()
	shadow.name = "GroundShadow"
	shadow.position = Vector2(0, 14)
	shadow.polygon = PackedVector2Array([
		Vector2(-16, 0), Vector2(-12, -4), Vector2(-5, -6), Vector2(5, -6),
		Vector2(12, -4), Vector2(16, 0), Vector2(11, 4), Vector2(4, 6),
		Vector2(-4, 6), Vector2(-11, 4)
	])
	shadow.color = Color(0.12, 0.18, 0.10, 0.20)
	shadow.z_index = -8
	add_child(shadow)

func _apply_elite_affix() -> void:
	match elite_affix:
		"swift":
			move_speed *= 1.42
			max_health *= 0.86
			_base_modulate = Color(0.72, 1.0, 0.92, 1.0)
		"tank":
			max_health *= 1.72
			move_speed *= 0.78
			contact_damage *= 1.18
			visual.scale *= 1.18
			_base_modulate = Color(1.0, 0.82, 0.62, 1.0)
		"volatile":
			contact_damage *= 1.24
			_base_modulate = Color(1.0, 0.70, 0.88, 1.0)
		_:
			_base_modulate = Color(1.0, 0.88, 0.96, 1.0)

func _build_parts() -> void:
	if enemy_kind == "pig":
		_head_art = _add_registered_part("res://assets/enemy/porco_cabeca.png", 2)
		_add_registered_part("res://assets/enemy/porco_corpo.png", 0)
		_arm_l = _add_registered_part("res://assets/enemy/porco_maoesq.png", 1)
		_arm_r = _add_registered_part("res://assets/enemy/MaoDir.png", 1)
		_leg_l = _add_registered_part("res://assets/enemy/PernsEsq.png", -1)
		_leg_r = _add_registered_part("res://assets/enemy/porco_pernadir.png", -1)
	else:
		_head_art = _add_registered_part("res://assets/enemy/Pinto_cabeca.png", 2)
		_add_registered_part("res://assets/enemy/pinto_corpo.png", 0)
		_arm_l = _add_registered_part("res://assets/enemy/Pinto_Maoesq.png", 1)
		_arm_r = _add_registered_part("res://assets/enemy/pinto_maodir.png", 1)
		_leg_l = _add_registered_part("res://assets/enemy/pinto_peEsq.png", -1)
		_leg_r = _add_registered_part("res://assets/enemy/Pinto_PeDir.png", -1)
		_tail_art = _add_registered_part("res://assets/enemy/Pinto_rabinho.png", -2)

func _add_registered_part(path: String, layer: int) -> CutoutArtPart:
	var part: CutoutArtPart = CutoutArtPart.new()
	part.position = Vector2.ZERO
	part.art_z_index = layer
	part.configure(path, REGISTERED_ENEMY_CANVAS, Vector2(0.5, 0.5))
	visual.add_child(part)
	parts.append(part)
	return part

func _physics_process(delta: float) -> void:
	if _dying:
		return
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	_hit_flash = maxf(0.0, _hit_flash - delta)
	if _player_node == null or not is_instance_valid(_player_node):
		_player_node = get_tree().get_first_node_in_group("player") as Node2D
	if _player_node == null:
		return
	var to_player: Vector2 = global_position.direction_to(_player_node.global_position)
	var distance: float = global_position.distance_to(_player_node.global_position)
	visual.modulate = _base_modulate

	match archetype:
		"shooter": _move_shooter(delta, to_player, distance)
		"charger": _move_charger(delta, to_player, distance)
		_: velocity = to_player * move_speed

	velocity += _knockback_velocity
	move_and_slide()
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, delta * 560.0)
	if _game_node != null and is_instance_valid(_game_node):
		_game_node.call("update_enemy_spatial", self)
	if absf(velocity.x) > 0.1:
		visual.scale.x = absf(visual.scale.x) * signf(velocity.x)
	_animate_parts(delta)
	if _hit_flash > 0.0:
		visual.modulate = Color(1.55, 0.74, 0.98, 1.0)

	if distance < 42.0 and attack_cooldown <= 0.0:
		var impact_multiplier: float = 1.55 if archetype == "charger" and _charge_active > 0.0 else 1.0
		_player_node.call("take_damage", contact_damage * impact_multiplier)
		if _game_node != null:
			_game_node.call("add_screen_shake", 4.2 if impact_multiplier > 1.0 else 2.8, 0.12)
		attack_cooldown = 0.86

func _animate_parts(delta: float) -> void:
	_anim_phase = fmod(_anim_phase + delta * (7.0 + move_speed * 0.018), TAU)
	var swing: float = sin(_anim_phase)
	var step: float = 1.0 if swing >= 0.0 else -1.0
	visual.position.y = -roundf(absf(sin(_anim_phase * 2.0)) * 1.3)
	if is_instance_valid(_head_art): _head_art.position = Vector2(0.0, -1.0 if absf(swing) > 0.66 else 0.0)
	if is_instance_valid(_arm_l): _arm_l.position = Vector2(0.0, step * 1.4)
	if is_instance_valid(_arm_r): _arm_r.position = Vector2(0.0, -step * 1.4)
	if is_instance_valid(_leg_l): _leg_l.position = Vector2(0.0, -1.4 if step > 0.0 else 0.0)
	if is_instance_valid(_leg_r): _leg_r.position = Vector2(0.0, -1.4 if step < 0.0 else 0.0)
	if is_instance_valid(_tail_art): _tail_art.position = Vector2(-1.3 if swing > 0.35 else 0.0, 0.0)

func _move_shooter(delta: float, to_player: Vector2, distance: float) -> void:
	if distance > 295.0:
		velocity = to_player * move_speed
	elif distance < 175.0:
		velocity = -to_player * move_speed * 0.82
	else:
		velocity = to_player.rotated(PI * 0.5 * _strafe_sign) * move_speed * 0.58
	_shoot_timer -= delta
	if _shoot_timer <= 0.0 and distance < 590.0:
		if _game_node != null:
			var projectile_damage: float = contact_damage * 0.74
			var projectile_speed: float = 195.0 + minf(135.0, maxf(0.0, power_scale - 1.0) * 11.0)
			_game_node.call("spawn_enemy_projectile", global_position, to_player, projectile_damage, projectile_speed)
		var cadence: float = maxf(0.66, 1.46 - minf(0.64, power_scale * 0.058))
		_shoot_timer = cadence + randf_range(-0.10, 0.15)

func _move_charger(delta: float, to_player: Vector2, distance: float) -> void:
	if _charge_active > 0.0:
		_charge_active -= delta
		velocity = _charge_direction * move_speed * 3.45
		visual.modulate = Color(1.0, 0.56, 0.68, 1.0)
		return
	if _charge_windup > 0.0:
		_charge_windup -= delta
		velocity = Vector2.ZERO
		var pulse: float = 0.72 + sin(float(Time.get_ticks_msec()) * 0.028) * 0.20
		visual.modulate = Color(1.0, pulse, pulse, 1.0)
		if _charge_windup <= 0.0:
			_charge_direction = to_player
			_charge_active = 0.58
		return
	_charge_cooldown -= delta
	velocity = to_player * move_speed
	if _charge_cooldown <= 0.0 and distance < 480.0:
		_charge_windup = 0.42
		_charge_cooldown = maxf(1.40, 3.05 - minf(1.45, power_scale * 0.065))

func take_damage(amount: float, hit_direction: Vector2 = Vector2.ZERO, is_critical: bool = false) -> void:
	if _dying:
		return
	health -= amount
	_hit_flash = 0.085 if not is_critical else 0.13
	var push_dir: Vector2 = hit_direction.normalized()
	if push_dir == Vector2.ZERO:
		push_dir = Vector2.RIGHT.rotated(randf() * TAU)
	var impulse: float = 78.0 + minf(125.0, amount * 4.4)
	if is_critical:
		impulse *= 1.48
	_knockback_velocity += push_dir * impulse
	if _knockback_velocity.length() > 290.0:
		_knockback_velocity = _knockback_velocity.normalized() * 290.0
	if not parts.is_empty():
		var part: CutoutArtPart = parts[randi() % parts.size()]
		part.add_random_blood_stain(3 if is_critical else 1)
	var root: Node = get_tree().current_scene
	if root != null:
		var number: DamageNumber = DamageNumber.new()
		root.add_child(number)
		number.configure(global_position + Vector2(randf_range(-9.0, 9.0), -28.0), amount, is_critical)
	if _blood_node == null or not is_instance_valid(_blood_node):
		_blood_node = get_tree().get_first_node_in_group("blood_system")
	if _blood_node != null:
		_blood_node.call("emit_burst", global_position, push_dir, 13 if is_critical else 7)
	if _game_node != null:
		_game_node.call("on_enemy_hit_feedback", global_position, is_critical, amount)
	if health <= 0.0:
		_dying = true
		_die(push_dir)

func _die(hit_direction: Vector2) -> void:
	if _blood_node != null:
		_blood_node.call("emit_burst", global_position, hit_direction, 46 if elite else 30)
		_blood_node.call("add_massive_splat", global_position, 14 if elite else 9, Color("a60930"))
		var chunk_parts: Array[CutoutArtPart] = []
		for part: CutoutArtPart in parts:
			chunk_parts.append(part)
		chunk_parts.shuffle()
		var chunk_count: int = mini(chunk_parts.size(), 6 if elite else 4)
		for i: int in chunk_count:
			var chunk_part: CutoutArtPart = chunk_parts[i]
			var force_dir: Vector2 = hit_direction
			if force_dir == Vector2.ZERO:
				force_dir = Vector2.RIGHT.rotated(randf() * TAU)
			force_dir = force_dir.rotated(randf_range(-1.18, 1.18))
			var scaled_size: Vector2 = chunk_part.target_size * absf(visual.scale.x)
			_blood_node.call("spawn_art_chunk", global_position, chunk_part.texture_path, scaled_size, force_dir * randf_range(100.0, 185.0))
	if elite and elite_affix == "volatile" and _game_node != null:
		for i: int in 12:
			var angle: float = TAU * float(i) / 12.0
			_game_node.call("spawn_enemy_projectile", global_position, Vector2.RIGHT.rotated(angle), contact_damage * 0.42, 235.0)
	if _game_node != null:
		_game_node.call("on_enemy_killed", global_position, xp_reward, elite)
	queue_free()
