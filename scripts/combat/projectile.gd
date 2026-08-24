class_name CuteProjectile
extends Node2D

var velocity := Vector2.ZERO
var damage := 8.0
var life := 1.5
var projectile_kind := "heart"
var critical := false

func configure(origin: Vector2, direction: Vector2, amount: float, kind: String = "heart") -> void:
	global_position = origin
	velocity = direction.normalized() * 390.0
	damage = amount
	projectile_kind = kind
	rotation = direction.angle()
	critical = randf() < 0.08
	queue_redraw()

func _process(delta: float) -> void:
	position += velocity * delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_squared_to(enemy.global_position) <= 13.0 * 13.0:
			enemy.take_damage(damage * (1.75 if critical else 1.0), velocity.normalized(), critical)
			queue_free()
			return

func _draw() -> void:
	match projectile_kind:
		"star":
			draw_rect(Rect2(-3, -1, 6, 2), Color("ffd64d"))
			draw_rect(Rect2(-1, -3, 2, 6), Color("ffd64d"))
			draw_rect(Rect2(-1, -1, 2, 2), Color("fff7c2"))
		"candy":
			draw_rect(Rect2(-4, -2, 8, 4), Color("ff6ca8"))
			draw_rect(Rect2(-6, -1, 2, 2), Color("f6b6dc"))
			draw_rect(Rect2(4, -1, 2, 2), Color("f6b6dc"))
		_:
			# Tiny pixel heart.
			draw_rect(Rect2(-3, -2, 2, 2), Color("ff62a0"))
			draw_rect(Rect2(1, -2, 2, 2), Color("ff62a0"))
			draw_rect(Rect2(-4, 0, 8, 2), Color("ff62a0"))
			draw_rect(Rect2(-2, 2, 4, 2), Color("e93278"))
