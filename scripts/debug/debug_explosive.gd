class_name DebugExplosive
extends Node2D

signal detonated(center: Vector2, mode: String)

var mode: String = "bomb"
var origin: Vector2 = Vector2.ZERO
var target: Vector2 = Vector2.ZERO
var age: float = 0.0
var flight_time: float = 0.48
var texture: Texture2D

func configure(from: Vector2, to: Vector2, explosive_mode: String) -> void:
	origin = from
	target = to
	mode = explosive_mode
	global_position = from
	z_index = 55
	var size: Vector2i = Vector2i(20, 20)
	var path: String = "res://assets/fx/MorangoFullGrande.png"
	if mode == "cluster":
		path = "res://assets/weapons/ama_cupcake.png"
		size = Vector2i(22, 18)
	elif mode == "nuke":
		size = Vector2i(28, 28)
	texture = CutoutArtPart.make_small_texture(path, size)
	queue_redraw()

func _process(delta: float) -> void:
	age += delta
	var t: float = clampf(age / flight_time, 0.0, 1.0)
	var arc: float = sin(t * PI) * (80.0 if mode == "nuke" else 52.0)
	global_position = origin.lerp(target, t) + Vector2(0.0, -arc)
	rotation += delta * (8.0 if mode != "nuke" else 5.0)
	queue_redraw()
	if t >= 1.0:
		detonated.emit(target, mode)
		queue_free()

func _draw() -> void:
	if texture == null:
		return
	var texture_size: Vector2 = texture.get_size()
	draw_texture(texture, -texture_size * 0.5)
