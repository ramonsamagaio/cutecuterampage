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

	# Large garden islands establish visual planes. They are static draw calls, so the
	# world gains depth without adding gameplay nodes or collision.
	for i: int in 3:
		_draw_garden_island(Vector2(rng.randi_range(70, chunk_pixels - 70), rng.randi_range(70, chunk_pixels - 70)), rng.randf_range(34.0, 66.0), rng, i)

	# Soft value shifts keep the lawn from reading as one flat green sheet.
	for i: int in 9:
		var patch: Vector2 = Vector2(rng.randi_range(24, chunk_pixels - 24), rng.randi_range(24, chunk_pixels - 24))
		var radius_x: float = rng.randf_range(20.0, 48.0)
		var radius_y: float = rng.randf_range(8.0, 22.0)
		var patch_color: Color = Color(0.36, 0.54, 0.20, rng.randf_range(0.07, 0.13))
		_draw_soft_ellipse(patch, radius_x, radius_y, patch_color)

	for i: int in 5:
		_draw_bush(Vector2(rng.randi_range(34, chunk_pixels - 34), rng.randi_range(34, chunk_pixels - 34)), rng.randi_range(0, 2))

	for i: int in 27:
		_draw_flower(Vector2(rng.randi_range(10, chunk_pixels - 10), rng.randi_range(10, chunk_pixels - 10)), rng.randi_range(0, 3))
	for i: int in 12:
		_draw_grass_tuft(Vector2(rng.randi_range(12, chunk_pixels - 12), rng.randi_range(12, chunk_pixels - 12)), rng.randi_range(0, 2))
	for i: int in 9:
		_draw_pebble(Vector2(rng.randi_range(12, chunk_pixels - 12), rng.randi_range(12, chunk_pixels - 12)), rng.randi_range(0, 2))
	for i: int in 3:
		_draw_mushroom(Vector2(rng.randi_range(20, chunk_pixels - 20), rng.randi_range(20, chunk_pixels - 20)), rng.randf() < 0.5)
	for i: int in 3:
		_draw_flower_cluster(Vector2(rng.randi_range(34, chunk_pixels - 34), rng.randi_range(34, chunk_pixels - 34)), rng)

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
	for i: int in 18:
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
