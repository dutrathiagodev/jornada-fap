extends Node
## Autoload "Jogo": dados das 5 cidades, layout de cada fase, progresso salvo e cupom.

const SAVE := "user://progresso.cfg"

const CIDADES := [
	{"id": "curitiba", "nome": "Curitiba", "chao": 771.0, "agua": false,
		"tema": "Português e Matemática", "dica": "A araucária é a árvore-símbolo do Paraná."},
	{"id": "foz", "nome": "Foz do Iguaçu", "chao": 731.0, "agua": true,
		"tema": "Ciências e Geografia", "dica": "As Cataratas do Iguaçu têm 275 quedas d'água."},
	{"id": "sao_paulo", "nome": "São Paulo", "chao": 810.0, "agua": false,
		"tema": "História, Lógica e Tecnologia", "dica": "A Avenida Paulista foi inaugurada em 1891."},
	{"id": "florianopolis", "nome": "Florianópolis", "chao": 778.0, "agua": true,
		"tema": "Bíblia: personagens e histórias", "dica": "A Ponte Hercílio Luz liga a ilha ao continente."},
	{"id": "porto_alegre", "nome": "Porto Alegre", "chao": 777.0, "agua": true,
		"tema": "Desafio final: estudo e Bíblia", "dica": "O pôr do sol do Guaíba é um dos mais bonitos do Brasil."},
]

var cidade_atual := 0
var estrelas := [0, 0, 0, 0, 0]
var melhor := [0, 0, 0, 0, 0]
var nome_jogador := ""


var musica_ligada := true
var musica_atual := ""
var _mus: AudioStreamPlayer
var _tween_mus: Tween
const VOL_MUSICA := -14.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_mus = AudioStreamPlayer.new()
	_mus.volume_db = VOL_MUSICA
	add_child(_mus)
	carregar()
	# fonte do jogo: Lilita One (licença livre OFL), estilo de jogo
	var fv := FontVariation.new()
	fv.base_font = load("res://assets/fontes/LilitaOne.ttf")
	ThemeDB.fallback_font = fv
	ThemeDB.get_default_theme().default_font = fv


## toca uma trilha em loop (não reinicia se já for a mesma). Arquivos em assets/musica/.
func tocar_musica(nome: String) -> void:
	if nome == musica_atual and _mus.playing:
		return
	musica_atual = nome
	var st = load("res://assets/musica/%s.wav" % nome)
	if st is AudioStreamWAV:
		st.loop_mode = AudioStreamWAV.LOOP_FORWARD
		st.loop_begin = 0
		st.loop_end = st.data.size() / 2
	_mus.stream = st
	_mus.volume_db = VOL_MUSICA if musica_ligada else -80.0
	_mus.play()


## abaixa a música durante perguntas, pausa e telas de resultado
func abafar(sim: bool) -> void:
	if not musica_ligada:
		return
	if _tween_mus:
		_tween_mus.kill()
	_tween_mus = create_tween()
	_tween_mus.tween_property(_mus, "volume_db", VOL_MUSICA - (11.0 if sim else 0.0), 0.35)


func alternar_musica() -> void:
	musica_ligada = not musica_ligada
	_mus.volume_db = VOL_MUSICA if musica_ligada else -80.0
	salvar()


## efeito sonoro avulso (menus)
func sfx(nome: String) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = load("res://assets/sons/%s.wav" % nome)
	p.volume_db = -6.0
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventKey and ev.pressed and not ev.echo and ev.physical_keycode == KEY_N:
		alternar_musica()


func liberada(i: int) -> bool:
	return i == 0 or int(estrelas[i - 1]) > 0


func terminou_tudo() -> bool:
	for e in estrelas:
		if int(e) == 0:
			return false
	return true


func total_estrelas() -> int:
	var t := 0
	for e in estrelas:
		t += int(e)
	return t


## faixa de desconto proposta (precisa ser aprovada pela FAP): ver docs/06-desconto.md
func faixa_desconto() -> int:
	if not terminou_tudo():
		return 0
	var t := total_estrelas()
	if t >= 14:
		return 15
	if t >= 10:
		return 10
	return 5


func registrar(i: int, est: int, pts: int) -> void:
	estrelas[i] = maxi(int(estrelas[i]), est)
	melhor[i] = maxi(int(melhor[i]), pts)
	salvar()


func salvar() -> void:
	var c := ConfigFile.new()
	c.set_value("jogo", "estrelas", estrelas)
	c.set_value("jogo", "melhor", melhor)
	c.set_value("jogo", "nome", nome_jogador)
	c.set_value("jogo", "musica", musica_ligada)
	c.save(SAVE)


func carregar() -> void:
	var c := ConfigFile.new()
	if c.load(SAVE) == OK:
		estrelas = c.get_value("jogo", "estrelas", estrelas)
		melhor = c.get_value("jogo", "melhor", melhor)
		nome_jogador = c.get_value("jogo", "nome", "")
		musica_ligada = c.get_value("jogo", "musica", true)


func apagar_progresso() -> void:
	estrelas = [0, 0, 0, 0, 0]
	melhor = [0, 0, 0, 0, 0]
	salvar()


## Código de cupom "FAP-26-XXXX-YYZ" (opção A do doc: sem servidor). A FAP confere o dígito Z.
func gerar_codigo(nome: String) -> String:
	var base := (nome.strip_edges().to_lower() + "|" + str(total_estrelas())).sha256_text()
	var xxxx := base.substr(0, 4).to_upper()
	var faixa := faixa_desconto()
	var soma := faixa * 7 + 31
	for ch in xxxx:
		soma += ch.unicode_at(0)
	return "FAP-26-%s-%02d%d" % [xxxx, faixa, soma % 10]


## Elementos de cada fase: [tipo, argumentos...]. Posições em pixels (x) e alturas acima do chão (dy).
func layout(id: String) -> Array:
	match id:
		"curitiba":
			return [
				["placa", 60, "← → ou A D: andar\nEspaço: pular (segure para pular mais alto)\nShift: correr", 470],
				["placa", 760, "Pegue as moedas \"A\"!\nBata nos blocos ? por baixo!", 330],
				["moedas", 750, 6, 0], ["moeda_arco", 1300, 8, 210], ["bloco", 1150],
				["inimigo", "preguica", 1750, 1550, 2000],
				["placa", 1950, "A porta pede uma resposta.\nChegue perto!", 330],
				["porta", 2350], ["moedas", 2650, 5, 0], ["moeda_arco", 2950, 5, 170], ["bloco", 2800],
				["checkpoint", 3250], ["placa", 3250, "Pule na plataforma\ncom a resposta certa!", 420],
				["caminho", 3500, 4400],
				["moedas", 4700, 6, 0], ["inimigo", "preguica", 4850, 4650, 5100], ["bloco", 4900],
				["porta", 5000], ["moeda_arco", 5250, 8, 200], ["bloco", 5450], ["porta", 5800], ["moedas", 5900, 6, 0],
				["fim", 6700]]
		"foz":
			return [
				["moedas", 700, 5, 0], ["bloco", 900], ["inimigo", "preguica", 1150, 950, 1300],
				["checkpoint", 1330], ["placa", 1250, "Pule nos troncos do rio!\nCai na água? Volta ao checkpoint.", 420],
				["poco", 1450, 2350], ["tronco", 1700, 130, 0.0], ["tronco", 2100, 130, 2.0], ["moeda_arco", 1500, 10, 260],
				["porta", 2750], ["moedas", 3000, 5, 0], ["inimigo", "distracao", 3350, 3150, 3750], ["bloco", 3500],
				["checkpoint", 3800], ["caminho", 4000, 4900],
				["moedas", 5100, 5, 0], ["inimigo", "preguica", 5250, 5050, 5500], ["bloco", 5400],
				["porta", 5800], ["bloco", 6100], ["inimigo", "distracao", 6300, 6200, 6500], ["porta", 6700],
				["fim", 7300]]
		"sao_paulo":
			return [
				["moedas", 700, 5, 0], ["bloco", 900], ["inimigo", "distracao", 1100, 950, 1400],
				["checkpoint", 1500], ["placa", 1450, "Salto longo! Segure Shift\npara correr e pule na beirada.", 420],
				["poco", 1700, 2200], ["moeda_arco", 1700, 6, 280],
				["porta", 2600], ["moedas", 2850, 5, 0],
				["plat", 3100, 170, 300], ["plat", 3450, 330, 300], ["moedas", 3100, 3, 190], ["moedas", 3450, 3, 350],
				["bloco", 3700], ["checkpoint", 3950], ["caminho", 4150, 5050],
				["moedas", 5250, 5, 0], ["bloco", 5450], ["porta", 5700],
				["inimigo", "distracao", 6000, 5850, 6300], ["plat", 6200, 150, 260], ["bloco", 6350], ["porta", 6700],
				["fim", 7300]]
		"florianopolis":
			return [
				["areia", 600, 6400], ["placa", 300, "Cuidado: a areia escorrega!\nPlaneje a freada.", 400],
				["moedas", 700, 5, 0], ["bloco", 900], ["inimigo", "preguica", 1250, 1000, 1450],
				["moeda_arco", 1500, 8, 220], ["porta", 2400], ["moedas", 2700, 5, 0],
				["inimigo", "preguica", 3000, 2800, 3300], ["bloco", 3100],
				["checkpoint", 3500], ["caminho", 3700, 4600],
				["moedas", 4800, 5, 0], ["bloco", 5000], ["inimigo", "preguica", 5200, 5000, 5450],
				["porta", 5800], ["moeda_arco", 6000, 8, 200], ["bloco", 6300], ["porta", 6700],
				["fim", 7300]]
		"porto_alegre":
			return [
				["moedas", 700, 5, 0], ["bloco", 900], ["inimigo", "preguica", 1150, 950, 1400],
				["porta", 2200], ["moeda_arco", 2500, 8, 220], ["inimigo", "distracao", 2900, 2700, 3200], ["bloco", 3000],
				["checkpoint", 3350], ["caminho", 3550, 4450],
				["moedas", 4650, 5, 0], ["bloco", 4800], ["inimigo", "preguica", 5000, 4850, 5200], ["porta", 5400],
				["placa", 5550, "Ponte do Conhecimento!\n3 perguntas montam a ponte.", 420],
				["ponte_final", 5900, 6800],
				["fim", 7200]]
	return []
