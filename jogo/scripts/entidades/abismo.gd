class_name Abismo
extends Node2D

var x1 := 0.0
var x2 := 0.0
var chao := 771.0
var agua := false
var t := 0.0

func _process(d: float) -> void:
	t += d
	queue_redraw()

func _draw() -> void:
	var w := x2 - x1
	var base := 1200.0
	if agua:
		var topo := chao + 22.0
		# paredes de terra
		draw_rect(Rect2(x1, chao - 4, w, base - chao), Color("#4A2E15"))
		# agua em faixas de profundidade (do turquesa ao azul fundo)
		var xa := x1 + 10.0
		var xb := x2 - 10.0
		var c1 := Color("#6FD8F0")
		var c2 := Color("#2A8CC8")
		var c3 := Color("#0B3A6E")
		draw_polygon(PackedVector2Array([Vector2(xa, topo), Vector2(xb, topo), Vector2(xb, topo + 180.0), Vector2(xa, topo + 180.0)]), PackedColorArray([c1, c1, c2, c2]))
		draw_polygon(PackedVector2Array([Vector2(xa, topo + 180.0), Vector2(xb, topo + 180.0), Vector2(xb, topo + 480.0), Vector2(xa, topo + 480.0)]), PackedColorArray([c2, c2, c3, c3]))
		draw_rect(Rect2(xa, topo + 480.0, xb - xa, base - topo), c3)
		# raios de luz
		for k in int(w / 160.0):
			var lx := x1 + 40.0 + k * 160.0 + sin(t * 0.8 + k) * 20.0
			draw_colored_polygon(PackedVector2Array([Vector2(lx, topo), Vector2(lx + 40, topo), Vector2(lx + 110, topo + 220), Vector2(lx + 40, topo + 220)]), Color(1, 1, 1, 0.07))
		# bolhas subindo
		for k in int(w / 110.0):
			var bx := x1 + 50.0 + k * 110.0 + sin(t + k * 2.0) * 12.0
			var by := topo + 260.0 - fmod(t * 40.0 + k * 53.0, 240.0)
			draw_arc(Vector2(bx, by), 5.0 + (k % 3) * 2.0, 0, TAU, 12, Color(1, 1, 1, 0.45), 2.0)
		# ondas da superficie (duas camadas) e espuma
		for camada in 2:
			var pts := PackedVector2Array()
			for k in 61:
				var u := k / 60.0
				pts.append(Vector2(x1 + 10.0 + u * (w - 20.0), topo + camada * 9.0 + sin(t * (2.6 + camada) + u * (20.0 + camada * 8.0)) * (6.0 - camada * 2.0)))
			draw_polyline(pts, Color("#EAF9FF") if camada == 0 else Color(1, 1, 1, 0.45), 6.0 - camada * 2.0)
		# brilhos
		for k in int(w / 90.0):
			var sx := x1 + 30.0 + k * 90.0 + fmod(t * 25.0 + k * 31.0, 60.0)
			draw_circle(Vector2(sx, topo + 28.0 + (k % 4) * 14.0), 3.0, Color(1, 1, 1, 0.5 + 0.4 * sin(t * 3.0 + k)))
		# pedras no fundo
		for k in int(w / 220.0):
			var rx := x1 + 70.0 + k * 220.0
			draw_circle(Vector2(rx, base - 40.0), 34.0, Color("#0A2C52"))
	else:
		var topo2 := chao - 4.0
		var ca := Color("#3A2A52")
		var cb := Color("#150F26")
		var cc := Color("#05030C")
		draw_polygon(PackedVector2Array([Vector2(x1, topo2), Vector2(x2, topo2), Vector2(x2, topo2 + 260.0), Vector2(x1, topo2 + 260.0)]), PackedColorArray([ca, ca, cb, cb]))
		draw_polygon(PackedVector2Array([Vector2(x1, topo2 + 260.0), Vector2(x2, topo2 + 260.0), Vector2(x2, base), Vector2(x1, base)]), PackedColorArray([cb, cb, cc, cc]))
		# estratos de rocha
		for k in int(w / 120.0) + 1:
			var rx2 := x1 + k * 120.0 + (k % 3) * 18.0
			var ry := topo2 + 40.0 + (k * 67 % 180)
			draw_colored_polygon(PackedVector2Array([Vector2(rx2, ry), Vector2(rx2 + 70, ry - 8), Vector2(rx2 + 96, ry + 14), Vector2(rx2 + 30, ry + 26)]), Color(1, 1, 1, 0.05))
		# estalactites pendendo da borda
		for k in int(w / 70.0):
			var sx2 := x1 + 20.0 + k * 70.0
			var alt := 34.0 + float((k * 37) % 50)
			draw_colored_polygon(PackedVector2Array([Vector2(sx2 - 18, topo2), Vector2(sx2 + 18, topo2), Vector2(sx2, topo2 + alt)]), Color("#4A3868"))
		# nevoa subindo e poeira brilhante
		for k in int(w / 200.0) + 1:
			var nx := x1 + 60.0 + k * 200.0 + sin(t * 0.6 + k) * 40.0
			draw_circle(Vector2(nx, topo2 + 200.0 + sin(t * 0.9 + k * 2.0) * 20.0), 90.0, Color(0.6, 0.5, 0.9, 0.06))
		for k in int(w / 90.0):
			var py := topo2 + 400.0 - fmod(t * 30.0 + k * 71.0, 380.0)
			draw_circle(Vector2(x1 + 30.0 + k * 90.0 + sin(t + k) * 10.0, py), 2.5, Color(1.0, 0.85, 0.5, 0.5))
		draw_rect(Rect2(x1, base - 90.0, w, 90.0), Color("#05030C"))
	# bordas: parede de terra com tufo de grama
	for lado in 2:
		var bx2 := x1 - 16.0 if lado == 0 else x2
		draw_rect(Rect2(bx2, chao - 4, 16.0, 420.0), Color("#5A3B22"))
		draw_rect(Rect2(bx2 + (0.0 if lado == 1 else 0.0), chao - 4, 16.0, 14.0), Color("#4CAF50"))
	draw_rect(Rect2(x1 - 6.0, chao - 8.0, 22.0, 12.0), Color("#5FCB5F"))
	draw_rect(Rect2(x2 - 16.0, chao - 8.0, 22.0, 12.0), Color("#5FCB5F"))
