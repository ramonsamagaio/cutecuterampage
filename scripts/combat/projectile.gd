class_name CuteProjectile
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var damage: float = 8.0
var life: float = 1.5
var projectile_kind: String = "heart"
var critical: bool = false
var pierce_remaining: int = 0
var _hit_ids: Dictionary[int, bool] = {}

func configure(origin: Vector2, direction: Vector2, amount: float, kind: String = "heart", pierce: int = 0, speed: float = 390.0) -> void:
	global_position = origin
	velocity = direction.normalized() * speed
	damage = amount
	projectile_kind = kind
	pierce_remaining = maxi(0, pierce)
	rotation = direction.angle()
	critical = randf() < (0.13 if projectile_kind == "heartstorm" else 0.08)
	life = 1.9 if projectile_kind == "heartstorm" else 1.5
	queue_redraw()

func _process(delta: float) -> void:
	position += velocity * delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	for enemy_node: Node in get_tree().get_nodes_in_group("enemy"):
		var enemy: Node2D = enemy_node as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var id: int = enemy.get_instance_id()
		if _hit_ids.has(id):
			continue
		var hit_radius: float = 17.0 if projectile_kind == "heartstorm" else 13.0
		if global_position.distance_squared_to(enemy.global_position) <= hit_radius * hit_radius:
			_hit_ids[id] = true
			enemy.call("take_damage", damage * (1.75 if critical else 1.0), velocity.normalized(), critical)
			if pierce_remaining > 0:
				pierce_remaining -= 1
				velocity *= 0.96
			else:
				queue_free()
				return

func _draw() -> void:
	match projectile_kind:
		"heartstorm":
			draw_rect(Rect2(-5, -3, 4, 4), Color("ff4b94"))
			draw_rect(Rect2(1, -3, 4, 4), Color("ff4b94"))
			draw_rect(Rect2(-6, 0, 12, 4), Color("ff4b94"))
			draw_rect(Rect2(-4, 4, 8, 3), Color("e52f76"))
			draw_rect(Rect2(-1, 7, 2, 2), Color("e52f76"))
			draw_rect(Rect2(-3, -2, 2, 2), Color("fff2f8"))
		"star":
			draw_rect(Rect2(-3, -1, 6, 2), Color("ffd64d"))
			draw_rect(Rect2(-1, -3, 2, 6), Color("ffd64d"))
			draw_rect(Rect2(-1, -1, 2, 2), Color("fff7c2"))
		"candy":
			draw_rect(Rect2(-4, -2, 8, 4), Color("ff6ca8"))
			draw_rect(Rect2(-6, -1, 2, 2), Color("f6b6dc"))
			draw_rect(Rect2(4, -1, 2, 2), Color("f6b6dc"))
		_:
			draw_rect(Rect2(-3, -2, 2, 2), Color("ff62a0"))
			draw_rect(Rect2(1, -2, 2, 2), Color("ff62a0"))
			draw_rect(Rect2(-4, 0, 8, 2), Color("ff62a0"))
			draw_rect(Rect2(-2, 2, 4, 2), Color("e93278"))
