class_name EnemyCandyBullet
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var damage: float = 7.0
var life: float = 4.0
var hit_radius: float = 11.0
var perfect_radius: float = 25.0

func configure(origin: Vector2, direction: Vector2, amount: float, speed: float) -> void:
	global_position = origin
	velocity = direction.normalized() * speed
	damage = amount
	rotation = direction.angle()
	z_index = 18
	queue_redraw()

func _process(delta: float) -> void:
	position += velocity * delta
	life -= delta
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
	# Tiny hostile candy diamond. Cute silhouette, dangerous palette.
	draw_rect(Rect2(-4, -2, 8, 4), ink)
	draw_rect(Rect2(-2, -4, 4, 8), ink)
	draw_rect(Rect2(-3, -1, 6, 2), hot)
	draw_rect(Rect2(-1, -3, 2, 6), hot)
	draw_rect(Rect2(-1, -1, 2, 2), pale)
	draw_rect(Rect2(-6, -1, 2, 2), yellow)
	draw_rect(Rect2(4, -1, 2, 2), yellow)
