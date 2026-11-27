"use client";

import { useEffect, useState } from "react";
import type { SistemaDetectado } from "@/domain/plataforma";

/** Lê o navegador e descobre o sistema. Função pura, fácil de testar. */
export function detectarSistema(userAgent: string, pontosDeToque: number): SistemaDetectado {
  if (/android|iphone|ipad|ipod/i.test(userAgent)) return "movel";
  // iPad moderno se identifica como Mac, mas tem tela de toque
  if (/Macintosh/.test(userAgent) && pontosDeToque > 1) return "movel";
  if (/Windows/i.test(userAgent)) return "windows";
  if (/Macintosh|Mac OS X/i.test(userAgent)) return "macos";
  if (/Linux|X11|CrOS/i.test(userAgent)) return "linux";
  return "desconhecido";
}

/** `null` até o navegador carregar (evita diferença entre o HTML do servidor e o do cliente). */
export function usePlataforma(): SistemaDetectado | null {
  const [sistema, setSistema] = useState<SistemaDetectado | null>(null);

  useEffect(() => {
    setSistema(detectarSistema(navigator.userAgent, navigator.maxTouchPoints));
  }, []);

  return sistema;
}
