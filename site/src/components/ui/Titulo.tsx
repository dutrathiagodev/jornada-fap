import { Revelar } from "./Revelar";
import estilos from "./Titulo.module.css";

interface Props {
  linhas: readonly [string, string];
  /** Tamanho: "grande" para seções principais, "medio" para destaques. */
  tamanho?: "grande" | "medio";
  centralizado?: boolean;
}

/** Título de seção: primeira linha em creme, segunda em ouro e mais pesada. */
export function Titulo({ linhas, tamanho = "grande", centralizado }: Props) {
  return (
    <Revelar como="h2" className={estilos.titulo}>
      <span data-tamanho={tamanho} data-centro={centralizado}>
        {linhas[0]}
        <br />
        <strong>{linhas[1]}</strong>
      </span>
    </Revelar>
  );
}
