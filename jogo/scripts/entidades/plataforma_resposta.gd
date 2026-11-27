class_name PlataformaResposta
extends StaticBody2D

const TEX := preload("res://assets/objetos/plataforma.png")
const TEX_PEDRA := preload("res://assets/ui/plataforma_pedra.png")
var w := 190.0
var h := 34.0
var cor := Color("#1B5AA6")
var texto := ""
var correta := false
var vivo := true
var destaque := false
var progresso := 0.0
var t := 0.0
var sensor: Area2D
var shape: CollisionShape2D

func _process(d: float) -> void:
	if destaque and vivo:
		t += d
		queue_redraw()

func montar(uma_via: bool, com_sensor: bool) -> void:
	shape = CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(w, h)
	shape.shape = r
	shape.position = Vector2(0, h / 2.0)
	shape.one_way_collision = uma_via
	add_child(shape)
	if com_sensor:
		sensor = Area2D.new()
		var f := CollisionShape2D.new()
		var rs := RectangleShape2D.new()
		rs.size = Vector2(w - 30.0, 56.0)
		f.shape = rs
		f.position = Vector2(0, -8)
		sensor.add_child(f)
		add_child(sensor)
		var l := Label.new()
		l.text = texto
		l.position = Vector2(-w / 2.0 - 40.0, -118)
		l.size = Vector2(w + 80.0, 80)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.add_theme_font_size_override("font_size", 34)
		l.add_theme_color_override("font_color", Color.WHITE)
		l.add_theme_color_override("font_outline_color", Color("#14213D"))
		l.add_theme_constant_override("outline_size", 12)
		add_child(l)

## ponte de tábuas que fecha o buraco: madeira, pregos dourados e corda
func _desenhar_ponte() -> void:
	var x0 := -w / 2.0
	var corpo := StyleBoxFlat.new()
	corpo.bg_color = Color("#8B5A2B")
	corpo.set_corner_radius_all(10)
	corpo.border_color = Color("#3B2412")
	corpo.set_border_width_all(4)
	draw_style_box(corpo, Rect2(x0, 0, w, 58))
	var n := int(w / 64.0)
	var tabua := w / n
	for i in n:
		var tx := x0 + i * tabua
		var tom := Color("#A86F38") if i % 2 == 0 else Color("#9A6230")
		draw_rect(Rect2(tx + 3, 5, tabua - 6, 48), tom)
		draw_rect(Rect2(tx + 3, 5, tabua - 6, 11), Color(1, 0.85, 0.55, 0.35))
		draw_line(Vector2(tx + 3, 54), Vector2(tx + tabua - 3, 54), Color(0, 0, 0, 0.35), 3.0)
		draw_circle(Vector2(tx + 12, 28), 3.5, Color("#FFD34E"))
		draw_circle(Vector2(tx + tabua - 12, 28), 3.5, Color("#FFD34E"))
	# vigas de sustentação por baixo
	for i in 3:
		var vx := x0 + w * (0.12 + i * 0.38)
		draw_rect(Rect2(vx, 58, 22, 40), Color("#5A3920"))
	# corda e musgo na frente
	draw_line(Vector2(x0 + 6, 2), Vector2(x0 + w - 6, 2), Color("#E8D29A"), 5.0)
	for i in int(w / 150.0):
		draw_circle(Vector2(x0 + 40 + i * 150.0, 58), 14.0, Color("#4CAF50"))

func _draw() -> void:
	if sensor == null and h <= 40.0:
		draw_texture_rect(TEX, Rect2(-w / 2.0 - 8.0, -26, w + 16.0, 86), false)
		return
	if sensor == null and h > 40.0:
		_desenhar_ponte()
		return
	# plataforma de pedra (arte do Gemini); o estado muda a cor e o brilho
	var k := 0.5 + 0.5 * sin(t * 8.0)
	var tw := w + 6.0
	var th := tw * TEX_PEDRA.get_height() / float(TEX_PEDRA.get_width())
	var ret := Rect2(-tw / 2.0, -14.0, tw, th)
	var tom := Color(1, 1, 1)
	if destaque and vivo:
		tom = Color(0.8, 1.4, 0.85).lerp(Color(1.1, 1.6, 1.0), k)
		draw_circle(Vector2(0, 14), w * 0.62, Color(0.3, 1.0, 0.5, 0.10 + 0.12 * k))
	elif not vivo:
		tom = Color(1.6, 0.55, 0.55, 0.75)
	draw_texture_rect(TEX_PEDRA, ret, false, tom)
	if progresso > 0.0:
		var pb := StyleBoxFlat.new()
		pb.bg_color = Color("#FFD34E")
		pb.set_corner_radius_all(8)
		pb.border_color = Color("#14213D")
		pb.set_border_width_all(3)
		draw_style_box(pb, Rect2(-w / 2.0 + 14.0, -6.0, maxf(14.0, (w - 28.0) * progresso), 18.0))
	if destaque and vivo:
		for i in 4:
			var u := fmod(t * 0.7 + i * 0.25, 1.0)
			draw_circle(Vector2(-w / 2.0 + w * fmod(i * 0.37 + 0.1, 1.0), -u * 70.0), 4.0 * (1.0 - u), Color(0.8, 1.0, 0.7, 1.0 - u))
