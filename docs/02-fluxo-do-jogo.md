# 2. Fluxo do jogo

## 2.1 Fluxo de telas

```mermaid
flowchart TD
    A[Abertura<br/>logo FAP + Educação Adventista] --> B[Menu principal]
    B -->|Jogar| C[Escolha do personagem<br/>menino ou menina]
    B -->|Como jogar| H[Tutorial rápido<br/>controles e regras]
    B -->|Créditos| K[Créditos<br/>fotos, ferramentas, equipe]
    H --> B
    K --> B
    C --> D[Mapa da viagem<br/>5 cidades em sequência]
    D --> F1[Fase 1 · Curitiba]
    F1 -->|passou| D
    D --> F2[Fase 2 · Foz do Iguaçu]
    F2 -->|passou| D
    D --> F3[Fase 3 · São Paulo]
    F3 -->|passou| D
    D --> F4[Fase 4 · Florianópolis]
    F4 -->|passou| D
    D --> F5[Fase 5 · Porto Alegre<br/>desafio final]
    F5 -->|passou| R[Resultado<br/>pontuação + estrelas]
    R --> CP[Cupom de desconto<br/>código + como usar]
    CP --> B
    F1 & F2 & F3 & F4 & F5 -->|sem vidas| GO[Fim de jogo<br/>tentar de novo]
    GO -->|repetir fase| D
    GO -->|menu| B
```

**Regras do fluxo**
- As fases são liberadas **em ordem**. Só dá para entrar na próxima depois de passar a anterior.
- O progresso fica salvo no aparelho (quais fases já passou e a melhor pontuação de cada uma).
- O botão **Pausar** existe dentro das fases: continuar, reiniciar a fase ou voltar ao mapa.
- O cupom só aparece depois de passar a **Fase 5**. Se o jogador parar antes, vê quanto faltou.

## 2.2 Fluxo dentro de uma fase

```mermaid
flowchart LR
    S[Início da fase<br/>nome da cidade] --> P1[Trecho 1<br/>correr, pular, moedas]
    P1 --> Q1{Porta-pergunta 1}
    Q1 -->|acertou| P2[Trecho 2]
    Q1 -->|errou| E1[Perde 1 coração<br/>e vê a resposta certa] --> P2
    P2 --> Q2{Porta-pergunta 2}
    Q2 --> P3[Trecho 3<br/>mais difícil]
    P3 --> Q3{Porta-pergunta 3}
    Q3 --> FIM[Bandeira da FAP<br/>fim da fase]
    FIM --> RES[Resumo da fase<br/>moedas, acertos, estrelas]
```

- Cada fase tem **3 portas-pergunta** no caminho. A porta só abre depois da resposta.
- Errar **não trava** o jogador: ele perde um coração, vê a explicação e segue em frente. A ideia é aprender, não punir.
- Ao longo do caminho também há **blocos "?"** opcionais. Bater por baixo abre uma pergunta bônus, que vale moedas extras.
- **Checkpoints:** cada porta-pergunta funciona como ponto de retorno se o jogador cair num buraco.

## 2.3 Fluxo de uma pergunta

```mermaid
sequenceDiagram
    participant J as Jogador
    participant G as Jogo
    J->>G: encosta na porta ou bate no bloco "?"
    G->>G: pausa a fase e sorteia pergunta do tema da cidade
    G->>J: mostra pergunta + 4 alternativas (com tempo de 20 s)
    J->>G: escolhe uma alternativa
    alt acertou
        G->>J: "Certo!" + versículo ou curiosidade + pontos
    else errou ou tempo esgotou
        G->>J: mostra a certa + explicação curta, tira 1 coração
    end
    G->>J: volta a fase (porta aberta)
```

## 2.4 Estados que o jogo guarda
| Dado | Onde | Para quê |
|------|------|----------|
| Personagem escolhido | memória da partida | trocar sprites |
| Fases liberadas e estrelas | arquivo local (`user://progresso.save`) | mapa e continuar depois |
| Pontuação, moedas, acertos | memória da partida | resultado e cupom |
| Perguntas já usadas | memória da partida | não repetir na mesma partida |
| Cupom gerado | arquivo local | mostrar de novo se fechar o jogo |
