extends Node2D

const TAFFI_SCENE: PackedScene = preload("res://scenes/actors/Taffi.tscn")
const SPECIAL_BEAM_LENGTH: float = 1180.0

var player: TaffiController
var hud: GameHUD
var blood: BloodSystem
var streamer: ChunkStreamer
var director: EnemyDirector

func _ready() -> void:
	add_to_group("game")
	_setup_vfx_environment()

	streamer = ChunkStreamer.new()
	streamer.name = "ChunkStreamer"
	add_child(streamer)

	blood = BloodSystem.new()
	blood.name = "BloodSystem"
	add_child(blood)

	player = TAFFI_SCENE.instantiate() as TaffiController
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

func _setup_vfx_environment() -> void:
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.name = "CuteCuteVFXEnvironment"
	var environment_resource: Environment = Environment.new()
	environment_resource.glow_enabled = true
	environment_resource.glow_intensity = 0.92
	environment_resource.glow_bloom = 0.10
	environment_resource.glow_hdr_threshold = 0.78
	environment_resource.glow_hdr_scale = 2.0
	environment_resource.glow_strength = 1.10
	environment_resource.glow_normalized = false
	world_environment.environment = environment_resource
	add_child(world_environment)

func get_nearest_enemy(from: Vector2) -> Node2D:
	var nearest: Node2D = null
	var best: float = INF
	for enemy_node: Node in get_tree().get_nodes_in_group("enemy"):
		var enemy: Node2D = enemy_node as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var distance_squared: float = from.distance_squared_to(enemy.global_position)
		if distance_squared < best:
			best = distance_squared
			nearest = enemy
	return nearest

func spawn_projectile(origin: Vector2, direction: Vector2, damage_amount: float, kind: String = "heart") -> void:
	var projectile: CuteProjectile = CuteProjectile.new()
	add_child(projectile)
	projectile.configure(origin, direction, damage_amount, kind)

func spawn_enemy_projectile(origin: Vector2, direction: Vector2, damage_amount: float, speed: float) -> void:
	var projectile: EnemyCandyBullet = EnemyCandyBullet.new()
	add_child(projectile)
	projectile.configure(origin, direction, damage_amount, speed)

func on_enemy_killed(pos: Vector2, xp_value: int = 1) -> void:
	player.register_kill()
	if hud != null:
		hud.on_kill()
	var orb: XPOrb = XPOrb.new()
	orb.value = xp_value
	orb.global_position = pos
	add_child.call_deferred(orb)

func trigger_special(fallback_origin: Vector2) -> void:
	var beam_origin: Vector2 = fallback_origin
	if is_instance_valid(player.weapon_socket):
		beam_origin = player.weapon_socket.global_position

	var beam_direction: Vector2 = Vector2.RIGHT
	var target: Node2D = get_nearest_enemy(player.global_position)
	if is_instance_valid(target):
		beam_direction = beam_origin.direction_to(target.global_position)
	elif player.visual.scale.x < 0.0:
		beam_direction = Vector2.LEFT

	player.begin_special_channel()
	var beam: TaffiStrawberryBeamVFX = TaffiStrawberryBeamVFX.new()
	beam.name = "TaffiStrawberryOverdrive"
	add_child(beam)
	beam.damage_tick.connect(_damage_strawberry_beam)
	beam.aim_changed.connect(player.set_special_aim)
	beam.finished.connect(player.end_special_channel)
	beam.configure(beam_origin, beam_direction, player.weapon_socket)

func _damage_strawberry_beam(origin: Vector2, beam_direction: Vector2) -> void:
	var forward: Vector2 = beam_direction.normalized()
	if forward == Vector2.ZERO:
		forward = Vector2.RIGHT
	var side: Vector2 = Vector2(-forward.y, forward.x)
	var enemy_nodes: Array[Node] = []
	for enemy_node: Node in get_tree().get_nodes_in_group("enemy"):
		enemy_nodes.append(enemy_node)

	for enemy_node: Node in enemy_nodes:
		var enemy: Node2D = enemy_node as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var offset: Vector2 = enemy.global_position - origin
		var along: float = offset.dot(forward)
		if along < -24.0 or along > SPECIAL_BEAM_LENGTH:
			continue
		var half_width: float = 62.0 + maxf(0.0, along) * 0.038
		var across: float = absf(offset.dot(side))
		if across <= half_width:
			enemy.call("take_damage", 9999.0, forward, true)

func get_threat_tier() -> int:
	return director.get_threat_tier() if director != null else 1

func get_run_time() -> float:
	return director.get_elapsed() if director != null else 0.0
