class_name ChunkStreamer
extends Node2D

const CHUNK_SIZE: int = 16
const TILE_SIZE: int = 32
const ACTIVE_RADIUS: int = 2

var player: Node2D
var _tile_set: TileSet
var _active: Dictionary[Vector2i, TileMapLayer] = {}
var _queued: Dictionary[Vector2i, bool] = {}
var _queue: Array[Vector2i] = []
var _last_center: Vector2i = Vector2i(999999, 999999)

func _ready() -> void:
	z_index = -1000
	_tile_set = WorldTiles.create_grass_tileset()

func _process(_delta: float) -> void:
	if player == null:
		return
	var world_chunk: int = CHUNK_SIZE * TILE_SIZE
	var center: Vector2i = Vector2i(
		floori(player.global_position.x / float(world_chunk)),
		floori(player.global_position.y / float(world_chunk))
	)
	if center != _last_center:
		_last_center = center
		_refresh_requested_chunks(center)
	if not _queue.is_empty():
		var next_chunk: Vector2i = _queue.pop_front()
		_build_chunk(next_chunk)

func _refresh_requested_chunks(center: Vector2i) -> void:
	var wanted: Dictionary[Vector2i, bool] = {}
	for y: int in range(center.y - ACTIVE_RADIUS, center.y + ACTIVE_RADIUS + 1):
		for x: int in range(center.x - ACTIVE_RADIUS, center.x + ACTIVE_RADIUS + 1):
			var c: Vector2i = Vector2i(x, y)
			wanted[c] = true
			if not _active.has(c) and not _queued.has(c):
				_queue.append(c)
				_queued[c] = true
	for c: Vector2i in _active:
		if not wanted.has(c):
			var layer: TileMapLayer = _active[c]
			if is_instance_valid(layer):
				layer.queue_free()
			_active.erase(c)

func _build_chunk(coord: Vector2i) -> void:
	_queued.erase(coord)
	if _active.has(coord):
		return
	var layer: TileMapLayer = TileMapLayer.new()
	layer.name = "Chunk_%d_%d" % [coord.x, coord.y]
	layer.tile_set = _tile_set
	layer.position = Vector2(coord.x, coord.y) * float(CHUNK_SIZE * TILE_SIZE)
	layer.z_index = -1000
	add_child(layer)
	for y: int in CHUNK_SIZE:
		for x: int in CHUNK_SIZE:
			var wx: int = coord.x * CHUNK_SIZE + x
			var wy: int = coord.y * CHUNK_SIZE + y
			var mixed: int = absi((wx * 73856093) ^ (wy * 19349663))
			var variant: int = mixed % WorldTiles.VARIANTS
			layer.set_cell(Vector2i(x, y), 0, Vector2i(variant, 0), 0)
	var dressing: GardenDressing = GardenDressing.new()
	dressing.name = "GardenDressing"
	dressing.configure(coord, CHUNK_SIZE * TILE_SIZE)
	layer.add_child(dressing)
	_active[coord] = layer
