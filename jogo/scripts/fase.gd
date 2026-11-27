extends Node2D
## Uma fase do jogo. Lê a cidade atual em Jogo.cidade_atual e monta tudo por código:
## cenário em parallax, chão com buracos, moedas, blocos "?", inimigos, portas-pergunta,
## "Caminho certo", troncos, telhados, areia, Ponte do Conhecimento, interface, sons e efeitos.

const Jogador := preload("res://scripts/jogador.gd")
const TEMPO_PERGUNTA := 20.0
const DWELL := 0.7

const AZUL := Color("#0B3A6E")
const AZUL_MEDIO := Color("#1B5AA6")
const CLARO := Color("#7CC6EA")
const OURO := Color("#FFD34E")
const NOITE := Color("#14213D")
const VERDE := Color("#3DBE6C")
const VERMELHO := Color("#E63946")

var cid: Dictionary
var idx := 0
var chao_y := 771.0
var fim_x := 7000.0
var layout: Array = []
var pocos: Array = []            # buracos: {x1, x2, agua}
var areias: Array = []
var tem_caminho := false
var caminho_x1 := 0.0
var caminho_x2 := 0.0
var tem_ponte := false
var ponte_x1 := 0.0
var ponte_x2 := 0.0

var mundo: Node2D
var ui: CanvasLayer
var jogador
var camera: Camera2D

var vidas := 3
var moedas := 0
var moedas_total := 0
var pontos := 0
var acertos := 0
var feitos := 0
var n_obrig := 0
var estado := "jogo"            # jogo | pergunta | feedback | pausa | fim
var venceu := false
var checkpoint := Vector2(200, 771)
var fila_mc: Array = []
var fila_vf: Array = []
var pergunta_caminho: Dictionary = {}
var alt_certa := ""
var sons := {}
var tremor := 0.0
var olhar := 0.0

var queda_livre := false
var primeiro_erro_caminho := true
var caminho_resolvido := false
var cooldown := 0.0
var dwell_plat = null
var dwell_t := 0.0
var plats: Array = []
var blocos: Array = []
var ponte_seg := 0
var ponte_iniciada := false

var perg_atual: Dictionary = {}
var perg_cb: Callable
var perg_ok := false
var perg_bonus := false
var perg_n := 4
var tempo := TEMPO_PERGUNTA
var aviso_id := 0
var demo_t := 0.0
var demo_tp := false
var demo_pulou: Array = []

# widgets
var coracoes
var lbl_moedas: Label
var lbl_pontos: Label
var lbl_fase: Label
var tela_perg: Control
var painel_perg: PanelContainer
var estilo_botao := {}
var fundo_perg: TextureRect
var lbl_tema: Label
var lbl_perg: Label
var botoes: Array = []
var barra: ProgressBar
var fill_tempo: StyleBoxFlat
var hud_prog
var lbl_feed: Label
var lbl_cont: Label
var aviso_painel: PanelContainer
var aviso_lbl: Label
var banner: PanelContainer
var banner_lbl: Label
var tela_fim: Control
var fim_titulo: Label
var fim_estrelas: Label
var fim_texto: Label
var fim_dica: Label
var tela_pausa: Control
var flash: ColorRect


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	idx = Jogo.cidade_atual
	cid = Jogo.CIDADES[idx]
	Jogo.tocar_musica(cid["id"])
	Jogo.abafar(false)
	chao_y = cid["chao"]
	checkpoint = Vector2(200, chao_y)
	layout = Jogo.layout(cid["id"])
	Perguntas.carregar(cid["id"])
	fila_mc = Perguntas.sortear(12)
	fila_vf = Perguntas.sortear_vf(8)
	_ler_layout()

	mundo = Node2D.new()
	mundo.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(mundo)

	_criar_sons()
	_fundo()
	_chao()
	_construir()
	_jogador()
	_criar_ui()
	_atualizar_hud()
	aviso("Fase %d · %s — %s" % [idx + 1, cid["nome"], cid["tema"]], 4.0)


# ====================================================================== montagem
func _ler_layout() -> void:
	for e in layout:
		match e[0]:
			"poco":
				pocos.append({"x1": e[1], "x2": e[2], "agua": cid["agua"]})
			"caminho":
				tem_caminho = true
				caminho_x1 = e[1]
				caminho_x2 = e[2]
				pocos.append({"x1": e[1], "x2": e[2], "agua": cid["agua"]})
			"ponte_final":
				tem_ponte = true
				ponte_x1 = e[1]
				ponte_x2 = e[2]
				pocos.append({"x1": e[1], "x2": e[2], "agua": cid["agua"]})
			"areia":
				areias.append([e[1], e[2]])
			"fim":
				fim_x = e[1]
	pocos.sort_custom(func(a, b): return a["x1"] < b["x1"])
	_distribuir_moedas()


## Moedas bem distribuídas: grupos que se alternam (fileira no chão, arco no ar, fileira alta)
## e um arco guiando o salto sobre cada buraco.
func _distribuir_moedas() -> void:
	layout = layout.filter(func(e): return e[0] != "moedas" and e[0] != "moeda_arco")
	var bloqueios: Array = []
	for p in pocos:
		bloqueios.append([p["x1"] - 160.0, p["x2"] + 120.0])
		if not (tem_caminho and p["x1"] == caminho_x1) and not (tem_ponte and p["x1"] == ponte_x1):
			var n := int((p["x2"] - p["x1"] - 100.0) / 85.0) + 1
			layout.append(["moeda_arco", p["x1"] + 50.0, n, 300.0 if p["x2"] - p["x1"] > 600.0 else 240.0])
	for e in layout:
		if e[0] == "porta":
			bloqueios.append([e[1] - 220.0, e[1] + 140.0])
		elif e[0] == "checkpoint":
			bloqueios.append([e[1] - 120.0, e[1] + 120.0])
		elif e[0] == "placa":
			bloqueios.append([e[1] - 80.0, e[1] + 320.0])
	var x := 600.0
	var k := 0
	while x < fim_x - 450.0:
		var largura: float = [360.0, 425.0, 270.0][k % 3]
		var bloq = null
		for b in bloqueios:
			if x < b[1] and x + largura > b[0]:
				bloq = b
				break
		if bloq != null:
			x = bloq[1] + 40.0
			continue
		match k % 3:
			0: layout.append(["moedas", x, 4, 0.0])
			1: layout.append(["moeda_arco", x, 5, 200.0])
			2: layout.append(["moedas", x, 3, 150.0])
		x += largura + 230.0
		k += 1


func _fundo() -> void:
	for c in [["1_fundo", 0.12], ["2_meio", 0.4], ["3_frente", 1.0]]:
		var tex: Texture2D = load("res://assets/%s/%s.png" % [cid["id"], c[0]])
		var p := Parallax2D.new()
		p.scroll_scale = Vector2(c[1], 0.0)
		p.repeat_size = Vector2(tex.get_width(), 0)
		p.repeat_times = 3
		var s := Sprite2D.new()
		s.texture = tex
		s.centered = false
		p.add_child(s)
		mundo.add_child(p)


func _corpo_rect(topo_esq: Vector2, tam: Vector2) -> StaticBody2D:
	var b := StaticBody2D.new()
	b.position = topo_esq + tam / 2.0
	var f := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = tam
	f.shape = r
	b.add_child(f)
	mundo.add_child(b)
	return b


func _chao() -> void:
	var cursor := -300.0
	for p in pocos:
		_corpo_rect(Vector2(cursor, chao_y), Vector2(p["x1"] - cursor, 400))
		cursor = p["x2"]
		var ab := Abismo.new()
		ab.x1 = p["x1"]
		ab.x2 = p["x2"]
		ab.chao = chao_y
		ab.agua = p["agua"]
		mundo.add_child(ab)
	_corpo_rect(Vector2(cursor, chao_y), Vector2(fim_x + 1200 - cursor, 400))
	_corpo_rect(Vector2(-360, -400), Vector2(60, 2200))
	_corpo_rect(Vector2(fim_x + 700, -400), Vector2(60, 2200))
	var abismo := Area2D.new()
	abismo.position = Vector2(fim_x / 2.0, 1300)
	var f := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(fim_x * 3.0, 200)
	f.shape = r
	abismo.add_child(f)
	abismo.body_entered.connect(_caiu)
	mundo.add_child(abismo)


func _area(pos: Vector2, tam: Vector2) -> Area2D:
	var a := Area2D.new()
	a.position = pos
	var f := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = tam
	f.shape = r
	a.add_child(f)
	mundo.add_child(a)
	return a


func _construir() -> void:
	for e in layout:
		match e[0]:
			"moedas":
				for i in int(e[2]):
					_moeda(Vector2(e[1] + i * 90, chao_y - 70 - e[3]))
			"moeda_arco":
				var n: int = e[2]
				for i in n:
					_moeda(Vector2(e[1] + i * 85, chao_y - 90 - sin(i / float(n - 1) * PI) * e[3]))
			"bloco":
				var b := Bloco.new()
				b.position = Vector2(e[1], chao_y - 345)
				mundo.add_child(b)
				blocos.append(b)
			"inimigo":
				var ini := Inimigo.new()
				ini.tipo = e[1]
				ini.position = Vector2(e[2], chao_y if e[1] == "preguica" else chao_y - 310)
				ini.x_min = e[3]
				ini.x_max = e[4]
				mundo.add_child(ini)
				ini.body_entered.connect(_bateu.bind(ini))
			"porta":
				n_obrig += 1
				var porta := Porta.new()
				porta.position = Vector2(e[1], chao_y)
				mundo.add_child(porta)
				var gat := _area(Vector2(e[1] - 330, chao_y - 150), Vector2(240, 300))
				gat.body_entered.connect(_chegou_porta.bind(porta))
			"checkpoint":
				_checkpoint(e[1])
			"caminho":
				n_obrig += 1
				_caminho()
			"tronco":
				var t := Tronco.new()
				t.x0 = e[1]
				t.amp = e[2]
				t.fase = e[3]
				t.position = Vector2(e[1], chao_y - 8)
				mundo.add_child(t)
			"plat":
				var p := Plat.new()
				p.w = e[3]
				p.cor = Color("#8C5A3C")
				p.position = Vector2(e[1], chao_y - e[2])
				p.montar(true, false)
				mundo.add_child(p)
			"placa":
				_placa(e[2], Vector2(e[1], chao_y - e[3]))
			"ponte_final":
				n_obrig += 3
				var gat2 := _area(Vector2(ponte_x1 - 280, chao_y - 150), Vector2(300, 300))
				gat2.body_entered.connect(_chegou_ponte)
			"fim":
				_bandeira_fim(e[1])


func _moeda(pos: Vector2) -> void:
	var m := Moeda.new()
	m.position = pos
	m.body_entered.connect(_pegou.bind(m))
	mundo.add_child(m)
	moedas_total += 1


func _jogador() -> void:
	jogador = Jogador.new()
	jogador.position = checkpoint
	if OS.has_environment("FAP_X"):
		jogador.position.x = float(OS.get_environment("FAP_X"))
	mundo.add_child(jogador)
	jogador.pulou.connect(func(): _tocar("pulo"))
	jogador.aterrissou.connect(_pousou)
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_right = int(fim_x + 600)
	camera.limit_top = 0
	camera.limit_bottom = 1080
	jogador.add_child(camera)


func _caminho() -> void:
	pergunta_caminho = Perguntas.embaralhar(fila_mc.pop_front())
	var alts: Array = pergunta_caminho["alternativas"].duplicate()
	alt_certa = alts[int(pergunta_caminho["correta"])]
	var outras: Array = alts.filter(func(a): return a != alt_certa)
	outras.shuffle()
	var tres: Array = [alt_certa, outras[0], outras[1]]
	tres.shuffle()
	for i in 3:
		var p := Plat.new()
		p.w = 240.0
		p.texto = tres[i]
		p.correta = (tres[i] == alt_certa)
		p.position = Vector2(caminho_x1 + 170.0 + i * 250.0, chao_y - 95)
		p.montar(true, true)
		mundo.add_child(p)
		plats.append(p)


func _checkpoint(x: float) -> void:
	var cp := Bandeira.new()
	cp.position = Vector2(x, chao_y)
	cp.cor = CLARO
	cp.escala = 0.6
	mundo.add_child(cp)
	var a := _area(Vector2(x, chao_y - 100), Vector2(120, 260))
	a.body_entered.connect(func(b):
		if b == jogador and checkpoint.x < x:
			checkpoint = Vector2(x, chao_y)
			_tocar("checkpoint")
			aviso("Checkpoint! Se cair, você volta aqui.", 2.5)
			cp.ativa = true)


func _bandeira_fim(x: float) -> void:
	var fim := Bandeira.new()
	fim.final = true
	fim.position = Vector2(x, chao_y)
	mundo.add_child(fim)
	var af := _area(Vector2(x, chao_y - 150), Vector2(160, 400))
	af.body_entered.connect(func(b):
		if b == jogador and estado == "jogo":
			_terminar())


func _placa(texto: String, pos: Vector2) -> void:
	var l := Label.new()
	l.text = texto
	l.position = pos
	l.add_theme_font_size_override("font_size", 28)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_stylebox_override("normal", _estilo(Color(0.04, 0.23, 0.43, 0.88), 18, CLARO, 4, 18))
	mundo.add_child(l)


# ====================================================================== interface
func _estilo(cor: Color, raio := 16, borda := Color.TRANSPARENT, larg_borda := 0, margem := 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = cor
	s.set_corner_radius_all(raio)
	if larg_borda > 0:
		s.border_color = borda
		s.set_border_width_all(larg_borda)
	if margem > 0:
		s.set_content_margin_all(margem)
	return s


func _rotulo(texto: String, tam: int, cor := Color.WHITE, contorno := true) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", cor)
	if contorno:
		l.add_theme_color_override("font_outline_color", NOITE)
		l.add_theme_constant_override("outline_size", 10)
	return l


func _criar_ui() -> void:
	ui = CanvasLayer.new()
	ui.layer = 10
	add_child(ui)

	flash = ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.color = Color(1, 0.1, 0.15, 0.0)
	ui.add_child(flash)

	coracoes = Coracoes.new()
	coracoes.position = Vector2(30, 24)
	coracoes.custom_minimum_size = Vector2(260, 80)
	ui.add_child(coracoes)
	var ico := TextureRect.new()
	ico.texture = load("res://assets/objetos/moeda_logo.png")
	ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	ico.position = Vector2(36, 108)
	ico.size = Vector2(52, 52)
	ui.add_child(ico)
	lbl_moedas = _rotulo("× 0", 44, OURO)
	lbl_moedas.position = Vector2(98, 100)
	ui.add_child(lbl_moedas)
	var cartao := Panel.new()
	cartao.position = Vector2(1920 - 400, 18)
	cartao.size = Vector2(370, 128)
	cartao.add_theme_stylebox_override("panel", _caixa_botao("azul"))
	ui.add_child(cartao)
	lbl_pontos = _rotulo("0", 64, OURO)
	lbl_pontos.position = Vector2(20, 2)
	lbl_pontos.size = Vector2(215, 76)
	lbl_pontos.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_pontos.add_theme_constant_override("outline_size", 8)
	cartao.add_child(lbl_pontos)
	var pts := _rotulo("PONTOS", 22, Color("#BFE8FF"), false)
	pts.position = Vector2(244, 38)
	cartao.add_child(pts)
	lbl_fase = _rotulo("Fase %d · %s" % [idx + 1, cid["nome"]], 26, Color.WHITE)
	lbl_fase.position = Vector2(30, 78)
	lbl_fase.size = Vector2(310, 36)
	lbl_fase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_fase.add_theme_constant_override("outline_size", 8)
	cartao.add_child(lbl_fase)

	hud_prog = Progresso.new()
	hud_prog.position = Vector2(540, 20)
	hud_prog.size = Vector2(840, 100)
	hud_prog.fim_x = fim_x
	for e in layout:
		if e[0] == "porta":
			hud_prog.marcas.append(e[1])
		elif e[0] == "caminho":
			hud_prog.marcas.append((e[1] + e[2]) / 2.0)
		elif e[0] == "ponte_final":
			hud_prog.marcas.append((e[1] + e[2]) / 2.0)
		elif e[0] == "checkpoint":
			hud_prog.checks.append(e[1])
	ui.add_child(hud_prog)

	aviso_painel = PanelContainer.new()
	aviso_painel.position = Vector2(360, 118)
	aviso_painel.custom_minimum_size = Vector2(1200, 0)
	aviso_painel.visible = false
	aviso_lbl = _rotulo("", 32, Color.WHITE, false)
	aviso_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	aviso_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso_painel.add_child(aviso_lbl)
	ui.add_child(aviso_painel)

	banner = PanelContainer.new()
	banner.add_theme_stylebox_override("panel", _estilo(Color(1, 0.83, 0.3, 0.96), 22, NOITE, 5, 18))
	banner.position = Vector2(360, 118)
	banner.custom_minimum_size = Vector2(1200, 0)
	banner.visible = false
	banner_lbl = _rotulo("", 36, NOITE, false)
	banner_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	banner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_child(banner_lbl)
	ui.add_child(banner)

	_criar_tela_pergunta()
	_criar_tela_fim()
	_criar_tela_pausa()
	# HUD fica por cima do escurecimento das telas (não "apaga" os pontos)
	for n in [coracoes, ico, lbl_moedas, cartao, hud_prog]:
		if n.get_parent() == ui:
			ui.move_child(n, -1)
	if OS.has_environment("FAP_PAUSA"):  # só para testes: abre a pausa sozinho
		get_tree().create_timer(1.0).timeout.connect(func():
			estado = "pausa"
			get_tree().paused = true
			tela_pausa.visible = true)


func _painel_arte() -> StyleBoxTexture:
	var sp := StyleBoxTexture.new()
	sp.texture = load("res://assets/ui/painel.png")
	sp.texture_margin_left = 62
	sp.texture_margin_right = 62
	sp.texture_margin_top = 58
	sp.texture_margin_bottom = 58
	sp.set_content_margin_all(64)
	return sp


func _caixa_botao(tipo: String, tom := Color.WHITE) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = load("res://assets/ui/botao_%s.png" % tipo)
	sb.texture_margin_left = 46
	sb.texture_margin_right = 46
	sb.texture_margin_top = 34
	sb.texture_margin_bottom = 34
	sb.content_margin_left = 40
	sb.content_margin_right = 30
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	sb.modulate_color = tom
	return sb


func _tela_cheia(escuro: float) -> Control:
	var t := Control.new()
	t.set_anchors_preset(Control.PRESET_FULL_RECT)
	t.visible = false
	var fundo := ColorRect.new()
	fundo.color = Color(0.02, 0.06, 0.14, escuro)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	t.add_child(fundo)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.add_child(centro)
	ui.add_child(t)
	return t


func _criar_tela_pergunta() -> void:
	tela_perg = _tela_cheia(0.45)
	fundo_perg = TextureRect.new()
	fundo_perg.texture = load("res://assets/%s/2_meio.png" % cid["id"])
	fundo_perg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fundo_perg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fundo_perg.set_anchors_preset(Control.PRESET_FULL_RECT)
	fundo_perg.modulate = Color(1, 1, 1, 0.55)
	fundo_perg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tela_perg.add_child(fundo_perg)
	tela_perg.move_child(fundo_perg, 0)
	var painel := PanelContainer.new()
	painel_perg = painel
	var sp := StyleBoxTexture.new()
	sp.texture = load("res://assets/ui/painel.png")
	sp.texture_margin_left = 62
	sp.texture_margin_right = 62
	sp.texture_margin_top = 58
	sp.texture_margin_bottom = 58
	sp.set_content_margin_all(60)
	painel.add_theme_stylebox_override("panel", sp)
	painel.custom_minimum_size = Vector2(1400, 0)
	tela_perg.get_child(2).add_child(painel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	painel.add_child(v)
	var cab := HBoxContainer.new()
	cab.add_theme_constant_override("separation", 20)
	v.add_child(cab)
	lbl_tema = _rotulo("", 28, CLARO, false)
	lbl_tema.add_theme_stylebox_override("normal", _estilo(Color(0.1, 0.35, 0.65), 22, Color(1, 1, 1, 0.5), 3, 14))
	lbl_tema.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	lbl_tema.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cab.add_child(lbl_tema)
	var esp := Control.new()
	esp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cab.add_child(esp)
	var marca := TextureRect.new()
	marca.texture = load("res://assets/logos/adventista_branco.png")
	marca.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	marca.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	marca.custom_minimum_size = Vector2(64, 58)
	marca.modulate = Color(1, 1, 1, 0.9)
	cab.add_child(marca)
	var placa := PanelContainer.new()
	var sbp := StyleBoxFlat.new()
	sbp.bg_color = Color(0.02, 0.08, 0.22, 0.6)
	sbp.set_corner_radius_all(24)
	sbp.border_color = Color(1.0, 0.83, 0.3, 0.55)
	sbp.set_border_width_all(3)
	sbp.content_margin_left = 36
	sbp.content_margin_right = 36
	sbp.content_margin_top = 22
	sbp.content_margin_bottom = 26
	placa.add_theme_stylebox_override("panel", sbp)
	v.add_child(placa)
	lbl_perg = _rotulo("", 58, Color.WHITE, false)
	lbl_perg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_perg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placa.add_child(lbl_perg)
	for i in 4:
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 88)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("font_size", 38)
		b.add_theme_color_override("font_color", Color.WHITE)
		b.add_theme_color_override("font_hover_color", Color.WHITE)
		b.add_theme_color_override("font_disabled_color", Color.WHITE)
		b.add_theme_stylebox_override("normal", _caixa_botao("azul"))
		b.add_theme_stylebox_override("hover", _caixa_botao("dourado"))
		b.add_theme_stylebox_override("pressed", _caixa_botao("dourado"))
		b.add_theme_stylebox_override("disabled", _caixa_botao("azul"))
		b.add_theme_color_override("font_hover_color", Color("#14213D"))
		b.add_theme_color_override("font_pressed_color", Color("#14213D"))
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		b.pressed.connect(_responder.bind(i))
		v.add_child(b)
		botoes.append(b)
	barra = ProgressBar.new()
	barra.custom_minimum_size = Vector2(0, 22)
	barra.show_percentage = false
	barra.max_value = TEMPO_PERGUNTA
	barra.add_theme_stylebox_override("background", _estilo(Color(0, 0, 0, 0.35), 11, Color(1, 1, 1, 0.25), 2))
	fill_tempo = _estilo(VERDE, 11)
	barra.add_theme_stylebox_override("fill", fill_tempo)
	v.add_child(barra)
	var dica_perg := _rotulo("↑ ↓ escolher     Espaço confirmar     (ou tecla 1 a 4)", 24, Color(1, 1, 1, 0.7), false)
	dica_perg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(dica_perg)
	lbl_feed = _rotulo("", 32, Color.WHITE, false)
	lbl_feed.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(lbl_feed)
	lbl_cont = _rotulo("Aperte ESPAÇO para continuar", 28, OURO, false)
	lbl_cont.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_child(lbl_cont)


func _criar_tela_fim() -> void:
	tela_fim = _tela_cheia(0.7)
	var painel := PanelContainer.new()
	painel.add_theme_stylebox_override("panel", _painel_arte())
	painel.custom_minimum_size = Vector2(1200, 0)
	tela_fim.get_child(1).add_child(painel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 18)
	painel.add_child(v)
	fim_titulo = _rotulo("", 64, Color.WHITE)
	fim_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(fim_titulo)
	fim_estrelas = _rotulo("", 110, OURO)
	fim_estrelas.visible = false
	v.add_child(fim_estrelas)
	fim_ctl = Estrelas.new()
	fim_ctl.raio = 92.0
	fim_ctl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(fim_ctl)
	fim_texto = _rotulo("", 34, Color.WHITE, false)
	fim_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fim_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(fim_texto)
	fim_dica = _rotulo("", 28, CLARO, false)
	fim_dica.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fim_dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(fim_dica)
	var dica := _rotulo("Espaço: continuar     M: mapa", 30, OURO, false)
	dica.name = "dica_teclas"
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(dica)


func _criar_tela_pausa() -> void:
	tela_pausa = _tela_cheia(0.6)
	var painel := PanelContainer.new()
	painel.add_theme_stylebox_override("panel", _painel_arte())
	painel.custom_minimum_size = Vector2(900, 0)
	tela_pausa.get_child(1).add_child(painel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 20)
	painel.add_child(v)
	var t := _rotulo("Pausado", 84, OURO)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	var ic := Label.new()
	ic.text = "Respire, estude e volte com tudo!"
	ic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ic.add_theme_font_size_override("font_size", 30)
	ic.add_theme_color_override("font_color", CLARO)
	v.add_child(ic)
	for par in [["Espaço", "continuar"], ["R", "reiniciar a fase"], ["M", "voltar ao mapa"], ["N", "música liga/desliga"]]:
		var linha := HBoxContainer.new()
		linha.add_theme_constant_override("separation", 24)
		linha.alignment = BoxContainer.ALIGNMENT_CENTER
		var tecla := Label.new()
		tecla.text = par[0]
		tecla.custom_minimum_size = Vector2(190, 70)
		tecla.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tecla.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		tecla.add_theme_font_size_override("font_size", 38)
		tecla.add_theme_color_override("font_color", NOITE)
		var sk := StyleBoxFlat.new()
		sk.bg_color = Color("#FFF2C6")
		sk.set_corner_radius_all(16)
		sk.border_color = Color("#C9A227")
		sk.set_border_width_all(4)
		sk.border_width_bottom = 10
		tecla.add_theme_stylebox_override("normal", sk)
		linha.add_child(tecla)
		var txt := _rotulo(par[1], 42, Color.WHITE, false)
		txt.custom_minimum_size = Vector2(380, 70)
		txt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		linha.add_child(txt)
		v.add_child(linha)


func _atualizar_hud() -> void:
	coracoes.cheios = vidas
	coracoes.queue_redraw()
	lbl_moedas.text = "× %d" % moedas
	lbl_pontos.text = "%d" % pontos


func aviso(texto: String, dur := 3.0, erro := false) -> void:
	aviso_id += 1
	var meu := aviso_id
	aviso_painel.add_theme_stylebox_override("panel", _estilo(Color(0.55, 0.08, 0.12, 0.96) if erro else Color(0.04, 0.23, 0.43, 0.93), 22, Color.WHITE if erro else CLARO, 4, 20))
	aviso_lbl.text = texto
	aviso_painel.visible = true
	aviso_painel.modulate.a = 0.0
	create_tween().tween_property(aviso_painel, "modulate:a", 1.0, 0.18)
	get_tree().create_timer(dur).timeout.connect(func():
		if meu == aviso_id:
			aviso_painel.visible = false)


# ====================================================================== sons e efeitos
func _criar_sons() -> void:
	for n in ["pulo", "moeda", "acerto", "erro", "dano", "porta", "vitoria", "pouso", "bloco", "checkpoint"]:
		var p := AudioStreamPlayer.new()
		p.stream = load("res://assets/sons/%s.wav" % n)
		p.volume_db = -6.0
		add_child(p)
		sons[n] = p


func _tocar(nome: String) -> void:
	if sons.has(nome):
		sons[nome].play()


func _flash(cor: Color) -> void:
	flash.color = cor
	create_tween().tween_property(flash, "color:a", 0.0, 0.55)


func _tremer(f: float) -> void:
	tremor = maxf(tremor, f)


func _particulas(pos: Vector2, cor: Color, qtd: int, vel: float, vida := 0.5, grav := 600.0, cima := true) -> void:
	var c := CPUParticles2D.new()
	c.position = pos
	c.emitting = true
	c.one_shot = true
	c.amount = qtd
	c.lifetime = vida
	c.explosiveness = 1.0
	c.direction = Vector2(0, -1) if cima else Vector2(0, -0.2)
	c.spread = 70.0 if cima else 180.0
	c.initial_velocity_min = vel * 0.5
	c.initial_velocity_max = vel
	c.gravity = Vector2(0, grav)
	c.scale_amount_min = 6.0
	c.scale_amount_max = 11.0
	c.color = cor
	mundo.add_child(c)
	get_tree().create_timer(vida + 0.3).timeout.connect(c.queue_free)


func _texto_flutuante(texto: String, pos: Vector2, cor := OURO) -> void:
	var l := _rotulo(texto, 44, cor)
	l.position = pos - Vector2(40, 40)
	mundo.add_child(l)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 90, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tw.chain().tween_callback(l.queue_free)


func _pousou(forte: bool) -> void:
	_particulas(jogador.global_position, Color(0.95, 0.92, 0.85, 0.9), 10 if forte else 5, 220.0 if forte else 130.0, 0.4, 500.0, false)
	if forte:
		_tocar("pouso")
		_tremer(0.25)


# ====================================================================== lógica
func _pegou(corpo: Node, m: Area2D) -> void:
	if corpo != jogador or not is_instance_valid(m):
		return
	moedas += 1
	pontos += 10
	_tocar("moeda")
	_particulas(m.global_position, OURO, 12, 380.0, 0.5, 700.0, false)
	_texto_flutuante("+10", m.global_position)
	m.queue_free()
	_atualizar_hud()


func perder_vida(origem_x := NAN) -> void:
	if OS.get_environment("FAP_DEMO") == "1":
		return   # modo de demonstração: não morre
	vidas -= 1
	_tocar("dano")
	_tremer(0.7)
	jogador.dano(origem_x)
	_atualizar_hud()
	_texto_flutuante("-1 coração", jogador.global_position + Vector2(0, -300), VERMELHO)
	coracoes.pivot_offset = Vector2(60, 40)
	coracoes.scale = Vector2(1.5, 1.5)
	create_tween().tween_property(coracoes, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if vidas <= 0:
		_fim_de_jogo()


func _caiu(corpo: Node) -> void:
	if corpo != jogador:
		return
	_particulas(Vector2(corpo.global_position.x, chao_y + 40), CLARO if cid["agua"] else Color(0.5, 0.4, 0.3), 14, 500.0, 0.6, 900.0)
	if not queda_livre:
		perder_vida()
		aviso("Caiu! Você volta ao último checkpoint.", 2.5)
	queda_livre = false
	if vidas > 0:
		jogador.global_position = checkpoint
		jogador.velocity = Vector2.ZERO


func _bateu(corpo: Node, ini) -> void:
	if corpo != jogador or not is_instance_valid(ini) or not ini.vivo or estado != "jogo":
		return
	var de_cima: bool = jogador.velocity.y > 50.0 and jogador.global_position.y < ini.global_position.y - (40.0 if ini.tipo == "preguica" else 10.0)
	if de_cima:
		ini.vivo = false
		pontos += 50
		jogador.velocity.y = -780.0
		_tocar("pouso")
		_particulas(ini.global_position + Vector2(0, -30), Color(0.7, 0.55, 0.9), 12, 350.0, 0.5)
		_texto_flutuante("+50", ini.global_position + Vector2(0, -60))
		_atualizar_hud()
		var tw := create_tween()
		tw.tween_property(ini, "scale", Vector2(1.4, 0.1), 0.12)
		tw.tween_callback(ini.queue_free)
	elif jogador.invencivel <= 0.0:
		perder_vida(ini.global_position.x)


func _chegou_porta(corpo: Node, porta: Node) -> void:
	if corpo != jogador or porta.usada or estado != "jogo":
		return
	porta.usada = true
	var q: Dictionary = Perguntas.embaralhar(fila_mc.pop_front())
	_perguntar(q, false, func(ok: bool):
		feitos += 1
		if ok:
			pontos += 200
			acertos += 1
			_atualizar_hud()
		porta.abrir()
		_tocar("porta")
		_tremer(0.4)
		_particulas(porta.global_position + Vector2(0, -170), Color(0.8, 0.8, 0.8, 0.9), 14, 260.0, 0.6, 400.0, false))


func _bater_bloco(b) -> void:
	b.usado = true
	b.queue_redraw()
	_tocar("bloco")
	var tw := create_tween()
	tw.tween_property(b, "position:y", b.position.y - 18, 0.07)
	tw.tween_property(b, "position:y", b.position.y, 0.09)
	if fila_vf.is_empty():
		return
	var q: Dictionary = fila_vf.pop_front()
	_perguntar(q, true, func(ok: bool):
		if ok:
			pontos += 100
			_atualizar_hud()
			_texto_flutuante("+100", b.global_position + Vector2(0, -80))
			_particulas(b.global_position + Vector2(0, -50), OURO, 16, 420.0, 0.6))


func _perguntar(q: Dictionary, bonus: bool, cb: Callable) -> void:
	estado = "pergunta"
	Jogo.abafar(true)
	get_tree().paused = true
	jogador.travado = true
	perg_atual = q
	perg_cb = cb
	perg_bonus = bonus
	perg_n = q["alternativas"].size()
	tempo = TEMPO_PERGUNTA
	var tema: String = String(q["tema"]).replace("matematica", "matemática").replace("portugues", "português").replace("ciencias", "ciências").replace("historia", "história").replace("logica", "lógica").replace("biblia", "bíblia").to_upper()
	if bonus:
		tema = "BLOCO BÔNUS  ·  " + tema + "  (sem perder coração)"
	else:
		tema = "DESAFIO %d DE %d  ·  %s" % [mini(feitos + 1, n_obrig), n_obrig, tema]
	lbl_tema.text = tema + ("   ·   " + str(q["referencia"]) if q.has("referencia") else "")
	lbl_perg.text = q["pergunta"]
	var cores := {"matematica": "#E07B1F", "portugues": "#C8344B", "ciencias": "#2E9E5B", "historia": "#9A6A3A", "geografia": "#1E8FA8", "tecnologia": "#2A74CC", "logica": "#7A4FBF", "biblia": "#C9A227"}
	var cc := Color(cores.get(String(q["tema"]), "#1B5AA6"))
	lbl_tema.add_theme_stylebox_override("normal", _estilo(cc, 22, Color(1, 1, 1, 0.55), 3, 14))
	lbl_tema.add_theme_color_override("font_color", Color.WHITE)
	for i in 4:
		botoes[i].visible = i < perg_n
		if i < perg_n:
			botoes[i].text = "%d   %s" % [i + 1, q["alternativas"][i]]
			botoes[i].disabled = false
			botoes[i].add_theme_stylebox_override("disabled", _caixa_botao("azul"))
	lbl_feed.text = ""
	lbl_feed.visible = false
	_selecionar(0)
	lbl_cont.visible = false
	barra.visible = true
	barra.value = TEMPO_PERGUNTA
	tela_perg.visible = true
	tela_perg.modulate.a = 0.0
	create_tween().tween_property(tela_perg, "modulate:a", 1.0, 0.2)


func _responder(i: int) -> void:
	if estado != "pergunta" or i >= perg_n:
		return
	estado = "feedback"
	var certa := int(perg_atual["correta"])
	perg_ok = (i == certa)
	for k in perg_n:
		botoes[k].disabled = true
	botoes[certa].add_theme_stylebox_override("disabled", _caixa_botao("azul", Color(0.55, 1.5, 0.65)))
	if not perg_ok and i >= 0:
		botoes[i].add_theme_stylebox_override("disabled", _caixa_botao("azul", Color(1.7, 0.5, 0.5)))
	barra.visible = false
	var expl: String = perg_atual["explicacao"]
	if perg_ok:
		lbl_feed.visible = true
		lbl_feed.text = "Isso mesmo! " + expl
		_tocar("acerto")
	else:
		lbl_feed.visible = true
		lbl_feed.text = ("Tempo esgotado! " if i < 0 else "Quase! ") + "A resposta certa é \"%s\". %s" % [perg_atual["alternativas"][certa], expl]
		_tocar("erro")
		_flash(Color(1, 0.1, 0.15, 0.35))
		if not perg_bonus:
			perder_vida()
	lbl_cont.visible = true


func _continuar() -> void:
	Jogo.abafar(false)
	tela_perg.visible = false
	get_tree().paused = false
	jogador.travado = true
	get_tree().create_timer(0.15).timeout.connect(func():
		if estado == "jogo":
			jogador.travado = false)
	if vidas <= 0:
		return
	estado = "jogo"
	perg_cb.call(perg_ok)


func _escolher_plat(p) -> void:
	cooldown = 1.3
	if p.correta:
		caminho_resolvido = true
		feitos += 1
		acertos += 1
		pontos += 200
		p.cor = VERDE
		p.queue_redraw()
		_tocar("acerto")
		_particulas(p.global_position + Vector2(0, -20), VERDE, 16, 400.0, 0.6)
		_flash(Color(0.2, 0.9, 0.4, 0.25))
		_texto_flutuante("Certo! +200", p.global_position + Vector2(-110, -170), VERDE)
		_atualizar_hud()
		aviso("Isso! " + str(pergunta_caminho["explicacao"]), 4.5)
		_ponte_caminho()
		banner.visible = false
	else:
		p.cor = VERMELHO
		p.queue_redraw()
		_tocar("erro")
		_tremer(0.6)
		_flash(Color(1, 0.1, 0.15, 0.4))
		_texto_flutuante("Ops! Não é essa", p.global_position + Vector2(-110, -170), VERMELHO)
		_particulas(p.global_position + Vector2(0, -10), VERMELHO, 14, 380.0, 0.5)
		var x0: float = p.position.x
		var sac := create_tween()
		for k in 6:
			sac.tween_property(p, "position:x", x0 + (12.0 if k % 2 == 0 else -12.0), 0.045)
		sac.tween_property(p, "position:x", x0, 0.045)
		for outra in plats:
			if is_instance_valid(outra) and outra.correta:
				outra.destaque = true   # a certa brilha: o jogador aprende
		if primeiro_erro_caminho:
			primeiro_erro_caminho = false
			perder_vida()
		queda_livre = true
		aviso("Errou! A resposta certa é \"%s\" (está brilhando). %s" % [alt_certa, pergunta_caminho["explicacao"]], 5.5, true)
		get_tree().create_timer(0.55).timeout.connect(func(): _cair(p))


func _cair(p) -> void:
	if not is_instance_valid(p):
		return
	p.vivo = false
	p.shape.set_deferred("disabled", true)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(p, "position:y", p.position.y + 700, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(p, "modulate:a", 0.0, 0.8)
	tw.chain().tween_callback(p.queue_free)


func _ponte_caminho() -> void:
	_pedaco_ponte((caminho_x1 + caminho_x2) / 2.0, caminho_x2 - caminho_x1 + 40.0)


func _pedaco_ponte(cx: float, larg: float) -> void:
	var b := Plat.new()
	b.w = larg
	b.h = 70
	b.cor = Color("#8B5A2B")
	b.position = Vector2(cx, chao_y + 120)
	b.montar(false, false)
	b.modulate.a = 0.0
	mundo.add_child(b)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(b, "position:y", chao_y, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(b, "modulate:a", 1.0, 0.4)


## Ponte do Conhecimento (fase final): 3 perguntas seguidas, cada uma monta um pedaço
func _chegou_ponte(corpo: Node) -> void:
	if corpo != jogador or ponte_iniciada or estado != "jogo":
		return
	ponte_iniciada = true
	aviso("Ponte do Conhecimento: cada resposta monta um pedaço da ponte!", 3.0)
	_pergunta_ponte()


func _pergunta_ponte() -> void:
	var q: Dictionary = Perguntas.embaralhar(fila_mc.pop_front())
	_perguntar(q, false, func(ok: bool):
		feitos += 1
		if ok:
			pontos += 200
			acertos += 1
			_atualizar_hud()
		var larg := (ponte_x2 - ponte_x1) / 3.0
		_pedaco_ponte(ponte_x1 + larg * (ponte_seg + 0.5), larg + 4.0)
		_tocar("porta")
		_tremer(0.4)
		ponte_seg += 1
		if ponte_seg < 3:
			jogador.travado = true
			_pergunta_ponte()
		else:
			aviso("Ponte completa! A bandeira está do outro lado.", 3.5))


func _fim_de_jogo() -> void:
	Jogo.abafar(true)
	estado = "fim"
	venceu = false
	jogador.travado = true
	fim_titulo.text = "Fim de jogo"
	fim_estrelas.visible = false
	fim_ctl.visible = false
	fim_texto.text = "Você chegou até aqui com %d pontos. Quem tenta de novo aprende mais!" % pontos
	fim_dica.text = ""
	tela_fim.find_child("dica_teclas", true, false).text = "Espaço: tentar de novo     M: mapa"
	tela_fim.visible = true
	tela_perg.visible = false
	get_tree().paused = false


func _terminar() -> void:
	Jogo.abafar(true)
	estado = "fim"
	venceu = true
	jogador.travado = true
	pontos += vidas * 100
	_tocar("vitoria")
	var est := 1
	if n_obrig > 0 and acertos * 10 >= n_obrig * 7:
		est = 2
	if acertos >= n_obrig and moedas >= int(moedas_total * 0.8):
		est = 3
	Jogo.registrar(idx, est, pontos)
	fim_titulo.text = "%s concluída!" % cid["nome"]
	fim_ctl.visible = true
	fim_ctl.n = est
	fim_texto.text = "%d de %d desafios certos   ·   %d de %d moedas\n%d corações   ·   %d pontos" % [acertos, n_obrig, moedas, moedas_total, vidas, pontos]
	fim_dica.text = "Você sabia? " + str(cid["dica"])
	tela_fim.find_child("dica_teclas", true, false).text = ("Espaço: próxima fase     M: mapa" if idx < 4 else "Espaço: ver meu prêmio     M: mapa")
	_atualizar_hud()
	get_tree().create_timer(0.9).timeout.connect(func():
		tela_fim.visible = true
		fim_ctl.animar()
		tela_fim.modulate.a = 0.0
		create_tween().tween_property(tela_fim, "modulate:a", 1.0, 0.4))
	for i in 3:
		get_tree().create_timer(0.15 + i * 0.55).timeout.connect(func():
			if is_instance_valid(jogador):
				jogador.velocity.y = -800.0
				jogador.travado = true)
	_particulas(jogador.global_position + Vector2(0, -200), OURO, 40, 700.0, 1.2, 500.0)


func _ir_mapa() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://mapa.tscn")


var perg_sel := 0
var fim_ctl: Estrelas


## destaca a alternativa escolhida com as setas (fica dourada)
func _selecionar(i: int) -> void:
	perg_sel = i
	for k in 4:
		var b: Button = botoes[k]
		b.add_theme_stylebox_override("normal", _caixa_botao("dourado") if k == i else _caixa_botao("azul"))
		b.add_theme_color_override("font_color", Color("#14213D") if k == i else Color.WHITE)


func _unhandled_input(ev: InputEvent) -> void:
	var tecla: int = ev.physical_keycode if ev is InputEventKey and ev.pressed and not ev.echo else -1
	if estado == "pergunta" and tecla >= KEY_1 and tecla <= KEY_4:
		_responder(tecla - KEY_1)
		get_viewport().set_input_as_handled()
	elif estado == "pergunta" and (tecla == KEY_UP or tecla == KEY_LEFT or tecla == KEY_W or tecla == KEY_A):
		_selecionar(posmod(perg_sel - 1, perg_n))
		get_viewport().set_input_as_handled()
	elif estado == "pergunta" and (tecla == KEY_DOWN or tecla == KEY_RIGHT or tecla == KEY_S or tecla == KEY_D):
		_selecionar(posmod(perg_sel + 1, perg_n))
		get_viewport().set_input_as_handled()
	elif estado == "pergunta" and ev.is_action_pressed("confirmar"):
		_responder(perg_sel)
		get_viewport().set_input_as_handled()
	elif estado == "feedback" and ev.is_action_pressed("confirmar"):
		_continuar()
		get_viewport().set_input_as_handled()
	elif estado == "fim" and tela_fim.visible:
		if ev.is_action_pressed("confirmar"):
			get_tree().paused = false
			if venceu:
				if idx < 4:
					Jogo.cidade_atual = idx + 1
					get_tree().change_scene_to_file("res://mapa.tscn")
				else:
					get_tree().change_scene_to_file("res://final.tscn")
			else:
				get_tree().reload_current_scene()
		elif tecla == KEY_M or tecla == KEY_ESCAPE:
			_ir_mapa()
	elif estado == "jogo" and ev.is_action_pressed("pausar"):
		estado = "pausa"
		Jogo.abafar(true)
		get_tree().paused = true
		tela_pausa.visible = true
	elif estado == "pausa":
		if ev.is_action_pressed("pausar") or ev.is_action_pressed("confirmar"):
			estado = "jogo"
			Jogo.abafar(false)
			get_tree().paused = false
			tela_pausa.visible = false
		elif tecla == KEY_R:
			get_tree().paused = false
			get_tree().reload_current_scene()
		elif tecla == KEY_M:
			_ir_mapa()


func _physics_process(delta: float) -> void:
	cooldown -= delta
	if estado != "jogo":
		return
	if tem_caminho and not caminho_resolvido and cooldown <= 0.0:
		# a resposta só vale se o jogador FICAR na plataforma (0,7 s): pousar de passagem não conta
		var em = null
		if jogador.is_on_floor():
			for p in plats:
				if is_instance_valid(p) and p.vivo and p.sensor.overlaps_body(jogador):
					em = p
					break
		if em != dwell_plat:
			if is_instance_valid(dwell_plat):
				dwell_plat.progresso = 0.0
				dwell_plat.queue_redraw()
			dwell_plat = em
			dwell_t = 0.0
		if em != null:
			dwell_t += delta
			em.progresso = minf(dwell_t / DWELL, 1.0)
			em.queue_redraw()
			if dwell_t >= DWELL:
				dwell_plat = null
				em.progresso = 0.0
				_escolher_plat(em)
	if not jogador.is_on_floor():
		for b in blocos:
			if not b.usado and b.sensor.overlaps_body(jogador):
				_bater_bloco(b)
				break
	var x: float = jogador.global_position.x
	var areia := false
	for a in areias:
		if x > a[0] and x < a[1]:
			areia = true
	jogador.aceleracao = 1300.0 if areia else 3200.0
	jogador.freio = 650.0 if areia else 3000.0


func _process(delta: float) -> void:
	if estado == "pergunta":
		tempo -= delta
		barra.value = tempo
		fill_tempo.bg_color = VERDE if tempo > 10.0 else (OURO if tempo > 5.0 else VERMELHO)
		if tempo <= 0.0:
			_responder(-1)
	var x: float = jogador.global_position.x
	var na_zona := tem_caminho and x > caminho_x1 - 650.0 and x < caminho_x2 and not caminho_resolvido and estado == "jogo"
	banner.visible = na_zona
	if na_zona:
		banner_lbl.text = "%s   →   pule na certa e fique nela!" % pergunta_caminho["pergunta"]
	hud_prog.x_jog = x
	hud_prog.feitos = feitos
	hud_prog.total = n_obrig
	hud_prog.queue_redraw()
	olhar = lerpf(olhar, float(jogador.olhando) * 140.0, 1.0 - exp(-3.0 * delta))
	tremor = maxf(0.0, tremor - delta * 2.2)
	camera.offset = Vector2(olhar, 0) + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * tremor * 22.0
	_demo(delta)


## modo de demonstração: FAP_DEMO=1 joga sozinho acertando tudo; FAP_DEMO=erro erra de propósito
func _demo(delta: float) -> void:
	if not OS.has_environment("FAP_DEMO"):
		return
	var errar := OS.get_environment("FAP_DEMO") == "erro"
	demo_t += delta
	if estado == "pergunta" and demo_t > 0.8:
		var c := int(perg_atual["correta"])
		_responder((c + 1) % perg_n if errar else c)
		demo_t = 0.0
	elif estado == "feedback" and demo_t > 1.0:
		_continuar()
		demo_t = 0.0
	elif estado == "jogo":
		var x: float = jogador.global_position.x
		Input.action_press("mover_direita")
		Input.action_press("correr")
		if int(demo_t * 1000.0) % 1400 < 40:
			Input.action_press("pular")
		elif int(demo_t * 1000.0) % 1400 > 350:
			Input.action_release("pular")
		# atravessa buracos "de graça" (a demo não sabe pular com precisão)
		for p in pocos:
			if (not tem_caminho or p["x1"] != caminho_x1) and (not tem_ponte or p["x1"] != ponte_x1):
				if x > p["x1"] - 140.0 and x < p["x1"] and not demo_pulou.has(p["x1"]):
					demo_pulou.append(p["x1"])
					jogador.global_position = Vector2(p["x2"] + 90.0, chao_y)
		if tem_caminho and not caminho_resolvido and not demo_tp and x > caminho_x1 - 100.0:
			demo_tp = true
			for p in plats:
				if p.correta != errar:
					jogador.global_position = p.global_position + Vector2(0, -4)
					jogador.velocity = Vector2.ZERO
					break


# ====================================================================== objetos
class Moeda extends Area2D:
	const GIRO := preload("res://assets/objetos/moeda_giro.png")
	const N := 32
	var t := randf() * 6.0

	func _ready() -> void:
		var f := CollisionShape2D.new()
		var r := CircleShape2D.new()
		r.radius = 34.0
		f.shape = r
		add_child(f)

	func _process(d: float) -> void:
		t += d
		queue_redraw()

	func _draw() -> void:
		var q := int(t * 20.0) % N
		var fw := GIRO.get_width() / float(N)
		var y := sin(t * 2.5) * 6.0
		draw_texture_rect_region(GIRO, Rect2(-42, -42 + y, 84, 84), Rect2(q * fw, 0, fw, GIRO.get_height()))
		# brilho que pisca de vez em quando
		var b := maxf(0.0, sin(t * 2.0 + 1.3) - 0.8) * 5.0
		if b > 0.0:
			draw_circle(Vector2(-14, -16 + y), 6.0 * b, Color(1, 1, 0.9, 0.9))


class Porta extends StaticBody2D:
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


class Bloco extends StaticBody2D:
	const TEX := preload("res://assets/objetos/bloco.png")
	var usado := false
	var sensor: Area2D
	var t := randf() * 6.0

	func _ready() -> void:
		var f := CollisionShape2D.new()
		var r := RectangleShape2D.new()
		r.size = Vector2(90, 90)
		f.shape = r
		add_child(f)
		sensor = Area2D.new()
		var fs := CollisionShape2D.new()
		var rs := RectangleShape2D.new()
		rs.size = Vector2(70, 40)
		fs.shape = rs
		fs.position = Vector2(0, 62)
		sensor.add_child(fs)
		add_child(sensor)

	func _process(d: float) -> void:
		t += d
		if not usado:
			queue_redraw()

	func _draw() -> void:
		var bri := 0.5 + 0.5 * sin(t * 4.0)
		var cor := Color(0.55, 0.55, 0.6) if usado else Color(1, 1, 1).lerp(Color(1.12, 1.08, 0.9), bri)
		draw_texture_rect(TEX, Rect2(-50, -50, 100, 98), false, cor)
		if not usado:
			var b2 := maxf(0.0, sin(t * 2.0 + 1.0))
			var cx := -26.0 + fmod(t * 20.0, 52.0)
			draw_line(Vector2(cx - 8, 30), Vector2(cx + 8, -30), Color(1, 1, 1, 0.25 * b2), 10.0)

class Inimigo extends Area2D:
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

class Tronco extends AnimatableBody2D:
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

class Abismo extends Node2D:
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

class Plat extends StaticBody2D:
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


class Bandeira extends Node2D:
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


class Progresso extends Control:
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


class Coracoes extends Control:
	const TEX := preload("res://assets/objetos/coracao.png")
	var cheios := 3
	var total := 3

	func _draw() -> void:
		for i in total:
			var cor := Color(1, 1, 1, 1) if i < cheios else Color(0.1, 0.1, 0.15, 0.45)
			draw_texture_rect(TEX, Rect2(10 + i * 84, 6, 72, 64), false, cor)

