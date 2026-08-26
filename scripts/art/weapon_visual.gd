@tool
class_name TaffiWeaponVisual
extends Node2D

const HEART_PATH: String = "res://assets/weapons/arma_heart.png"
const CUPCAKE_PATH: String = "res://assets/weapons/ama_cupcake.png"
const STAR_PATH: String = "res://assets/weapons/arma_star.png"
const BOW_PATH: String = "res://assets/weapons/arma_arco.png"

@export_enum("heart", "star", "bow", "cupcake") var preview_kind: String = "heart":
	set(value):
		preview_kind = value
		if Engine.is_editor_hint() and is_inside_tree():
			_apply_kind(preview_kind, true)
@export var fit_offset: Vector2 = Vector2.ZERO:
	set(value):
		fit_offset = value
		if Engine.is_editor_hint() and is_inside_tree():
			_apply_kind(preview_kind, true)
@export var fit_rotation_degrees: float = 0.0:
	set(value):
		fit_rotation_degrees = value
		if Engine.is_editor_hint() and is_inside_tree():
			_apply_kind(preview_kind, true)

var art: Sprite2D
var muzzle: Marker2D
var support_grip: Marker2D
var base_kind: String = "heart"
var current_kind: String = ""
var _override_time: float = 0.0

func _ready() -> void:
	_ensure_nodes()
	_apply_kind(preview_kind if Engine.is_editor_hint() else base_kind, true)

func _ensure_nodes() -> void:
	if art == null or not is_instance_valid(art):
		art = Sprite2D.new()
		art.name = "WeaponArt"
		art.centered = true
		art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		art.z_index = 6
		add_child(art)
	if muzzle == null or not is_instance_valid(muzzle):
		muzzle = Marker2D.new()
		muzzle.name = "Muzzle"
		add_child(muzzle)
	if support_grip == null or not is_instance_valid(support_grip):
		support_grip = Marker2D.new()
		support_grip.name = "SupportGrip"
		add_child(support_grip)

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or _override_time <= 0.0:
		return
	_override_time = maxf(0.0, _override_time - delta)
	if _override_time <= 0.0:
		_apply_kind(base_kind)

func set_base_weapon(kind: String) -> void:
	if base_kind == kind and current_kind == kind and _override_time <= 0.0:
		return
	base_kind = kind
	if _override_time <= 0.0:
		_apply_kind(kind)

func flash_weapon(kind: String, duration: float = 0.4) -> void:
	_override_time = maxf(_override_time, duration)
	_apply_kind(kind)

func get_muzzle_global_position() -> Vector2:
	return muzzle.global_position if is_instance_valid(muzzle) else global_position

func get_support_grip_global_position() -> Vector2:
	return support_grip.global_position if is_instance_valid(support_grip) else global_position

func _apply_kind(kind: String, force: bool = false) -> void:
	_ensure_nodes()
	if not force and current_kind == kind:
		return
	current_kind = kind
	var path: String = HEART_PATH
	var texture_size: Vector2i = Vector2i(22, 14)
	var art_pos: Vector2 = Vector2(7.2, 0.0)
	var muzzle_pos: Vector2 = Vector2(16.2, 0.0)
	var support_pos: Vector2 = Vector2(3.5, 1.0)
	var base_rotation: float = 0.0
	match kind:
		"cupcake":
			path = CUPCAKE_PATH
			texture_size = Vector2i(24, 16)
			art_pos = Vector2(7.8, -0.5)
			muzzle_pos = Vector2(17.6, -0.5)
			support_pos = Vector2(3.8, 1.8)
		"star":
			path = STAR_PATH
			texture_size = Vector2i(23, 15)
			art_pos = Vector2(7.5, -0.2)
			muzzle_pos = Vector2(16.8, -0.4)
			support_pos = Vector2(3.7, 1.2)
		"bow":
			path = BOW_PATH
			texture_size = Vector2i(22, 19)
			art_pos = Vector2(6.5, 0.0)
			muzzle_pos = Vector2(15.8, 0.0)
			support_pos = Vector2(3.0, 1.5)
			base_rotation = -0.04
		_:
			pass
	art.texture = CutoutArtPart.make_small_texture(path, texture_size)
	art.position = art_pos + fit_offset
	art.rotation = base_rotation + deg_to_rad(fit_rotation_degrees)
	muzzle.position = muzzle_pos + fit_offset
	support_grip.position = support_pos + fit_offset
