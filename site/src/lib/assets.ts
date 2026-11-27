const BASE = process.env.NEXT_PUBLIC_BASE_PATH ?? "";

/** Caminho público de uma imagem em /public/img (respeita o basePath). */
export function img(caminho: string): string {
  return `${BASE}/img/${caminho}`;
}
