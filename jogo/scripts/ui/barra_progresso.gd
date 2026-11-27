class_name BarraProgresso
extends Control

const BANDEIRA := preload("res://assets/ui/bandeira_checkpoint.png")
var fim_x := 7000.0
var x_jog := 0.0
var marcas: Array = []
var checks: Array = []
var feitos := 0
var total := 0

const LOGO := preload("res://assets/logos/adventista_branco.png")
var t := 0.0

func _process(d: float) -> void:
	t += d
	queue_redraw()

func _draw() -> void:
	var x0 := 70.0
	var larg := size.x - 140.0
	var y := 38.0
	var r := clampf(x_jog / fim_x, 0.0, 1.0)
	var navy := Color("#14213D")
	# moldura azul com borda dourada, no mesmo estilo dos painéis
	var mold := StyleBoxFlat.new()
	mold.bg_color = Color(0.04, 0.14, 0.34, 0.92)
	mold.set_corner_radius_all(30)
	mold.border_color = Color("#FFD34E")
	mold.set_border_width_all(4)
	mold.shadow_color = Color(0, 0, 0, 0.35)
	mold.shadow_size = 8
	draw_style_box(mold, Rect2(0, y - 26, size.x, 86))
	# trilho
	var trilho := StyleBoxFlat.new()
	trilho.bg_color = Color(0.01, 0.05, 0.14, 0.9)
	trilho.set_corner_radius_all(14)
	trilho.border_color = Color(1, 1, 1, 0.25)
	trilho.set_border_width_all(2)
	draw_style_box(trilho, Rect2(x0 - 10, y - 14, larg + 20, 28))
	if r > 0.01:
		var cheio := StyleBoxFlat.new()
		cheio.bg_color = Color("#F5B820")
		cheio.set_corner_radius_all(11)
		draw_style_box(cheio, Rect2(x0 - 6, y - 10, larg * r + 6, 20))
		var luz := StyleBoxFlat.new()
		luz.bg_color = Color(1, 0.97, 0.7, 0.55)
		luz.set_corner_radius_all(5)
		draw_style_box(luz, Rect2(x0, y - 8, maxf(10.0, larg * r - 8), 6))
		# brilho que percorre o preenchimento
		var sx := x0 + fmod(t * 140.0, maxf(40.0, larg * r))
		draw_circle(Vector2(sx, y), 7.0, Color(1, 1, 1, 0.35))
	for c in checks:
		var cx: float = x0 + larg * clampf(c / fim_x, 0.0, 1.0)
		draw_line(Vector2(cx, y - 24), Vector2(cx, y - 8), Color.WHITE, 3.0)
		draw_colored_polygon(PackedVector2Array([Vector2(cx, y - 24), Vector2(cx + 13, y - 19), Vector2(cx, y - 14)]), Color("#7CFF9B") if c <= x_jog else Color("#9FD8F5"))
	# marcos dos desafios: medalhas com "?"; viram verdes com ✓ quando passa
	var fonte := ThemeDB.fallback_font
	for m in marcas:
		var mx: float = x0 + larg * clampf(m / fim_x, 0.0, 1.0)
		var feito: bool = m <= x_jog
		draw_circle(Vector2(mx, y), 14.0, navy)
		draw_circle(Vector2(mx, y), 11.5, Color("#3DBE6C") if feito else Color("#4DB6E8"))
		draw_string(fonte, Vector2(mx - 6, y + 8), "✓" if feito else "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
	# bandeira de chegada
	draw_texture_rect(BANDEIRA, Rect2(x0 + larg + 2, y - 36, 44, 56), false)
	# jogador: medalha dourada com o símbolo da rede adventista
	var px := x0 + larg * r
	var pulso := 1.0 + 0.06 * sin(t * 5.0)
	draw_circle(Vector2(px, y), 24.0 * pulso, Color(1, 0.85, 0.3, 0.25))
	draw_circle(Vector2(px, y), 20.0, navy)
	draw_circle(Vector2(px, y), 17.0, Color("#FFD34E"))
	draw_texture_rect(LOGO, Rect2(px - 11, y - 10, 22, 20), false, Color("#14213D"))
	# contador de desafios
	var txt := "Desafios  %d / %d" % [feitos, total]
	var tw := fonte.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	draw_string_outline(fonte, Vector2((size.x - tw) / 2.0, y + 46), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 7, navy)
	draw_string(fonte, Vector2((size.x - tw) / 2.0, y + 46), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
