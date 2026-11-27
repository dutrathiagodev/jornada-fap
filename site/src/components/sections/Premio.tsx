import { Confete } from "@/components/effects/Confete";
import { Eyebrow } from "@/components/ui/Eyebrow";
import { Imagem } from "@/components/ui/Imagem";
import { Revelar } from "@/components/ui/Revelar";
import { Titulo } from "@/components/ui/Titulo";
import estilos from "./Premio.module.css";

export function Premio() {
  return (
    <section id="premio" className={estilos.premio}>
      <Confete />
      <div className={estilos.conteudo}>
        <Eyebrow>No fim da jornada</Eyebrow>
        <Titulo linhas={["Um cupom", "só seu"]} centralizado />
        <Revelar como="p" atraso={1} className={estilos.lead}>
          Terminou as cinco cidades? Digite seu nome e o jogo gera o seu código de desconto para apresentar na FAP. Quanto mais
          estrelas, maior a faixa de desconto.
        </Revelar>
        <Revelar atraso={2} className={estilos.cupom}>
          <Imagem arquivo="telas/cupom.webp" alt="Tela do cupom de desconto" largura={1280} altura={720} />
        </Revelar>
        <p className={estilos.aviso}>Faixas e regras do desconto serão confirmadas pela secretaria da FAP.</p>
      </div>
    </section>
  );
}
