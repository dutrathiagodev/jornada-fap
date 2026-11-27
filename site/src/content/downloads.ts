import type { Plataforma } from "@/domain/plataforma";

const REPOSITORIO = "https://github.com/dutrathiagodev/jornada-fap";

export const URL_RELEASES = `${REPOSITORIO}/releases/latest`;

/** Versão jogável no navegador (celular e computador), publicada pelo GitHub Pages. */
export const URL_JOGO_WEB = "https://dutrathiagodev.github.io/jornada-fap/";

export const PLATAFORMAS: readonly Plataforma[] = [
  {
    id: "windows",
    nome: "Windows",
    arquivo: "JornadaFAP-windows-x64-setup.exe",
    tamanho: "71 MB",
    instrucao: "Dois cliques e siga o instalador. Cria o atalho na área de trabalho.",
  },
  {
    id: "macos",
    nome: "macOS",
    arquivo: "JornadaFAP-macos.pkg",
    tamanho: "103 MB",
    instrucao: "Dois cliques e siga o instalador. Instala em Aplicativos e cria o atalho.",
  },
  {
    id: "linux",
    nome: "Linux",
    arquivo: "JornadaFAP-linux-x64.tar.gz",
    tamanho: "72 MB",
    instrucao: "Extraia e rode ./instalar.sh. Cria o atalho na área de trabalho e no menu.",
  },
];

/** Link direto para o arquivo da última versão publicada. */
export function urlDownload(arquivo: string): string {
  return `${REPOSITORIO}/releases/latest/download/${arquivo}`;
}
