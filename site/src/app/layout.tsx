import type { Metadata, Viewport } from "next";
import { Cinzel, Nunito_Sans } from "next/font/google";
import localFont from "next/font/local";
import { SITE } from "@/content/site";
import "./globals.css";

const titulo = Cinzel({ subsets: ["latin"], weight: ["500", "700"], variable: "--font-cinzel" });
const texto = Nunito_Sans({ subsets: ["latin"], variable: "--font-nunito" });
const jogo = localFont({ src: "../../public/fonte/LilitaOne.ttf", variable: "--font-lilita", display: "swap" });

export const metadata: Metadata = {
  title: `${SITE.nome} — ${SITE.slogan}`,
  description: SITE.descricao,
  openGraph: { title: SITE.nome, description: SITE.descricao, type: "website", locale: "pt_BR" },
};

export const viewport: Viewport = { themeColor: "#080b11" };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR" className={`${titulo.variable} ${texto.variable} ${jogo.variable}`}>
      <body>{children}</body>
    </html>
  );
}
