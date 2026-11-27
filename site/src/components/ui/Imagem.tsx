import Image from "next/image";
import { img } from "@/lib/assets";

interface Props {
  arquivo: string;
  alt: string;
  largura: number;
  altura: number;
  className?: string;
  prioridade?: boolean;
}

/** Imagem de /public/img com dimensões declaradas (sem salto de layout). */
export function Imagem({ arquivo, alt, largura, altura, className, prioridade }: Props) {
  return (
    <Image
      src={img(arquivo)}
      alt={alt}
      width={largura}
      height={altura}
      className={className}
      priority={prioridade}
    />
  );
}
