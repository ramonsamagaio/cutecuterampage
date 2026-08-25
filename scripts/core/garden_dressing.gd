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
	# Layer 1: soft value changes and dirt pockets. These break the lawn into readable planes.
	for i: int in 14:
		var patch: Vector2 = Vector2(rng.randi_range(24, chunk_pixels - 24), rng.randi_range(24, chunk_pixels - 24))
		var patch_size: Vector2 = Vector2(rng.randi_range(24, 76), rng.randi_range(10, 32))
		var patch_color: Color = Color(0.44, 0.61, 0.22, rng.randf_range(0.10, 0.18))
		draw_rect(Rect2(patch - patch_size * 0.5, patch_size), patch_color)
		if rng.randf() < 0.34:
			draw_rect(Rect2(patch - patch_size * 0.34 + Vector2(2, 3), patch_size * 0.68), Color(0.68, 0.76, 0.35, 0.08))

	# Layer 2: larger bushes create foreground/background depth cues without blocking movement.
	for i: int in 5:
		_draw_bush(Vector2(rng.randi_range(34, chunk_pixels - 34), rng.randi_range(34, chunk_pixels - 34)), rng.randi_range(0, 2))

	# Layer 3: small readable dressing.
	for i: int in 34:
		_draw_flower(Vector2(rng.randi_range(10, chunk_pixels - 10), rng.randi_range(10, chunk_pixels - 10)), rng.randi_range(0, 3))
	for i: int in 14:
		_draw_grass_tuft(Vector2(rng.randi_range(12, chunk_pixels - 12), rng.randi_range(12, chunk_pixels - 12)), rng.randi_range(0, 2))
	for i: int in 11:
		_draw_pebble(Vector2(rng.randi_range(12, chunk_pixels - 12), rng.randi_range(12, chunk_pixels - 12)), rng.randi_range(0, 2))
	for i: int in 4:
		_draw_mushroom(Vector2(rng.randi_range(20, chunk_pixels - 20), rng.randi_range(20, chunk_pixels - 20)), rng.randf() < 0.5)
	for i: int in 3:
		_draw_flower_cluster(Vector2(rng.randi_range(34, chunk_pixels - 34), rng.randi_range(34, chunk_pixels - 34)), rng)

func _draw_flower(p: Vector2, variant: int) -> void:
	var petal: Color = Color("ff8eb8")
	if variant == 1: petal = Color("8fcfff")
	if variant == 2: petal = Color("fff08b")
	if variant == 3: petal = Color("d4a0ff")
	var stem: Color = Color("4f9b42")
	var ink: Color = Color(0.18, 0.28, 0.14, 0.42)
	draw_rect(Rect2(p + Vector2(-1, 2), Vector2(3, 5)), ink)
	draw_rect(Rect2(p + Vector2(0, 2), Vector2(2, 4)), stem)
	draw_rect(Rect2(p + Vector2(-3, -1), Vector2(3, 3)), ink)
	draw_rect(Rect2(p + Vector2(2, -1), Vector2(3, 3)), ink)
	draw_rect(Rect2(p + Vector2(-1, -4), Vector2(3, 3)), ink)
	draw_rect(Rect2(p + Vector2(-1, 1), Vector2(3, 3)), ink)
	draw_rect(Rect2(p + Vector2(-2, -1), Vector2(2, 2)), petal)
	draw_rect(Rect2(p + Vector2(2, -1), Vector2(2, 2)), petal)
	draw_rect(Rect2(p + Vector2(0, -3), Vector2(2, 2)), petal)
	draw_rect(Rect2(p + Vector2(0, 1), Vector2(2, 2)), petal)
	draw_rect(Rect2(p, Vector2(2, 2)), Color("fff4c7"))

func _draw_pebble(p: Vector2, variant: int) -> void:
	var c: Color = Color("d6d7ca") if variant == 0 else Color("b9c6b0")
	draw_rect(Rect2(p + Vector2(-4, 1), Vector2(8, 3)), Color(0.20, 0.26, 0.18, 0.20))
	draw_rect(Rect2(p + Vector2(-3, -1), Vector2(6, 3)), c)
	draw_rect(Rect2(p + Vector2(-1, -2), Vector2(3, 1)), c.lightened(0.16))

func _draw_mushroom(p: Vector2, pink: bool) -> void:
	var cap: Color = Color("ff6fa4") if pink else Color("f45c4f")
	draw_rect(Rect2(p + Vector2(-5, 2), Vector2(10, 3)), Color(0.18, 0.22, 0.12, 0.26))
	draw_rect(Rect2(p + Vector2(-4, -4), Vector2(8, 4)), Color("3d2436"))
	draw_rect(Rect2(p + Vector2(-3, -4), Vector2(6, 3)), cap)
	draw_rect(Rect2(p + Vector2(-1, 0), Vector2(3, 5)), Color("fff0d7"))
	draw_rect(Rect2(p + Vector2(-2, -3), Vector2(2, 1)), Color("fff5d9"))

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
	# Ground shadow gives the clump a clear vertical read.
	draw_circle(p + Vector2(2, 8), 16.0, Color(0.13, 0.20, 0.10, 0.24))
	draw_circle(p + Vector2(-9, 1), 11.0, dark)
	draw_circle(p + Vector2(8, 2), 12.0, dark)
	draw_circle(p + Vector2(0, -5), 14.0, mid)
	draw_circle(p + Vector2(-5, -8), 6.0, light)
	draw_circle(p + Vector2(6, -6), 5.0, light)
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
	draw_rect(Rect2(p + Vector2(-3, 1), Vector2(7, 2)), Color(0.18, 0.24, 0.12, 0.16))
	draw_line(p + Vector2(-2, 1), p + Vector2(-4, -5), dark, 2.0)
	draw_line(p, p + Vector2(0, -7), light, 2.0)
	draw_line(p + Vector2(2, 1), p + Vector2(5, -4), dark, 2.0)

func _draw_flower_cluster(p: Vector2, rng: RandomNumberGenerator) -> void:
	draw_circle(p + Vector2(1, 4), 10.0, Color(0.20, 0.30, 0.15, 0.12))
	for i: int in 7:
		var q: Vector2 = p + Vector2(rng.randf_range(-10.0, 10.0), rng.randf_range(-7.0, 7.0))
		_draw_flower(q, rng.randi_range(0, 3))
