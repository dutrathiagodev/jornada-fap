"use client";

import { useEffect, useRef } from "react";
import type { TelaGaleria } from "@/domain/tela-galeria";
import { Icone } from "@/components/ui/Icone";
import { img } from "@/lib/assets";
import estilos from "./Lightbox.module.css";

interface Props {
  telas: readonly TelaGaleria[];
  /** Posição da tela aberta, ou `null` com o visualizador fechado. */
  indice: number | null;
  aoMudar: (indice: number | null) => void;
}

/** Visualizador de tela cheia baseado em <dialog>: Esc fecha, setas navegam. */
export function Lightbox({ telas, indice, aoMudar }: Props) {
  const dialogo = useRef<HTMLDialogElement>(null);
  const aberto = indice !== null;

  useEffect(() => {
    const el = dialogo.current;
    if (!el) return;
    if (aberto && !el.open) el.showModal();
    if (!aberto && el.open) el.close();
  }, [aberto]);

  useEffect(() => {
    if (indice === null) return;
    const aoTeclar = (e: KeyboardEvent) => {
      if (e.key === "ArrowRight") aoMudar((indice + 1) % telas.length);
      if (e.key === "ArrowLeft") aoMudar((indice - 1 + telas.length) % telas.length);
    };
    window.addEventListener("keydown", aoTeclar);
    return () => window.removeEventListener("keydown", aoTeclar);
  }, [indice, telas.length, aoMudar]);

  const tela = indice === null ? null : telas[indice];

  return (
    <dialog
      ref={dialogo}
      className={estilos.dialogo}
      aria-label="Tela do jogo ampliada"
      onClose={() => aoMudar(null)}
      onClick={(e) => e.target === e.currentTarget && aoMudar(null)}
    >
      {tela && (
        <figure className={estilos.figura}>
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img className={estilos.imagem} src={img(tela.arquivo)} alt={tela.legenda} />
          <figcaption className={estilos.legenda}>{tela.legenda}</figcaption>
        </figure>
      )}
      <button type="button" className={estilos.fechar} onClick={() => aoMudar(null)} aria-label="Fechar">
        <Icone nome="fechar" tamanho={20} />
      </button>
      {indice !== null && (
        <>
          <button
            type="button"
            className={`${estilos.seta} ${estilos.anterior}`}
            onClick={() => aoMudar((indice - 1 + telas.length) % telas.length)}
            aria-label="Tela anterior"
          >
            <Icone nome="seta-esquerda" tamanho={22} />
          </button>
          <button
            type="button"
            className={`${estilos.seta} ${estilos.proxima}`}
            onClick={() => aoMudar((indice + 1) % telas.length)}
            aria-label="Próxima tela"
          >
            <Icone nome="seta-direita" tamanho={22} />
          </button>
        </>
      )}
    </dialog>
  );
}
