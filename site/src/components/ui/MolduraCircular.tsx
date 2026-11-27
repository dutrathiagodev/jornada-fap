import { Imagem } from "./Imagem";
import estilos from "./MolduraCircular.module.css";

interface Props {
  arquivo: string;
  alt: string;
}

/** Imagem dentro de anéis dourados que giram devagar, no estilo de astrolábio. */
export function MolduraCircular({ arquivo, alt }: Props) {
  return (
    <div className={estilos.moldura}>
      <svg className={estilos.aneis} viewBox="0 0 200 200" aria-hidden="true">
        <circle className={estilos.anelExterno} cx="100" cy="100" r="98" />
        <circle className={estilos.anelPontilhado} cx="100" cy="100" r="92" />
        <path className={estilos.arco} d="M100 4 A96 96 0 0 1 196 100" />
        <path className={estilos.arco} d="M100 196 A96 96 0 0 1 4 100" />
      </svg>
      <div className={estilos.disco}>
        <Imagem arquivo={arquivo} alt={alt} largura={1280} altura={720} className={estilos.foto} />
      </div>
    </div>
  );
}
