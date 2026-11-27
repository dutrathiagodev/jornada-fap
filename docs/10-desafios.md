# 10. Desafios

O jogo não pode ser "um quiz com um boneco andando". Os desafios precisam **ser parte do jogo de plataforma**: o jogador responde pulando, pegando e pisando, e não só clicando numa lista.

## 10.1 Princípios
1. **Responder = jogar.** Sempre que der, a resposta é um movimento (pular na plataforma certa, pegar a moeda certa).
2. **Errar ensina.** Todo erro mostra a resposta certa e a explicação curta. Quem erra aprende, e não só perde.
3. **Nunca trava.** O erro tira 1 coração, mas a pergunta segue e a fase pode ser terminada. Perdeu tudo, tenta a fase de novo com perguntas diferentes.
4. **Curto.** Cada desafio dura de 10 a 30 segundos, para não quebrar o ritmo.
5. **Acessível.** Tempo desligável, texto grande, vale com teclado, toque e controle.

## 10.2 Os 6 tipos de desafio

| # | Tipo | Como funciona | Serve para | Obrigatório? |
|---|------|---------------|-----------|--------------|
| 1 | **Porta-pergunta** | A porta bloqueia o caminho. Abre a caixa com a pergunta e 4 alternativas. Acertou, a porta abre. | qualquer tema | Sim, 3 por fase |
| 2 | **Caminho certo** | A pergunta aparece no alto e 3 ou 4 plataformas (ou portas) têm as alternativas. Pular na errada a faz cair, e o jogador volta e tenta outra (perde 1 coração só na 1ª vez). | geografia, história, Bíblia | Sim, 1 por fase |
| 3 | **Bloco "?" bônus** | Bate por baixo, aparece uma pergunta rápida de verdadeiro ou falso. Acertou, ganha 100 pontos ou um item. | revisão rápida | Não |
| 4 | **Moedas-letra** | Uma dica aparece na tela ("Capital do Paraná") e moedas com letras ficam espalhadas. Pega as letras na ordem para formar a palavra. | português, ortografia, nomes da Bíblia | Não, 1 por fase |
| 5 | **Conta no portal** | O portal pede um número (ex.: "some 24"). Há moedas numeradas pelo cenário. Pega as que somam o valor. | matemática | Não (fases 1 e 3) |
| 6 | **Ordem certa** | Blocos numerados ou com figuras (os dias da criação, linha do tempo). Pisar na ordem correta forma uma ponte. | história, Bíblia | Não (fases 3, 4 e 5) |

O inimigo **Dúvida** (nuvem "?") é um sétimo desafio embutido: some de vez quando o jogador acerta a próxima pergunta (ver [Mecânicas](03-mecanicas.md)).

## 10.3 O que cada fase usa

| Fase | Tema | Porta-pergunta | Caminho certo | Extras |
|------|------|:--------------:|:-------------:|--------|
| 1 Curitiba | Português e Matemática | 3 | 1 (fácil, 2 alternativas) | Conta no portal, moedas-letra |
| 2 Foz do Iguaçu | Ciências e Geografia | 3 | 1 (troncos no rio como alternativas) | Bloco "?" |
| 3 São Paulo | História, Lógica e Tecnologia | 3 | 1 | Ordem certa (linha do tempo), conta no portal |
| 4 Florianópolis | Bíblia | 3 | 1 | Moedas-letra (nomes bíblicos), Ordem certa (dias da criação) |
| 5 Porto Alegre | Mistura + Bíblia | 3 | 1 | **Ponte do Conhecimento** (3 perguntas seguidas), Ordem certa |

> **Troncos no rio (Foz):** o caminho certo aproveita a novidade da fase. Cada tronco flutuante carrega uma alternativa, e o jogador pula no certo.

## 10.4 Ponte do Conhecimento (desafio final)
Na fase 5, antes da bandeira há um abismo. O jogador responde **3 perguntas seguidas** (uma de estudo, uma da Bíblia e uma mista) e **cada acerto monta um pedaço da ponte**. Errou, a pergunta volta com outras alternativas e o jogador perde 1 coração. Com a ponte completa, a bandeira fica ao alcance.

## 10.5 Perguntas de Bíblia
Têm cuidado extra, porque é parte da identidade da FAP:
- Todas trazem a **referência** (livro, capítulo, versículo), mostrada depois da resposta.
- Tom **acolhedor**: o erro nunca vem com "você errou feio", e sim "quase! a resposta é... (Gênesis 6)".
- Revisão por pastor ou capelão antes de publicar.
- Versão da Bíblia a ser usada nos versículos: a definir com a FAP (decisão pendente).

## 10.6 Dificuldade e dicas
| Dificuldade | Como aparece |
|-------------|--------------|
| ★ (1) | 2 alternativas no caminho certo, pergunta direta |
| ★★ (2) | 3 a 4 alternativas |
| ★★★ (3) | 4 alternativas, pergunta com raciocínio, tempo menor |

**Dica:** uma vez por fase o jogador gasta uma moeda "A" para eliminar 2 alternativas erradas, como o "50/50" dos programas de perguntas.

## 10.7 Como entra na pontuação e no desconto
Cada tipo marca acerto ou erro e alimenta as **estrelas** (ver [Mecânicas §3.6](03-mecanicas.md) e [Desconto](06-desconto.md)). Só contam para as estrelas as perguntas **obrigatórias** (porta, caminho certo, ponte). Os extras dão pontos e itens, mas não derrubam o desconto de quem prefere não fazê-los.

## 10.8 Como fica no código (Godot)
- Uma cena base `Desafio` com os sinais `acertou` e `errou`, e cada tipo é uma cena que herda dela: `PortaPergunta`, `CaminhoCerto`, `BlocoBonus`, `MoedasLetra`, `ContaNoPortal`, `OrdemCerta`.
- Os dados vêm dos JSON em `jogo/dados/perguntas/` (ver [Perguntas](05-perguntas.md)). Para os tipos novos, o JSON ganha o campo `tipo` e os campos próprios (`palavra`, `alvo`, `ordem`).
- **Decidido (27/11/2026):** o MVP tem só `PortaPergunta` e `CaminhoCerto`. Os outros tipos entram depois, sem mudar o resto do jogo.

## 10.9 Decisões pendentes
- A FAP quer só múltipla escolha, ou aceita os tipos com movimento (caminho certo, moedas-letra)?
- Quem escreve e revisa os desafios de ordem e de moedas-letra (precisam de conteúdo extra além das 60 perguntas).
- Versão da Bíblia para as referências.
