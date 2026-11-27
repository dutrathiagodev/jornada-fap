"""Personagem modular v2 (estilo Spriter): pecas do Gemini + esqueleto completo.
Articulacoes: pescoco, ombros, cotovelos, pulsos, quadril, joelhos, tornozelos. Troca de rosto por animacao.
Uso: python3 animar_v2.py <menino|menina> <saida_sheet.png>
Folha: quadros 384x384, 8 colunas; linhas:
  0 parado(8)  1 correr(8)  2 pular(2)  3 cair(2)  4 comemorar(6)  5 dano(4)  6 derrota(6)
"""
import math
import os
import sys
from PIL import Image, ImageEnhance

AQUI = os.path.dirname(os.path.abspath(__file__))
PARTES = os.path.join(AQUI, "..", "arte", "partes_v2")
Q = 384
TELA = 920                # quadro em tamanho nativo (depois reduz para 384)
CHAO = int(TELA * 0.965)   # sola dos pes

ANIMS_ORDEM = ["parado", "correr", "pular", "cair", "comemorar", "dano", "derrota"]


# ---------- utilitarios ----------
def abrir(*p):
    return Image.open(os.path.join(PARTES, *p)).convert("RGBA")


def escala(im, sx, sy=None):
    sy = sx if sy is None else sy
    return im.resize((max(1, round(im.width * sx)), max(1, round(im.height * sy))), Image.LANCZOS)


def centro_faixa(im, y0, y1):
    a = im.getchannel("A")
    xs = []
    for y in range(max(0, y0), min(im.height, y1)):
        for x in range(0, im.width, 2):
            if a.getpixel((x, y)) > 128:
                xs.append(x)
    return (sum(xs) / len(xs)) if xs else im.width / 2


def eixo(im, top=0.10, bot=0.10):
    """pontas do membro: centro das linhas de cima e de baixo"""
    h = im.height
    p0 = (centro_faixa(im, 0, int(h * top)), h * top * 0.5)
    p1 = (centro_faixa(im, int(h * (1 - bot)), h), h * (1 - bot * 0.5))
    return p0, p1


def angulo(p0, p1):
    dx, dy = p1[0] - p0[0], p1[1] - p0[1]
    return math.degrees(math.atan2(-dx, dy))  # 0 = apontando para baixo; + = horario


def rot(v, ang):
    t = math.radians(ang)
    return (v[0] * math.cos(t) - v[1] * math.sin(t), v[0] * math.sin(t) + v[1] * math.cos(t))


def soma(a, b):
    return (a[0] + b[0], a[1] + b[1])


def escurecer(im, f=0.84):
    rgb = ImageEnhance.Brightness(im.convert("RGB")).enhance(f)
    rgb.putalpha(im.getchannel("A"))
    return rgb


def colar(tela, im, piv, ang, pos):
    w, h = im.size
    r = int(math.ceil(max(math.hypot(piv[0] - cx, piv[1] - cy) for cx in (0, w) for cy in (0, h)))) + 2
    pad = Image.new("RGBA", (2 * r, 2 * r))
    pad.paste(im, (int(round(r - piv[0])), int(round(r - piv[1]))))
    pad = pad.rotate(-ang, resample=Image.BICUBIC, center=(r, r))
    tela.alpha_composite(pad, (int(round(pos[0] - r)), int(round(pos[1] - r))))


class Membro:
    """peca com duas pontas (inicio/fim). Desenha alinhada a um angulo 'mundo'."""
    def __init__(self, im, top=0.10, bot=0.10):
        self.im = im
        self.ini, self.fim = eixo(im, top, bot)
        self.base = angulo(self.ini, self.fim)
        self.L = math.hypot(self.fim[0] - self.ini[0], self.fim[1] - self.ini[1])
        self.esc = escurecer(im)

    def desenhar(self, tela, pos, ang, tras=False):
        colar(tela, self.esc if tras else self.im, self.ini, ang - self.base, pos)
        return soma(pos, rot((0, self.L), ang))


# ---------- personagem ----------
class Personagem:
    def __init__(self, quem):
        c = "menino_kit_corpo"
        HEAD = 1.5
        if quem == "menina":
            g = "menina_kit_cabecas"
            cab = [abrir(g, f"parte_0{i}.png") for i in range(5)]
            self.cabecas = dict(normal=cab[0], pisca=cab[1], fechado=cab[2], rindo=cab[3], susto=cab[4])
            HEAD = 1.5
        else:
            cab = [abrir(c, f"cabeca_{i}.png") for i in range(4)] + [abrir(c, "parte_01.png")]
            self.cabecas = dict(normal=cab[0], pisca=cab[1], fechado=cab[2], rindo=cab[3], susto=cab[4])
        self.cabecas = {k: escala(v, HEAD) for k, v in self.cabecas.items()}

        self.tronco = abrir(c, "parte_02.png")
        manga = abrir(c, "parte_03.png")
        braco = abrir(c, "parte_04.png")
        self.punho = abrir(c, "parte_05.png")
        self.mao = abrir(c, "parte_06.png")
        # antebraco = parte de pele do braco (abaixo da manga)
        corte = int(braco.height * 0.50)
        ante = braco.crop((0, corte, braco.width, braco.height))
        ante = ante.crop(ante.getbbox())

        pernas = "menino_kit_pernas"
        tubo = abrir(pernas, "parte_01.png")
        self.tenis = escala(abrir(pernas, "parte_02.png"), 0.50)

        self.braco_sup = Membro(manga, 0.12, 0.12)
        self.antebraco = Membro(ante, 0.12, 0.12)
        self.coxa = Membro(escala(tubo, 0.54, 0.25), 0.12, 0.12)
        self.canela = Membro(escala(tubo, 0.52, 0.25), 0.12, 0.12)
        # pontos fixos
        t = self.tronco
        self.t_quadril = (t.width * 0.50, t.height * 0.93)
        self.t_pesc = (centro_faixa(t, 0, int(t.height * 0.08)), t.height * 0.10)
        self.t_ombro_f = (t.width * 0.80, t.height * 0.20)
        self.t_ombro_t = (t.width * 0.22, t.height * 0.20)
        self.t_coxa_f = (t.width * 0.64, t.height * 0.86)
        self.t_coxa_t = (t.width * 0.38, t.height * 0.86)
        h = self.cabecas["normal"]
        self.c_pesc = (h.width * 0.40, h.height * 0.76) if quem == "menina" else (h.width * 0.50, h.height * 0.92)
        self.tenis_piv = (self.tenis.width * 0.30, self.tenis.height * 0.22)
        self.punho_piv = (self.punho.width * 0.45, self.punho.height * 0.15)
        self.mao_piv = (self.mao.width * 0.40, self.mao.height * 0.80)
        # altura do quadril acima do chao com pernas retas
        self.alt_perna = self.coxa.L + self.canela.L + self.tenis.height * 0.62

    def braco(self, tela, ombro, a, f, mao, tras):
        cot = soma(ombro, rot((0, self.braco_sup.L * 0.92), a))
        pul = self.antebraco.desenhar(tela, cot, a + f, tras)
        if mao == "aberta":
            im = escurecer(self.mao) if tras else self.mao
            colar(tela, im, self.mao_piv, a + f + 180, pul)
        else:
            im = escurecer(self.punho) if tras else self.punho
            colar(tela, im, self.punho_piv, a + f, pul)
        self.braco_sup.desenhar(tela, ombro, a, tras)

    def perna(self, tela, quadril, a, k, ft, tras):
        joelho = soma(quadril, rot((0, self.coxa.L * 0.95), a))
        tornoz = soma(joelho, rot((0, self.canela.L * 0.92), a + k))
        im = escurecer(self.tenis) if tras else self.tenis
        colar(tela, im, self.tenis_piv, ft, tornoz)
        self.canela.desenhar(tela, joelho, a + k, tras)
        self.coxa.desenhar(tela, quadril, a, tras)

    def quadro(self, p):
        tela = Image.new("RGBA", (TELA, TELA))
        quad = (TELA * 0.47 + p.get("x", 0), CHAO - self.alt_perna + p.get("y", 0))
        tr = p.get("tr", 0)

        def T(pt):  # ponto do tronco -> mundo
            v = rot((pt[0] - self.t_quadril[0], pt[1] - self.t_quadril[1] + p.get("by", 0)), tr)
            return soma(quad, v)

        self.braco(tela, T(self.t_ombro_t), p["aB"], p["fB"], p.get("maoB", "punho"), True)
        self.perna(tela, T(self.t_coxa_t), p["lB"], p["kB"], p.get("ftB", 0), True)
        self.perna(tela, T(self.t_coxa_f), p["lF"], p["kF"], p.get("ftF", 0), False)
        colar(tela, self.tronco, self.t_quadril, tr, T(self.t_quadril))
        cab = self.cabecas[p.get("rosto", "normal")]
        colar(tela, cab, self.c_pesc, tr + p.get("hr", 0), T(self.t_pesc))
        self.braco(tela, T(self.t_ombro_f), p["aF"], p["fF"], p.get("maoF", "punho"), False)
        if p.get("girar"):
            tela = tela.rotate(-p["girar"], resample=Image.BICUBIC, center=(TELA * 0.47 + p.get("x", 0), CHAO))
            subir = int(abs(p["girar"]) / 84 * 120)  # deitado: sobe para o corpo ficar sobre o chao
            nova = Image.new("RGBA", tela.size)
            nova.alpha_composite(tela, (0, -subir))
            tela = nova
        return tela.resize((Q, Q), Image.LANCZOS)


# ---------- animacoes ----------
sin, cos, PI = math.sin, math.cos, math.pi
BASE = dict(tr=0, hr=0, y=0, by=0, aF=8, fF=-12, aB=-6, fB=-14, lF=-4, kF=4, lB=5, kB=4, ftF=0, ftB=0)
P = lambda **k: {**BASE, **k}


def anims():
    A = {}
    A["parado"] = [P(by=6 * (1 - cos(2 * PI * i / 8)) / 2, hr=2 * sin(2 * PI * i / 8),
                     aF=8 + 4 * sin(2 * PI * i / 8), aB=-6 - 3 * sin(2 * PI * i / 8),
                     rosto="fechado" if i == 5 else "normal") for i in range(8)]
    corr = []
    for i in range(8):
        ph = 2 * PI * i / 8
        s, c = sin(ph), cos(ph)
        corr.append(P(y=10 - 26 * abs(s), tr=10, hr=-8,
                      lF=-6 - 42 * s, lB=-6 + 42 * s,
                      kF=10 + 70 * max(0, c), kB=10 + 70 * max(0, -c),
                      ftF=-10 + 25 * max(0, c), ftB=-10 + 25 * max(0, -c),
                      aF=-20 + 48 * s, aB=-20 - 48 * s, fF=-85, fB=-85))
    A["correr"] = corr
    A["pular"] = [P(y=-20, tr=4, hr=-8, lF=-55, kF=90, lB=20, kB=50, ftF=15, ftB=30,
                    aF=-95, fF=-45, aB=50, fB=-40, rosto="rindo"),
                  P(y=-30, tr=4, hr=-10, lF=-62, kF=96, lB=24, kB=58, ftF=18, ftB=34,
                    aF=-100, fF=-40, aB=56, fB=-36, rosto="rindo")]
    A["cair"] = [P(y=-20, tr=-3, hr=-4, lF=-18, kF=32, lB=14, kB=24, ftF=20, ftB=24,
                   aF=-125, fF=-25, aB=-110, fB=-20, maoF="aberta", maoB="aberta", rosto="susto"),
                 P(y=-20, tr=-3, hr=-4, lF=-14, kF=28, lB=16, kB=22, ftF=22, ftB=24,
                   aF=-135, fF=-18, aB=-118, fB=-14, maoF="aberta", maoB="aberta", rosto="susto")]
    A["comemorar"] = [(lambda h, t: P(y=-70 * h, hr=-6, aF=12 + 8 * sin(2 * PI * t), fF=-125,
                                      aB=150 + 10 * sin(2 * PI * t), fB=-20,
                                      lF=-8, kF=40 * h, lB=10, kB=60 * h, ftB=15 * h,
                                      rosto="rindo"))(sin(PI * i / 6), i / 6) for i in range(6)]
    A["dano"] = [P(x=-14 * k, tr=-14 * k, hr=-12 * k, aF=-40 * k - 10, fF=-30, aB=-70 * k, fB=-30,
                   lF=10 * k, kF=10, lB=-10 * k, kB=14, maoF="aberta", maoB="aberta", rosto="susto")
                 for k in (0.6, 1.0, 0.8, 0.4)]
    der = []
    for i in range(6):
        t = i / 5
        der.append(P(girar=-84 * t * t, x=330 * t * t, y=10 * t, tr=-6 * t, hr=-10 * t,
                     aF=-60 - 60 * t, fF=-20, aB=-80 - 50 * t, fB=-20,
                     lF=-10 - 30 * t, kF=10 + 30 * t, lB=8 - 20 * t, kB=10,
                     maoF="aberta", maoB="aberta", rosto="susto" if t < 0.5 else "fechado"))
    A["derrota"] = der
    return A


def main(quem, saida):
    p = Personagem(quem)
    A = anims()
    sheet = Image.new("RGBA", (Q * 8, Q * len(ANIMS_ORDEM)))
    for r, nome in enumerate(ANIMS_ORDEM):
        for i, pose in enumerate(A[nome]):
            sheet.alpha_composite(p.quadro(pose), (i * Q, r * Q))
    sheet.save(saida)


if __name__ == "__main__":
    main(*sys.argv[1:])
