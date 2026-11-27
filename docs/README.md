# JOGO-FAP — Documentação

Jogo de plataforma 2D (estilo Mario) da **Faculdade Adventista do Paraná (FAP)**.
O jogador atravessa 5 cidades do Sul/Sudeste, responde perguntas de estudo e da Bíblia e, ao final, ganha um **cupom de desconto**.

> Status (26/11/2026): arte pronta (personagens animados + 5 cenários em parallax). Montagem no Godot ainda **não começou**.

## Índice

| # | Documento | O que tem |
|---|-----------|-----------|
| 1 | [Visão geral](01-visao-geral.md) | Conceito, público, objetivo, escopo, plataformas |
| 2 | [Fluxo do jogo](02-fluxo-do-jogo.md) | Fluxo de telas e fluxo dentro de cada fase (diagramas) |
| 3 | [Mecânicas](03-mecanicas.md) | Controles, movimento, vidas, moedas, inimigos, pontuação |
| 4 | [Fases](04-fases.md) | As 5 cidades: tema, perguntas, obstáculos, dificuldade |
| 5 | [Perguntas](05-perguntas.md) | Banco de perguntas (estudo + Bíblia), formato do arquivo, exemplos |
| 6 | [Desconto](06-desconto.md) | Regras do cupom, segurança, LGPD, o que precisa da FAP |
| 7 | [Arte e assets](07-arte-e-assets.md) | Identidade visual, personagens, cenários, pastas, como regerar |
| 8 | [Arquitetura no Godot](08-arquitetura-godot.md) | Estrutura do projeto, cenas, scripts, configurações |
| 9 | [Roteiro de trabalho](09-roteiro.md) | Etapas, checklist e decisões pendentes |
| 10 | [Desafios](10-desafios.md) | Tipos de desafio (porta, caminho certo, moedas-letra, ordem...), uso por fase, Ponte do Conhecimento |

Material antigo (primeiros rascunhos): pasta [`arquivo/`](arquivo/).

## Estrutura de pastas do projeto

```
JOGO-FAP/
├── docs/                  ← esta documentação
├── assets/
│   ├── personagens/       ← folhas de animação prontas (menino_sheet.png, menina_sheet.png)
│   ├── cenarios/<cidade>/parallax/   ← 3 camadas por cidade (1_fundo, 2_meio, 3_frente)
│   ├── gemini/            ← imagens originais geradas no Gemini (fonte)
│   └── referencias/       ← fotos reais de referência (Wikimedia, com créditos)
├── arte/                  ← peças recortadas dos personagens e rascunhos antigos (SVG/HTML)
├── ferramentas/
│   ├── godot/             ← Godot 4.7.2 (executável)
│   └── *.py               ← scripts que geram/animam a arte
└── jogo/                  ← (a criar) projeto Godot
```

## Ferramentas (todas gratuitas)
- **Godot 4.7.2** — motor do jogo (`ferramentas/godot/`).
- **Gemini** (conta Google) — geração da arte.
- **Python + Pillow** — recorte, animação e parallax (`ferramentas/*.py`).
- **Krita / LibreSprite / Piskel** — retoques manuais, se precisar.
