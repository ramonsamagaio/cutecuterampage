class_name TaffiWeaponVisual
extends Node2D

const HEART_PATH: String = "res://assets/weapons/arma_heart.png"
const CUPCAKE_PATH: String = "res://assets/weapons/ama_cupcake.png"
const STAR_PATH: String = "res://assets/weapons/arma_star.png"
const BOW_PATH: String = "res://assets/weapons/arma_arco.png"

var art: CutoutArtPart
var base_kind: String = "heart"
var current_kind: String = ""
var _override_time: float = 0.0

func _ready() -> void:
	art = CutoutArtPart.new()
	art.name = "WeaponArt"
	art.z_index = 4
	add_child(art)
	_apply_kind(base_kind)

func _process(delta: float) -> void:
	if _override_time <= 0.0:
		return
	_override_time = maxf(0.0, _override_time - delta)
	if _override_time <= 0.0:
		_apply_kind(base_kind)

func set_base_weapon(kind: String) -> void:
	base_kind = kind
	if _override_time <= 0.0:
		_apply_kind(kind)

func flash_weapon(kind: String, duration: float = 0.4) -> void:
	_override_time = maxf(_override_time, duration)
	_apply_kind(kind)

func _apply_kind(kind: String) -> void:
	if art == null or not is_instance_valid(art):
		return
	if current_kind == kind and art.visible:
		return
	current_kind = kind
	# These sizes are display-canvas sizes only. The original PNGs are kept intact;
	# CutoutArtPart scales the Sprite2D and uses the pivot to place the grip on socket.
	match kind:
		"cupcake": art.configure(CUPCAKE_PATH, Vector2(18.0, 14.0), Vector2(0.16, 0.53))
		"star": art.configure(STAR_PATH, Vector2(18.0, 14.0), Vector2(0.16, 0.54))
		"bow": art.configure(BOW_PATH, Vector2(18.0, 18.0), Vector2(0.22, 0.52))
		_: art.configure(HEART_PATH, Vector2(18.0, 14.0), Vector2(0.16, 0.54))
