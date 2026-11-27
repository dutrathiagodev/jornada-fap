extends Node2D
## Mapa das 5 cidades: escolhe a fase, mostra estrelas e cadeados.

const NOITE := Color("#14213D")
const OURO := Color("#FFD34E")
const CLARO := Color("#7CC6EA")

var sel := 0
var cartoes: Array = []
var info: Label
var t := 0.0
var fundo: TextureRect


class Vagalumes extends Control:
	var t := 0.0

	func _process(d: float) -> void:
		t += d
		queue_redraw()

	func _draw() -> void:
		for i in 40:
			var u := fmod(t * (0.04 + (i % 5) * 0.01) + i * 0.173, 1.0)
			var x := fmod(i * 233.0, 1920.0) + sin(t * 0.7 + i) * 24.0
			var piscar := 0.5 + 0.5 * sin(t * 2.6 + i * 1.9)
			draw_circle(Vector2(x, 1080.0 - u * 1100.0), 2.0 + (i % 3), Color(1.0, 0.9, 0.5, 0.7 * piscar * sin(u * PI)))


class Cadeado extends Control:
	func _draw() -> void:
		var c := size / 2.0
		draw_arc(c + Vector2(0, -22), 26.0, PI, TAU, 24, Color("#D9DEE8"), 10.0)
		var corpo := StyleBoxFlat.new()
		corpo.bg_color = Color("#C9A227")
		corpo.set_corner_radius_all(12)
		corpo.border_color = NOITE
		corpo.set_border_width_all(5)
		draw_style_box(corpo, Rect2(c.x - 44, c.y - 22, 88, 70))
		draw_circle(c + Vector2(0, 8), 9.0, NOITE)
		draw_rect(Rect2(c.x - 3.5, c.y + 8, 7, 20), NOITE)


func _ready() -> void:
	Jogo.tocar_musica("tema")
	sel = clampi(Jogo.cidade_atual, 0, 4)
	while not Jogo.liberada(sel):
		sel -= 1
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
	sombra.color = Color(0.02, 0.06, 0.16, 0.55)
	sombra.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(sombra)
	var vg := Vagalumes.new()
	vg.size = Vector2(1920, 1080)
	ui.add_child(vg)
	var lg := TextureRect.new()
	lg.texture = load("res://assets/logos/fap_branco.svg")
	lg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	lg.position = Vector2(60, 40)
	lg.size = Vector2(240, 96)
	ui.add_child(lg)

	# faixa dourada do título
	var faixa := TextureRect.new()
	faixa.texture = load("res://assets/ui/botao_dourado.png")
	faixa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	faixa.stretch_mode = TextureRect.STRETCH_SCALE
	faixa.position = Vector2(620, 36)
	faixa.size = Vector2(680, 130)
	ui.add_child(faixa)
	var tt := _rot(faixa, "Escolha a cidade", 66, Vector2(-620, 22), Color("#14213D"))
	tt.add_theme_constant_override("outline_size", 0)
	var pill := Panel.new()
	var sp := StyleBoxFlat.new()
	sp.bg_color = Color(0.03, 0.12, 0.3, 0.85)
	sp.set_corner_radius_all(26)
	sp.border_color = OURO
	sp.set_border_width_all(3)
	pill.add_theme_stylebox_override("panel", sp)
	pill.position = Vector2(740, 180)
	pill.size = Vector2(440, 62)
	ui.add_child(pill)
	var est_tot := _rot(pill, "★ %d de 15 estrelas" % Jogo.total_estrelas(), 36, Vector2(-740, 6), OURO)
	est_tot.add_theme_constant_override("outline_size", 0)

	for i in 5:
		var c: Dictionary = Jogo.CIDADES[i]
		var lib := Jogo.liberada(i)
		var painel := Panel.new()
		painel.position = Vector2(60 + i * 366, 290)
		painel.size = Vector2(340, 560)
		ui.add_child(painel)
		var img := TextureRect.new()
		img.texture = load("res://assets/%s/1_fundo.png" % c["id"])
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		img.position = Vector2(14, 14)
		img.size = Vector2(312, 290)
		img.clip_contents = true
		if not lib:
			img.modulate = Color(0.45, 0.47, 0.55)
		painel.add_child(img)
		# número da fase numa medalha dourada
		var med := Panel.new()
		var sm := StyleBoxFlat.new()
		sm.bg_color = OURO if lib else Color(0.5, 0.52, 0.6)
		sm.set_corner_radius_all(30)
		sm.border_color = NOITE
		sm.set_border_width_all(5)
		med.add_theme_stylebox_override("panel", sm)
		med.position = Vector2(-8, -8)
		med.size = Vector2(60, 60)
		painel.add_child(med)
		var nn := _rot(med, str(i + 1), 40, Vector2(-930, 4), NOITE)
		nn.size = Vector2(1920, 60)
		nn.add_theme_constant_override("outline_size", 0)
		nn.position = Vector2(30 - 960, 0)
		if not lib:
			var cd := Cadeado.new()
			cd.position = Vector2(14, 14)
			cd.size = Vector2(312, 290)
			painel.add_child(cd)
		var nome := _rot(painel, c["nome"], 36, Vector2(-790, 314), Color.WHITE)
		nome.position = Vector2(170 - 960, 314)
		var tema := _rot(painel, c["tema"], 24, Vector2(10, 372), CLARO)
		tema.position = Vector2(10, 366)
		tema.size = Vector2(320, 70)
		tema.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if lib:
			var es := Estrelas.new()
			es.n = int(Jogo.estrelas[i])
			es.raio = 30.0
			es.position = Vector2(10, 445)
			es.size = Vector2(320, 90)
			painel.add_child(es)
		else:
			var e := _rot(painel, "bloqueada", 32, Vector2(10, 470), Color(1, 1, 1, 0.6))
			e.position = Vector2(170 - 960, 470)
		cartoes.append(painel)

	info = _rot(ui, "", 34, Vector2(0, 890), Color.WHITE)
	_rot(ui, Jogo.dica("← →  escolher     Enter  jogar     Esc  voltar", "Direcional  escolher     A  jogar     B  voltar", "Direcional  escolher     Cruz  jogar     Bolinha  voltar"), 30, Vector2(0, 1000), Color(1, 1, 1, 0.85))
	if Jogo.terminou_tudo():
		_rot(ui, "P  ver meu prêmio", 36, Vector2(0, 945), OURO)
	_atualizar()


func _rot(pai: Node, texto: String, tam: int, pos: Vector2, cor: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = pos
	l.size = Vector2(1920, tam + 30)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", cor)
	l.add_theme_color_override("font_outline_color", NOITE)
	l.add_theme_constant_override("outline_size", 10)
	pai.add_child(l)
	return l


func _estilo(sel_: bool, lib: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.04, 0.2, 0.42, 0.96) if lib else Color(0.1, 0.12, 0.2, 0.96)
	s.set_corner_radius_all(28)
	s.border_color = OURO if sel_ else (CLARO if lib else Color(0.5, 0.55, 0.7))
	s.set_border_width_all(9 if sel_ else 4)
	if sel_:
		s.shadow_color = Color(1.0, 0.82, 0.3, 0.55)
		s.shadow_size = 30
	return s


func _atualizar() -> void:
	for i in 5:
		cartoes[i].add_theme_stylebox_override("panel", _estilo(i == sel, Jogo.liberada(i)))
		cartoes[i].scale = Vector2.ONE * (1.07 if i == sel else 1.0)
		cartoes[i].pivot_offset = Vector2(170, 280)
	var c: Dictionary = Jogo.CIDADES[sel]
	info.text = "Você sabia? " + str(c["dica"])


func _process(d: float) -> void:
	t += d
	fundo.scale = Vector2.ONE * (1.0 + 0.02 * (0.5 + 0.5 * sin(t * 0.4)))
	cartoes[sel].position.y = 290 - 8 + sin(t * 4.0) * 6.0


func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("mover_direita") and sel < 4 and Jogo.liberada(sel + 1):
		cartoes[sel].position.y = 290
		Jogo.sfx("clique")
		sel += 1
		_atualizar()
	elif ev.is_action_pressed("mover_esquerda") and sel > 0:
		cartoes[sel].position.y = 290
		Jogo.sfx("clique")
		sel -= 1
		_atualizar()
	elif ev.is_action_pressed("confirmar"):
		Jogo.cidade_atual = sel
		Jogo.sfx("clique")
		get_tree().change_scene_to_file("res://fase.tscn")
	elif ev.is_action_pressed("voltar"):
		get_tree().change_scene_to_file("res://main.tscn")
	elif ev is InputEventKey and ev.pressed and not ev.echo:
		if ev.physical_keycode == KEY_P and Jogo.terminou_tudo():
			get_tree().change_scene_to_file("res://final.tscn")
