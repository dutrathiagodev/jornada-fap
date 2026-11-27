import type { Destaque } from "@/domain/destaque";

export const DESTAQUES: readonly Destaque[] = [
  {
    secaoId: "desafios",
    eyebrow: "Estudo de verdade",
    tituloLinhas: ["Cada porta faz", "uma pergunta"],
    citacao: "Aprender é a maior aventura.",
    texto:
      "Matemática, português, ciências, geografia, história, lógica, tecnologia e Bíblia. As perguntas aparecem em portas, em blocos “?” e nas plataformas do caminho. Errou? O jogo explica a resposta e você continua.",
    itens: [
      "Responda com as setas e Espaço, ou com as teclas 1 a 4",
      "Tempo para pensar, com barra que acompanha",
      "Explicação depois de cada resposta",
    ],
    imagem: "telas/pergunta.webp",
    legenda: "Caixa de pergunta do jogo",
    objeto: "porta",
    invertido: false,
  },
  {
    secaoId: "mundo",
    eyebrow: "Plataforma de verdade",
    tituloLinhas: ["Pule na", "resposta certa"],
    citacao: "Quem fica firme na resposta certa, atravessa.",
    texto:
      "No caminho certo, três pedras flutuantes mostram três respostas. Pule na correta e fique nela até a barra dourada encher. Se errar, a pedra racha e você perde um coração. Cuidado com o preguiçoso roxo e com o celular distraído.",
    itens: [
      "Pulo curto e longo: controle fácil de aprender",
      "Checkpoints com bandeira: cair não é o fim",
      "Pontos, moedas e até 3 estrelas por cidade",
    ],
    imagem: "telas/caminho.webp",
    legenda: "Caminho certo sobre o buraco",
    objeto: "preguica",
    invertido: true,
  },
  {
    secaoId: "ponte",
    eyebrow: "Cada cidade, uma regra",
    tituloLinhas: ["A Ponte do", "Conhecimento"],
    citacao: "Um acerto de cada vez.",
    texto:
      "No fim de Porto Alegre, o rio só se atravessa com saber: cada resposta certa constrói um pedaço da ponte de tábuas. Acertou as três? A bandeira da FAP está esperando do outro lado.",
    itens: [
      "Três perguntas, três tábuas",
      "Estudo e Bíblia no mesmo desafio",
      "Chegue à bandeira e receba suas estrelas",
    ],
    imagem: "telas/ponte.webp",
    legenda: "Ponte do Conhecimento em Porto Alegre",
    objeto: "coracao",
    invertido: false,
  },
];
