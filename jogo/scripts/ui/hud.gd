class_name Hud
extends Control
## Painel fixo da fase: corações, moedas, pontos e barra de progresso.

var _coracoes: Coracoes
var _moedas: Label
var _pontos: Label
var _progresso: BarraProgresso


## `layout` é a lista de elementos da fase; dela saem as marcas de desafio e de checkpoint na barra.
func _init(nome_fase: String, fim_x: float, layout: Array) -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_criar_vidas_e_moedas()
	_criar_cartao_de_pontos(nome_fase)
	_criar_barra(fim_x, layout)


func atualizar(vidas: int, moedas: int, pontos: int) -> void:
	_coracoes.cheios = vidas
	_coracoes.queue_redraw()
	_moedas.text = "× %d" % moedas
	_pontos.text = "%d" % pontos


func atualizar_progresso(x_jogador: float, feitos: int, total: int) -> void:
	_progresso.x_jog = x_jogador
	_progresso.feitos = feitos
	_progresso.total = total
	_progresso.queue_redraw()


## os corações "pulam" quando se perde um
func pulsar_coracoes() -> void:
	_coracoes.pivot_offset = Vector2(60, 40)
	_coracoes.scale = Vector2(1.5, 1.5)
	create_tween().tween_property(_coracoes, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _criar_vidas_e_moedas() -> void:
	_coracoes = Coracoes.new()
	_coracoes.position = Vector2(30, 24)
	_coracoes.custom_minimum_size = Vector2(260, 80)
	add_child(_coracoes)
	var icone := TextureRect.new()
	icone.texture = load("res://assets/objetos/moeda_logo.png")
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	icone.position = Vector2(36, 108)
	icone.size = Vector2(52, 52)
	add_child(icone)
	_moedas = Estilos.rotulo("× 0", 44, Paleta.OURO)
	_moedas.position = Vector2(98, 100)
	add_child(_moedas)


func _criar_cartao_de_pontos(nome_fase: String) -> void:
	var cartao := Panel.new()
	cartao.position = Vector2(1920 - 400, 18)
	cartao.size = Vector2(370, 128)
	cartao.add_theme_stylebox_override("panel", Estilos.caixa_botao("azul"))
	add_child(cartao)
	_pontos = Estilos.rotulo("0", 64, Paleta.OURO)
	_pontos.position = Vector2(20, 2)
	_pontos.size = Vector2(215, 76)
	_pontos.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_pontos.add_theme_constant_override("outline_size", 8)
	cartao.add_child(_pontos)
	var legenda := Estilos.rotulo("PONTOS", 22, Color("#BFE8FF"), false)
	legenda.position = Vector2(244, 38)
	cartao.add_child(legenda)
	var fase := Estilos.rotulo(nome_fase, 26, Color.WHITE)
	fase.position = Vector2(30, 78)
	fase.size = Vector2(310, 36)
	fase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fase.add_theme_constant_override("outline_size", 8)
	cartao.add_child(fase)


func _criar_barra(fim_x: float, layout: Array) -> void:
	_progresso = BarraProgresso.new()
	_progresso.position = Vector2(540, 20)
	_progresso.size = Vector2(840, 100)
	_progresso.fim_x = fim_x
	for e in layout:
		match e[0]:
			"porta":
				_progresso.marcas.append(e[1])
			"caminho", "ponte_final":
				_progresso.marcas.append((e[1] + e[2]) / 2.0)
			"checkpoint":
				_progresso.checks.append(e[1])
	add_child(_progresso)
