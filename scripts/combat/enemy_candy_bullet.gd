class_name EnemyCandyBullet
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var damage: float = 7.0
var life: float = 4.0
var hit_radius: float = 14.0
var perfect_radius: float = 30.0
var _player_node: Node
var _player_2d: Node2D

func configure(origin: Vector2, direction: Vector2, amount: float, speed: float) -> void:
	global_position = origin
	velocity = direction.normalized() * speed
	damage = amount
	rotation = direction.angle()
	z_index = 18
	_player_node = get_tree().get_first_node_in_group("player")
	_player_2d = _player_node as Node2D
	queue_redraw()

func _process(delta: float) -> void:
	position += velocity * delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	if _player_node == null or not is_instance_valid(_player_node) or _player_2d == null:
		_player_node = get_tree().get_first_node_in_group("player")
		_player_2d = _player_node as Node2D
	if _player_node == null or _player_2d == null:
		return
	var distance: float = global_position.distance_to(_player_2d.global_position)
	var dashing: bool = bool(_player_node.call("is_dashing"))
	if dashing and distance <= perfect_radius:
		_player_node.call("register_perfect_dodge")
		queue_free()
		return
	if not dashing and distance <= hit_radius:
		_player_node.call("take_damage", damage)
		queue_free()

func _draw() -> void:
	var ink: Color = Color("32152c")
	var hot: Color = Color("ff477f")
	var pale: Color = Color("ffe1ec")
	var yellow: Color = Color("ffd95f")
	# Static silhouette is cheaper than pulsing every projectile every frame, while the
	# soft HDR halo and rear trail keep hostile shots easy to read.
	draw_circle(Vector2.ZERO, 11.0, Color(1.45, 0.16, 0.72, 0.14))
	draw_line(Vector2(-20, 0), Vector2(-8, 0), Color(1.35, 0.28, 0.62, 0.30), 5.0, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -7), Vector2(7, 0), Vector2(0, 7), Vector2(-7, 0)
	]), ink)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -5), Vector2(5, 0), Vector2(0, 5), Vector2(-5, 0)
	]), hot)
	draw_circle(Vector2.ZERO, 2.8, pale)
	draw_circle(Vector2(-7, 0), 2.3, yellow)
	draw_circle(Vector2(7, 0), 2.3, yellow)
