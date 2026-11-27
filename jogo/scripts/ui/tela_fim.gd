class_name TelaFim
extends TelaCheia
## Resultado da fase: derrota ("Fim de jogo") ou vitória com as estrelas.

var _titulo: Label
var _estrelas: Estrelas
var _resumo: Label
var _curiosidade: Label
var _teclas: Label


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


func mostrar_derrota(pontos: int) -> void:
	_titulo.text = "Fim de jogo"
	_estrelas.visible = false
	_resumo.text = "Você chegou até aqui com %d pontos. Quem tenta de novo aprende mais!" % pontos
	_curiosidade.text = ""
	_teclas.text = Jogo.dica("Enter: tentar de novo     M: mapa", "A: tentar de novo     Y: mapa", "Cruz: tentar de novo     Triângulo: mapa")
	visible = true


## aparece depois de `atraso` segundos, com as estrelas animando
func mostrar_vitoria(titulo: String, n_estrelas: int, resumo: String, curiosidade: String, teclas: String, atraso := 0.9) -> void:
	_titulo.text = titulo
	_estrelas.visible = true
	_estrelas.n = n_estrelas
	_resumo.text = resumo
	_curiosidade.text = curiosidade
	_teclas.text = teclas
	get_tree().create_timer(atraso).timeout.connect(func():
		aparecer(0.4)
		_estrelas.animar())
