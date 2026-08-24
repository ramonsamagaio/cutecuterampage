class_name CuteProjectile
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var damage: float = 8.0
var life: float = 1.5
var projectile_kind: String = "heart"
var critical: bool = false
var pierce_remaining: int = 0
var _hit_ids: Dictionary[int, bool] = {}
var art: CutoutArtPart

func configure(origin: Vector2, direction: Vector2, amount: float, kind: String = "heart", pierce: int = 0, speed: float = 390.0) -> void:
	global_position = origin
	velocity = direction.normalized() * speed
	damage = amount
	projectile_kind = kind
	pierce_remaining = maxi(0, pierce)
	critical = randf() < (0.13 if projectile_kind == "heartstorm" else 0.08)
	life = 1.9 if projectile_kind == "heartstorm" else 1.5
	_build_visual()

func _build_visual() -> void:
	if art != null and is_instance_valid(art):
		art.queue_free()
	art = CutoutArtPart.new()
	art.name = "ProjectileArt"
	match projectile_kind:
		"heartstorm": art.configure("res://assets/fx/CoracaoAlado.png", Vector2(13, 13), Vector2(0.5, 0.5))
		"star": art.configure("res://assets/fx/Estrela.png", Vector2(9, 9), Vector2(0.5, 0.5))
		"candy": art.configure("res://assets/fx/MorangoHaf.png", Vector2(9, 9), Vector2(0.5, 0.5))
		_: art.configure("res://assets/fx/CoracaoRosaCheio.png", Vector2(10, 10), Vector2(0.5, 0.5))
	add_child(art)
	z_index = 18

func _process(delta: float) -> void:
	position += velocity * delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	for enemy_node: Node in get_tree().get_nodes_in_group("enemy"):
		var enemy: Node2D = enemy_node as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var id: int = enemy.get_instance_id()
		if _hit_ids.has(id):
			continue
		var hit_radius: float = 17.0 if projectile_kind == "heartstorm" else 13.0
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

func _spawn_hit_fx() -> void:
	var game_node: Node = get_tree().get_first_node_in_group("game")
	if game_node == null:
		return
	game_node.call("spawn_cute_fx", global_position, "crit" if critical else "impact", velocity.normalized(), 1.0)
