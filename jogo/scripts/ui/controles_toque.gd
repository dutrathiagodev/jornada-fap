class_name ControlesToque
extends Control
## Botões na tela para celular e tablet: andar, pular, correr e pausar.
## Vários dedos ao mesmo tempo funcionam (ex.: segurar "correr" e tocar "pular").

signal pausar_pedido

const COR := Color(1, 1, 1, 0.42)
const COR_ATIVA := Color(1, 0.85, 0.35, 0.85)
const COR_FUNDO := Color(0.03, 0.08, 0.2, 0.45)

## Zonas em coordenadas da tela do jogo (1920x1080).
const ZONAS := {
	"esquerda": {"centro": Vector2(150, 925), "raio": 92.0, "acao": "mover_esquerda"},
	"direita": {"centro": Vector2(370, 925), "raio": 92.0, "acao": "mover_direita"},
	"pular": {"centro": Vector2(1750, 905), "raio": 125.0, "acao": "pular"},
	"correr": {"centro": Vector2(1500, 965), "raio": 88.0, "acao": "correr"},
	"pausa": {"centro": Vector2(1835, 205), "raio": 44.0, "acao": ""},
}

var _dedos := {}      # índice do dedo -> nome da zona
var _ativas := {}     # nome da zona -> true enquanto pressionada
var _simular_mouse := false


## true em aparelhos com tela de toque (ou quando FAP_TOQUE=1, para testar no computador)
static func deve_aparecer() -> bool:
	return DisplayServer.is_touchscreen_available() or OS.has_environment("FAP_TOQUE") \
		or OS.has_feature("web_android") or OS.has_feature("web_ios")


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_simular_mouse = OS.has_environment("FAP_TOQUE")


func _input(ev: InputEvent) -> void:
	if not visible:
		return
	if ev is InputEventScreenTouch:
		_atualizar_dedo(ev.index, ev.position, ev.pressed)
	elif ev is InputEventScreenDrag:
		_atualizar_dedo(ev.index, ev.position, true)
	elif _simular_mouse and ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		_atualizar_dedo(-1, ev.position, ev.pressed)
	elif _simular_mouse and ev is InputEventMouseMotion and _dedos.has(-1):
		_atualizar_dedo(-1, ev.position, true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not visible:
		_dedos.clear()
		_aplicar()


func _atualizar_dedo(indice: int, pos: Vector2, pressionado: bool) -> void:
	if pressionado:
		var zona := _zona_em(pos)
		if zona == "":
			_dedos.erase(indice)
		else:
			_dedos[indice] = zona
	else:
		_dedos.erase(indice)
	_aplicar()


func _zona_em(pos: Vector2) -> String:
	for nome in ZONAS:
		var z: Dictionary = ZONAS[nome]
		# margem generosa: o dedo é maior que o desenho
		if pos.distance_to(z["centro"]) <= float(z["raio"]) * 1.25:
			return nome
	return ""


## compara as zonas tocadas agora com as de antes e aperta/solta as ações
func _aplicar() -> void:
	var agora := {}
	for nome in _dedos.values():
		agora[nome] = true
	for nome in ZONAS:
		var antes: bool = _ativas.has(nome)
		var depois: bool = agora.has(nome)
		if antes == depois:
			continue
		_mudar_zona(nome, depois)
	_ativas = agora
	queue_redraw()


func _mudar_zona(nome: String, pressionada: bool) -> void:
	var acao: String = ZONAS[nome]["acao"]
	if acao == "":
		if pressionada:
			pausar_pedido.emit()
	elif pressionada:
		Input.action_press(acao)
	else:
		Input.action_release(acao)


# ---------------------------------------------------------------- desenho
func _draw() -> void:
	for nome in ZONAS:
		var z: Dictionary = ZONAS[nome]
		var c: Vector2 = z["centro"]
		var r: float = z["raio"]
		var ativa: bool = _ativas.has(nome)
		draw_circle(c, r, COR_FUNDO)
		draw_arc(c, r, 0.0, TAU, 48, COR_ATIVA if ativa else COR, 5.0, true)
		_desenhar_icone(nome, c, r, COR_ATIVA if ativa else Color(1, 1, 1, 0.8))


func _desenhar_icone(nome: String, c: Vector2, r: float, cor: Color) -> void:
	var k := r * 0.42
	match nome:
		"esquerda":
			draw_colored_polygon(PackedVector2Array([c + Vector2(-k, 0), c + Vector2(k * 0.7, -k), c + Vector2(k * 0.7, k)]), cor)
		"direita":
			draw_colored_polygon(PackedVector2Array([c + Vector2(k, 0), c + Vector2(-k * 0.7, -k), c + Vector2(-k * 0.7, k)]), cor)
		"pular":
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -k * 1.1), c + Vector2(k, k * 0.6), c + Vector2(-k, k * 0.6)]), cor)
		"correr":
			for dx in [-0.5, 0.5]:
				draw_colored_polygon(PackedVector2Array([
					c + Vector2(k * (dx - 0.1), -k * 0.9), c + Vector2(k * (dx + 0.9), 0), c + Vector2(k * (dx - 0.1), k * 0.9)]), cor)
		"pausa":
			draw_rect(Rect2(c + Vector2(-k * 0.8, -k), Vector2(k * 0.5, k * 2)), cor)
			draw_rect(Rect2(c + Vector2(k * 0.3, -k), Vector2(k * 0.5, k * 2)), cor)
