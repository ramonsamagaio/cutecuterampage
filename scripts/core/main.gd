extends Node2D

const TAFFI_SCENE: PackedScene = preload("res://scenes/actors/Taffi.tscn")
const SPECIAL_BEAM_LENGTH: float = 1180.0
const MAX_PLAYER_PROJECTILES: int = 220
const MAX_ENEMY_PROJECTILES: int = 260
const MAX_CUTE_FX: int = 110

var player: TaffiController
var hud: GameHUD
var blood: BloodSystem
var streamer: ChunkStreamer
var director: EnemyDirector
var love_orbit: LoveOrbit
var current_boss: SugarBoss
var enemy_index: EnemySpatialIndex = EnemySpatialIndex.new()

var _camera_shake_strength: float = 0.0
var _camera_shake_time: float = 0.0
var _camera_shake_duration: float = 0.0
var _hit_feedback_cooldown: float = 0.0
var _active_cute_fx: int = 0
var _active_player_projectiles: int = 0
var _active_enemy_projectiles: int = 0
var _total_kills: int = 0

func _ready() -> void:
	add_to_group("game")
	_setup_vfx_environment()
	_setup_world_finish()
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

func _process(delta: float) -> void:
	_hit_feedback_cooldown = maxf(0.0, _hit_feedback_cooldown - delta)
	if not is_instance_valid(player):
		return
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return
	if _camera_shake_time > 0.0:
		_camera_shake_time = maxf(0.0, _camera_shake_time - delta)
		var life_ratio: float = _camera_shake_time / maxf(0.001, _camera_shake_duration)
		var current_strength: float = _camera_shake_strength * clampf(life_ratio, 0.0, 1.0)
		camera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * current_strength
	else:
		_camera_shake_strength = 0.0
		camera.offset = camera.offset.lerp(Vector2.ZERO, minf(1.0, delta * 18.0))

func add_screen_shake(strength: float, duration: float = 0.12) -> void:
	_camera_shake_strength = minf(14.0, maxf(_camera_shake_strength, strength))
	_camera_shake_time = maxf(_camera_shake_time, duration)
	_camera_shake_duration = maxf(_camera_shake_duration, duration)
	if _camera_shake_time == duration:
		_camera_shake_duration = duration

func _setup_vfx_environment() -> void:
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.name = "CuteCuteVFXEnvironment"
	var environment_resource: Environment = Environment.new()
	environment_resource.glow_enabled = true
	environment_resource.glow_intensity = 1.12
	environment_resource.glow_bloom = 0.13
	environment_resource.glow_hdr_threshold = 0.68
	environment_resource.glow_hdr_scale = 2.20
	environment_resource.glow_strength = 1.18
	environment_resource.glow_normalized = false
	world_environment.environment = environment_resource
	add_child(world_environment)

func _setup_world_finish() -> void:
	var finish_layer: CanvasLayer = CanvasLayer.new()
	finish_layer.name = "WorldFinishLayer"
	finish_layer.layer = 5
	add_child(finish_layer)
	var overlay: ColorRect = ColorRect.new()
	overlay.name = "WorldFinish"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color.WHITE
	var finish_shader: Shader = load("res://shaders/world_finish.gdshader") as Shader
	if finish_shader != null:
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = finish_shader
		overlay.material = material
	finish_layer.add_child(overlay)

func register_enemy(enemy: Node2D) -> void:
	enemy_index.register_enemy(enemy)

func unregister_enemy(enemy: Node2D) -> void:
	enemy_index.unregister_enemy(enemy)

func update_enemy_spatial(enemy: Node2D) -> void:
	enemy_index.update_enemy(enemy)

func get_enemy_count() -> int:
	return enemy_index.get_count()

func get_enemies_near(center: Vector2, radius: float) -> Array[Node2D]:
	return enemy_index.get_nearby(center, radius)

func get_nearest_enemy(from: Vector2) -> Node2D:
	return enemy_index.get_nearest(from, 960.0)

func get_priority_enemy(from: Vector2, max_range: float) -> Node2D:
	if is_instance_valid(current_boss) and from.distance_to(current_boss.global_position) <= max_range:
		return current_boss
	var nearest: Node2D = null
	var best_score: float = INF
	var candidates: Array[Node2D] = get_enemies_near(from, max_range)
	for enemy: Node2D in candidates:
		var distance: float = from.distance_to(enemy.global_position)
		var score: float = distance * (0.35 if enemy.is_in_group("boss") else 1.0)
		if score < best_score:
			best_score = score
			nearest = enemy
	return nearest

func spawn_projectile(origin: Vector2, direction: Vector2, damage_amount: float, kind: String = "heart", pierce: int = 0, speed: float = 390.0) -> void:
	if _active_player_projectiles >= MAX_PLAYER_PROJECTILES:
		return
	var projectile: CuteProjectile = CuteProjectile.new()
	add_child(projectile)
	_active_player_projectiles += 1
	projectile.tree_exited.connect(_on_player_projectile_exited)
	projectile.configure(origin, direction, damage_amount, kind, pierce, speed)
	if randf() < 0.34:
		spawn_cute_fx(origin, "muzzle", direction, 0.92)

func _on_player_projectile_exited() -> void:
	_active_player_projectiles = maxi(0, _active_player_projectiles - 1)

func spawn_cupcake_mortar(origin: Vector2, target: Vector2, damage_amount: float, radius: float, evolved: bool) -> void:
	var mortar: CupcakeMortar = CupcakeMortar.new()
	add_child(mortar)
	mortar.configure(origin, target, damage_amount, radius, evolved)
	spawn_cute_fx(origin, "heart", origin.direction_to(target), 0.95)

func explode_cupcake(center: Vector2, damage_amount: float, radius: float, evolved: bool) -> void:
	var candidates: Array[Node2D] = get_enemies_near(center, radius)
	for enemy: Node2D in candidates:
		if enemy == null or not is_instance_valid(enemy):
			continue
		var distance: float = center.distance_to(enemy.global_position)
		if distance <= radius:
			var falloff: float = lerpf(1.0, 0.58, clampf(distance / maxf(1.0, radius), 0.0, 1.0))
			enemy.call("take_damage", damage_amount * falloff, center.direction_to(enemy.global_position), distance < radius * 0.35)
	blood.emit_burst(center, Vector2.UP, 13 if evolved else 8)
	spawn_cute_fx(center, "puff", Vector2.UP, 1.55 if evolved else 1.18)
	spawn_cute_fx(center, "impact", Vector2.ZERO, 1.70 if evolved else 1.30)
	add_screen_shake(8.0 if evolved else 5.0, 0.18 if evolved else 0.13)
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
	if _active_enemy_projectiles >= MAX_ENEMY_PROJECTILES:
		return
	var projectile: EnemyCandyBullet = EnemyCandyBullet.new()
	add_child(projectile)
	_active_enemy_projectiles += 1
	projectile.tree_exited.connect(_on_enemy_projectile_exited)
	projectile.configure(origin, direction, damage_amount, speed)

func _on_enemy_projectile_exited() -> void:
	_active_enemy_projectiles = maxi(0, _active_enemy_projectiles - 1)

func spawn_cute_fx(global_pos: Vector2, kind: String, direction: Vector2 = Vector2.ZERO, size_multiplier: float = 1.0) -> void:
	if _active_cute_fx >= MAX_CUTE_FX:
		return
	var path: String = "res://assets/fx/BrilhoRosa.png"
	var target_size: Vector2 = Vector2(17, 17)
	var lifetime: float = 0.24
	var drift: Vector2 = direction.normalized() * 34.0
	var spin: float = randf_range(-3.1, 3.1)
	var end_scale: float = 1.35
	match kind:
		"impact":
			path = "res://assets/fx/ImpactoRosa.png"
			target_size = Vector2(23, 23)
			lifetime = 0.20
			end_scale = 1.58
		"crit":
			path = "res://assets/fx/BrilhoDourado.png"
			target_size = Vector2(31, 31)
			lifetime = 0.31
			end_scale = 1.75
		"kill":
			path = "res://assets/fx/PufffRosa.png"
			target_size = Vector2(28, 28)
			lifetime = 0.32
			drift = Vector2(0, -19)
			end_scale = 1.62
		"heart":
			path = "res://assets/fx/CoracaoAlado.png"
			target_size = Vector2(22, 22)
			lifetime = 0.42
			drift = Vector2(randf_range(-18, 18), -38)
		"strawberry":
			path = "res://assets/fx/MorangoFull.png"
			target_size = Vector2(20, 20)
			lifetime = 0.46
			drift = Vector2(randf_range(-30, 30), randf_range(-46, -20))
		"powerup":
			path = "res://assets/fx/CoracaoRosaMoldura.png"
			target_size = Vector2(30, 30)
			lifetime = 0.58
			drift = Vector2(0, -28)
			end_scale = 1.82
		"puff":
			path = "res://assets/fx/PufffRosa.png"
			target_size = Vector2(34, 34)
			lifetime = 0.32
			drift = Vector2.ZERO
			end_scale = 1.82
		"muzzle":
			path = "res://assets/fx/BrilhoRosa.png"
			target_size = Vector2(16, 16)
			lifetime = 0.11
			drift = direction.normalized() * 24.0
			end_scale = 1.42
	var fx: CuteFX = CuteFX.new()
	add_child(fx)
	_active_cute_fx += 1
	fx.tree_exited.connect(_on_cute_fx_exited)
	fx.configure(global_pos, path, target_size * size_multiplier, lifetime, drift, spin, 0.72, end_scale)

func _on_cute_fx_exited() -> void:
	_active_cute_fx = maxi(0, _active_cute_fx - 1)

func on_enemy_hit_feedback(pos: Vector2, is_critical: bool, amount: float) -> void:
	if not is_critical and _hit_feedback_cooldown > 0.0:
		return
	_hit_feedback_cooldown = 0.032 if not is_critical else 0.018
	var shake: float = 1.55 + minf(1.8, amount * 0.028)
	if is_critical:
		shake += 2.9
	add_screen_shake(shake, 0.095 if not is_critical else 0.14)
	if is_critical:
		spawn_cute_fx(pos, "crit", Vector2.ZERO, 1.25)
	elif randf() < 0.22:
		spawn_cute_fx(pos, "impact", Vector2.ZERO, 0.82)

func on_enemy_killed(pos: Vector2, xp_value: int = 1, was_elite: bool = false) -> void:
	_total_kills += 1
	player.register_kill()
	if hud != null:
		hud.on_kill()
	var orb: XPOrb = XPOrb.new()
	orb.value = maxi(1, roundi(float(xp_value) * player.get_cute_xp_multiplier()))
	orb.global_position = pos
	add_child.call_deferred(orb)
	spawn_cute_fx(pos, "kill", Vector2.UP, 1.35 if was_elite else 0.98)
	add_screen_shake(5.8 if was_elite else 3.2, 0.16 if was_elite else 0.105)
	if randf() < (0.40 if was_elite else 0.14):
		spawn_cute_fx(pos + Vector2(randf_range(-8, 8), -5), "heart", Vector2.UP, 1.05)
	if player.cute_meter >= 75.0 and randf() < 0.20:
		spawn_cute_fx(pos + Vector2(randf_range(-10, 10), 0), "strawberry", Vector2.UP, 1.0)

	# Visible reward pacing. Early guaranteed boxes teach the system; later boxes become jackpot punctuation.
	if _total_kills == 18:
		spawn_reward_chest(pos, false, 1)
	elif _total_kills == 65:
		spawn_reward_chest(pos, false, 3)
	elif _total_kills >= 175 and _total_kills % 175 == 0:
		spawn_reward_chest(pos, false, 3)
	elif was_elite and randf() < 0.18:
		spawn_reward_chest(pos, false, 3 if randf() < 0.27 else 1)

func spawn_boss(power: float) -> void:
	if is_instance_valid(current_boss):
		return
	current_boss = SugarBoss.new()
	current_boss.name = "QueenMallow"
	current_boss.configure(power)
	var angle: float = randf_range(0.0, TAU)
	current_boss.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * 610.0
	add_child(current_boss)
	add_screen_shake(8.0, 0.28)
	if hud != null:
		hud.show_reward_toast("WARNING!  QUEEN MALLOW HAS ARRIVED")

func on_boss_defeated(pos: Vector2, defeated_name: String) -> void:
	current_boss = null
	player.cute_meter = minf(100.0, player.cute_meter + 28.0)
	player.special_meter = minf(100.0, player.special_meter + 35.0)
	spawn_cute_fx(pos, "crit", Vector2.ZERO, 2.7)
	spawn_cute_fx(pos + Vector2(-24, -12), "heart", Vector2.UP, 1.8)
	spawn_cute_fx(pos + Vector2(24, -6), "strawberry", Vector2.UP, 1.8)
	add_screen_shake(12.0, 0.32)
	spawn_reward_chest(pos, true, 5)
	if hud != null:
		hud.show_reward_toast("%s POPPED!  OMG!!! BOX INCOMING!" % defeated_name)

func spawn_reward_chest(pos: Vector2, legendary: bool, reward_count: int = 1) -> void:
	var chest: RewardChest = RewardChest.new()
	chest.legendary = legendary
	chest.reward_count = 5 if legendary else clampi(reward_count, 1, 5)
	chest.global_position = pos
	add_child.call_deferred(chest)

func claim_reward_chest(_pos: Vector2, legendary: bool, reward_count: int = 1) -> void:
	var count: int = 5 if legendary else clampi(reward_count, 1, 5)
	var tier_name: String = "OMG!!! BOX" if count >= 5 else ("PARTY BOX" if count >= 3 else "SWEET BOX")
	var rewards: Array[String] = []
	var arsenal: ArsenalController = get_tree().get_first_node_in_group("arsenal") as ArsenalController

	if is_instance_valid(arsenal):
		for i: int in count:
			# Boss/legendary boxes can evolve one ready weapon, then continue as juicy upgrade rolls.
			var evolution_roll: bool = legendary and i == 0
			rewards.append(arsenal.open_chest(evolution_roll))
	else:
		for i: int in count:
			if legendary and i == 0:
				rewards.append(player.claim_evolution_chest())
			else:
				rewards.append(player.claim_bonus_chest())

	var reward_text: String = tier_name
	if not rewards.is_empty():
		reward_text += "  ♡  " + "  +  ".join(rewards)

	var fx_scale: float = 1.05 + float(count - 1) * 0.12
	spawn_cute_fx(player.global_position + Vector2(0, -28), "powerup", Vector2.UP, fx_scale)
	spawn_cute_fx(player.global_position + Vector2(18, -18), "crit", Vector2.ZERO, 0.78 + float(count) * 0.12)
	if count >= 3:
		spawn_cute_fx(player.global_position + Vector2(-22, -15), "heart", Vector2.UP, 1.10)
	if count >= 5:
		spawn_cute_fx(player.global_position + Vector2(0, -40), "strawberry", Vector2.UP, 1.45)
	add_screen_shake(2.8 + float(count) * 1.25, 0.14 + float(count) * 0.018)
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
	# A concentrated opening flash sells the cannon firing without spawning a storm of nodes.
	spawn_cute_fx(beam_origin, "crit", beam_direction, 1.55)
	spawn_cute_fx(beam_origin + beam_direction * 20.0, "heart", beam_direction, 1.20)
	spawn_cute_fx(beam_origin - Vector2(0, 18), "strawberry", Vector2.UP, 1.10)
	add_screen_shake(10.5, 0.24)
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
	var query_center: Vector2 = origin + forward * (SPECIAL_BEAM_LENGTH * 0.5)
	var candidates: Array[Node2D] = get_enemies_near(query_center, SPECIAL_BEAM_LENGTH * 0.60)
	for enemy: Node2D in candidates:
		if enemy == null or not is_instance_valid(enemy):
			continue
		var offset: Vector2 = enemy.global_position - origin
		var along: float = offset.dot(forward)
		if along < -24.0 or along > SPECIAL_BEAM_LENGTH:
			continue
		var half_width: float = 68.0 + maxf(0.0, along) * 0.040
		var across: float = absf(offset.dot(side))
		if across <= half_width:
			enemy.call("take_damage", 9999.0, forward, true)

func get_threat_tier() -> int:
	return director.get_threat_tier() if director != null else 1

func get_run_time() -> float:
	return director.get_elapsed() if director != null else 0.0

func get_perf_snapshot() -> Dictionary:
	return {
		"enemies": get_enemy_count(),
		"player_projectiles": _active_player_projectiles,
		"enemy_projectiles": _active_enemy_projectiles,
		"cute_fx": _active_cute_fx,
		"blood_children": blood.get_child_count() if blood != null else 0,
		"splats": blood.splats.size() if blood != null else 0,
		"chests": get_tree().get_nodes_in_group("reward_chest").size()
	}
