class_name EnemyDirector
extends Node

var player: Node2D
var elapsed: float = 0.0
var spawn_timer: float = 0.30
var next_surge: float = 16.0
var burst_remaining: int = 0
var threat_tier: int = 1
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 20260824

func _process(delta: float) -> void:
	if player == null:
		return
	elapsed += delta
	spawn_timer -= delta
	var player_level: int = int(player.call("get_level_value"))
	threat_tier = 1 + floori(elapsed / 50.0) + floori(float(maxi(0, player_level - 1)) / 8.0)

	if elapsed >= next_surge:
		burst_remaining += 8 + threat_tier * 5
		next_surge += maxf(16.0, 24.0 - float(threat_tier) * 0.55)

	var count: int = get_tree().get_nodes_in_group("enemy").size()
	var max_enemies: int = mini(340, 55 + player_level * 3 + floori(elapsed * 0.55))
	if spawn_timer <= 0.0 and count < max_enemies:
		_spawn_enemy(player_level)
		if burst_remaining > 0:
			burst_remaining -= 1
			spawn_timer = 0.065
		else:
			var cadence: float = 0.78 - elapsed * 0.0022 - float(player_level) * 0.0065
			spawn_timer = maxf(0.075, cadence)

func _spawn_enemy(player_level: int) -> void:
	var enemy: CuteEnemy = CuteEnemy.new()
	var pig_chance: float = clampf(0.22 + elapsed * 0.00035 + float(player_level) * 0.0025, 0.22, 0.48)
	enemy.enemy_kind = "pig" if rng.randf() < pig_chance else "chick"

	var shooter_chance: float = clampf(maxf(0.0, elapsed - 35.0) * 0.00065 + float(maxi(0, player_level - 7)) * 0.0055, 0.0, 0.24)
	var charger_chance: float = clampf(maxf(0.0, elapsed - 55.0) * 0.00055 + float(maxi(0, player_level - 11)) * 0.0048, 0.0, 0.22)
	var roll: float = rng.randf()
	if roll < shooter_chance:
		enemy.archetype = "shooter"
	elif roll < shooter_chance + charger_chance:
		enemy.archetype = "charger"
	else:
		enemy.archetype = "chaser"

	var elite_chance: float = clampf(0.015 + float(threat_tier) * 0.014, 0.02, 0.18)
	enemy.elite = rng.randf() < elite_chance
	var level_term: float = pow(float(maxi(0, player_level - 1)), 1.18) * 0.065
	enemy.power_scale = 1.0 + elapsed / 95.0 + level_term

	var angle: float = rng.randf_range(0.0, TAU)
	var radius: float = rng.randf_range(520.0, 720.0)
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
	get_parent().add_child(enemy)

func get_threat_tier() -> int:
	return threat_tier

func get_elapsed() -> float:
	return elapsed
