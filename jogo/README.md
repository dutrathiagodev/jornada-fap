# Jornada FAP — projeto Godot

Abrir e jogar: `./jogar.sh` (na pasta do JOGO-FAP). Para editar, abra a pasta `jogo/` no Godot 4.7.2 (`ferramentas/godot/`).

**Controles:** ← → ou A D andam · Espaço/W/↑ pula (segure para pular mais alto) · Shift corre · Esc pausa.
**Perguntas:** ↑ ↓ ← → escolhem e **Enter** confirma (ou teclas 1 a 4). **Enter** também continua e avança de fase.
**Controle (Xbox, PlayStation, Switch...):** analógico esquerdo ou direcional andam · A (Cruz) pula e confirma · X/RB/RT (Quadrado/R1/R2) corre · Start pausa · B (Bolinha) volta · Y (Triângulo) mapa. As dicas na tela trocam sozinhas para os botões do controle.

**Fases prontas:** as 5 cidades (Curitiba, Foz do Iguaçu, São Paulo, Florianópolis, Porto Alegre), tela de título, mapa, resultado, pausa e tela do cupom. Perguntas em `dados/perguntas/<cidade>.json`.

**Variáveis de teste (só para desenvolvimento):**
- `FAP_CIDADE=n` (1 a 5) pula direto para a fase; `FAP_X=x` escolhe onde o jogador nasce.
- `FAP_DEMO=1` joga sozinho acertando tudo; `FAP_DEMO=erro` erra de propósito.
- `FAP_PAUSA=1` abre a pausa sozinho.
Exemplo: `FAP_CIDADE=3 FAP_DEMO=1 ./jogar.sh`. Os testes gravam em `user://progresso.cfg`; apague depois (`~/.local/share/godot/app_userdata/Jornada FAP/progresso.cfg`).

**Código:** `scripts/fase.gd` (fase inteira, montada por código), `jogador.gd`, `jogo.gd` (autoload: cidades, progresso, cupom, fonte), `perguntas.gd` (autoload: perguntas e teclas), `titulo.gd`, `mapa.gd`, `final.gd` (cupom), `estrelas.gd` (estrelas desenhadas).

Efeitos sonoros: `python3 ferramentas/gerar_sons.py` (sintetizados, sem direitos autorais).

**Landing page:** `landing/index.html` (HTML puro, sem build). Para ver: `cd landing && python3 -m http.server 8765` e abrir `http://localhost:8765`. Imagens em `landing/img/` (telas do jogo, capas, logos); fonte Lilita One em `landing/fonte/`.
**Música:** `python3 ferramentas/gerar_musica.py` recompõe as 6 trilhas em `jogo/assets/musica/` (tema, uma por cidade); tecla N liga/desliga no jogo.
