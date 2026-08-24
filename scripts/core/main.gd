extends Node2D

const TAFFI_SCENE: PackedScene = preload("res://scenes/actors/Taffi.tscn")
const SPECIAL_BEAM_LENGTH: float = 1180.0

var player: TaffiController
var hud: GameHUD
var blood: BloodSystem
var streamer: ChunkStreamer
var director: EnemyDirector
var love_orbit: LoveOrbit
var current_boss: SugarBoss

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

func get_priority_enemy(from: Vector2, max_range: float) -> Node2D:
	if is_instance_valid(current_boss) and from.distance_to(current_boss.global_position) <= max_range:
		return current_boss
	var nearest: Node2D = null
	var best_score: float = INF
	for enemy_node: Node in get_tree().get_nodes_in_group("enemy"):
		var enemy: Node2D = enemy_node as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var distance: float = from.distance_to(enemy.global_position)
		if distance > max_range:
			continue
		var score: float = distance
		if enemy_node.is_in_group("boss"):
			score *= 0.35
		if score < best_score:
			best_score = score
			nearest = enemy
	return nearest

func spawn_projectile(origin: Vector2, direction: Vector2, damage_amount: float, kind: String = "heart", pierce: int = 0, speed: float = 390.0) -> void:
	var projectile: CuteProjectile = CuteProjectile.new()
	add_child(projectile)
	projectile.configure(origin, direction, damage_amount, kind, pierce, speed)

func spawn_cupcake_mortar(origin: Vector2, target: Vector2, damage_amount: float, radius: float, evolved: bool) -> void:
	var mortar: CupcakeMortar = CupcakeMortar.new()
	add_child(mortar)
	mortar.configure(origin, target, damage_amount, radius, evolved)

func explode_cupcake(center: Vector2, damage_amount: float, radius: float, evolved: bool) -> void:
	var enemy_nodes: Array[Node] = []
	for enemy_node: Node in get_tree().get_nodes_in_group("enemy"):
		enemy_nodes.append(enemy_node)
	for enemy_node: Node in enemy_nodes:
		var enemy: Node2D = enemy_node as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var distance: float = center.distance_to(enemy.global_position)
		if distance <= radius:
			var falloff: float = lerpf(1.0, 0.58, clampf(distance / maxf(1.0, radius), 0.0, 1.0))
			enemy.call("take_damage", damage_amount * falloff, center.direction_to(enemy.global_position), distance < radius * 0.35)
	blood.emit_burst(center, Vector2.UP, 13 if evolved else 7)
	if evolved:
		# Birthday Massacre throws a ring of piercing sugar-stars after the blast.
		for i: int in 10:
			var angle: float = TAU * float(i) / 10.0
			spawn_projectile(center, Vector2.RIGHT.rotated(angle), damage_amount * 0.42, "star", 1, 460.0)

func ensure_love_orbit(owner: TaffiController, level_value: int, evolved: bool) -> void:
	if love_orbit == null or not is_instance_valid(love_orbit):
		love_orbit = LoveOrbit.new()
		love_orbit.name = "LoveOrbit"
		add_child(love_orbit)
		love_orbit.configure(owner, level_value, evolved)
	else:
		love_orbit.update_stats(level_value, evolved)

func spawn_enemy_projectile(origin: Vector2, direction: Vector2, damage_amount: float, speed: float) -> void:
	var projectile: EnemyCandyBullet = EnemyCandyBullet.new()
	add_child(projectile)
	projectile.configure(origin, direction, damage_amount, speed)

func on_enemy_killed(pos: Vector2, xp_value: int = 1, was_elite: bool = false) -> void:
	player.register_kill()
	if hud != null:
		hud.on_kill()
	var orb: XPOrb = XPOrb.new()
	orb.value = maxi(1, roundi(float(xp_value) * player.get_cute_xp_multiplier()))
	orb.global_position = pos
	add_child.call_deferred(orb)
	if was_elite and randf() < 0.085:
		spawn_reward_chest(pos, false)

func spawn_boss(power: float) -> void:
	if is_instance_valid(current_boss):
		return
	current_boss = SugarBoss.new()
	current_boss.name = "QueenMallow"
	current_boss.configure(power)
	var angle: float = randf_range(0.0, TAU)
	current_boss.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * 610.0
	add_child(current_boss)
	if hud != null:
		hud.show_reward_toast("WARNING!  QUEEN MALLOW HAS ARRIVED")

func on_boss_defeated(pos: Vector2, defeated_name: String) -> void:
	current_boss = null
	player.cute_meter = minf(100.0, player.cute_meter + 28.0)
	player.special_meter = minf(100.0, player.special_meter + 35.0)
	spawn_reward_chest(pos, true)
	if hud != null:
		hud.show_reward_toast("%s POPPED!  EVOLUTION CHEST!" % defeated_name)

func spawn_reward_chest(pos: Vector2, legendary: bool) -> void:
	var chest: RewardChest = RewardChest.new()
	chest.legendary = legendary
	chest.global_position = pos
	add_child.call_deferred(chest)

func claim_reward_chest(_pos: Vector2, legendary: bool) -> void:
	var reward_text: String
	if legendary:
		reward_text = player.claim_evolution_chest()
	else:
		reward_text = player.claim_bonus_chest()
	if hud != null:
		hud.show_reward_toast(reward_text)

func is_boss_active() -> bool:
	return is_instance_valid(current_boss)

func get_boss_health_ratio() -> float:
	if not is_instance_valid(current_boss):
		return 0.0
	return current_boss.get_health_ratio()

func get_boss_name() -> String:
	if not is_instance_valid(current_boss):
		return ""
	return current_boss.get_display_name()

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
