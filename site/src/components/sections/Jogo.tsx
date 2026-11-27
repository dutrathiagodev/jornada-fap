import { Botao } from "@/components/ui/Botao";
import { Eyebrow } from "@/components/ui/Eyebrow";
import { MolduraCircular } from "@/components/ui/MolduraCircular";
import { Ornamento } from "@/components/ui/Ornamento";
import { Revelar } from "@/components/ui/Revelar";
import { Titulo } from "@/components/ui/Titulo";
import { Icone } from "@/components/ui/Icone";
import { FATOS } from "@/content/fatos";
import estilos from "./Jogo.module.css";

export function Jogo() {
  return (
    <section id="jogo" className={estilos.jogo}>
      <Revelar className={estilos.moldura}>
        <MolduraCircular arquivo="telas/curitiba.webp" alt="Curitiba, a primeira cidade da jornada" />
      </Revelar>

      <div className={estilos.texto}>
        <Eyebrow>Bem-vindo à jornada</Eyebrow>
        <Titulo linhas={["Estudar nunca foi", "tão divertido"]} />
        <Ornamento alinhar="inicio" />
        <Revelar como="p" atraso={1} className={estilos.lead}>
          Jornada FAP é um jogo de plataforma gratuito, no estilo dos clássicos que você já conhece. Um menino e uma menina de
          uniforme atravessam cinco cidades do Sul e do Sudeste do Brasil, pulando obstáculos, juntando moedas com o símbolo
          da rede adventista e resolvendo desafios de estudo e de Bíblia pelo caminho. No fim, quem chega lá ganha um cupom
          de desconto da FAP.
        </Revelar>

        <ul className={estilos.fatos}>
          {FATOS.map((fato, i) => (
            <Revelar como="li" key={fato.rotulo} atraso={i + 2} className={estilos.fato}>
              <Icone nome={fato.icone} tamanho={22} />
              <strong>{fato.valor}</strong>
              <span>{fato.rotulo}</span>
            </Revelar>
          ))}
        </ul>

        <Revelar atraso={6}>
          <Botao href="#galeria" icone="ampliar">Ver telas do jogo</Botao>
        </Revelar>
      </div>
    </section>
  );
}
