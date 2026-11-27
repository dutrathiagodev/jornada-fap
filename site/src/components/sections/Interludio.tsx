import { Revelar } from "@/components/ui/Revelar";
import estilos from "./Interludio.module.css";

interface Props {
  frase: string;
  /** Palavras (por posição) destacadas em ouro. */
  destaques?: readonly number[];
}

/** Respiro entre seções: uma frase grande cujas palavras surgem uma a uma. */
export function Interludio({ frase, destaques = [] }: Props) {
  return (
    <Revelar efeito={false} como="section" className={estilos.interludio}>
      <p className={estilos.frase}>
        {frase.split(" ").map((palavra, i) => (
          <span
            key={i}
            className={estilos.palavra}
            data-ouro={destaques.includes(i)}
            style={{ transitionDelay: `${i * 90}ms` }}
          >
            {palavra}
          </span>
        ))}
      </p>
    </Revelar>
  );
}
