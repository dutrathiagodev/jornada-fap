"use client";

import { type RefObject, useEffect } from "react";

const PAUSA_PARA_PARAR_MS = 140;

/**
 * Escreve no elemento o quanto da sua altura já foi percorrido pela rolagem:
 *  --p        progresso de 0 a 1
 *  --dir      1 (descendo) ou -1 (subindo)
 *  data-rolando="true" enquanto a pessoa está rolando
 * Não causa re-render: tudo é feito via CSS.
 */
export function useProgressoRolagem(ref: RefObject<HTMLElement | null>): void {
  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    let ultimoY = window.scrollY;
    let quadro = 0;
    let parar = 0;

    const atualizar = () => {
      quadro = 0;
      const topo = el.offsetTop;
      const percurso = el.offsetHeight - window.innerHeight;
      const p = percurso > 0 ? (window.scrollY - topo) / percurso : 0;
      el.style.setProperty("--p", Math.min(1, Math.max(0, p)).toFixed(4));
    };

    const aoRolar = () => {
      const y = window.scrollY;
      if (y !== ultimoY) el.style.setProperty("--dir", y > ultimoY ? "1" : "-1");
      ultimoY = y;
      el.dataset.rolando = "true";
      window.clearTimeout(parar);
      parar = window.setTimeout(() => (el.dataset.rolando = "false"), PAUSA_PARA_PARAR_MS);
      if (!quadro) quadro = requestAnimationFrame(atualizar);
    };

    atualizar();
    window.addEventListener("scroll", aoRolar, { passive: true });
    window.addEventListener("resize", atualizar);
    return () => {
      window.removeEventListener("scroll", aoRolar);
      window.removeEventListener("resize", atualizar);
      cancelAnimationFrame(quadro);
      window.clearTimeout(parar);
    };
  }, [ref]);
}
