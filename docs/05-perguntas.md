# 5. Banco de perguntas

## 5.1 Regras
- Múltipla escolha com **4 alternativas** e **1 correta**.
- Texto curto: a pergunta com no máximo 120 caracteres e cada alternativa com no máximo 40, para caber no celular.
- Toda pergunta tem uma **explicação** curta (≤ 140 caracteres), mostrada depois da resposta.
- As perguntas da Bíblia trazem a **referência** (livro, capítulo e versículo).
- Tempo para responder: 20 s (pode desligar nas opções de acessibilidade).
- As alternativas aparecem **embaralhadas** a cada vez.
- Mínimo para o MVP: **12 perguntas por fase** (3 portas + bônus + reserva para não repetir), ou seja, **60 no total**.
- **Revisão:** um professor da FAP revisa as perguntas de estudo e um pastor ou capelão revisa as da Bíblia.

## 5.2 Temas por fase
| Fase | Categoria (`tema`) | Exemplos de assunto |
|------|--------------------|---------------------|
| Curitiba | `portugues`, `matematica` | ortografia, crase, frações, porcentagem |
| Foz do Iguaçu | `ciencias`, `geografia` | ciclo da água, biomas, estados e capitais |
| São Paulo | `historia`, `logica`, `tecnologia` | Brasil República, sequências, informática |
| Florianópolis | `biblia` | personagens, milagres, parábolas |
| Porto Alegre | todos + `biblia` | mistura, nível difícil |

## 5.3 Formato do arquivo
Um arquivo JSON por fase em `jogo/dados/perguntas/<cidade>.json`. Assim dá para editar sem mexer em código.

```json
{
  "fase": "curitiba",
  "perguntas": [
    {
      "id": "cwb-001",
      "tema": "matematica",
      "dificuldade": 1,
      "pergunta": "Quanto é 25% de 80?",
      "alternativas": ["20", "25", "16", "40"],
      "correta": 0,
      "explicacao": "25% é um quarto. 80 ÷ 4 = 20."
    },
    {
      "id": "cwb-002",
      "tema": "portugues",
      "dificuldade": 1,
      "pergunta": "Qual palavra está escrita corretamente?",
      "alternativas": ["Exceção", "Excessão", "Eceção", "Esceção"],
      "correta": 0,
      "explicacao": "Exceção vem do verbo excetuar."
    }
  ]
}
```

Bíblia, com o campo extra `referencia`:
```json
{
  "id": "fln-001",
  "tema": "biblia",
  "dificuldade": 2,
  "pergunta": "Quem construiu a arca a pedido de Deus?",
  "alternativas": ["Noé", "Moisés", "Abraão", "Davi"],
  "correta": 0,
  "explicacao": "Deus pediu a Noé que construísse a arca.",
  "referencia": "Gênesis 6:13-14"
}
```

## 5.4 Exemplos iniciais (rascunho para revisão)
| Fase | Pergunta | Resposta |
|------|----------|----------|
| Curitiba | Qual é o plural de "cidadão"? | Cidadãos |
| Curitiba | 3/4 de 100 é igual a... | 75 |
| Foz | As Cataratas do Iguaçu ficam na divisa do Brasil com qual país? | Argentina |
| Foz | Qual bioma tem a mata das Cataratas? | Mata Atlântica |
| São Paulo | Em que ano foi proclamada a República no Brasil? | 1889 |
| São Paulo | Qual vem a seguir: 2, 4, 8, 16, ...? | 32 |
| Florianópolis | Quem derrotou o gigante Golias? | Davi (1 Samuel 17) |
| Florianópolis | Quantos discípulos Jesus escolheu? | 12 (Marcos 3:14) |
| Porto Alegre | Qual é o primeiro livro da Bíblia? | Gênesis |
| Porto Alegre | Qual é a raiz quadrada de 144? | 12 |

> O banco completo, com as 60 perguntas, é uma das tarefas do [roteiro](09-roteiro.md). Precisa de revisão da FAP antes de publicar.
