class_name RegisteredTextureMath
extends RefCounted

static func fit_scale(texture: Texture2D, target_size: Vector2) -> float:
	if texture == null:
		return 1.0
	var source_size: Vector2 = texture.get_size()
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return 1.0
	return minf(target_size.x / source_size.x, target_size.y / source_size.y)
