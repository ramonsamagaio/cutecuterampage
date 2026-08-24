class_name EnemyDirector
extends Node

var player: Node2D
var elapsed := 0.0
var spawn_timer := 0.3
var next_surge := 18.0
var burst_remaining := 0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 20260824

func _process(delta: float) -> void:
	if player == null:
		return
	elapsed += delta
	spawn_timer -= delta
	if elapsed >= next_surge:
		burst_remaining += 10 + floori(elapsed / 30.0) * 3
		next_surge += 22.0
	var count := get_tree().get_nodes_in_group("enemy").size()
	var max_enemies := mini(220, 55 + floori(elapsed * 1.7))
	if spawn_timer <= 0.0 and count < max_enemies:
		_spawn_enemy()
		if burst_remaining > 0:
			burst_remaining -= 1
			spawn_timer = 0.08
		else:
			spawn_timer = maxf(0.16, 0.92 - elapsed * 0.009)

func _spawn_enemy() -> void:
	var enemy := CuteEnemy.new()
	enemy.enemy_kind = "pig" if elapsed > 24.0 and rng.randf() < 0.30 else "chick"
	enemy.elite = elapsed > 42.0 and rng.randf() < minf(0.16, elapsed * 0.0015)
	var angle := rng.randf_range(0.0, TAU)
	var radius := rng.randf_range(500.0, 680.0)
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * radius
	get_parent().add_child(enemy)
