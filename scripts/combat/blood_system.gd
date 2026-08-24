class_name BloodSystem
extends Node2D

const MAX_SPLATS := 1100
var splats: Array[Dictionary] = []

func _ready() -> void:
	add_to_group("blood_system")
	z_index = -30

func emit_burst(global_origin: Vector2, direction: Vector2, amount: int = 8) -> void:
	var local_origin := to_local(global_origin)
	var base_dir := direction.normalized()
	if base_dir == Vector2.ZERO:
		base_dir = Vector2.RIGHT.rotated(randf() * TAU)
	for i in amount:
		var droplet := BloodDroplet.new()
		add_child(droplet)
		var spread := base_dir.rotated(randf_range(-1.45, 1.45))
		var speed := randf_range(70.0, 230.0)
		var shade := Color("9f0b2c") if randf() < 0.35 else Color("d51c42")
		droplet.configure(local_origin, spread * speed, randf_range(0.16, 0.52), randi_range(1, 3), shade)

func spawn_chunk(global_origin: Vector2, chunk_kind: String, tint: Color, force: Vector2) -> void:
	var chunk := BodyChunk.new()
	add_child(chunk)
	chunk.configure(to_local(global_origin), chunk_kind, tint, force * randf_range(55.0, 125.0))

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
	for splat in splats:
		var p: Vector2i = splat["pos"]
		var s: int = splat["size"]
		var c: Color = splat["shade"]
		draw_rect(Rect2(p.x - s, p.y - 1, s * 2, 3), c)
		draw_rect(Rect2(p.x - 1, p.y - s, 3, s * 2), c.darkened(0.08))
		if int(splat["seed"]) % 2 == 0:
			draw_rect(Rect2(p.x + s + 2, p.y, 2, 2), c)
