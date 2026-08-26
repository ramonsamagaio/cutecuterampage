class_name GardenDressing
extends Node2D

var chunk_coord: Vector2i = Vector2i.ZERO
var chunk_pixels: int = 512
var seed_value: int = 0

func configure(coord: Vector2i, size_px: int) -> void:
	chunk_coord = coord
	chunk_pixels = size_px
	seed_value = absi((coord.x * 92837111) ^ (coord.y * 689287499) ^ 0x5A17)
	z_index = 1
	queue_redraw()

func _draw() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value

	# A faint curving path appears only in some chunks, creating larger visual flow across the lawn.
	if seed_value % 3 != 0:
		_draw_path_ribbon(rng)

	# Large garden islands establish visual planes. They are static draw calls, so the
	# world gains depth without adding gameplay nodes or collision.
	for i: int in 3:
		_draw_garden_island(Vector2(rng.randi_range(70, chunk_pixels - 70), rng.randi_range(70, chunk_pixels - 70)), rng.randf_range(34.0, 66.0), rng, i)

	# One authored-looking landmark per chunk makes exploration visually memorable.
	var landmark_pos: Vector2 = Vector2(rng.randi_range(105, chunk_pixels - 105), rng.randi_range(105, chunk_pixels - 105))
	_draw_landmark(landmark_pos, seed_value % 5, rng)

	# Soft value shifts keep the lawn from reading as one flat green sheet.
	for i: int in 8:
		var patch: Vector2 = Vector2(rng.randi_range(24, chunk_pixels - 24), rng.randi_range(24, chunk_pixels - 24))
		var radius_x: float = rng.randf_range(20.0, 48.0)
		var radius_y: float = rng.randf_range(8.0, 22.0)
		var patch_color: Color = Color(0.36, 0.54, 0.20, rng.randf_range(0.06, 0.11))
		_draw_soft_ellipse(patch, radius_x, radius_y, patch_color)

	for i: int in 5:
		_draw_bush(Vector2(rng.randi_range(34, chunk_pixels - 34), rng.randi_range(34, chunk_pixels - 34)), rng.randi_range(0, 2))

	for i: int in 25:
		_draw_flower(Vector2(rng.randi_range(10, chunk_pixels - 10), rng.randi_range(10, chunk_pixels - 10)), rng.randi_range(0, 3))
	for i: int in 11:
		_draw_grass_tuft(Vector2(rng.randi_range(12, chunk_pixels - 12), rng.randi_range(12, chunk_pixels - 12)), rng.randi_range(0, 2))
	for i: int in 8:
		_draw_pebble(Vector2(rng.randi_range(12, chunk_pixels - 12), rng.randi_range(12, chunk_pixels - 12)), rng.randi_range(0, 2))
	for i: int in 3:
		_draw_mushroom(Vector2(rng.randi_range(20, chunk_pixels - 20), rng.randi_range(20, chunk_pixels - 20)), rng.randf() < 0.5)
	for i: int in 2:
		_draw_flower_cluster(Vector2(rng.randi_range(34, chunk_pixels - 34), rng.randi_range(34, chunk_pixels - 34)), rng)

func _draw_path_ribbon(rng: RandomNumberGenerator) -> void:
	var y0: float = rng.randf_range(72.0, float(chunk_pixels) - 72.0)
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(-24, y0 + rng.randf_range(-20.0, 20.0)),
		Vector2(float(chunk_pixels) * 0.24, y0 + rng.randf_range(-32.0, 32.0)),
		Vector2(float(chunk_pixels) * 0.52, y0 + rng.randf_range(-42.0, 42.0)),
		Vector2(float(chunk_pixels) * 0.77, y0 + rng.randf_range(-28.0, 28.0)),
		Vector2(float(chunk_pixels) + 24.0, y0 + rng.randf_range(-18.0, 18.0))
	])
	draw_polyline(points, Color(0.56, 0.48, 0.29, 0.055), 38.0, true)
	draw_polyline(points, Color(0.76, 0.68, 0.43, 0.040), 24.0, true)

func _draw_landmark(p: Vector2, kind: int, rng: RandomNumberGenerator) -> void:
	match kind:
		0:
			_draw_heart_flower_bed(p, rng)
		1:
			_draw_lily_pond(p, rng)
		2:
			_draw_picnic_patch(p, rng)
		3:
			_draw_stone_garden(p, rng)
		_:
			_draw_sign_and_fence(p, rng)

func _draw_heart_flower_bed(p: Vector2, rng: RandomNumberGenerator) -> void:
	draw_circle(p + Vector2(0, 10), 31.0, Color(0.12, 0.20, 0.10, 0.12))
	var soil: Color = Color(0.52, 0.36, 0.28, 0.20)
	draw_circle(p + Vector2(-15, -6), 22.0, soil)
	draw_circle(p + Vector2(15, -6), 22.0, soil)
	draw_colored_polygon(PackedVector2Array([
		p + Vector2(-34, 0), p + Vector2(34, 0), p + Vector2(0, 42)
	]), soil)
	for i: int in 14:
		var angle: float = TAU * float(i) / 14.0
		var q: Vector2 = p + Vector2(cos(angle) * rng.randf_range(12.0, 27.0), sin(angle) * rng.randf_range(8.0, 24.0))
		_draw_flower(q, i % 4)
	_draw_sparkle_ground(p + Vector2(0, -3), Color(1.0, 0.86, 0.95, 0.50))

func _draw_lily_pond(p: Vector2, rng: RandomNumberGenerator) -> void:
	_draw_soft_ellipse(p + Vector2(2, 8), 50.0, 30.0, Color(0.10, 0.22, 0.18, 0.16))
	_draw_soft_ellipse(p, 47.0, 27.0, Color(0.20, 0.62, 0.70, 0.42))
	_draw_soft_ellipse(p + Vector2(-6, -5), 38.0, 18.0, Color(0.38, 0.80, 0.85, 0.18))
	draw_arc(p, 34.0, 3.4, 5.9, 24, Color(0.82, 1.0, 1.0, 0.24), 2.0, true)
	for i: int in 4:
		var q: Vector2 = p + Vector2(rng.randf_range(-31.0, 31.0), rng.randf_range(-14.0, 14.0))
		draw_circle(q, 6.0, Color("5aa94e"))
		draw_line(q, q + Vector2(6, -2), Color(0.16, 0.47, 0.24, 0.85), 2.0)
	if rng.randf() < 0.72:
		_draw_flower(p + Vector2(18, -10), 0)

func _draw_picnic_patch(p: Vector2, rng: RandomNumberGenerator) -> void:
	_draw_soft_ellipse(p + Vector2(0, 8), 46.0, 29.0, Color(0.12, 0.20, 0.10, 0.10))
	var blanket: Rect2 = Rect2(p + Vector2(-28, -18), Vector2(56, 38))
	draw_rect(blanket, Color("f28fb4"), true)
	for i: int in 5:
		draw_line(p + Vector2(-28 + i * 14, -18), p + Vector2(-28 + i * 14, 20), Color(1.0, 0.78, 0.88, 0.36), 2.0)
	for i: int in 4:
		draw_line(p + Vector2(-28, -18 + i * 12), p + Vector2(28, -18 + i * 12), Color(1.0, 0.78, 0.88, 0.28), 2.0)
	# Tiny sweets sell the toy-diorama feeling without spawning item nodes.
	draw_circle(p + Vector2(-10, -2), 6.0, Color("fff1d2"))
	draw_circle(p + Vector2(-10, -4), 4.0, Color("ff8ab5"))
	draw_circle(p + Vector2(12, 4), 5.0, Color("ffd96d"))
	draw_circle(p + Vector2(12, 2), 3.0, Color("fff2d0"))
	if rng.randf() < 0.7:
		_draw_flower(p + Vector2(34, -5), 2)

func _draw_stone_garden(p: Vector2, rng: RandomNumberGenerator) -> void:
	_draw_soft_ellipse(p, 50.0, 26.0, Color(0.66, 0.62, 0.44, 0.11))
	for i: int in 7:
		var angle: float = TAU * float(i) / 7.0
		var q: Vector2 = p + Vector2(cos(angle) * rng.randf_range(25.0, 40.0), sin(angle) * rng.randf_range(12.0, 22.0))
		_draw_pebble(q, i % 2)
	for i: int in 3:
		draw_arc(p, 12.0 + float(i) * 8.0, 0.15, PI * 1.65, 22, Color(0.88, 0.86, 0.69, 0.16), 1.5, true)
	_draw_mushroom(p + Vector2(6, -3), true)

func _draw_sign_and_fence(p: Vector2, rng: RandomNumberGenerator) -> void:
	var wood_dark: Color = Color("6f4b43")
	var wood: Color = Color("b77963")
	# Short fence fragment.
	for i: int in 4:
		var x: float = -42.0 + float(i) * 22.0
		draw_rect(Rect2(p + Vector2(x, -14), Vector2(7, 34)), wood_dark)
		draw_rect(Rect2(p + Vector2(x + 1, -13), Vector2(5, 31)), wood)
	draw_rect(Rect2(p + Vector2(-44, -4), Vector2(74, 6)), wood_dark)
	draw_rect(Rect2(p + Vector2(-43, -3), Vector2(72, 4)), wood.lightened(0.08))
	# Little candy-direction sign.
	draw_rect(Rect2(p + Vector2(38, -26), Vector2(6, 47)), wood_dark)
	draw_rect(Rect2(p + Vector2(39, -25), Vector2(4, 44)), wood)
	draw_colored_polygon(PackedVector2Array([
		p + Vector2(28, -28), p + Vector2(61, -28), p + Vector2(70, -20), p + Vector2(61, -12), p + Vector2(28, -12)
	]), Color("ff8db7"))
	draw_circle(p + Vector2(42, -20), 3.0, Color("fff4c7"))
	if rng.randf() < 0.75:
		_draw_flower(p + Vector2(-49, 14), 3)

func _draw_garden_island(p: Vector2, radius: float, rng: RandomNumberGenerator, variant: int) -> void:
	var shadow: Color = Color(0.10, 0.17, 0.08, 0.10)
	var soil: Color = Color(0.60, 0.48, 0.29, 0.11)
	var rim: Color = Color(0.72, 0.72, 0.38, 0.09)
	if variant == 1:
		soil = Color(0.50, 0.57, 0.25, 0.13)
	elif variant == 2:
		soil = Color(0.66, 0.52, 0.34, 0.09)
	draw_circle(p + Vector2(3, 7), radius * 0.92, shadow)
	draw_circle(p, radius, soil)
	draw_arc(p, radius * 0.86, 0.2, PI * 1.25, 28, rim, 3.0, true)
	for i: int in 5:
		var a: float = rng.randf() * TAU
		var dist: float = rng.randf_range(radius * 0.30, radius * 0.76)
		var q: Vector2 = p + Vector2.RIGHT.rotated(a) * dist
		if i < 3:
			_draw_flower(q, rng.randi_range(0, 3))
		else:
			_draw_grass_tuft(q, rng.randi_range(0, 2))
	for i: int in 3:
		var stone_angle: float = -0.5 + float(i) * 0.34 + rng.randf_range(-0.08, 0.08)
		var stone_pos: Vector2 = p + Vector2.RIGHT.rotated(stone_angle) * radius * rng.randf_range(0.52, 0.78)
		_draw_pebble(stone_pos, rng.randi_range(0, 1))

func _draw_soft_ellipse(p: Vector2, radius_x: float, radius_y: float, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in 19:
		var a: float = TAU * float(i) / 18.0
		points.append(p + Vector2(cos(a) * radius_x, sin(a) * radius_y))
	draw_colored_polygon(points, color)

func _draw_flower(p: Vector2, variant: int) -> void:
	var petal: Color = Color("ff8eb8")
	if variant == 1: petal = Color("8fcfff")
	if variant == 2: petal = Color("fff08b")
	if variant == 3: petal = Color("d4a0ff")
	var stem: Color = Color("4f9b42")
	var ink: Color = Color(0.18, 0.28, 0.14, 0.34)
	draw_line(p + Vector2(0, 2), p + Vector2(0, 7), ink, 3.0, true)
	draw_line(p + Vector2(0, 2), p + Vector2(0, 6), stem, 1.5, true)
	draw_circle(p + Vector2(-2.5, 0), 2.2, ink)
	draw_circle(p + Vector2(2.5, 0), 2.2, ink)
	draw_circle(p + Vector2(0, -2.5), 2.2, ink)
	draw_circle(p + Vector2(0, 2.5), 2.2, ink)
	draw_circle(p + Vector2(-2.2, 0), 1.6, petal)
	draw_circle(p + Vector2(2.2, 0), 1.6, petal)
	draw_circle(p + Vector2(0, -2.2), 1.6, petal)
	draw_circle(p + Vector2(0, 2.2), 1.6, petal)
	draw_circle(p, 1.5, Color("fff4c7"))

func _draw_pebble(p: Vector2, variant: int) -> void:
	var c: Color = Color("d6d7ca") if variant == 0 else Color("b9c6b0")
	draw_circle(p + Vector2(1, 2), 4.5, Color(0.20, 0.26, 0.18, 0.14))
	draw_circle(p, 3.8, c)
	draw_arc(p + Vector2(-0.6, -0.7), 2.2, 3.6, 5.2, 8, c.lightened(0.16), 1.2, true)

func _draw_mushroom(p: Vector2, pink: bool) -> void:
	var cap: Color = Color("ff6fa4") if pink else Color("f45c4f")
	draw_circle(p + Vector2(1, 4), 6.0, Color(0.18, 0.22, 0.12, 0.18))
	draw_rect(Rect2(p + Vector2(-1.4, -1), Vector2(2.8, 6)), Color("fff0d7"))
	draw_circle(p + Vector2(0, -2), 5.3, Color("3d2436"))
	draw_circle(p + Vector2(0, -2.3), 4.3, cap)
	draw_circle(p + Vector2(-1.6, -3.3), 0.9, Color("fff5d9"))
	draw_circle(p + Vector2(2.0, -1.8), 0.8, Color("fff5d9"))

func _draw_bush(p: Vector2, variant: int) -> void:
	var dark: Color = Color("347b3e")
	var mid: Color = Color("4d9b48")
	var light: Color = Color("72b955")
	if variant == 1:
		dark = Color("427b48")
		mid = Color("5ea255")
		light = Color("83c66b")
	elif variant == 2:
		dark = Color("3a7142")
		mid = Color("53914d")
		light = Color("73ae59")
	draw_circle(p + Vector2(2, 9), 16.5, Color(0.13, 0.20, 0.10, 0.20))
	draw_circle(p + Vector2(-9, 1), 11.5, dark)
	draw_circle(p + Vector2(8, 2), 12.5, dark)
	draw_circle(p + Vector2(0, -5), 14.5, mid)
	draw_circle(p + Vector2(-5, -8), 6.4, light)
	draw_circle(p + Vector2(6, -6), 5.4, light)
	draw_arc(p + Vector2(-2, -5), 10.0, 3.7, 5.5, 12, light.lightened(0.13), 1.7, true)
	if variant == 0:
		draw_circle(p + Vector2(-7, -2), 2.0, Color("ff8eb8"))
		draw_circle(p + Vector2(8, 0), 2.0, Color("fff08b"))

func _draw_grass_tuft(p: Vector2, variant: int) -> void:
	var dark: Color = Color("3f8d3e")
	var light: Color = Color("65ad4b")
	if variant == 1:
		light = Color("78bd55")
	elif variant == 2:
		dark = Color("397b43")
	draw_line(p + Vector2(-3, 2), p + Vector2(4, 2), Color(0.18, 0.24, 0.12, 0.12), 2.0, true)
	draw_line(p + Vector2(-2, 1), p + Vector2(-4, -5), dark, 2.0, true)
	draw_line(p, p + Vector2(0, -7), light, 2.0, true)
	draw_line(p + Vector2(2, 1), p + Vector2(5, -4), dark, 2.0, true)

func _draw_flower_cluster(p: Vector2, rng: RandomNumberGenerator) -> void:
	draw_circle(p + Vector2(1, 4), 10.0, Color(0.20, 0.30, 0.15, 0.10))
	for i: int in 6:
		var q: Vector2 = p + Vector2(rng.randf_range(-10.0, 10.0), rng.randf_range(-7.0, 7.0))
		_draw_flower(q, rng.randi_range(0, 3))

func _draw_sparkle_ground(p: Vector2, color: Color) -> void:
	draw_line(p + Vector2(-5, 0), p + Vector2(5, 0), color, 1.5, true)
	draw_line(p + Vector2(0, -5), p + Vector2(0, 5), color, 1.5, true)
