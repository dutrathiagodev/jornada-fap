"""Recorta as pecas de um kit de partes (imagem com fundo branco) em PNGs transparentes.
Uso: python3 recortar_partes.py <imagem.jpeg> <pasta_saida>
Salva parte_00.png, parte_01.png ... (ordenadas de cima p/ baixo, esquerda p/ direita)
e imprime o retangulo de cada peca.
"""
import os
import sys
from PIL import Image, ImageDraw, ImageFilter

ESC = 4  # reducao para achar as pecas


def achar_pecas(im):
    peq = im.convert("L").resize((im.width // ESC, im.height // ESC))
    m = peq.point(lambda v: 255 if v < 228 else 0).filter(ImageFilter.MaxFilter(7))
    caixas, k = [], 1
    px = m.load()
    for y in range(m.height):
        for x in range(m.width):
            if px[x, y] == 255:
                ImageDraw.floodfill(m, (x, y), k)
                bb = m.point(lambda v, k=k: 255 if v == k else 0).getbbox()
                if bb and (bb[2] - bb[0]) * (bb[3] - bb[1]) > 60:
                    caixas.append(tuple(v * ESC for v in bb))
                k += 1
                if k >= 255:
                    raise SystemExit("pecas demais")
    return caixas


def recortar(im, bb, margem=12):
    x0, y0, x1, y1 = bb
    x0, y0 = max(0, x0 - margem), max(0, y0 - margem)
    x1, y1 = min(im.width, x1 + margem), min(im.height, y1 + margem)
    c = im.crop((x0, y0, x1, y1)).convert("RGB")
    # fundo = tudo que e quase branco e esta ligado a borda
    marca = (255, 0, 255)
    larg, alt = c.size
    for p in [(0, 0), (larg - 1, 0), (0, alt - 1), (larg - 1, alt - 1)]:
        if c.getpixel(p) != marca:
            ImageDraw.floodfill(c, p, marca, thresh=40)
    a = Image.new("L", c.size, 255)
    ap, cp = a.load(), c.load()
    for y in range(alt):
        for x in range(larg):
            if cp[x, y] == marca:
                ap[x, y] = 0
    a = a.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(0.7))
    orig = im.crop((x0, y0, x1, y1)).convert("RGBA")
    orig.putalpha(a)
    return orig.crop(orig.getbbox()), (x0, y0, x1, y1)


def main(arq, saida):
    os.makedirs(saida, exist_ok=True)
    im = Image.open(arq)
    caixas = achar_pecas(im)
    # ordena por linha (faixas de 300px) e depois por x
    caixas.sort(key=lambda b: (b[1] // 300, b[0]))
    for i, bb in enumerate(caixas):
        p, r = recortar(im, bb)
        p.save(os.path.join(saida, f"parte_{i:02d}.png"))
        print(i, r, p.size)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
