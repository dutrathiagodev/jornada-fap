"use client";

import { useState } from "react";
import { CIDADES } from "@/content/cidades";
import { Eyebrow } from "@/components/ui/Eyebrow";
import { Imagem } from "@/components/ui/Imagem";
import { Revelar } from "@/components/ui/Revelar";
import { Titulo } from "@/components/ui/Titulo";
import { classes } from "@/lib/classes";
import estilos from "./Cidades.module.css";

/** Cinco cartões que se expandem ao passar o mouse, focar com o teclado ou tocar. */
export function Cidades() {
  const [aberta, setAberta] = useState(0);

  return (
    <section id="cidades" className={estilos.cidades}>
      <Eyebrow>Uma viagem pelo Brasil</Eyebrow>
      <Titulo linhas={["Cinco cidades,", "cinco aventuras"]} />

      <Revelar atraso={1} className={estilos.lista}>
        {CIDADES.map((cidade, i) => (
          <button
            key={cidade.id}
            type="button"
            className={classes(estilos.cartao, i === aberta && estilos.aberto)}
            aria-expanded={i === aberta}
            onMouseEnter={() => setAberta(i)}
            onFocus={() => setAberta(i)}
            onClick={() => setAberta(i)}
          >
            <Imagem arquivo={cidade.imagem} alt="" largura={900} altura={251} className={estilos.foto} />
            <span className={estilos.info}>
              <span className={estilos.fase}>Fase {cidade.fase}</span>
              <span className={estilos.nome}>{cidade.nome}</span>
              <span className={estilos.detalhe}>
                <b>{cidade.materia}.</b> {cidade.descricao}
              </span>
            </span>
          </button>
        ))}
      </Revelar>
    </section>
  );
}
