class_name Estilos
extends RefCounted
## Fábrica de estilos e rótulos usados por todas as telas.


static func caixa(cor: Color, raio := 16, borda := Color.TRANSPARENT, larg_borda := 0, margem := 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = cor
	s.set_corner_radius_all(raio)
	if larg_borda > 0:
		s.border_color = borda
		s.set_border_width_all(larg_borda)
	if margem > 0:
		s.set_content_margin_all(margem)
	return s


static func rotulo(texto: String, tam: int, cor := Color.WHITE, contorno := true) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", cor)
	if contorno:
		l.add_theme_color_override("font_outline_color", Paleta.NOITE)
		l.add_theme_constant_override("outline_size", 10)
	return l


## rótulo centralizado que quebra linha
static func rotulo_texto(texto: String, tam: int, cor := Color.WHITE) -> Label:
	var l := rotulo(texto, tam, cor, false)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


## moldura de pergunta, pausa e resultado (arte do jogo)
static func painel_arte(margem_conteudo := 64) -> StyleBoxTexture:
	var sp := StyleBoxTexture.new()
	sp.texture = load("res://assets/ui/painel.png")
	sp.texture_margin_left = 62
	sp.texture_margin_right = 62
	sp.texture_margin_top = 58
	sp.texture_margin_bottom = 58
	sp.set_content_margin_all(margem_conteudo)
	return sp


## botão de arte ("azul" ou "dourado"), com tom opcional
static func caixa_botao(tipo: String, tom := Color.WHITE) -> StyleBoxTexture:
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
