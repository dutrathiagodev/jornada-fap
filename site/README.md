# Site do Jornada FAP (Next.js)

Landing page estática do jogo. Next.js (App Router) + TypeScript + CSS Modules, sem bibliotecas de animação.

```bash
npm install
npm run dev      # http://localhost:3100
npm run build    # gera a pasta out/ (HTML estático, pronta para qualquer hospedagem)
npm run lint     # checagem de tipos
```

## Arquitetura

| Pasta | Responsabilidade |
|---|---|
| `src/domain` | Tipos puros (Cidade, Destaque, Fato...). Não importam nada do resto. |
| `src/content` | Textos e dados do site. Para mudar um texto, edite só aqui. |
| `src/hooks` | Comportamento reutilizável (revelar ao rolar, seção ativa, progresso de rolagem, parallax do mouse). |
| `src/lib` | Funções utilitárias sem React. |
| `src/components/ui` | Peças visuais genéricas (Botao, Titulo, Ornamento, MolduraCircular, Revelar...). |
| `src/components/layout` | Barra do topo, navegação lateral, faixa de chamada, rodapé. |
| `src/components/effects` | Efeitos decorativos (moedas, confete, menino em sprite). |
| `src/components/sections` | Seções da página, cada uma com seu `.module.css`. |

Fluxo de dependência: `app → sections → ui/layout/effects → hooks/lib → domain`, com `content` alimentando as seções.
Componentes só viram client (`"use client"`) quando precisam de estado ou efeito de navegador.

## Notas
- Imagens em `public/img` (webp otimizadas a partir de `jogo/assets`).
- Hospedando em subpasta: `NEXT_PUBLIC_BASE_PATH=/jogo npm run build`.
- O botão "Jogar" está como "em breve" até existir a exportação web do jogo.
