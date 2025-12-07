# Guia de uso — Exemplo LaTeX

Este README explica como utilizar o arquivo `exemplo.tex` e como compilar seu projeto LaTeX; também traz dicas práticas para solucionar problemas comuns. O guia foi preparado com base no conteúdo do arquivo `exemplo.tex` presente nesta pasta.

---

## ✅ O que há neste projeto
- `exemplo.tex` — documento de exemplo com preâmbulo e conteúdo de artigo.
- `referencias.bib` — arquivo BibTeX com referência de exemplo.
- `inovacao.jpeg` — imagem usada no documento.
- `exemplo.tex` — documento principal (entry point) para compilar. Use `\input{styles/preamble}` para carregar preâmbulo e `\input{chapters/XX}` para capítulos.
 - `chapters/` — pasta com arquivos de capítulos (ex.: `01-intro.tex`).
 - `bib/referencias.bib` — arquivo BibTeX com referência de exemplo.
 - `figures/inovacao.jpeg` — imagem usada no documento.
- `exemplo.pdf` — saída (quando compilado com sucesso).
- `missfont.log` — log que lista tentativas de geração de métricas de fontes que não foram encontradas.

---

## 🚩 Principais dependências e pacotes no preâmbulo
O `exemplo.tex` usa os seguintes pacotes importantes:
- `fontspec` — seleção de fontes com XeLaTeX/LuaLaTeX (usa fontes do sistema). Requer XeTeX ou LuaTeX, **não** funciona com pdflatex.
- `graphicx` — inclusão de imagens (png, jpeg, pdf, etc.).
- `natbib` — gerenciamento de citações estilo `plainnat` (com BibTeX). Use `biblatex` se preferir `biber`.
- `amsmath` — fórmulas matemáticas.
- `listings` — destaques para códigos-fonte.
- `setspace`, `geometry`, `titlesec`, `enumitem`, `multicol` — controle de espaçamento, margens, títulos, listas e colunas.

No preâmbulo do `exemplo.tex` há também:
- `\setmainfont{Times New Roman}` — define a fonte principal (sistema).
- `\IfFontExistsTF{Inconsolata}{\setmonofont{Inconsolata}}{\setmonofont{Consolas}}` — fallback condicional para a fonte mono. Isso evita abortos se Inconsolata não estiver instalada.

---

## 🧭 Como compilar (recomendações)
### Recomendado: XeLaTeX (compila usando fontes do sistema)
Abra o terminal (PowerShell) na pasta do projeto e rode:

```powershell
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
bibtex exemplo
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
```

- 1ª execução: gera `.aux` e tabelas de conteúdo.
- `bibtex`: gera o `.bbl` a partir de `referencias.bib`.
- 2ª e 3ª execuções: resolvem citações e referências internas.

Alternativa automática (latexmk):

```powershell
latexmk -xelatex -pdf exemplo.tex
```

### Scripts e automação incluídos neste projeto
O repositório contém arquivos para facilitar a compilação automática e limpa:

- `latexmkrc` — configuração do latexmk para usar XeLaTeX por padrão, com flags seguras.
  (Nota: não forçamos `pdflatex` para `xelatex` no arquivo de configuração; o `build.ps1` respeita o engine selecionado pelo usuário.)
- `build.ps1` — script PowerShell para compilar o projeto com latexmk (XeLaTeX) e opcionais `-clean` ou `-bib`.
- `Makefile` — para usuários Unix-like (ou Windows com make), invoca `latexmk -xelatex -pdf`.
 - `scripts/` — scripts de build, ex.: `scripts/build.ps1` e `scripts/Makefile`.

### Organização de capítulos
Adicione novos capítulos em `chapters/` e inclua-os no documento principal com `\input{chapters/02-methods.tex}`.

Exemplo de arquivo `exemplo.tex` (already present):
```tex
\input{styles/preamble.tex}
\begin{document}
\input{chapters/01-intro.tex}
\input{chapters/02-methods.tex}
\end{document}
```

Exemplo de uso no PowerShell (executar a partir da pasta do projeto):

```powershell
# Compilar com `build.ps1` (escolha de engine)
.\scripts\build.ps1 # usa XeLaTeX por padrão
.\scripts\build.ps1 -engine xelatex
.\scripts\build.ps1 -engine lualatex
.\scripts\build.ps1 -engine pdflatex -Force # use -Force para ignorar checagem de fontspec

# Limpar arquivos intermediários (preserva PDF)
.\scripts\build.ps1 -clean  # full clean (remove PDF)
.\scripts\build.ps1 -light  # light clean (keep PDF)

# Limpar com o script específico (PowerShell)
.\scripts\clean.ps1   # pede confirmação, remove arquivos intermediários
.\scripts\clean.ps1 -Full  # limpeza completa (incluindo PDF)

# Limpeza completa (remove PDF e todos os arquivos gerados por LaTeX/latexmk)
latexmk -C
```

Opcional: guardar versões de PDF por engine e definir qual versão será o `exemplo.pdf` canônico:

```powershell
# Gerar exemplo.xelatex.pdf e também exemplo.pdf
.\scripts\build.ps1 -engine xelatex -KeepEnginePdf

# Gerar exemplo.lualatex.pdf e também exemplo.pdf
.\scripts\build.ps1 -engine lualatex -KeepEnginePdf

# Manter o exemplo.xelatex.pdf como versão final (copiando-o para exemplo.pdf)
.\scripts\build.ps1 -FinalizeAs xelatex
```

Exemplo de uso com Make (Unix-like ou ambiente com GNU Make):

```bash
make
make clean
```

### Outra opção (LuaLaTeX)
Se preferir LuaLaTeX:

```powershell
lualatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
bibtex exemplo
lualatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
lualatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
```

### Se for preciso usar pdflatex (sem `fontspec`)
- Remova `\usepackage{fontspec}` e use:
  ```tex
  \usepackage[T1]{fontenc}
  \usepackage[utf8]{inputenc} % só se usar pdflatex
  \usepackage{lmodern} % fonte compatível com pdflatex
  ```
- Compile com:
  ```powershell
  pdflatex -interaction=nonstopmode -halt-on-error exemplo.tex
  bibtex exemplo
  pdflatex -interaction=nonstopmode -halt-on-error exemplo.tex
  pdflatex -interaction=nonstopmode -halt-on-error exemplo.tex
  ```
  Observação: com pdflatex você perde suporte a fontes do sistema via `fontspec`.

---

## 🛠️ Erros e avisos comuns (resumo e soluções)
- "Fatal Package fontspec Error: The fontspec package requires either XeTeX or LuaTeX."  
  *Causa:* você está rodando pdflatex com `fontspec` no documento.  
  *Solução:* compile com XeLaTeX ou LuaLaTeX; ou remova `fontspec` e use `fontenc + inputenc + lmodern` para pdflatex.

- "The font 'Inconsolata' cannot be found" ou mensagens de `mktextfm` no log/`missfont.log`.  
  *Causa:* a fonte especificada não está instalada no sistema.  
  *Soluções:* 
  - Instale a fonte (por exemplo Inconsolata) no Windows (abrir o .ttf/.otf e instalar). 
  - Use `
    \IfFontExistsTF{Inconsolata}{\setmonofont{Inconsolata}}{\setmonofont{Consolas}}` 
    para fallback (já configurado no `exemplo.tex`). 
  - Para evitar mktextfm, use fontes que existam ou instaladas corretamente.

- "Underfull \vbox (badness 10000)"  
  *Causa:* LaTeX não consegue preencher verticalmente uma caixa (ex.: colunas, espaço vertical grande).  
  *Solução:* reorganize o conteúdo, adicione `\vfill`/`\raggedbottom` ou ajuste o layout (margens ou `
  \onecolumn/\twocolumn` control), ou use `\flushbottom`/`\raggedbottom` dependendo do efeito desejado.

- "Undefined references / citations"  
  *Causa:* normalmente porque BibTeX/Biber não foi executado, ou a compilação de múltiplas vezes não foi feita.  
  *Solução:* rode `bibtex` (ou `biber` se estiver usando `biblatex`) e compile o documento 2x/3x novamente; ou use `latexmk` que automatiza isto.

- "File `nome` not found"  
  *Causa:* imagem/fonte/arquivo ausente.  
  *Solução:* verifique se os arquivos (ex: `inovacao.jpeg`) estão na mesma pasta ou corrija o caminho no \includegraphics.

---

## 🧾 Estrutura e trechos úteis do `exemplo.tex`
- Cabeçalho/Document Class: `\documentclass[12pt, a4paper, twoside]{article}`
- Fontes com `fontspec` (XeLaTeX/LuaLaTeX):
  ```tex
  \usepackage{fontspec}
  \setmainfont{Times New Roman}
  \IfFontExistsTF{Inconsolata}{\setmonofont{Inconsolata}}{\setmonofont{Consolas}}
  ```
- Inclusão de imagens:
  ```tex
  \usepackage{graphicx}
  \includegraphics[width=0.5\linewidth]{inovacao.jpeg}
  ```
- Bibliografia com natbib e BibTeX:
  ```tex
  \usepackage{natbib}
  \bibliographystyle{plainnat}
  \bibliography{referencias}
  ```
- Listagens (código):
  ```tex
  \usepackage{listings}
  \begin{lstlisting}[language=Python]
  def fibonacci(n):
      a, b = 0, 1
      ...
  \end{lstlisting}
  ```
- Multicolunas:
  ```tex
  \usepackage{multicol}
  \begin{multicols}{2}
  ...
  \end{multicols}
  ```

---

## 🧭 Dicas de edição e automação
- Para compilar automaticamente sempre com XeLaTeX e BibTeX, use o `latexmk` com `-xelatex`:
  ```powershell
  # Use the engine of your choice; default is XeLaTeX, but you can also pass -lualatex or -pdflatex if needed
  latexmk -xelatex -pdf exemplo.tex
  latexmk -lualatex -pdf exemplo.tex
  latexmk -pdf -pdflatex exemplo.tex
  ```
ou

    ```powershell
    bibtex exemplo; xelatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex; xelatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex  
    ```

- No VS Code (com LaTeX Workshop): defina o "recipe" / engine para `xelatex`/`lualatex` nas configurações.
- Para gerenciar ref`erências automaticamente prefira `biblatex` + `biber` se precisar de estilos de citação mais modernos e maior controle.

### Criar um novo projeto a partir deste template
Você pode gerar um novo projeto com a estrutura adotada automaticamente usando o script abaixo:

```powershell
.\scripts\init-project.ps1 -Name MeuProjeto
```
Você pode também escolher o engine padrão do projeto ao criar com `-DefaultEngine`:

```powershell
.\scripts\init-project.ps1 -Name MeuProjeto -DefaultEngine lualatex
```

Use `-Path <caminho>` para criar o projeto em outro local, e `-Force` para sobrescrever se o diretório já existir.

### Limpeza e arquivos removidos
- `latexmk -c` (ou `.uild.ps1 -clean`) — remove arquivos intermediários como: `aux`, `bbl`, `blg`, `log`, `lof`, `lot`, `lol`, `out`, `toc`, `fls`, `fdb_latexmk`, `synctex.gz`, `run.xml`, `nav`, `snm`, `vrb`.
- `latexmk -C` — limpeza completa: remove todos os arquivos listados acima **e** o `exemplo.pdf` gerado.

Observação: o comportamento exato de limpeza pode variar de acordo com arquivos adicionais (por exemplo `biber`/`bbl`), e as entradas estão configuradas em `latexmkrc`.

---

## 💡 Observações finais
- O exemplo está pronto para ser editado: altere o conteúdo textual, adicione mais citações à `referencias.bib`, substitua imagens e teste variações de fontes.

Veja também: `GUIDE.md` — guia detalhado com organização, build, CI e boas práticas.
Veja também: `CHEATSHEET.md` — referência rápida com snippets e comandos úteis.

Diga o que prefere e eu faço os próximos ajustes.