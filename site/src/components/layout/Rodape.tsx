import { SITE } from "@/content/site";
import { img } from "@/lib/assets";
import estilos from "./Rodape.module.css";

export function Rodape() {
  return (
    <footer className={estilos.rodape}>
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img className={estilos.logo} src={img("logos/fap_branco.svg")} alt="FAP" />
      <p className={estilos.legal}>
        © {SITE.ano} {SITE.instituicao}. Projeto acadêmico feito com Godot, com arte gerada por IA. Logos usados sujeitos à
        autorização da instituição. O símbolo da rede adventista é marca de seus respectivos titulares.
      </p>
    </footer>
  );
}
