class_name TelaPausa
extends TelaCheia

signal retomou
signal reiniciou
signal foi_ao_mapa
## Tela de pausa: título e a lista de teclas (ou botões do controle).


func _init() -> void:
	super(0.6)
	var coluna := _painel_com_coluna(900.0, 20)
	var titulo := Estilos.rotulo("Pausado", 84, Paleta.OURO)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coluna.add_child(titulo)
	var sub := Estilos.rotulo("Respire, estude e volte com tudo!", 30, Paleta.CLARO, false)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coluna.add_child(sub)
	if ControlesToque.deve_aparecer():
		_criar_botoes(coluna)
	else:
		for par in _atalhos():
			coluna.add_child(_linha_atalho(par[0], par[1]))


func _criar_botoes(coluna: VBoxContainer) -> void:
	for item in [["Continuar", retomou], ["Reiniciar a fase", reiniciou], ["Voltar ao mapa", foi_ao_mapa]]:
		var botao := Estilos.botao(item[0], 42)
		botao.custom_minimum_size = Vector2(0, 96)
		botao.pressed.connect(func(): item[1].emit())
		coluna.add_child(botao)


func _atalhos() -> Array:
	return [
		[Jogo.dica("Enter", "A", "Cruz"), "continuar"],
		[Jogo.dica("R", "X", "Quadrado"), "reiniciar a fase"],
		[Jogo.dica("M", "Y", "Triângulo"), "voltar ao mapa"],
		["N", "música liga/desliga"],
	]


func _linha_atalho(tecla: String, descricao: String) -> HBoxContainer:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 24)
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	linha.add_child(_tecla(tecla))
	var texto := Estilos.rotulo(descricao, 42, Color.WHITE, false)
	texto.custom_minimum_size = Vector2(380, 70)
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	linha.add_child(texto)
	return linha


## "tecla" desenhada: caixa creme com sombra embaixo
func _tecla(rotulo: String) -> Label:
	var t := Label.new()
	t.text = rotulo
	t.custom_minimum_size = Vector2(190, 70)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 38)
	t.add_theme_color_override("font_color", Paleta.NOITE)
	var s := StyleBoxFlat.new()
	s.bg_color = Color("#FFF2C6")
	s.set_corner_radius_all(16)
	s.border_color = Color("#C9A227")
	s.set_border_width_all(4)
	s.border_width_bottom = 10
	t.add_theme_stylebox_override("normal", s)
	return t
