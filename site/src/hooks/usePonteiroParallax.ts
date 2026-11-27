"use client";

import { type RefObject, useEffect } from "react";

/** Escreve --mx e --my (de -1 a 1) conforme o mouse se move sobre o elemento. */
export function usePonteiroParallax(ref: RefObject<HTMLElement | null>): void {
  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const aoMover = (e: PointerEvent) => {
      el.style.setProperty("--mx", ((e.clientX / window.innerWidth) * 2 - 1).toFixed(3));
      el.style.setProperty("--my", ((e.clientY / window.innerHeight) * 2 - 1).toFixed(3));
    };

    el.addEventListener("pointermove", aoMover);
    return () => el.removeEventListener("pointermove", aoMover);
  }, [ref]);
}
