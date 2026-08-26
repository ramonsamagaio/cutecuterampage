class_name ArtBodyChunk
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var angular_velocity: float = 0.0
var life: float = 2.0
var landed: bool = false
var art: Sprite2D

func configure(local_origin: Vector2, texture_path: String, target_size: Vector2, force: Vector2) -> void:
	position = local_origin
	velocity = force + Vector2(randf_range(-82.0, 82.0), randf_range(-88.0, 68.0))
	angular_velocity = randf_range(-6.0, 6.0)
	life = randf_range(1.35, 2.25)
	z_as_relative = false
	z_index = 24
	art = Sprite2D.new()
	art.name = "ChunkArt"
	art.centered = true
	art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var texture: Texture2D = CutoutArtPart.load_original_texture(texture_path)
	art.texture = texture
	if texture != null:
		var fit: float = RegisteredTextureMath.fit_scale(texture, target_size)
		art.scale = Vector2.ONE * fit
	add_child(art)
	queue_redraw()

func _process(delta: float) -> void:
	position += velocity * delta
	velocity *= pow(0.12, delta)
	rotation += angular_velocity * delta
	angular_velocity *= pow(0.20, delta)
	life -= delta
	if not landed and velocity.length() < 18.0:
		landed = true
		var blood_parent: Node = get_parent()
		if blood_parent != null and blood_parent.has_method("add_ground_splat"):
			blood_parent.call("add_ground_splat", global_position, randi_range(3, 5), Color("a90e31"))
	if life <= 0.0:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2(-2, 2), 3.0, Color("9d082b"))
	draw_circle(Vector2(2, -1), 2.0, Color("d91c43"))
