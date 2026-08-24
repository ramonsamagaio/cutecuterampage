class_name TaffiStrawberryBeamVFX
extends Node2D

signal finished
signal damage_tick(origin: Vector2, direction: Vector2)
signal aim_changed(direction: Vector2)

const BEAM_SHADER: Shader = preload("res://shaders/strawberry_beam.gdshader")
const LIFE: float = 4.25
const BEAM_LENGTH: float = 1180.0
const MUZZLE_X: float = 34.0
const DAMAGE_TICK_INTERVAL: float = 0.075

var age: float = 0.0
var direction: Vector2 = Vector2.RIGHT
var _source: Node2D
var _back_glow: Line2D
var _body: Line2D
var _core: Line2D
var _spark_core: Line2D
var _cannon_art: CutoutArtPart
var _particles: Array[GPUParticles2D] = []
var _damage_timer: float = 0.0

func _ready() -> void:
	z_index = 70
	_build_cannon_art()
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
	for emitter: GPUParticles2D in _particles:
		emitter.restart()
		emitter.emitting = true

func _process(delta: float) -> void:
	if is_instance_valid(_source):
		var source_pos: Vector2 = _source.global_position
		global_position = Vector2(roundi(source_pos.x), roundi(source_pos.y))
	_update_mouse_aim(delta)
	age += delta
	_damage_timer -= delta
	var attack: float = smoothstep(0.0, 0.075, age)
	var release: float = 1.0 - smoothstep(LIFE - 0.24, LIFE, age)
	var envelope: float = attack * release
	var throb: float = 1.0 + sin(age * 38.0) * 0.045
	_back_glow.width = 112.0 * envelope * throb
	_body.width = 72.0 * envelope * (1.0 + sin(age * 29.0) * 0.035)
	_core.width = 31.0 * envelope
	_spark_core.width = 9.0 * envelope * (1.0 + sin(age * 47.0) * 0.10)
	if age >= 0.055:
		while _damage_timer <= 0.0:
			damage_tick.emit(global_position, direction)
			_damage_timer += DAMAGE_TICK_INTERVAL
	queue_redraw()
	if age >= LIFE:
		for emitter: GPUParticles2D in _particles:
			emitter.emitting = false
		finished.emit()
		queue_free()

func _update_mouse_aim(delta: float) -> void:
	var mouse_world: Vector2 = get_global_mouse_position()
	var desired: Vector2 = global_position.direction_to(mouse_world)
	if desired == Vector2.ZERO:
		return
	var current_angle: float = direction.angle()
	var desired_angle: float = desired.angle()
	var turn_weight: float = minf(1.0, delta * 13.5)
	var next_angle: float = lerp_angle(current_angle, desired_angle, turn_weight)
	direction = Vector2.RIGHT.rotated(next_angle)
	global_rotation = next_angle
	aim_changed.emit(direction)

func _build_cannon_art() -> void:
	_cannon_art = CutoutArtPart.new()
	_cannon_art.name = "StrawberryCannonArt"
	_cannon_art.art_z_index = 6
	_cannon_art.configure("res://assets/weapons/arma_waterjet.png", Vector2(116, 58), Vector2(0.77, 0.5))
	add_child(_cannon_art)

func _build_beam_layers() -> void:
	_back_glow = _make_line("BackGlow", 112.0, Color(1.0, 0.10, 0.52, 0.24), 1.65, 1.9)
	_body = _make_line("PinkBody", 72.0, Color(1.0, 0.18, 0.62, 0.78), 2.35, 1.45)
	_core = _make_line("WhiteCore", 31.0, Color(1.0, 0.78, 0.94, 0.92), 3.25, 1.15)
	_spark_core = _make_line("HotCore", 9.0, Color(1.0, 0.98, 1.0, 1.0), 4.2, 0.8)

func _make_line(node_name: String, base_width: float, tint: Color, energy: float, edge_power: float) -> Line2D:
	var line: Line2D = Line2D.new()
	line.name = node_name
	line.width = base_width
	line.antialiased = false
	line.default_color = Color.WHITE
	line.points = PackedVector2Array([Vector2(MUZZLE_X, 0.0), Vector2(BEAM_LENGTH, 0.0)])
	var beam_material: ShaderMaterial = ShaderMaterial.new()
	beam_material.shader = BEAM_SHADER
	beam_material.set_shader_parameter("beam_tint", tint)
	beam_material.set_shader_parameter("energy", energy)
	beam_material.set_shader_parameter("edge_power", edge_power)
	beam_material.set_shader_parameter("ripple_speed", 21.0 + base_width * 0.07)
	beam_material.set_shader_parameter("ripple_density", 28.0 + base_width * 0.11)
	line.material = beam_material
	add_child(line)
	return line

func _build_particle_emitters() -> void:
	_particles.append(_make_particles("Strawberries", "res://assets/fx/MorangoFull.png", Vector2(16, 16), 34, 0.82, 260.0, 520.0, 68.0, 48.0))
	_particles.append(_make_particles("StrawberrySlices", "res://assets/fx/MorangoHaf.png", Vector2(12, 12), 22, 0.68, 320.0, 650.0, 76.0, 18.0))
	_particles.append(_make_particles("Hearts", "res://assets/fx/CoracaoRosaCheio.png", Vector2(12, 12), 46, 0.68, 340.0, 690.0, 82.0, 0.0))
	_particles.append(_make_particles("Stars", "res://assets/fx/Estrela.png", Vector2(10, 10), 58, 0.54, 420.0, 820.0, 96.0, 0.0))
	_particles.append(_make_particles("PinkSparkles", "res://assets/fx/BrilhoRosa.png", Vector2(9, 9), 36, 0.42, 450.0, 900.0, 105.0, 0.0))

func _make_particles(node_name: String, texture_path: String, display_size: Vector2, amount: int, lifetime: float, speed_min: float, speed_max: float, vertical_spread: float, gravity_y: float) -> GPUParticles2D:
	var particles: GPUParticles2D = GPUParticles2D.new()
	particles.name = node_name
	particles.amount = amount
	particles.lifetime = lifetime
	particles.one_shot = false
	particles.explosiveness = 0.12
	particles.randomness = 0.46
	particles.fixed_fps = 30
	particles.interpolate = false
	particles.local_coords = true
	particles.position = Vector2((MUZZLE_X + BEAM_LENGTH) * 0.5, 0.0)
	var original_texture: Texture2D = CutoutArtPart.load_original_texture(texture_path)
	particles.texture = original_texture
	particles.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	particles.self_modulate = Color(1.65, 1.15, 1.45, 1.0)
	var process_material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3((BEAM_LENGTH - MUZZLE_X) * 0.48, vertical_spread, 0.0)
	process_material.direction = Vector3(1.0, 0.0, 0.0)
	process_material.spread = 17.0
	process_material.initial_velocity_min = speed_min
	process_material.initial_velocity_max = speed_max
	process_material.gravity = Vector3(0.0, gravity_y, 0.0)
	var texture_fit: float = RegisteredTextureMath.fit_scale(original_texture, display_size)
	process_material.scale_min = texture_fit * 0.8
	process_material.scale_max = texture_fit * 1.5
	process_material.angular_velocity_min = -180.0
	process_material.angular_velocity_max = 180.0
	particles.process_material = process_material
	add_child(particles)
	return particles

func _draw() -> void:
	var envelope: float = smoothstep(0.0, 0.075, age) * (1.0 - smoothstep(LIFE - 0.24, LIFE, age))
	var flare: float = (18.0 + sin(age * 44.0) * 5.0) * envelope
	if flare > 0.5:
		draw_circle(Vector2(MUZZLE_X, 0.0), flare, Color(2.2, 0.35, 1.25, 0.32))
		draw_rect(Rect2(MUZZLE_X - flare - 6.0, -3.0, flare * 2.0 + 12.0, 6.0), Color(2.5, 0.75, 1.8, 0.75))
		draw_rect(Rect2(MUZZLE_X - 3.0, -flare - 6.0, 6.0, flare * 2.0 + 12.0), Color(2.5, 0.75, 1.8, 0.75))
