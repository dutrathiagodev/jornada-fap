extends Node
## Autoload: banco de perguntas (lê JSON) e mapa de controles.

var banco: Array = []
var banco_vf: Array = []


func _ready() -> void:
	_criar_controles()


func _criar_controles() -> void:
	# teclado. Enter confirma (perguntas e menus); Espaço só pula.
	var teclas := {
		"mover_esquerda": [KEY_LEFT, KEY_A],
		"mover_direita": [KEY_RIGHT, KEY_D],
		"correr": [KEY_SHIFT],
		"pular": [KEY_SPACE, KEY_UP, KEY_W],
		"confirmar": [KEY_ENTER, KEY_KP_ENTER],
		"pausar": [KEY_ESCAPE, KEY_P],
		"voltar": [KEY_ESCAPE],
		"mapa": [KEY_M],
		"reiniciar": [KEY_R],
		"nav_anterior": [KEY_UP, KEY_LEFT, KEY_W, KEY_A],
		"nav_proximo": [KEY_DOWN, KEY_RIGHT, KEY_S, KEY_D],
	}
	for acao in teclas:
		_garantir_acao(acao)
		for k in teclas[acao]:
			var e := InputEventKey.new()
			e.physical_keycode = k
			InputMap.action_add_event(acao, e)

	# controle (Xbox, PlayStation, Switch...). O Godot usa nomes neutros:
	# A = X do PlayStation (cruz), B = bolinha, X = quadrado, Y = triângulo.
	var botoes := {
		"pular": [JOY_BUTTON_A],
		"correr": [JOY_BUTTON_X, JOY_BUTTON_RIGHT_SHOULDER],
		"confirmar": [JOY_BUTTON_A],
		"pausar": [JOY_BUTTON_START],
		"voltar": [JOY_BUTTON_B],
		"mapa": [JOY_BUTTON_Y, JOY_BUTTON_BACK],
		"reiniciar": [JOY_BUTTON_X],
		"mover_esquerda": [JOY_BUTTON_DPAD_LEFT],
		"mover_direita": [JOY_BUTTON_DPAD_RIGHT],
		"nav_anterior": [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_LEFT],
		"nav_proximo": [JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_RIGHT],
	}
	for acao in botoes:
		_garantir_acao(acao)
		for idx in botoes[acao]:
			var b := InputEventJoypadButton.new()
			b.button_index = idx
			InputMap.action_add_event(acao, b)

	# analógico esquerdo e gatilho direito (correr)
	var eixos := [
		["mover_esquerda", JOY_AXIS_LEFT_X, -1.0],
		["mover_direita", JOY_AXIS_LEFT_X, 1.0],
		["nav_anterior", JOY_AXIS_LEFT_Y, -1.0],
		["nav_anterior", JOY_AXIS_LEFT_X, -1.0],
		["nav_proximo", JOY_AXIS_LEFT_Y, 1.0],
		["nav_proximo", JOY_AXIS_LEFT_X, 1.0],
		["correr", JOY_AXIS_TRIGGER_RIGHT, 1.0],
	]
	for item in eixos:
		var m := InputEventJoypadMotion.new()
		m.axis = item[1]
		m.axis_value = item[2]
		InputMap.action_add_event(item[0], m)
	for acao in ["mover_esquerda", "mover_direita", "nav_anterior", "nav_proximo", "correr"]:
		InputMap.action_set_deadzone(acao, 0.5)


func _garantir_acao(acao: String) -> void:
	if not InputMap.has_action(acao):
		InputMap.add_action(acao)


func carregar(fase: String) -> void:
	var f := FileAccess.open("res://dados/perguntas/%s.json" % fase, FileAccess.READ)
	var d: Dictionary = JSON.parse_string(f.get_as_text())
	banco = d["perguntas"]
	banco_vf = d.get("vf", [])


## n perguntas diferentes, em ordem aleatória
func sortear(n: int) -> Array:
	var copia := banco.duplicate()
	copia.shuffle()
	return copia.slice(0, n)


## n perguntas de verdadeiro/falso, em ordem aleatória
func sortear_vf(n: int) -> Array:
	var copia := banco_vf.duplicate()
	copia.shuffle()
	return copia.slice(0, n)


## cópia da pergunta com as alternativas embaralhadas (e o índice da certa ajustado)
func embaralhar(p: Dictionary) -> Dictionary:
	var alts: Array = p["alternativas"]
	var certa = alts[int(p["correta"])]
	var novas := alts.duplicate()
	novas.shuffle()
	var r := p.duplicate()
	r["alternativas"] = novas
	r["correta"] = novas.find(certa)
	return r
