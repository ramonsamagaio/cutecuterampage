class_name XPOrb
extends Node2D

var value := 1
var velocity := Vector2.ZERO

func _ready() -> void:
	z_index = 8

func _process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var distance := global_position.distance_to(player.global_position)
	if distance < 130.0:
		velocity = velocity.lerp(global_position.direction_to(player.global_position) * 300.0, minf(1.0, delta * 9.0))
		position += velocity * delta
	if distance < 15.0:
		if player.has_method("gain_xp"):
			player.gain_xp(value)
		queue_free()

func _draw() -> void:
	var purple := Color("9d61ff")
	var light := Color("f1d6ff")
	draw_rect(Rect2(-3, -1, 6, 2), purple)
	draw_rect(Rect2(-1, -3, 2, 6), purple)
	draw_rect(Rect2(-1, -1, 2, 2), light)
