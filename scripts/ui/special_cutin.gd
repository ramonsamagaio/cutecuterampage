class_name SpecialCutin
extends Control

signal finished

var active := false
var elapsed := 0.0
const DURATION := 0.88
var title_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
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

func _draw() -> void:
	var w := size.x
	var h := size.y
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.02, 0.08, 0.88))
	var center := Vector2(w * 0.5, h * 0.5)
	var panel := Rect2(w * 0.12, h * 0.25, w * 0.76, h * 0.48)
	draw_rect(panel, Color("f04b91"))
	draw_rect(panel.grow(-8), Color("ffb6d2"))
	# Anime action lines, deterministic and chunky.
	for i in 22:
		var a := TAU * float(i) / 22.0
		var start := center + Vector2.RIGHT.rotated(a) * 390.0
		var finish := center + Vector2.RIGHT.rotated(a) * 175.0
		draw_line(start, finish, Color("fff6fa"), 5.0)
	# Pixel-art Taffi face in the middle of the cut-in.
	var pulse := 1.0 + sin(elapsed * 18.0) * 0.035
	var face_center := center + Vector2(-190, -5)
	var face_size := Vector2(220, 170) * pulse
	var face := Rect2(face_center - face_size * 0.5, face_size)
	draw_rect(face, Color("fff7f4"))
	draw_rect(Rect2(face.position + Vector2(25, -105), Vector2(45, 120)), Color("fff7f4"))
	draw_rect(Rect2(face.position + Vector2(145, -105), Vector2(45, 120)), Color("fff7f4"))
	draw_rect(Rect2(face.position + Vector2(38, -80), Vector2(18, 70)), Color("ff8eb6"))
	draw_rect(Rect2(face.position + Vector2(157, -80), Vector2(18, 70)), Color("ff8eb6"))
	draw_rect(Rect2(face.position + Vector2(54, 60), Vector2(24, 28)), Color("17131d"))
	draw_rect(Rect2(face.position + Vector2(142, 60), Vector2(24, 28)), Color("17131d"))
	draw_rect(Rect2(face.position + Vector2(34, 98), Vector2(34, 18)), Color("ff8fb2"))
	draw_rect(Rect2(face.position + Vector2(153, 98), Vector2(34, 18)), Color("ff8fb2"))
	# Bow.
	draw_rect(Rect2(face.position + Vector2(7, 5), Vector2(50, 45)), Color("ff4d95"))
	draw_rect(Rect2(face.position + Vector2(58, 13), Vector2(32, 28)), Color("e93178"))
