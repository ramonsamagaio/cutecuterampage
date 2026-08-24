class_name SpecialCutin
extends Control

signal finished

const DURATION: float = 0.88

var active: bool = false
var elapsed: float = 0.0
var title_label: Label
var _head_texture: Texture2D
var _ear1_texture: Texture2D
var _ear2_texture: Texture2D
var _bow_texture: Texture2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_head_texture = CutoutArtPart.make_small_texture("res://assets/Taffi/Cabeca.png", Vector2i(230, 190))
	_ear1_texture = CutoutArtPart.make_small_texture("res://assets/Taffi/Ore1.png", Vector2i(72, 155))
	_ear2_texture = CutoutArtPart.make_small_texture("res://assets/Taffi/Ore2.png", Vector2i(72, 155))
	_bow_texture = CutoutArtPart.make_small_texture("res://assets/Taffi/Laco.png", Vector2i(105, 82))
	title_label = Label.new()
	title_label.text = "TAFFI ♡ STRAWBERRY OVERDRIVE!"
	title_label.position = Vector2(515, 458)
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color("fff4fb"))
	add_child(title_label)

func play() -> void:
	if active:
		return
	active = true
	elapsed = 0.0
	visible = true
	get_tree().paused = true
	queue_redraw()

func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	queue_redraw()
	if elapsed >= DURATION:
		active = false
		visible = false
		get_tree().paused = false
		finished.emit()

func _draw_texture_centered(texture: Texture2D, center: Vector2, scale_factor: float = 1.0) -> void:
	if texture == null:
		return
	var draw_size: Vector2 = texture.get_size() * scale_factor
	draw_texture_rect(texture, Rect2(center - draw_size * 0.5, draw_size), false)

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.02, 0.08, 0.88))
	var center: Vector2 = Vector2(w * 0.5, h * 0.5)
	var panel: Rect2 = Rect2(w * 0.12, h * 0.25, w * 0.76, h * 0.48)
	draw_rect(panel, Color("f04b91"))
	draw_rect(panel.grow(-8), Color("ffb6d2"))
	for i: int in 22:
		var a: float = TAU * float(i) / 22.0
		var start: Vector2 = center + Vector2.RIGHT.rotated(a) * 390.0
		var finish: Vector2 = center + Vector2.RIGHT.rotated(a) * 175.0
		draw_line(start, finish, Color("fff6fa"), 5.0)
	var pulse: float = 1.0 + sin(elapsed * 18.0) * 0.035
	var face_center: Vector2 = center + Vector2(-190, 0)
	_draw_texture_centered(_ear1_texture, face_center + Vector2(-55, -126), pulse)
	_draw_texture_centered(_ear2_texture, face_center + Vector2(55, -126), pulse)
	_draw_texture_centered(_head_texture, face_center + Vector2(0, 0), pulse)
	_draw_texture_centered(_bow_texture, face_center + Vector2(-76, -76), pulse)
