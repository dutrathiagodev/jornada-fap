"""Gera os sprites 32x32 do menino e da menina (uniforme Educacao Adventista).
Uso: python3 gerar_personagens.py <pasta_saida>
Frames: 0 parado, 1-4 andar, 5 pular, 6 comemorar.
"""
import sys, os
from PIL import Image

MARINHO = (0, 59, 113, 255)
CLARO = (126, 200, 232, 255)
BRANCO = (244, 246, 248, 255)
CONTORNO = (20, 30, 48, 255)
OLHO = (30, 24, 24, 255)
BOCA = (150, 60, 60, 255)

PERSONAGENS = {
    "menino": dict(pele=(222, 164, 120, 255), cabelo=(90, 58, 34, 255), menina=False),
    "menina": dict(pele=(240, 196, 160, 255), cabelo=(122, 78, 45, 255), menina=True),
}


def rect(im, x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if 0 <= x < 32 and 0 <= y < 32:
                im.putpixel((x, y), c)


def contorno(im):
    src = im.copy()
    for y in range(32):
        for x in range(32):
            if src.getpixel((x, y))[3] == 0:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < 32 and 0 <= ny < 32 and src.getpixel((nx, ny))[3] > 0:
                        im.putpixel((x, y), CONTORNO)
                        break


def frame(p, pose, n=0):
    im = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    pele, cab = p["pele"], p["cabelo"]
    dy = -1 if pose == "andar" and n in (1, 3) else 0  # balanco do corpo
    if pose == "pular":
        dy = -1

    # rabo de cavalo (atras da cabeca)
    if p["menina"]:
        rect(im, 21, 6 + dy, 24, 13 + dy, cab)
        rect(im, 22, 14 + dy, 23, 16 + dy, cab)

    # pernas e sapatos
    if pose in ("parado", "comemorar"):
        rect(im, 11, 24, 15, 28, MARINHO); rect(im, 16, 24, 20, 28, MARINHO)
        rect(im, 10, 29, 15, 30, BRANCO); rect(im, 16, 29, 21, 30, BRANCO)
        rect(im, 10, 30, 15, 30, CLARO); rect(im, 16, 30, 21, 30, CLARO)
    elif pose == "andar":
        # n: 1 e 3 = passo aberto, 2 e 4 = cruzando
        a = [(0, 0), (-2, 2), (0, 0), (2, -2)][n - 1] if n in (1, 2, 3, 4) else (0, 0)
        a = {1: (-2, 2), 2: (0, 0), 3: (2, -2), 4: (0, 0)}[n]
        # perna esquerda
        lx = 11 + a[0]; rx = 16 + a[1]
        lh = 28 if a[0] >= 0 else 27
        rh = 28 if a[1] >= 0 else 27
        rect(im, lx, 24, lx + 4, lh, MARINHO); rect(im, rx, 24, rx + 4, rh, MARINHO)
        rect(im, lx - 1, lh + 1, lx + 4, lh + 2, BRANCO); rect(im, rx, rh + 1, rx + 5, rh + 2, BRANCO)
        rect(im, lx - 1, lh + 2, lx + 4, lh + 2, CLARO); rect(im, rx, rh + 2, rx + 5, rh + 2, CLARO)
    elif pose == "pular":
        rect(im, 10, 24 + dy, 14, 26 + dy, MARINHO); rect(im, 17, 24 + dy, 21, 26 + dy, MARINHO)
        rect(im, 8, 27 + dy, 13, 28 + dy, BRANCO); rect(im, 18, 27 + dy, 23, 28 + dy, BRANCO)
        rect(im, 8, 28 + dy, 13, 28 + dy, CLARO); rect(im, 18, 28 + dy, 23, 28 + dy, CLARO)

    # tronco: camisa branca com faixa lateral marinho
    rect(im, 11, 16 + dy, 20, 23 + dy, BRANCO)
    rect(im, 19, 17 + dy, 20, 23 + dy, MARINHO)          # faixa lateral
    rect(im, 11, 23 + dy, 20, 23 + dy, CLARO)            # barra
    rect(im, 14, 16 + dy, 17, 16 + dy, MARINHO)          # gola
    rect(im, 12, 18 + dy, 13, 19 + dy, MARINHO)          # logo "A"
    im.putpixel((12, 19 + dy), BRANCO)

    # bracos
    if pose in ("pular", "comemorar"):
        for x0 in (8, 22):
            rect(im, x0, 13 + dy, x0 + 1, 15 + dy, MARINHO)
            rect(im, x0, 10 + dy, x0 + 1, 12 + dy, pele)
    else:
        sw = {1: (1, -1), 2: (0, 0), 3: (-1, 1), 4: (0, 0)}.get(n, (0, 0)) if pose == "andar" else (0, 0)
        rect(im, 9, 16 + dy, 10, 19 + dy, MARINHO); rect(im, 9, 20 + dy + sw[0], 10, 22 + dy + sw[0], pele)
        rect(im, 21, 16 + dy, 22, 19 + dy, MARINHO); rect(im, 21, 20 + dy + sw[1], 22, 22 + dy + sw[1], pele)
        rect(im, 9, 19 + dy, 10, 19 + dy, CLARO); rect(im, 21, 19 + dy, 22, 19 + dy, CLARO)

    # cabeca
    rect(im, 9, 5 + dy, 22, 15 + dy, pele)
    rect(im, 8, 7 + dy, 23, 12 + dy, pele)
    # cabelo
    rect(im, 9, 3 + dy, 22, 6 + dy, cab)
    rect(im, 8, 5 + dy, 23, 8 + dy, cab)
    rect(im, 8, 9 + dy, 9, 11 + dy, cab); rect(im, 22, 9 + dy, 23, 11 + dy, cab)
    if p["menina"]:
        rect(im, 8, 9 + dy, 9, 14 + dy, cab)  # mechas laterais
    else:
        rect(im, 13, 7 + dy, 18, 7 + dy, pele); rect(im, 12, 7 + dy, 19, 7 + dy, cab)
    # rosto
    rect(im, 12, 10 + dy, 13, 11 + dy, OLHO); rect(im, 18, 10 + dy, 19, 11 + dy, OLHO)
    im.putpixel((12, 10 + dy), BRANCO); im.putpixel((18, 10 + dy), BRANCO)
    rect(im, 11, 13 + dy, 12, 13 + dy, (232, 140, 130, 255)); rect(im, 19, 13 + dy, 20, 13 + dy, (232, 140, 130, 255))
    if pose in ("comemorar", "pular"):
        rect(im, 14, 13 + dy, 17, 14 + dy, BOCA)
    else:
        rect(im, 14, 13 + dy, 17, 13 + dy, BOCA)
    contorno(im)
    return im


def main(saida):
    os.makedirs(saida, exist_ok=True)
    for nome, p in PERSONAGENS.items():
        frames = [frame(p, "parado")] + [frame(p, "andar", n) for n in (1, 2, 3, 4)] \
                 + [frame(p, "pular"), frame(p, "comemorar")]
        sheet = Image.new("RGBA", (32 * len(frames), 32), (0, 0, 0, 0))
        for i, f in enumerate(frames):
            sheet.paste(f, (32 * i, 0))
        sheet.save(os.path.join(saida, f"{nome}_sheet.png"))
        frames[0].save(os.path.join(saida, f"{nome}_parado.png"))
    # previa ampliada (8x, fundo azul-claro)
    prev = Image.new("RGBA", (32 * 7 * 5, 32 * 2 * 5), (190, 225, 242, 255))
    for r, nome in enumerate(PERSONAGENS):
        s = Image.open(os.path.join(saida, f"{nome}_sheet.png"))
        s = s.resize((s.width * 5, s.height * 5), Image.NEAREST)
        prev.paste(s, (0, r * 160), s)
    prev.save(os.path.join(saida, "previa.png"))

    # animacao GIF (8x): os dois lado a lado, parado -> andar -> pular -> comemorar
    esc = 8
    sheets = [Image.open(os.path.join(saida, f"{n}_sheet.png")) for n in PERSONAGENS]
    seq = [(0, 500)] + [(i, 130) for i in (1, 2, 3, 4) * 4] + [(5, 450), (6, 700)]
    quadros, tempos = [], []
    for idx, dur in seq:
        q = Image.new("RGBA", (80, 40), (190, 225, 242, 255))
        q.paste((92, 160, 76, 255), (0, 35, 80, 40))   # grama
        q.paste((120, 84, 52, 255), (0, 37, 80, 40))   # terra
        for k, s in enumerate(sheets):
            f = s.crop((32 * idx, 0, 32 * idx + 32, 32))
            q.paste(f, (4 + k * 40, 4), f)
        quadros.append(q.resize((80 * esc, 40 * esc), Image.NEAREST).convert("RGB"))
        tempos.append(dur)
    quadros[0].save(os.path.join(saida, "animacao.gif"), save_all=True,
                    append_images=quadros[1:], duration=tempos, loop=0)


if __name__ == "__main__":
    main(sys.argv[1])
