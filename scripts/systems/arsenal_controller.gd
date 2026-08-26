class_name ArsenalController
extends Node2D

signal loadout_changed

const MAX_TRANSIENT_VISUALS: int = 48
const MAX_BOOMERANGS: int = 18
const MAX_STAR_SHOTS: int = 26
const MAX_MINES: int = 18
const MAX_RAIN_MARKS: int = 14
const MAX_DROPS: int = 9
const DRAW_INTERVAL: float = 1.0 / 30.0

var weapons: Dictionary = {"heart_blaster": 1}
var passives: Dictionary = {}
var evolved: Dictionary = {}

var _player: TaffiController
var _game: Node
var _timers: Dictionary = {}
var _visuals: Array[Dictionary] = []
var _boomerangs: Array[Dictionary] = []
var _stars: Array[Dictionary] = []
var _mines: Array[Dictionary] = []
var _rain_marks: Array[Dictionary] = []
var _drops: Array[Dictionary] = []
var _laser: Dictionary = {}
var _mine_tick: float = 0.0
var _moving_hit_tick: float = 0.0
var _draw_tick: float = 0.0
var _sweep_flip: float = 1.0

func _ready() -> void:
	add_to_group("arsenal")
	z_as_relative = false
	z_index = 17
	call_deferred("_bind_runtime")

func _bind_runtime() -> void:
	_player = get_tree().get_first_node_in_group("player") as TaffiController
	_game = get_tree().get_first_node_in_group("game")
	if is_instance_valid(_player):
		_sync_all_legacy()
		loadout_changed.emit()

func _process(delta: float) -> void:
	if not is_instance_valid(_player) or _game == null:
		_bind_runtime()
		return

	_update_weapon_timers(delta)
	_update_rain(delta)
	_update_drops(delta)
	_update_boomerangs(delta)
	_update_stars(delta)
	_update_mines(delta)
	_update_laser(delta)
	_update_visuals(delta)

	_draw_tick -= delta
	if _draw_tick <= 0.0:
		_draw_tick = DRAW_INTERVAL
		queue_redraw()

func get_level_choices(count: int = 3) -> Array[Dictionary]:
	var candidates: Array[String] = []
	for id: Variant in weapons.keys():
		var weapon_id: String = String(id)
		if int(weapons[id]) < ArsenalCatalog.MAX_WEAPON_LEVEL:
			candidates.append("weapon:%s" % weapon_id)
	if weapons.size() < ArsenalCatalog.MAX_WEAPON_SLOTS:
		for weapon_id: String in ArsenalCatalog.weapon_ids():
			if not weapons.has(weapon_id):
				candidates.append("weapon:%s" % weapon_id)

	for id: Variant in passives.keys():
		var passive_id: String = String(id)
		if int(passives[id]) < ArsenalCatalog.MAX_PASSIVE_LEVEL:
			candidates.append("passive:%s" % passive_id)
	if passives.size() < ArsenalCatalog.MAX_PASSIVE_SLOTS:
		for passive_id: String in ArsenalCatalog.passive_ids():
			if not passives.has(passive_id):
				candidates.append("passive:%s" % passive_id)

	if candidates.is_empty():
		return [{
			"id": "bonus:heal",
			"type": "BONUS",
			"name": "SWEET RECOVERY",
			"description": "Everything is maxed. Heal 30% HP.",
			"level": 1,
			"next_level": 1
		}]

	candidates.shuffle()
	var result: Array[Dictionary] = []
	var seen: Dictionary = {}
	for choice_id: String in candidates:
		if seen.has(choice_id):
			continue
		seen[choice_id] = true
		result.append(_describe_choice(choice_id))
		if result.size() >= count:
			break
	return result

func apply_choice(choice_id: String) -> String:
	var result_text: String = ""
	if choice_id.begins_with("weapon:"):
		var weapon_id: String = choice_id.trim_prefix("weapon:")
		var current: int = int(weapons.get(weapon_id, 0))
		if current <= 0 and weapons.size() >= ArsenalCatalog.MAX_WEAPON_SLOTS:
			return "WEAPON SLOTS FULL"
		var next_level: int = mini(ArsenalCatalog.MAX_WEAPON_LEVEL, current + 1)
		weapons[weapon_id] = next_level
		_sync_legacy_weapon(weapon_id)
		var data: Dictionary = ArsenalCatalog.get_weapon(weapon_id)
		result_text = "%s  LV %d" % [String(data.get("name", weapon_id)), next_level]
	elif choice_id.begins_with("passive:"):
		var passive_id: String = choice_id.trim_prefix("passive:")
		var current: int = int(passives.get(passive_id, 0))
		if current <= 0 and passives.size() >= ArsenalCatalog.MAX_PASSIVE_SLOTS:
			return "CHARM SLOTS FULL"
		var next_level: int = mini(ArsenalCatalog.MAX_PASSIVE_LEVEL, current + 1)
		passives[passive_id] = next_level
		_apply_passive_level(passive_id)
		var data: Dictionary = ArsenalCatalog.get_passive(passive_id)
		result_text = "%s  LV %d" % [String(data.get("name", passive_id)), next_level]
	elif choice_id == "bonus:heal":
		_player.hp = minf(_player.max_hp, _player.hp + _player.max_hp * 0.30)
		result_text = "SWEET RECOVERY!"
	loadout_changed.emit()
	return result_text

func open_chest(legendary: bool) -> String:
	var reward: String = ""
	var run_time: float = 0.0
	if _game != null and _game.has_method("get_run_time"):
		run_time = float(_game.call("get_run_time"))
	var evolution_ready: Array[String] = _eligible_evolutions()
	if not evolution_ready.is_empty() and (legendary or run_time >= 90.0):
		evolution_ready.shuffle()
		reward = _evolve_weapon(evolution_ready[0])
	else:
		var upgradable: Array[String] = []
		for id: Variant in weapons.keys():
			if int(weapons[id]) < ArsenalCatalog.MAX_WEAPON_LEVEL:
				upgradable.append("weapon:%s" % String(id))
		for id: Variant in passives.keys():
			if int(passives[id]) < ArsenalCatalog.MAX_PASSIVE_LEVEL:
				upgradable.append("passive:%s" % String(id))
		if not upgradable.is_empty():
			upgradable.shuffle()
			reward = "CHEST!  %s" % apply_choice(upgradable[0])
		else:
			_player.hp = minf(_player.max_hp, _player.hp + _player.max_hp * 0.24)
			_player.cute_meter = minf(100.0, _player.cute_meter + 14.0)
			reward = "CHEST!  HONEY REFILL ♡"
	_show_reward(reward)
	return reward

func get_compact_loadout() -> Dictionary:
	return {
		"weapons": weapons.duplicate(),
		"passives": passives.duplicate(),
		"evolved": evolved.duplicate()
	}

func get_active_attack_token_count() -> int:
	return _visuals.size() + _boomerangs.size() + _stars.size() + _mines.size() + _rain_marks.size() + _drops.size() + (1 if not _laser.is_empty() else 0)

func _describe_choice(choice_id: String) -> Dictionary:
	if choice_id.begins_with("weapon:"):
		var id: String = choice_id.trim_prefix("weapon:")
		var data: Dictionary = ArsenalCatalog.get_weapon(id)
		var current: int = int(weapons.get(id, 0))
		return {
			"id": choice_id,
			"type": "WEAPON",
			"name": String(data.get("name", id)),
			"description": String(data.get("description", "")),
			"level": current,
			"next_level": current + 1,
			"evolution": String(data.get("evolution", ""))
		}
	var id: String = choice_id.trim_prefix("passive:")
	var data: Dictionary = ArsenalCatalog.get_passive(id)
	var current: int = int(passives.get(id, 0))
	return {
		"id": choice_id,
		"type": "CHARM",
		"name": String(data.get("name", id)),
		"description": String(data.get("description", "")),
		"level": current,
		"next_level": current + 1,
		"evolution": ""
	}

func _eligible_evolutions() -> Array[String]:
	var out: Array[String] = []
	for key: Variant in weapons.keys():
		var id: String = String(key)
		if int(weapons[id]) < ArsenalCatalog.MAX_WEAPON_LEVEL or bool(evolved.get(id, false)):
			continue
		var data: Dictionary = ArsenalCatalog.get_weapon(id)
		var required: String = String(data.get("passive", ""))
		if required.is_empty() or int(passives.get(required, 0)) > 0:
			out.append(id)
	return out

func _evolve_weapon(id: String) -> String:
	evolved[id] = true
	_sync_legacy_weapon(id)
	var data: Dictionary = ArsenalCatalog.get_weapon(id)
	var evolution_name: String = String(data.get("evolution", "EVOLVED"))
	loadout_changed.emit()
	return "EVOLUTION!!!  %s" % evolution_name

func _sync_all_legacy() -> void:
	for id: Variant in weapons.keys():
		_sync_legacy_weapon(String(id))

func _sync_legacy_weapon(id: String) -> void:
	if not is_instance_valid(_player):
		return
	var level_value: int = int(weapons.get(id, 0))
	match id:
		"heart_blaster":
			_player.heart_level = level_value
			_player.heart_evolved = bool(evolved.get(id, false))
		"cupcake_mortar":
			_player.cupcake_level = level_value
			_player.cupcake_evolved = bool(evolved.get(id, false))
		"love_orbit":
			_player.orbit_level = level_value
			_player.orbit_evolved = bool(evolved.get(id, false))
			if _game != null and level_value > 0:
				_game.call("ensure_love_orbit", _player, level_value, _player.orbit_evolved)

func _apply_passive_level(id: String) -> void:
	if not is_instance_valid(_player):
		return
	match id:
		"strawberry_core":
			_player.damage *= 1.10
		"sugar_rush":
			_player.fire_interval = maxf(0.085, _player.fire_interval * 0.95)
		"extra_sprinkles":
			var level_value: int = int(passives.get(id, 0))
			if level_value == 2 or level_value == 4:
				_player.multishot = mini(6, _player.multishot + 1)
		"bubblegum_shoes":
			_player.move_speed += 7.0
		"plush_armor":
			_player.damage_taken_multiplier = maxf(0.52, _player.damage_taken_multiplier * 0.95)
		"honey_heart":
			_player.max_hp += 10.0
			_player.hp = minf(_player.max_hp, _player.hp + 10.0)
		_:
			pass

func _update_weapon_timers(delta: float) -> void:
	for key: Variant in weapons.keys():
		var id: String = String(key)
		var data: Dictionary = ArsenalCatalog.get_weapon(id)
		if bool(data.get("legacy", false)):
			continue
		var timer: float = float(_timers.get(id, randf_range(0.02, 0.35))) - delta
		if timer <= 0.0:
			_fire_weapon(id, int(weapons[id]))
			timer += _weapon_cooldown(id, int(weapons[id]))
		_timers[id] = timer

func _weapon_cooldown(id: String, level_value: int) -> float:
	var base: float = 1.4
	match id:
		"ribbon_ripper": base = 0.92
		"kawaii_chainsaw": base = 0.20
		"sugar_crash": base = 2.45
		"strawberry_rain": base = 2.65
		"bunny_boomerang": base = 1.45
		"bubblegum_minefield": base = 1.75
		"lollipop_guillotine": base = 1.25
		"teddy_drop": base = 3.15
		"friendship_laser": base = 3.35
		"star_tantrum": base = 2.15
	var level_mult: float = maxf(0.70, 1.0 - float(level_value - 1) * 0.035)
	return base * level_mult * _cooldown_mult()

func _fire_weapon(id: String, level_value: int) -> void:
	match id:
		"ribbon_ripper": _fire_ribbon(level_value)
		"kawaii_chainsaw": _fire_chainsaw(level_value)
		"sugar_crash": _fire_sugar_crash(level_value)
		"strawberry_rain": _fire_strawberry_rain(level_value)
		"bunny_boomerang": _fire_bunny_boomerang(level_value)
		"bubblegum_minefield": _fire_bubblegum_minefield(level_value)
		"lollipop_guillotine": _fire_lollipop_guillotine(level_value)
		"teddy_drop": _fire_teddy_drop(level_value)
		"friendship_laser": _fire_friendship_laser(level_value)
		"star_tantrum": _fire_star_tantrum(level_value)

func _fire_ribbon(level_value: int) -> void:
	var direction: Vector2 = _facing_dir()
	var radius: float = (70.0 + float(level_value) * 6.0) * _area_mult()
	var half_angle: float = 1.05 + float(level_value) * 0.025
	var damage_value: float = _damage(0.82 + float(level_value) * 0.12, "ribbon_ripper")
	_damage_arc(_player.global_position, direction, radius, half_angle, damage_value)
	if _is_evolved("ribbon_ripper"):
		_damage_arc(_player.global_position, -direction, radius * 1.05, half_angle, damage_value * 0.82)
	_add_visual("slash", _player.global_position, radius, 0.18, direction)

func _fire_chainsaw(level_value: int) -> void:
	var direction: Vector2 = _facing_dir()
	var radius: float = (52.0 + float(level_value) * 3.2) * _area_mult()
	var damage_value: float = _damage(0.24 + float(level_value) * 0.045, "kawaii_chainsaw")
	if _is_evolved("kawaii_chainsaw"):
		_damage_circle(_player.global_position, radius * 1.08, damage_value)
	else:
		_damage_arc(_player.global_position, direction, radius, 1.46, damage_value)
	_add_visual("saw", _player.global_position + direction * radius * 0.52, radius * 0.56, 0.13, direction)

func _fire_sugar_crash(level_value: int) -> void:
	var radius: float = (92.0 + float(level_value) * 8.0) * _area_mult()
	var damage_value: float = _damage(1.10 + float(level_value) * 0.15, "sugar_crash")
	if _is_evolved("sugar_crash"):
		radius *= 1.34
		damage_value *= 1.22
	_damage_circle(_player.global_position, radius, damage_value)
	_add_visual("pulse", _player.global_position, radius, 0.42, Vector2.ZERO)
	if _game != null:
		_game.call("add_screen_shake", 3.3 if not _is_evolved("sugar_crash") else 5.0, 0.10)

func _fire_strawberry_rain(level_value: int) -> void:
	if _rain_marks.size() >= MAX_RAIN_MARKS:
		return
	var target_count: int = mini(5, 1 + floori(float(level_value) / 3.0) + _amount_bonus())
	if _is_evolved("strawberry_rain"):
		target_count = mini(7, target_count + 2)
	var candidates: Array = _game.call("get_enemies_near", _player.global_position, 600.0)
	candidates.shuffle()
	for i: int in target_count:
		if _rain_marks.size() >= MAX_RAIN_MARKS:
			break
		var target_pos: Vector2 = _player.global_position + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(80.0, 360.0)
		if i < candidates.size():
			var enemy: Node2D = candidates[i] as Node2D
			if is_instance_valid(enemy):
				target_pos = enemy.global_position
		_rain_marks.append({
			"pos": target_pos,
			"time": 0.58,
			"radius": (48.0 + float(level_value) * 4.0) * _area_mult(),
			"damage": _damage(1.20 + float(level_value) * 0.16, "strawberry_rain")
		})

func _fire_bunny_boomerang(level_value: int) -> void:
	if _boomerangs.size() >= MAX_BOOMERANGS:
		return
	var count: int = mini(4, 1 + _amount_bonus() + (1 if level_value >= 6 else 0))
	if _is_evolved("bunny_boomerang"):
		count = mini(6, count + 2)
	var base_dir: Vector2 = _facing_dir()
	for i: int in count:
		if _boomerangs.size() >= MAX_BOOMERANGS:
			break
		var offset: float = (float(i) - float(count - 1) * 0.5) * 0.28
		var dir: Vector2 = base_dir.rotated(offset)
		_boomerangs.append({
			"pos": _player.global_position + dir * 28.0,
			"vel": dir * (285.0 + float(level_value) * 13.0) * _speed_mult(),
			"age": 0.0,
			"life": 1.28 * _duration_mult(),
			"radius": (17.0 + float(level_value) * 0.9) * _area_mult(),
			"damage": _damage(0.76 + float(level_value) * 0.10, "bunny_boomerang"),
			"hits": {}
		})

func _fire_bubblegum_minefield(level_value: int) -> void:
	if _mines.size() >= MAX_MINES:
		_minies_trim()
	var backwards: Vector2 = -_player.velocity.normalized()
	if backwards == Vector2.ZERO:
		backwards = -_facing_dir()
	var mine_pos: Vector2 = _player.global_position + backwards * 26.0 + Vector2(randf_range(-14.0, 14.0), randf_range(-10.0, 10.0))
	_mines.append({
		"pos": mine_pos,
		"age": 0.0,
		"life": (4.2 + float(level_value) * 0.35) * _duration_mult() * (1.45 if _is_evolved("bubblegum_minefield") else 1.0),
		"radius": (38.0 + float(level_value) * 3.6) * _area_mult() * (1.18 if _is_evolved("bubblegum_minefield") else 1.0),
		"damage": _damage(0.28 + float(level_value) * 0.035, "bubblegum_minefield")
	})

func _fire_lollipop_guillotine(level_value: int) -> void:
	var outer: float = (98.0 + float(level_value) * 7.0) * _area_mult()
	var inner: float = outer * 0.48
	var damage_value: float = _damage(1.0 + float(level_value) * 0.14, "lollipop_guillotine")
	_damage_annulus(_player.global_position, inner, outer, damage_value)
	if _is_evolved("lollipop_guillotine"):
		_damage_circle(_player.global_position, inner, damage_value * 0.46)
	_sweep_flip *= -1.0
	_add_visual("guillotine", _player.global_position, outer, 0.28, Vector2(_sweep_flip, 0.0))

func _fire_teddy_drop(level_value: int) -> void:
	if _drops.size() >= MAX_DROPS:
		return
	var target: Node2D = _game.call("get_priority_enemy", _player.global_position, 720.0) as Node2D
	var center: Vector2 = target.global_position if is_instance_valid(target) else _player.global_position + _facing_dir() * 220.0
	var count: int = 3 if _is_evolved("teddy_drop") else 1
	for i: int in count:
		var offset: Vector2 = Vector2.ZERO if i == 0 else Vector2.RIGHT.rotated(TAU * float(i - 1) / 2.0) * 82.0
		_drops.append({
			"pos": center + offset,
			"time": 0.68 + float(i) * 0.08,
			"radius": (72.0 + float(level_value) * 6.0) * _area_mult(),
			"damage": _damage(2.25 + float(level_value) * 0.22, "teddy_drop")
		})

func _fire_friendship_laser(level_value: int) -> void:
	if not _laser.is_empty():
		return
	var target: Node2D = _game.call("get_nearest_enemy", _player.global_position) as Node2D
	var dir: Vector2 = _facing_dir()
	if is_instance_valid(target):
		dir = _player.global_position.direction_to(target.global_position)
	_laser = {
		"age": 0.0,
		"life": (0.74 + float(level_value) * 0.035) * _duration_mult(),
		"angle": dir.angle(),
		"tick": 0.0,
		"width": (22.0 + float(level_value) * 2.2) * _area_mult() * (1.30 if _is_evolved("friendship_laser") else 1.0),
		"damage": _damage(0.36 + float(level_value) * 0.055, "friendship_laser")
	}

func _fire_star_tantrum(level_value: int) -> void:
	var count: int = mini(12, 5 + floori(float(level_value) / 2.0) + _amount_bonus())
	if _is_evolved("star_tantrum"):
		count = mini(16, count + 4)
	for i: int in count:
		if _stars.size() >= MAX_STAR_SHOTS:
			break
		var angle: float = TAU * float(i) / float(count) + randf_range(-0.08, 0.08)
		var dir: Vector2 = Vector2.RIGHT.rotated(angle)
		_stars.append({
			"pos": _player.global_position + dir * 28.0,
			"vel": dir * (240.0 + float(level_value) * 12.0) * _speed_mult(),
			"age": 0.0,
			"life": 1.34 * _duration_mult(),
			"radius": (13.0 + float(level_value) * 0.7) * _area_mult(),
			"damage": _damage(0.54 + float(level_value) * 0.07, "star_tantrum"),
			"hits": {}
		})

func _update_rain(delta: float) -> void:
	for i: int in range(_rain_marks.size() - 1, -1, -1):
		var mark: Dictionary = _rain_marks[i]
		mark["time"] = float(mark["time"]) - delta
		if float(mark["time"]) <= 0.0:
			var p: Vector2 = mark["pos"]
			_damage_circle(p, float(mark["radius"]), float(mark["damage"]))
			_add_visual("rain_burst", p, float(mark["radius"]), 0.34, Vector2.ZERO)
			if _game != null:
				_game.call("spawn_cute_fx", p, "strawberry", Vector2.UP, 0.82)
			_rain_marks.remove_at(i)
		else:
			_rain_marks[i] = mark

func _update_drops(delta: float) -> void:
	for i: int in range(_drops.size() - 1, -1, -1):
		var drop: Dictionary = _drops[i]
		drop["time"] = float(drop["time"]) - delta
		if float(drop["time"]) <= 0.0:
			var p: Vector2 = drop["pos"]
			_damage_circle(p, float(drop["radius"]), float(drop["damage"]))
			_add_visual("teddy_impact", p, float(drop["radius"]), 0.48, Vector2.ZERO)
			_game.call("add_screen_shake", 6.0 if not _is_evolved("teddy_drop") else 8.5, 0.16)
			_drops.remove_at(i)
		else:
			_drops[i] = drop

func _update_boomerangs(delta: float) -> void:
	_moving_hit_tick -= delta
	var do_hits: bool = _moving_hit_tick <= 0.0
	if do_hits:
		_moving_hit_tick = 0.055
	for i: int in range(_boomerangs.size() - 1, -1, -1):
		var shot: Dictionary = _boomerangs[i]
		var age: float = float(shot["age"]) + delta
		var life: float = float(shot["life"])
		var vel: Vector2 = shot["vel"]
		if age > life * 0.50:
			var home_dir: Vector2 = Vector2(shot["pos"]).direction_to(_player.global_position)
			vel = vel.lerp(home_dir * vel.length(), minf(1.0, delta * 5.8))
		shot["age"] = age
		shot["vel"] = vel
		shot["pos"] = Vector2(shot["pos"]) + vel * delta
		if do_hits:
			_hit_moving_token(shot)
		if age >= life:
			_boomerangs.remove_at(i)
		else:
			_boomerangs[i] = shot

func _update_stars(delta: float) -> void:
	var do_hits: bool = _moving_hit_tick <= 0.012
	for i: int in range(_stars.size() - 1, -1, -1):
		var shot: Dictionary = _stars[i]
		var age: float = float(shot["age"]) + delta
		shot["age"] = age
		shot["pos"] = Vector2(shot["pos"]) + Vector2(shot["vel"]) * delta
		if do_hits:
			_hit_moving_token(shot)
		if age >= float(shot["life"]):
			_stars.remove_at(i)
		else:
			_stars[i] = shot

func _hit_moving_token(shot: Dictionary) -> void:
	var pos: Vector2 = shot["pos"]
	var radius: float = float(shot["radius"])
	var hits: Dictionary = shot["hits"]
	var candidates: Array = _game.call("get_enemies_near", pos, radius + 26.0)
	for entry: Variant in candidates:
		var enemy: Node2D = entry as Node2D
		if not is_instance_valid(enemy):
			continue
		var enemy_id: int = enemy.get_instance_id()
		if hits.has(enemy_id):
			continue
		if pos.distance_squared_to(enemy.global_position) <= radius * radius:
			hits[enemy_id] = true
			var dir: Vector2 = pos.direction_to(enemy.global_position)
			enemy.call("take_damage", float(shot["damage"]) * _crit_roll(), dir, _last_roll_was_crit)
	shot["hits"] = hits

var _last_roll_was_crit: bool = false
func _crit_roll() -> float:
	_last_roll_was_crit = randf() < _crit_chance()
	return 1.75 if _last_roll_was_crit else 1.0

func _update_mines(delta: float) -> void:
	_mine_tick -= delta
	for i: int in range(_mines.size() - 1, -1, -1):
		var mine: Dictionary = _mines[i]
		mine["age"] = float(mine["age"]) + delta
		if float(mine["age"]) >= float(mine["life"]):
			_mines.remove_at(i)
		else:
			_mines[i] = mine
	if _mine_tick <= 0.0:
		_mine_tick = 0.23
		for mine: Dictionary in _mines:
			_damage_circle(Vector2(mine["pos"]), float(mine["radius"]), float(mine["damage"]), false)

func _update_laser(delta: float) -> void:
	if _laser.is_empty():
		return
	_laser["age"] = float(_laser["age"]) + delta
	_laser["tick"] = float(_laser["tick"]) - delta
	var age: float = float(_laser["age"])
	var life: float = float(_laser["life"])
	if float(_laser["tick"]) <= 0.0:
		_laser["tick"] = 0.085
		var sweep: float = sin(age / maxf(0.01, life) * PI) * 0.28 - 0.14
		var direction: Vector2 = Vector2.RIGHT.rotated(float(_laser["angle"]) + sweep)
		_damage_beam(_player.global_position, direction, 720.0, float(_laser["width"]), float(_laser["damage"]))
		if _is_evolved("friendship_laser"):
			_damage_beam(_player.global_position, -direction, 480.0, float(_laser["width"]) * 0.72, float(_laser["damage"]) * 0.62)
	if age >= life:
		_laser.clear()

func _update_visuals(delta: float) -> void:
	for i: int in range(_visuals.size() - 1, -1, -1):
		var v: Dictionary = _visuals[i]
		v["age"] = float(v["age"]) + delta
		if float(v["age"]) >= float(v["life"]):
			_visuals.remove_at(i)
		else:
			_visuals[i] = v

func _damage_circle(center: Vector2, radius: float, damage_value: float, allow_crit: bool = true) -> void:
	var candidates: Array = _game.call("get_enemies_near", center, radius + 20.0)
	for entry: Variant in candidates:
		var enemy: Node2D = entry as Node2D
		if not is_instance_valid(enemy):
			continue
		if center.distance_squared_to(enemy.global_position) <= radius * radius:
			var critical: bool = allow_crit and randf() < _crit_chance()
			enemy.call("take_damage", damage_value * (1.75 if critical else 1.0), center.direction_to(enemy.global_position), critical)

func _damage_arc(center: Vector2, direction: Vector2, radius: float, half_angle: float, damage_value: float) -> void:
	var candidates: Array = _game.call("get_enemies_near", center, radius + 18.0)
	var min_dot: float = cos(half_angle)
	for entry: Variant in candidates:
		var enemy: Node2D = entry as Node2D
		if not is_instance_valid(enemy):
			continue
		var offset: Vector2 = enemy.global_position - center
		if offset.length_squared() > radius * radius:
			continue
		var dir: Vector2 = offset.normalized()
		if dir.dot(direction) >= min_dot:
			var critical: bool = randf() < _crit_chance()
			enemy.call("take_damage", damage_value * (1.75 if critical else 1.0), direction, critical)

func _damage_annulus(center: Vector2, inner: float, outer: float, damage_value: float) -> void:
	var candidates: Array = _game.call("get_enemies_near", center, outer + 18.0)
	var min_sq: float = inner * inner
	var max_sq: float = outer * outer
	for entry: Variant in candidates:
		var enemy: Node2D = entry as Node2D
		if not is_instance_valid(enemy):
			continue
		var dist_sq: float = center.distance_squared_to(enemy.global_position)
		if dist_sq >= min_sq and dist_sq <= max_sq:
			var critical: bool = randf() < _crit_chance()
			enemy.call("take_damage", damage_value * (1.75 if critical else 1.0), center.direction_to(enemy.global_position), critical)

func _damage_beam(origin: Vector2, direction: Vector2, length: float, width: float, damage_value: float) -> void:
	var center: Vector2 = origin + direction * length * 0.5
	var candidates: Array = _game.call("get_enemies_near", center, length * 0.56 + width)
	for entry: Variant in candidates:
		var enemy: Node2D = entry as Node2D
		if not is_instance_valid(enemy):
			continue
		var offset: Vector2 = enemy.global_position - origin
		var along: float = offset.dot(direction)
		if along < 0.0 or along > length:
			continue
		var closest: Vector2 = origin + direction * along
		if closest.distance_squared_to(enemy.global_position) <= width * width:
			var critical: bool = randf() < _crit_chance()
			enemy.call("take_damage", damage_value * (1.75 if critical else 1.0), direction, critical)

func _damage(factor: float, weapon_id: String) -> float:
	var evolved_mult: float = 1.46 if _is_evolved(weapon_id) else 1.0
	return _player.damage * factor * _might_mult() * evolved_mult

func _might_mult() -> float:
	return 1.0 + float(passives.get("strawberry_core", 0)) * 0.10

func _area_mult() -> float:
	return 1.0 + float(passives.get("bigger_bow", 0)) * 0.10

func _duration_mult() -> float:
	return 1.0 + float(passives.get("long_love", 0)) * 0.12

func _speed_mult() -> float:
	return 1.0 + float(passives.get("fast_delivery", 0)) * 0.10

func _cooldown_mult() -> float:
	return maxf(0.58, 1.0 - float(passives.get("sugar_rush", 0)) * 0.065)

func _amount_bonus() -> int:
	return mini(3, floori((float(passives.get("extra_sprinkles", 0)) + 1.0) / 2.0))

func _crit_chance() -> float:
	return 0.05 + float(passives.get("lucky_ribbon", 0)) * 0.025

func _is_evolved(id: String) -> bool:
	return bool(evolved.get(id, false))

func _facing_dir() -> Vector2:
	if not is_instance_valid(_player) or not is_instance_valid(_player.visual):
		return Vector2.RIGHT
	return Vector2.RIGHT if _player.visual.scale.x >= 0.0 else Vector2.LEFT

func _add_visual(kind: String, pos: Vector2, radius: float, life: float, direction: Vector2) -> void:
	if _visuals.size() >= MAX_TRANSIENT_VISUALS:
		_visuals.pop_front()
	_visuals.append({"kind": kind, "pos": pos, "radius": radius, "life": life, "age": 0.0, "dir": direction})

func _minies_trim() -> void:
	while _mines.size() >= MAX_MINES:
		_mines.pop_front()

func _show_reward(text: String) -> void:
	if _game == null:
		return
	var hud: Node = _game.get_node_or_null("HUD")
	if hud != null and hud.has_method("show_reward_toast"):
		hud.call("show_reward_toast", text)

func _draw() -> void:
	# Persistent bubblegum zones.
	for mine: Dictionary in _mines:
		var p: Vector2 = mine["pos"]
		var r: float = float(mine["radius"])
		var life_ratio: float = 1.0 - float(mine["age"]) / maxf(0.01, float(mine["life"]))
		draw_circle(p, r, Color(1.25, 0.22, 0.70, 0.075 * life_ratio))
		draw_arc(p, r * 0.82, 0.0, TAU, 28, Color(1.45, 0.66, 1.0, 0.22 * life_ratio), 2.0)
		for j: int in 4:
			var a: float = TAU * float(j) / 4.0 + float(mine["age"]) * 0.25
			draw_circle(p + Vector2.RIGHT.rotated(a) * r * 0.46, 3.0, Color(1.6, 0.60, 1.0, 0.26 * life_ratio))

	# Telegraphs are deliberately simple and cheap.
	for mark: Dictionary in _rain_marks:
		var p: Vector2 = mark["pos"]
		var r: float = float(mark["radius"])
		var t: float = clampf(float(mark["time"]) / 0.58, 0.0, 1.0)
		draw_circle(p, r * (1.0 - t * 0.22), Color(1.40, 0.18, 0.54, 0.055))
		draw_arc(p, r * (1.0 - t * 0.22), 0.0, TAU, 24, Color(1.55, 0.65, 0.88, 0.38), 2.0)
		_draw_spark(p + Vector2(0, -r * 0.65), 6.0, Color(1.55, 0.92, 1.0, 0.62))

	for drop: Dictionary in _drops:
		var p: Vector2 = drop["pos"]
		var r: float = float(drop["radius"])
		var t: float = clampf(float(drop["time"]) / 0.68, 0.0, 1.0)
		draw_circle(p, r * 0.72, Color(0.25, 0.10, 0.20, 0.09))
		draw_arc(p, r * 0.72, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - t), 28, Color(1.45, 0.68, 0.95, 0.60), 4.0)
		_draw_teddy_face(p + Vector2(0, -32.0 - t * 72.0), 0.54 + (1.0 - t) * 0.22)

	for shot: Dictionary in _boomerangs:
		var p: Vector2 = shot["pos"]
		var r: float = float(shot["radius"])
		draw_arc(p, r, -2.3, 2.3, 14, Color(1.55, 0.55, 0.92, 0.82), 5.0)
		draw_circle(p + Vector2(r * 0.58, 0), 3.0, Color(1.8, 0.94, 1.0, 0.86))

	for shot: Dictionary in _stars:
		_draw_spark(Vector2(shot["pos"]), float(shot["radius"]), Color(1.7, 0.92, 0.34, 0.80))

	if not _laser.is_empty() and is_instance_valid(_player):
		var age: float = float(_laser["age"])
		var life: float = float(_laser["life"])
		var sweep: float = sin(age / maxf(0.01, life) * PI) * 0.28 - 0.14
		var dir: Vector2 = Vector2.RIGHT.rotated(float(_laser["angle"]) + sweep)
		var origin: Vector2 = _player.global_position
		var width: float = float(_laser["width"])
		draw_line(origin, origin + dir * 720.0, Color(1.5, 0.18, 0.72, 0.16), width * 2.0)
		draw_line(origin, origin + dir * 720.0, Color(1.7, 0.55, 1.0, 0.72), width)
		draw_line(origin, origin + dir * 720.0, Color(2.0, 0.94, 1.0, 0.92), maxf(3.0, width * 0.26))

	for visual: Dictionary in _visuals:
		var kind: String = String(visual["kind"])
		var p: Vector2 = visual["pos"]
		var r: float = float(visual["radius"])
		var age: float = float(visual["age"])
		var life: float = float(visual["life"])
		var t: float = clampf(age / maxf(0.01, life), 0.0, 1.0)
		var alpha: float = 1.0 - t
		var direction: Vector2 = visual["dir"]
		match kind:
			"slash":
				var angle: float = direction.angle()
				draw_arc(p, r * (0.72 + t * 0.28), angle - 1.05, angle + 1.05, 24, Color(1.65, 0.50, 0.94, alpha * 0.78), 9.0)
				draw_arc(p, r * (0.58 + t * 0.25), angle - 0.86, angle + 0.86, 20, Color(2.0, 0.92, 1.0, alpha * 0.72), 3.0)
			"saw":
				draw_circle(p, r * 0.56, Color(1.45, 0.24, 0.70, alpha * 0.10))
				draw_arc(p, r * 0.48, age * 13.0, age * 13.0 + PI * 1.6, 18, Color(1.75, 0.70, 1.0, alpha * 0.72), 5.0)
			"pulse":
				draw_circle(p, r * t, Color(1.55, 0.55, 0.90, alpha * 0.08))
				draw_arc(p, r * t, 0.0, TAU, 32, Color(1.8, 0.85, 1.0, alpha * 0.64), 4.0)
			"guillotine":
				var spin: float = age * 11.0 * _sweep_flip
				var tip: Vector2 = p + Vector2.RIGHT.rotated(spin) * r
				draw_line(p + Vector2.RIGHT.rotated(spin) * r * 0.48, tip, Color(1.75, 0.58, 0.92, alpha * 0.85), 12.0)
				draw_circle(tip, 10.0, Color(2.0, 0.90, 1.0, alpha * 0.88))
			"rain_burst", "teddy_impact":
				draw_circle(p, r * (0.55 + t * 0.45), Color(1.55, 0.26, 0.64, alpha * 0.12))
				draw_arc(p, r * (0.35 + t * 0.65), 0.0, TAU, 32, Color(1.75, 0.78, 1.0, alpha * 0.70), 5.0)

func _draw_spark(center: Vector2, radius: float, color: Color) -> void:
	draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), color, 2.0)
	draw_line(center + Vector2(0, -radius), center + Vector2(0, radius), color, 2.0)
	draw_circle(center, maxf(2.0, radius * 0.22), color)

func _draw_teddy_face(center: Vector2, scale_value: float) -> void:
	var dark: Color = Color(0.22, 0.10, 0.20, 0.82)
	var fur: Color = Color(1.45, 0.58, 0.78, 0.82)
	var light: Color = Color(1.75, 0.88, 1.0, 0.82)
	var r: float = 18.0 * scale_value
	draw_circle(center + Vector2(-r * 0.72, -r * 0.62), r * 0.45, dark)
	draw_circle(center + Vector2(r * 0.72, -r * 0.62), r * 0.45, dark)
	draw_circle(center, r, dark)
	draw_circle(center, r * 0.84, fur)
	draw_circle(center + Vector2(0, r * 0.18), r * 0.38, light)
	draw_circle(center + Vector2(-r * 0.32, -r * 0.16), r * 0.10, dark)
	draw_circle(center + Vector2(r * 0.32, -r * 0.16), r * 0.10, dark)
