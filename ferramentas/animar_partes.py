"""Anima um personagem a partir das pecas recortadas (arte gerada no Gemini) com esqueleto 2D.
Uso: python3 animar_partes.py <pasta_partes> <saida_sheet.png> [mapa]
mapa = indices das pecas: cabeca,tronco,braco_reto_a,braco_reto_b,braco_dobrado_a,braco_dobrado_b,perna_a,perna_b
       (padrao do kit do Gemini: 0,2,3,4,5,6,8,9)
Folha: quadros 384x384, linhas: 0 parado(8) 1 correr(8) 2 pular(2) 3 cair(2) 4 comemorar(6).
"""
import math
import sys
from PIL import Image, ImageChops, ImageDraw, ImageEnhance

QUADRO = 384
ESC = 0.33                 # escala final (pecas do Gemini sao grandes)
TELA = int(QUADRO / ESC)   # quadro em tamanho nativo
CHAO = int(372 / ESC)      # linha da sola dos pes


def centro_linha(im, y):
    a = im.getchannel("A")
    xs = [x for x in range(im.width) if a.getpixel((x, y)) > 128]
    return (min(xs) + max(xs)) / 2 if xs else im.width / 2


def segmentos_linha(im, y):
    a = im.getchannel("A")
    segs, ini = [], None
    for x in range(im.width):
        on = a.getpixel((x, y)) > 128
        if on and ini is None:
            ini = x
        if not on and ini is not None:
            segs.append((ini, x - 1)); ini = None
    if ini is not None:
        segs.append((ini, im.width - 1))
    return segs


def escurecer(im, f=0.78):
    rgb = ImageEnhance.Brightness(im.convert("RGB")).enhance(f)
    rgb.putalpha(im.getchannel("A"))
    return rgb


def rot(v, ang):
    t = math.radians(ang)
    return (v[0] * math.cos(t) - v[1] * math.sin(t), v[0] * math.sin(t) + v[1] * math.cos(t))


def colar(tela, im, piv, ang, pos):
    """cola 'im' girada 'ang' graus (horario) em torno de 'piv', com o pivo indo para 'pos'."""
    w, h = im.size
    r = int(math.ceil(max(math.hypot(piv[0], piv[1]), math.hypot(w - piv[0], piv[1]),
                          math.hypot(piv[0], h - piv[1]), math.hypot(w - piv[0], h - piv[1])))) + 2
    pad = Image.new("RGBA", (2 * r, 2 * r))
    pad.paste(im, (int(r - piv[0]), int(r - piv[1])))
    pad = pad.rotate(-ang, resample=Image.BICUBIC, center=(r, r))
    tela.alpha_composite(pad, (int(pos[0] - r), int(pos[1] - r)))


class Boneco:
    def __init__(self, pasta, mapa):
        P = [Image.open(f"{pasta}/parte_{i:02d}.png").convert("RGBA") for i in mapa]
        self.cab, self.tor, ra, rb, da, db, pa, pb = P
        self.cab = self.cab.resize((int(self.cab.width * 1.12), int(self.cab.height * 1.12)), Image.LANCZOS)
        self.reto = (ra, rb)
        self.dobr = (da, db)
        # perna dividida no joelho (coxa por cima da canela)
        perna = pa
        self.Lh = perna.height
        jy = int(perna.height * 0.50)
        self.coxa = perna.crop((0, 0, perna.width, jy + 18))
        self.canela = perna.crop((0, jy - 18, perna.width, perna.height))
        self.p_quad = (centro_linha(perna, 45), 45)
        self.p_joel = (centro_linha(perna, jy), jy)
        # arredonda a ponta de baixo da coxa (esconde o corte no joelho) e contorna
        sg = segmentos_linha(perna, jy)
        x0, x1 = (min(s[0] for s in sg), max(s[1] for s in sg)) if sg else (0, perna.width)
        m = Image.new("L", self.coxa.size, 0)
        d = ImageDraw.Draw(m)
        d.rectangle((0, 0, self.coxa.width, jy), fill=255)
        d.ellipse((x0, jy - 16, x1, jy + 16), fill=255)
        self.coxa.putalpha(ImageChops.multiply(self.coxa.getchannel("A"), m))
        ImageDraw.Draw(self.coxa).arc((x0 + 2, jy - 15, x1 - 2, jy + 15), 10, 170, fill=(70, 30, 35, 255), width=5)
        self.p_joel_can = (self.p_joel[0], 18)
        self.sola = perna.height - 8 - 45
        # tronco: quadril embaixo, ombro da frente na manga da esquerda, ombro de tras na direita
        t = self.tor
        self.p_quadril = (centro_linha(t, t.height - 40), t.height - 40)
        segs = segmentos_linha(t, 60)
        self.ombro_f = ((segs[0][0] + segs[0][1]) / 2 + 6, 46) if segs else (60, 46)
        self.ombro_t = (t.width * 0.66, 50)
        self.pescoco = (t.width * 0.58, 22)
        # cabeca: pescoco embaixo, perto do queixo
        c = self.cab
        self.p_cab = (centro_linha(c, c.height - 30) - 18, c.height - 30)
        # bracos: pivo no topo da manga
        self.p_reto = [(centro_linha(b, 40), 40) for b in self.reto]
        self.p_dobr = [(segmentos_linha(b, 40)[0][0] / 2 + segmentos_linha(b, 40)[0][1] / 2, 40) for b in self.dobr]

    def quadro(self, p):
        tela = Image.new("RGBA", (TELA, TELA))
        quadril = (TELA * 0.45, CHAO - self.sola + p.get("y", 0))
        tr = p.get("tr", 0)

        def no_tronco(pt):
            v = rot((pt[0] - self.p_quadril[0], pt[1] - self.p_quadril[1] + p.get("by", 0)), tr)
            return (quadril[0] + v[0], quadril[1] + v[1])

        def braco(lado, ang, tipo, tras):
            img = (self.dobr if tipo == "d" else self.reto)[lado]
            piv = (self.p_dobr if tipo == "d" else self.p_reto)[lado]
            if tras:
                img = escurecer(img)
            ombro = no_tronco(self.ombro_t if tras else self.ombro_f)
            colar(tela, img, piv, tr + ang, ombro)

        def perna(ang, joelho, dx, tras):
            coxa, can = (escurecer(self.coxa), escurecer(self.canela)) if tras else (self.coxa, self.canela)
            q = (quadril[0] + dx, quadril[1])
            v = rot((self.p_joel[0] - self.p_quad[0], self.p_joel[1] - self.p_quad[1]), ang)
            colar(tela, can, self.p_joel_can, ang + joelho, (q[0] + v[0], q[1] + v[1]))
            colar(tela, coxa, self.p_quad, ang, q)

        braco(1, p["aB"], p.get("tipoB", "r"), True)
        perna(p["lB"], p["kB"], -14, True)
        perna(p["lF"], p["kF"], 14, False)
        colar(tela, self.tor, self.p_quadril, tr, no_tronco(self.p_quadril))
        colar(tela, self.cab, self.p_cab, tr + p.get("hr", 0), no_tronco(self.pescoco))
        braco(0, p["aF"], p.get("tipoF", "r"), False)
        return tela.resize((QUADRO, QUADRO), Image.LANCZOS)


sin, cos, PI = math.sin, math.cos, math.pi
BASE = dict(y=0, by=0, tr=0, hr=0, aF=4, aB=-6, lF=-3, kF=2, lB=4, kB=2, tipoF="r", tipoB="r")
P = lambda **k: {**BASE, **k}

ANIMS = [
    ("parado", [P(by=4 * (1 - cos(2 * PI * i / 8)), hr=1.5 * sin(2 * PI * i / 8),
                  aF=4 + 3 * sin(2 * PI * i / 8), aB=-6 - 2 * sin(2 * PI * i / 8)) for i in range(8)]),
    ("correr", [(lambda s, c: P(y=6 - 16 * abs(s), tr=8, hr=-6, lF=-4 - 36 * s, lB=-4 + 36 * s,
                                kF=8 + 62 * max(0, c), kB=8 + 62 * max(0, -c),
                                aF=-28 + 34 * s, aB=-28 - 34 * s, tipoF="d", tipoB="d"))(sin(2 * PI * i / 8), cos(2 * PI * i / 8))
                for i in range(8)]),
    ("pular", [P(y=-6, tr=4, hr=-6, lF=-48, kF=80, lB=16, kB=40, aF=-62, tipoF="d", aB=40),
               P(y=-10, tr=4, hr=-8, lF=-54, kF=88, lB=20, kB=46, aF=-70, tipoF="d", aB=46)]),
    ("cair", [P(y=-6, tr=-2, hr=-4, lF=-16, kF=30, lB=12, kB=22, aF=-62, aB=55),
              P(y=-6, tr=-2, hr=-4, lF=-12, kF=26, lB=14, kB=20, aF=-68, aB=62)]),
    ("comemorar", [(lambda h, t: P(y=-30 * h, hr=-5, aF=-42 - 14 * sin(2 * PI * t), tipoF="d",
                                   aB=25 + 8 * sin(2 * PI * t), lF=-5, kF=18 * h, lB=8, kB=32 * h))(sin(PI * i / 6), i / 6)
                   for i in range(6)]),
]


def main(pasta, saida, mapa="0,2,3,4,5,6,8,9"):
    b = Boneco(pasta, [int(v) for v in mapa.split(",")])
    sheet = Image.new("RGBA", (QUADRO * 8, QUADRO * len(ANIMS)))
    for r, (_, poses) in enumerate(ANIMS):
        for i, p in enumerate(poses):
            sheet.alpha_composite(b.quadro(p), (i * QUADRO, r * QUADRO))
    sheet.save(saida)


if __name__ == "__main__":
    main(*sys.argv[1:])
