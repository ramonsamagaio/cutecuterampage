class_name BloodDroplet
extends Node2D

var velocity := Vector2.ZERO
var life := 0.35
var size_px := 2
var shade := Color("c3183d")
var shape_variant: int = 0

func configure(local_origin: Vector2, initial_velocity: Vector2, lifetime: float, px_size: int, color: Color) -> void:
	position = local_origin
	velocity = initial_velocity
	life = lifetime
	size_px = px_size
	shade = color
	shape_variant = randi_range(0, 3)
	rotation = initial_velocity.angle()
	z_index = 30
	queue_redraw()

func _process(delta: float) -> void:
	position += velocity * delta
	velocity *= pow(0.12, delta)
	if velocity.length_squared() > 20.0:
		rotation = lerp_angle(rotation, velocity.angle(), minf(1.0, delta * 12.0))
	life -= delta
	if life <= 0.0:
		var blood = get_parent()
		if blood and blood.has_method("add_ground_splat"):
			blood.add_ground_splat(global_position, size_px + randi_range(0, 3), shade)
		queue_free()

func _draw() -> void:
	match shape_variant:
		0:
			draw_rect(Rect2(-size_px * 0.5, -size_px * 0.5, size_px, size_px), shade)
		1:
			# Long arterial fleck.
			draw_rect(Rect2(-float(size_px), -maxf(1.0, float(size_px) * 0.34), float(size_px) * 2.3, maxf(2.0, float(size_px) * 0.68)), shade)
		2:
			# Fat bead with a darker core.
			draw_circle(Vector2.ZERO, maxf(1.5, float(size_px) * 0.62), shade)
			draw_circle(Vector2(float(size_px) * 0.18, -float(size_px) * 0.16), maxf(1.0, float(size_px) * 0.24), shade.darkened(0.16))
		_:
			# Split fleck, reads as torn tissue/blood debris at speed.
			draw_rect(Rect2(-size_px, -1, size_px, maxi(2, size_px / 2)), shade)
			draw_rect(Rect2(1, -maxi(2, size_px / 2), maxi(2, size_px / 2), size_px), shade.lightened(0.05))
