class_name Bloco
extends StaticBody2D

const TEX := preload("res://assets/objetos/bloco.png")
var usado := false
var sensor: Area2D
var t := randf() * 6.0

func _ready() -> void:
	var f := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(90, 90)
	f.shape = r
	add_child(f)
	sensor = Area2D.new()
	var fs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(70, 40)
	fs.shape = rs
	fs.position = Vector2(0, 62)
	sensor.add_child(fs)
	add_child(sensor)

func _process(d: float) -> void:
	t += d
	if not usado:
		queue_redraw()

func _draw() -> void:
	var bri := 0.5 + 0.5 * sin(t * 4.0)
	var cor := Color(0.55, 0.55, 0.6) if usado else Color(1, 1, 1).lerp(Color(1.12, 1.08, 0.9), bri)
	draw_texture_rect(TEX, Rect2(-50, -50, 100, 98), false, cor)
	if not usado:
		var b2 := maxf(0.0, sin(t * 2.0 + 1.0))
		var cx := -26.0 + fmod(t * 20.0, 52.0)
		draw_line(Vector2(cx - 8, 30), Vector2(cx + 8, -30), Color(1, 1, 1, 0.25 * b2), 10.0)
