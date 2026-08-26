class_name WorldTiles
extends RefCounted

const TILE_SIZE: int = 32
const VARIANTS: int = 8

static func create_grass_tileset() -> TileSet:
	var image: Image = Image.create(TILE_SIZE * VARIANTS, TILE_SIZE, false, Image.FORMAT_RGBA8)
	for variant: int in VARIANTS:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = 1337 + variant * 997
		var tile_origin_x: int = variant * TILE_SIZE
		var base_shift: int = (variant % 4) - 2
		var base: Color = Color8(111 + base_shift * 2, 176 + base_shift * 3, 76 + base_shift, 255)
		for y: int in TILE_SIZE:
			for x: int in TILE_SIZE:
				var wave: float = sin(float(x + variant * 7) * 0.23) * 0.5 + cos(float(y - variant * 3) * 0.19) * 0.5
				var lift: int = roundi(wave * 2.0)
				image.set_pixel(tile_origin_x + x, y, Color8(
					clampi(roundi(base.r * 255.0) + lift, 0, 255),
					clampi(roundi(base.g * 255.0) + lift * 2, 0, 255),
					clampi(roundi(base.b * 255.0) + lift, 0, 255),
					255
				))

		# Sparse clusters read like blades/leaves instead of TV noise.
		var cluster_count: int = 4 + variant % 3
		for _cluster: int in cluster_count:
			var cx: int = rng.randi_range(4, TILE_SIZE - 5)
			var cy: int = rng.randi_range(4, TILE_SIZE - 5)
			var dark: Color = Color8(76, 145 + rng.randi_range(-5, 7), 56, 255)
			var light: Color = Color8(145, 198 + rng.randi_range(-4, 8), 84, 255)
			image.set_pixel(tile_origin_x + cx, cy, dark)
			image.set_pixel(tile_origin_x + cx + 1, cy - 1, light)
			if rng.randf() < 0.62:
				image.set_pixel(tile_origin_x + cx - 1, cy + 1, dark)
			if rng.randf() < 0.38:
				image.set_pixel(tile_origin_x + cx + 2, cy, light)

		# A few authored accents, never on every tile.
		if variant == 2 or variant == 6:
			var bx: int = tile_origin_x + (10 if variant == 2 else 23)
			var by: int = 17 if variant == 2 else 9
			image.set_pixel(bx, by, Color8(74, 139, 55))
			image.set_pixel(bx + 1, by - 2, Color8(93, 164, 65))
			image.set_pixel(bx + 2, by - 4, Color8(129, 188, 75))
		if variant == 3:
			_draw_tiny_flower(image, tile_origin_x + 19, 12, Color8(255, 124, 180), Color8(255, 242, 193))
		elif variant == 5:
			_draw_tiny_flower(image, tile_origin_x + 8, 22, Color8(144, 207, 255), Color8(255, 242, 193))
		elif variant == 7:
			_draw_tiny_flower(image, tile_origin_x + 25, 19, Color8(245, 221, 105), Color8(255, 244, 211))

	var texture: ImageTexture = ImageTexture.create_from_image(image)
	var atlas: TileSetAtlasSource = TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for variant: int in VARIANTS:
		atlas.create_tile(Vector2i(variant, 0))
	var tile_set: TileSet = TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tile_set.add_source(atlas, 0)
	return tile_set

static func _draw_tiny_flower(image: Image, x: int, y: int, petal: Color, center: Color) -> void:
	image.set_pixel(x - 1, y, petal)
	image.set_pixel(x + 1, y, petal)
	image.set_pixel(x, y - 1, petal)
	image.set_pixel(x, y + 1, petal)
	image.set_pixel(x, y, center)
