class_name CuteProjectile
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var damage: float = 8.0
var life: float = 1.5
var projectile_kind: String = "heart"
var critical: bool = false
var pierce_remaining: int = 0
var _hit_ids: Dictionary[int, bool] = {}
var _art: Sprite2D
var _game_node: Node

func configure(origin: Vector2, direction: Vector2, amount: float, kind: String = "heart", pierce: int = 0, speed: float = 390.0) -> void:
	global_position = origin
	velocity = direction.normalized() * speed
	damage = amount
	projectile_kind = kind
	pierce_remaining = maxi(0, pierce)
	critical = randf() < (0.13 if projectile_kind == "heartstorm" else 0.08)
	life = 1.9 if projectile_kind == "heartstorm" else 1.5
	rotation = direction.angle()
	_game_node = get_tree().get_first_node_in_group("game")
	_build_visual()
	queue_redraw()

func _build_visual() -> void:
	_art = Sprite2D.new()
	_art.name = "ProjectileArt"
	_art.centered = true
	_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var path: String = "res://assets/fx/CoracaoRosaCheio.png"
	var size_px: Vector2i = Vector2i(22, 22)
	match projectile_kind:
		"heartstorm":
			path = "res://assets/fx/CoracaoAlado.png"
			size_px = Vector2i(29, 29)
		"star":
			path = "res://assets/fx/Estrela.png"
			size_px = Vector2i(21, 21)
		"candy":
			path = "res://assets/fx/MorangoHaf.png"
			size_px = Vector2i(20, 20)
	_art.texture = CutoutArtPart.make_small_texture(path, size_px)
	_art.modulate = Color(1.32, 0.98, 1.18, 1.0) if projectile_kind != "star" else Color(1.30, 1.22, 0.82, 1.0)
	add_child(_art)
	z_index = 18

func _process(delta: float) -> void:
	position += velocity * delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	if _game_node == null or not is_instance_valid(_game_node):
		_game_node = get_tree().get_first_node_in_group("game")
	if _game_node == null:
		return
	var hit_radius: float = 25.0 if projectile_kind == "heartstorm" else 19.0
	var candidate_value: Variant = _game_node.call("get_enemies_near", global_position, hit_radius + 12.0)
	if not (candidate_value is Array):
		return
	var candidates: Array = candidate_value as Array
	for entry: Variant in candidates:
		var enemy: Node2D = entry as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var id: int = enemy.get_instance_id()
		if _hit_ids.has(id):
			continue
		if global_position.distance_squared_to(enemy.global_position) <= hit_radius * hit_radius:
			_hit_ids[id] = true
			enemy.call("take_damage", damage * (1.75 if critical else 1.0), velocity.normalized(), critical)
			_spawn_hit_fx()
			if pierce_remaining > 0:
				pierce_remaining -= 1
				velocity *= 0.96
			else:
				queue_free()
				return

func _draw() -> void:
	var glow: Color = Color(1.55, 0.22, 0.82, 0.15)
	var trail: Color = Color(1.45, 0.52, 1.0, 0.34)
	if projectile_kind == "star":
		glow = Color(1.55, 1.20, 0.32, 0.15)
		trail = Color(1.50, 1.05, 0.32, 0.34)
	var radius: float = 14.0 if projectile_kind != "heartstorm" else 18.0
	draw_circle(Vector2.ZERO, radius, glow)
	draw_line(Vector2(-23, 0), Vector2(-7, 0), trail, 4.0, true)
	draw_line(Vector2(-18, 0), Vector2(-6, 0), Color(trail.r, trail.g, trail.b, 0.16), 8.0, true)

func _spawn_hit_fx() -> void:
	if _game_node == null:
		return
	_game_node.call("spawn_cute_fx", global_position, "crit" if critical else "impact", velocity.normalized(), 1.22 if critical else 1.02)
