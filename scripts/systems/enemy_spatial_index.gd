class_name EnemySpatialIndex
extends RefCounted

const CELL_SIZE: float = 144.0

var _cells: Dictionary = {}
var _enemy_cells: Dictionary = {}
var _enemies: Dictionary = {}

func register_enemy(enemy: Node2D) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	var id: int = enemy.get_instance_id()
	if _enemies.has(id):
		update_enemy(enemy)
		return
	_enemies[id] = enemy
	var cell: Vector2i = _cell_for(enemy.global_position)
	_enemy_cells[id] = cell
	_add_to_cell(cell, enemy)

func unregister_enemy(enemy: Node2D) -> void:
	if enemy == null:
		return
	var id: int = enemy.get_instance_id()
	if not _enemies.has(id):
		return
	var cell_variant: Variant = _enemy_cells.get(id, null)
	if cell_variant is Vector2i:
		_remove_from_cell(cell_variant as Vector2i, enemy)
	_enemy_cells.erase(id)
	_enemies.erase(id)

func update_enemy(enemy: Node2D) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	var id: int = enemy.get_instance_id()
	if not _enemies.has(id):
		register_enemy(enemy)
		return
	var new_cell: Vector2i = _cell_for(enemy.global_position)
	var old_variant: Variant = _enemy_cells.get(id, new_cell)
	if not (old_variant is Vector2i):
		_enemy_cells[id] = new_cell
		_add_to_cell(new_cell, enemy)
		return
	var old_cell: Vector2i = old_variant as Vector2i
	if old_cell == new_cell:
		return
	_remove_from_cell(old_cell, enemy)
	_add_to_cell(new_cell, enemy)
	_enemy_cells[id] = new_cell

func get_count() -> int:
	return _enemies.size()

func get_nearby(center: Vector2, radius: float) -> Array[Node2D]:
	var result: Array[Node2D] = []
	var safe_radius: float = maxf(1.0, radius)
	var min_cell: Vector2i = _cell_for(center - Vector2.ONE * safe_radius)
	var max_cell: Vector2i = _cell_for(center + Vector2.ONE * safe_radius)
	var radius_sq: float = safe_radius * safe_radius
	for y: int in range(min_cell.y, max_cell.y + 1):
		for x: int in range(min_cell.x, max_cell.x + 1):
			var bucket_variant: Variant = _cells.get(Vector2i(x, y), null)
			if not (bucket_variant is Array):
				continue
			var bucket: Array = bucket_variant as Array
			for entry: Variant in bucket:
				var enemy: Node2D = entry as Node2D
				if enemy == null or not is_instance_valid(enemy):
					continue
				if center.distance_squared_to(enemy.global_position) <= radius_sq:
					result.append(enemy)
	return result

func get_nearest(center: Vector2, max_range: float = 920.0) -> Node2D:
	# Hot targeting path: scan the relevant buckets directly instead of first building
	# an Array of every enemy inside the full search radius. This removes a recurring
	# allocation from Heart Blaster and other auto-targeted weapons.
	var safe_range: float = maxf(1.0, max_range)
	var min_cell: Vector2i = _cell_for(center - Vector2.ONE * safe_range)
	var max_cell: Vector2i = _cell_for(center + Vector2.ONE * safe_range)
	var range_sq: float = safe_range * safe_range
	var nearest: Node2D = null
	var best_sq: float = range_sq
	for y: int in range(min_cell.y, max_cell.y + 1):
		for x: int in range(min_cell.x, max_cell.x + 1):
			var bucket_variant: Variant = _cells.get(Vector2i(x, y), null)
			if not (bucket_variant is Array):
				continue
			var bucket: Array = bucket_variant as Array
			for entry: Variant in bucket:
				var enemy: Node2D = entry as Node2D
				if enemy == null or not is_instance_valid(enemy):
					continue
				var distance_sq: float = center.distance_squared_to(enemy.global_position)
				if distance_sq <= best_sq:
					best_sq = distance_sq
					nearest = enemy
	return nearest

func _cell_for(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / CELL_SIZE), floori(pos.y / CELL_SIZE))

func _add_to_cell(cell: Vector2i, enemy: Node2D) -> void:
	var bucket_variant: Variant = _cells.get(cell, null)
	var bucket: Array = []
	if bucket_variant is Array:
		bucket = bucket_variant as Array
	bucket.append(enemy)
	_cells[cell] = bucket

func _remove_from_cell(cell: Vector2i, enemy: Node2D) -> void:
	var bucket_variant: Variant = _cells.get(cell, null)
	if not (bucket_variant is Array):
		return
	var bucket: Array = bucket_variant as Array
	bucket.erase(enemy)
	if bucket.is_empty():
		_cells.erase(cell)
	else:
		_cells[cell] = bucket
