"use client";

import { useRef } from "react";
import { FaixaChamada } from "@/components/layout/FaixaChamada";
import { Botao } from "@/components/ui/Botao";
import { Moedas } from "@/components/effects/Moedas";
import { Menino } from "@/components/effects/Menino";
import { usePonteiroParallax } from "@/hooks/usePonteiroParallax";
import { useProgressoRolagem } from "@/hooks/useProgressoRolagem";
import { SITE } from "@/content/site";
import { img } from "@/lib/assets";
import estilos from "./Hero.module.css";

/** Camadas do cenário de Curitiba. `fator` é o quanto cada uma se desloca ao rolar. */
const CAMADAS = [
  { arquivo: "parallax/curitiba_fundo.webp", fator: 0.25 },
  { arquivo: "parallax/curitiba_meio.webp", fator: 0.6 },
  { arquivo: "parallax/curitiba_frente.webp", fator: 1 },
] as const;

/**
 * Herói cinematográfico: o cenário fica fixo na tela enquanto a pessoa rola,
 * as camadas deslizam em velocidades diferentes e o menino corre pelo cenário.
 */
export function Hero() {
  const ref = useRef<HTMLElement>(null);
  useProgressoRolagem(ref);
  usePonteiroParallax(ref);

  return (
    <section id="inicio" ref={ref} className={estilos.hero}>
      <div className={estilos.palco}>
        {CAMADAS.map((camada) => (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            key={camada.arquivo}
            className={estilos.camada}
            style={{ "--f": camada.fator } as React.CSSProperties}
            src={img(camada.arquivo)}
            alt=""
            fetchPriority="high"
          />
        ))}
        <Menino />
        <div className={estilos.veu} />
        <Moedas />

        <div className={estilos.texto}>
          <p className={estilos.apresenta}>{SITE.instituicao} apresenta</p>
          <h1 className={estilos.nome}>
            Jornada
            <br />
            FAP
          </h1>
          <p className={estilos.slogan}>{SITE.slogan}</p>
          <div className={estilos.acoes}>
            <Botao variante="ouro" href="#jogar" icone="play">
              Quero jogar
            </Botao>
            <Botao href="#jogo">Conhecer o jogo</Botao>
          </div>
        </div>

        <p className={estilos.rolar}>Role para correr</p>
        <FaixaChamada />
      </div>
    </section>
  );
}
