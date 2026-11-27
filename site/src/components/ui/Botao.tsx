import type { ComponentProps, ReactNode } from "react";
import { classes } from "@/lib/classes";
import { Icone } from "./Icone";
import estilos from "./Botao.module.css";

type Variante = "ouro" | "moldura";

interface Props {
  children: ReactNode;
  variante?: Variante;
  href?: string;
  desativado?: boolean;
  icone?: ComponentProps<typeof Icone>["nome"];
}

/** Botão de placa com cantos chanfrados e filete duplo. "ouro" é o principal. */
export function Botao({ children, variante = "moldura", href, desativado, icone }: Props) {
  const nome = classes(estilos.botao, estilos[variante]);
  const conteudo = (
    <span className={estilos.conteudo}>
      {icone && <Icone nome={icone} tamanho={16} />}
      {children}
    </span>
  );

  if (desativado || !href) {
    return (
      <span className={nome} aria-disabled="true">
        {conteudo}
      </span>
    );
  }
  return (
    <a className={nome} href={href}>
      {conteudo}
    </a>
  );
}
