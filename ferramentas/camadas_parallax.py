"""Prepara as camadas de parallax geradas no Gemini.
- remove o fundo magenta (chroma key #FF00FF) com borda suave e tira o reflexo rosa
- deixa cada camada repetivel na horizontal (emenda as bordas esquerda/direita)
- salva PNG 1080px de altura e informa a altura do chao na camada da frente
Uso: python3 camadas_parallax.py <pasta_jpegs> <pasta_saida>
     (arquivos esperados: 1_fundo.jpeg, 2_meio.jpeg, 3_frente.jpeg)
"""
import os
import sys
from PIL import Image

ALT = 1080
EMENDA = 220  # largura da faixa de mistura nas bordas


def chroma(im):
    im = im.convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, _ = px[x, y]
            spill = min(r, b) - g  # quanto o pixel "puxa" para magenta
            a = 0 if spill > 115 else 255 if spill < 55 else int((115 - spill) * 255 / 60)
            if spill > 12:  # tira o rosado das bordas
                k = int(spill * 1.0)
                r, b = max(0, r - k), max(0, b - k)
            px[x, y] = (r, g, b, a)
    return im


def repetivel(im):
    """imagem + copia espelhada: as bordas sempre casam, sem costura."""
    w, h = im.size
    out = Image.new("RGBA", (w * 2, h))
    out.paste(im, (0, 0))
    out.paste(im.transpose(Image.FLIP_LEFT_RIGHT), (w, 0))
    return out


def topo_chao(im):
    a = im.getchannel("A")
    w = im.width
    cols = range(int(w * 0.3), int(w * 0.7), 8)
    for y in range(im.height):
        cheio = sum(1 for x in cols if a.getpixel((x, y)) > 128)
        if cheio > 0.9 * len(cols):
            return y
    return None


def deslocamentos(ent):
    """le deslocamento.txt (ex.: 2_meio=-0.15 -> sobe 15% da altura)"""
    d = {}
    arq = os.path.join(ent, "deslocamento.txt")
    if os.path.exists(arq):
        for linha in open(arq):
            if "=" in linha:
                k, v = linha.strip().split("=")
                d[k] = float(v)
    return d


def main(ent, sai):
    os.makedirs(sai, exist_ok=True)
    desl = deslocamentos(ent)
    for nome, chave in (("1_fundo", False), ("2_meio", True), ("3_frente", True)):
        arq = next(os.path.join(ent, nome + e) for e in (".png", ".jpeg", ".jpg") if os.path.exists(os.path.join(ent, nome + e)))
        im = Image.open(arq).convert("RGB")
        im = im.resize((int(im.width * ALT / im.height), ALT), Image.LANCZOS)
        im = chroma(im) if chave else im.convert("RGBA")
        if nome in desl:
            dy = int(desl[nome] * ALT)
            movida = Image.new("RGBA", im.size)
            movida.paste(im, (0, dy))
            im = movida
        im = repetivel(im)
        im.save(os.path.join(sai, nome + ".png"))
        msg = f"{nome}: {im.size}"
        if nome == "3_frente":
            msg += f"  topo do chao em y={topo_chao(im)}"
        print(msg)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
