export type ObjetoDoJogo = "preguica" | "coracao" | "bloco" | "porta";

export interface Destaque {
  readonly secaoId: string;
  readonly eyebrow: string;
  readonly tituloLinhas: readonly [string, string];
  readonly citacao: string;
  readonly texto: string;
  readonly itens: readonly string[];
  readonly imagem: string;
  readonly legenda: string;
  readonly objeto: ObjetoDoJogo;
  readonly invertido: boolean;
}
