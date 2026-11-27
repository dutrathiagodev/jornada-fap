import estilos from "./Ornamento.module.css";

/** Divisor com losango central, inspirado nos frisos dourados. */
export function Ornamento({ alinhar = "centro" }: { alinhar?: "centro" | "inicio" }) {
  return (
    <div className={estilos.ornamento} data-alinhar={alinhar} aria-hidden="true">
      <span className={estilos.linha} />
      <i className={estilos.losango} />
      <span className={estilos.linha} />
    </div>
  );
}
