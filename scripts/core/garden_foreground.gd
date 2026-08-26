class_name GardenForeground
extends Node2D

var chunk_coord: Vector2i = Vector2i.ZERO
var chunk_pixels: int = 512
var seed_value: int = 0

func configure(coord: Vector2i, size_px: int) -> void:
	chunk_coord = coord
	chunk_pixels = size_px
	seed_value = absi((coord.x * 51619717) ^ (coord.y * 1103515245) ^ 0x72B9)
	z_as_relative = false
	z_index = 5
	queue_redraw()

func _draw() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	# Only a few tall clusters per chunk. Occlusion is sparse on purpose so gameplay stays readable.
	var cluster_count: int = 1 + int(seed_value % 2)
	for i: int in cluster_count:
		var margin: int = 54
		var p: Vector2 = Vector2(
			rng.randi_range(margin, chunk_pixels - margin),
			rng.randi_range(margin, chunk_pixels - margin)
		)
		var kind: int = rng.randi_range(0, 2)
		if kind == 0:
			_draw_tall_flower_cluster(p, rng)
		elif kind == 1:
			_draw_leaf_canopy(p, rng)
		else:
			_draw_candy_bush(p, rng)

func _draw_tall_flower_cluster(p: Vector2, rng: RandomNumberGenerator) -> void:
	var stems: int = rng.randi_range(4, 7)
	for i: int in stems:
		var x: float = rng.randf_range(-22.0, 22.0)
		var height: float = rng.randf_range(24.0, 44.0)
		var stem_color: Color = Color("397f42")
		draw_line(p + Vector2(x, 12), p + Vector2(x * 0.82, 12 - height), stem_color, 3.0)
		var flower_center: Vector2 = p + Vector2(x * 0.82, 12 - height)
		var petal: Color = Color("ff85b8")
		match rng.randi_range(0, 3):
			1: petal = Color("ffcf70")
			2: petal = Color("a9a0ff")
			3: petal = Color("8fdcff")
			_: petal = Color("ff85b8")
		draw_circle(flower_center + Vector2(-5, 0), 5.0, petal.darkened(0.05))
		draw_circle(flower_center + Vector2(5, 0), 5.0, petal)
		draw_circle(flower_center + Vector2(0, -5), 5.0, petal.lightened(0.05))
		draw_circle(flower_center + Vector2(0, 5), 5.0, petal.darkened(0.08))
		draw_circle(flower_center, 3.4, Color("fff0a0"))
	# Dark lower leaves create the sense that characters can pass behind foreground foliage.
	for i: int in 5:
		var leaf_p: Vector2 = p + Vector2(rng.randf_range(-28.0, 28.0), rng.randf_range(0.0, 16.0))
		draw_circle(leaf_p, rng.randf_range(7.0, 12.0), Color(0.16, 0.36, 0.20, 0.90))

func _draw_leaf_canopy(p: Vector2, rng: RandomNumberGenerator) -> void:
	var dark: Color = Color(0.16, 0.34, 0.19, 0.92)
	var mid: Color = Color(0.24, 0.49, 0.25, 0.92)
	var light: Color = Color(0.36, 0.62, 0.31, 0.90)
	for i: int in 9:
		var q: Vector2 = p + Vector2(rng.randf_range(-30.0, 30.0), rng.randf_range(-18.0, 18.0))
		var radius: float = rng.randf_range(10.0, 18.0)
		var canopy_color: Color = dark if i < 3 else mid
		draw_circle(q, radius, canopy_color)
		if i >= 4:
			draw_circle(q + Vector2(-3, -4), radius * 0.48, light)
	if rng.randf() < 0.58:
		for i: int in 4:
			var berry: Vector2 = p + Vector2(rng.randf_range(-25.0, 25.0), rng.randf_range(-14.0, 12.0))
			draw_circle(berry, 2.4, Color("ff709f"))

func _draw_candy_bush(p: Vector2, rng: RandomNumberGenerator) -> void:
	var base: Color = Color(0.24, 0.47, 0.25, 0.92)
	var top: Color = Color(0.34, 0.60, 0.31, 0.94)
	for i: int in 6:
		var q: Vector2 = p + Vector2(rng.randf_range(-25.0, 25.0), rng.randf_range(-10.0, 15.0))
		draw_circle(q, rng.randf_range(11.0, 17.0), base)
		draw_circle(q + Vector2(-2, -4), rng.randf_range(5.0, 8.0), top)
	for i: int in 5:
		var candy_p: Vector2 = p + Vector2(rng.randf_range(-24.0, 24.0), rng.randf_range(-16.0, 10.0))
		var candy_color: Color = Color("ff8bbb") if i % 2 == 0 else Color("ffd770")
		draw_circle(candy_p, 3.0, candy_color)
		draw_line(candy_p + Vector2(-5, 0), candy_p + Vector2(5, 0), candy_color.lightened(0.15), 1.2)
