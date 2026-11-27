extends Node2D
## Uma fase do jogo. Lê a cidade atual em Jogo.cidade_atual e monta tudo por código:
## cenário em parallax, chão com buracos, moedas, blocos "?", inimigos, portas-pergunta,
## "Caminho certo", troncos, telhados, areia, Ponte do Conhecimento, interface, sons e efeitos.

const Jogador := preload("res://scripts/jogador.gd")
const TEMPO_PERGUNTA := 20.0
const DWELL := 0.7


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
var demo_t := 0.0
var demo_tp := false
var demo_pulou: Array = []

# widgets
var hud: Hud
var avisos: Avisos
var tela_perg: TelaPergunta
var tela_fim: TelaFim
var tela_pausa: TelaPausa
var toque: ControlesToque       # botões na tela (só em aparelhos de toque)


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
				var p := PlataformaResposta.new()
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
		var p := PlataformaResposta.new()
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
	cp.cor = Paleta.CLARO
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
	l.add_theme_stylebox_override("normal", Estilos.caixa(Color(0.04, 0.23, 0.43, 0.88), 18, Paleta.CLARO, 4, 18))
	mundo.add_child(l)


# ====================================================================== interface
func _criar_ui() -> void:
	ui = CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	avisos = Avisos.new()
	ui.add_child(avisos)
	if ControlesToque.deve_aparecer():
		toque = ControlesToque.new()
		toque.pausar_pedido.connect(_pausar)
		ui.add_child(toque)
	tela_perg = TelaPergunta.new(cid["id"], TEMPO_PERGUNTA)
	tela_perg.escolheu.connect(_responder)
	tela_perg.continuou.connect(_continuar_se_feedback)
	ui.add_child(tela_perg)
	tela_fim = TelaFim.new()
	tela_fim.avancou.connect(_avancar_fim)
	tela_fim.foi_ao_mapa.connect(_ir_mapa)
	ui.add_child(tela_fim)
	tela_pausa = TelaPausa.new()
	tela_pausa.retomou.connect(_retomar)
	tela_pausa.reiniciou.connect(_reiniciar)
	tela_pausa.foi_ao_mapa.connect(_ir_mapa)
	ui.add_child(tela_pausa)
	# HUD por último: fica por cima do escurecimento das telas (não "apaga" os pontos)
	hud = Hud.new("Fase %d · %s" % [idx + 1, cid["nome"]], fim_x, layout)
	ui.add_child(hud)
	if OS.has_environment("FAP_PAUSA"):  # só para testes: abre a pausa sozinho
		get_tree().create_timer(1.0).timeout.connect(_pausar)


func _atualizar_hud() -> void:
	hud.atualizar(vidas, moedas, pontos)


func aviso(texto: String, dur := 3.0, erro := false) -> void:
	avisos.mostrar(texto, dur, erro)


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
	avisos.clarao(cor)


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


func _texto_flutuante(texto: String, pos: Vector2, cor := Paleta.OURO) -> void:
	var l := Estilos.rotulo(texto, 44, cor)
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
	_particulas(m.global_position, Paleta.OURO, 12, 380.0, 0.5, 700.0, false)
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
	_texto_flutuante("-1 coração", jogador.global_position + Vector2(0, -300), Paleta.VERMELHO)
	hud.pulsar_coracoes()
	if vidas <= 0:
		_fim_de_jogo()


func _caiu(corpo: Node) -> void:
	if corpo != jogador:
		return
	_particulas(Vector2(corpo.global_position.x, chao_y + 40), Paleta.CLARO if cid["agua"] else Color(0.5, 0.4, 0.3), 14, 500.0, 0.6, 900.0)
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
			_particulas(b.global_position + Vector2(0, -50), Paleta.OURO, 16, 420.0, 0.6))


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
	var rotulo_tema := tema + ("   ·   " + str(q["referencia"]) if q.has("referencia") else "")
	tela_perg.mostrar_pergunta(rotulo_tema, String(q["tema"]), q["pergunta"], q["alternativas"])
	tela_perg.atualizar_tempo(TEMPO_PERGUNTA)


func _responder(i: int) -> void:
	if estado != "pergunta" or i >= perg_n:
		return
	estado = "feedback"
	var certa := int(perg_atual["correta"])
	perg_ok = (i == certa)
	var expl: String = perg_atual["explicacao"]
	var mensagem := "Isso mesmo! " + expl
	if not perg_ok:
		mensagem = ("Tempo esgotado! " if i < 0 else "Quase! ") + "A resposta certa é \"%s\". %s" % [perg_atual["alternativas"][certa], expl]
	tela_perg.mostrar_resposta(i, certa, mensagem)
	if perg_ok:
		_tocar("acerto")
	else:
		_tocar("erro")
		_flash(Color(1, 0.1, 0.15, 0.35))
		if not perg_bonus:
			perder_vida()


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
		p.cor = Paleta.VERDE
		p.queue_redraw()
		_tocar("acerto")
		_particulas(p.global_position + Vector2(0, -20), Paleta.VERDE, 16, 400.0, 0.6)
		_flash(Color(0.2, 0.9, 0.4, 0.25))
		_texto_flutuante("Certo! +200", p.global_position + Vector2(-110, -170), Paleta.VERDE)
		_atualizar_hud()
		aviso("Isso! " + str(pergunta_caminho["explicacao"]), 4.5)
		_ponte_caminho()
		avisos.faixa("")
	else:
		p.cor = Paleta.VERMELHO
		p.queue_redraw()
		_tocar("erro")
		_tremer(0.6)
		_flash(Color(1, 0.1, 0.15, 0.4))
		_texto_flutuante("Ops! Não é essa", p.global_position + Vector2(-110, -170), Paleta.VERMELHO)
		_particulas(p.global_position + Vector2(0, -10), Paleta.VERMELHO, 14, 380.0, 0.5)
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
	var b := PlataformaResposta.new()
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
	tela_fim.mostrar_derrota(pontos)
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
	var teclas := Jogo.dica("Enter: próxima fase     M: mapa", "A: próxima fase     Y: mapa", "Cruz: próxima fase     Triângulo: mapa") if idx < 4 else Jogo.dica("Enter: ver meu prêmio     M: mapa", "A: ver meu prêmio     Y: mapa", "Cruz: ver meu prêmio     Triângulo: mapa")
	var resumo := "%d de %d desafios certos   ·   %d de %d moedas\n%d corações   ·   %d pontos" % [acertos, n_obrig, moedas, moedas_total, vidas, pontos]
	var acao := "Próxima fase" if idx < 4 else "Ver meu prêmio"
	tela_fim.mostrar_vitoria("%s concluída!" % cid["nome"], est, resumo, "Você sabia? " + str(cid["dica"]), teclas, acao)
	_atualizar_hud()
	for i in 3:
		get_tree().create_timer(0.15 + i * 0.55).timeout.connect(func():
			if is_instance_valid(jogador):
				jogador.velocity.y = -800.0
				jogador.travado = true)
	_particulas(jogador.global_position + Vector2(0, -200), Paleta.OURO, 40, 700.0, 1.2, 500.0)


## depois do fim da fase: vitória segue (próxima cidade ou prêmio); derrota tenta de novo
func _avancar_fim() -> void:
	get_tree().paused = false
	if not venceu:
		get_tree().reload_current_scene()
	elif idx < 4:
		Jogo.cidade_atual = idx + 1
		get_tree().change_scene_to_file("res://mapa.tscn")
	else:
		get_tree().change_scene_to_file("res://final.tscn")


func _reiniciar() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _continuar_se_feedback() -> void:
	if estado == "feedback":
		_continuar()


func _ir_mapa() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://mapa.tscn")




func _pausar() -> void:
	if estado != "jogo":
		return
	estado = "pausa"
	Jogo.abafar(true)
	get_tree().paused = true
	tela_pausa.visible = true


func _retomar() -> void:
	estado = "jogo"
	Jogo.abafar(false)
	get_tree().paused = false
	tela_pausa.visible = false


func _unhandled_input(ev: InputEvent) -> void:
	var tecla: int = ev.physical_keycode if ev is InputEventKey and ev.pressed and not ev.echo else -1
	if estado == "pergunta" and tecla >= KEY_1 and tecla <= KEY_4:
		_responder(tecla - KEY_1)
		get_viewport().set_input_as_handled()
	elif estado == "pergunta" and ev.is_action_pressed("nav_anterior"):
		tela_perg.mover(-1)
		get_viewport().set_input_as_handled()
	elif estado == "pergunta" and ev.is_action_pressed("nav_proximo"):
		tela_perg.mover(1)
		get_viewport().set_input_as_handled()
	elif estado == "pergunta" and ev.is_action_pressed("confirmar"):
		_responder(tela_perg.selecionada)
		get_viewport().set_input_as_handled()
	elif estado == "feedback" and ev.is_action_pressed("confirmar"):
		_continuar()
		get_viewport().set_input_as_handled()
	elif estado == "fim" and tela_fim.visible:
		if ev.is_action_pressed("confirmar"):
			_avancar_fim()
		elif ev.is_action_pressed("mapa") or ev.is_action_pressed("voltar"):
			_ir_mapa()
	elif estado == "jogo" and ev.is_action_pressed("pausar"):
		_pausar()
	elif estado == "pausa":
		if ev.is_action_pressed("pausar") or ev.is_action_pressed("confirmar"):
			_retomar()
		elif ev.is_action_pressed("reiniciar"):
			_reiniciar()
		elif ev.is_action_pressed("mapa"):
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
	if toque:
		toque.visible = estado == "jogo"
	if estado == "pergunta":
		tempo -= delta
		tela_perg.atualizar_tempo(tempo)
		if tempo <= 0.0:
			_responder(-1)
	var x: float = jogador.global_position.x
	var na_zona := tem_caminho and x > caminho_x1 - 650.0 and x < caminho_x2 and not caminho_resolvido and estado == "jogo"
	avisos.faixa("%s   →   pule na certa e fique nela!" % pergunta_caminho["pergunta"] if na_zona else "")
	hud.atualizar_progresso(x, feitos, n_obrig)
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
