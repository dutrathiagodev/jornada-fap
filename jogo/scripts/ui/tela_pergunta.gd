class_name TelaPergunta
extends TelaCheia
## Tela de pergunta: tema, enunciado, até 4 alternativas, barra de tempo e feedback.

signal escolheu(indice: int)
signal continuou

const CORES_TEMA := {"matematica": "#E07B1F", "portugues": "#C8344B", "ciencias": "#2E9E5B", "historia": "#9A6A3A", "geografia": "#1E8FA8", "tecnologia": "#2A74CC", "logica": "#7A4FBF", "biblia": "#C9A227"}
const MAX_ALTERNATIVAS := 4

var selecionada := 0
var _n := MAX_ALTERNATIVAS
var _tema: Label
var _enunciado: Label
var _botoes: Array[Button] = []
var _barra: ProgressBar
var _cor_barra: StyleBoxFlat
var _feedback: Label
var _continuar: Control


func _init(cidade_id: String, tempo_max: float) -> void:
	super(0.45)
	var fundo := TextureRect.new()
	fundo.texture = load("res://assets/%s/2_meio.png" % cidade_id)
	fundo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fundo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fundo.modulate = Color(1, 1, 1, 0.55)
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fundo)
	move_child(fundo, 0)
	var coluna := _painel_com_coluna(1400.0, 16, 60)
	_criar_cabecalho(coluna)
	_criar_enunciado(coluna)
	for i in MAX_ALTERNATIVAS:
		_botoes.append(_criar_botao(coluna, i))
	_criar_barra(coluna, tempo_max)
	_criar_rodape(coluna)


## `tema` é a chave ("matematica"...), `rotulo_tema` o texto da etiqueta.
func mostrar_pergunta(rotulo_tema: String, tema: String, enunciado: String, alternativas: Array) -> void:
	_n = alternativas.size()
	_tema.text = rotulo_tema
	_tema.add_theme_stylebox_override("normal", Estilos.caixa(Color(CORES_TEMA.get(tema, "#1B5AA6")), 22, Color(1, 1, 1, 0.55), 3, 14))
	_tema.add_theme_color_override("font_color", Color.WHITE)
	_enunciado.text = enunciado
	for i in MAX_ALTERNATIVAS:
		_botoes[i].visible = i < _n
		if i < _n:
			_botoes[i].text = "%d   %s" % [i + 1, alternativas[i]]
			_botoes[i].disabled = false
			_botoes[i].add_theme_stylebox_override("disabled", Estilos.caixa_botao("azul"))
	_feedback.visible = false
	_continuar.visible = false
	_barra.visible = true
	selecionar(0)
	aparecer(0.2)


## trava os botões, pinta certa (verde) e errada (vermelha) e mostra a explicação
func mostrar_resposta(escolhida: int, certa: int, mensagem: String) -> void:
	for k in _n:
		_botoes[k].disabled = true
	_botoes[certa].add_theme_stylebox_override("disabled", Estilos.caixa_botao("azul", Color(0.55, 1.5, 0.65)))
	if escolhida >= 0 and escolhida != certa:
		_botoes[escolhida].add_theme_stylebox_override("disabled", Estilos.caixa_botao("azul", Color(1.7, 0.5, 0.5)))
	_barra.visible = false
	_feedback.text = mensagem
	_feedback.visible = true
	_continuar.visible = true


## destaca a alternativa escolhida com as setas (fica dourada)
func selecionar(i: int) -> void:
	selecionada = i
	for k in MAX_ALTERNATIVAS:
		_botoes[k].add_theme_stylebox_override("normal", Estilos.caixa_botao("dourado" if k == i else "azul"))
		_botoes[k].add_theme_color_override("font_color", Paleta.NOITE if k == i else Color.WHITE)


## passo = -1 (anterior) ou +1 (próxima), dando a volta
func mover(passo: int) -> void:
	selecionar(posmod(selecionada + passo, _n))


## barra de tempo: verde, depois dourada e vermelha perto do fim
func atualizar_tempo(restante: float) -> void:
	_barra.value = restante
	_cor_barra.bg_color = Paleta.VERDE if restante > 10.0 else (Paleta.OURO if restante > 5.0 else Paleta.VERMELHO)


func _criar_cabecalho(coluna: VBoxContainer) -> void:
	var cab := HBoxContainer.new()
	cab.add_theme_constant_override("separation", 20)
	coluna.add_child(cab)
	_tema = Estilos.rotulo("", 28, Paleta.CLARO, false)
	_tema.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_tema.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cab.add_child(_tema)
	var espaco := Control.new()
	espaco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cab.add_child(espaco)
	var marca := TextureRect.new()
	marca.texture = load("res://assets/logos/adventista_branco.png")
	marca.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	marca.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	marca.custom_minimum_size = Vector2(64, 58)
	marca.modulate = Color(1, 1, 1, 0.9)
	cab.add_child(marca)


func _criar_enunciado(coluna: VBoxContainer) -> void:
	var placa := PanelContainer.new()
	var estilo := Estilos.caixa(Color(0.02, 0.08, 0.22, 0.6), 24, Color(1.0, 0.83, 0.3, 0.55), 3)
	estilo.content_margin_left = 36
	estilo.content_margin_right = 36
	estilo.content_margin_top = 22
	estilo.content_margin_bottom = 26
	placa.add_theme_stylebox_override("panel", estilo)
	coluna.add_child(placa)
	_enunciado = Estilos.rotulo_texto("", 58)
	placa.add_child(_enunciado)


func _criar_botao(coluna: VBoxContainer, i: int) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 88)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override("font_size", 38)
	for cor in ["font_color", "font_disabled_color"]:
		b.add_theme_color_override(cor, Color.WHITE)
	for cor in ["font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(cor, Paleta.NOITE)
	b.add_theme_stylebox_override("normal", Estilos.caixa_botao("azul"))
	b.add_theme_stylebox_override("hover", Estilos.caixa_botao("dourado"))
	b.add_theme_stylebox_override("pressed", Estilos.caixa_botao("dourado"))
	b.add_theme_stylebox_override("disabled", Estilos.caixa_botao("azul"))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.pressed.connect(func(): escolheu.emit(i))
	coluna.add_child(b)
	return b


func _criar_barra(coluna: VBoxContainer, tempo_max: float) -> void:
	_barra = ProgressBar.new()
	_barra.custom_minimum_size = Vector2(0, 22)
	_barra.show_percentage = false
	_barra.max_value = tempo_max
	_barra.value = tempo_max
	_barra.add_theme_stylebox_override("background", Estilos.caixa(Color(0, 0, 0, 0.35), 11, Color(1, 1, 1, 0.25), 2))
	_cor_barra = Estilos.caixa(Paleta.VERDE, 11)
	_barra.add_theme_stylebox_override("fill", _cor_barra)
	coluna.add_child(_barra)


func _criar_rodape(coluna: VBoxContainer) -> void:
	var toque := ControlesToque.deve_aparecer()
	if not toque:
		var dica := Estilos.rotulo(Jogo.dica("↑ ↓ escolher     Enter confirmar     (ou tecla 1 a 4)", "Direcional: escolher     A: confirmar", "Direcional: escolher     Cruz: confirmar"), 24, Color(1, 1, 1, 0.7), false)
		dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		coluna.add_child(dica)
	_feedback = Estilos.rotulo("", 32, Color.WHITE, false)
	_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coluna.add_child(_feedback)
	if toque:
		var botao := Estilos.botao("Continuar", 40)
		botao.custom_minimum_size = Vector2(420, 90)
		botao.size_flags_horizontal = Control.SIZE_SHRINK_END
		botao.pressed.connect(func(): continuou.emit())
		_continuar = botao
	else:
		var aviso := Estilos.rotulo(Jogo.dica("Aperte ENTER para continuar", "Aperte A para continuar", "Aperte Cruz para continuar"), 28, Paleta.OURO, false)
		aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_continuar = aviso
	coluna.add_child(_continuar)
