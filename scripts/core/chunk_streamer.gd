class_name ChunkStreamer
extends Node2D

const CHUNK_SIZE := 16
const TILE_SIZE := 32
const ACTIVE_RADIUS := 2

var player: Node2D
var _tile_set: TileSet
var _active: Dictionary = {}
var _queued: Dictionary = {}
var _queue: Array[Vector2i] = []
var _last_center := Vector2i(999999, 999999)

func _ready() -> void:
	z_index = -1000
	_tile_set = WorldTiles.create_grass_tileset()

func _process(_delta: float) -> void:
	if player == null:
		return
	var world_chunk := CHUNK_SIZE * TILE_SIZE
	var center := Vector2i(
		floori(player.global_position.x / world_chunk),
		floori(player.global_position.y / world_chunk)
	)
	if center != _last_center:
		_last_center = center
		_refresh_requested_chunks(center)
	# Important: one chunk per frame. Never dump a whole ring onto the main thread.
	if not _queue.is_empty():
		_build_chunk(_queue.pop_front())

func _refresh_requested_chunks(center: Vector2i) -> void:
	var wanted := {}
	for y in range(center.y - ACTIVE_RADIUS, center.y + ACTIVE_RADIUS + 1):
		for x in range(center.x - ACTIVE_RADIUS, center.x + ACTIVE_RADIUS + 1):
			var c := Vector2i(x, y)
			wanted[c] = true
			if not _active.has(c) and not _queued.has(c):
				_queue.append(c)
				_queued[c] = true
	for c in _active.keys():
		if not wanted.has(c):
			var layer: TileMapLayer = _active[c]
			layer.queue_free()
			_active.erase(c)

func _build_chunk(coord: Vector2i) -> void:
	_queued.erase(coord)
	if _active.has(coord):
		return
	var layer := TileMapLayer.new()
	layer.name = "Chunk_%d_%d" % [coord.x, coord.y]
	layer.tile_set = _tile_set
	layer.position = Vector2(coord.x, coord.y) * float(CHUNK_SIZE * TILE_SIZE)
	layer.z_index = -1000
	add_child(layer)
	for y in CHUNK_SIZE:
		for x in CHUNK_SIZE:
			var wx := coord.x * CHUNK_SIZE + x
			var wy := coord.y * CHUNK_SIZE + y
			var mixed := abs((wx * 73856093) ^ (wy * 19349663))
			var variant := mixed % 4
			layer.set_cell(Vector2i(x, y), 0, Vector2i(variant, 0), 0)
	_active[coord] = layer
