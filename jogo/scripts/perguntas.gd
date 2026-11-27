extends Node
## Autoload: banco de perguntas (lê JSON) e mapa de controles.

var banco: Array = []
var banco_vf: Array = []


func _ready() -> void:
	_criar_controles()


func _criar_controles() -> void:
	var teclas := {
		"mover_esquerda": [KEY_LEFT, KEY_A],
		"mover_direita": [KEY_RIGHT, KEY_D],
		"correr": [KEY_SHIFT],
		"pular": [KEY_SPACE, KEY_UP, KEY_W],
		"confirmar": [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER],
		"pausar": [KEY_ESCAPE, KEY_P],
	}
	for acao in teclas:
		if not InputMap.has_action(acao):
			InputMap.add_action(acao)
		for k in teclas[acao]:
			var e := InputEventKey.new()
			e.physical_keycode = k
			InputMap.action_add_event(acao, e)
	# controle (gamepad)
	var botoes := {"pular": JOY_BUTTON_A, "correr": JOY_BUTTON_X, "confirmar": JOY_BUTTON_A}
	for acao in botoes:
		var b := InputEventJoypadButton.new()
		b.button_index = botoes[acao]
		InputMap.action_add_event(acao, b)
	for par in [["mover_esquerda", -1.0], ["mover_direita", 1.0]]:
		var m := InputEventJoypadMotion.new()
		m.axis = JOY_AXIS_LEFT_X
		m.axis_value = par[1]
		InputMap.action_add_event(par[0], m)


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
