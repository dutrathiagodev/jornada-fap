class_name Tronco
extends AnimatableBody2D

const TEX := preload("res://assets/objetos/tronco.png")
var x0 := 0.0
var amp := 120.0
var fase := 0.0
var t := 0.0
var w := 240.0

func _ready() -> void:
	sync_to_physics = true
	var f := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(w, 36)
	f.shape = r
	f.position = Vector2(0, 18)
	f.one_way_collision = true
	add_child(f)

func _physics_process(d: float) -> void:
	t += d
	position.x = x0 + sin(t * 1.1 + fase) * amp

func _draw() -> void:
	draw_texture_rect(TEX, Rect2(-w / 2.0 - 10.0, -16, w + 20.0, 100), false)
