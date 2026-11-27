"""Transforma um video de animacao (Veo, fundo branco) em uma tira de sprites, quadro a quadro.

Uso:
  python3 video_para_sprites.py <video.mp4> <saida.png> ciclo [passo=1] [de=0] [ate=fim] [pmin=10] [pmax=40]
      acha o trecho que se repete (loop) entre os quadros de..ate e usa TODOS os quadros dele
      (passo=2 usa 1 a cada 2)
  Em qualquer modo, pe=1 prende o pe no chao em todos os quadros (para o pulo) e esc=0.50 fixa a escala (use a mesma em todas as animacoes do personagem).
  python3 video_para_sprites.py <video.mp4> <saida.png> trecho <inicio> <fim> [passo=1]
      usa os quadros de <inicio> ate <fim> (para pulo, dano, derrota: animacoes que nao repetem)
  python3 video_para_sprites.py <video.mp4> <saida.png> vaivem <inicio> <fim> [passo=1]
      trecho de ida e volta (loop perfeito para respiracao/parado)

Obs.: no Gemini, cada video novo na mesma conversa vem COM os videos anteriores no comeco
(10 s, 20 s, 30 s...). O movimento novo e sempre os ultimos 10 s (240 quadros).

Saida: tira com quadros de 384x384 (um ao lado do outro), fundo transparente,
e uma previa <saida>.gif para conferir.

Para nao "quebrar" a animacao:
- o recorte, a escala e a posicao sao OS MESMOS para todos os quadros
  (a camera do video ja e parada; nada e realinhado quadro a quadro, entao o boneco nao treme);
- so uma deriva lenta do personagem no video (andar para o lado sem querer) e compensada,
  com uma reta, sem mexer no movimento natural;
- o ciclo e escolhido comparando o trecho inteiro, para a volta do ultimo ao primeiro quadro ficar lisa.
"""
import glob
import os
import subprocess
import sys
import tempfile
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageStat

Q = 384
PE = 371           # linha do pe dentro do quadro
ALTURA_ALVO = 300  # altura do personagem em pe (px no quadro)
FPS = 24
PE_FIXO = False    # pe=1: prende o pe na linha do chao em cada quadro (pulo: a altura vem da fisica do jogo)
ESCALA = None      # esc=0.50 na linha de comando: mesma escala em todas as animacoes do personagem


def extrair(video, pasta):
    subprocess.run(["ffmpeg", "-loglevel", "error", "-i", video, "-vf", f"fps={FPS}",
                    os.path.join(pasta, "f%04d.png")], check=True)
    return sorted(glob.glob(os.path.join(pasta, "f*.png")))


def mascara(im):
    """fundo = branco ligado a borda (nao apaga a camiseta branca)"""
    rgb = im.convert("RGB")
    w, h = rgb.size
    marca = (255, 0, 255)
    for p in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1), (w // 2, 0), (w // 2, h - 1),
              (0, h // 2), (w - 1, h // 2), (w // 4, 0), (3 * w // 4, 0), (w // 4, h - 1), (3 * w // 4, h - 1)]:
        px = rgb.getpixel(p)
        if px != marca and min(px) > 200:
            ImageDraw.floodfill(rgb, p, marca, thresh=40)
    m = ImageChops.difference(rgb, Image.new("RGB", rgb.size, marca)).convert("L")
    m = Image.eval(m, lambda v: 0 if v < 12 else 255)
    # tira a borda clara (halo) e suaviza o contorno
    return m.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(0.7))


def pequeno(im):
    return im.convert("L").resize((128, 72))


def diferenca(a, b):
    return ImageStat.Stat(ImageChops.difference(a, b)).mean[0]


def melhor_ciclo(peq, pmin=10, pmax=40):
    """inicio e periodo cujo trecho inteiro mais se repete: compara a..a+p com a+p..a+2p"""
    n = len(peq)
    melhor = (1e9, 0, 0)
    for p in range(pmin, min(pmax, n // 2) + 1):
        for a in range(0, n - 2 * p + 1):
            pontos = range(0, p, max(1, p // 6))
            d = sum(diferenca(peq[a + k], peq[a + p + k]) for k in pontos) / len(pontos)
            d += 0.002 * p  # empate: prefere o ciclo mais curto
            if d < melhor[0]:
                melhor = (d, a, p)
    return melhor


def main(video, saida, modo="ciclo", *resto):
    with tempfile.TemporaryDirectory() as tmp:
        arqs = extrair(video, tmp)
        print("quadros no video:", len(arqs))
        if modo == "ciclo":
            op = {"passo": 1, "de": 0, "ate": len(arqs), "pmin": 10, "pmax": 40}
            for i, v in enumerate(resto):
                if "=" in v:
                    k, v = v.split("=")
                    op[k] = int(v)
                elif i == 0:
                    op["passo"] = int(v)
            passo = op["passo"]
            peq = [pequeno(Image.open(a)) for a in arqs[op["de"]:op["ate"]]]
            d, a, p = melhor_ciclo(peq, op["pmin"], op["pmax"])
            a += op["de"]
            print(f"ciclo: inicio {a}, periodo {p} quadros ({p / FPS:.2f} s), diferenca {d:.2f}")
            idx = list(range(a, a + p, passo))
        elif modo == "vaivem":
            ini, fim = int(resto[0]), int(resto[1])
            passo = int(resto[2]) if len(resto) > 2 else 1
            ida = list(range(ini, fim + 1, passo))
            idx = ida + ida[-2:0:-1]
        else:
            ini, fim = int(resto[0]), int(resto[1])
            passo = int(resto[2]) if len(resto) > 2 else 1
            idx = list(range(ini, min(fim, len(arqs) - 1) + 1, passo))
        cache = {}
        brutos = [cache.setdefault(i, Image.open(arqs[i]).convert("RGB")) for i in idx]
        masks = [mascara(b) for b in brutos]
        caixas = [m.getbbox() for m in masks]

        # um unico enquadramento para todos os quadros
        topo = min(b[1] for b in caixas)
        base = max(b[3] for b in caixas)
        alt_pe = sorted(b[3] - b[1] for b in caixas)[len(caixas) // 2]  # altura tipica
        esc = ESCALA or min(ALTURA_ALVO / alt_pe, (PE - 4) / (base - topo))
        # deriva lenta: reta pelo centro horizontal dos quadros
        cxs = [(b[0] + b[2]) / 2 for b in caixas]
        n = len(cxs)
        mx = (n - 1) / 2
        my = sum(cxs) / n
        incl = (sum((i - mx) * (c - my) for i, c in enumerate(cxs)) / max(1e-9, sum((i - mx) ** 2 for i in range(n)))) if n > 2 else 0
        if modo == "trecho":
            incl = 0  # em pulo/derrota o deslocamento e parte do movimento

        tira = Image.new("RGBA", (Q * n, Q))
        quadros = []
        for k, (b, m) in enumerate(zip(brutos, masks)):
            im = b.convert("RGBA")
            im.putalpha(m)
            centro = my + incl * (k - mx)
            im = im.resize((round(im.width * esc), round(im.height * esc)), Image.LANCZOS)
            x = round(Q / 2 - centro * esc)
            y = round(PE - (caixas[k][3] if PE_FIXO else base) * esc)
            q = Image.new("RGBA", (Q, Q))
            q.paste(im, (x, y), im)
            tira.alpha_composite(q, (k * Q, 0))
            quadros.append(q)
        tira.save(saida)

        # previa sobre fundo claro
        prev = []
        for q in quadros:
            f = Image.new("RGBA", (Q, Q), (226, 236, 244, 255))
            ImageDraw.Draw(f).line([(0, PE), (Q, PE)], fill=(150, 170, 190, 255), width=2)
            f.alpha_composite(q)
            prev.append(f.convert("RGB").resize((Q // 2, Q // 2), Image.LANCZOS))
        prev[0].save(os.path.splitext(saida)[0] + ".gif", save_all=True, append_images=prev[1:],
                     duration=round(1000 * passo / FPS), loop=0)
        print(f"salvo {saida}: {n} quadros (video {idx[0]}..{idx[-1]}, passo {passo}), escala {esc:.3f}")


if __name__ == "__main__":
    args = []
    for a in sys.argv[1:]:
        if a == "pe=1":
            PE_FIXO = True
        elif a.startswith("esc="):
            ESCALA = float(a[4:])
        else:
            args.append(a)
    main(*args)
