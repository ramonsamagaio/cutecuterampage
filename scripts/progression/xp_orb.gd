class_name XPOrb
extends Node2D

var value: int = 1
var velocity: Vector2 = Vector2.ZERO
var _phase: float = 0.0

func _ready() -> void:
	z_index = 8
	queue_redraw()

func _process(delta: float) -> void:
	_phase += delta * 5.5
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var distance: float = global_position.distance_to(player.global_position)
	if distance < 165.0:
		velocity = velocity.lerp(global_position.direction_to(player.global_position) * 340.0, minf(1.0, delta * 10.0))
		position += velocity * delta
	if distance < 20.0:
		if player.has_method("gain_xp"):
			player.call("gain_xp", value)
		queue_free()
	queue_redraw()

func _draw() -> void:
	var bob: float = roundf(sin(_phase) * 1.0)
	var purple: Color = Color("824cff")
	var blue: Color = Color("56d4ff")
	var light: Color = Color("f1e6ff")
	var p: Vector2 = Vector2(0, bob)
	draw_rect(Rect2(p + Vector2(-4, -6), Vector2(8, 12)), Color("251735"))
	draw_rect(Rect2(p + Vector2(-6, -3), Vector2(12, 6)), Color("251735"))
	draw_rect(Rect2(p + Vector2(-3, -5), Vector2(6, 10)), purple)
	draw_rect(Rect2(p + Vector2(-5, -2), Vector2(10, 4)), purple)
	draw_rect(Rect2(p + Vector2(-2, -3), Vector2(4, 5)), blue)
	draw_rect(Rect2(p + Vector2(-1, -4), Vector2(2, 2)), light)
