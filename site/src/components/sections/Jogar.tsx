import { Botao } from "@/components/ui/Botao";
import { Eyebrow } from "@/components/ui/Eyebrow";
import { Revelar } from "@/components/ui/Revelar";
import { Titulo } from "@/components/ui/Titulo";
import { FAQ } from "@/content/faq";
import { img } from "@/lib/assets";
import estilos from "./Jogar.module.css";

export function Jogar() {
  return (
    <section id="jogar" className={estilos.jogar} style={{ "--fundo": `url(${img("telas/capa.webp")})` } as React.CSSProperties}>
      <div className={estilos.conteudo}>
        <Eyebrow>Pronto para a aventura?</Eyebrow>
        <Titulo linhas={["Sua jornada", "começa agora"]} centralizado />
        <Revelar como="p" atraso={1} className={estilos.lead}>
          Em breve: jogue direto no navegador e no celular. Enquanto isso, a versão para computador está em testes com a equipe
          da FAP.
        </Revelar>
        <Revelar atraso={2} className={estilos.acoes}>
          <Botao variante="ouro" desativado icone="play">
            Jogar — em breve
          </Botao>
          <Botao href="#galeria">Rever as telas</Botao>
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
