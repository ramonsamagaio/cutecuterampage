class_name BloodDroplet
extends Node2D

var velocity := Vector2.ZERO
var life := 0.35
var size_px := 2
var shade := Color("c3183d")

func configure(local_origin: Vector2, initial_velocity: Vector2, lifetime: float, px_size: int, color: Color) -> void:
	position = local_origin
	velocity = initial_velocity
	life = lifetime
	size_px = px_size
	shade = color
	z_index = 30
	queue_redraw()

func _process(delta: float) -> void:
	position += velocity * delta
	velocity *= pow(0.12, delta)
	life -= delta
	if life <= 0.0:
		var blood = get_parent()
		if blood and blood.has_method("add_ground_splat"):
			blood.add_ground_splat(global_position, size_px + randi_range(0, 2), shade)
		queue_free()

func _draw() -> void:
	draw_rect(Rect2(-size_px * 0.5, -size_px * 0.5, size_px, size_px), shade)
