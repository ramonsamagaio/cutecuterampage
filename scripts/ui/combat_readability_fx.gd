class_name CombatReadabilityFX
extends Node2D

const REDRAW_INTERVAL: float = 1.0 / 12.0

var _time: float = 0.0
var _redraw_timer: float = 0.0

func _ready() -> void:
	z_as_relative = false
	z_index = 4

func _process(delta: float) -> void:
	_time += delta
	_redraw_timer -= delta
	if _redraw_timer <= 0.0:
		_redraw_timer = REDRAW_INTERVAL
		queue_redraw()

func _draw() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	for enemy_node: Node in enemies:
		var enemy: Node2D = enemy_node as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var p: Vector2 = enemy.global_position
		if enemy.is_in_group("boss"):
			_draw_ellipse(p + Vector2(0, 23), 55.0, 18.0, Color(1.45, 0.34, 0.72, 0.18), 3.0)
			continue

		var elite_value: Variant = enemy.get("elite")
		var is_elite: bool = bool(elite_value) if elite_value != null else false
		var archetype_value: Variant = enemy.get("archetype")
		var archetype: String = String(archetype_value) if archetype_value != null else ""

		if is_elite:
			var affix: String = String(enemy.get("elite_affix"))
			var tint: Color = Color(1.45, 0.48, 0.88, 0.34)
			if affix == "swift":
				tint = Color(0.56, 1.45, 1.08, 0.32)
			elif affix == "tank":
				tint = Color(1.45, 0.84, 0.42, 0.34)
			elif affix == "volatile":
				tint = Color(1.55, 0.34, 0.62, 0.36)
			var breathe: float = 1.0 + sin(_time * 3.2 + float(enemy.get_instance_id() % 17)) * 0.055
			_draw_ellipse(p + Vector2(0, 18), 27.0 * breathe, 9.0 * breathe, tint, 2.2)
			for i: int in 3:
				var a: float = _time * 0.85 + TAU * float(i) / 3.0 + float(enemy.get_instance_id() % 11) * 0.09
				var star: Vector2 = p + Vector2(cos(a) * 24.0, sin(a) * 9.0 + 18.0)
				_draw_spark(star, 2.8, Color(tint.r, tint.g, tint.b, tint.a * 1.15))

		if archetype == "charger":
			var windup_value: Variant = enemy.get("_charge_windup")
			var windup: float = float(windup_value) if windup_value != null else 0.0
			if windup > 0.0:
				var warning_pulse: float = 0.65 + sin(_time * 18.0) * 0.25
				_draw_ellipse(p + Vector2(0, 18), 38.0 + warning_pulse * 5.0, 13.0 + warning_pulse * 2.0, Color(1.55, 0.20, 0.42, 0.32 + warning_pulse * 0.14), 3.0)
		elif archetype == "shooter" and not is_elite:
			# A quiet lavender floor cue distinguishes ranged threats without adding UI labels.
			_draw_ellipse(p + Vector2(0, 17), 19.0, 6.0, Color(0.88, 0.54, 1.45, 0.15), 1.4)

func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color, width: float) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in 25:
		var angle: float = TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_polyline(points, color, width, true)

func _draw_spark(center: Vector2, radius: float, color: Color) -> void:
	draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), color, 1.2)
	draw_line(center + Vector2(0, -radius), center + Vector2(0, radius), color, 1.2)
