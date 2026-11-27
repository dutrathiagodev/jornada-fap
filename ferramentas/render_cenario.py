"""Renderiza o cenario cartoon de Curitiba (arte/cenario_curitiba.html) em camadas.
Uso: python3 render_cenario.py <pasta_saida> <pasta_personagens>
Gera: ceu.png serra.png morros.png jardim.png chao.png jogo.png (1920x1080, transparentes),
      previa.png (tudo junto + personagens) e previa_parallax.gif (camadas rolando).
"""
import os
import subprocess
import sys
from PIL import Image

AQUI = os.path.dirname(os.path.abspath(__file__))
HTML = os.path.abspath(os.path.join(AQUI, "..", "arte", "cenario_curitiba.html"))
CAMADAS = ["ceu", "serra", "morros", "jardim", "chao", "jogo"]
VEL = {"ceu": 0.0, "serra": 0.08, "morros": 0.25, "jardim": 0.5, "chao": 1.0, "jogo": 1.0}
CHAO_Y = 905  # altura da grama na camada chao


def render(layer, out):
    subprocess.run(["google-chrome", "--headless=new", "--disable-gpu", "--hide-scrollbars",
                    "--force-device-scale-factor=1", "--default-background-color=00000000",
                    "--window-size=1920,1080", f"--screenshot={out}", f"file://{HTML}?layer={layer}"],
                   check=True, capture_output=True, timeout=90)


def rolar(im, dx):
    dx = int(dx) % im.width
    if dx == 0:
        return im
    out = Image.new("RGBA", im.size)
    out.paste(im.crop((dx, 0, im.width, im.height)), (0, 0))
    out.paste(im.crop((0, 0, dx, im.height)), (im.width - dx, 0))
    return out


def main(saida, pers):
    os.makedirs(saida, exist_ok=True)
    L = {}
    for c in CAMADAS:
        p = os.path.join(saida, f"{c}.png")
        render(c, p)
        L[c] = Image.open(p).convert("RGBA")
    menino = Image.open(os.path.join(pers, "menino_sheet.png")).convert("RGBA")
    menina = Image.open(os.path.join(pers, "menina_sheet.png")).convert("RGBA")
    fr = lambda s, r, i: s.crop((i * 256, r * 256, i * 256 + 256, r * 256 + 256))
    pe = 244  # linha do chao dentro do quadro do personagem

    # previa estatica
    im = Image.new("RGBA", (1920, 1080))
    for c in CAMADAS:
        im.alpha_composite(L[c])
    im.alpha_composite(fr(menino, 1, 2), (300, CHAO_Y + 4 - pe))
    im.alpha_composite(fr(menina, 0, 0), (1140, 640 + 2 - pe))
    im.convert("RGB").save(os.path.join(saida, "previa.png"))

    # GIF com parallax: os dois correndo, camadas rolando em velocidades diferentes
    quadros = []
    for f in range(32):
        q = Image.new("RGBA", (1920, 1080))
        for c in CAMADAS:
            q.alpha_composite(rolar(L[c], f * 44 * VEL[c]))
        q.alpha_composite(fr(menina, 1, (f + 3) % 8), (220, CHAO_Y + 4 - pe))
        q.alpha_composite(fr(menino, 1, f % 8), (470, CHAO_Y + 4 - pe))
        quadros.append(q.convert("RGB").resize((960, 540), Image.LANCZOS))
    quadros[0].save(os.path.join(saida, "previa_parallax.gif"), save_all=True,
                    append_images=quadros[1:], duration=70, loop=0, optimize=True)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
