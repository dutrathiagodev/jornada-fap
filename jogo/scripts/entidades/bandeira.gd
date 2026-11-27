class_name Bandeira
extends Node2D

const LOGO_A := preload("res://assets/logos/adventista_branco.png")
const LOGO_FAP := preload("res://assets/logos/fap_branco.svg")
const TEX_CP := preload("res://assets/ui/bandeira_checkpoint.png")
const TEX_FIM := preload("res://assets/ui/bandeira_final.png")
var cor := Color("#0B3A6E")
var escala := 1.0
var final := false
var ativa := false:
	set(v):
		if v and not ativa:
			rajada = 1.0
		ativa = v
var rajada := 0.0
var t := randf() * 5.0

func _process(d: float) -> void:
	t += d
	rajada = maxf(0.0, rajada - d * 0.8)
	queue_redraw()

## desenha a textura em faixas verticais que ondulam como pano ao vento
func _pano(tex: Texture2D, r: Rect2, tom: Color, amp: float, fase: float) -> void:
	var n := 24
	var tw := tex.get_width() / float(n)
	for i in n:
		var u := i / float(n - 1)
		var solta := clampf((u - 0.18) / 0.82, 0.0, 1.0)
		var dy := sin(t * 4.0 + u * 5.0 + fase) * amp * solta
		var dx := cos(t * 3.0 + u * 4.0 + fase) * amp * 0.3 * solta
		draw_texture_rect_region(tex, Rect2(r.position.x + r.size.x * u + dx, r.position.y + dy, r.size.x / n + 1.0, r.size.y), Rect2(i * tw, 0, tw, tex.get_height()), tom)

func _draw() -> void:
	if final:
		var h := 420.0
		var w := h * TEX_FIM.get_width() / float(TEX_FIM.get_height())
		var k := 0.5 + 0.5 * sin(t * 2.0)
		draw_circle(Vector2(w * 0.25, -h * 0.7), 190.0 + sin(t * 3.0) * 8.0, Color(1.0, 0.83, 0.3, 0.07 + 0.06 * k))
		# raios girando atrás da bandeira
		for i in 8:
			var a := t * 0.5 + i * TAU / 8.0
			var c := Vector2(w * 0.3, -h * 0.65)
			draw_colored_polygon(PackedVector2Array([c, c + Vector2(cos(a - 0.08), sin(a - 0.08)) * 330.0, c + Vector2(cos(a + 0.08), sin(a + 0.08)) * 330.0]), Color(1.0, 0.9, 0.5, 0.07))
		_pano(TEX_FIM, Rect2(-w * 0.08, -h, w, h), Color(1, 1, 1), 7.0, 0.0)
		# confete e estrelinhas subindo
		for i in 14:
			var u := fmod(t * 0.35 + i * 0.0714, 1.0)
			var px := -40.0 + float((i * 53) % 230) + sin(t * 2.0 + i) * 14.0
			var cor_c: Color = [Color("#FFD34E"), Color("#4DD2FF"), Color("#FF7AA8"), Color("#7CFF9B")][i % 4]
			draw_circle(Vector2(px, -u * 460.0), 5.0 * (1.0 - u * 0.6), Color(cor_c.r, cor_c.g, cor_c.b, 1.0 - u))
	else:
		var h := 300.0 * escala
		var w := h * TEX_CP.get_width() / float(TEX_CP.get_height())
		var tom := Color(1.5, 1.25, 0.45) if ativa else Color(1, 1, 1)
		if ativa:
			draw_circle(Vector2(w * 0.3, -h * 0.6), 80.0 * escala + sin(t * 4.0) * 6.0, Color(1.0, 0.85, 0.3, 0.12))
		_pano(TEX_CP, Rect2(-w * 0.2, -h, w, h), tom, 5.0 * escala, 0.0)
		var lw := 40.0 * escala
		draw_texture_rect(LOGO_A, Rect2(-w * 0.2 + w * 0.42 - lw / 2.0, -h + h * 0.26 - lw * 0.46 + sin(t * 4.0 + 2.0) * 4.0, lw, lw * 0.91), false)
		# explosão de faíscas ao ativar
		if rajada > 0.0:
			for i in 18:
				var a := i * TAU / 18.0
				var dist := (1.0 - rajada) * 170.0 * escala
				draw_circle(Vector2(w * 0.3, -h * 0.65) + Vector2(cos(a), sin(a)) * dist, 6.0 * rajada, Color(1.0, 0.85, 0.3, rajada))
		elif ativa:
			for i in 3:
				var u := fmod(t * 0.6 + i * 0.33, 1.0)
				draw_circle(Vector2(w * 0.1 + i * w * 0.2, -h * 0.4 - u * h * 0.6), 3.5, Color(1.0, 0.9, 0.5, 1.0 - u))
