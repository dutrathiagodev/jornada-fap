import { aleatorio } from "@/lib/aleatorio";
import { img } from "@/lib/assets";
import estilos from "./Moedas.module.css";

const QUANTIDADE = 9;

/** Moedas giratórias que flutuam ao fundo (sprite de 32 quadros do jogo). */
export function Moedas() {
  return (
    <div
      className={estilos.moedas}
      aria-hidden="true"
      style={{ "--sprite": `url(${img("objetos/moeda_giro.webp")})` } as React.CSSProperties}
    >
      {Array.from({ length: QUANTIDADE }, (_, i) => (
        <i
          key={i}
          className={estilos.moeda}
          style={{
            left: `${6 + i * 10.5 + aleatorio(i) * 4}%`,
            top: `${14 + aleatorio(i + 40) * 44}%`,
            animationDelay: `${-aleatorio(i + 7) * 3}s, ${-aleatorio(i + 19) * 4}s`,
          }}
        />
      ))}
    </div>
  );
}
