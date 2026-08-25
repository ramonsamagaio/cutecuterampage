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

func _ready() -> void:
	rng.seed = 20260824

func _process(delta: float) -> void:
	if player == null:
		return
	elapsed += delta
	spawn_timer -= delta
	var player_level: int = int(player.call("get_level_value"))
	threat_tier = 1 + floori(elapsed / 42.0) + floori(float(maxi(0, player_level - 1)) / 7.0)

	var game_node: Node = get_tree().get_first_node_in_group("game")
	if not boss_spawned and elapsed >= 125.0 and game_node != null:
		boss_spawned = true
		var boss_power: float = 1.08 + float(threat_tier) * 0.20 + float(player_level) * 0.038
		game_node.call("spawn_boss", boss_power)

	var boss_active: bool = bool(game_node.call("is_boss_active")) if game_node != null else false
	if elapsed >= next_surge and not boss_active:
		burst_remaining += 12 + threat_tier * 6
		next_surge += maxf(13.5, 21.0 - float(threat_tier) * 0.52)

	var count: int = get_tree().get_nodes_in_group("enemy").size()
	var max_enemies: int = mini(380, 72 + player_level * 4 + floori(elapsed * 0.62))
	if boss_active:
		max_enemies = mini(max_enemies, 110 + threat_tier * 6)

	if spawn_timer <= 0.0 and count < max_enemies:
		_spawn_enemy(player_level)
		if burst_remaining > 0 and not boss_active:
			burst_remaining -= 1
			spawn_timer = 0.052
		else:
			var cadence: float = 0.66 - elapsed * 0.00235 - float(player_level) * 0.0072
			if boss_active:
				cadence *= 1.50
			spawn_timer = maxf(0.065, cadence)

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
	var level_term: float = pow(float(maxi(0, player_level - 1)), 1.18) * 0.072
	enemy.power_scale = 1.0 + elapsed / 88.0 + level_term

	var angle: float = rng.randf_range(0.0, TAU)
	var radius: float = rng.randf_range(500.0, 690.0)
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
	get_parent().add_child(enemy)

func get_threat_tier() -> int:
	return threat_tier

func get_elapsed() -> float:
	return elapsed
