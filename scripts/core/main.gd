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
	if randf() < 0.42:
		spawn_cute_fx(origin, "muzzle", direction, 0.75)

func spawn_cupcake_mortar(origin: Vector2, target: Vector2, damage_amount: float, radius: float, evolved: bool) -> void:
	var mortar: CupcakeMortar = CupcakeMortar.new()
	add_child(mortar)
	mortar.configure(origin, target, damage_amount, radius, evolved)
	spawn_cute_fx(origin, "heart", origin.direction_to(target), 0.8)

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
	spawn_cute_fx(center, "puff", Vector2.UP, 1.35 if evolved else 1.0)
	spawn_cute_fx(center, "impact", Vector2.ZERO, 1.55 if evolved else 1.1)
	if evolved:
		for i: int in 10:
			var angle: float = TAU * float(i) / 10.0
			spawn_projectile(center, Vector2.RIGHT.rotated(angle), damage_amount * 0.42, "star", 1, 460.0)

func ensure_love_orbit(player_owner: TaffiController, level_value: int, evolved: bool) -> void:
	if love_orbit == null or not is_instance_valid(love_orbit):
		love_orbit = LoveOrbit.new()
		love_orbit.name = "LoveOrbit"
		add_child(love_orbit)
		love_orbit.configure(player_owner, level_value, evolved)
	else:
		love_orbit.update_stats(level_value, evolved)

func spawn_enemy_projectile(origin: Vector2, direction: Vector2, damage_amount: float, speed: float) -> void:
	var projectile: EnemyCandyBullet = EnemyCandyBullet.new()
	add_child(projectile)
	projectile.configure(origin, direction, damage_amount, speed)

func spawn_cute_fx(global_pos: Vector2, kind: String, direction: Vector2 = Vector2.ZERO, size_multiplier: float = 1.0) -> void:
	var active_fx_count: int = get_tree().get_nodes_in_group("cute_fx").size()
	if active_fx_count >= 140:
		return
	var path: String = "res://assets/fx/BrilhoRosa.png"
	var target_size: Vector2 = Vector2(12, 12)
	var lifetime: float = 0.22
	var drift: Vector2 = direction.normalized() * 28.0
	var spin: float = randf_range(-2.5, 2.5)
	var end_scale: float = 1.25
	match kind:
		"impact":
			path = "res://assets/fx/ImpactoRosa.png"
			target_size = Vector2(15, 15)
			lifetime = 0.18
			end_scale = 1.42
		"crit":
			path = "res://assets/fx/BrilhoDourado.png"
			target_size = Vector2(19, 19)
			lifetime = 0.28
			end_scale = 1.55
		"kill":
			path = "res://assets/fx/PufffRosa.png"
			target_size = Vector2(18, 18)
			lifetime = 0.30
			drift = Vector2(0, -16)
			end_scale = 1.45
		"heart":
			path = "res://assets/fx/CoracaoAlado.png"
			target_size = Vector2(15, 15)
			lifetime = 0.42
			drift = Vector2(randf_range(-15, 15), -34)
		"strawberry":
			path = "res://assets/fx/MorangoFull.png"
			target_size = Vector2(14, 14)
			lifetime = 0.46
			drift = Vector2(randf_range(-26, 26), randf_range(-42, -18))
		"powerup":
			path = "res://assets/fx/CoracaoRosaMoldura.png"
			target_size = Vector2(22, 22)
			lifetime = 0.58
			drift = Vector2(0, -24)
			end_scale = 1.65
		"puff":
			path = "res://assets/fx/PufffRosa.png"
			target_size = Vector2(22, 22)
			lifetime = 0.32
			drift = Vector2.ZERO
			end_scale = 1.65
		"muzzle":
			path = "res://assets/fx/BrilhoRosa.png"
			target_size = Vector2(10, 10)
			lifetime = 0.12
			drift = direction.normalized() * 18.0
			end_scale = 1.28
	var fx: CuteFX = CuteFX.new()
	add_child(fx)
	fx.configure(global_pos, path, target_size * size_multiplier, lifetime, drift, spin, 0.72, end_scale)

func on_enemy_killed(pos: Vector2, xp_value: int = 1, was_elite: bool = false) -> void:
	player.register_kill()
	if hud != null:
		hud.on_kill()
	var orb: XPOrb = XPOrb.new()
	orb.value = maxi(1, roundi(float(xp_value) * player.get_cute_xp_multiplier()))
	orb.global_position = pos
	add_child.call_deferred(orb)
	spawn_cute_fx(pos, "kill", Vector2.UP, 1.15 if was_elite else 0.85)
	if randf() < (0.38 if was_elite else 0.14):
		spawn_cute_fx(pos + Vector2(randf_range(-8, 8), -5), "heart", Vector2.UP, 1.0)
	if player.cute_meter >= 75.0 and randf() < 0.22:
		spawn_cute_fx(pos + Vector2(randf_range(-10, 10), 0), "strawberry", Vector2.UP, 1.0)
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
	spawn_cute_fx(pos, "crit", Vector2.ZERO, 2.5)
	spawn_cute_fx(pos + Vector2(-24, -12), "heart", Vector2.UP, 1.8)
	spawn_cute_fx(pos + Vector2(24, -6), "strawberry", Vector2.UP, 1.8)
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
	spawn_cute_fx(player.global_position + Vector2(0, -28), "powerup", Vector2.UP, 1.55 if legendary else 1.0)
	spawn_cute_fx(player.global_position + Vector2(18, -18), "crit", Vector2.ZERO, 1.15 if legendary else 0.75)
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
