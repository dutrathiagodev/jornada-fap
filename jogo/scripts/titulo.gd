extends Node2D
## Tela de título: cenário em movimento, o menino correndo e "Espaço para jogar".
## FAP_CIDADE=n (1 a 5) pula direto para uma fase (usado nos testes).

const Jogador := preload("res://scripts/jogador.gd")
const NOITE := Color("#14213D")
const OURO := Color("#FFD34E")
var t := 0.0


func _ready() -> void:
	Jogo.tocar_musica("tema")
	if OS.has_environment("FAP_CIDADE"):
		Jogo.cidade_atual = clampi(int(OS.get_environment("FAP_CIDADE")) - 1, 0, 4)
		call_deferred("_jogar_direto")
		return
	var capa := TextureRect.new()
	capa.texture = load("res://assets/ui/capa_titulo.jpg")
	capa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	capa.stretch_mode = TextureRect.STRETCH_SCALE
	capa.size = Vector2(1920, 1080)
	capa.pivot_offset = Vector2(960, 540)
	capa.name = "capa"
	add_child(capa)
	var br := Brilhos.new()
	capa.add_child(br)
	var ui := CanvasLayer.new()
	add_child(ui)
	# logo oficial da FAP no canto livre (arte feita pela IA deixa o espaço vazio)
	var selo := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.12, 0.3, 0.72)
	sb.set_corner_radius_all(26)
	sb.border_color = Color(1, 0.85, 0.35, 0.9)
	sb.set_border_width_all(4)
	selo.add_theme_stylebox_override("panel", sb)
	selo.position = Vector2(1440, 26)
	selo.size = Vector2(440, 160)
	ui.add_child(selo)
	_logo(ui, "res://assets/logos/fap_branco.svg", Vector2(1480, 42), 360, 126)
	var tot := Jogo.total_estrelas()
	if tot > 0:
		_rotulo(ui, "★ %d de 15 estrelas" % tot, 44, Vector2(-380, 880), OURO)


class Brilhos extends Control:
	var t := 0.0

	func _process(d: float) -> void:
		t += d
		queue_redraw()

	func _draw() -> void:
		# brilho pulsando em volta do botão "Pressione [ESPAÇO]"
		var k := 0.5 + 0.5 * sin(t * 4.0)
		var c := Vector2(468, 657)
		draw_circle(c, 250.0 + 14.0 * k, Color(1.0, 0.85, 0.3, 0.05 + 0.05 * k))
		# vaga-lumes dourados e faíscas subindo
		for i in 46:
			var u := fmod(t * (0.05 + (i % 5) * 0.012) + i * 0.137, 1.0)
			var x := fmod(i * 211.0, 1920.0) + sin(t * 0.8 + i) * 22.0
			var y := 1080.0 - u * 1000.0
			var piscar := 0.5 + 0.5 * sin(t * 3.0 + i * 1.7)
			draw_circle(Vector2(x, y), 2.0 + (i % 3), Color(1.0, 0.9, 0.5, 0.75 * piscar * sin(u * PI)))
		# estrelinhas em cruz perto dos personagens
		for i in 6:
			var p := Vector2(1100.0 + i * 110.0 + sin(t + i) * 12.0, 470.0 + cos(t * 1.3 + i * 2.0) * 60.0)
			var s := maxf(0.0, sin(t * 2.5 + i * 1.1)) * 14.0
			draw_line(p - Vector2(s, 0), p + Vector2(s, 0), Color(1, 1, 0.85, 0.9), 3.0)
			draw_line(p - Vector2(0, s), p + Vector2(0, s), Color(1, 1, 0.85, 0.9), 3.0)


func _rotulo(pai: Node, texto: String, tam: int, pos: Vector2, cor: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = pos
	l.size = Vector2(1920, tam + 30)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", cor)
	l.add_theme_color_override("font_outline_color", NOITE)
	l.add_theme_constant_override("outline_size", 14)
	pai.add_child(l)
	return l


func _jogar_direto() -> void:
	get_tree().change_scene_to_file("res://fase.tscn")


func _process(d: float) -> void:
	t += d
	var capa := get_node_or_null("capa")
	if capa:
		capa.scale = Vector2.ONE * (1.0 + 0.02 * (0.5 + 0.5 * sin(t * 0.4)))


func _unhandled_input(ev: InputEvent) -> void:
	# a arte da capa diz "Pressione [ESPAÇO]": Espaço, Enter e o botão A começam o jogo
	if ev.is_action_pressed("confirmar") or ev.is_action_pressed("pular") or (ev is InputEventMouseButton and ev.pressed):
		Jogo.sfx("clique")
		get_tree().change_scene_to_file("res://mapa.tscn")


func _logo(pai: Node, caminho: String, pos: Vector2, larg: float, alt := -1.0) -> void:
	var r := TextureRect.new()
	r.texture = load(caminho)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	r.position = pos
	r.size = Vector2(larg, larg * 0.4 if alt < 0.0 else alt)
	pai.add_child(r)
