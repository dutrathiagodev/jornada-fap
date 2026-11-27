# 7. Arte e assets

## 7.1 Identidade visual
| Uso | Cor | Hex |
|-----|-----|-----|
| Marca, mangas, calça, interface | Azul-marinho | `#0B3A6E` |
| Detalhes, debrum, destaques | Azul-claro | `#7CC6EA` |
| Camisa, textos sobre o azul | Branco | `#F8FAFC` |
| Contornos | Azul-noite | `#14213D` |
| Moedas e estrelas | Dourado | `#FFD34E` |

- **Logo:** o "A" da Educação Adventista (logo enviado no chat; salvar em `assets/referencias/identidade/`).
- **Fonte sugerida (grátis):** *Baloo 2* ou *Nunito* (Google Fonts), arredondadas e legíveis no celular.
- **Estilo:** cartoon pintado à mão (Rayman Legends), com contorno escuro nos personagens para destacá-los do cenário.

## 7.2 Personagens
- **Formato:** uma tira PNG por animação em `assets/personagens/<menino|menina>/<animação>.png`, com **quadros de 384 × 384** lado a lado e fundo transparente. Cada tira tem um `.gif` de prévia ao lado.
- **Lista de animações:** exatamente as da tabela em [Mecânicas §3.2](03-mecanicas.md): parado, correr, pular (decolar, subir, cair, aterrissar), comemorar, dano e derrota.
- O pé fica em **y = 371** dentro do quadro (a base da colisão no Godot). A escala é a mesma em todas as animações do personagem (`esc=0.50`). No jogo, a escala sugerida é **0,6**.
- **Como são feitas (quadro a quadro):**
  1. No Gemini (conversa "Criação de Sprite Chibi Escolar"), peça um **vídeo do Veo** do personagem fazendo o movimento **no lugar**, de perfil para a direita, câmera parada e fundo branco.
  2. Baixe pelo botão **Baixar vídeo** (o arquivo chega como `gemini_generated_video_*.mp4`) e guarde em `assets/gemini/veo/`.
  3. Converta com `ferramentas/video_para_sprites.py`. O script usa **todos** os quadros, o mesmo recorte e a mesma escala em todos eles (não treme) e acha o trecho que fecha o loop:
     ```
     # loop (parado, correr)
     python3 ferramentas/video_para_sprites.py assets/gemini/veo/menino_correr.mp4 assets/personagens/menino/correr.png ciclo esc=0.50
     # trecho que não repete, com o pé preso no chão (pulo)
     python3 ferramentas/video_para_sprites.py assets/gemini/veo/menino_pular.mp4 assets/personagens/menino/pular_subir.png trecho 519 540 esc=0.50 pe=1
     ```
- ⚠️ **Veo:** cada vídeo novo na mesma conversa vem com os anteriores no começo (10 s, 20 s, 30 s…). O movimento novo são sempre os **últimos 10 s** (use `de=` ou `trecho`). O limite é de cerca de 3 vídeos por dia.
- **Versões antigas guardadas:** folha 3072 × 2688 feita com o boneco de peças (`menino_sheet.png`, `menina_sheet.png`, script `animar_v2.py`) e a v1 em `assets/personagens/v1-gemini/`.

## 7.3 Cenários (parallax)
Cada cidade tem 3 camadas PNG de **≈ 3870 × 1080**, que repetem na horizontal sem emenda (imagem + cópia espelhada).

| Cidade | Pasta | Topo do chão (y/1080) |
|--------|-------|-----------------------|
| Curitiba | `assets/cenarios/curitiba/parallax/` | 771 |
| Foz do Iguaçu | `assets/cenarios/foz/parallax/` | 731 |
| São Paulo | `assets/cenarios/sao_paulo/parallax/` | 810 |
| Florianópolis | `assets/cenarios/florianopolis/parallax/` | 778 |
| Porto Alegre | `assets/cenarios/porto_alegre/parallax/` | 777 |

| Camada | Arquivo | Velocidade sugerida no `Parallax2D` |
|--------|---------|-------------------------------------|
| Fundo (céu e paisagem distante) | `1_fundo.png` | `scroll_scale = 0.12` |
| Meio (prédios e árvores) | `2_meio.png` | `scroll_scale = 0.4` |
| Frente (chão) | `3_frente.png` | `scroll_scale = 1.0` |

**Como foram feitos:**
1. O Gemini gera cada camada separada. As camadas de meio e de frente vêm sobre fundo **magenta #FF00FF**.
2. Cada imagem é capturada **como aparece na tela** (1376 × 768).
3. O script `ferramentas/camadas_parallax.py` remove o magenta, deixa a camada repetível, aplica o ajuste de altura e salva o PNG:
   ```
   python3 ferramentas/camadas_parallax.py assets/gemini/camadas_<cidade> assets/cenarios/<cidade>/parallax
   ```
   O ajuste de altura da camada do meio fica em `assets/gemini/camadas_<cidade>/deslocamento.txt` (ex.: `2_meio=-0.15` sobe 15%).
4. A prévia com os personagens vem do `ferramentas/demo_parallax.py` (gera `demo_parallax.gif`).

> ⚠️ **Gemini:** **não use** o botão "baixar em tamanho original" nas imagens com fundo magenta. Ele refaz a imagem e inventa coisas (já misturou a ponte de Florianópolis no cenário de Curitiba). Capture a imagem exibida.

## 7.4 Arte do jogo (estado em 27/11/2026)
Tudo abaixo já está no jogo, em `jogo/assets/`:
| Item | Arquivo | Origem |
|------|---------|--------|
| Moeda 3D girando (símbolo "A" da rede) | `objetos/moeda_giro.png` (32 quadros) | vídeo da moeda feito pelo usuário; quadros recortados |
| Bloco "?", inimigos (preguiça e distração), coração, tronco | `objetos/*.png` | Gemini (fundo magenta) + recorte |
| Plataforma de pedra do "caminho certo" | `ui/plataforma_pedra.png` | Gemini; a cor/brilho (certa verde, errada vermelha) é feita em código |
| Porta, bandeira de checkpoint, bandeira final (logo FAP) | `ui/porta.png`, `ui/bandeira_*.png` | Gemini + logo real aplicado por código |
| Painel, botões azul/dourado | `ui/painel.png`, `ui/botao_*.png` | Gemini, usados como 9-slice |
| Capa e tela de título completa | `ui/capa.jpg`, `ui/capa_titulo.jpg` | Gemini (título, botão e barra de comandos já desenhados) |
| Fonte do jogo | `fontes/LilitaOne.ttf` | Lilita One, licença livre (OFL) |
| Logos | `logos/` | arquivos oficiais da FAP e da Educação Adventista |

**Desenhado por código (sem imagem):** buraco de caverna roxa (estalactites e névoa), água dos rios com ondas e bolhas, ponte de tábuas, barra de progresso, cartão de pontos, estrelas, cadeado, ingresso do cupom, confete e vaga-lumes.

**Animações extras:** bandeiras ondulam como pano (faixas verticais), faíscas ao ativar o checkpoint, raios e confete na bandeira final, moeda girando com brilho, "?" da porta flutuando com faíscas.

**Receita do Gemini (fundo magenta):** pedir fundo `#FF00FF` chapado; capturar a imagem exibida (overlay de 100% da altura + captura de tela); recortar pela distância até o magenta e tirar o rosa residual só nas bordas. Cuidado: a regra antiga (`min(r,b)-g`) apaga reflexos e deixa buracos na arte (foi o que estragou o coração e o slime). O Gemini **não** reproduz logos reais: o logo oficial é sempre colocado por código.

Ainda falta: sons e música finais, vídeos Veo de comemorar/dano/derrota e a menina inteira.

## 7.5 Créditos e licenças
- Arte gerada no Gemini (Google), com uso conforme os termos do serviço.
- Fotos de referência: Wikimedia Commons, com autores e licenças em `assets/referencias/CREDITOS.md` (algumas CC BY/BY-SA pedem crédito na tela de créditos).
- Logo e uniforme da Educação Adventista: marca registrada, com uso **sujeito à autorização** da instituição.
- Godot: licença MIT, com o aviso na tela de créditos.
