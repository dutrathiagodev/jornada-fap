/** Junta nomes de classes ignorando valores vazios. */
export function classes(...itens: Array<string | false | null | undefined>): string {
  return itens.filter(Boolean).join(" ");
}
