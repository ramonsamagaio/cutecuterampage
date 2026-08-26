class_name TaffiStrawberryBeamVFX
extends Node2D

signal finished
signal damage_tick(origin: Vector2, direction: Vector2)
signal aim_changed(direction: Vector2)

const BEAM_SHADER: Shader = preload("res://shaders/strawberry_beam.gdshader")
const LIFE: float = 4.25
const BEAM_LENGTH: float = 1180.0
const MUZZLE_X: float = 42.0
const DAMAGE_TICK_INTERVAL: float = 0.085
const DRAW_INTERVAL: float = 1.0 / 30.0

var age: float = 0.0
var direction: Vector2 = Vector2.RIGHT
var _source: Node2D
var _outer_bloom: Line2D
var _ribbon_aura: Line2D
var _body: Line2D
var _core: Line2D
var _hot_core: Line2D
var _cannon_art: CutoutArtPart
var _particles: Array[GPUParticles2D] = []
var _damage_timer: float = 0.0
var _draw_timer: float = 0.0

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
	_draw_timer -= delta

	var attack: float = smoothstep(0.0, 0.10, age)
	var release: float = 1.0 - smoothstep(LIFE - 0.28, LIFE, age)
	var envelope: float = attack * release
	var throb_a: float = 1.0 + sin(age * 22.0) * 0.040
	var throb_b: float = 1.0 + sin(age * 39.0 + 0.7) * 0.028

	_outer_bloom.width = 154.0 * envelope * throb_a
	_ribbon_aura.width = 106.0 * envelope * throb_b
	_body.width = 72.0 * envelope * (1.0 + sin(age * 29.0) * 0.026)
	_core.width = 34.0 * envelope
	_hot_core.width = 10.0 * envelope * (1.0 + sin(age * 51.0) * 0.08)

	if age >= 0.065:
		while _damage_timer <= 0.0:
			damage_tick.emit(global_position, direction)
			_damage_timer += DAMAGE_TICK_INTERVAL

	if _draw_timer <= 0.0:
		_draw_timer = DRAW_INTERVAL
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
	var turn_weight: float = minf(1.0, delta * 11.5)
	var next_angle: float = lerp_angle(current_angle, desired_angle, turn_weight)
	direction = Vector2.RIGHT.rotated(next_angle)
	global_rotation = next_angle
	aim_changed.emit(direction)

func _build_cannon_art() -> void:
	_cannon_art = CutoutArtPart.new()
	_cannon_art.name = "StrawberryCannonArt"
	_cannon_art.art_z_index = 6
	_cannon_art.configure("res://assets/weapons/arma_waterjet.png", Vector2(142, 72), Vector2(0.72, 0.50))
	_cannon_art.position = Vector2(22, 0)
	add_child(_cannon_art)

func _build_beam_layers() -> void:
	_outer_bloom = _make_line("OuterBloom", 154.0, Color(1.0, 0.04, 0.45, 0.15), 1.18, 1.25, 0.15, 0.44, 0.05, 0.2)
	_ribbon_aura = _make_line("RibbonAura", 106.0, Color(1.0, 0.13, 0.58, 0.32), 1.55, 1.45, 0.12, 0.56, 0.08, 1.1)
	_body = _make_line("PinkBody", 72.0, Color(1.0, 0.20, 0.64, 0.78), 2.35, 1.70, 0.085, 0.35, 0.11, 2.0)
	_core = _make_line("WhiteCore", 34.0, Color(1.0, 0.78, 0.95, 0.95), 3.15, 2.20, 0.045, 0.20, 0.15, 2.8)
	_hot_core = _make_line("HotCore", 10.0, Color(1.0, 0.98, 1.0, 1.0), 4.6, 3.0, 0.02, 0.10, 0.22, 4.0)

func _make_line(node_name: String, base_width: float, tint: Color, energy: float, edge_power: float, wave_strength: float, strand_strength: float, sparkle_strength: float, phase: float) -> Line2D:
	var line: Line2D = Line2D.new()
	line.name = node_name
	line.width = base_width
	line.antialiased = true
	line.default_color = Color.WHITE
	line.points = PackedVector2Array([Vector2(MUZZLE_X, 0.0), Vector2(BEAM_LENGTH, 0.0)])
	var beam_material: ShaderMaterial = ShaderMaterial.new()
	beam_material.shader = BEAM_SHADER
	beam_material.set_shader_parameter("beam_tint", tint)
	beam_material.set_shader_parameter("energy", energy)
	beam_material.set_shader_parameter("edge_power", edge_power)
	beam_material.set_shader_parameter("ripple_speed", 17.0 + base_width * 0.08)
	beam_material.set_shader_parameter("ripple_density", 26.0 + base_width * 0.12)
	beam_material.set_shader_parameter("wave_strength", wave_strength)
	beam_material.set_shader_parameter("strand_strength", strand_strength)
	beam_material.set_shader_parameter("sparkle_strength", sparkle_strength)
	beam_material.set_shader_parameter("phase", phase)
	beam_material.set_shader_parameter("flow_speed", 3.4 + phase * 0.28)
	line.material = beam_material
	add_child(line)
	return line

func _build_particle_emitters() -> void:
	# Three GPU emitters replace the previous five. Fewer particles, larger/readable shapes.
	_particles.append(_make_particles("Hearts", "res://assets/fx/CoracaoRosaCheio.png", Vector2(15, 15), 24, 0.72, 290.0, 610.0, 70.0, 0.0))
	_particles.append(_make_particles("Stars", "res://assets/fx/Estrela.png", Vector2(12, 12), 32, 0.56, 390.0, 800.0, 88.0, 0.0))
	_particles.append(_make_particles("StrawberrySparks", "res://assets/fx/MorangoHaf.png", Vector2(13, 13), 22, 0.70, 300.0, 670.0, 82.0, 26.0))

func _make_particles(node_name: String, texture_path: String, display_size: Vector2, amount: int, lifetime: float, speed_min: float, speed_max: float, vertical_spread: float, gravity_y: float) -> GPUParticles2D:
	var particles: GPUParticles2D = GPUParticles2D.new()
	particles.name = node_name
	particles.amount = amount
	particles.lifetime = lifetime
	particles.one_shot = false
	particles.explosiveness = 0.08
	particles.randomness = 0.52
	particles.fixed_fps = 30
	particles.interpolate = true
	particles.local_coords = true
	particles.position = Vector2((MUZZLE_X + BEAM_LENGTH) * 0.5, 0.0)
	var original_texture: Texture2D = CutoutArtPart.load_original_texture(texture_path)
	particles.texture = original_texture
	particles.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	particles.self_modulate = Color(1.35, 1.08, 1.25, 0.92)
	var process_material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3((BEAM_LENGTH - MUZZLE_X) * 0.48, vertical_spread, 0.0)
	process_material.direction = Vector3(1.0, 0.0, 0.0)
	process_material.spread = 19.0
	process_material.initial_velocity_min = speed_min
	process_material.initial_velocity_max = speed_max
	process_material.gravity = Vector3(0.0, gravity_y, 0.0)
	var texture_fit: float = RegisteredTextureMath.fit_scale(original_texture, display_size)
	process_material.scale_min = texture_fit * 0.75
	process_material.scale_max = texture_fit * 1.42
	process_material.angular_velocity_min = -170.0
	process_material.angular_velocity_max = 170.0
	particles.process_material = process_material
	add_child(particles)
	return particles

func _draw() -> void:
	var envelope: float = smoothstep(0.0, 0.10, age) * (1.0 - smoothstep(LIFE - 0.28, LIFE, age))
	if envelope <= 0.001:
		return

	var pulse: float = 0.5 + sin(age * 33.0) * 0.5
	var flare: float = (26.0 + pulse * 9.0) * envelope
	var muzzle: Vector2 = Vector2(MUZZLE_X, 0.0)

	# Muzzle volume: concentric HDR discs + star flare + contracting charge rings.
	draw_circle(muzzle, flare * 1.65, Color(1.9, 0.16, 0.92, 0.10 * envelope))
	draw_circle(muzzle, flare, Color(2.2, 0.38, 1.28, 0.24 * envelope))
	draw_circle(muzzle, flare * 0.44, Color(2.7, 1.05, 2.0, 0.60 * envelope))
	draw_line(muzzle + Vector2(-flare * 1.7, 0), muzzle + Vector2(flare * 1.7, 0), Color(2.8, 1.1, 2.1, 0.62 * envelope), 4.0, true)
	draw_line(muzzle + Vector2(0, -flare * 1.35), muzzle + Vector2(0, flare * 1.35), Color(2.8, 1.1, 2.1, 0.48 * envelope), 3.0, true)
	for ring_i: int in 3:
		var ring_phase: float = fmod(age * (1.5 + float(ring_i) * 0.18) + float(ring_i) * 0.31, 1.0)
		var radius: float = lerpf(18.0, 66.0, ring_phase)
		var alpha: float = (1.0 - ring_phase) * 0.30 * envelope
		draw_arc(muzzle, radius, 0.0, TAU, 34, Color(1.7, 0.45, 1.08, alpha), 2.0, true)

	# Procedural energy motes travel along the beam. One CanvasItem, zero spawned nodes.
	for i: int in 18:
		var travel: float = fmod(age * (260.0 + float(i % 4) * 32.0) + float(i) * 79.0, BEAM_LENGTH - MUZZLE_X - 24.0)
		var x: float = MUZZLE_X + 18.0 + travel
		var wave: float = sin(age * (5.0 + float(i % 3)) + float(i) * 1.73 + x * 0.018)
		var y: float = wave * (24.0 + float(i % 5) * 7.0)
		var p: Vector2 = Vector2(x, y)
		var streak: float = 9.0 + float(i % 4) * 5.0
		var c: Color = Color(1.7, 0.65 + float(i % 2) * 0.18, 1.35, (0.24 + float(i % 3) * 0.07) * envelope)
		draw_line(p - Vector2(streak, 0), p + Vector2(streak * 0.35, 0), c, 1.5 + float(i % 2), true)
		if i % 4 == 0:
			draw_circle(p, 2.4, Color(2.0, 1.0, 1.6, 0.60 * envelope))

	# Endpoint corona makes the beam read as a volume instead of a line disappearing into nowhere.
	var tip: Vector2 = Vector2(BEAM_LENGTH - 8.0, 0.0)
	var tip_pulse: float = 24.0 + sin(age * 27.0) * 5.0
	draw_circle(tip, tip_pulse * 2.2, Color(1.8, 0.10, 0.72, 0.07 * envelope))
	draw_circle(tip, tip_pulse, Color(2.1, 0.48, 1.25, 0.18 * envelope))
	draw_line(tip + Vector2(-tip_pulse * 1.5, 0), tip + Vector2(tip_pulse * 1.5, 0), Color(2.4, 1.0, 1.8, 0.42 * envelope), 3.0, true)
	draw_line(tip + Vector2(0, -tip_pulse), tip + Vector2(0, tip_pulse), Color(2.4, 1.0, 1.8, 0.34 * envelope), 2.0, true)
