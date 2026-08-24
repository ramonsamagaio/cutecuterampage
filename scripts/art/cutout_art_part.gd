class_name CutoutArtPart
extends Node2D

static var _texture_cache: Dictionary[String, Texture2D] = {}

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
	var cached_value: Variant = _texture_cache.get(path, null)
	if cached_value is Texture2D:
		return cached_value as Texture2D
	var source_texture: Texture2D = load(path) as Texture2D
	if source_texture != null:
		_texture_cache[path] = source_texture
	return source_texture

# Kept for old call sites. It intentionally does NOT bake, crop or resize anymore.
# `max_size` is ignored; callers that need a display size should scale the node/quad.
static func make_small_texture(path: String, _max_size: Vector2i) -> Texture2D:
	return load_original_texture(path)

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
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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

	# Important: preserve the complete transparent source canvas. This is what keeps
	# all Photoshop-exported body parts registered to each other. Only Sprite2D scale
	# changes; the PNG itself is never cropped or resampled.
	var source_size: Vector2 = original_texture.get_size()
	var fit: float = RegisteredTextureMath.fit_scale(original_texture, target_size)
	sprite.scale = Vector2.ONE * fit

	# Optional anchor adjustment for standalone graphics such as weapons. Character
	# body layers use pivot_fraction = (0.5, 0.5), so their registered canvases remain
	# perfectly superimposed.
	sprite.offset = Vector2(
		(0.5 - pivot_fraction.x) * source_size.x,
		(0.5 - pivot_fraction.y) * source_size.y
	)

func add_blood_stain(local_pos: Vector2 = Vector2.ZERO) -> void:
	blood_stains.append(local_pos)
	if blood_stains.size() > 7:
		blood_stains.pop_front()
	queue_redraw()

func add_random_blood_stain(amount: int = 1) -> void:
	for _i: int in maxi(1, amount):
		var x_limit: float = maxf(2.0, target_size.x * 0.24)
		var y_limit: float = maxf(2.0, target_size.y * 0.24)
		add_blood_stain(Vector2(randf_range(-x_limit, x_limit), randf_range(-y_limit, y_limit)))

func _draw() -> void:
	for stain: Vector2 in blood_stains:
		draw_rect(Rect2(stain - Vector2(1.5, 1.0), Vector2(3.0, 2.0)), Color("b41435"))
		if int(absf(stain.x + stain.y)) % 2 == 0:
			draw_rect(Rect2(stain + Vector2(1.0, 1.0), Vector2(1.5, 1.5)), Color("e32642"))
