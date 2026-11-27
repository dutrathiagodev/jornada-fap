export type IdPlataforma = "windows" | "macos" | "linux";

/** Sistema detectado no navegador de quem visita. */
export type SistemaDetectado = IdPlataforma | "movel" | "desconhecido";

export interface Plataforma {
  readonly id: IdPlataforma;
  readonly nome: string;
  readonly arquivo: string;
  readonly tamanho: string;
  readonly instrucao: string;
}
