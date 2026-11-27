# 1. Visão geral

## Conceito
Jogo de plataforma 2D com rolagem lateral, no estilo Super Mario. Dois estudantes da rede adventista (um menino e uma menina, de uniforme) viajam por **5 cidades**. Em cada cidade correm, pulam, coletam moedas e respondem **perguntas** para avançar. Quem termina ganha um **cupom de desconto** na FAP.

**Frase de apresentação:** *"Atravesse o Sul do Brasil, mostre o que você sabe e ganhe desconto para estudar na FAP."*

## Objetivos
| Para quem | Objetivo |
|-----------|----------|
| FAP | Divulgar a faculdade de forma divertida e captar interessados (vestibular/matrícula) |
| Jogador | Diversão rápida (10 a 15 min), testar conhecimentos e ganhar desconto |
| Trabalho da faculdade | Projeto completo: design, arte, programação e documentação |

## Público
- Principal: estudantes do ensino médio (15 a 18 anos), principalmente da rede adventista.
- Secundário: pais e comunidade da igreja.
- O jogo precisa ser **fácil de entender** e funcionar no **celular e no computador**.

## Valores do jogo
- Estudo e fé juntos: perguntas de conhecimento geral e da Bíblia.
- Linguagem positiva e respeitosa. Sem violência: os "inimigos" são ideias como *Preguiça*, *Distração* e *Dúvida*, e o jogador os vence pulando em cima.
- Identidade da Educação Adventista: azul-marinho, azul-claro, branco e o "A" da marca.

## Escopo da 1ª versão (MVP)
Entra:
- 2 personagens jogáveis (escolha no início).
- 5 fases (Curitiba, Foz do Iguaçu, São Paulo, Florianópolis, Porto Alegre).
- Movimento: andar, correr, pular. Moedas, blocos de pergunta e inimigos simples.
- Perguntas de múltipla escolha (estudo e Bíblia).
- Tela final com pontuação e código de desconto.
- Versão Web (link) e Android.

Fica para depois:
- Ranking online, contas de usuário, som/música originais, mais cidades, modo para 2 jogadores.

## Plataformas
| Plataforma | Prioridade | Observação |
|------------|-----------|------------|
| Web (HTML5) | Alta | Basta um link para divulgar. Renderizador *Compatibility* do Godot. |
| Android | Alta | Controles na tela (botões de toque). |
| Windows/Linux | Média | Para apresentações e eventos. |

## Referências de estilo
- Visual: cartoon pintado à mão, no estilo Rayman Legends (parallax com várias camadas).
- Jogabilidade: Super Mario World (pular, moedas, blocos "?").
