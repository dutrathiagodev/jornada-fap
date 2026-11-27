# 8. Arquitetura no Godot

## 8.1 Configuração do projeto
| Item | Valor |
|------|-------|
| Versão | Godot 4.7.2 (`ferramentas/godot/Godot_v4.7.2-stable_linux.x86_64`) |
| Pasta | `JOGO-FAP/jogo/` |
| Renderizador | **Compatibility** (funciona na Web e em celulares simples) |
| Resolução base | 1920 × 1080, `stretch_mode = canvas_items`, `aspect = expand` |
| Linguagem | GDScript |
| Física | 2D padrão do Godot |

## 8.2 Estrutura de pastas do jogo
```
jogo/
├── project.godot
├── autoload/
│   ├── Jogo.gd              ← estado da partida (personagem, pontos, vidas, fase atual)
│   ├── Progresso.gd         ← salvar/carregar progresso (user://progresso.save)
│   └── Perguntas.gd         ← carrega os JSON, sorteia sem repetir
├── cenas/
│   ├── telas/               ← Abertura, Menu, EscolhaPersonagem, Mapa, Resultado, Cupom, FimDeJogo, Creditos
│   ├── jogador/Jogador.tscn ← CharacterBody2D + AnimatedSprite2D + CollisionShape2D
│   ├── fases/               ← Fase_Curitiba.tscn ... Fase_PortoAlegre.tscn (herdam de FaseBase.tscn)
│   ├── objetos/             ← Moeda, BlocoPergunta, PortaPergunta, CaminhoCerto, Livro, BandeiraFim, PlataformaMovel, Checkpoint
│   ├── inimigos/            ← Preguica, Distracao, Duvida
│   └── ui/                  ← HUD (corações, moedas), JanelaPergunta, Pausa, BotoesToque
├── scripts/                 ← scripts compartilhados (se houver)
├── dados/perguntas/         ← curitiba.json, foz.json, sao_paulo.json, florianopolis.json, porto_alegre.json
└── assets/                  ← cópia/links da arte usada (personagens, cenários, ui, sons)
```

## 8.3 Cenas principais

**Jogador.tscn**
```
Jogador (CharacterBody2D)  ← Jogador.gd: movimento, pulo, dano, animação
├── Sprite (AnimatedSprite2D)  ← SpriteFrames feito da folha 384×384 (menino ou menina)
├── Colisao (CollisionShape2D)  ← cápsula ~70×150 (na escala 0,5)
├── Pes (RayCast2D)  ← opcional, para detectar a beirada
└── Camera2D  ← suavização ligada, limites definidos pela fase
```

**FaseBase.tscn**, da qual todas as fases herdam:
```
Fase (Node2D)  ← Fase.gd: tema das perguntas, início/fim, checkpoints
├── Fundo (Node2D)
│   ├── CamadaFundo (Parallax2D, scroll_scale 0.12, repeat_size.x = largura da imagem)
│   ├── CamadaMeio  (Parallax2D, scroll_scale 0.4)
│   └── CamadaFrente(Parallax2D, scroll_scale 1.0)
├── Chao (TileMapLayer ou StaticBody2D)  ← colisão alinhada ao topo do chão da cidade
├── Objetos (Node2D)  ← moedas, blocos, portas, plataformas
├── Inimigos (Node2D)
├── Jogador (instância)
├── BandeiraFim
└── UI (CanvasLayer) ← HUD + JanelaPergunta + Pausa + BotoesToque
```

## 8.4 Scripts globais (Autoload)
| Autoload | Responsabilidade | Funções principais |
|----------|------------------|--------------------|
| `Jogo` | estado da partida | `iniciar_partida(personagem)`, `adicionar_pontos(n)`, `perder_vida()`, `concluir_fase(estrelas)` |
| `Progresso` | gravação local | `salvar()`, `carregar()`, `fase_liberada(n)`, `estrelas_total()` |
| `Perguntas` | banco de perguntas | `carregar(fase)`, `sortear(tema) -> Dictionary`, `marcar_usada(id)` |

**Sinais (eventos) entre as cenas:**
- `PortaPergunta.pergunta_pedida(tema)` → a `JanelaPergunta` abre e o jogo pausa (`get_tree().paused = true`, com a janela em `process_mode = ALWAYS`).
- `JanelaPergunta.respondida(acertou: bool)` → a porta abre, `Jogo` soma pontos ou tira vida.
- `Jogador.morreu` → volta ao checkpoint ou abre a tela de Fim de Jogo.
- `BandeiraFim.alcancada` → resumo da fase, depois volta ao Mapa.

## 8.5 Input Map
| Ação | Teclas |
|------|--------|
| `mover_esquerda` | ←, A, direcional esquerda |
| `mover_direita` | →, D, direcional direita |
| `correr` | Shift, X do controle |
| `pular` | Espaço, W, ↑, A do controle |
| `pausar` | Esc, P, Start |

No celular, a cena `BotoesToque` usa `TouchScreenButton` ligados às mesmas ações. Ela só aparece em telas de toque.

## 8.6 Recursos da Asset Library (grátis)
| Necessidade | Opção | Licença |
|-------------|-------|---------|
| Parallax | Nó nativo `Parallax2D` (Godot 4.3+), sem plugin | — |
| Controle do personagem (referência) | *Ultimate Platformer Controller 2D* (id 3312) | MIT |
| Diálogos/perguntas (opcional) | *Dialogue Manager 3* (id 3654) | MIT |

A janela de pergunta é simples. Fazer à mão com nós `Control` é mais fácil que usar plugin.

## 8.7 Exportação
- **Web:** instalar os *Export Templates* 4.7.2 (Editor → Manage Export Templates). Exportar HTML5 e publicar no itch.io ou GitHub Pages (ambos grátis).
- **Android:** precisa do Android SDK e de uma chave de assinatura (debug serve para testes).
- **Tamanho:** comprimir as camadas em WebP com perda (qualidade ~85) na importação, para o jogo Web ficar leve.


## 8.8 Como o jogo está montado hoje (27/11/2026)
- Cenas: `main.tscn` (título), `mapa.tscn`, `fase.tscn`, `final.tscn`. Cada uma só chama um script; a tela é montada **por código** (`titulo.gd`, `mapa.gd`, `fase.gd`, `final.gd`).
- `fase.gd` contém a fase inteira e as classes internas: `Moeda`, `Porta`, `Bloco`, `Inimigo`, `Tronco`, `Abismo`, `Plat`, `Bandeira`, `Progresso`, `Coracoes`.
- `estrelas.gd` (`class_name Estrelas`) desenha as estrelas do mapa, do resultado e do cupom.
- Autoloads: `Jogo` (cidades, layout de cada fase, progresso salvo em `user://progresso.cfg`, cupom, fonte Lilita One) e `Perguntas` (banco de perguntas e mapa de teclas).
- Resolução 1920×1080, renderizador Compatibility. A pausa e as perguntas pausam só o mundo; a interface continua ativa e o HUD fica por cima do escurecimento.
- Variáveis de teste `FAP_CIDADE`, `FAP_X`, `FAP_DEMO`, `FAP_PAUSA`: ver `jogo/README.md`.
