import { BarraTopo } from "@/components/layout/BarraTopo";
import { NavLateral } from "@/components/layout/NavLateral";
import { Rodape } from "@/components/layout/Rodape";
import { Cidades } from "@/components/sections/Cidades";
import { Destaque } from "@/components/sections/Destaque";
import { Galeria } from "@/components/sections/Galeria";
import { Hero } from "@/components/sections/Hero";
import { Interludio } from "@/components/sections/Interludio";
import { Jogar } from "@/components/sections/Jogar";
import { Jogo } from "@/components/sections/Jogo";
import { Premio } from "@/components/sections/Premio";
import { DESTAQUES } from "@/content/destaques";

export default function Pagina() {
  const [desafios, plataformas, ponte] = DESTAQUES;

  return (
    <>
      <BarraTopo />
      <NavLateral />
      <main>
        <Hero />
        <Jogo />
        <Interludio frase="Cinco cidades. Uma só jornada." destaques={[1, 2]} />
        <Cidades />
        <Destaque dados={desafios} />
        <Destaque dados={plataformas} />
        <Interludio frase="Aprender também é uma aventura" destaques={[3, 4]} />
        <Destaque dados={ponte} />
        <Premio />
        <Galeria />
        <Jogar />
      </main>
      <Rodape />
    </>
  );
}
