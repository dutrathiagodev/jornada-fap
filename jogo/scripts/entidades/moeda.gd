class_name Moeda
extends Area2D

const GIRO := preload("res://assets/objetos/moeda_giro.png")
const N := 32
var t := randf() * 6.0

func _ready() -> void:
	var f := CollisionShape2D.new()
	var r := CircleShape2D.new()
	r.radius = 34.0
	f.shape = r
	add_child(f)

func _process(d: float) -> void:
	t += d
	queue_redraw()

func _draw() -> void:
	var q := int(t * 20.0) % N
	var fw := GIRO.get_width() / float(N)
	var y := sin(t * 2.5) * 6.0
	draw_texture_rect_region(GIRO, Rect2(-42, -42 + y, 84, 84), Rect2(q * fw, 0, fw, GIRO.get_height()))
	# brilho que pisca de vez em quando
	var b := maxf(0.0, sin(t * 2.0 + 1.3) - 0.8) * 5.0
	if b > 0.0:
		draw_circle(Vector2(-14, -16 + y), 6.0 * b, Color(1, 1, 0.9, 0.9))
