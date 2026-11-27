import type { Cidade } from "@/domain/cidade";

export const CIDADES: readonly Cidade[] = [
  {
    id: "curitiba",
    fase: 1,
    nome: "Curitiba",
    materia: "Português e Matemática",
    descricao:
      "Entre pelas portas-pergunta e escolha a plataforma certa sobre o buraco, no Jardim Botânico e entre as araucárias.",
    imagem: "cidades/cid_curitiba.webp",
  },
  {
    id: "foz",
    fase: 2,
    nome: "Foz do Iguaçu",
    materia: "Ciências e Geografia",
    descricao: "Pule nos troncos que boiam no rio, perto das Cataratas e do arco-íris.",
    imagem: "cidades/cid_foz.webp",
  },
  {
    id: "sao_paulo",
    fase: 3,
    nome: "São Paulo",
    materia: "História, Lógica e Tecnologia",
    descricao: "Saltos longos entre prédios, celulares com asas e a Avenida Paulista ao entardecer.",
    imagem: "cidades/cid_sao_paulo.webp",
  },
  {
    id: "florianopolis",
    fase: 4,
    nome: "Florianópolis",
    materia: "Bíblia: personagens e histórias",
    descricao: "A areia escorrega! Planeje a freada diante da Ponte Hercílio Luz.",
    imagem: "cidades/cid_florianopolis.webp",
  },
  {
    id: "porto_alegre",
    fase: 5,
    nome: "Porto Alegre",
    materia: "Desafio final: estudo e Bíblia",
    descricao:
      "Três respostas certas montam a Ponte do Conhecimento sobre o Guaíba. A bandeira da FAP espera do outro lado.",
    imagem: "cidades/cid_porto_alegre.webp",
  },
];
