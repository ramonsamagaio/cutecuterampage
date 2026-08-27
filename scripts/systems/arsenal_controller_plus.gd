class_name ArsenalControllerPlus
extends ArsenalController

# Pass 07 deliberately reuses the base controller's stars, mines, drops and transient
# visual pools. Only Bowling For Besties needs its own tiny moving-token array.
const MAX_BALLS: int = 6
var _balls: Array[Dictionary] = []
var _ball_hit_tick: float = 0.0
var _tea_angle: float = 0.0
var _audio: CuteAudioDirector

func _bind_runtime() -> void:
	super._bind_runtime()
	_audio = get_tree().get_first_node_in_group("audio") as CuteAudioDirector

func _process(delta: float) -> void:
	super._process(delta)
	if not is_instance_valid(_player) or _game == null:
		return
	_ball_hit_tick = maxf(0.0, _ball_hit_tick - delta)
	_update_balls(delta)

func get_active_attack_token_count() -> int:
	return super.get_active_attack_token_count() + _balls.size()

func _weapon_cooldown(id: String, level_value: int) -> float:
	var base: float = -1.0
	match id:
		"love_letter_opener": base = 1.05
		"honey_hazard": base = 1.55
		"bowling_besties": base = 2.10
		"bunny_hopper": base = 1.48
		"tea_party": base = 1.30
		"cupid_bad_day": base = 2.50
		"glitter_bomb": base = 2.75
		"marshmallow_hammer": base = 2.40
		"kiss_of_death": base = 2.95
		"rainbow_roadkill": base = 0.58
		_: return super._weapon_cooldown(id, level_value)
	var level_mult: float = maxf(0.70, 1.0 - float(level_value - 1) * 0.035)
	return base * level_mult * _cooldown_mult()

func _fire_weapon(id: String, level_value: int) -> void:
	_play_weapon_sfx(id)
	match id:
		"love_letter_opener": _fire_scissors(level_value)
		"honey_hazard": _fire_honey(level_value)
		"bowling_besties": _fire_bowling(level_value)
		"bunny_hopper": _fire_hopper(level_value)
		"tea_party": _fire_tea(level_value)
		"cupid_bad_day": _fire_cupid(level_value)
		"glitter_bomb": _fire_glitter(level_value)
		"marshmallow_hammer": _fire_hammer(level_value)
		"kiss_of_death": _fire_kiss(level_value)
		"rainbow_roadkill": _fire_rainbow(level_value)
		_: super._fire_weapon(id, level_value)

func _play_weapon_sfx(id: String) -> void:
	if not is_instance_valid(_audio):
		_audio = get_tree().get_first_node_in_group("audio") as CuteAudioDirector
	if is_instance_valid(_audio):
		_audio.play_weapon(id, _is_evolved(id))

func _fire_scissors(level_value: int) -> void:
	var dir: Vector2 = _facing_dir()
	var reach: float = (94.0 + float(level_value) * 7.0) * _area_mult()
	var damage_value: float = _damage(1.02 + float(level_value) * 0.13, "love_letter_opener")
	_damage_arc(_player.global_position, dir.rotated(-0.23), reach, 0.54, damage_value)
	_damage_arc(_player.global_position, dir.rotated(0.23), reach, 0.54, damage_value)
	if _is_evolved("love_letter_opener"):
		_damage_beam(_player.global_position, dir, reach * 1.75, 22.0 * _area_mult(), damage_value * 0.72)
	_add_visual("slash", _player.global_position, reach, 0.20, dir)

func _fire_honey(level_value: int) -> void:
	# Uses the same persistent-area pool and 0.23 s damage cadence as Bubblegum Minefield.
	if _mines.size() >= MAX_MINES:
		_minies_trim()
	var target: Node2D = _game.call("get_priority_enemy", _player.global_position, 520.0) as Node2D
	var p: Vector2 = target.global_position if is_instance_valid(target) else _player.global_position - _facing_dir() * 46.0
	_mines.append({
		"pos": p,
		"age": 0.0,
		"life": (4.5 + float(level_value) * 0.34) * _duration_mult() * (1.35 if _is_evolved("honey_hazard") else 1.0),
		"radius": (36.0 + float(level_value) * 3.8) * _area_mult() * (1.18 if _is_evolved("honey_hazard") else 1.0),
		"damage": _damage(0.30 + float(level_value) * 0.038, "honey_hazard")
	})

func _fire_bowling(level_value: int) -> void:
	if _balls.size() >= MAX_BALLS:
		return
	var target: Node2D = _game.call("get_nearest_enemy", _player.global_position) as Node2D
	var dir: Vector2 = _facing_dir()
	if is_instance_valid(target):
		dir = _player.global_position.direction_to(target.global_position)
	var count: int = 2 if _is_evolved("bowling_besties") else 1
	for i: int in count:
		if _balls.size() >= MAX_BALLS:
			break
		var shot_dir: Vector2 = dir.rotated((float(i) - float(count - 1) * 0.5) * 0.22)
		_balls.append({
			"pos": _player.global_position + shot_dir * 32.0,
			"vel": shot_dir * (215.0 + float(level_value) * 11.0) * _speed_mult(),
			"age": 0.0,
			"life": 1.95 * _duration_mult(),
			"radius": (22.0 + float(level_value) * 1.1) * _area_mult(),
			"damage": _damage(1.02 + float(level_value) * 0.12, "bowling_besties"),
			"hits": {}
		})

func _fire_hopper(level_value: int) -> void:
	var candidates: Array = _game.call("get_enemies_near", _player.global_position, 520.0)
	if candidates.is_empty():
		return
	var hops: int = mini(8, 2 + floori(float(level_value) / 2.0) + _amount_bonus() + (2 if _is_evolved("bunny_hopper") else 0))
	var used: Dictionary = {}
	var current: Vector2 = _player.global_position
	for _hop: int in hops:
		var best: Node2D = null
		var best_sq: float = INF
		for entry: Variant in candidates:
			var enemy: Node2D = entry as Node2D
			if not is_instance_valid(enemy) or used.has(enemy.get_instance_id()):
				continue
			var dist_sq: float = current.distance_squared_to(enemy.global_position)
			if dist_sq < best_sq:
				best_sq = dist_sq
				best = enemy
		if not is_instance_valid(best):
			break
		var segment: Vector2 = best.global_position - current
		var critical: bool = randf() < _crit_chance()
		best.call("take_damage", _damage(0.62 + float(level_value) * 0.075, "bunny_hopper") * (1.75 if critical else 1.0), segment.normalized(), critical)
		_add_visual("slash", current, minf(82.0, segment.length()), 0.13, segment.normalized())
		used[best.get_instance_id()] = true
		current = best.global_position

func _fire_tea(level_value: int) -> void:
	_tea_angle = fmod(_tea_angle + 0.38, TAU)
	var count: int = mini(8, 3 + _amount_bonus() + (2 if level_value >= 6 else 0) + (2 if _is_evolved("tea_party") else 0))
	for i: int in count:
		if _stars.size() >= MAX_STAR_SHOTS:
			break
		var angle: float = _tea_angle + TAU * float(i) / float(count)
		var dir: Vector2 = Vector2.RIGHT.rotated(angle)
		_stars.append({
			"pos": _player.global_position + dir * 30.0,
			"vel": dir * (280.0 + float(level_value) * 10.0) * _speed_mult(),
			"age": 0.0,
			"life": 1.16 * _duration_mult(),
			"radius": (10.0 + float(level_value) * 0.6) * _area_mult(),
			"damage": _damage(0.46 + float(level_value) * 0.055, "tea_party"),
			"hits": {}
		})
	_add_visual("pulse", _player.global_position, 52.0 * _area_mult(), 0.20, Vector2.ZERO)

func _fire_cupid(level_value: int) -> void:
	var dir: Vector2 = Vector2(0.78, 0.62).normalized()
	if _facing_dir().x < 0.0:
		dir.x *= -1.0
	var side: Vector2 = Vector2(-dir.y, dir.x)
	var lanes: int = mini(6, 2 + floori(float(level_value) / 3.0) + _amount_bonus() + (1 if _is_evolved("cupid_bad_day") else 0))
	var width: float = (12.0 + float(level_value) * 1.2) * _area_mult()
	for i: int in lanes:
		var offset: float = (float(i) - float(lanes - 1) * 0.5) * 72.0
		var origin: Vector2 = _player.global_position - dir * 360.0 + side * offset
		_damage_beam(origin, dir, 720.0, width, _damage(0.78 + float(level_value) * 0.085, "cupid_bad_day"))
	_add_visual("slash", _player.global_position, 180.0 * _area_mult(), 0.23, dir)

func _fire_glitter(level_value: int) -> void:
	# Glitter Bomb reuses the delayed heavy-impact pool. Sprite/VFX can diverge later.
	if _drops.size() >= MAX_DROPS:
		return
	var target: Node2D = _game.call("get_priority_enemy", _player.global_position, 650.0) as Node2D
	var p: Vector2 = target.global_position if is_instance_valid(target) else _player.global_position + _facing_dir() * 180.0
	var count: int = 3 if _is_evolved("glitter_bomb") else 1
	for i: int in count:
		if _drops.size() >= MAX_DROPS:
			break
		var offset: Vector2 = Vector2.ZERO if i == 0 else Vector2.RIGHT.rotated(TAU * float(i) / float(count)) * 58.0
		_drops.append({
			"pos": p + offset,
			"time": 0.82 + float(i) * 0.06,
			"radius": (58.0 + float(level_value) * 5.0) * _area_mult(),
			"damage": _damage(1.60 + float(level_value) * 0.17, "glitter_bomb")
		})

func _fire_hammer(level_value: int) -> void:
	var dir: Vector2 = _facing_dir()
	var reach: float = (106.0 + float(level_value) * 8.0) * _area_mult()
	var center: Vector2 = _player.global_position + dir * reach * 0.52
	var damage_value: float = _damage(1.95 + float(level_value) * 0.22, "marshmallow_hammer")
	_damage_circle(center, reach * 0.58, damage_value)
	if _is_evolved("marshmallow_hammer"):
		_damage_circle(_player.global_position, reach * 0.82, damage_value * 0.52)
	_add_visual("teddy_impact", center, reach * 0.66, 0.36, dir)
	_game.call("add_screen_shake", 6.8 if not _is_evolved("marshmallow_hammer") else 9.0, 0.15)

func _fire_kiss(level_value: int) -> void:
	var candidates: Array = _game.call("get_enemies_near", _player.global_position, 720.0)
	var best: Node2D = null
	var best_hp: float = -1.0
	for entry: Variant in candidates:
		var enemy: Node2D = entry as Node2D
		if not is_instance_valid(enemy):
			continue
		var hp_value: Variant = enemy.get("hp")
		var hp_number: float = 0.0
		if typeof(hp_value) == TYPE_FLOAT or typeof(hp_value) == TYPE_INT:
			hp_number = float(hp_value)
		if hp_number > best_hp:
			best_hp = hp_number
			best = enemy
	if not is_instance_valid(best):
		return
	var dir: Vector2 = _player.global_position.direction_to(best.global_position)
	var percent_chunk: float = minf(36.0 + float(level_value) * 3.0, maxf(0.0, best_hp) * (0.055 + float(level_value) * 0.006))
	var damage_value: float = _damage(1.28 + float(level_value) * 0.10, "kiss_of_death") + percent_chunk
	if _is_evolved("kiss_of_death"):
		damage_value *= 1.30
	best.call("take_damage", damage_value, dir, true)
	_game.call("spawn_cute_fx", best.global_position, "crit", Vector2.ZERO, 1.15)

func _fire_rainbow(level_value: int) -> void:
	# Movement history as damage, using the same capped persistent-area pool as mines/honey.
	if _mines.size() >= MAX_MINES:
		_minies_trim()
	var backwards: Vector2 = -_player.velocity.normalized()
	if backwards == Vector2.ZERO:
		backwards = -_facing_dir()
	_mines.append({
		"pos": _player.global_position + backwards * 30.0,
		"age": 0.0,
		"life": (2.4 + float(level_value) * 0.22) * _duration_mult() * (1.30 if _is_evolved("rainbow_roadkill") else 1.0),
		"radius": (27.0 + float(level_value) * 2.0) * _area_mult(),
		"damage": _damage(0.25 + float(level_value) * 0.03, "rainbow_roadkill")
	})

func _update_balls(delta: float) -> void:
	var do_hits: bool = _ball_hit_tick <= 0.0
	if do_hits:
		_ball_hit_tick = 0.065
	for i: int in range(_balls.size() - 1, -1, -1):
		var ball: Dictionary = _balls[i]
		ball["age"] = float(ball["age"]) + delta
		ball["pos"] = Vector2(ball["pos"]) + Vector2(ball["vel"]) * delta
		if do_hits:
			var before: int = (ball["hits"] as Dictionary).size()
			_hit_moving_token(ball)
			var after: int = (ball["hits"] as Dictionary).size()
			if after > before:
				ball["radius"] = minf(48.0 * _area_mult(), float(ball["radius"]) + float(after - before) * 2.2)
		if float(ball["age"]) >= float(ball["life"]):
			_balls.remove_at(i)
		else:
			_balls[i] = ball

func _draw() -> void:
	super._draw()
	for ball: Dictionary in _balls:
		var p: Vector2 = ball["pos"]
		var r: float = float(ball["radius"])
		draw_circle(p + Vector2(3, 5), r, Color(0.18, 0.08, 0.15, 0.16))
		draw_circle(p, r, Color(1.35, 0.42, 0.72, 0.88))
		draw_circle(p + Vector2(-r * 0.28, -r * 0.18), r * 0.09, Color(0.18, 0.07, 0.16, 0.9))
		draw_circle(p + Vector2(r * 0.28, -r * 0.18), r * 0.09, Color(0.18, 0.07, 0.16, 0.9))
		draw_arc(p + Vector2(0, r * 0.08), r * 0.30, 0.2, PI - 0.2, 10, Color(1.0, 0.9, 0.95, 0.8), 2.0)
