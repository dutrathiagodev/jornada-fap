"use client";

import { useEffect, useState } from "react";

/** Devolve o id da seção que ocupa o centro da tela. */
export function useSecaoAtiva(ids: readonly string[]): string {
  const [ativa, setAtiva] = useState(ids[0]);

  useEffect(() => {
    const observador = new IntersectionObserver(
      (entradas) => {
        for (const entrada of entradas) {
          if (entrada.isIntersecting) setAtiva(entrada.target.id);
        }
      },
      { rootMargin: "-45% 0px -45% 0px" },
    );
    for (const id of ids) {
      const el = document.getElementById(id);
      if (el) observador.observe(el);
    }
    return () => observador.disconnect();
  }, [ids]);

  return ativa;
}
