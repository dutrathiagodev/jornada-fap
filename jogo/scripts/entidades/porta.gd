class_name Porta
extends StaticBody2D

const TEX := preload("res://assets/ui/porta.png")
var usada := false
var t := 0.0

func _ready() -> void:
	var f := CollisionShape2D.new()
	f.name = "forma"
	var r := RectangleShape2D.new()
	r.size = Vector2(120, 290)
	f.shape = r
	f.position = Vector2(0, -145)
	add_child(f)

func _process(d: float) -> void:
	t += d
	queue_redraw()

func _draw() -> void:
	if not usada:
		draw_circle(Vector2(0, -140), 120.0 + sin(t * 4.0) * 8.0, Color(1.0, 0.83, 0.3, 0.14))
	draw_texture_rect(TEX, Rect2(-118, -300, 236, 300), false)
	if not usada:
		for i in 5:
			var u := fmod(t * 0.45 + i * 0.2, 1.0)
			draw_circle(Vector2(-45.0 + i * 22.0 + sin(t * 3.0 + i) * 6.0, -40.0 - u * 200.0), 4.0 * (1.0 - u), Color(1.0, 0.9, 0.5, 1.0 - u))
	# "?" dourado com contorno, no centro do vão
	var fonte := ThemeDB.fallback_font
	var bob := sin(t * 3.0) * 5.0
	draw_string_outline(fonte, Vector2(-26, -105 + bob), "?", HORIZONTAL_ALIGNMENT_LEFT, 60, 130, 10, Color("#14213D"))
	draw_string(fonte, Vector2(-26, -105 + bob), "?", HORIZONTAL_ALIGNMENT_LEFT, 60, 130, Color("#FFD34E") if not usada else Color("#FFF2B0"))

func abrir() -> void:
	get_node("forma").set_deferred("disabled", true)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "position:y", position.y - 460, 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "modulate:a", 0.0, 0.9)
