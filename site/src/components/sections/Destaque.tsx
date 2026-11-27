import type { Destaque as DestaqueModelo } from "@/domain/destaque";
import { Eyebrow } from "@/components/ui/Eyebrow";
import { Imagem } from "@/components/ui/Imagem";
import { Ornamento } from "@/components/ui/Ornamento";
import { Revelar } from "@/components/ui/Revelar";
import { Titulo } from "@/components/ui/Titulo";
import { classes } from "@/lib/classes";
import estilos from "./Destaque.module.css";

const TAMANHO_OBJETO: Record<DestaqueModelo["objeto"], [number, number]> = {
  preguica: [260, 251],
  coracao: [200, 182],
  bloco: [143, 139],
  porta: [317, 396],
};

/** Bloco com uma tela do jogo de um lado e texto do outro; alterna o lado por `invertido`. */
export function Destaque({ dados }: { dados: DestaqueModelo }) {
  const [largura, altura] = TAMANHO_OBJETO[dados.objeto];

  return (
    <section id={dados.secaoId} className={classes(estilos.destaque, dados.invertido && estilos.invertido)}>
      <Revelar className={estilos.tela}>
        <div className={estilos.moldura}>
          <Imagem arquivo={dados.imagem} alt={dados.legenda} largura={1280} altura={720} className={estilos.foto} />
        </div>
        <Imagem
          arquivo={`objetos/${dados.objeto}.webp`}
          alt=""
          largura={largura}
          altura={altura}
          className={estilos.objeto}
        />
      </Revelar>

      <div className={estilos.texto}>
        <Eyebrow>{dados.eyebrow}</Eyebrow>
        <Titulo linhas={dados.tituloLinhas} tamanho="medio" />
        <Ornamento alinhar="inicio" />
        <Revelar como="blockquote" atraso={1} className={estilos.citacao}>
          “{dados.citacao}”
        </Revelar>
        <Revelar como="p" atraso={2} className={estilos.paragrafo}>
          {dados.texto}
        </Revelar>
        <ul className={estilos.itens}>
          {dados.itens.map((item, i) => (
            <Revelar como="li" key={item} atraso={3 + i}>
              {item}
            </Revelar>
          ))}
        </ul>
      </div>
    </section>
  );
}
