class_name WorldTiles
extends RefCounted

const TILE_SIZE: int = 32
const VARIANTS: int = 4

static func create_grass_tileset() -> TileSet:
	var image: Image = Image.create(TILE_SIZE * VARIANTS, TILE_SIZE, false, Image.FORMAT_RGBA8)
	var base: Color = Color8(112, 176, 76)
	image.fill(base)
	for variant: int in VARIANTS:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = 1337 + variant * 997
		# Keep the seamless grass calm. The concept gets density from authored-looking
		# flowers/props, not uniform TV-static noise across every tile.
		var detail_count: int = 7 + variant * 2
		for _i: int in detail_count:
			var x: int = variant * TILE_SIZE + rng.randi_range(3, TILE_SIZE - 4)
			var y: int = rng.randi_range(3, TILE_SIZE - 4)
			var c: Color = Color8(94, 157, 63) if rng.randf() < 0.68 else Color8(151, 196, 80)
			image.set_pixel(x, y, c)
			if rng.randf() < 0.42 and x + 1 < (variant + 1) * TILE_SIZE - 3:
				image.set_pixel(x + 1, y, c)
		if variant == 2:
			var blade_x: int = variant * TILE_SIZE + 11
			image.set_pixel(blade_x, 17, Color8(82, 148, 57))
			image.set_pixel(blade_x + 1, 16, Color8(82, 148, 57))
		if variant == 3:
			var fx: int = variant * TILE_SIZE + 19
			var fy: int = 12
			image.set_pixel(fx - 1, fy, Color8(255, 120, 176))
			image.set_pixel(fx + 1, fy, Color8(255, 120, 176))
			image.set_pixel(fx, fy - 1, Color8(255, 233, 195))
			image.set_pixel(fx, fy, Color8(255, 246, 216))
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
