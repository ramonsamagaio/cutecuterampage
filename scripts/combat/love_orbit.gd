class_name LoveOrbit
extends Node2D

var owner_player: TaffiController
var orbit_level: int = 1
var evolved: bool = false
var _angle: float = 0.0
var _tick_timer: float = 0.0

func configure(player: TaffiController, level_value: int, is_evolved: bool) -> void:
	owner_player = player
	update_stats(level_value, is_evolved)
	z_index = 16

func update_stats(level_value: int, is_evolved: bool) -> void:
	orbit_level = maxi(1, level_value)
	evolved = is_evolved
	queue_redraw()

func _process(delta: float) -> void:
	if not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position
	_angle = fmod(_angle + delta * (2.1 + float(orbit_level) * 0.08), TAU)
	_tick_timer -= delta
	if _tick_timer <= 0.0:
		_tick_timer = 0.11
		_damage_nearby()
	queue_redraw()

func _damage_nearby() -> void:
	var count: int = _orb_count()
	var radius: float = _orbit_radius()
	var damage_amount: float = owner_player.damage * (0.34 + float(orbit_level) * 0.075) * owner_player.get_cute_damage_multiplier()
	if evolved:
		damage_amount *= 1.35
	for enemy_node: Node in get_tree().get_nodes_in_group("enemy"):
		var enemy: Node2D = enemy_node as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		for i: int in count:
			var phase: float = _angle + TAU * float(i) / float(count)
			var orb_pos: Vector2 = global_position + Vector2.RIGHT.rotated(phase) * radius
			if orb_pos.distance_squared_to(enemy.global_position) <= 20.0 * 20.0:
				enemy.call("take_damage", damage_amount, orb_pos.direction_to(enemy.global_position), false)
				break

func _orb_count() -> int:
	if evolved:
		return 7
	return mini(5, 2 + floori(float(orbit_level) * 0.75))

func _orbit_radius() -> float:
	return 48.0 + float(orbit_level) * 3.0 + (10.0 if evolved else 0.0)

func _draw() -> void:
	var count: int = _orb_count()
	var radius: float = _orbit_radius()
	for i: int in count:
		var phase: float = _angle + TAU * float(i) / float(count)
		var p: Vector2 = Vector2.RIGHT.rotated(phase) * radius
		_draw_heart(p, evolved)

func _draw_heart(p: Vector2, big: bool) -> void:
	var scale_px: float = 1.35 if big else 1.0
	var hot: Color = Color("ff4d91")
	var pale: Color = Color("ffd1e3")
	var dark: Color = Color("bd2d66")
	draw_rect(Rect2(p + Vector2(-5, -3) * scale_px, Vector2(4, 4) * scale_px), hot)
	draw_rect(Rect2(p + Vector2(1, -3) * scale_px, Vector2(4, 4) * scale_px), hot)
	draw_rect(Rect2(p + Vector2(-6, 0) * scale_px, Vector2(12, 4) * scale_px), hot)
	draw_rect(Rect2(p + Vector2(-4, 4) * scale_px, Vector2(8, 3) * scale_px), dark)
	draw_rect(Rect2(p + Vector2(-1, 7) * scale_px, Vector2(2, 2) * scale_px), dark)
	draw_rect(Rect2(p + Vector2(-3, -2) * scale_px, Vector2(2, 2) * scale_px), pale)
