import { img } from "@/lib/assets";
import estilos from "./Menino.module.css";

/** Menino da FAP em sprite: corre enquanto a página rola e fica parado quando ela para. */
export function Menino() {
  const sprites = {
    "--sprite-parado": `url(${img("sprites/menino_parado.webp")})`,
    "--sprite-correr": `url(${img("sprites/menino_correr.webp")})`,
  } as React.CSSProperties;

  return (
    <div className={estilos.menino} style={sprites} aria-hidden="true">
      <div className={estilos.sprite} />
    </div>
  );
}
