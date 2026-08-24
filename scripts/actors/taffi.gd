class_name TaffiController
extends CharacterBody2D

signal level_up_requested
signal special_requested

@export var move_speed: float = 118.0
@export var max_hp: float = 100.0

var hp: float = 100.0
var damage: float = 8.0
var fire_interval: float = 0.28
var multishot: int = 1
var level: int = 1
var xp: int = 0
var xp_needed: int = 7
var special_meter: float = 0.0
var combo: int = 0
var combo_timer: float = 0.0
var special_channeling: bool = false
var damage_taken_multiplier: float = 1.0
var special_charge_multiplier: float = 1.0

var heart_level: int = 1
var cupcake_level: int = 0
var orbit_level: int = 0
var heart_evolved: bool = false
var cupcake_evolved: bool = false
var orbit_evolved: bool = false

var cute_meter: float = 0.0
var _cute_decay_delay: float = 0.0

var _fire_timer: float = 0.0
var _cupcake_timer: float = 1.25
var _dash_timer: float = 0.0
var _dash_cooldown: float = 0.0
var _dash_cooldown_base: float = 0.82
var _dash_direction: Vector2 = Vector2.RIGHT
var _walk_phase: float = 0.0
var _facing: float = 1.0
var _invulnerable_timer: float = 0.0
var _perfect_dodge_flash: float = 0.0
var _perfect_dodge_lock: float = 0.0
var _upgrade_levels: Dictionary[String, int] = {}

@onready var visual: Node2D = $Visual
@onready var hip: Bone2D = $Visual/Skeleton2D/HipRoot
@onready var torso: Bone2D = $Visual/Skeleton2D/HipRoot/Torso
@onready var head: Bone2D = $Visual/Skeleton2D/HipRoot/Torso/Head
@onready var ear_l: Bone2D = $Visual/Skeleton2D/HipRoot/Torso/Head/EarL
@onready var ear_r: Bone2D = $Visual/Skeleton2D/HipRoot/Torso/Head/EarR
@onready var bow: Bone2D = $Visual/Skeleton2D/HipRoot/Torso/Head/Bow
@onready var arm_back: Bone2D = $Visual/Skeleton2D/HipRoot/Torso/ArmBack
@onready var arm_weapon: Bone2D = $Visual/Skeleton2D/HipRoot/Torso/ArmWeapon
@onready var weapon_socket: Marker2D = $Visual/Skeleton2D/HipRoot/Torso/ArmWeapon/WeaponSocket
@onready var leg_l: Bone2D = $Visual/Skeleton2D/HipRoot/LegL
@onready var leg_r: Bone2D = $Visual/Skeleton2D/HipRoot/LegR

var _rest: Dictionary[String, Vector2] = {}

func _ready() -> void:
	add_to_group("player")
	hp = max_hp
	xp_needed = _xp_required(level)
	_rest = {
		"hip": hip.position,
		"torso": torso.position,
		"head": head.position,
		"ear_l": ear_l.position,
		"ear_r": ear_r.position,
		"leg_l": leg_l.position,
		"leg_r": leg_r.position
	}

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SHIFT and not special_channeling:
			_start_dash()
		elif event.keycode == KEY_SPACE:
			special_requested.emit()

func _physics_process(delta: float) -> void:
	_dash_cooldown = maxf(0.0, _dash_cooldown - delta)
	_fire_timer = maxf(0.0, _fire_timer - delta)
	combo_timer = maxf(0.0, combo_timer - delta)
	_invulnerable_timer = maxf(0.0, _invulnerable_timer - delta)
	_perfect_dodge_flash = maxf(0.0, _perfect_dodge_flash - delta)
	_perfect_dodge_lock = maxf(0.0, _perfect_dodge_lock - delta)
	_cute_decay_delay = maxf(0.0, _cute_decay_delay - delta)
	if combo_timer <= 0.0:
		combo = 0
	if _cute_decay_delay <= 0.0 and cute_meter > 0.0 and not special_channeling:
		cute_meter = maxf(0.0, cute_meter - delta * 3.6)

	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var wasd: Vector2 = Vector2.ZERO
	if Input.is_key_pressed(KEY_A): wasd.x -= 1.0
	if Input.is_key_pressed(KEY_D): wasd.x += 1.0
	if Input.is_key_pressed(KEY_W): wasd.y -= 1.0
	if Input.is_key_pressed(KEY_S): wasd.y += 1.0
	if wasd.length_squared() > 0.0:
		input_dir = wasd.normalized()

	if _dash_timer > 0.0:
		_dash_timer -= delta
		velocity = _dash_direction * 330.0
	else:
		var channel_speed: float = 0.38 if special_channeling else 1.0
		velocity = input_dir * move_speed * channel_speed
	move_and_slide()

	if input_dir.x != 0.0 and not special_channeling:
		_facing = signf(input_dir.x)
	_animate_skeleton(delta, input_dir.length_squared() > 0.01)
	if not special_channeling:
		_update_weapons(delta)

func _start_dash() -> void:
	if _dash_cooldown > 0.0 or special_channeling:
		return
	var dir: Vector2 = velocity.normalized()
	if dir == Vector2.ZERO:
		dir = Vector2(_facing, 0.0)
	_dash_direction = dir
	_dash_timer = 0.15
	_dash_cooldown = _dash_cooldown_base

func _animate_skeleton(delta: float, moving: bool) -> void:
	visual.scale = Vector2(3.0 * _facing, 3.0)
	if moving:
		_walk_phase = fmod(_walk_phase + delta * (7.5 if special_channeling else 10.0), TAU)
	else:
		_walk_phase = lerpf(_walk_phase, 0.0, minf(1.0, delta * 10.0))
	var s: float = sin(_walk_phase)
	var bounce: float = -roundf(absf(sin(_walk_phase * 2.0)) * (0.55 if special_channeling else (1.0 if moving else 0.35)))
	hip.position = _rest["hip"] + Vector2(0.0, bounce)
	torso.position = _rest["torso"] + Vector2(0.0, roundf(-absf(sin(_walk_phase * 2.0 - 0.18)) * 0.5))
	head.position = _rest["head"] + Vector2(0.0, roundf(-absf(sin(_walk_phase * 2.0 - 0.32)) * 0.5))
	leg_l.position = _rest["leg_l"] + Vector2(roundf(s * 1.2), -roundf(maxf(0.0, s)))
	leg_r.position = _rest["leg_r"] + Vector2(roundf(-s * 1.2), -roundf(maxf(0.0, -s)))
	arm_back.rotation = s * 0.12 if moving else sin(float(Time.get_ticks_msec()) * 0.003) * 0.025
	arm_weapon.rotation = -0.03 + (s * 0.018 if moving else 0.0)
	ear_l.rotation = sin(_walk_phase - 0.42) * 0.055 if moving else sin(float(Time.get_ticks_msec()) * 0.0022) * 0.018
	ear_r.rotation = sin(_walk_phase - 0.56) * 0.05 if moving else sin(float(Time.get_ticks_msec()) * 0.0020) * 0.015
	bow.rotation = sin(_walk_phase - 0.35) * 0.035 if moving else 0.0

func _update_weapons(delta: float) -> void:
	_auto_fire_heart()
	_auto_fire_cupcake(delta)
	if orbit_level > 0:
		_sync_orbit()

func _auto_fire_heart() -> void:
	if _fire_timer > 0.0:
		return
	var game: Node = get_tree().get_first_node_in_group("game")
	if game == null:
		return
	var target: Node2D = game.call("get_nearest_enemy", global_position) as Node2D
	if target == null:
		return
	var origin: Vector2 = weapon_socket.global_position
	var base_dir: Vector2 = origin.direction_to(target.global_position)
	if absf(base_dir.x) > 0.15:
		_facing = signf(base_dir.x)
	var heart_bonus: float = 1.0 + float(maxi(0, heart_level - 1)) * 0.10
	var projectile_damage: float = damage * heart_bonus * get_cute_damage_multiplier()
	var kind: String = "heartstorm" if heart_evolved else "heart"
	var pierce: int = 3 if heart_evolved else 0
	var projectile_speed: float = 480.0 if heart_evolved else 390.0
	var shot_count: int = multishot + (1 if heart_evolved else 0)
	for i: int in shot_count:
		var offset_index: float = float(i) - float(shot_count - 1) * 0.5
		var spread: float = 0.072 if heart_evolved else 0.09
		var dir: Vector2 = base_dir.rotated(offset_index * spread)
		game.call("spawn_projectile", origin, dir, projectile_damage, kind, pierce, projectile_speed)
	var evolved_speed_bonus: float = 0.74 if heart_evolved else 1.0
	_fire_timer = fire_interval * evolved_speed_bonus

func _auto_fire_cupcake(delta: float) -> void:
	if cupcake_level <= 0:
		return
	_cupcake_timer -= delta
	if _cupcake_timer > 0.0:
		return
	var game: Node = get_tree().get_first_node_in_group("game")
	if game == null:
		return
	var target: Node2D = game.call("get_priority_enemy", global_position, 720.0) as Node2D
	if target == null:
		return
	var level_factor: float = float(cupcake_level)
	var mortar_damage: float = damage * (1.35 + level_factor * 0.42) * get_cute_damage_multiplier()
	var radius: float = 58.0 + level_factor * 7.0 + (32.0 if cupcake_evolved else 0.0)
	game.call("spawn_cupcake_mortar", weapon_socket.global_position, target.global_position, mortar_damage, radius, cupcake_evolved)
	_cupcake_timer = maxf(0.72, 3.15 - level_factor * 0.31) * (0.78 if cupcake_evolved else 1.0)

func _sync_orbit() -> void:
	var game: Node = get_tree().get_first_node_in_group("game")
	if game != null:
		game.call("ensure_love_orbit", self, orbit_level, orbit_evolved)

func take_damage(amount: float) -> void:
	if _dash_timer > 0.0 or _invulnerable_timer > 0.0:
		return
	var channel_reduction: float = 0.50 if special_channeling else 1.0
	var final_amount: float = amount * damage_taken_multiplier * channel_reduction
	hp = maxf(0.0, hp - final_amount)
	_invulnerable_timer = 0.28
	combo = floori(float(combo) * 0.58)
	combo_timer = minf(combo_timer, 1.1)
	cute_meter = maxf(0.0, cute_meter - 24.0)
	_cute_decay_delay = 0.35
	var blood: Node = get_tree().get_first_node_in_group("blood_system")
	if blood != null:
		blood.call("emit_burst", global_position, Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)), 5)
	if hp <= 0.0:
		hp = max_hp
		global_position = Vector2.ZERO
		special_channeling = false
		cute_meter = 0.0
		combo = 0

func gain_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_needed:
		xp -= xp_needed
		level += 1
		xp_needed = _xp_required(level)
		level_up_requested.emit()

func _xp_required(level_value: int) -> int:
	var scaled: float = pow(float(maxi(1, level_value)), 1.34) * 3.2
	return 4 + roundi(scaled)

func apply_upgrade(id: String) -> void:
	var previous_level: int = int(_upgrade_levels.get(id, 0))
	_upgrade_levels[id] = previous_level + 1
	match id:
		"sugar_rush": fire_interval = maxf(0.09, fire_interval * 0.82)
		"heart_piercer":
			damage += 3.0
			heart_level = mini(6, heart_level + 1)
		"bubblegum_shoes": move_speed += 12.0
		"strawberry_core":
			max_hp += 12.0
			hp = minf(max_hp, hp + 20.0)
		"sprinkles":
			multishot = mini(5, multishot + 1)
			heart_level = mini(6, heart_level + 1)
		"ribbon_reflex": _dash_cooldown_base = maxf(0.36, _dash_cooldown_base * 0.88)
		"plush_armor": damage_taken_multiplier = maxf(0.55, damage_taken_multiplier * 0.90)
		"love_battery": special_charge_multiplier += 0.18
		"cupcake_mortar": cupcake_level = mini(6, cupcake_level + 1)
		"love_orbit":
			orbit_level = mini(6, orbit_level + 1)
			_sync_orbit()

func can_take_upgrade(id: String) -> bool:
	match id:
		"sugar_rush": return fire_interval > 0.095
		"sprinkles": return multishot < 5
		"ribbon_reflex": return _dash_cooldown_base > 0.37
		"plush_armor": return damage_taken_multiplier > 0.56
		"cupcake_mortar": return cupcake_level < 6
		"love_orbit": return orbit_level < 6
		_: return true

func claim_evolution_chest() -> String:
	if not heart_evolved and heart_level >= 4 and multishot >= 3:
		heart_evolved = true
		return "EVOLUTION!  HEARTSTORM ♡"
	if not cupcake_evolved and cupcake_level >= 4:
		cupcake_evolved = true
		return "EVOLUTION!  BIRTHDAY MASSACRE!"
	if not orbit_evolved and orbit_level >= 4:
		orbit_evolved = true
		_sync_orbit()
		return "EVOLUTION!  HALO OF HUGS!"
	if cupcake_level <= 0:
		cupcake_level = 1
		return "NEW WEAPON!  CUPCAKE MORTAR"
	if orbit_level <= 0:
		orbit_level = 1
		_sync_orbit()
		return "NEW WEAPON!  LOVE ORBIT"
	damage += 6.0
	max_hp += 12.0
	hp = minf(max_hp, hp + 28.0)
	special_charge_multiplier += 0.12
	return "SUPER SUGAR CACHE!  POWER UP!"

func claim_bonus_chest() -> String:
	var pool: Array[String] = ["sugar_rush", "heart_piercer", "bubblegum_shoes", "strawberry_core", "sprinkles", "ribbon_reflex", "plush_armor", "love_battery", "cupcake_mortar", "love_orbit"]
	var available: Array[String] = []
	for upgrade_id: String in pool:
		if can_take_upgrade(upgrade_id):
			available.append(upgrade_id)
	if available.is_empty():
		damage += 3.0
		hp = minf(max_hp, hp + 18.0)
		return "SUGAR CACHE!  +POWER"
	var picked: String = available[randi_range(0, available.size() - 1)]
	apply_upgrade(picked)
	var names: Dictionary[String, String] = {
		"sugar_rush": "SUGAR RUSH",
		"heart_piercer": "HEART PIERCER",
		"bubblegum_shoes": "BUBBLEGUM SHOES",
		"strawberry_core": "STRAWBERRY CORE",
		"sprinkles": "SPRINKLES",
		"ribbon_reflex": "RIBBON REFLEX",
		"plush_armor": "PLUSH ARMOR",
		"love_battery": "LOVE BATTERY",
		"cupcake_mortar": "CUPCAKE MORTAR",
		"love_orbit": "LOVE ORBIT"
	}
	return "CHEST!  %s +1" % names[picked]

func register_kill() -> void:
	combo += 1
	combo_timer = 2.3
	var cute_gain: float = 1.6 + minf(2.4, float(combo) * 0.018)
	cute_meter = minf(100.0, cute_meter + cute_gain)
	_cute_decay_delay = 1.15
	if not special_channeling:
		var charge: float = (3.0 + minf(2.0, float(combo) * 0.025)) * special_charge_multiplier
		special_meter = minf(100.0, special_meter + charge)

func register_perfect_dodge() -> void:
	if _perfect_dodge_lock > 0.0:
		return
	_perfect_dodge_lock = 0.12
	_perfect_dodge_flash = 0.60
	combo += 6
	combo_timer = maxf(combo_timer, 2.6)
	cute_meter = minf(100.0, cute_meter + 11.0)
	_cute_decay_delay = 1.5
	if not special_channeling:
		special_meter = minf(100.0, special_meter + 9.0 * special_charge_multiplier)

func get_cute_damage_multiplier() -> float:
	return 1.0 + cute_meter * 0.004

func get_cute_xp_multiplier() -> float:
	return 1.0 + cute_meter * 0.0025

func get_cute_rank() -> String:
	if cute_meter >= 96.0: return "STRAWBERRY FEVER"
	if cute_meter >= 75.0: return "SUGAR RUSH"
	if cute_meter >= 50.0: return "KAWAII"
	if cute_meter >= 25.0: return "CUTE"
	return "SWEET"

func get_weapon_summary() -> String:
	var heart_name: String = "HEARTSTORM" if heart_evolved else "HEART BLASTER"
	var summary: String = "%s %d" % [heart_name, heart_level]
	if cupcake_level > 0:
		var cupcake_name: String = "BIRTHDAY MASSACRE" if cupcake_evolved else "CUPCAKE"
		summary += "   •   %s %d" % [cupcake_name, cupcake_level]
	if orbit_level > 0:
		var orbit_name: String = "HALO OF HUGS" if orbit_evolved else "LOVE ORBIT"
		summary += "   •   %s %d" % [orbit_name, orbit_level]
	return summary

func is_dashing() -> bool:
	return _dash_timer > 0.0

func begin_special_channel() -> void:
	special_channeling = true
	_dash_timer = 0.0

func end_special_channel() -> void:
	special_channeling = false

func set_special_aim(direction: Vector2) -> void:
	if absf(direction.x) > 0.05:
		_facing = signf(direction.x)

func get_level_value() -> int:
	return level

func can_special() -> bool:
	return special_meter >= 100.0 and not special_channeling

func consume_special() -> void:
	special_meter = 0.0
	combo += 25
	combo_timer = 3.0
	cute_meter = minf(100.0, cute_meter + 15.0)
	_cute_decay_delay = 2.0

func get_combo_caption() -> String:
	if _perfect_dodge_flash > 0.0: return "PERFECT!"
	if combo >= 120: return "STRAWBERRY JUICE!"
	if combo >= 70: return "SUGAR RUSH!"
	if combo >= 35: return "KAWAII!"
	if combo >= 12: return "CUTE!"
	return ""
