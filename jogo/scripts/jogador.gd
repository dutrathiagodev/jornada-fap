extends CharacterBody2D
## Menino da FAP. Movimento "gostoso": coyote time, jump buffer, pulo curto/longo,
## cai mais rápido do que sobe, squash & stretch e animações quadro a quadro (24 fps).

signal pulou
signal aterrissou(forte: bool)

const ESCALA := 0.78         # tamanho do sprite no jogo
const QUADRO := 384
const PE := 371              # linha do pé dentro do quadro

const ANIMS := {
	"parado": ["parado", 24.0, true],
	"correr": ["correr", 24.0, true],
	"subir": ["pular_subir", 40.0, false],
	"cair": ["pular_cair", 30.0, false],
	"aterrissar": ["pular_aterrissar", 60.0, false],
}

var vel_andar := 420.0
var vel_correr := 720.0
var aceleracao := 3200.0
var freio := 3000.0
var gravidade := 2400.0
var forca_pulo := -1190.0
var coyote_max := 0.10
var buffer_max := 0.12

var travado := false          # perguntas, fim de fase...
var olhando := 1
var coyote := 0.0
var buffer := 0.0
var invencivel := 0.0
var sem_controle := 0.0
var aterrissando := 0.0
var vy_anterior := 0.0
var estava_no_chao := true

var spr := AnimatedSprite2D.new()
var tween_forma: Tween


static func montar_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	for nome in ANIMS:
		var info: Array = ANIMS[nome]
		var tex: Texture2D = load("res://assets/menino/%s.png" % info[0])
		sf.add_animation(nome)
		sf.set_animation_speed(nome, info[1])
		sf.set_animation_loop(nome, info[2])
		for i in tex.get_width() / QUADRO:
			var at := AtlasTexture.new()
			at.atlas = tex
			at.region = Rect2(i * QUADRO, 0, QUADRO, QUADRO)
			sf.add_frame(nome, at)
	return sf


func _ready() -> void:
	z_index = 5
	var sf := montar_frames()
	spr.sprite_frames = sf
	spr.scale = Vector2(ESCALA, ESCALA)
	spr.position = Vector2(0, -(PE - QUADRO / 2) * ESCALA)
	add_child(spr)

	var forma := CollisionShape2D.new()
	var cap := CapsuleShape2D.new()
	cap.radius = 46.0
	cap.height = 220.0
	forma.shape = cap
	forma.position = Vector2(0, -110)
	add_child(forma)
	spr.play("parado")


func _physics_process(delta: float) -> void:
	vy_anterior = velocity.y
	var dir := 0.0
	if not travado and sem_controle <= 0.0:
		dir = Input.get_axis("mover_esquerda", "mover_direita")
	sem_controle = maxf(0.0, sem_controle - delta)

	# --- horizontal ---
	var vmax := vel_correr if Input.is_action_pressed("correr") else vel_andar
	if dir != 0.0:
		olhando = 1 if dir > 0.0 else -1
		var a := aceleracao
		if signf(velocity.x) != signf(dir) and absf(velocity.x) > 50.0:
			a = freio  # virar rápido
		velocity.x = move_toward(velocity.x, dir * vmax, a * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, freio * delta)

	# --- vertical ---
	if is_on_floor():
		coyote = coyote_max
	else:
		coyote -= delta
	if not travado and Input.is_action_just_pressed("pular"):
		buffer = buffer_max
	else:
		buffer -= delta
	if buffer > 0.0 and coyote > 0.0 and not travado:
		velocity.y = forca_pulo
		buffer = 0.0
		coyote = 0.0
		aterrissando = 0.0
		_forma(Vector2(0.78, 1.25))
		pulou.emit()
	if Input.is_action_just_released("pular") and velocity.y < -350.0:
		velocity.y *= 0.45   # soltou cedo: pulo curto
	var g := gravidade * (1.4 if velocity.y > 0.0 else 1.0)
	velocity.y = minf(velocity.y + g * delta, 1700.0)

	move_and_slide()

	# --- pouso ---
	var no_chao := is_on_floor()
	if no_chao and not estava_no_chao:
		var forte := vy_anterior > 900.0
		_forma(Vector2(1.28, 0.78) if forte else Vector2(1.12, 0.9))
		if forte and dir == 0.0:
			aterrissando = 0.38
		aterrissou.emit(forte)
	estava_no_chao = no_chao

	# --- invencibilidade (pisca) ---
	if invencivel > 0.0:
		invencivel -= delta
		spr.modulate.a = 0.35 + 0.65 * float(int(Time.get_ticks_msec() / 90.0) % 2)
	else:
		spr.modulate.a = 1.0

	_animar(delta, dir)


func _animar(delta: float, dir: float) -> void:
	spr.flip_h = olhando < 0
	aterrissando = maxf(0.0, aterrissando - delta)
	if not is_on_floor():
		spr.speed_scale = 1.0
		_tocar("subir" if velocity.y < 0.0 else "cair")
	elif aterrissando > 0.0 and absf(velocity.x) < 30.0:
		_tocar("aterrissar")
	elif absf(velocity.x) > 25.0:
		_tocar("correr")
		spr.speed_scale = clampf(absf(velocity.x) / 520.0, 0.55, 1.5)
	else:
		spr.speed_scale = 1.0
		_tocar("parado")


func _tocar(nome: String) -> void:
	if spr.animation != nome:
		spr.play(nome)


## squash & stretch: deforma o sprite e volta suave
func _forma(f: Vector2) -> void:
	if tween_forma:
		tween_forma.kill()
	spr.scale = Vector2(ESCALA, ESCALA) * f
	tween_forma = create_tween()
	tween_forma.tween_property(spr, "scale", Vector2(ESCALA, ESCALA), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func dano(empurrar_de_x := NAN) -> void:
	invencivel = 1.5
	if not is_nan(empurrar_de_x):
		velocity = Vector2(signf(global_position.x - empurrar_de_x) * 420.0, -560.0)
		sem_controle = 0.3
	_forma(Vector2(1.2, 0.85))
