class_name SpecialBurst
extends Node2D

var age := 0.0
const LIFE := 0.65

func _ready() -> void:
	z_index = 80

func _process(delta: float) -> void:
	age += delta
	queue_redraw()
	if age >= LIFE:
		queue_free()

func _draw() -> void:
	var t := clampf(age / LIFE, 0.0, 1.0)
	var radius := lerpf(20.0, 520.0, t)
	var alpha := 1.0 - t
	for i in 28:
		var a := TAU * float(i) / 28.0
		var p := Vector2.RIGHT.rotated(a) * radius
		var len := 18.0 + (i % 4) * 7.0
		draw_line(p, p + Vector2.RIGHT.rotated(a) * len, Color(1.0, 0.45, 0.72, alpha), 5.0)
	for i in 12:
		var a := TAU * float(i) / 12.0 + 0.18
		var p := Vector2.RIGHT.rotated(a) * radius * 0.7
		var c := Color(1.0, 0.86, 0.28, alpha)
		draw_rect(Rect2(p.x - 4, p.y - 1, 8, 2), c)
		draw_rect(Rect2(p.x - 1, p.y - 4, 2, 8), c)
