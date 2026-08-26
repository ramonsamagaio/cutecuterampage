class_name TaffiAimRig
extends Node

@export var visual_scale: float = 3.0
@export var aim_speed: float = 20.0
@export var support_arm_weight: float = 0.72
@export var max_aim_angle: float = 0.82

var _taffi: TaffiController
var _visual: Node2D
var _arm_weapon: Bone2D
var _arm_support: Bone2D
var _weapon_visual: TaffiWeaponVisual
var _cached_target: Node2D
var _retarget_timer: float = 0.0
var _aim_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	_taffi = get_parent() as TaffiController
	if _taffi == null:
		set_process(false)
		return
	_visual = _taffi.get_node("Visual") as Node2D
	_arm_weapon = _taffi.get_node("Visual/Skeleton2D/HipRoot/Torso/ArmWeapon") as Bone2D
	_arm_support = _taffi.get_node("Visual/Skeleton2D/HipRoot/Torso/ArmBack") as Bone2D
	_weapon_visual = _taffi.get_node("Visual/Skeleton2D/HipRoot/Torso/ArmWeapon/WeaponSocket/WeaponVisual") as TaffiWeaponVisual

func _process(delta: float) -> void:
	if _taffi == null or not is_instance_valid(_taffi):
		return
	var facing: float = -1.0 if _visual.scale.x < 0.0 else 1.0
	_visual.scale = Vector2(visual_scale * facing, visual_scale)
	if _taffi.special_channeling:
		var mouse_direction: Vector2 = _taffi.global_position.direction_to(_taffi.get_global_mouse_position())
		if mouse_direction.length_squared() > 0.001:
			_aim_direction = mouse_direction.normalized()
	else:
		_retarget_timer -= delta
		if _retarget_timer <= 0.0 or not is_instance_valid(_cached_target):
			_retarget_timer = 0.065
			var game: Node = get_tree().get_first_node_in_group("game")
			_cached_target = null
			if game != null:
				_cached_target = game.call("get_nearest_enemy", _taffi.global_position) as Node2D
		if is_instance_valid(_cached_target):
			var muzzle_origin: Vector2 = _taffi.global_position
			if is_instance_valid(_weapon_visual):
				muzzle_origin = _weapon_visual.get_muzzle_global_position()
			var desired: Vector2 = muzzle_origin.direction_to(_cached_target.global_position)
			if desired.length_squared() > 0.001:
				_aim_direction = desired.normalized()

	if absf(_aim_direction.x) > 0.08:
		facing = signf(_aim_direction.x)
		_visual.scale = Vector2(visual_scale * facing, visual_scale)

	var local_dir: Vector2 = _aim_direction
	if facing < 0.0:
		local_dir.x *= -1.0
	var active_max_angle: float = 1.08 if _taffi.special_channeling else max_aim_angle
	var target_angle: float = clampf(local_dir.angle(), -active_max_angle, active_max_angle)
	var weight: float = minf(1.0, delta * (24.0 if _taffi.special_channeling else aim_speed))
	_arm_weapon.rotation = lerp_angle(_arm_weapon.rotation, target_angle, weight)

	# The special is visibly two-handed: the support arm follows the cannon much more closely.
	var active_support_weight: float = 0.90 if _taffi.special_channeling else support_arm_weight
	var support_bias: float = -0.015 if _taffi.special_channeling else 0.035
	var support_target: float = target_angle * active_support_weight + support_bias
	_arm_support.rotation = lerp_angle(_arm_support.rotation, support_target, weight * 0.94)
