class_name Avisos
extends Control
## Mensagens sobre o jogo: clarão de cor, aviso temporário e faixa dourada do caminho.

var _flash: ColorRect
var _aviso: PanelContainer
var _aviso_texto: Label
var _faixa: PanelContainer
var _faixa_texto: Label
var _aviso_id := 0


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash = ColorRect.new()
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.color = Color(1, 0.1, 0.15, 0.0)
	add_child(_flash)
	_aviso = _criar_caixa(32, Color.WHITE)
	_aviso_texto = _aviso.get_child(0)
	_faixa = _criar_caixa(36, Paleta.NOITE)
	_faixa_texto = _faixa.get_child(0)
	_faixa.add_theme_stylebox_override("panel", Estilos.caixa(Color(1, 0.83, 0.3, 0.96), 22, Paleta.NOITE, 5, 18))


## clarão de cor que some (vermelho ao errar, verde ao acertar)
func clarao(cor: Color) -> void:
	_flash.color = cor
	create_tween().tween_property(_flash, "color:a", 0.0, 0.55)


func mostrar(texto: String, duracao := 3.0, erro := false) -> void:
	_aviso_id += 1
	var meu := _aviso_id
	_aviso.add_theme_stylebox_override("panel", Estilos.caixa(Color(0.55, 0.08, 0.12, 0.96) if erro else Color(0.04, 0.23, 0.43, 0.93), 22, Color.WHITE if erro else Paleta.CLARO, 4, 20))
	_aviso_texto.text = texto
	_aviso.visible = true
	_aviso.modulate.a = 0.0
	create_tween().tween_property(_aviso, "modulate:a", 1.0, 0.18)
	get_tree().create_timer(duracao).timeout.connect(func():
		if meu == _aviso_id:
			_aviso.visible = false)


## faixa dourada com a pergunta do caminho; texto vazio esconde
func faixa(texto: String) -> void:
	_faixa.visible = texto != ""
	if texto != "":
		_faixa_texto.text = texto


func _criar_caixa(tam_fonte: int, cor: Color) -> PanelContainer:
	var caixa := PanelContainer.new()
	caixa.position = Vector2(360, 118)
	caixa.custom_minimum_size = Vector2(1200, 0)
	caixa.visible = false
	var texto := Estilos.rotulo("", tam_fonte, cor, false)
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(texto)
	add_child(caixa)
	return caixa
