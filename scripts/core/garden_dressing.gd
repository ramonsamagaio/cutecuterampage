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
	# Soft dirt/flower-bed pixels make the lawn less like a flat debug plane.
	for i: int in 10:
		var patch: Vector2 = Vector2(rng.randi_range(20, chunk_pixels - 20), rng.randi_range(20, chunk_pixels - 20))
		var patch_size: Vector2 = Vector2(rng.randi_range(18, 52), rng.randi_range(8, 22))
		draw_rect(Rect2(patch - patch_size * 0.5, patch_size), Color(0.49, 0.66, 0.27, 0.16))
	for i: int in 26:
		_draw_flower(Vector2(rng.randi_range(10, chunk_pixels - 10), rng.randi_range(10, chunk_pixels - 10)), rng.randi_range(0, 3))
	for i: int in 9:
		_draw_pebble(Vector2(rng.randi_range(12, chunk_pixels - 12), rng.randi_range(12, chunk_pixels - 12)), rng.randi_range(0, 2))
	for i: int in 3:
		_draw_mushroom(Vector2(rng.randi_range(20, chunk_pixels - 20), rng.randi_range(20, chunk_pixels - 20)), rng.randf() < 0.5)

func _draw_flower(p: Vector2, variant: int) -> void:
	var petal: Color = Color("ff8eb8")
	if variant == 1: petal = Color("8fcfff")
	if variant == 2: petal = Color("fff08b")
	var stem: Color = Color("4f9b42")
	draw_rect(Rect2(p + Vector2(0, 2), Vector2(2, 4)), stem)
	draw_rect(Rect2(p + Vector2(-2, -1), Vector2(2, 2)), petal)
	draw_rect(Rect2(p + Vector2(2, -1), Vector2(2, 2)), petal)
	draw_rect(Rect2(p + Vector2(0, -3), Vector2(2, 2)), petal)
	draw_rect(Rect2(p + Vector2(0, 1), Vector2(2, 2)), petal)
	draw_rect(Rect2(p, Vector2(2, 2)), Color("fff4c7"))

func _draw_pebble(p: Vector2, variant: int) -> void:
	var c: Color = Color("d6d7ca") if variant == 0 else Color("b9c6b0")
	draw_rect(Rect2(p + Vector2(-3, -1), Vector2(6, 3)), c)
	draw_rect(Rect2(p + Vector2(-1, -2), Vector2(3, 1)), c.lightened(0.16))

func _draw_mushroom(p: Vector2, pink: bool) -> void:
	var cap: Color = Color("ff6fa4") if pink else Color("f45c4f")
	draw_rect(Rect2(p + Vector2(-4, -4), Vector2(8, 4)), Color("3d2436"))
	draw_rect(Rect2(p + Vector2(-3, -4), Vector2(6, 3)), cap)
	draw_rect(Rect2(p + Vector2(-1, 0), Vector2(3, 5)), Color("fff0d7"))
	draw_rect(Rect2(p + Vector2(-2, -3), Vector2(2, 1)), Color("fff5d9"))
