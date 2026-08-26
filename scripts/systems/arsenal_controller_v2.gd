class_name ArsenalControllerV2
extends ArsenalController

const MAX_BOWLING_BALLS: int = 6
const MAX_HONEY_PUDDLES: int = 12
const MAX_GLITTER_BOMBS: int = 7
const MAX_RAINBOW_TRAILS: int = 16

var _audio: CuteAudioDirector
var _bowling_balls: Array[Dictionary] = []
var _honey_puddles: Array[Dictionary] = []
var _glitter_bombs: Array[Dictionary] = []
var _rainbow_trails: Array[Dictionary] = []
var _extra_hit_tick: float = 0.0
var _honey_tick: float = 0.0
var _rainbow_tick: float = 0.0
var _tea_angle: float = 0.0

func _bind_runtime() -> void:
	super._bind_runtime()
	_audio = get_tree().get_first_node_in_group("audio") as CuteAudioDirector

func _process(delta: float) -> void:
	super._process(delta)
	if not is_instance_valid(_player) or _game == null:
		return
	_extra_hit_tick = maxf(0.0, _extra_hit_tick - delta)
	_update_bowling_balls(delta)
	_update_honey(delta)
	_update_glitter(delta)
	_update_rainbow(delta)

func get_active_attack_token_count() -> int:
	return super.get_active_attack_token_count() + _bowling_balls.size() + _honey_puddles.size() + _glitter_bombs.size() + _rainbow_trails.size()

func _weapon_cooldown(id: String, level_value: int) -> float:
	var base: float = -1.0
	match id:
		"love_letter_opener": base = 1.05
		"honey_hazard": base = 1.52
		"bowling_besties": base = 2.10
		"bunny_hopper": base = 1.48
		"tea_party": base = 1.28
		"cupid_bad_day": base = 2.52
		"glitter_bomb": base = 2.72
		"marshmallow_hammer": base = 2.38
		"kiss_of_death": base = 2.92
		"rainbow_roadkill": base = 0.52
		_: return super._weapon_cooldown(id, level_value)
	var level_mult: float = maxf(0.70, 1.0 - float(level_value - 1) * 0.035)
	return base * level_mult * _cooldown_mult()

func _fire_weapon(id: String, level_value: int) -> void:
	_play_weapon_sfx(id)
	match id:
		"love_letter_opener": _fire_love_letter_opener(level_value)
		"honey_hazard": _fire_honey_hazard(level_value)
		"bowling_besties": _fire_bowling_besties(level_value)
		"bunny_hopper": _fire_bunny_hopper(level_value)
		"tea_party": _fire_tea_party(level_value)
		"cupid_bad_day": _fire_cupid_bad_day(level_value)
		"glitter_bomb": _fire_glitter_bomb(level_value)
		"marshmallow_hammer": _fire_marshmallow_hammer(level_value)
		"kiss_of_death": _fire_kiss_of_death(level_value)
		"rainbow_roadkill": _fire_rainbow_roadkill(level_value)
		_: super._fire_weapon(id, level_value)

func _play_weapon_sfx(id: String) -> void:
	if not is_instance_valid(_audio):
		_audio = get_tree().get_first_node_in_group("audio") as CuteAudioDirector
	if is_instance_valid(_audio):
		_audio.play_weapon(id, _is_evolved(id))

func _fire_love_letter_opener(level_value: int) -> void:
	var dir: Vector2 = _facing_dir()
	var reach: float = (92.0 + float(level_value) * 7.0) * _area_mult()
	var damage_value: float = _damage(1.02 + float(level_value) * 0.13, "love_letter_opener")
	_damage_arc(_player.global_position, dir.rotated(-0.24), reach, 0.50, damage_value)
	_damage_arc(_player.global_position, dir.rotated(0.24), reach, 0.50, damage_value)
	if _is_evolved("love_letter_opener"):
		_damage_beam(_player.global_position - dir * 20.0, dir, reach * 1.65, 22.0 * _area_mult(), damage_value * 0.72)
	_add_visual("scissors", _player.global_position, reach, 0.22, dir)

func _fire_honey_hazard(level_value: int) -> void:
	while _honey_puddles.size() >= MAX_HONEY_PUDDLES:
		_honey_puddles.pop_front()
	var target: Node2D = _game.call("get_priority_enemy", _player.global_position, 520.0) as Node2D
	var p: Vector2 = target.global_position if is_instance_valid(target) else _player.global_position - _player.velocity.normalized() * 40.0
	if p == _player.global_position:
		p += -_facing_dir() * 42.0
	_honey_puddles.append({
		"pos": p,
		"age": 0.0,
		"life": (4.0 + float(level_value) * 0.38) * _duration_mult() * (1.38 if _is_evolved("honey_hazard") else 1.0),
		"radius": (34.0 + float(level_value) * 3.7) * _area_mult() * (1.22 if _is_evolved("honey_hazard") else 1.0),
		"damage": _damage(0.30 + float(level_value) * 0.038, "honey_hazard")
	})

func _fire_bowling_besties(level_value: int) -> void:
	if _bowling_balls.size() >= MAX_BOWLING_BALLS:
		return
	var target: Node2D = _game.call("get_nearest_enemy", _player.global_position) as Node2D
	var dir: Vector2 = _facing_dir()
	if is_instance_valid(target):
		dir = _player.global_position.direction_to(target.global_position)
	var count: int = 2 if _is_evolved("bowling_besties") else 1
	for i: int in count:
		var shot_dir: Vector2 = dir.rotated((float(i) - float(count - 1) * 0.5) * 0.22)
		_bowling_balls.append({
			"pos": _player.global_position + shot_dir * 34.0,
			"vel": shot_dir * (215.0 + float(level_value) * 11.0) * _speed_mult(),
			"age": 0.0,
			"life": 2.0 * _duration_mult(),
			"radius": (21.0 + float(level_value) * 1.2) * _area_mult(),
			"damage": _damage(1.05 + float(level_value) * 0.12, "bowling_besties"),
			"hits": {}
		})

func _fire_bunny_hopper(level_value: int) -> void:
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
			var d: float = current.distance_squared_to(enemy.global_position)
			if d < best_sq:
				best_sq = d
				best = enemy
		if not is_instance_valid(best):
			break
		var segment: Vector2 = best.global_position - current
		var critical: bool = randf() < _crit_chance()
		best.call("take_damage", _damage(0.62 + float(level_value) * 0.075, "bunny_hopper") * (1.75 if critical else 1.0), segment.normalized(), critical)
		_add_visual("hop_link", current, segment.length(), 0.16, segment.normalized())
		used[best.get_instance_id()] = true
		current = best.global_position

func _fire_tea_party(level_value: int) -> void:
	_tea_angle = fmod(_tea_angle + 0.37, TAU)
	var count: int = mini(8, 3 + _amount_bonus() + (2 if level_value >= 6 else 0) + (2 if _is_evolved("tea_party") else 0))
	for i: int in count:
		if _stars.size() >= 26:
			break
		var angle: float = _tea_angle + TAU * float(i) / float(count)
		var dir: Vector2 = Vector2.RIGHT.rotated(angle)
		_stars.append({
			"pos": _player.global_position + dir * 32.0,
			"vel": dir * (275.0 + float(level_value) * 10.0) * _speed_mult(),
			"age": 0.0,
			"life": 1.18 * _duration_mult(),
			"radius": (10.0 + float(level_value) * 0.6) * _area_mult(),
			"damage": _damage(0.46 + float(level_value) * 0.055, "tea_party"),
			"hits": {}
		})
	_add_visual("tea", _player.global_position, 48.0 * _area_mult(), 0.28, Vector2.RIGHT.rotated(_tea_angle))

func _fire_cupid_bad_day(level_value: int) -> void:
	var dir: Vector2 = Vector2(0.78, 0.62).normalized()
	if _facing_dir().x < 0.0:
		dir.x *= -1.0
	var width: float = (13.0 + float(level_value) * 1.2) * _area_mult()
	var lanes: int = mini(6, 2 + floori(float(level_value) / 3.0) + _amount_bonus() + (1 if _is_evolved("cupid_bad_day") else 0))
	var side: Vector2 = Vector2(-dir.y, dir.x)
	for i: int in lanes:
		var offset: float = (float(i) - float(lanes - 1) * 0.5) * 72.0
		var origin: Vector2 = _player.global_position - dir * 380.0 + side * offset
		_damage_beam(origin, dir, 760.0, width, _damage(0.78 + float(level_value) * 0.085, "cupid_bad_day"))
		_add_visual("lane", origin, 760.0, 0.22, dir)

func _fire_glitter_bomb(level_value: int) -> void:
	if _glitter_bombs.size() >= MAX_GLITTER_BOMBS:
		_glitter_bombs.pop_front()
	var target: Node2D = _game.call("get_priority_enemy", _player.global_position, 650.0) as Node2D
	var p: Vector2 = target.global_position if is_instance_valid(target) else _player.global_position + _facing_dir() * 180.0
	_glitter_bombs.append({
		"pos": p,
		"time": 0.92,
		"radius": (62.0 + float(level_value) * 5.0) * _area_mult(),
		"damage": _damage(1.65 + float(level_value) * 0.17, "glitter_bomb"),
		"evolved": _is_evolved("glitter_bomb")
	})

func _fire_marshmallow_hammer(level_value: int) -> void:
	var dir: Vector2 = _facing_dir()
	var reach: float = (104.0 + float(level_value) * 8.0) * _area_mult()
	var center: Vector2 = _player.global_position + dir * reach * 0.50
	var damage_value: float = _damage(1.95 + float(level_value) * 0.22, "marshmallow_hammer")
	_damage_circle(center, reach * 0.58, damage_value)
	if _is_evolved("marshmallow_hammer"):
		_damage_circle(_player.global_position, reach * 0.82, damage_value * 0.52)
	_add_visual("hammer", center, reach * 0.68, 0.34, dir)
	_game.call("add_screen_shake", 6.8 if not _is_evolved("marshmallow_hammer") else 9.0, 0.15)

func _fire_kiss_of_death(level_value: int) -> void:
	var candidates: Array = _game.call("get_enemies_near", _player.global_position, 720.0)
	var best: Node2D = null
	var best_hp: float = -1.0
	for entry: Variant in candidates:
		var enemy: Node2D = entry as Node2D
		if not is_instance_valid(enemy):
			continue
		var hp_value: Variant = enemy.get("hp")
		var hp_number: float = float(hp_value) if hp_value is float or hp_value is int else 0.0
		if hp_number > best_hp:
			best_hp = hp_number
			best = enemy
	if not is_instance_valid(best):
		return
	var dir: Vector2 = _player.global_position.direction_to(best.global_position)
	var percent_chunk: float = minf(34.0 + float(level_value) * 3.0, maxf(0.0, best_hp) * (0.055 + float(level_value) * 0.006))
	var damage_value: float = _damage(1.30 + float(level_value) * 0.10, "kiss_of_death") + percent_chunk
	if _is_evolved("kiss_of_death"):
		damage_value *= 1.30
	best.call("take_damage", damage_value, dir, true)
	_add_visual("kiss", _player.global_position, _player.global_position.distance_to(best.global_position), 0.30, dir)

func _fire_rainbow_roadkill(level_value: int) -> void:
	while _rainbow_trails.size() >= MAX_RAINBOW_TRAILS:
		_rainbow_trails.pop_front()
	var backwards: Vector2 = -_player.velocity.normalized()
	if backwards == Vector2.ZERO:
		backwards = -_facing_dir()
	_rainbow_trails.append({
		"pos": _player.global_position + backwards * 28.0,
		"age": 0.0,
		"life": (2.3 + float(level_value) * 0.22) * _duration_mult() * (1.32 if _is_evolved("rainbow_roadkill") else 1.0),
		"radius": (27.0 + float(level_value) * 2.0) * _area_mult(),
		"damage": _damage(0.25 + float(level_value) * 0.03, "rainbow_roadkill")
	})

func _update_bowling_balls(delta: float) -> void:
	var do_hits: bool = _extra_hit_tick <= 0.0
	if do_hits:
		_extra_hit_tick = 0.065
	for i: int in range(_bowling_balls.size() - 1, -1, -1):
		var ball: Dictionary = _bowling_balls[i]
		ball["age"] = float(ball["age"]) + delta
		ball["pos"] = Vector2(ball["pos"]) + Vector2(ball["vel"]) * delta
		if do_hits:
			var before: int = (ball["hits"] as Dictionary).size()
			_hit_moving_token(ball)
			var after: int = (ball["hits"] as Dictionary).size()
			if after > before:
				ball["radius"] = minf(48.0 * _area_mult(), float(ball["radius"]) + float(after - before) * 2.2)
		if float(ball["age"]) >= float(ball["life"]):
			_bowling_balls.remove_at(i)
		else:
			_bowling_balls[i] = ball

func _update_honey(delta: float) -> void:
	_honey_tick -= delta
	for i: int in range(_honey_puddles.size() - 1, -1, -1):
		var puddle: Dictionary = _honey_puddles[i]
		puddle["age"] = float(puddle["age"]) + delta
		if float(puddle["age"]) >= float(puddle["life"]):
			_honey_puddles.remove_at(i)
		else:
			_honey_puddles[i] = puddle
	if _honey_tick <= 0.0:
		_honey_tick = 0.26
		for puddle: Dictionary in _honey_puddles:
			_damage_circle(Vector2(puddle["pos"]), float(puddle["radius"]), float(puddle["damage"]), false)

func _update_glitter(delta: float) -> void:
	for i: int in range(_glitter_bombs.size() - 1, -1, -1):
		var bomb: Dictionary = _glitter_bombs[i]
		bomb["time"] = float(bomb["time"]) - delta
		if float(bomb["time"]) <= 0.0:
			var p: Vector2 = bomb["pos"]
			var radius: float = float(bomb["radius"])
			var damage_value: float = float(bomb["damage"])
			_damage_circle(p, radius, damage_value)
			_add_visual("glitter", p, radius, 0.42, Vector2.ZERO)
			if bool(bomb["evolved"]):
				for j: int in 4:
					var q: Vector2 = p + Vector2.RIGHT.rotated(TAU * float(j) / 4.0) * radius * 0.72
					_damage_circle(q, radius * 0.52, damage_value * 0.48)
					_add_visual("glitter", q, radius * 0.52, 0.32, Vector2.ZERO)
			_game.call("add_screen_shake", 5.4 if not bool(bomb["evolved"]) else 7.2, 0.14)
			_glitter_bombs.remove_at(i)
		else:
			_glitter_bombs[i] = bomb

func _update_rainbow(delta: float) -> void:
	_rainbow_tick -= delta
	for i: int in range(_rainbow_trails.size() - 1, -1, -1):
		var trail: Dictionary = _rainbow_trails[i]
		trail["age"] = float(trail["age"]) + delta
		if float(trail["age"]) >= float(trail["life"]):
			_rainbow_trails.remove_at(i)
		else:
			_rainbow_trails[i] = trail
	if _rainbow_tick <= 0.0:
		_rainbow_tick = 0.22
		for trail: Dictionary in _rainbow_trails:
			_damage_circle(Vector2(trail["pos"]), float(trail["radius"]), float(trail["damage"]), false)

func _draw() -> void:
	super._draw()
	for puddle: Dictionary in _honey_puddles:
		var p: Vector2 = puddle["pos"]
		var r: float = float(puddle["radius"])
		var life_ratio: float = 1.0 - float(puddle["age"]) / maxf(0.01, float(puddle["life"]))
		draw_circle(p, r, Color(1.30, 0.76, 0.16, 0.095 * life_ratio))
		draw_arc(p, r * 0.84, 0.0, TAU, 20, Color(1.55, 1.0, 0.40, 0.30 * life_ratio), 2.0)
	for trail: Dictionary in _rainbow_trails:
		var p: Vector2 = trail["pos"]
		var r: float = float(trail["radius"])
		var life_ratio: float = 1.0 - float(trail["age"]) / maxf(0.01, float(trail["life"]))
		var colors: Array[Color] = [Color(1.4,0.28,0.45,0.18),Color(1.5,0.70,0.20,0.17),Color(0.55,1.2,0.48,0.15),Color(0.42,0.78,1.4,0.15),Color(1.0,0.50,1.35,0.16)]
		for j: int in colors.size():
			draw_arc(p, r - float(j) * 3.2, PI, TAU, 18, Color(colors[j].r, colors[j].g, colors[j].b, colors[j].a * life_ratio), 3.0)
	for ball: Dictionary in _bowling_balls:
		var p: Vector2 = ball["pos"]
		var r: float = float(ball["radius"])
		draw_circle(p + Vector2(3, 5), r, Color(0.18, 0.08, 0.15, 0.16))
		draw_circle(p, r, Color(1.35, 0.42, 0.72, 0.88))
		draw_circle(p + Vector2(-r*0.28,-r*0.18), r*0.09, Color(0.18,0.07,0.16,0.9))
		draw_circle(p + Vector2(r*0.28,-r*0.18), r*0.09, Color(0.18,0.07,0.16,0.9))
		draw_arc(p + Vector2(0,r*0.08), r*0.30, 0.2, PI-0.2, 10, Color(1.0,0.9,0.95,0.8), 2.0)
	for bomb: Dictionary in _glitter_bombs:
		var p: Vector2 = bomb["pos"]
		var r: float = float(bomb["radius"])
		var t: float = clampf(float(bomb["time"]) / 0.92, 0.0, 1.0)
		draw_arc(p, r * (0.72 + (1.0-t)*0.18), 0.0, TAU, 22, Color(1.6,0.62,1.0,0.55), 3.0)
		_draw_spark(p, 7.0 + (1.0-t)*5.0, Color(1.7,1.0,1.3,0.82))

	# Extra transient geometry shares the base visual pool, so no new Nodes are spawned.
	for visual: Dictionary in _visuals:
		var kind: String = String(visual["kind"])
		if kind not in ["scissors","hop_link","tea","lane","hammer","kiss","glitter"]:
			continue
		var p: Vector2 = visual["pos"]
		var r: float = float(visual["radius"])
		var age: float = float(visual["age"])
		var life: float = float(visual["life"])
		var alpha: float = 1.0 - clampf(age / maxf(0.01, life), 0.0, 1.0)
		var dir: Vector2 = visual["dir"]
		match kind:
			"scissors":
				var tip: Vector2 = p + dir * r
				draw_line(p, tip.rotated(0.10, p), Color(1.7,0.62,1.0,alpha*0.82), 7.0)
				draw_line(p, tip.rotated(-0.10, p), Color(2.0,0.92,1.0,alpha*0.80), 5.0)
			"hop_link", "kiss", "lane":
				draw_line(p, p + dir * r, Color(1.65,0.55,1.0,alpha*0.70), 5.0 if kind != "lane" else 8.0)
				draw_line(p, p + dir * r, Color(2.0,0.94,1.0,alpha*0.62), 2.0)
			"tea":
				for j: int in 3:
					var q: Vector2 = p + Vector2.RIGHT.rotated(dir.angle()+TAU*float(j)/3.0)*r
					draw_circle(q, 9.0, Color(1.2,0.55,0.88,alpha*0.78))
					draw_circle(q, 5.0, Color(1.8,0.92,1.0,alpha*0.72))
			"hammer":
				draw_circle(p, r * 0.52, Color(1.45,0.58,0.82,alpha*0.28))
				draw_rect(Rect2(p-Vector2(r*0.44,r*0.18),Vector2(r*0.88,r*0.36)),Color(1.55,0.72,0.92,alpha*0.72))
			"glitter":
				draw_arc(p, r*(0.45+age/life*0.55),0.0,TAU,24,Color(1.9,0.85,1.25,alpha*0.72),4.0)
