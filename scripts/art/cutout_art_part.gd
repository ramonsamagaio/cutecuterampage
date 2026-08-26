class_name CutoutArtPart
extends Node2D

static var _original_cache: Dictionary[String, Texture2D] = {}
static var _standalone_cache: Dictionary[String, Texture2D] = {}

@export_file("*.png") var texture_path: String = ""
@export var target_size: Vector2 = Vector2(32.0, 32.0)
@export var pivot_fraction: Vector2 = Vector2(0.5, 0.5)
@export var art_modulate: Color = Color.WHITE
@export var art_z_index: int = 0

var sprite: Sprite2D
var blood_stains: Array[Vector2] = []

static func load_original_texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var cached_value: Variant = _original_cache.get(path, null)
	if cached_value is Texture2D:
		return cached_value as Texture2D
	var source_texture: Texture2D = load(path) as Texture2D
	if source_texture != null:
		_original_cache[path] = source_texture
	return source_texture

# Standalone art is baked once and cached. Lanczos keeps the supplied illustration
# clean when reduced for HUD/projectiles, instead of creating the crunchy AI/pixel read.
static func make_small_texture(path: String, max_size: Vector2i) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var safe_size: Vector2i = Vector2i(maxi(1, max_size.x), maxi(1, max_size.y))
	var cache_key: String = "%s@%dx%d" % [path, safe_size.x, safe_size.y]
	var cached_value: Variant = _standalone_cache.get(cache_key, null)
	if cached_value is Texture2D:
		return cached_value as Texture2D
	var source_texture: Texture2D = load_original_texture(path)
	if source_texture == null:
		return null
	var source_image: Image = source_texture.get_image()
	if source_image == null or source_image.is_empty():
		return source_texture
	var used_rect: Rect2i = source_image.get_used_rect()
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		return source_texture
	var cropped: Image = source_image.get_region(used_rect)
	var ratio_x: float = float(safe_size.x) / float(maxi(1, cropped.get_width()))
	var ratio_y: float = float(safe_size.y) / float(maxi(1, cropped.get_height()))
	var ratio: float = minf(ratio_x, ratio_y)
	var baked_width: int = maxi(1, roundi(float(cropped.get_width()) * ratio))
	var baked_height: int = maxi(1, roundi(float(cropped.get_height()) * ratio))
	cropped.resize(baked_width, baked_height, Image.INTERPOLATE_LANCZOS)
	var baked_texture: ImageTexture = ImageTexture.create_from_image(cropped)
	_standalone_cache[cache_key] = baked_texture
	return baked_texture

func _ready() -> void:
	_rebuild()

func configure(path: String, size: Vector2, pivot: Vector2 = Vector2(0.5, 0.5), tint: Color = Color.WHITE) -> void:
	texture_path = path
	target_size = size
	pivot_fraction = pivot
	art_modulate = tint
	if is_inside_tree():
		_rebuild()

func _ensure_sprite() -> void:
	if sprite != null and is_instance_valid(sprite):
		return
	sprite = Sprite2D.new()
	sprite.name = "Art"
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(sprite)

func _rebuild() -> void:
	_ensure_sprite()
	var original_texture: Texture2D = load_original_texture(texture_path)
	sprite.texture = original_texture
	sprite.modulate = art_modulate
	sprite.z_index = art_z_index
	if original_texture == null:
		sprite.visible = false
		return
	sprite.visible = true

	# Registered body-part PNGs keep their complete transparent canvas. Every part is
	# scaled by the same full-canvas factor so Photoshop registration survives.
	var source_size: Vector2 = original_texture.get_size()
	var fit: float = RegisteredTextureMath.fit_scale(original_texture, target_size)
	sprite.scale = Vector2.ONE * fit
	sprite.offset = Vector2(
		(0.5 - pivot_fraction.x) * source_size.x,
		(0.5 - pivot_fraction.y) * source_size.y
	)

func add_blood_stain(local_pos: Vector2 = Vector2.ZERO) -> void:
	blood_stains.append(local_pos)
	if blood_stains.size() > 8:
		blood_stains.pop_front()
	queue_redraw()

func add_random_blood_stain(amount: int = 1) -> void:
	for _i: int in maxi(1, amount):
		var x_limit: float = maxf(2.0, target_size.x * 0.24)
		var y_limit: float = maxf(2.0, target_size.y * 0.24)
		add_blood_stain(Vector2(randf_range(-x_limit, x_limit), randf_range(-y_limit, y_limit)))

func _draw() -> void:
	for stain: Vector2 in blood_stains:
		draw_circle(stain, 2.2, Color("9e092c"))
		draw_circle(stain + Vector2(1.2, 1.0), 1.2, Color("e32642"))
