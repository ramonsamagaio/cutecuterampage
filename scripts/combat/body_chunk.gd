class_name BodyChunk
extends Node2D

var velocity := Vector2.ZERO
var angular_velocity := 0.0
var life := 2.8
var chunk_kind := "body"
var tint := Color.WHITE
var landed := false

func configure(local_origin: Vector2, kind: String, color: Color, force: Vector2) -> void:
	position = local_origin
	chunk_kind = kind
	tint = color
	velocity = force + Vector2(randf_range(-110.0, 110.0), randf_range(-110.0, 110.0))
	angular_velocity = randf_range(-8.0, 8.0)
	life = randf_range(2.0, 3.5)
	z_index = 25
	queue_redraw()

func _process(delta: float) -> void:
	position += velocity * delta
	velocity *= pow(0.16, delta)
	rotation += angular_velocity * delta
	angular_velocity *= pow(0.25, delta)
	life -= delta
	if not landed and velocity.length() < 18.0:
		landed = true
		var blood = get_parent()
		if blood and blood.has_method("add_ground_splat"):
			blood.add_ground_splat(global_position, randi_range(3, 6), Color("a90e31"))
	if life <= 0.0:
		queue_free()

func _draw() -> void:
	var ink := Color("24152d")
	match chunk_kind:
		"head":
			draw_rect(Rect2(-4, -3, 8, 6), ink)
			draw_rect(Rect2(-3, -2, 6, 4), tint)
		"leg":
			draw_rect(Rect2(-2, -4, 4, 8), ink)
			draw_rect(Rect2(-1, -3, 2, 6), tint)
		_:
			draw_rect(Rect2(-4, -3, 8, 6), ink)
			draw_rect(Rect2(-3, -2, 6, 4), tint)
	# Blood permanently stuck to the flying piece.
	draw_rect(Rect2(-2, 1, 3, 2), Color("b41435"))
	draw_rect(Rect2(1, -2, 2, 2), Color("dd2347"))
