# JOGO-FAP — Plano do jogo

Plataforma 2D estilo Mario, feito em Godot 4.7.2 (gratuito, open source).
Tema: Faculdade Adventista do Paraná (FAP). Ganhar as fases = desconto.

## Como rodar o Godot
```
~/Documentos/faculdade/JOGO-FAP/ferramentas/godot/Godot_v4.7.2-stable_linux.x86_64
```
Crie o projeto na pasta `JOGO-FAP/jogo/` (Project Manager > New Project > renderer Compatibility, que roda em qualquer PC).

## Como se cria um jogo no Godot (resumo)
- Tudo é **Cena** (scene) feita de **Nós** (nodes). Jogador = `CharacterBody2D` + `Sprite2D`/`AnimatedSprite2D` + `CollisionShape2D`.
- Fase = `TileMapLayer` (chão e plataformas) + inimigos/itens (`Area2D`) + `Camera2D`.
- Código em **GDScript** (parecido com Python). Pulo/movimento: `move_and_slide()`.
- Interface (perguntas, vidas, desconto) = nós `Control` (`CanvasLayer`).
- Exportar: Web (HTML5, ótimo pra divulgar num link), Windows, Linux, Android.
- Doc oficial: https://docs.godotengine.org/pt-br/ — comece por "Seu primeiro jogo 2D".

## Fases (região Sul, 5 cenários)
| # | Cenário | Visual | Desafio |
|---|---------|--------|---------|
| 1 | Curitiba — montanhas / Serra do Mar | morros, araucárias, Jardim Botânico | Estudo: matemática/português |
| 2 | Foz do Iguaçu — cataratas | cachoeiras, passarelas, verde | Estudo: conhecimentos gerais / ENEM |
| 3 | São Paulo — prédios | skyline, arranha-céus, telhados | Estudo: lógica / tecnologia |
| 4 | Florianópolis | pontes, praias, dunas | Bíblia: personagens e histórias |
| 5 | Porto Alegre | pôr do sol no Guaíba, usina | Chefão: mistura estudo + Bíblia |

Ordem das 3 principais (Curitiba, Foz, SP) mais as 2 do Sul fica ajustável.

## Personagens
Menina e menino, ambos com a camisa da IASD/rede adventista. Jogador escolhe no início.
Visual pixel art 32x32 (fácil de animar: parado, andar, pular).

## Desafios (ideias)
- **Quiz-porta**: no fim de cada trecho uma porta pede uma pergunta; acertar abre.
- **Moedas de conhecimento**: coletáveis que, ao pegar, mostram um versículo ou fato curto.
- **Inimigos "Procrastinação / Dúvida"**: pula em cima pra vencer (estilo Mario).
- **Versículo embaralhado**: monta a frase na ordem certa.
- **Chefão (Porto Alegre)**: 3 perguntas seguidas, estudo + Bíblia.

## Recompensa
Pontuação final vira desconto (exemplo, ajustar com a FAP):
- 1–2 fases: 5% · 3–4 fases: 10% · 5 fases: 15% + cupom/código.
Regra real do desconto precisa vir da faculdade.

## Ferramentas GRATUITAS para arte e design
| Para quê | Ferramenta | Link |
|---|---|---|
| Pixel art / sprites | Piskel (no navegador) | https://www.piskelapp.com |
| Pixel art desktop | LibreSprite | https://libresprite.github.io |
| Pintar cenários | Krita | https://krita.org |
| Mapas de fase | TileMap do próprio Godot (Tiled é opcional) | https://www.mapeditor.org |
| Arte pronta CC0 | Kenney | https://kenney.nl/assets |
| Arte pronta | OpenGameArt, itch.io (filtro CC0) | https://opengameart.org · https://itch.io/game-assets/free |
| Sons/música | Freesound, Kenney audio, OpenGameArt | https://freesound.org |
| Interface/mockups | Figma (grátis) ou Inkscape | https://www.inkscape.org |

Sempre conferir a licença de cada asset na página dele (use CC0 ou dê crédito).

## Fotos para os cenários
Ideia: usar fotos reais como **referência** e desenhar em pixel art por cima (Krita), ou
estilizar com filtro. Para usar fotos da FAP/IASD, o ideal é pedir autorização à faculdade.
Fotos de cidades: Wikimedia Commons (licenças livres) — guardar em `assets/referencias/`.

## Próximos passos
1. Abrir o Godot e fazer o tutorial "Dodge the Creeps" (1–2 h).
2. Criar projeto em `jogo/`, personagem andando e pulando.
3. Fase 1 (Curitiba) com tileset Kenney, depois trocar pelo visual próprio.
4. Tela de pergunta + pontuação + desconto final.
5. Exportar para Web e testar.

## Fontes
- Docs Godot: https://docs.godotengine.org/pt-br/
- Download oficial: https://godotengine.org/pt-br/download
- Kenney Platformer Pack: https://kenney.nl/assets/platformer-art-pixel-redux
- Info FAP: instituição privada em Ivatuba-PR, mantida pela Instituição Adventista Sul Brasileira de Educação.

## Arte (atualizado 26/11/2026)
- Personagens: arte do Gemini em peças (`assets/gemini/*_partes_gemini.jpeg`), animadas por esqueleto com `ferramentas/animar_partes.py`.
  Folhas em `assets/personagens/` (quadros 384x384): linha 0 parado(8), 1 correr(8), 2 pular(2), 3 cair(2), 4 comemorar(6).
- Cenários: as 5 cidades estão em `assets/gemini/cenario_*.jpeg` (imagem única).
- Parallax: Curitiba já está em 3 camadas repetíveis em `assets/cenarios/curitiba/parallax/` (fundo, meio, frente; topo do chão em y=771 de 1080).
  Velocidades sugeridas no `Parallax2D`: fundo 0.12, meio 0.4, frente 1.0.
- Atenção Gemini: o botão "baixar em tamanho original" refaz a imagem e às vezes inventa coisas (principalmente com fundo magenta).
  Para camadas, capturar a imagem exibida (1376x768) em vez de baixar.

## Asset Library do Godot (grátis, MIT/CC0)
- Parallax: nó nativo `Parallax2D` (Godot 4.3+), não precisa de plugin.
- Controle do jogador: "Ultimate Platformer Controller 2D" (id 3312) ou "Parametric 2D Platformer Player Controller" (id 3912).
- Perguntas/diálogos: "Dialogue Manager 3" (id 3654).
- Arte extra CC0: "Kenney's Pixel Platformer" (id 1858).
- Parallax pronto para as 5 cidades em `assets/cenarios/<cidade>/parallax/` (1_fundo, 2_meio, 3_frente), com demo `demo_parallax.gif` em cada pasta.
  Fonte das camadas: `assets/gemini/camadas_<cidade>/` (+ `deslocamento.txt` com o ajuste de altura da camada do meio).
  Para refazer: `python3 ferramentas/camadas_parallax.py assets/gemini/camadas_<cidade> assets/cenarios/<cidade>/parallax`
