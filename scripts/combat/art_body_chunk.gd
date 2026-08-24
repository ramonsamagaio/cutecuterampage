class_name ArtBodyChunk
extends Node2D

var velocity: Vector2 = Vector2.ZERO
var angular_velocity: float = 0.0
var life: float = 2.6
var landed: bool = false
var art: CutoutArtPart

func configure(local_origin: Vector2, texture_path: String, target_size: Vector2, force: Vector2) -> void:
	position = local_origin
	velocity = force + Vector2(randf_range(-90.0, 90.0), randf_range(-95.0, 75.0))
	angular_velocity = randf_range(-7.0, 7.0)
	life = randf_range(1.8, 3.2)
	z_as_relative = false
	z_index = 24
	art = CutoutArtPart.new()
	art.name = "ChunkArt"
	art.configure(texture_path, target_size, Vector2(0.5, 0.5))
	add_child(art)
	art.add_random_blood_stain(randi_range(1, 3))

func _process(delta: float) -> void:
	position += velocity * delta
	velocity *= pow(0.16, delta)
	rotation += angular_velocity * delta
	angular_velocity *= pow(0.22, delta)
	life -= delta
	if not landed and velocity.length() < 18.0:
		landed = true
		var blood_parent: Node = get_parent()
		if blood_parent != null and blood_parent.has_method("add_ground_splat"):
			blood_parent.call("add_ground_splat", global_position, randi_range(3, 6), Color("a90e31"))
	if life <= 0.0:
		queue_free()
