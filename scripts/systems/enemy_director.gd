class_name EnemyDirector
extends Node

var player: Node2D
var elapsed: float = 0.0
var spawn_timer: float = 0.24
var next_surge: float = 13.0
var burst_remaining: int = 0
var threat_tier: int = 1
var boss_spawned: bool = false
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _game_node: Node

func _ready() -> void:
	rng.seed = 20260824
	_game_node = get_tree().get_first_node_in_group("game")

func _process(delta: float) -> void:
	if player == null:
		return
	elapsed += delta
	spawn_timer -= delta
	var player_level: int = int(player.call("get_level_value"))
	threat_tier = 1 + floori(elapsed / 42.0) + floori(float(maxi(0, player_level - 1)) / 7.0)

	if _game_node == null or not is_instance_valid(_game_node):
		_game_node = get_tree().get_first_node_in_group("game")
	if not boss_spawned and elapsed >= 125.0 and _game_node != null:
		boss_spawned = true
		var boss_power: float = 1.08 + float(threat_tier) * 0.20 + float(player_level) * 0.038
		_game_node.call("spawn_boss", boss_power)

	var boss_active: bool = bool(_game_node.call("is_boss_active")) if _game_node != null else false
	if elapsed >= next_surge and not boss_active:
		burst_remaining += 10 + threat_tier * 5
		next_surge += maxf(14.0, 22.0 - float(threat_tier) * 0.52)

	var count: int = int(_game_node.call("get_enemy_count")) if _game_node != null else 0
	# Performance budget: difficulty comes increasingly from tougher mixed archetypes,
	# not an unlimited Node2D population.
	var max_enemies: int = mini(280, 64 + player_level * 3 + floori(elapsed * 0.48))
	if boss_active:
		max_enemies = mini(max_enemies, 96 + threat_tier * 5)

	if spawn_timer <= 0.0 and count < max_enemies:
		_spawn_enemy(player_level)
		if burst_remaining > 0 and not boss_active:
			burst_remaining -= 1
			spawn_timer = 0.060
		else:
			var cadence: float = 0.70 - elapsed * 0.0021 - float(player_level) * 0.0067
			if boss_active:
				cadence *= 1.55
			spawn_timer = maxf(0.074, cadence)

func _spawn_enemy(player_level: int) -> void:
	var enemy: CuteEnemy = CuteEnemy.new()
	var pig_chance: float = clampf(0.26 + elapsed * 0.00042 + float(player_level) * 0.0030, 0.26, 0.54)
	enemy.enemy_kind = "pig" if rng.randf() < pig_chance else "chick"

	var shooter_chance: float = clampf(maxf(0.0, elapsed - 24.0) * 0.00078 + float(maxi(0, player_level - 5)) * 0.0062, 0.0, 0.29)
	var charger_chance: float = clampf(maxf(0.0, elapsed - 38.0) * 0.00068 + float(maxi(0, player_level - 8)) * 0.0056, 0.0, 0.27)
	var roll: float = rng.randf()
	if roll < shooter_chance:
		enemy.archetype = "shooter"
	elif roll < shooter_chance + charger_chance:
		enemy.archetype = "charger"
	else:
		enemy.archetype = "chaser"

	var elite_chance: float = clampf(0.022 + float(threat_tier) * 0.016, 0.025, 0.20)
	enemy.elite = rng.randf() < elite_chance
	if enemy.elite:
		var affixes: Array[String] = ["swift", "tank", "volatile"]
		enemy.elite_affix = affixes[rng.randi_range(0, affixes.size() - 1)]
	var level_term: float = pow(float(maxi(0, player_level - 1)), 1.18) * 0.078
	enemy.power_scale = 1.0 + elapsed / 84.0 + level_term

	var angle: float = rng.randf_range(0.0, TAU)
	var radius: float = rng.randf_range(500.0, 690.0)
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
	get_parent().add_child(enemy)

func get_threat_tier() -> int:
	return threat_tier

func get_elapsed() -> float:
	return elapsed
