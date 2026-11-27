import { Eyebrow } from "@/components/ui/Eyebrow";
import { Revelar } from "@/components/ui/Revelar";
import { Titulo } from "@/components/ui/Titulo";
import { FAQ } from "@/content/faq";
import { img } from "@/lib/assets";
import { PainelDownload } from "./PainelDownload";
import estilos from "./Jogar.module.css";

export function Jogar() {
  return (
    <section id="jogar" className={estilos.jogar} style={{ "--fundo": `url(${img("telas/capa.webp")})` } as React.CSSProperties}>
      <div className={estilos.conteudo}>
        <Eyebrow>Pronto para a aventura?</Eyebrow>
        <Titulo linhas={["Sua jornada", "começa agora"]} centralizado />
        <Revelar como="p" atraso={1} className={estilos.lead}>
          Baixe para o seu computador ou jogue agora no navegador, inclusive no celular. É gratuito e o progresso fica salvo.
        </Revelar>
        <Revelar atraso={2}>
          <PainelDownload />
        </Revelar>

        <Revelar atraso={3} className={estilos.faq}>
          {FAQ.map((item) => (
            <details key={item.pergunta} className={estilos.item}>
              <summary>{item.pergunta}</summary>
              <p>{item.resposta}</p>
            </details>
          ))}
        </Revelar>
      </div>
    </section>
  );
}
