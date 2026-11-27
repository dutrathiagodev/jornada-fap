class_name Inimigo
extends Area2D

const TEX_P := preload("res://assets/objetos/preguica.png")
const TEX_D := preload("res://assets/objetos/distracao.png")
var tipo := "preguica"
var x_min := 0.0
var x_max := 0.0
var dir := 1.0
var vivo := true
var t := randf() * 6.0
var base_y := 0.0

func _ready() -> void:
	var f := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(90, 70) if tipo == "preguica" else Vector2(70, 80)
	f.shape = r
	f.position = Vector2(0, -35) if tipo == "preguica" else Vector2.ZERO
	add_child(f)
	base_y = position.y

func _physics_process(d: float) -> void:
	if not vivo:
		return
	t += d
	position.x += dir * (70.0 if tipo == "preguica" else 130.0) * d
	if position.x > x_max:
		dir = -1.0
	elif position.x < x_min:
		dir = 1.0
	if tipo == "distracao":
		position.y = base_y + sin(t * 2.2) * 60.0
	queue_redraw()

func _draw() -> void:
	if tipo == "preguica":
		var sq := 1.0 + 0.05 * sin(t * 3.0)
		draw_set_transform(Vector2(0, 0), 0.0, Vector2(-dir * sq, 1.0 / sq))
		draw_texture_rect(TEX_P, Rect2(-62, -112, 124, 114), false)
	else:
		draw_set_transform(Vector2(0, sin(t * 16.0) * 3.0), sin(t * 3.0) * 0.1, Vector2(dir, 1.0))
		draw_texture_rect(TEX_D, Rect2(-62, -48, 124, 96), false)
