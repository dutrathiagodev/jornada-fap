"""Compõe e sintetiza as músicas do jogo (loops sem direitos autorais) em jogo/assets/musica/*.wav.
Uso: python3 ferramentas/gerar_musica.py
Cada trilha tem 16 compassos e fecha em loop. Mude os parâmetros em FAIXAS para criar novas."""
import math, random, struct, wave, os
SR = 22050
PASTA = os.path.join(os.path.dirname(__file__), "..", "jogo", "assets", "musica")
os.makedirs(PASTA, exist_ok=True)

MAIOR = [0, 2, 4, 5, 7, 9, 11]
MENOR = [0, 2, 3, 5, 7, 8, 10]

# nome: raiz midi, modo, bpm, progressão (graus), semente, estilo
FAIXAS = {
    "tema":          dict(raiz=60, modo=MAIOR, bpm=112, prog=[0, 4, 5, 3], seed=11, estilo="alegre"),
    "curitiba":      dict(raiz=55, modo=MAIOR, bpm=104, prog=[0, 3, 4, 0], seed=21, estilo="folk"),
    "foz":           dict(raiz=62, modo=MAIOR, bpm=116, prog=[0, 5, 3, 4], seed=31, estilo="agua"),
    "sao_paulo":     dict(raiz=57, modo=MENOR, bpm=122, prog=[0, 5, 3, 6], seed=41, estilo="urbano"),
    "florianopolis": dict(raiz=53, modo=MAIOR, bpm=98,  prog=[0, 3, 0, 4], seed=51, estilo="praia"),
    "porto_alegre":  dict(raiz=64, modo=MENOR, bpm=112, prog=[0, 5, 2, 6], seed=61, estilo="epico"),
}

def hz(m): return 440.0 * 2 ** ((m - 69) / 12.0)

def nota_escala(raiz, modo, grau):
    oit, i = divmod(grau, 7)
    return raiz + modo[i] + 12 * oit

def acorde(raiz, modo, grau):
    return [nota_escala(raiz, modo, grau + k) for k in (0, 2, 4)]

class Faixa:
    def __init__(self, dur):
        self.n = int(dur * SR); self.b = [0.0] * self.n
    def add(self, t0, dur, f, vol, tipo):
        i0 = int(t0 * SR); n = int(dur * SR); fase = 0.0
        for k in range(n):
            t = k / SR
            if tipo == "lead":
                vib = 1 + 0.004 * math.sin(2 * math.pi * 5.5 * t) * min(1, t / 0.2)
                fase += 2 * math.pi * f * vib / SR
                s = (2 / math.pi) * math.asin(math.sin(fase)) + 0.25 * math.sin(2 * fase)
                env = min(1, k / (SR * 0.012)) * math.exp(-1.8 * t / dur) * min(1, (n - k) / (SR * 0.05))
            elif tipo == "baixo":
                fase += 2 * math.pi * f / SR
                s = math.sin(fase) + 0.4 * math.sin(2 * fase)
                env = min(1, k / (SR * 0.008)) * math.exp(-2.6 * t / dur) * min(1, (n - k) / (SR * 0.03))
            elif tipo == "arp":
                fase += 2 * math.pi * f / SR
                s = 1.0 if (fase / (2 * math.pi)) % 1 < 0.25 else -1.0
                env = min(1, k / (SR * 0.004)) * math.exp(-5.0 * t / dur)
            elif tipo == "pad":
                fase += 2 * math.pi * f / SR
                s = math.sin(fase) + 0.5 * math.sin(fase * 1.003 * 2)
                env = min(1, k / (SR * 0.35)) * min(1, (n - k) / (SR * 0.35))
            else:
                s = 0.0; env = 0.0
            j = (i0 + k) % self.n
            self.b[j] += s * env * vol
    def bumbo(self, t0, vol):
        i0 = int(t0 * SR); n = int(0.16 * SR); fase = 0.0
        for k in range(n):
            t = k / n; f = 130 * (1 - t) + 45 * t
            fase += 2 * math.pi * f / SR
            self.b[(i0 + k) % self.n] += math.sin(fase) * (1 - t) ** 2 * vol
    def ruido(self, t0, dur, vol, rnd):
        i0 = int(t0 * SR); n = int(dur * SR); ant = 0.0
        for k in range(n):
            r = rnd.uniform(-1, 1); a = r - ant * 0.6; ant = r
            self.b[(i0 + k) % self.n] += a * (1 - k / n) ** 2 * vol

def compor(nome, p):
    rnd = random.Random(p["seed"]); raiz, modo, bpm = p["raiz"], p["modo"], p["bpm"]
    batida = 60.0 / bpm; compasso = 4 * batida; N = 16
    f = Faixa(N * compasso); estilo = p["estilo"]
    swing = batida / 6 if estilo == "praia" else 0.0
    # motivo de 4 compassos (graus da escala em colcheias; None = pausa)
    def frase():
        g = 7 + rnd.choice([0, 2, 4]); m = []
        for c in range(4):
            bar = []
            for s in range(8):
                if s == 0: g = nota_escala(0, [0, 1, 2, 3, 4, 5, 6], 0) + rnd.choice([0, 2, 4]) + (7 if rnd.random() < .7 else 0) + (0 if True else 0)
                if rnd.random() < (0.72 if s % 2 == 0 else 0.5):
                    g = max(4, min(13, g + rnd.choice([-2, -1, -1, 0, 1, 1, 2])))
                    bar.append(g)
                else:
                    bar.append(None)
            m.append(bar)
        return m
    A, B = frase(), frase()
    partes = [A, A, B, A]
    for c in range(N):
        grau_ac = p["prog"][c % 4]
        ac = acorde(raiz - 12, modo, grau_ac)
        t0 = c * compasso
        # baixo
        for s in range(8):
            if estilo in ("urbano", "epico") or s in (0, 3, 4, 6 if estilo == "agua" else 4):
                nb = ac[0] if s % 4 != 3 else ac[2]
                f.add(t0 + s * batida / 2, batida / 2 * 0.95, hz(nb), 0.30, "baixo")
        # acompanhamento
        if estilo in ("alegre", "agua", "folk", "praia"):
            for s in range(8):
                arp = acorde(raiz, modo, grau_ac)[s % 3] + (12 if estilo == "agua" and s % 2 else 0)
                f.add(t0 + s * batida / 2 + (swing if s % 2 else 0), batida / 2, hz(arp), 0.07, "arp")
        if estilo in ("alegre", "praia", "epico", "urbano"):
            for nn in acorde(raiz, modo, grau_ac):
                f.add(t0, compasso, hz(nn), 0.05 if estilo != "epico" else 0.08, "pad")
        # percussão
        for s in range(4):
            if estilo in ("alegre", "urbano", "epico", "agua") and s in (0, 2):
                f.bumbo(t0 + s * batida, 0.45)
            if estilo in ("urbano", "epico") and s in (1, 3):
                f.ruido(t0 + s * batida, 0.12, 0.18, rnd)
            if estilo != "epico" or c % 2:
                f.ruido(t0 + s * batida + batida / 2, 0.05, 0.07, rnd)
        if estilo == "folk" and c % 2 == 0:
            f.bumbo(t0, 0.3); f.bumbo(t0 + 2 * batida, 0.25)
        # melodia
        m = partes[c // 4][c % 4]
        for s, g in enumerate(m):
            if g is None: continue
            gg = g if c % 4 != 3 or s < 6 else grau_ac + 7 + (0 if s == 6 else 2)
            if s == 0: gg = grau_ac + 7 + rnd.choice([0, 2, 4]) if c % 4 == 0 else gg
            nota = nota_escala(raiz, modo, gg)
            f.add(t0 + s * batida / 2 + (swing if s % 2 else 0), batida * 0.9, hz(nota), 0.20, "lead")
    pico = max(abs(x) for x in f.b) or 1.0
    amostras = [x / pico * 0.8 for x in f.b]
    with wave.open(os.path.join(PASTA, nome + ".wav"), "w") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(a * 32000)) for a in amostras))
    print(nome, round(len(amostras) / SR, 1), "s")

if __name__ == "__main__":
    for nome, p in FAIXAS.items():
        compor(nome, p)
