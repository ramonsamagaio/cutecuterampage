class_name WorldTiles
extends RefCounted

const TILE_SIZE := 32
const VARIANTS := 4

static func create_grass_tileset() -> TileSet:
	var image := Image.create(TILE_SIZE * VARIANTS, TILE_SIZE, false, Image.FORMAT_RGBA8)
	var base := Color8(123, 183, 78)
	image.fill(base)
	for variant in VARIANTS:
		var rng := RandomNumberGenerator.new()
		rng.seed = 1337 + variant * 997
		# Details never touch the border, so every base tile remains seamless.
		for i in 30 + variant * 4:
			var x := variant * TILE_SIZE + rng.randi_range(2, TILE_SIZE - 3)
			var y := rng.randi_range(2, TILE_SIZE - 3)
			var c := Color8(104, 165, 67) if rng.randf() < 0.72 else Color8(176, 204, 83)
			image.set_pixel(x, y, c)
			if rng.randf() < 0.18 and x + 1 < (variant + 1) * TILE_SIZE - 2:
				image.set_pixel(x + 1, y, c)
		if variant == 3:
			for i in 3:
				var fx := variant * TILE_SIZE + rng.randi_range(4, TILE_SIZE - 5)
				var fy := rng.randi_range(4, TILE_SIZE - 5)
				image.set_pixel(fx, fy, Color8(255, 117, 171))
				image.set_pixel(fx + 1, fy, Color8(255, 238, 196))
	var texture := ImageTexture.create_from_image(image)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for variant in VARIANTS:
		atlas.create_tile(Vector2i(variant, 0))
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tile_set.add_source(atlas, 0)
	return tile_set
