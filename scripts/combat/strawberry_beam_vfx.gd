class_name TaffiStrawberryBeamVFX
extends Node2D

signal finished

const BEAM_SHADER := preload("res://shaders/strawberry_beam.gdshader")
const LIFE := 0.92
const BEAM_LENGTH := 1180.0
const MUZZLE_X := 34.0

var age := 0.0
var direction := Vector2.RIGHT
var _source: Node2D
var _back_glow: Line2D
var _body: Line2D
var _core: Line2D
var _spark_core: Line2D
var _particles: Array[GPUParticles2D] = []

func _ready() -> void:
	z_index = 70
	_build_beam_layers()
	_build_particle_emitters()
	queue_redraw()

func configure(origin: Vector2, fire_direction: Vector2, source_node: Node2D = null) -> void:
	_source = source_node
	global_position = Vector2(roundi(origin.x), roundi(origin.y))
	direction = fire_direction.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	global_rotation = direction.angle()
	for emitter in _particles:
		emitter.restart()
		emitter.emitting = true

func _process(delta: float) -> void:
	if is_instance_valid(_source):
		var source_pos := _source.global_position
		global_position = Vector2(roundi(source_pos.x), roundi(source_pos.y))

	age += delta
	var attack := smoothstep(0.0, 0.075, age)
	var release := 1.0 - smoothstep(LIFE - 0.20, LIFE, age)
	var envelope := attack * release
	var throb := 1.0 + sin(age * 38.0) * 0.045

	_back_glow.width = 112.0 * envelope * throb
	_body.width = 72.0 * envelope * (1.0 + sin(age * 29.0) * 0.035)
	_core.width = 31.0 * envelope
	_spark_core.width = 9.0 * envelope * (1.0 + sin(age * 47.0) * 0.10)

	queue_redraw()
	if age >= LIFE:
		finished.emit()
		queue_free()

func _build_beam_layers() -> void:
	_back_glow = _make_line("BackGlow", 112.0, Color(1.0, 0.10, 0.52, 0.24), 1.65, 1.9)
	_body = _make_line("PinkBody", 72.0, Color(1.0, 0.18, 0.62, 0.78), 2.35, 1.45)
	_core = _make_line("WhiteCore", 31.0, Color(1.0, 0.78, 0.94, 0.92), 3.25, 1.15)
	_spark_core = _make_line("HotCore", 9.0, Color(1.0, 0.98, 1.0, 1.0), 4.2, 0.8)

func _make_line(node_name: String, base_width: float, tint: Color, energy: float, edge_power: float) -> Line2D:
	var line := Line2D.new()
	line.name = node_name
	line.width = base_width
	line.antialiased = false
	line.default_color = Color.WHITE
	line.points = PackedVector2Array([Vector2(MUZZLE_X, 0.0), Vector2(BEAM_LENGTH, 0.0)])
	var material := ShaderMaterial.new()
	material.shader = BEAM_SHADER
	material.set_shader_parameter("beam_tint", tint)
	material.set_shader_parameter("energy", energy)
	material.set_shader_parameter("edge_power", edge_power)
	material.set_shader_parameter("ripple_speed", 21.0 + base_width * 0.07)
	material.set_shader_parameter("ripple_density", 28.0 + base_width * 0.11)
	line.material = material
	add_child(line)
	return line

func _build_particle_emitters() -> void:
	_particles.append(_make_particles("Strawberries", "strawberry", 26, 0.82, 260.0, 520.0, 68.0))
	_particles.append(_make_particles("Hearts", "heart", 34, 0.68, 340.0, 690.0, 82.0))
	_particles.append(_make_particles("Stars", "star", 46, 0.54, 420.0, 820.0, 96.0))

func _make_particles(node_name: String, kind: String, amount: int, lifetime: float, speed_min: float, speed_max: float, vertical_spread: float) -> GPUParticles2D:
	var particles := GPUParticles2D.new()
	particles.name = node_name
	particles.amount = amount
	particles.lifetime = lifetime
	particles.one_shot = true
	particles.explosiveness = 0.72
	particles.randomness = 0.42
	particles.fixed_fps = 30
	particles.interpolate = false
	particles.local_coords = true
	particles.position = Vector2((MUZZLE_X + BEAM_LENGTH) * 0.5, 0.0)
	particles.texture = _make_pixel_texture(kind)
	particles.self_modulate = Color(1.65, 1.15, 1.45, 1.0)

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3((BEAM_LENGTH - MUZZLE_X) * 0.48, vertical_spread, 0.0)
	process.direction = Vector3(1.0, 0.0, 0.0)
	process.spread = 17.0
	process.initial_velocity_min = speed_min
	process.initial_velocity_max = speed_max
	process.gravity = Vector3(0.0, 48.0 if kind == "strawberry" else 0.0, 0.0)
	process.scale_min = 1.0
	process.scale_max = 1.75 if kind == "strawberry" else 1.4
	process.angular_velocity_min = -180.0
	process.angular_velocity_max = 180.0
	particles.process_material = process
	add_child(particles)
	return particles

func _make_pixel_texture(kind: String) -> Texture2D:
	var image := Image.create(11, 11, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	match kind:
		"strawberry": _paint_strawberry(image)
		"star": _paint_star(image)
		_: _paint_heart(image)
	return ImageTexture.create_from_image(image)

func _paint_heart(image: Image) -> void:
	var pink := Color("ff4f98")
	var light := Color("ffb2d0")
	var dark := Color("d72e70")
	for y in range(2, 8):
		for x in range(1, 10):
			var dx := absf(float(x) - 5.0)
			var inside := (y <= 4 and ((x >= 1 and x <= 4) or (x >= 6 and x <= 9))) or (y >= 4 and dx <= float(8 - y))
			if inside:
				image.set_pixel(x, y, pink)
	image.set_pixel(3, 2, light)
	image.set_pixel(7, 2, light)
	image.set_pixel(5, 8, dark)

func _paint_star(image: Image) -> void:
	var yellow := Color("ffd84d")
	var light := Color("fff6b0")
	var orange := Color("f59a32")
	for x in range(2, 9):
		image.set_pixel(x, 5, yellow)
	for y in range(2, 9):
		image.set_pixel(5, y, yellow)
	for p in [Vector2i(3, 3), Vector2i(7, 3), Vector2i(3, 7), Vector2i(7, 7), Vector2i(4, 4), Vector2i(6, 4), Vector2i(4, 6), Vector2i(6, 6)]:
		image.set_pixel(p.x, p.y, yellow)
	image.set_pixel(5, 4, light)
	image.set_pixel(5, 5, light)
	image.set_pixel(5, 8, orange)

func _paint_strawberry(image: Image) -> void:
	var red := Color("f2304f")
	var hot := Color("ff5670")
	var dark := Color("b51339")
	var green := Color("56a83f")
	var seed := Color("ffd65b")
	for y in range(3, 9):
		var half_width := 4 - maxi(0, y - 6)
		for x in range(5 - half_width, 6 + half_width):
			if x >= 0 and x < 11:
				image.set_pixel(x, y, red)
	for p in [Vector2i(3, 2), Vector2i(4, 1), Vector2i(5, 2), Vector2i(6, 1), Vector2i(7, 2)]:
		image.set_pixel(p.x, p.y, green)
	image.set_pixel(4, 4, hot)
	image.set_pixel(4, 5, Color.WHITE)
	for p in [Vector2i(3, 6), Vector2i(6, 5), Vector2i(7, 7), Vector2i(5, 8)]:
		image.set_pixel(p.x, p.y, seed)
	image.set_pixel(5, 9, dark)

func _draw() -> void:
	var envelope := smoothstep(0.0, 0.075, age) * (1.0 - smoothstep(LIFE - 0.20, LIFE, age))
	var ink := Color("28152e")
	var pink := Color("f64c96")
	var hot := Color("d92f76")
	var pale := Color("ffe8f2")
	var red := Color("f03450")
	var green := Color("60ad45")

	# Giant rigid pixel cannon placeholder. Replace with final cannon sprite later.
	draw_rect(Rect2(-104, -25, 137, 50), ink)
	draw_rect(Rect2(-99, -21, 127, 42), pink)
	draw_rect(Rect2(-84, -17, 54, 34), pale)
	draw_rect(Rect2(-24, -20, 17, 40), hot)
	draw_rect(Rect2(0, -23, 30, 46), hot)
	draw_rect(Rect2(-74, 20, 22, 35), ink)
	draw_rect(Rect2(-70, 20, 16, 30), pink)

	# Heart emblem.
	draw_rect(Rect2(-62, -8, 9, 8), red)
	draw_rect(Rect2(-48, -8, 9, 8), red)
	draw_rect(Rect2(-66, -3, 31, 8), red)
	draw_rect(Rect2(-61, 5, 21, 6), red)
	draw_rect(Rect2(-55, 11, 10, 5), red)

	# Strawberry muzzle cap.
	draw_rect(Rect2(16, -16, 15, 31), red)
	draw_rect(Rect2(12, -11, 23, 20), red)
	draw_rect(Rect2(15, -21, 6, 8), green)
	draw_rect(Rect2(22, -22, 6, 9), green)
	draw_rect(Rect2(28, -19, 6, 7), green)

	# Charging muzzle flare, kept chunky and pixel-like before glow.
	var flare := (18.0 + sin(age * 44.0) * 5.0) * envelope
	if flare > 0.5:
		draw_circle(Vector2(MUZZLE_X, 0.0), flare, Color(2.2, 0.35, 1.25, 0.32))
		draw_rect(Rect2(MUZZLE_X - flare - 6.0, -3.0, flare * 2.0 + 12.0, 6.0), Color(2.5, 0.75, 1.8, 0.75))
		draw_rect(Rect2(MUZZLE_X - 3.0, -flare - 6.0, 6.0, flare * 2.0 + 12.0), Color(2.5, 0.75, 1.8, 0.75))
