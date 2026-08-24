class_name BloodSystem
extends Node2D

const MAX_SPLATS: int = 1800
var splats: Array[Dictionary] = []

func _ready() -> void:
	add_to_group("blood_system")
	z_index = -30

func emit_burst(global_origin: Vector2, direction: Vector2, amount: int = 8) -> void:
	var local_origin: Vector2 = to_local(global_origin)
	var base_dir: Vector2 = direction.normalized()
	if base_dir == Vector2.ZERO:
		base_dir = Vector2.RIGHT.rotated(randf() * TAU)
	for _i: int in amount:
		var droplet: BloodDroplet = BloodDroplet.new()
		add_child(droplet)
		var spread: Vector2 = base_dir.rotated(randf_range(-1.70, 1.70))
		var speed: float = randf_range(90.0, 330.0)
		var shade: Color = Color("8f0828") if randf() < 0.38 else Color("d71943")
		droplet.configure(local_origin, spread * speed, randf_range(0.20, 0.68), randi_range(2, 4), shade)

func spawn_chunk(global_origin: Vector2, chunk_kind: String, tint: Color, force: Vector2) -> void:
	var chunk: BodyChunk = BodyChunk.new()
	add_child(chunk)
	chunk.configure(to_local(global_origin), chunk_kind, tint, force * randf_range(55.0, 125.0))

func spawn_art_chunk(global_origin: Vector2, texture_path: String, target_size: Vector2, force: Vector2) -> void:
	var chunk: ArtBodyChunk = ArtBodyChunk.new()
	add_child(chunk)
	chunk.configure(to_local(global_origin), texture_path, target_size, force)

func add_massive_splat(global_pos: Vector2, radius: int, shade: Color) -> void:
	var pieces: int = maxi(5, radius)
	for i: int in pieces:
		var angle: float = TAU * float(i) / float(pieces) + randf_range(-0.25, 0.25)
		var distance: float = randf_range(0.0, float(radius) * 1.7)
		var p: Vector2 = global_pos + Vector2.RIGHT.rotated(angle) * distance
		add_ground_splat(p, randi_range(3, maxi(4, radius)), shade.lightened(randf_range(0.0, 0.10)))

func add_ground_splat(global_pos: Vector2, px_size: int, shade: Color) -> void:
	splats.append({
		"pos": Vector2i(roundi(global_pos.x), roundi(global_pos.y)),
		"size": px_size,
		"shade": shade,
		"seed": randi()
	})
	if splats.size() > MAX_SPLATS:
		splats.pop_front()
	queue_redraw()

func _draw() -> void:
	for splat: Dictionary in splats:
		var p: Vector2i = splat["pos"]
		var s: int = splat["size"]
		var c: Color = splat["shade"]
		var seed_value: int = int(splat["seed"])
		draw_rect(Rect2(p.x - s, p.y - maxi(2, s / 2), s * 2, maxi(4, s)), c)
		draw_rect(Rect2(p.x - maxi(2, s / 2), p.y - s, maxi(4, s), s * 2), c.darkened(0.07))
		var seed_a_y: int = floori(float(seed_value) / 11.0)
		var seed_b_x: int = floori(float(seed_value) / 17.0)
		var seed_b_y: int = floori(float(seed_value) / 23.0)
		var satellite_a: Vector2i = Vector2i((seed_value % 9) - 4, (seed_a_y % 9) - 4)
		var satellite_b: Vector2i = Vector2i((seed_b_x % 13) - 6, (seed_b_y % 11) - 5)
		draw_rect(Rect2(p + satellite_a - Vector2i(2, 2), Vector2i(4, 4)), c.lightened(0.04))
		draw_rect(Rect2(p + satellite_b - Vector2i(1, 1), Vector2i(3, 3)), c.darkened(0.10))
