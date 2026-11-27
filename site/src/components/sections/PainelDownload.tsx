"use client";

import { Botao } from "@/components/ui/Botao";
import { PLATAFORMAS, URL_JOGO_WEB, URL_RELEASES, urlDownload } from "@/content/downloads";
import type { Plataforma } from "@/domain/plataforma";
import { usePlataforma } from "@/hooks/usePlataforma";
import estilos from "./PainelDownload.module.css";

/** Botão principal conforme o sistema de quem visita, mais as outras opções. */
export function PainelDownload() {
  const sistema = usePlataforma();
  const ehMovel = sistema === "movel";
  const recomendada = PLATAFORMAS.find((p) => p.id === sistema);

  return (
    <div className={estilos.painel}>
      <div className={estilos.principal}>
        {recomendada ? <BotaoBaixar plataforma={recomendada} /> : null}
        <Botao variante={recomendada ? "moldura" : "ouro"} href={URL_JOGO_WEB} icone={ehMovel ? "celular" : "play"}>
          {ehMovel ? "Jogar no celular" : "Jogar no navegador"}
        </Botao>
      </div>

      {recomendada && <p className={estilos.instrucao}>{recomendada.instrucao}</p>}
      {ehMovel && (
        <p className={estilos.instrucao}>
          No celular o jogo abre direto no navegador, com botões na tela para andar, pular e correr. Gire o aparelho para a horizontal.
        </p>
      )}

      <ul className={estilos.outras} aria-label="Baixar para outros sistemas">
        {PLATAFORMAS.filter((p) => p.id !== recomendada?.id).map((p) => (
          <li key={p.id}>
            <a href={urlDownload(p.arquivo)}>
              {p.nome} <span>{p.tamanho}</span>
            </a>
          </li>
        ))}
        <li>
          <a href={URL_RELEASES}>Todas as versões</a>
        </li>
      </ul>
    </div>
  );
}

function BotaoBaixar({ plataforma }: { plataforma: Plataforma }) {
  return (
    <Botao variante="ouro" href={urlDownload(plataforma.arquivo)} icone="baixar">
      Baixar para {plataforma.nome}
    </Botao>
  );
}
