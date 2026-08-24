extends Node2D

const TAFFI_SCENE := preload("res://scenes/actors/Taffi.tscn")
const SPECIAL_BEAM_LENGTH := 1180.0

var player
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

func _setup_vfx_environment() -> void:
	var world_environment := WorldEnvironment.new()
	world_environment.name = "CuteCuteVFXEnvironment"
	var environment := Environment.new()
	environment.glow_enabled = true
	environment.glow_intensity = 0.92
	environment.glow_bloom = 0.10
	environment.glow_hdr_threshold = 0.78
	environment.glow_hdr_scale = 2.0
	environment.glow_strength = 1.10
	environment.glow_normalized = false
	world_environment.environment = environment
	add_child(world_environment)

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

func trigger_special(fallback_origin: Vector2) -> void:
	var beam_origin := fallback_origin
	if is_instance_valid(player.weapon_socket):
		beam_origin = player.weapon_socket.global_position

	var beam_direction := Vector2.RIGHT
	var target := get_nearest_enemy(player.global_position)
	if is_instance_valid(target):
		beam_direction = beam_origin.direction_to(target.global_position)
	elif player.visual.scale.x < 0.0:
		beam_direction = Vector2.LEFT

	var beam := TaffiStrawberryBeamVFX.new()
	beam.name = "TaffiStrawberryOverdrive"
	add_child(beam)
	beam.configure(beam_origin, beam_direction, player.weapon_socket)

	_damage_strawberry_beam(beam_origin, beam_direction)

func _damage_strawberry_beam(origin: Vector2, beam_direction: Vector2) -> void:
	var forward := beam_direction.normalized()
	if forward == Vector2.ZERO:
		forward = Vector2.RIGHT
	var side := Vector2(-forward.y, forward.x)
	var enemies := get_tree().get_nodes_in_group("enemy").duplicate()

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var offset: Vector2 = enemy.global_position - origin
		var along := offset.dot(forward)
		if along < -24.0 or along > SPECIAL_BEAM_LENGTH:
			continue
		# Slightly widens toward the tip, matching the absurd anime cannon silhouette.
		var half_width := 62.0 + maxf(0.0, along) * 0.038
		var across := absf(offset.dot(side))
		if across <= half_width:
			enemy.take_damage(9999.0, forward, true)
