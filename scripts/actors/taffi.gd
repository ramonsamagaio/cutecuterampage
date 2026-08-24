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
var xp_needed: int = 5
var special_meter: float = 0.0
var combo: int = 0
var combo_timer: float = 0.0

var _fire_timer := 0.0
var _dash_timer := 0.0
var _dash_cooldown := 0.0
var _dash_direction := Vector2.RIGHT
var _walk_phase := 0.0
var _facing := 1.0

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

var _rest := {}

func _ready() -> void:
	add_to_group("player")
	hp = max_hp
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
		if event.keycode == KEY_SHIFT:
			_start_dash()
		elif event.keycode == KEY_SPACE:
			special_requested.emit()

func _physics_process(delta: float) -> void:
	_dash_cooldown = maxf(0.0, _dash_cooldown - delta)
	_fire_timer = maxf(0.0, _fire_timer - delta)
	combo_timer = maxf(0.0, combo_timer - delta)
	if combo_timer <= 0.0:
		combo = 0

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var wasd := Vector2.ZERO
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
		velocity = input_dir * move_speed
	move_and_slide()

	if input_dir.x != 0.0:
		_facing = signf(input_dir.x)
	_animate_skeleton(delta, input_dir.length_squared() > 0.01)
	_auto_fire()

func _start_dash() -> void:
	if _dash_cooldown > 0.0:
		return
	var dir := velocity.normalized()
	if dir == Vector2.ZERO:
		dir = Vector2(_facing, 0.0)
	_dash_direction = dir
	_dash_timer = 0.13
	_dash_cooldown = 0.82

func _animate_skeleton(delta: float, moving: bool) -> void:
	visual.scale = Vector2(3.0 * _facing, 3.0)
	if moving:
		_walk_phase = fmod(_walk_phase + delta * 10.0, TAU)
	else:
		_walk_phase = lerpf(_walk_phase, 0.0, minf(1.0, delta * 10.0))
	var s := sin(_walk_phase)
	var bounce := -round(abs(sin(_walk_phase * 2.0)) * (1.0 if moving else 0.35))
	hip.position = _rest["hip"] + Vector2(0, bounce)
	torso.position = _rest["torso"] + Vector2(0, round(-abs(sin(_walk_phase * 2.0 - 0.18)) * 0.5))
	head.position = _rest["head"] + Vector2(0, round(-abs(sin(_walk_phase * 2.0 - 0.32)) * 0.5))
	leg_l.position = _rest["leg_l"] + Vector2(round(s * 1.2), -round(maxf(0.0, s) * 1.0))
	leg_r.position = _rest["leg_r"] + Vector2(round(-s * 1.2), -round(maxf(0.0, -s) * 1.0))
	arm_back.rotation = s * 0.12 if moving else sin(Time.get_ticks_msec() * 0.003) * 0.025
	arm_weapon.rotation = -0.03 + (s * 0.025 if moving else 0.0)
	ear_l.rotation = sin(_walk_phase - 0.42) * 0.055 if moving else sin(Time.get_ticks_msec() * 0.0022) * 0.018
	ear_r.rotation = sin(_walk_phase - 0.56) * 0.05 if moving else sin(Time.get_ticks_msec() * 0.0020) * 0.015
	bow.rotation = sin(_walk_phase - 0.35) * 0.035 if moving else 0.0

func _auto_fire() -> void:
	if _fire_timer > 0.0:
		return
	var game := get_tree().get_first_node_in_group("game")
	if game == null:
		return
	var target: Node2D = game.get_nearest_enemy(global_position)
	if target == null:
		return
	var origin := weapon_socket.global_position
	var base_dir := origin.direction_to(target.global_position)
	if absf(base_dir.x) > 0.15:
		_facing = signf(base_dir.x)
	for i in multishot:
		var offset_index := float(i) - float(multishot - 1) * 0.5
		var dir := base_dir.rotated(offset_index * 0.09)
		game.spawn_projectile(origin, dir, damage, "heart")
	_fire_timer = fire_interval

func take_damage(amount: float) -> void:
	hp = maxf(0.0, hp - amount)
	var blood := get_tree().get_first_node_in_group("blood_system")
	if blood:
		blood.emit_burst(global_position, Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)), 5)
	if hp <= 0.0:
		# Placeholder respawn loop while the meta-game is not implemented.
		hp = max_hp
		global_position = Vector2.ZERO

func gain_xp(amount: int) -> void:
	xp += amount
	if xp >= xp_needed:
		xp -= xp_needed
		level += 1
		xp_needed = 5 + level * 4
		level_up_requested.emit()

func apply_upgrade(id: String) -> void:
	match id:
		"sugar_rush": fire_interval = maxf(0.09, fire_interval * 0.82)
		"heart_piercer": damage += 3.0
		"bubblegum_shoes": move_speed += 12.0
		"strawberry_core":
			max_hp += 12.0
			hp = minf(max_hp, hp + 20.0)
		"sprinkles": multishot = mini(5, multishot + 1)

func register_kill() -> void:
	combo += 1
	combo_timer = 2.3
	special_meter = minf(100.0, special_meter + 3.0 + minf(2.0, combo * 0.025))

func can_special() -> bool:
	return special_meter >= 100.0

func consume_special() -> void:
	special_meter = 0.0
	combo += 25
	combo_timer = 3.0

func get_combo_caption() -> String:
	if combo >= 120: return "STRAWBERRY JUICE!"
	if combo >= 70: return "SUGAR RUSH!"
	if combo >= 35: return "KAWAII!"
	if combo >= 12: return "CUTE!"
	return ""
