"use client";

import { SECOES } from "@/content/secoes";
import { useSecaoAtiva } from "@/hooks/useSecaoAtiva";
import estilos from "./NavLateral.module.css";

const IDS = SECOES.map((s) => s.id);

/** Losangos fixos na lateral: mostram e permitem trocar a seção atual. */
export function NavLateral() {
  const ativa = useSecaoAtiva(IDS);

  return (
    <nav className={estilos.nav} aria-label="Seções da página">
      {SECOES.map((secao) => (
        <a
          key={secao.id}
          href={`#${secao.id}`}
          className={estilos.ponto}
          aria-current={ativa === secao.id ? "true" : undefined}
          aria-label={secao.rotulo}
        >
          <span className={estilos.rotulo}>{secao.rotulo}</span>
        </a>
      ))}
    </nav>
  );
}
