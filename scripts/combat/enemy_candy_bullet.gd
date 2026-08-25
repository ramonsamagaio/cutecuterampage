class_name EnemyCandyBullet
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var damage: float = 7.0
var life: float = 4.0
var hit_radius: float = 14.0
var perfect_radius: float = 30.0
var _pulse: float = 0.0

func configure(origin: Vector2, direction: Vector2, amount: float, speed: float) -> void:
	global_position = origin
	velocity = direction.normalized() * speed
	damage = amount
	rotation = direction.angle()
	z_index = 18
	_pulse = randf() * TAU
	queue_redraw()

func _process(delta: float) -> void:
	position += velocity * delta
	life -= delta
	_pulse = fmod(_pulse + delta * 10.0, TAU)
	scale = Vector2.ONE * (1.0 + sin(_pulse) * 0.05)
	if life <= 0.0:
		queue_free()
		return

	var player_node: Node = get_tree().get_first_node_in_group("player")
	var player_2d: Node2D = player_node as Node2D
	if player_node == null or player_2d == null:
		return
	var distance: float = global_position.distance_to(player_2d.global_position)
	var dashing: bool = bool(player_node.call("is_dashing"))
	if dashing and distance <= perfect_radius:
		player_node.call("register_perfect_dodge")
		queue_free()
		return
	if not dashing and distance <= hit_radius:
		player_node.call("take_damage", damage)
		queue_free()

func _draw() -> void:
	var ink: Color = Color("32152c")
	var hot: Color = Color("ff477f")
	var pale: Color = Color("ffd3e2")
	var yellow: Color = Color("ffd95f")
	# Larger hostile candy projectile so danger reads immediately in the chaos.
	draw_circle(Vector2.ZERO, 10.0, Color(1.45, 0.16, 0.72, 0.12))
	draw_rect(Rect2(-6, -3, 12, 6), ink)
	draw_rect(Rect2(-3, -6, 6, 12), ink)
	draw_rect(Rect2(-5, -2, 10, 4), hot)
	draw_rect(Rect2(-2, -5, 4, 10), hot)
	draw_rect(Rect2(-2, -2, 4, 4), pale)
	draw_rect(Rect2(-9, -2, 3, 4), yellow)
	draw_rect(Rect2(6, -2, 3, 4), yellow)
