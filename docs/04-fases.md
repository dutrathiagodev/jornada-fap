# 4. Fases

Ordem fixa, com dificuldade crescente. Cada fase leva de 2 a 3 minutos e tem 3 portas-pergunta.

| # | Cidade | Tema das perguntas | Dificuldade | Novidade de jogabilidade |
|---|--------|--------------------|-------------|--------------------------|
| 1 | Curitiba | Português e Matemática básica | ★☆☆ | Tutorial: andar, pular, moeda, 1º bloco "?" |
| 2 | Foz do Iguaçu | Ciências e Geografia | ★★☆ | Plataformas móveis (troncos no rio), inimigo Distração |
| 3 | São Paulo | História, Lógica e Tecnologia | ★★☆ | Telhados e pulos longos, correr fica importante |
| 4 | Florianópolis | Bíblia: personagens e histórias | ★★★ | Areia (escorrega um pouco), inimigo Dúvida |
| 5 | Porto Alegre | Desafio final: estudo + Bíblia | ★★★ | Sequência de 3 perguntas seguidas antes da bandeira |

## Detalhes por fase

### Fase 1 — Curitiba
- **Cenário:** céu azul com a Serra do Mar, morros com araucárias, a Estufa do Jardim Botânico e um chão de grama.
- **Camadas:** `assets/cenarios/curitiba/parallax/`. Topo do chão em **y = 771** (de 1080).
- **Ensina:** movimento, pulo, pegar moeda e bater no bloco "?". Placas com dicas no começo.
- **Inimigo:** Preguiça (poucos).
- **Curiosidade ao acertar:** "A araucária é a árvore-símbolo do Paraná."

### Fase 2 — Foz do Iguaçu
- **Cenário:** Cataratas com arco-íris ao pôr do sol, mata atlântica com tucanos e quatis, e grama sobre terra vermelha.
- **Camadas:** `assets/cenarios/foz/parallax/`. Topo do chão em **y = 731**.
- **Novidade:** troncos flutuando que se movem e buracos com "água".
- **Inimigos:** Preguiça e Distração.

### Fase 3 — São Paulo
- **Cenário:** skyline dourado com Copan e Edifício Itália, o MASP, ipês, e chão de calçada de ondas pretas e brancas.
- **Camadas:** `assets/cenarios/sao_paulo/parallax/`. Topo do chão em **y = 810**.
- **Novidade:** pular entre toldos e telhados (plataformas em várias alturas).
- **Inimigos:** Distração (mais rápido).

### Fase 4 — Florianópolis
- **Cenário:** mar turquesa com a Ponte Hercílio Luz, casinhas açorianas e coqueiros, e chão de areia com conchas.
- **Camadas:** `assets/cenarios/florianopolis/parallax/`. Topo do chão em **y = 778**.
- **Novidade:** areia com menos atrito e dunas em rampa.
- **Inimigos:** Dúvida e Preguiça.

### Fase 5 — Porto Alegre (final)
- **Cenário:** pôr do sol no Guaíba com a Catedral, a Usina do Gasômetro e jacarandás, e chão de grama.
- **Camadas:** `assets/cenarios/porto_alegre/parallax/`. Topo do chão em **y = 777**.
- **Novidade:** no fim, a **"Ponte do Conhecimento"**: 3 perguntas seguidas, e cada acerto monta um pedaço da ponte até a bandeira.
- **Inimigos:** todos, em menor quantidade (o foco são as perguntas).

## Como uma fase é montada (padrão para todas)
1. Fundo: 3 camadas `Parallax2D` da cidade.
2. Chão e plataformas: `TileMapLayer` invisível de colisão, mais blocos visuais.
3. Itens: moedas, blocos "?", livro (cenas reutilizáveis).
4. Inimigos posicionados à mão.
5. 3 `PortaPergunta`, cada uma com o tema da cidade.
6. `BandeiraFim` no final.
7. Limites da câmera = largura da fase (cerca de 8 000 a 12 000 px).
