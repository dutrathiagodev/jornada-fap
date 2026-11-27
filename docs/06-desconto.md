# 6. Desconto

> ⚠️ **Os valores abaixo são uma proposta.** O percentual, a validade e as condições precisam ser definidos e aprovados pela FAP (setor financeiro ou de marketing) antes de publicar o jogo.

## 6.1 Proposta de faixas
| Estrelas (de 15) | Desconto sugerido |
|------------------|-------------------|
| Terminou as 5 fases (5 a 9 ★) | 5% |
| 10 a 13 ★ | 10% |
| 14 a 15 ★ | 15% |

- O desconto vale **só para quem termina a Fase 5**.
- Uma pessoa recebe **um cupom**. Jogar de novo pode melhorar a faixa, mas não gera cupons extras.

## 6.2 Como o cupom funciona

### Opção A — Código sem servidor (MVP, mais simples)
1. No fim, o jogo pede **nome e e-mail** (com aceite de privacidade).
2. Gera um código no formato `FAP-26-XXXX-YY`:
   - `XXXX` = 4 letras/números aleatórios.
   - `YY` = faixa de desconto mais um dígito verificador calculado com uma chave.
3. O jogador mostra ou envia o código para a secretaria, que confere o dígito numa planilha ou ferramenta simples.
- **Limitação:** quem souber programar pode tentar gerar códigos. Serve para uma ação de divulgação controlada.

### Opção B — Com servidor (recomendada para uso real)
1. O jogo envia o resultado para um servidor (por exemplo, Supabase grátis ou Google Forms/Planilha).
2. O servidor confere, registra e devolve um código único.
3. A secretaria consulta a lista para validar, e cada código só vale uma vez.
- **Vantagem:** evita fraude e a FAP fica com a lista de interessados (leads).

## 6.3 Privacidade (LGPD)
- Coletar **só o necessário**: nome, e-mail e, opcionalmente, telefone e curso de interesse.
- Mostrar um aviso claro, por exemplo: "Seus dados serão usados pela FAP para entrar em contato sobre o desconto".
- Ter caixa de aceite (não pré-marcada) e link para a política de privacidade da FAP.
- Menores de 18 anos: pedir o e-mail de um responsável, ou deixar o cupom só para resgate presencial.

## 6.4 O que precisa da FAP
- [ ] Percentual de desconto de cada faixa.
- [ ] Em que vale: matrícula, mensalidade, qual curso.
- [ ] Validade do cupom.
- [ ] Opção A ou B (e quem valida o código).
- [ ] Texto de privacidade aprovado.
- [ ] Autorização para usar o logo e o uniforme da Educação Adventista.
