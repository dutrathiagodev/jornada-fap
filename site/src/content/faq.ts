import type { PerguntaFrequente } from "@/domain/pergunta-frequente";

export const FAQ: readonly PerguntaFrequente[] = [
  {
    pergunta: "É mesmo de graça?",
    resposta: "Sim. O jogo é gratuito e feito só com ferramentas livres, sem compras dentro do jogo.",
  },
  {
    pergunta: "Preciso ser aluno da FAP?",
    resposta:
      "Não. Qualquer pessoa pode jogar. O cupom de desconto é para apresentar na FAP, seguindo as regras da secretaria.",
  },
  {
    pergunta: "Quais são os controles?",
    resposta:
      "Setas ou A/D andam, Espaço pula (segure para pular mais alto), Shift corre. Nas perguntas, use as setas e Espaço, ou as teclas 1 a 4. Esc pausa e N liga ou desliga a música.",
  },
  {
    pergunta: "Quanto tempo leva?",
    resposta:
      "Cada cidade leva em torno de 5 a 8 minutos. Dá para jogar uma por vez e continuar depois: o progresso fica salvo.",
  },
];
