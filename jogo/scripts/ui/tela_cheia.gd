class_name TelaCheia
extends Control
## Base das telas que cobrem tudo (pergunta, pausa, resultado): fundo escuro e um centro para o painel.

var centro: CenterContainer


func _init(escurecimento := 0.5) -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	var fundo := ColorRect.new()
	fundo.color = Color(0.02, 0.06, 0.14, escurecimento)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)
	centro = CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)


## mostra com um desvanecer suave
func aparecer(duracao := 0.2) -> void:
	visible = true
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, duracao)


## painel de arte já posicionado no centro, com uma coluna vertical dentro
func _painel_com_coluna(largura: float, separacao: int, margem := 64) -> VBoxContainer:
	var painel := PanelContainer.new()
	painel.add_theme_stylebox_override("panel", Estilos.painel_arte(margem))
	painel.custom_minimum_size = Vector2(largura, 0)
	centro.add_child(painel)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", separacao)
	painel.add_child(coluna)
	return coluna
