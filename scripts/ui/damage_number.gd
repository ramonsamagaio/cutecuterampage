class_name DamageNumber
extends Node2D

var age: float = 0.0
var lifetime: float = 0.72
var velocity: Vector2 = Vector2.ZERO
var label: Label

func configure(world_pos: Vector2, amount: float, critical: bool) -> void:
	global_position = world_pos
	z_as_relative = false
	z_index = 95
	label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.position = Vector2(-34, -16)
	label.size = Vector2(68, 34)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = _format_amount(amount)
	label.add_theme_font_size_override("font_size", 25 if critical else 18)
	label.add_theme_color_override("font_color", Color("fff29a") if critical else Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color("27152d"))
	label.add_theme_constant_override("outline_size", 5 if critical else 3)
	add_child(label)
	velocity = Vector2(randf_range(-18.0, 18.0), -72.0 if critical else -54.0)
	scale = Vector2.ONE * (1.18 if critical else 1.0)

func _process(delta: float) -> void:
	age += delta
	position += velocity * delta
	velocity.y += 58.0 * delta
	var t: float = clampf(age / lifetime, 0.0, 1.0)
	modulate.a = 1.0 - smoothstep(0.58, 1.0, t)
	if age >= lifetime:
		queue_free()

func _format_amount(amount: float) -> String:
	if amount >= 9999.0:
		return "9.9K!"
	if amount >= 1000.0:
		return "%.1fK!" % (amount / 1000.0)
	return "%d%s" % [roundi(amount), "!" if amount >= 20.0 else ""]
