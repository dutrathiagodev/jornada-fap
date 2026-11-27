"""Renderiza os personagens cartoon (arte/personagens.html) com o Chrome headless.
Uso: python3 render_personagens.py <pasta_saida>
Gera: menino_sheet.png, menina_sheet.png (2048x1280, quadros 256x256),
      previa.png (todos os quadros em fundo claro) e animacao.gif.
Linhas da folha: 0 parado(8) 1 correr(8) 2 pular(2) 3 cair(2) 4 comemorar(6).
"""
import os
import subprocess
import sys
from PIL import Image

AQUI = os.path.dirname(os.path.abspath(__file__))
HTML = os.path.join(AQUI, "..", "arte", "personagens.html")
ANIMS = [("parado", 8), ("correr", 8), ("pular", 2), ("cair", 2), ("comemorar", 6)]
F = 256


def render(char, out):
    url = "file://" + os.path.abspath(HTML) + f"?char={char}"
    subprocess.run(["google-chrome", "--headless=new", "--disable-gpu", "--hide-scrollbars",
                    "--force-device-scale-factor=1", "--default-background-color=00000000",
                    "--window-size=2048,1280", f"--screenshot={out}", url],
                   check=True, capture_output=True, timeout=90)


def quadro(sheet, linha, i):
    return sheet.crop((i * F, linha * F, i * F + F, linha * F + F))


def main(saida):
    os.makedirs(saida, exist_ok=True)
    sheets = {}
    for c in ("menino", "menina"):
        p = os.path.join(saida, f"{c}_sheet.png")
        render(c, p)
        sheets[c] = Image.open(p).convert("RGBA")

    # previa: as duas folhas empilhadas em fundo claro
    prev = Image.new("RGBA", (2048, 2560), (205, 232, 246, 255))
    prev.alpha_composite(sheets["menino"], (0, 0))
    prev.alpha_composite(sheets["menina"], (0, 1280))
    prev.convert("RGB").resize((1024, 1280), Image.LANCZOS).save(os.path.join(saida, "previa.png"))

    # GIF: os dois lado a lado, sequencia parado -> correr -> pular -> cair -> comemorar
    seq = [(0, i % 8, 110) for i in range(16)] + [(1, i % 8, 80) for i in range(24)] \
        + [(2, 0, 160), (2, 1, 220), (3, 0, 160), (3, 1, 200)] + [(4, i % 6, 110) for i in range(12)]
    quadros, tempos = [], []
    for linha, i, ms in seq:
        q = Image.new("RGBA", (560, 300), (205, 232, 246, 255))
        q.paste((110, 185, 80, 255), (0, 268, 560, 300))
        q.paste((92, 160, 64, 255), (0, 268, 560, 274))
        for k, c in enumerate(("menino", "menina")):
            q.alpha_composite(quadro(sheets[c], linha, i), (20 + k * 270, 24 + 0))
        quadros.append(q.convert("RGB"))
        tempos.append(ms)
    quadros[0].save(os.path.join(saida, "animacao.gif"), save_all=True, append_images=quadros[1:],
                    duration=tempos, loop=0, optimize=True)


if __name__ == "__main__":
    main(sys.argv[1])
