type Nome =
  | "play"
  | "fechar"
  | "seta-direita"
  | "seta-esquerda"
  | "mapa"
  | "presente"
  | "livro"
  | "estrela"
  | "ampliar";

const TRACOS: Record<Nome, React.ReactNode> = {
  play: <path d="M8 5.5v13l10.5-6.5z" fill="currentColor" stroke="none" />,
  fechar: <path d="M6 6l12 12M18 6L6 18" />,
  "seta-direita": <path d="M4 12h15M13 6l6 6-6 6" />,
  "seta-esquerda": <path d="M20 12H5M11 6l-6 6 6 6" />,
  mapa: (
    <>
      <path d="M12 21s-6.5-5.6-6.5-10.5a6.5 6.5 0 0113 0C18.5 15.4 12 21 12 21z" />
      <circle cx="12" cy="10.5" r="2.4" />
    </>
  ),
  presente: (
    <>
      <rect x="4" y="9" width="16" height="11" rx="1" />
      <path d="M3 9h18v-3H3zM12 6v14M12 6c-1-3-5-3.5-5-1.2C7 6.2 9 6 12 6zm0 0c1-3 5-3.5 5-1.2C17 6.2 15 6 12 6z" />
    </>
  ),
  livro: <path d="M5 4.5A1.5 1.5 0 016.5 3H19v15H6.5A1.5 1.5 0 005 19.5zM5 19.5A1.5 1.5 0 006.5 21H19v-3M9 7h6" />,
  estrela: <path d="M12 3.5l2.6 5.4 5.9.8-4.3 4.1 1 5.9L12 16.9l-5.2 2.8 1-5.9-4.3-4.1 5.9-.8z" />,
  ampliar: <path d="M14 4h6v6M10 20H4v-6M20 4l-7 7M4 20l7-7" />,
};

interface Props {
  nome: Nome;
  tamanho?: number;
  className?: string;
}

/** Ícones de traço fino (24×24) que herdam a cor do texto. */
export function Icone({ nome, tamanho = 20, className }: Props) {
  return (
    <svg
      className={className}
      width={tamanho}
      height={tamanho}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.5}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      {TRACOS[nome]}
    </svg>
  );
}
