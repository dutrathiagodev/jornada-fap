class_name TelaFim
extends TelaCheia

signal avancou
signal foi_ao_mapa
## Resultado da fase: derrota ("Fim de jogo") ou vitória com as estrelas.

var _titulo: Label
var _estrelas: Estrelas
var _resumo: Label
var _curiosidade: Label
var _teclas: Label
var _avancar: Button


func _init() -> void:
	super(0.7)
	var coluna := _painel_com_coluna(1200.0, 18)
	_titulo = Estilos.rotulo("", 64, Color.WHITE)
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coluna.add_child(_titulo)
	_estrelas = Estrelas.new()
	_estrelas.raio = 92.0
	_estrelas.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	coluna.add_child(_estrelas)
	_resumo = Estilos.rotulo_texto("", 34)
	coluna.add_child(_resumo)
	_curiosidade = Estilos.rotulo_texto("", 28, Paleta.CLARO)
	coluna.add_child(_curiosidade)
	_teclas = Estilos.rotulo_texto("", 30, Paleta.OURO)
	coluna.add_child(_teclas)
	if ControlesToque.deve_aparecer():
		_teclas.visible = false
		coluna.add_child(_criar_botoes())


func _criar_botoes() -> HBoxContainer:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 24)
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	_avancar = Estilos.botao("Continuar", 40)
	_avancar.custom_minimum_size = Vector2(440, 96)
	_avancar.pressed.connect(func(): avancou.emit())
	linha.add_child(_avancar)
	var mapa := Estilos.botao("Mapa", 40)
	mapa.custom_minimum_size = Vector2(300, 96)
	mapa.pressed.connect(func(): foi_ao_mapa.emit())
	linha.add_child(mapa)
	return linha


func _texto_avancar(texto: String) -> void:
	if _avancar:
		_avancar.text = texto


func mostrar_derrota(pontos: int) -> void:
	_titulo.text = "Fim de jogo"
	_estrelas.visible = false
	_resumo.text = "Você chegou até aqui com %d pontos. Quem tenta de novo aprende mais!" % pontos
	_curiosidade.text = ""
	_teclas.text = Jogo.dica("Enter: tentar de novo     M: mapa", "A: tentar de novo     Y: mapa", "Cruz: tentar de novo     Triângulo: mapa")
	_texto_avancar("Tentar de novo")
	visible = true


## aparece depois de `atraso` segundos, com as estrelas animando
func mostrar_vitoria(titulo: String, n_estrelas: int, resumo: String, curiosidade: String, teclas: String, acao: String, atraso := 0.9) -> void:
	_texto_avancar(acao)
	_titulo.text = titulo
	_estrelas.visible = true
	_estrelas.n = n_estrelas
	_resumo.text = resumo
	_curiosidade.text = curiosidade
	_teclas.text = teclas
	get_tree().create_timer(atraso).timeout.connect(func():
		aparecer(0.4)
		_estrelas.animar())
