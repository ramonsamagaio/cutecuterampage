class_name CuteRadarUI
extends Control

const UPDATE_INTERVAL: float = 0.125
const WORLD_RADIUS: float = 780.0
const MAP_RECT: Rect2 = Rect2(14, 218, 166, 142)

var _player: Node2D
var _game: Node
var _nearby: Array[Node2D] = []
var _chests: Array[Node] = []
var _timer: float = 0.0
var _time: float = 0.0
var _font: Font

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_font = ThemeDB.fallback_font
	call_deferred("_bind")

func _bind() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D
	_game = get_tree().get_first_node_in_group("game")

func _process(delta: float) -> void:
	_time += delta
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = UPDATE_INTERVAL
	if not is_instance_valid(_player) or _game == null:
		_bind()
	if not is_instance_valid(_player) or _game == null:
		return
	_nearby.clear()
	var candidates: Array[Node2D] = _game.call("get_enemies_near", _player.global_position, WORLD_RADIUS) as Array[Node2D]
	var count: int = mini(72, candidates.size())
	for i: int in count:
		var enemy: Node2D = candidates[i]
		if is_instance_valid(enemy):
			_nearby.append(enemy)
	_chests = get_tree().get_nodes_in_group("reward_chest")
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(_player):
		return
	var rect: Rect2 = MAP_RECT
	_draw_pixel_frame(rect)
	var inner: Rect2 = Rect2(rect.position + Vector2(9, 22), rect.size - Vector2(18, 31))

	# Quiet garden grid gives the radar spatial scale without pretending this is a full map system.
	draw_rect(inner, Color("315f37"))
	for i: int in 6:
		var x: float = inner.position.x + inner.size.x * float(i) / 5.0
		draw_line(Vector2(x, inner.position.y), Vector2(x, inner.end.y), Color(0.56, 0.82, 0.51, 0.10), 1.0)
	for i: int in 5:
		var y: float = inner.position.y + inner.size.y * float(i) / 4.0
		draw_line(Vector2(inner.position.x, y), Vector2(inner.end.x, y), Color(0.56, 0.82, 0.51, 0.10), 1.0)

	# A couple of fixed flower flecks keep the display from reading like debug radar.
	for i: int in 10:
		var seed_x: float = float((i * 47 + 13) % 101) / 101.0
		var seed_y: float = float((i * 71 + 9) % 97) / 97.0
		var p: Vector2 = inner.position + Vector2(seed_x * inner.size.x, seed_y * inner.size.y)
		draw_circle(p, 1.3, Color("8dd06a") if i % 2 == 0 else Color("ff9abe"))

	var center: Vector2 = inner.get_center()
	var half: Vector2 = inner.size * 0.46
	for enemy: Node2D in _nearby:
		var offset: Vector2 = (enemy.global_position - _player.global_position) / WORLD_RADIUS
		if absf(offset.x) > 1.0 or absf(offset.y) > 1.0:
			continue
		var p: Vector2 = center + Vector2(offset.x * half.x, offset.y * half.y)
		var is_boss: bool = enemy.is_in_group("boss")
		var is_elite: bool = enemy.is_in_group("elite") or bool(enemy.get("elite"))
		if is_boss:
			draw_circle(p, 4.0, Color("fff08d"))
			draw_circle(p, 2.0, Color("ff4f8f"))
		elif is_elite:
			draw_circle(p, 2.6, Color("ffb15f"))
		else:
			draw_circle(p, 1.8, Color("ff6d9f"))

	for chest_node: Node in _chests:
		if not is_instance_valid(chest_node) or not (chest_node is Node2D):
			continue
		var chest: Node2D = chest_node as Node2D
		var offset: Vector2 = (chest.global_position - _player.global_position) / WORLD_RADIUS
		if absf(offset.x) <= 1.0 and absf(offset.y) <= 1.0:
			var p: Vector2 = center + Vector2(offset.x * half.x, offset.y * half.y)
			_draw_spark(p, 3.5 + sin(_time * 4.0) * 0.7, Color("fff0a0"))

	# Player marker is intentionally the strongest icon.
	draw_circle(center, 4.5, Color("fff2f7"))
	draw_circle(center, 2.7, Color("ff58a0"))
	_draw_heart(center + Vector2(0, -1), 0.34, Color("fff2f7"))

	_draw_text(rect.position + Vector2(10, 16), "SWEET RADAR", 10, Color("ffd0e2"))
	_draw_text(rect.position + Vector2(112, 16), "♡", 11, Color("fff0a0"))
	# tiny corner hotkey badge for the reference-style map cartridge feel
	draw_rect(Rect2(rect.end - Vector2(23, 22), Vector2(15, 14)), Color("fff1f7"))
	draw_rect(Rect2(rect.end - Vector2(21, 20), Vector2(11, 10)), Color("30142d"))
	_draw_text(rect.end - Vector2(19, 11), "M", 8, Color("fff2f7"))

func _draw_pixel_frame(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(5, 6), rect.size), Color(0.02, 0.003, 0.02, 0.58))
	draw_rect(rect, Color("30102c"))
	draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4)), Color("fff1f7"))
	draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), Color("ff76a8"))
	draw_rect(Rect2(rect.position + Vector2(7, 7), rect.size - Vector2(14, 14)), Color("211020"))
	var cut: float = 6.0
	var bite: Color = Color(0.035, 0.006, 0.032, 0.96)
	draw_rect(Rect2(rect.position, Vector2(cut, cut)), bite)
	draw_rect(Rect2(Vector2(rect.end.x - cut, rect.position.y), Vector2(cut, cut)), bite)
	draw_rect(Rect2(Vector2(rect.position.x, rect.end.y - cut), Vector2(cut, cut)), bite)
	draw_rect(Rect2(rect.end - Vector2(cut, cut), Vector2(cut, cut)), bite)

func _draw_text(pos: Vector2, text: String, font_size: int, color: Color) -> void:
	if _font == null:
		return
	draw_string(_font, pos + Vector2(1, 1), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.04, 0.003, 0.03, color.a * 0.85))
	draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw_spark(p: Vector2, radius: float, color: Color) -> void:
	draw_line(p + Vector2(-radius, 0), p + Vector2(radius, 0), color, 1.4, true)
	draw_line(p + Vector2(0, -radius), p + Vector2(0, radius), color, 1.4, true)

func _draw_heart(p: Vector2, s: float, color: Color) -> void:
	var r: float = 4.0 * s
	draw_circle(p + Vector2(-3, -1) * s, r, color)
	draw_circle(p + Vector2(3, -1) * s, r, color)
	draw_colored_polygon(PackedVector2Array([p + Vector2(-6, 0) * s, p + Vector2(6, 0) * s, p + Vector2(0, 7) * s]), color)
