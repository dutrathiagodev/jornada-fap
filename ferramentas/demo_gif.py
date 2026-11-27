"""Monta um GIF de demonstracao: menino e menina (folhas 384px) no cenario de Curitiba do Gemini.
Uso: python3 demo_gif.py <menino_sheet> <menina_sheet> <fundo.jpeg> <saida.gif>
"""
import math
import sys
from PIL import Image

Q = 384


def main(sm, sf, fundo, saida):
    folhas = [Image.open(sm).convert("RGBA"), Image.open(sf).convert("RGBA")]
    bg = Image.open(fundo).convert("RGBA")
    bg = bg.resize((960, int(bg.height * 960 / bg.width)), Image.LANCZOS)
    bg = bg.crop((0, bg.height - 540, 960, bg.height)) if bg.height > 540 else bg
    chao = int(540 * 0.885)          # topo da grama no cenario
    e = 0.42                         # escala dos personagens
    t = int(Q * e)

    def q(f, r, i):
        return folhas[f].crop((i * Q, r * Q, i * Q + Q, r * Q + Q)).resize((t, t), Image.LANCZOS)

    seq = []  # (linha, quadro, x_menino, y_extra, ms)
    for i in range(10):
        seq.append((0, i % 8, 120, 0, 110))
    for i in range(32):
        seq.append((1, i % 8, 120 + i * 13, 0, 70))
    x = 120 + 32 * 13
    arco = [(2, 0), (2, 1), (2, 1), (3, 0), (3, 1), (3, 1)]
    for k, (r, i) in enumerate(arco):
        seq.append((r, i, x + k * 14, -int(110 * math.sin(math.pi * (k + 1) / 7)), 90))
    x += len(arco) * 14
    for i in range(12):
        seq.append((4, i % 6, x, 0, 100))

    quadros, tempos = [], []
    for r, i, xm, dy, ms in seq:
        im = bg.copy()
        base = chao - int(372 * e)
        im.alpha_composite(q(1, r, (i + 2) % (8 if r < 2 else (2 if r < 4 else 6))), (xm - 120, base + dy))
        im.alpha_composite(q(0, r, i), (xm, base + dy))
        quadros.append(im.convert("RGB"))
        tempos.append(ms)
    quadros[0].save(saida, save_all=True, append_images=quadros[1:], duration=tempos, loop=0, optimize=True)


if __name__ == "__main__":
    main(*sys.argv[1:])
