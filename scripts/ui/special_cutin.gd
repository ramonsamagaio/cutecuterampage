class_name SpecialCutin
extends Control

signal finished

const DURATION: float = 1.18
const REGISTERED_TAFFI_CUTIN_SIZE: Vector2 = Vector2(430.0, 628.0)

var active: bool = false
var elapsed: float = 0.0
var title_label: Label
var subtitle_label: Label
var kicker_label: Label

var _head_texture: Texture2D
var _ear1_texture: Texture2D
var _ear2_texture: Texture2D
var _bow_texture: Texture2D
var _body_texture: Texture2D
var _arm_texture: Texture2D
var _hand_texture: Texture2D
var _cannon_texture: Texture2D
var _font: Font

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_font = ThemeDB.fallback_font

	_head_texture = CutoutArtPart.load_original_texture("res://assets/Taffi/Cabeca.png")
	_ear1_texture = CutoutArtPart.load_original_texture("res://assets/Taffi/Ore1.png")
	_ear2_texture = CutoutArtPart.load_original_texture("res://assets/Taffi/Ore2.png")
	_bow_texture = CutoutArtPart.load_original_texture("res://assets/Taffi/Laco.png")
	_body_texture = CutoutArtPart.load_original_texture("res://assets/Taffi/Corpo.png")
	_arm_texture = CutoutArtPart.load_original_texture("res://assets/Taffi/BraçoDir.png")
	_hand_texture = CutoutArtPart.load_original_texture("res://assets/Taffi/MaoEsq.png")
	_cannon_texture = CutoutArtPart.make_small_texture("res://assets/weapons/arma_waterjet.png", Vector2i(390, 180))

	kicker_label = _make_label("♡ TAFFI SUPER MOVE ♡", 18, Color("ffd0e4"), 3)
	kicker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(kicker_label)

	title_label = _make_label("STRAWBERRY\nOVERDRIVE!!!", 44, Color("fff7fb"), 7)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_shadow_color", Color(0.40, 0.01, 0.18, 0.75))
	title_label.add_theme_constant_override("shadow_offset_x", 5)
	title_label.add_theme_constant_override("shadow_offset_y", 6)
	add_child(title_label)

	subtitle_label = _make_label("LOVE • SUGAR • MAXIMUM FIREPOWER", 15, Color("fff0a9"), 3)
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(subtitle_label)

func _make_label(text_value: String, font_size: int, color: Color, outline: int) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("3a0b2c"))
	label.add_theme_constant_override("outline_size", outline)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func play() -> void:
	if active:
		return
	active = true
	elapsed = 0.0
	visible = true
	modulate = Color.WHITE
	get_tree().paused = true
	_update_labels()
	queue_redraw()

func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	_update_labels()
	queue_redraw()
	if elapsed >= DURATION:
		active = false
		visible = false
		get_tree().paused = false
		finished.emit()

func _update_labels() -> void:
	var w: float = size.x
	var h: float = size.y
	var intro: float = clampf(elapsed / 0.30, 0.0, 1.0)
	var eased: float = _ease_out_cubic(intro)
	var drift: float = maxf(0.0, elapsed - 0.30) * 9.0
	var text_x: float = lerpf(w + 110.0, w * 0.55, eased) - drift
	var alpha: float = minf(1.0, elapsed / 0.12) * (1.0 - smoothstep(DURATION - 0.15, DURATION, elapsed))

	kicker_label.position = Vector2(text_x + 22.0, h * 0.245)
	kicker_label.size = Vector2(w * 0.37, 30)
	kicker_label.modulate.a = alpha

	title_label.position = Vector2(text_x, h * 0.31)
	title_label.size = Vector2(w * 0.43, 145)
	title_label.modulate.a = alpha

	subtitle_label.position = Vector2(text_x + 4.0, h * 0.515)
	subtitle_label.size = Vector2(w * 0.42, 28)
	subtitle_label.modulate.a = alpha

func _ease_out_cubic(t: float) -> float:
	var inv: float = 1.0 - clampf(t, 0.0, 1.0)
	return 1.0 - inv * inv * inv

func _draw_registered_layer(texture: Texture2D, rect: Rect2, tint: Color = Color.WHITE) -> void:
	if texture == null:
		return
	draw_texture_rect(texture, rect, false, tint)

func _draw() -> void:
	if not active:
		return
	var w: float = size.x
	var h: float = size.y
	var intro: float = clampf(elapsed / 0.30, 0.0, 1.0)
	var eased: float = _ease_out_cubic(intro)
	var exit_alpha: float = 1.0 - smoothstep(DURATION - 0.17, DURATION, elapsed)
	var flash: float = 1.0 - smoothstep(0.0, 0.11, elapsed)

	# Transparent cinematic veil. The cut-in is a diagonal slash across gameplay, not a rectangle card.
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.045, 0.008, 0.055, 0.72 * exit_alpha))
	if flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(1.35, 0.72, 1.05, flash * 0.62))

	var band_slide: float = lerpf(-w * 0.72, 0.0, eased)
	var top_y: float = h * 0.18
	var bottom_y: float = h * 0.77
	var band: PackedVector2Array = PackedVector2Array([
		Vector2(-120 + band_slide, top_y + 92),
		Vector2(w * 0.17 + band_slide, top_y - 34),
		Vector2(w + 180 + band_slide, top_y + 18),
		Vector2(w * 0.84 + band_slide, bottom_y + 48),
		Vector2(-80 + band_slide, bottom_y - 6)
	])
	draw_colored_polygon(band, Color(0.72, 0.035, 0.35, 0.94 * exit_alpha))

	var inner: PackedVector2Array = PackedVector2Array([
		Vector2(-90 + band_slide, top_y + 108),
		Vector2(w * 0.19 + band_slide, top_y - 12),
		Vector2(w + 120 + band_slide, top_y + 36),
		Vector2(w * 0.82 + band_slide, bottom_y + 22),
		Vector2(-50 + band_slide, bottom_y - 18)
	])
	draw_colored_polygon(inner, Color(1.0, 0.31, 0.64, 0.79 * exit_alpha))

	for i: int in 3:
		var y_shift: float = float(i) * 9.0
		draw_line(Vector2(-20, top_y + 72 + y_shift), Vector2(w + 40, top_y - 4 + y_shift), Color(1.0, 0.87, 0.94, 0.54 * exit_alpha), 2.0, true)

	var line_scroll: float = fmod(elapsed * 820.0, 150.0)
	for i: int in 24:
		var seed: float = float((i * 71) % 101) / 101.0
		var y: float = h * (0.15 + seed * 0.66)
		var length: float = 74.0 + float((i * 43) % 170)
		var x: float = fmod(float(i) * 91.0 + line_scroll, w + 260.0) - 140.0
		var thickness: float = 1.0 + float(i % 3)
		var c: Color = Color(1.35, 0.77, 1.08, (0.14 + float(i % 4) * 0.035) * exit_alpha)
		draw_line(Vector2(x, y), Vector2(x + length, y - length * 0.08), c, thickness, true)

	for i: int in 10:
		var a: float = float(i) * 0.91 + elapsed * 0.8
		var p: Vector2 = Vector2(w * 0.52, h * 0.48) + Vector2(cos(a) * (250.0 + float(i % 3) * 40.0), sin(a * 1.13) * (150.0 + float(i % 2) * 28.0))
		if i % 2 == 0:
			_draw_spark(p, 5.0 + float(i % 3) * 2.0, Color(1.35, 0.90, 1.10, 0.58 * exit_alpha))
		else:
			_draw_heart(p, 0.56 + float(i % 3) * 0.10, Color(1.0, 0.30, 0.64, 0.40 * exit_alpha))

	var portrait_x: float = lerpf(-w * 0.44, w * 0.285, eased) + maxf(0.0, elapsed - 0.30) * 7.0
	var portrait_y: float = h * 0.56 + sin(elapsed * 2.2) * 2.5
	var pulse: float = 1.0 + sin(elapsed * 7.0) * 0.006
	var registered_size: Vector2 = REGISTERED_TAFFI_CUTIN_SIZE * pulse
	var registered_center: Vector2 = Vector2(portrait_x, portrait_y)
	var registered_rect: Rect2 = Rect2(registered_center - registered_size * 0.5, registered_size)

	var shadow_rect: Rect2 = Rect2(registered_rect.position + Vector2(8, 7), registered_rect.size)
	_draw_registered_layer(_body_texture, shadow_rect, Color(0.18, 0.02, 0.15, 0.40 * exit_alpha))
	_draw_registered_layer(_ear1_texture, shadow_rect, Color(0.18, 0.02, 0.15, 0.40 * exit_alpha))
	_draw_registered_layer(_ear2_texture, shadow_rect, Color(0.18, 0.02, 0.15, 0.40 * exit_alpha))
	_draw_registered_layer(_head_texture, shadow_rect, Color(0.18, 0.02, 0.15, 0.40 * exit_alpha))

	_draw_registered_layer(_body_texture, registered_rect)
	_draw_registered_layer(_ear1_texture, registered_rect)
	_draw_registered_layer(_ear2_texture, registered_rect)
	_draw_registered_layer(_head_texture, registered_rect)
	_draw_registered_layer(_arm_texture, registered_rect)
	_draw_registered_layer(_hand_texture, registered_rect)
	_draw_registered_layer(_bow_texture, registered_rect)

	if _cannon_texture != null:
		var cannon_center: Vector2 = registered_center + Vector2(146, 112)
		var cannon_size: Vector2 = Vector2(360, 166)
		draw_set_transform(cannon_center, -0.055, Vector2.ONE)
		draw_texture_rect(_cannon_texture, Rect2(-cannon_size * 0.5, cannon_size), false, Color(1.08, 1.0, 1.06, exit_alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_draw_muzzle_star(cannon_center + Vector2(168, -11), exit_alpha)

	draw_line(Vector2(w * 0.04, h * 0.79), Vector2(w * 0.96, h * 0.70), Color(1.0, 0.94, 0.98, 0.76 * exit_alpha), 4.0, true)
	draw_line(Vector2(w * 0.10, h * 0.81), Vector2(w * 0.86, h * 0.745), Color(1.0, 0.35, 0.66, 0.76 * exit_alpha), 2.0, true)

func _draw_muzzle_star(p: Vector2, alpha: float) -> void:
	var pulse: float = 0.82 + sin(elapsed * 29.0) * 0.18
	_draw_spark(p, 18.0 * pulse, Color(1.7, 0.93, 1.35, 0.70 * alpha))
	draw_circle(p, 7.0 * pulse, Color(2.0, 0.72, 1.35, 0.32 * alpha))

func _draw_spark(p: Vector2, radius: float, color: Color) -> void:
	draw_line(p + Vector2(-radius, 0), p + Vector2(radius, 0), color, 2.0, true)
	draw_line(p + Vector2(0, -radius), p + Vector2(0, radius), color, 2.0, true)
	draw_circle(p, 2.2, color)

func _draw_heart(p: Vector2, scale_value: float, color: Color) -> void:
	var r: float = 6.0 * scale_value
	draw_circle(p + Vector2(-5, -2) * scale_value, r, color)
	draw_circle(p + Vector2(5, -2) * scale_value, r, color)
	draw_colored_polygon(PackedVector2Array([
		p + Vector2(-11, 0) * scale_value,
		p + Vector2(11, 0) * scale_value,
		p + Vector2(0, 13) * scale_value
	]), color)
