import type { ReactNode } from "react";
import { Revelar } from "./Revelar";
import estilos from "./Eyebrow.module.css";

/** Texto pequeno e espaçado que antecede um título. */
export function Eyebrow({ children }: { children: ReactNode }) {
  return (
    <Revelar como="p" className={estilos.eyebrow}>
      {children}
    </Revelar>
  );
}
