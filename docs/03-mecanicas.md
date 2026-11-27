# 3. Mecânicas

## 3.1 Controles
| Ação | Teclado | Controle | Celular (botões na tela) |
|------|---------|----------|--------------------------|
| Andar | ← → ou A D | analógico / direcional | setas à esquerda |
| Correr | Shift (segurar) | X | correr automático ao segurar a seta |
| Pular | Espaço, W ou ↑ | A | botão "Pular" à direita |
| Responder pergunta | ↑ ↓ ← → (ou W A S D) escolhem e **Enter** confirma; ou tecla 1 a 4; ou clique | direcional + A | toque na alternativa |
| Continuar / próxima fase | **Enter** | A | toque |
| Pausar | Esc / P | Start | botão ‖ no canto |

Nomes das ações no Godot (Input Map): `mover_esquerda`, `mover_direita`, `correr`, `pular`, `pausar`, `confirmar` (Enter, A do controle), `voltar` (Esc, B), `mapa` (M, Y), `reiniciar` (R, X), `nav_anterior`/`nav_proximo` (setas, direcional e analógico).

## 3.2 Movimento do personagem
Valores iniciais. São ajustados nos testes e ficam em variáveis exportadas do script do jogador.

| Parâmetro | Valor inicial |
|-----------|---------------|
| Velocidade andando | 320 px/s |
| Velocidade correndo | 520 px/s |
| Aceleração / freio | 2200 / 2600 px/s² |
| Altura do pulo | ~260 px (pulo curto se soltar o botão cedo) |
| Gravidade | 2400 px/s² (caindo: ×1,4 para não "flutuar") |
| Coyote time | 0,1 s (ainda pula logo depois de sair da beirada) |
| Jump buffer | 0,12 s (aperto um pouco antes de tocar o chão vale) |

**Animações** — lista fechada, **exatamente estas**, iguais para o menino e a menina. Cada uma é uma tira própria em `assets/personagens/<menino|menina>/<nome>.png`, tirada quadro a quadro de um vídeo do Veo e tocada a **24 FPS**:
| Estado | Animação | Repete? | Quadros (menino) | Status |
|--------|----------|---------|------------------|--------|
| Parado | `parado` | sim | 38 | ✅ menino |
| Andando/correndo | `correr` | sim | 19 | ✅ menino |
| Apertou pular | `pular_decolar` | não | 35 | ✅ menino |
| Subindo | `pular_subir` | não (segura o último) | 22 | ✅ menino |
| Caindo | `pular_cair` | não (segura o último) | 38 | ✅ menino |
| Tocou o chão | `pular_aterrissar` | não | 46 | ✅ menino |
| Fim de fase / acerto | `comemorar` | não | — | falta |
| Levou dano | `dano` | não | — | falta |
| Sem corações | `derrota` | não | — | falta |

A menina ainda não tem nenhuma tira nova. Nas partes do pulo o pé fica preso na linha do chão: quem sobe e desce é a física do jogo.

O sprite olha para a direita. Para a esquerda usa `flip_h = true`.

## 3.3 Vidas e dano
- **3 corações** por fase.
- Perde 1 coração quando: encosta num inimigo de lado, erra uma pergunta ou cai num buraco (nesse caso volta ao último checkpoint).
- Depois de levar dano, fica **1,5 s piscando**, sem levar dano de novo.
- Sem corações: tela **Fim de jogo**, com as opções repetir a fase ou voltar ao menu.

## 3.4 Itens e objetos
| Objeto | Como funciona | Pontos |
|--------|---------------|--------|
| Moeda "A" | encostar para pegar | +10 |
| Livro | item raro escondido, dá 1 coração extra (máx. 3) | +50 |
| Bloco "?" (azul-marinho) | bater por baixo, abre pergunta bônus | +100 se acertar |
| Porta-pergunta | obrigatória, abre com resposta | +200 se acertar |
| Bandeira FAP | fim da fase | +500 |
| Plataformas | fixas e móveis (horizontal/vertical) | — |

## 3.5 Inimigos (sem violência)
São "maus hábitos" do estudante, desenhados de forma fofa:

| Inimigo | Comportamento | Como vencer |
|---------|---------------|-------------|
| **Preguiça** (bichinho sonolento) | anda devagar de um lado para o outro | pular em cima |
| **Distração** (celular com asinhas) | voa em onda | pular em cima |
| **Dúvida** (nuvenzinha "?") | aparece e some; só some de vez quando o jogador acerta a pergunta seguinte | responder certo |

Pular em cima dá +50 pontos e um pulinho extra.

## 3.6 Pontuação e estrelas
Pontuação da fase = moedas + acertos + bônus de tempo + corações restantes × 100.

Estrelas por fase:
- ★ terminou a fase
- ★★ terminou acertando pelo menos 2 das 3 portas
- ★★★ acertou as 3 portas e pegou 80% das moedas

O total de estrelas (máx. 15) define a faixa de desconto. Ver [Desconto](06-desconto.md).

## 3.7 Câmera e parallax
- `Camera2D` segue o jogador com suavização e limites na largura da fase.
- O cenário usa **3 camadas `Parallax2D`**: fundo (0,12), meio (0,4) e frente/chão (1,0), repetindo na horizontal.
- O chão onde o jogador pisa é colisão própria (`StaticBody2D`/`TileMapLayer`), alinhada com o desenho da camada da frente.
