"use client";

import { useEffect, useState } from "react";
import { Botao } from "@/components/ui/Botao";
import { img } from "@/lib/assets";
import estilos from "./BarraTopo.module.css";

const LIMITE_ROLAGEM_PX = 60;

export function BarraTopo() {
  const [rolou, setRolou] = useState(false);

  useEffect(() => {
    const atualizar = () => setRolou(window.scrollY > LIMITE_ROLAGEM_PX);
    atualizar();
    window.addEventListener("scroll", atualizar, { passive: true });
    return () => window.removeEventListener("scroll", atualizar);
  }, []);

  return (
    <header className={estilos.barra} data-rolou={rolou}>
      <a href="#inicio" aria-label="Jornada FAP — início">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img className={estilos.logo} src={img("logos/fap_branco.svg")} alt="FAP — Faculdade Adventista do Paraná" />
      </a>
      <nav className={estilos.acoes} aria-label="Atalhos">
        <a className={estilos.link} href="#cidades">
          As cidades
        </a>
        <Botao href="#jogar">Quero jogar</Botao>
      </nav>
    </header>
  );
}
