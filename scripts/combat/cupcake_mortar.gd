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

func configure(origin: Vector2, target: Vector2, damage_amount: float, radius: float, is_evolved: bool = false) -> void:
	_origin = origin
	_target = target
	damage = damage_amount
	blast_radius = radius
	evolved = is_evolved
	global_position = origin
	z_index = 24
	queue_redraw()

func _process(delta: float) -> void:
	if _landed:
		_pop_age += delta
		queue_redraw()
		if _pop_age >= 0.20:
			queue_free()
		return

	_age += delta
	var t: float = clampf(_age / _flight_time, 0.0, 1.0)
	var arc_height: float = sin(t * PI) * (92.0 if evolved else 68.0)
	global_position = _origin.lerp(_target, t) + Vector2(0.0, -arc_height)
	rotation += delta * (8.0 if evolved else 5.5)
	queue_redraw()
	if t >= 1.0:
		_land()

func _land() -> void:
	if _landed:
		return
	_landed = true
	global_position = _target
	rotation = 0.0
	var game_node: Node = get_tree().get_first_node_in_group("game")
	if game_node != null:
		game_node.call("explode_cupcake", _target, damage, blast_radius, evolved)
	queue_redraw()

func _draw() -> void:
	if _landed:
		var pop_t: float = clampf(_pop_age / 0.20, 0.0, 1.0)
		var radius: float = lerpf(8.0, blast_radius * 0.72, pop_t)
		var alpha: float = 1.0 - pop_t
		draw_circle(Vector2.ZERO, radius, Color(1.7, 0.35, 0.85, alpha * 0.16))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(1.0, 0.82, 0.94, alpha), 4.0)
		return

	var ink: Color = Color("2b1832")
	var wrapper: Color = Color("ff5f9f")
	var cream: Color = Color("fff2dc")
	var cherry: Color = Color("e93258")
	var sprinkle: Color = Color("ffd95f")
	draw_rect(Rect2(-7, 0, 14, 8), ink)
	draw_rect(Rect2(-6, 0, 12, 7), wrapper)
	draw_rect(Rect2(-8, -5, 16, 6), ink)
	draw_rect(Rect2(-7, -4, 14, 5), cream)
	draw_rect(Rect2(-2, -8, 5, 5), cherry)
	draw_rect(Rect2(-5, -3, 2, 1), sprinkle)
	draw_rect(Rect2(3, -2, 2, 1), Color("8f71ff"))
	if evolved:
		draw_rect(Rect2(-9, -1, 2, 2), Color("fff5a6"))
		draw_rect(Rect2(7, -4, 2, 2), Color("fff5a6"))
