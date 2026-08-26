class_name CupcakeMortar
extends Node2D

var damage: float = 18.0
var blast_radius: float = 68.0
var evolved: bool = false
var _origin: Vector2 = Vector2.ZERO
var _target: Vector2 = Vector2.ZERO
var _age: float = 0.0
var _flight_time: float = 0.58
var _landed: bool = false
var _pop_age: float = 0.0
var _redraw_timer: float = 0.0
var _game_node: Node

func configure(origin: Vector2, target: Vector2, damage_amount: float, radius: float, is_evolved: bool = false) -> void:
	_origin = origin
	_target = target
	damage = damage_amount
	blast_radius = radius
	evolved = is_evolved
	global_position = origin
	z_index = 24
	_game_node = get_tree().get_first_node_in_group("game")
	queue_redraw()

func _process(delta: float) -> void:
	if _landed:
		_pop_age += delta
		_redraw_timer -= delta
		if _redraw_timer <= 0.0:
			_redraw_timer = 1.0 / 30.0
			queue_redraw()
		if _pop_age >= 0.20:
			queue_free()
		return

	_age += delta
	var t: float = clampf(_age / _flight_time, 0.0, 1.0)
	var arc_height: float = sin(t * PI) * (92.0 if evolved else 68.0)
	global_position = _origin.lerp(_target, t) + Vector2(0.0, -arc_height)
	rotation += delta * (8.0 if evolved else 5.5)
	if t >= 1.0:
		_land()

func _land() -> void:
	if _landed:
		return
	_landed = true
	global_position = _target
	rotation = 0.0
	if _game_node == null or not is_instance_valid(_game_node):
		_game_node = get_tree().get_first_node_in_group("game")
	if _game_node != null:
		_game_node.call("explode_cupcake", _target, damage, blast_radius, evolved)
	queue_redraw()

func _draw() -> void:
	if _landed:
		var pop_t: float = clampf(_pop_age / 0.20, 0.0, 1.0)
		var radius: float = lerpf(8.0, blast_radius * 0.72, pop_t)
		var alpha: float = 1.0 - pop_t
		draw_circle(Vector2.ZERO, radius, Color(1.7, 0.35, 0.85, alpha * 0.16))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, Color(1.0, 0.82, 0.94, alpha), 4.0, true)
		return

	var ink: Color = Color("2b1832")
	var wrapper: Color = Color("ff5f9f")
	var cream: Color = Color("fff2dc")
	var cherry: Color = Color("e93258")
	var sprinkle: Color = Color("ffd95f")
	draw_circle(Vector2(0, 2), 13.0, Color(1.4, 0.24, 0.72, 0.10))
	draw_colored_polygon(PackedVector2Array([Vector2(-7, 0), Vector2(7, 0), Vector2(5, 9), Vector2(-5, 9)]), ink)
	draw_colored_polygon(PackedVector2Array([Vector2(-5, 1), Vector2(5, 1), Vector2(4, 7), Vector2(-4, 7)]), wrapper)
	draw_circle(Vector2.ZERO, 8.0, ink)
	draw_circle(Vector2.ZERO, 6.8, cream)
	draw_circle(Vector2(0, -6), 3.2, cherry)
	draw_circle(Vector2(-3, -1), 1.0, sprinkle)
	draw_circle(Vector2(3, 0), 1.0, Color("8f71ff"))
	if evolved:
		draw_circle(Vector2(-9, -2), 1.5, Color("fff5a6"))
		draw_circle(Vector2(9, -4), 1.5, Color("fff5a6"))
