import { aleatorio } from "@/lib/aleatorio";
import estilos from "./Confete.module.css";

const CORES = ["#d8b56a", "#4dd2ff", "#ff7aa8", "#7cff9b", "#ffffff"];
const QUANTIDADE = 46;

export function Confete() {
  return (
    <div className={estilos.confete} aria-hidden="true">
      {Array.from({ length: QUANTIDADE }, (_, i) => (
        <i
          key={i}
          style={{
            left: `${aleatorio(i) * 100}%`,
            background: CORES[i % CORES.length],
            animationDuration: `${6 + aleatorio(i + 3) * 7}s`,
            animationDelay: `${-aleatorio(i + 11) * 10}s`,
          }}
        />
      ))}
    </div>
  );
}
