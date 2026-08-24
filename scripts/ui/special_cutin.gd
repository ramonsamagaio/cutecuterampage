class_name SpecialCutin
extends Control

signal finished

const DURATION: float = 0.88
const REGISTERED_TAFFI_CUTIN_SIZE: Vector2 = Vector2(300.0, 439.0)

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
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_head_texture = CutoutArtPart.load_original_texture("res://assets/Taffi/Cabeca.png")
	_ear1_texture = CutoutArtPart.load_original_texture("res://assets/Taffi/Ore1.png")
	_ear2_texture = CutoutArtPart.load_original_texture("res://assets/Taffi/Ore2.png")
	_bow_texture = CutoutArtPart.load_original_texture("res://assets/Taffi/Laco.png")
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

func _draw_registered_layer(texture: Texture2D, rect: Rect2) -> void:
	if texture == null:
		return
	draw_texture_rect(texture, rect, false)

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

	# Taffi's exported parts share the exact same 728x1066 registration canvas.
	# Draw every layer into the same destination rect, preserving the Photoshop fit.
	var pulse: float = 1.0 + sin(elapsed * 18.0) * 0.035
	var registered_size: Vector2 = REGISTERED_TAFFI_CUTIN_SIZE * pulse
	var registered_center: Vector2 = center + Vector2(-190.0, 105.0)
	var registered_rect: Rect2 = Rect2(registered_center - registered_size * 0.5, registered_size)
	_draw_registered_layer(_ear1_texture, registered_rect)
	_draw_registered_layer(_ear2_texture, registered_rect)
	_draw_registered_layer(_head_texture, registered_rect)
	_draw_registered_layer(_bow_texture, registered_rect)
