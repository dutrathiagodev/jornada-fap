extends Control
class_name Estrelas
## Três estrelas desenhadas por código (douradas ou vazias), com animação de "pop".

var n := 0
var raio := 60.0
var pops := [1.0, 1.0, 1.0]
var t := 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(raio * 6.4, raio * 2.2)


func animar() -> void:
	for i in 3:
		pops[i] = 0.0
		if i < n:
			var tw := create_tween()
			tw.tween_interval(0.25 + i * 0.35)
			tw.tween_callback(Jogo.sfx.bind("estrela"))
			tw.tween_method(func(v: float): pops[i] = v; queue_redraw(), 0.0, 1.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			pops[i] = 1.0
	queue_redraw()


func _process(d: float) -> void:
	t += d
	queue_redraw()


func _estrela(c: Vector2, r: float, cor: Color, borda: Color) -> void:
	var pts := PackedVector2Array()
	for k in 10:
		var a := -PI / 2.0 + k * PI / 5.0
		var rr := r if k % 2 == 0 else r * 0.45
		pts.append(c + Vector2(cos(a), sin(a)) * rr)
	var contorno := PackedVector2Array(pts)
	contorno.append(pts[0])
	draw_colored_polygon(pts, cor)
	draw_polyline(contorno, borda, maxf(3.0, r * 0.1), true)


func _draw() -> void:
	for i in 3:
		var c := Vector2(size.x / 2.0 + (i - 1) * raio * 2.2, size.y / 2.0 + (12.0 if i != 1 else -4.0) * (raio / 60.0))
		var cheia := i < n
		var s: float = pops[i] if cheia else 1.0
		if cheia:
			var br := 0.5 + 0.5 * sin(t * 3.0 + i)
			_estrela(c, raio * s, Color("#FFC928"), Color("#7A4A00"))
			_estrela(c + Vector2(0, -raio * 0.06), raio * 0.62 * s, Color("#FFE680"), Color(1, 1, 1, 0))
		else:
			_estrela(c, raio, Color(0.02, 0.07, 0.18, 0.7), Color(1, 1, 1, 0.35))
