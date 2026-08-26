class_name FriendshipLaserPolish
extends Node2D

const DRAW_INTERVAL: float = 1.0 / 30.0
const LASER_LENGTH: float = 720.0

var _arsenal: ArsenalController
var _player: Node2D
var _timer: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	z_as_relative = false
	z_index = 18
	call_deferred("_bind")

func _bind() -> void:
	_arsenal = get_tree().get_first_node_in_group("arsenal") as ArsenalController
	_player = get_tree().get_first_node_in_group("player") as Node2D

func _process(delta: float) -> void:
	_time += delta
	_timer -= delta
	if not is_instance_valid(_arsenal) or not is_instance_valid(_player):
		_bind()
	if _timer <= 0.0:
		_timer = DRAW_INTERVAL
		queue_redraw()

func _draw() -> void:
	if not is_instance_valid(_arsenal) or not is_instance_valid(_player):
		return
	var laser_variant: Variant = _arsenal.get("_laser")
	if not (laser_variant is Dictionary):
		return
	var laser: Dictionary = laser_variant as Dictionary
	if laser.is_empty():
		return

	var age: float = float(laser.get("age", 0.0))
	var life: float = maxf(0.01, float(laser.get("life", 0.01)))
	var width: float = maxf(4.0, float(laser.get("width", 12.0)))
	var sweep: float = sin(age / life * PI) * 0.28 - 0.14
	var dir: Vector2 = Vector2.RIGHT.rotated(float(laser.get("angle", 0.0)) + sweep)
	var origin: Vector2 = _player.global_position
	var tip: Vector2 = origin + dir * LASER_LENGTH
	var envelope: float = sin(clampf(age / life, 0.0, 1.0) * PI)
	var breathe: float = 1.0 + sin(_time * 41.0) * 0.035

	# Oversized aura/body/core stack. This is rendered by one CanvasItem on top of the existing damage geometry.
	draw_line(origin, tip, Color(1.35, 0.03, 0.62, 0.09 * envelope), width * 4.8 * breathe, true)
	draw_line(origin, tip, Color(1.65, 0.13, 0.82, 0.18 * envelope), width * 3.1 * breathe, true)
	draw_line(origin, tip, Color(1.85, 0.44, 1.05, 0.58 * envelope), width * 1.65, true)
	draw_line(origin, tip, Color(2.2, 0.86, 1.32, 0.88 * envelope), maxf(4.0, width * 0.72), true)
	draw_line(origin, tip, Color(2.8, 1.45, 2.2, 0.96 * envelope), maxf(2.0, width * 0.22), true)

	var side: Vector2 = Vector2(-dir.y, dir.x)
	for i: int in 10:
		var along: float = fmod(_time * (180.0 + float(i % 4) * 28.0) + float(i) * 93.0, LASER_LENGTH - 40.0) + 20.0
		var wave: float = sin(_time * (6.0 + float(i % 3)) + float(i) * 1.93 + along * 0.022)
		var p: Vector2 = origin + dir * along + side * wave * (width * 1.15 + float(i % 3) * 4.0)
		var streak: float = 8.0 + float(i % 3) * 4.0
		draw_line(p - dir * streak, p + dir * 3.0, Color(1.9, 0.75, 1.35, 0.42 * envelope), 1.5, true)
		if i % 3 == 0:
			_draw_spark(p, 3.0 + float(i % 2), Color(2.1, 1.0, 1.55, 0.58 * envelope))

	# Origin and endpoint make the laser feel launched and received rather than painted across the screen.
	var muzzle_radius: float = (14.0 + sin(_time * 31.0) * 3.0) * envelope
	draw_circle(origin, muzzle_radius * 1.8, Color(1.7, 0.20, 0.88, 0.12 * envelope))
	draw_circle(origin, muzzle_radius, Color(2.3, 0.74, 1.48, 0.35 * envelope))
	_draw_spark(origin, muzzle_radius * 1.25, Color(2.6, 1.25, 2.0, 0.62 * envelope))
	var tip_radius: float = (17.0 + sin(_time * 27.0) * 4.0) * envelope
	draw_circle(tip, tip_radius * 1.9, Color(1.7, 0.12, 0.72, 0.10 * envelope))
	draw_circle(tip, tip_radius, Color(2.2, 0.72, 1.38, 0.28 * envelope))
	_draw_spark(tip, tip_radius * 1.10, Color(2.5, 1.15, 1.95, 0.52 * envelope))

func _draw_spark(p: Vector2, radius: float, color: Color) -> void:
	draw_line(p + Vector2(-radius, 0), p + Vector2(radius, 0), color, 1.5, true)
	draw_line(p + Vector2(0, -radius), p + Vector2(0, radius), color, 1.5, true)
