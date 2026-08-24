class_name CuteFX
extends Node2D

var art: CutoutArtPart
var lifetime: float = 0.22
var age: float = 0.0
var drift: Vector2 = Vector2.ZERO
var spin_speed: float = 0.0
var start_scale: float = 0.8
var end_scale: float = 1.25

func _ready() -> void:
	add_to_group("cute_fx")
	z_as_relative = false
	z_index = 45

func configure(global_pos: Vector2, texture_path: String, target_size: Vector2, life: float, initial_drift: Vector2 = Vector2.ZERO, spin: float = 0.0, from_scale: float = 0.8, to_scale: float = 1.25) -> void:
	global_position = global_pos
	lifetime = maxf(0.05, life)
	drift = initial_drift
	spin_speed = spin
	start_scale = from_scale
	end_scale = to_scale
	art = CutoutArtPart.new()
	art.name = "FXArt"
	art.configure(texture_path, target_size, Vector2(0.5, 0.5))
	add_child(art)
	scale = Vector2.ONE * start_scale

func _process(delta: float) -> void:
	age += delta
	position += drift * delta
	rotation += spin_speed * delta
	var t: float = clampf(age / lifetime, 0.0, 1.0)
	var s: float = lerpf(start_scale, end_scale, t)
	scale = Vector2.ONE * s
	modulate.a = 1.0 - smoothstep(0.55, 1.0, t)
	if age >= lifetime:
		queue_free()
