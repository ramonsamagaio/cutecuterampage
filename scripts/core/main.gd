extends Node2D

const TAFFI_SCENE := preload("res://scenes/actors/Taffi.tscn")

var player
var hud: GameHUD
var blood: BloodSystem
var streamer: ChunkStreamer
var director: EnemyDirector

func _ready() -> void:
	add_to_group("game")

	streamer = ChunkStreamer.new()
	streamer.name = "ChunkStreamer"
	add_child(streamer)

	blood = BloodSystem.new()
	blood.name = "BloodSystem"
	add_child(blood)

	player = TAFFI_SCENE.instantiate()
	player.name = "Taffi"
	player.global_position = Vector2.ZERO
	add_child(player)
	streamer.player = player

	director = EnemyDirector.new()
	director.name = "EnemyDirector"
	director.player = player
	add_child(director)

	hud = GameHUD.new()
	hud.name = "HUD"
	add_child(hud)
	hud.bind(player, self)

func get_nearest_enemy(from: Vector2) -> Node2D:
	var nearest: Node2D = null
	var best := INF
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		var d := from.distance_squared_to(enemy.global_position)
		if d < best:
			best = d
			nearest = enemy
	return nearest

func spawn_projectile(origin: Vector2, direction: Vector2, damage: float, kind: String = "heart") -> void:
	var projectile := CuteProjectile.new()
	add_child(projectile)
	projectile.configure(origin, direction, damage, kind)

func on_enemy_killed(pos: Vector2, xp_value: int = 1) -> void:
	player.register_kill()
	if hud:
		hud.on_kill()
	var orb := XPOrb.new()
	orb.value = xp_value
	orb.global_position = pos
	add_child.call_deferred(orb)

func trigger_special(origin: Vector2) -> void:
	var burst := SpecialBurst.new()
	burst.global_position = origin
	add_child(burst)
	var enemies := get_tree().get_nodes_in_group("enemy").duplicate()
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var distance := origin.distance_to(enemy.global_position)
		if distance <= 540.0:
			var dir := origin.direction_to(enemy.global_position)
			enemy.take_damage(9999.0, dir, true)
	# Extra strawberry spray at the epicenter.
	blood.emit_burst(origin, Vector2.UP, 28)
