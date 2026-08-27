class_name BloodSystem
extends Node2D

const MAX_SPLATS: int = 560
const MAX_FLYING_CHILDREN: int = 130
const REDRAW_INTERVAL: float = 1.0 / 10.0

var splats: Array[Dictionary] = []
var _redraw_pending: bool = false
var _redraw_timer: float = 0.0

func _ready() -> void:
	add_to_group("blood_system")
	z_index = -30

func _process(delta: float) -> void:
	if not _redraw_pending:
		return
	_redraw_timer -= delta
	if _redraw_timer <= 0.0:
		_redraw_timer = REDRAW_INTERVAL
		_redraw_pending = false
		queue_redraw()

func emit_burst(global_origin: Vector2, direction: Vector2, amount: int = 8) -> void:
	var active_children: int = get_child_count()
	if active_children >= MAX_FLYING_CHILDREN:
		return
	var allowed: int = mini(amount, MAX_FLYING_CHILDREN - active_children)
	if active_children > 96:
		allowed = mini(allowed, 3)
	elif active_children > 66:
		allowed = mini(allowed, 6)
	var local_origin: Vector2 = to_local(global_origin)
	var base_dir: Vector2 = direction.normalized()
	if base_dir == Vector2.ZERO:
		base_dir = Vector2.RIGHT.rotated(randf() * TAU)
	for _i: int in allowed:
		var droplet: BloodDroplet = BloodDroplet.new()
		add_child(droplet)
		var spread: Vector2 = base_dir.rotated(randf_range(-1.82, 1.82))
		var speed: float = randf_range(105.0, 395.0)
		var shade_roll: float = randf()
		var shade: Color = Color("d71943")
		if shade_roll < 0.27:
			shade = Color("7b0824")
		elif shade_roll < 0.56:
			shade = Color("a60930")
		elif shade_roll > 0.88:
			shade = Color("f23a55")
		var size_value: int = randi_range(2, 6)
		if randf() < 0.14:
			size_value += randi_range(2, 3)
		droplet.configure(local_origin, spread * speed, randf_range(0.18, 0.58), size_value, shade)

func spawn_chunk(global_origin: Vector2, chunk_kind: String, tint: Color, force: Vector2) -> void:
	if get_child_count() >= MAX_FLYING_CHILDREN:
		return
	var chunk: BodyChunk = BodyChunk.new()
	add_child(chunk)
	chunk.configure(to_local(global_origin), chunk_kind, tint, force * randf_range(55.0, 125.0))

func spawn_art_chunk(global_origin: Vector2, texture_path: String, target_size: Vector2, force: Vector2) -> void:
	if get_child_count() >= MAX_FLYING_CHILDREN:
		return
	var chunk: ArtBodyChunk = ArtBodyChunk.new()
	add_child(chunk)
	chunk.configure(to_local(global_origin), texture_path, target_size, force)

func add_massive_splat(global_pos: Vector2, radius: int, shade: Color) -> void:
	var pieces: int = mini(12, maxi(6, radius))
	for i: int in pieces:
		var angle: float = TAU * float(i) / float(pieces) + randf_range(-0.30, 0.30)
		var distance: float = randf_range(0.0, float(radius) * 2.0)
		var p: Vector2 = global_pos + Vector2.RIGHT.rotated(angle) * distance
		add_ground_splat(p, randi_range(3, maxi(5, radius + 1)), shade.lightened(randf_range(0.0, 0.10)))
	for _i: int in randi_range(3, 6):
		var satellite: Vector2 = global_pos + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(float(radius) * 1.3, float(radius) * 3.2)
		add_ground_splat(satellite, randi_range(2, 4), shade.darkened(randf_range(0.0, 0.12)))

func add_ground_splat(global_pos: Vector2, px_size: int, shade: Color) -> void:
	splats.append({
		"pos": Vector2i(roundi(global_pos.x), roundi(global_pos.y)),
		"size": px_size,
		"shade": shade,
		"seed": randi(),
		"kind": randi_range(0, 3),
		"angle": randf_range(0.0, TAU)
	})
	if splats.size() > MAX_SPLATS:
		splats.pop_front()
	_redraw_pending = true

func _draw() -> void:
	for splat: Dictionary in splats:
		var p: Vector2i = splat["pos"]
		var s: int = splat["size"]
		var c: Color = splat["shade"]
		var seed_value: int = int(splat["seed"])
		var kind: int = int(splat.get("kind", 0))
		var angle: float = float(splat.get("angle", 0.0))
		match kind:
			0:
				draw_circle(Vector2(p), float(s), c)
				draw_circle(Vector2(p) + Vector2(float(s) * 0.62, -float(s) * 0.22), maxf(1.5, float(s) * 0.44), c.darkened(0.08))
			1:
				var streak_dir: Vector2 = Vector2.RIGHT.rotated(angle)
				var side: Vector2 = Vector2(-streak_dir.y, streak_dir.x)
				var a: Vector2 = Vector2(p) - streak_dir * float(s) * 1.55 - side * float(s) * 0.30
				var b: Vector2 = Vector2(p) + streak_dir * float(s) * 1.75 - side * float(s) * 0.30
				var d: Vector2 = Vector2(p) - streak_dir * float(s) * 1.55 + side * float(s) * 0.30
				var e: Vector2 = Vector2(p) + streak_dir * float(s) * 1.75 + side * float(s) * 0.30
				draw_colored_polygon(PackedVector2Array([a, b, e, d]), c)
			2:
				draw_circle(Vector2(p), float(s) * 1.12, c)
				draw_circle(Vector2(p) + Vector2(-float(s) * 0.70, float(s) * 0.18), maxf(1.4, float(s) * 0.35), c.lightened(0.04))
			_:
				var smear_dir: Vector2 = Vector2.RIGHT.rotated(angle)
				draw_line(Vector2(p) - smear_dir * float(s), Vector2(p) + smear_dir * float(s) * 1.35, c, maxf(2.0, float(s) * 0.85), true)
		var seed_y: int = floori(float(seed_value) / 11.0)
		var satellite: Vector2i = Vector2i((seed_value % 11) - 5, (seed_y % 9) - 4)
		draw_circle(Vector2(p + satellite), maxf(1.0, float(s) * 0.24), c.darkened(0.08))
