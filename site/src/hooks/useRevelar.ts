"use client";

import { type RefObject, useEffect, useState } from "react";

/** Fica `true` (uma única vez) quando o elemento entra na tela. */
export function useRevelar(ref: RefObject<Element | null>, limiar = 0.2): boolean {
  const [visivel, setVisivel] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const observador = new IntersectionObserver(
      ([entrada]) => {
        if (!entrada.isIntersecting) return;
        setVisivel(true);
        observador.disconnect();
      },
      { threshold: limiar },
    );
    observador.observe(el);
    return () => observador.disconnect();
  }, [ref, limiar]);

  return visivel;
}
