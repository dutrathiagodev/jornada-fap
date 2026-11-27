export type IconeFato = "mapa" | "presente" | "livro" | "estrela";

export interface Fato {
  readonly valor: string;
  readonly rotulo: string;
  readonly icone: IconeFato;
}
