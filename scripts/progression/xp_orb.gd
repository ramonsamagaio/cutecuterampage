class_name XPOrb
extends Node2D

const MAX_WORLD_ORBS: int = 140
static var active_count: int = 0

var value: int = 1
var velocity: Vector2 = Vector2.ZERO
var _phase: float = 0.0
var _player: Node2D
var _registered: bool = false

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D
	if active_count >= MAX_WORLD_ORBS:
		if _player != null and _player.has_method("gain_xp"):
			_player.call("gain_xp", value)
		queue_free()
		return
	active_count += 1
	_registered = true
	z_index = 8
	queue_redraw()

func _exit_tree() -> void:
	if _registered:
		active_count = maxi(0, active_count - 1)
		_registered = false

func _process(delta: float) -> void:
	_phase += delta * 5.0
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null:
		return
	var distance: float = global_position.distance_to(_player.global_position)
	var magnet_range: float = 250.0 if active_count > 90 else 185.0
	if distance < magnet_range:
		var target_speed: float = 390.0 if active_count > 90 else 340.0
		velocity = velocity.lerp(global_position.direction_to(_player.global_position) * target_speed, minf(1.0, delta * 10.0))
		position += velocity * delta
	if distance < 22.0:
		if _player.has_method("gain_xp"):
			_player.call("gain_xp", value)
		queue_free()
		return
	var pulse: float = 1.0 + sin(_phase) * 0.045
	scale = Vector2.ONE * pulse

func _draw() -> void:
	var purple: Color = Color("824cff")
	var blue: Color = Color("56d4ff")
	var light: Color = Color("f1e6ff")
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -7), Vector2(7, 0), Vector2(0, 7), Vector2(-7, 0)
	]), Color("251735"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -5), Vector2(5, 0), Vector2(0, 5), Vector2(-5, 0)
	]), purple)
	draw_circle(Vector2.ZERO, 2.7, blue)
	draw_circle(Vector2(-1, -2), 1.1, light)
