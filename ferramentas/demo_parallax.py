"""GIF de demonstracao do parallax: 3 camadas rolando em velocidades diferentes + personagens correndo.
Uso: python3 demo_parallax.py <pasta_camadas> <menino_sheet> <menina_sheet> <chao_y_1080> <saida.gif>
"""
import math
import sys
from PIL import Image

Q = 384
VEL = {"1_fundo": 0.12, "2_meio": 0.4, "3_frente": 1.0}


def rolar(im, dx):
    dx = int(dx) % im.width
    out = Image.new("RGBA", im.size)
    out.paste(im.crop((dx, 0, im.width, im.height)), (0, 0))
    out.paste(im.crop((0, 0, dx, im.height)), (im.width - dx, 0))
    return out


def main(pasta, sm, sf, chao_y, saida):
    chao = int(int(chao_y) / 2)
    L = {}
    for n in VEL:
        im = Image.open(f"{pasta}/{n}.png").convert("RGBA")
        L[n] = im.resize((im.width // 2, 540), Image.LANCZOS)
    folhas = [Image.open(sm).convert("RGBA"), Image.open(sf).convert("RGBA")]
    e = 0.56
    t = int(Q * e)

    def q(f, r, i):
        return folhas[f].crop((i * Q, r * Q, i * Q + Q, r * Q + Q)).resize((t, t), Image.LANCZOS)

    quadros = []
    N = 40
    for f in range(N):
        im = Image.new("RGBA", (960, 540))
        for n, v in VEL.items():
            camada = rolar(L[n], f * 14 * v)
            while camada.width < 960:  # repete se a camada for mais estreita que a tela
                dupla = Image.new("RGBA", (camada.width * 2, 540))
                dupla.paste(camada, (0, 0)); dupla.paste(camada, (camada.width, 0))
                camada = dupla
            im.alpha_composite(camada.crop((0, 0, 960, 540)))
        base = chao - int(372 * e) + 6
        # menina sempre correndo
        im.alpha_composite(q(1, 1, (f + 3) % 8), (230, base))
        # menino corre e pula no meio
        if 24 <= f < 36:
            k = f - 24
            linha, quadro = (2, min(1, k // 3)) if k < 6 else (3, min(1, (k - 6) // 3))
            dy = -int(130 * math.sin(math.pi * (k + 1) / 13))
            im.alpha_composite(q(0, linha, quadro), (420, base + dy))
        else:
            im.alpha_composite(q(0, 1, f % 8), (420, base))
        quadros.append(im.convert("RGB"))
    quadros[0].save(saida, save_all=True, append_images=quadros[1:], duration=60, loop=0, optimize=True)


if __name__ == "__main__":
    main(*sys.argv[1:])
