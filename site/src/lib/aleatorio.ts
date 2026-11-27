/**
 * Número pseudoaleatório determinístico entre 0 e 1.
 * Usado em efeitos decorativos para que servidor e navegador gerem o mesmo HTML.
 */
export function aleatorio(semente: number): number {
  const x = Math.sin(semente * 12.9898) * 43758.5453;
  return x - Math.floor(x);
}
