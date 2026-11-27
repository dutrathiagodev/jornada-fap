"""Instala a moeda feita pelo usuario: tira o fundo cinza (flood fill a partir das bordas) e salva em jogo/assets/objetos/moeda_logo.png.
Uso: python3 instalar_moeda.py <imagem.png>"""
import sys
from PIL import Image, ImageDraw, ImageFilter, ImageChops
im = Image.open(sys.argv[1]).convert("RGB")
w, h = im.size
marca = (255, 0, 255)
f = im.copy()
for p in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1), (w // 2, 0), (w // 2, h - 1), (0, h // 2), (w - 1, h // 2)]:
    ImageDraw.floodfill(f, p, marca, thresh=38)
m = ImageChops.difference(f, Image.new("RGB", f.size, marca)).convert("L").point(lambda v: 0 if v < 12 else 255)
m = m.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
out = im.convert("RGBA"); out.putalpha(m)
out = out.crop(out.getbbox()); out.thumbnail((256, 256), Image.LANCZOS)
out.save("../jogo/assets/objetos/moeda_logo.png"); print("ok", out.size)
