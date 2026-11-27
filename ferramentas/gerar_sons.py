"""Gera os efeitos sonoros do jogo (sintetizados, sem direitos autorais) em jogo/assets/sons/*.wav.
Uso: python3 ferramentas/gerar_sons.py"""
import math, random, struct, wave, os
SR = 44100
PASTA = os.path.join(os.path.dirname(__file__), "..", "jogo", "assets", "sons")
os.makedirs(PASTA, exist_ok=True)

def tom(freq_ini, freq_fim, dur, forma="seno", vol=0.5, ataque=0.005):
    n = int(SR * dur); out = []; fase = 0.0
    for i in range(n):
        t = i / n
        f = freq_ini + (freq_fim - freq_ini) * t
        fase += 2 * math.pi * f / SR
        if forma == "seno": s = math.sin(fase)
        elif forma == "quadrada": s = 1.0 if math.sin(fase) > 0 else -1.0
        elif forma == "serra": s = 2 * ((fase / (2 * math.pi)) % 1) - 1
        else: s = random.uniform(-1, 1)
        env = min(1.0, i / (SR * ataque)) * (1 - t) ** 1.5
        out.append(s * env * vol)
    return out

def seq(*partes):
    r = []
    for p in partes: r += p
    return r

def salvar(nome, amostras):
    with wave.open(os.path.join(PASTA, nome + ".wav"), "w") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, a)) * 32000)) for a in amostras))

salvar("pulo", tom(280, 620, 0.16, "quadrada", 0.22))
salvar("moeda", seq(tom(988, 988, 0.07, "quadrada", 0.2), tom(1319, 1319, 0.18, "quadrada", 0.2)))
salvar("acerto", seq(tom(523, 523, 0.1, "seno", 0.4), tom(659, 659, 0.1, "seno", 0.4), tom(784, 784, 0.1, "seno", 0.4), tom(1047, 1047, 0.3, "seno", 0.4)))
salvar("erro", seq(tom(220, 180, 0.18, "serra", 0.3), tom(165, 110, 0.32, "serra", 0.3)))
salvar("dano", tom(400, 90, 0.3, "serra", 0.35))
salvar("porta", seq(tom(90, 60, 0.35, "seno", 0.7), tom(0, 0, 0.0)))
salvar("vitoria", seq(*[tom(f, f, 0.14, "quadrada", 0.22) for f in (523, 659, 784, 1047)], tom(1319, 1319, 0.5, "quadrada", 0.22)))
salvar("pouso", tom(120, 60, 0.12, "ruido", 0.18))
salvar("clique", tom(900, 700, 0.05, "quadrada", 0.18))
salvar("estrela", seq(tom(784, 784, 0.07, "seno", 0.45), tom(1175, 1175, 0.07, "seno", 0.45), tom(1568, 1568, 0.3, "seno", 0.45)))
salvar("bloco", seq(tom(180, 120, 0.07, "quadrada", 0.3), tom(1047, 1319, 0.2, "quadrada", 0.2)))
salvar("checkpoint", seq(tom(659, 659, 0.09, "seno", 0.4), tom(880, 880, 0.09, "seno", 0.4), tom(1319, 1319, 0.35, "seno", 0.4)))
print("sons gerados em", os.path.abspath(PASTA))
