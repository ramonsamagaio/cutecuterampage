class_name PixelPart
extends Node2D

@export var part_kind: String = "head"
var blood_stains: Array[Vector2i] = []

const INK := Color("24152d")
const WHITE := Color("fff6f4")
const SHADOW := Color("ead6d8")
const PINK := Color("ff5f9f")
const HOT_PINK := Color("e92f7b")
const BLUSH := Color("ff91b4")
const YELLOW := Color("ffd95a")
const ORANGE := Color("f08a45")
const RED := Color("b41435")
const MINT := Color("74e4c3")

func add_blood_stain(local_pixel: Vector2i) -> void:
	blood_stains.append(local_pixel)
	if blood_stains.size() > 6:
		blood_stains.pop_front()
	queue_redraw()

func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(Rect2(x, y, w, h), color)

func _draw() -> void:
	match part_kind:
		"head": _draw_head()
		"ear_l", "ear_r": _draw_ear()
		"bow": _draw_bow()
		"torso": _draw_torso()
		"arm_back", "arm_weapon": _draw_arm()
		"leg": _draw_leg()
		"weapon_blaster": _draw_weapon()
		"chick_head": _draw_chick_head()
		"chick_body": _draw_chick_body()
		"chick_feet": _draw_chick_feet()
		"pig_head": _draw_pig_head()
		"pig_body": _draw_pig_body()
		"pig_feet": _draw_pig_feet()
	for stain in blood_stains:
		_px(stain.x, stain.y, 2, 2, RED)
		if (stain.x + stain.y) % 2 == 0:
			_px(stain.x + 2, stain.y + 1, 1, 1, Color("e32642"))

func _draw_head() -> void:
	_px(-6, -5, 12, 8, INK)
	_px(-5, -7, 10, 12, INK)
	_px(-5, -6, 10, 10, WHITE)
	_px(-6, -3, 12, 6, WHITE)
	_px(-3, -1, 2, 2, Color("17131d"))
	_px(2, -1, 2, 2, Color("17131d"))
	_px(-2, 2, 2, 1, BLUSH)
	_px(2, 2, 2, 1, BLUSH)
	_px(0, 1, 1, 1, HOT_PINK)
	_px(-1, 2, 1, 1, RED)
	_px(1, 2, 1, 1, RED)

func _draw_ear() -> void:
	_px(-2, -6, 4, 7, INK)
	_px(-1, -6, 2, 6, WHITE)
	_px(0, -4, 1, 3, BLUSH)

func _draw_bow() -> void:
	_px(-3, -2, 2, 4, INK)
	_px(2, -2, 2, 4, INK)
	_px(-2, -1, 5, 3, PINK)
	_px(0, 0, 1, 1, HOT_PINK)

func _draw_torso() -> void:
	_px(-5, -2, 10, 9, INK)
	_px(-4, -2, 8, 7, PINK)
	_px(-5, 4, 10, 2, HOT_PINK)
	_px(-4, 6, 2, 1, WHITE)
	_px(-1, 6, 2, 1, WHITE)
	_px(2, 6, 2, 1, WHITE)
	_px(-1, 0, 2, 2, Color("fff0f7"))

func _draw_arm() -> void:
	_px(-2, -2, 4, 5, INK)
	_px(-1, -1, 3, 4, WHITE)
	_px(0, 2, 2, 1, SHADOW)

func _draw_leg() -> void:
	_px(-2, -1, 4, 4, INK)
	_px(-1, -1, 3, 3, WHITE)
	_px(-1, 2, 3, 1, SHADOW)

func _draw_weapon() -> void:
	_px(0, -2, 9, 5, INK)
	_px(0, -1, 8, 3, PINK)
	_px(2, 0, 2, 1, Color("fff1f7"))
	_px(7, -1, 2, 3, HOT_PINK)
	_px(1, 3, 2, 3, INK)
	_px(1, 3, 1, 2, PINK)

func _draw_chick_head() -> void:
	_px(-5, -5, 10, 9, INK)
	_px(-4, -5, 8, 8, YELLOW)
	_px(-2, -1, 1, 2, Color("17131d"))
	_px(2, -1, 1, 2, Color("17131d"))
	_px(-1, 1, 3, 1, ORANGE)
	_px(-4, 1, 2, 1, BLUSH)
	_px(3, 1, 2, 1, BLUSH)
	_px(-3, -6, 2, 2, YELLOW)
	_px(1, -7, 2, 3, YELLOW)

func _draw_chick_body() -> void:
	_px(-4, -2, 8, 7, INK)
	_px(-3, -2, 6, 6, YELLOW)
	_px(-2, 0, 4, 3, Color("fff0bd"))
	_px(-5, -1, 2, 3, YELLOW)
	_px(4, -1, 2, 3, YELLOW)

func _draw_chick_feet() -> void:
	_px(-3, 0, 2, 2, ORANGE)
	_px(1, 0, 2, 2, ORANGE)

func _draw_pig_head() -> void:
	_px(-6, -5, 12, 9, INK)
	_px(-5, -4, 10, 8, Color("ff9fbd"))
	_px(-5, -6, 3, 3, Color("ff9fbd"))
	_px(2, -6, 3, 3, Color("ff9fbd"))
	_px(-2, -1, 4, 3, PINK)
	_px(-1, 0, 1, 1, RED)
	_px(1, 0, 1, 1, RED)
	_px(-3, -2, 1, 1, Color("17131d"))
	_px(3, -2, 1, 1, Color("17131d"))
	_px(-3, 2, 1, 2, WHITE)
	_px(3, 2, 1, 2, WHITE)

func _draw_pig_body() -> void:
	_px(-5, -2, 10, 7, INK)
	_px(-4, -2, 8, 6, Color("ff9fbd"))
	_px(-4, 1, 8, 2, Color("ffbed0"))

func _draw_pig_feet() -> void:
	_px(-4, 0, 3, 2, Color("5d2a43"))
	_px(1, 0, 3, 2, Color("5d2a43"))
