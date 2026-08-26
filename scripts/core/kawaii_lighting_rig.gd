class_name KawaiiLightingRig
extends Node2D

const UPDATE_INTERVAL: float = 1.0 / 20.0

var _player: Node2D
var _ambient: CanvasModulate
var _player_light: PointLight2D
var _spark_light: PointLight2D
var _update_timer: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	z_as_relative = false
	z_index = 2
	_build_ambient()
	_build_player_light()
	_build_spark_light()
	call_deferred("_bind_player")

func _build_ambient() -> void:
	_ambient = CanvasModulate.new()
	_ambient.name = "CandyAmbient"
	# Very light modulation only. It gives lights somewhere to live without turning the garden into night.
	_ambient.color = Color(0.955, 0.935, 0.970, 1.0)
	add_child(_ambient)

func _make_radial_texture(inner: Color, outer: Color, size_px: int = 256) -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([inner, outer])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = size_px
	texture.height = size_px
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	return texture

func _build_player_light() -> void:
	_player_light = PointLight2D.new()
	_player_light.name = "TaffiSoftLight"
	_player_light.texture = _make_radial_texture(Color(1.0, 0.74, 0.91, 0.95), Color(1.0, 0.34, 0.68, 0.0), 256)
	_player_light.texture_scale = 2.05
	_player_light.energy = 0.34
	_player_light.color = Color(1.0, 0.78, 0.92, 1.0)
	_player_light.blend_mode = Light2D.BLEND_MODE_ADD
	_player_light.shadow_enabled = false
	add_child(_player_light)

func _build_spark_light() -> void:
	# A tiny hot center makes weapon fire and high Cute values feel luminous without per-projectile lights.
	_spark_light = PointLight2D.new()
	_spark_light.name = "TaffiHotCenter"
	_spark_light.texture = _make_radial_texture(Color(1.0, 0.96, 0.72, 1.0), Color(1.0, 0.55, 0.82, 0.0), 128)
	_spark_light.texture_scale = 0.90
	_spark_light.energy = 0.10
	_spark_light.color = Color(1.0, 0.88, 0.76, 1.0)
	_spark_light.blend_mode = Light2D.BLEND_MODE_ADD
	_spark_light.shadow_enabled = false
	add_child(_spark_light)

func _bind_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D

func _process(delta: float) -> void:
	_time += delta
	_update_timer -= delta
	if _update_timer > 0.0:
		return
	_update_timer = UPDATE_INTERVAL
	if not is_instance_valid(_player):
		_bind_player()
	if not is_instance_valid(_player):
		return

	global_position = _player.global_position + Vector2(0, 4)
	var cute: float = clampf(float(_player.get("cute_meter")) / 100.0, 0.0, 1.0)
	var special: float = clampf(float(_player.get("special_meter")) / 100.0, 0.0, 1.0)
	var channeling: bool = bool(_player.get("special_channeling"))
	var breathe: float = 0.5 + sin(_time * 2.2) * 0.5

	_player_light.energy = 0.28 + cute * 0.15 + special * 0.07 + breathe * 0.025
	_player_light.texture_scale = 1.95 + cute * 0.28 + (0.42 if channeling else 0.0)
	_spark_light.energy = 0.08 + cute * 0.08 + special * 0.10 + (0.30 if channeling else 0.0)
	_spark_light.texture_scale = 0.82 + special * 0.16 + (0.48 if channeling else 0.0)

	# High-Cute runs become slightly warmer/brighter in the center while the ambience stays restrained.
	_ambient.color = Color(
		0.948 + cute * 0.025,
		0.928 + cute * 0.018,
		0.965 + cute * 0.020,
		1.0
	)
