import { Botao } from "@/components/ui/Botao";
import estilos from "./FaixaChamada.module.css";

/** Faixa inferior do herói, com friso dourado e chamada curta. */
export function FaixaChamada() {
  return (
    <div className={estilos.faixa}>
      <span className={estilos.topo} aria-hidden="true" />
      <p className={estilos.texto}>Jogo gratuito para toda a comunidade FAP</p>
      <Botao href="#cidades">Ver as 5 cidades</Botao>
    </div>
  );
}
