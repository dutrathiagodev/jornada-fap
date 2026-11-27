extends Node2D
## Tela final: estrelas, faixa de desconto e cupom em formato de ingresso.

const NOITE := Color("#14213D")
const OURO := Color("#FFD34E")
const CLARO := Color("#7CC6EA")
const AZUL := Color("#0B3A6E")

var campo: LineEdit
var lbl_codigo: Label
var lbl_aviso: Label
var fundo: TextureRect


class Confete extends Control:
	var t := 0.0

	func _process(d: float) -> void:
		t += d
		queue_redraw()

	func _draw() -> void:
		var cores := [Color("#FFD34E"), Color("#4DD2FF"), Color("#FF7AA8"), Color("#7CFF9B"), Color("#FFFFFF")]
		for i in 70:
			var u := fmod(t * (0.10 + (i % 7) * 0.02) + i * 0.0613, 1.0)
			var x := fmod(i * 157.0, 1920.0) + sin(t * 1.5 + i) * 40.0
			var y := -40.0 + u * 1160.0
			var rot := t * (2.0 + i % 4) + i
			var w := 10.0 + (i % 3) * 4.0
			draw_set_transform(Vector2(x, y), rot, Vector2(1.0, 0.5 + 0.5 * sin(t * 3.0 + i)))
			draw_rect(Rect2(-w / 2.0, -w, w, w * 2.0), cores[i % cores.size()])
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


class Ingresso extends Control:
	const LOGO := preload("res://assets/logos/fap_branco.svg")
	var faixa := 0
	var t := 0.0

	func _process(d: float) -> void:
		t += d
		queue_redraw()

	func _draw() -> void:
		var corpo := StyleBoxFlat.new()
		corpo.bg_color = Color("#FFF6DC")
		corpo.set_corner_radius_all(34)
		corpo.border_color = Color("#E0A800")
		corpo.set_border_width_all(8)
		corpo.shadow_color = Color(0, 0, 0, 0.45)
		corpo.shadow_size = 24
		draw_style_box(corpo, Rect2(Vector2.ZERO, size))
		# lado esquerdo azul com o desconto
		var esq := StyleBoxFlat.new()
		esq.bg_color = Color("#0B3A6E")
		esq.corner_radius_top_left = 28
		esq.corner_radius_bottom_left = 28
		draw_style_box(esq, Rect2(8, 8, 480, size.y - 16))
		var fonte := ThemeDB.fallback_font
		draw_texture_rect(LOGO, Rect2(50, 40, 280, 100), false, Color.WHITE)
		_texto(fonte, "SEU DESCONTO", 36, Vector2(0, 205), 496, Color("#BFE8FF"))
		_texto(fonte, ("%d%%" % faixa) if faixa > 0 else "—", 170, Vector2(0, 360), 496, Color("#FFD34E"))
		var br := 0.5 + 0.5 * sin(t * 3.0)
		draw_circle(Vector2(440, 70), 6.0 + 3.0 * br, Color(1, 0.9, 0.5, 0.8))
		draw_circle(Vector2(70, size.y - 60), 5.0 + 3.0 * (1.0 - br), Color(1, 0.9, 0.5, 0.8))
		# picote
		var x := 488.0
		var y := 24.0
		while y < size.y - 24.0:
			draw_line(Vector2(x, y), Vector2(x, y + 16.0), Color("#C9A227"), 5.0)
			y += 30.0
		draw_circle(Vector2(x, 0), 24.0, Color(0.05, 0.12, 0.28))
		draw_circle(Vector2(x, size.y), 24.0, Color(0.05, 0.12, 0.28))

	func _texto(f: Font, s: String, tam: int, pos: Vector2, larg: float, cor: Color) -> void:
		var w := f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
		var p := Vector2(pos.x + 8 + (larg - w) / 2.0, pos.y)
		draw_string_outline(f, p, s, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, 12, Color("#06203F"))
		draw_string(f, p, s, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, cor)


func _ready() -> void:
	Jogo.tocar_musica("tema")
	var ui := CanvasLayer.new()
	add_child(ui)
	fundo = TextureRect.new()
	fundo.texture = load("res://assets/ui/capa.jpg")
	fundo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fundo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fundo.size = Vector2(1920, 1080)
	fundo.pivot_offset = Vector2(960, 540)
	ui.add_child(fundo)
	var sombra := ColorRect.new()
	sombra.color = Color(0.02, 0.06, 0.16, 0.6)
	sombra.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(sombra)
	var cf := Confete.new()
	cf.size = Vector2(1920, 1080)
	ui.add_child(cf)

	var lg := TextureRect.new()
	lg.texture = load("res://assets/logos/fap_branco.svg")
	lg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	lg.position = Vector2(60, 40)
	lg.size = Vector2(240, 96)
	ui.add_child(lg)
	var tot := Jogo.total_estrelas()
	var faixa := Jogo.faixa_desconto()

	var plaqueta := TextureRect.new()
	plaqueta.texture = load("res://assets/ui/botao_dourado.png")
	plaqueta.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plaqueta.stretch_mode = TextureRect.STRETCH_SCALE
	plaqueta.position = Vector2(360, 36)
	plaqueta.size = Vector2(1200, 140)
	ui.add_child(plaqueta)
	var t1 := _rot(plaqueta, "Parabéns! Jornada FAP concluída!", 68, 26, Color("#14213D"))
	t1.position.x = -360
	t1.add_theme_constant_override("outline_size", 0)

	var es := Estrelas.new()
	es.raio = 44.0
	es.n = clampi(int(round(tot / 5.0)), 0, 3)
	es.position = Vector2(960 - 140, 190)
	es.size = Vector2(280, 100)
	ui.add_child(es)
	es.animar()
	_rot(ui, "★ %d de 15 estrelas" % tot, 40, 285, OURO)

	var ing := Ingresso.new()
	ing.faixa = faixa
	ing.position = Vector2(210, 380)
	ing.size = Vector2(1500, 440)
	ui.add_child(ing)

	var cx := 210.0 + 520.0
	_rot_em(ui, "Digite seu nome para gerar o cupom", 34, Vector2(cx, 408), 940.0, Color("#0B3A6E"), false)
	campo = LineEdit.new()
	campo.placeholder_text = "Seu nome completo"
	campo.text = Jogo.nome_jogador
	campo.position = Vector2(cx + 30, 468)
	campo.size = Vector2(880, 78)
	campo.alignment = HORIZONTAL_ALIGNMENT_CENTER
	campo.add_theme_font_size_override("font_size", 40)
	campo.add_theme_color_override("font_color", NOITE)
	campo.add_theme_color_override("font_placeholder_color", Color(0.2, 0.25, 0.4, 0.5))
	campo.add_theme_color_override("caret_color", NOITE)
	var sc := StyleBoxFlat.new()
	sc.bg_color = Color.WHITE
	sc.set_corner_radius_all(20)
	sc.border_color = Color("#0B3A6E")
	sc.set_border_width_all(4)
	campo.add_theme_stylebox_override("normal", sc)
	campo.add_theme_stylebox_override("focus", sc)
	campo.max_length = 40
	campo.text_changed.connect(_mudou)
	campo.text_submitted.connect(func(_t): _mudou(campo.text))
	ui.add_child(campo)

	_rot_em(ui, "SEU CÓDIGO", 28, Vector2(cx, 568), 940.0, Color("#8A6A00"), false)
	lbl_codigo = _rot_em(ui, "", 78, Vector2(cx, 600), 940.0, Color("#0B3A6E"), false)
	lbl_aviso = _rot_em(ui, "Mostre este código na FAP. Valores e regras do desconto serão confirmados pela secretaria.", 26, Vector2(cx + 40, 715), 860.0, Color("#3A4560"), false)
	lbl_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_aviso.custom_minimum_size = Vector2(860, 80)
	lbl_aviso.size = Vector2(860, 80)
	if faixa == 0:
		_rot(ui, "Termine as 5 cidades para liberar o desconto", 44, 850, CLARO)
	if ControlesToque.deve_aparecer():
		var voltar := Estilos.botao("Voltar ao mapa", 38)
		voltar.position = Vector2(700, 900)
		voltar.size = Vector2(520, 100)
		voltar.pressed.connect(func(): get_tree().change_scene_to_file("res://mapa.tscn"))
		ui.add_child(voltar)
	else:
		_rot(ui, Jogo.dica("Esc  voltar ao mapa", "B  voltar ao mapa", "Bolinha  voltar ao mapa"), 30, 985, Color(1, 1, 1, 0.85))
	_mudou(campo.text)
	campo.grab_focus()


func _process(_d: float) -> void:
	fundo.scale = Vector2.ONE * (1.0 + 0.02 * (0.5 + 0.5 * sin(Time.get_ticks_msec() / 2500.0)))


func _rot(pai: Node, texto: String, tam: int, y: float, cor: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = Vector2(0, y)
	l.size = Vector2(1920, tam + 30)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", cor)
	l.add_theme_color_override("font_outline_color", NOITE)
	l.add_theme_constant_override("outline_size", 12)
	pai.add_child(l)
	return l


## rótulo dentro do ingresso (sem contorno, cor escura)
func _rot_em(pai: Node, texto: String, tam: int, pos: Vector2, larg: float, cor: Color, contorno: bool) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = pos
	l.size = Vector2(larg, tam + 30)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", cor)
	pai.add_child(l)
	return l


func _mudou(texto: String) -> void:
	if texto.strip_edges().length() < 3 or Jogo.faixa_desconto() == 0:
		lbl_codigo.text = "—"
		return
	Jogo.nome_jogador = texto.strip_edges()
	Jogo.salvar()
	lbl_codigo.text = Jogo.gerar_codigo(texto)


func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("voltar"):
		get_tree().change_scene_to_file("res://mapa.tscn")
