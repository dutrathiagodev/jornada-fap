"use client";

import { type ElementType, type ReactNode, useRef } from "react";
import { useRevelar } from "@/hooks/useRevelar";
import { classes } from "@/lib/classes";
import estilos from "./Revelar.module.css";

interface Props {
  children: ReactNode;
  como?: ElementType;
  /** Atraso em passos de 120 ms, para escalonar a entrada de vários elementos. */
  atraso?: number;
  /** `false` só marca `data-visivel`; o CSS de quem usa decide a animação. */
  efeito?: boolean;
  className?: string;
}

/** Faz o conteúdo surgir suavemente quando entra na tela. */
export function Revelar({ children, como: Tag = "div", atraso = 0, efeito = true, className }: Props) {
  const ref = useRef<HTMLElement>(null);
  const visivel = useRevelar(ref);

  return (
    <Tag
      ref={ref}
      data-visivel={visivel}
      className={classes(efeito && estilos.revelar, className)}
      style={atraso ? { transitionDelay: `${atraso * 120}ms` } : undefined}
    >
      {children}
    </Tag>
  );
}
