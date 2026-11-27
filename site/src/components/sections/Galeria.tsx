"use client";

import { useState } from "react";
import { GALERIA } from "@/content/galeria";
import { Eyebrow } from "@/components/ui/Eyebrow";
import { Imagem } from "@/components/ui/Imagem";
import { Revelar } from "@/components/ui/Revelar";
import { Titulo } from "@/components/ui/Titulo";
import { Lightbox } from "./Lightbox";
import estilos from "./Galeria.module.css";

export function Galeria() {
  const [aberta, setAberta] = useState<number | null>(null);

  return (
    <section id="galeria" className={estilos.galeria}>
      <Eyebrow>Veja por dentro</Eyebrow>
      <Titulo linhas={["Telas do", "jogo"]} />

      <Revelar atraso={1} como="ul" className={estilos.grade}>
        {GALERIA.map((tela, i) => (
          <li key={tela.arquivo}>
            <button type="button" className={estilos.miniatura} onClick={() => setAberta(i)}>
              <Imagem arquivo={tela.arquivo} alt={tela.legenda} largura={1280} altura={720} className={estilos.foto} />
              <span className={estilos.legenda}>{tela.legenda}</span>
            </button>
          </li>
        ))}
      </Revelar>

      <Lightbox telas={GALERIA} indice={aberta} aoMudar={setAberta} />
    </section>
  );
}
