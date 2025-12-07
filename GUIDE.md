# Guia do Projeto LaTeX — Estrutura, Build e Boas Práticas

Este guia documenta a organização recomendada, como compilar o projeto, solução de problemas comuns e boas práticas para manter seu projeto LaTeX reprodutível e colaborativo.

---

## Sumário
- Estrutura de diretórios recomendada
- Como compilar (XeLaTeX / LuaLaTeX / pdflatex)
- Scripts e automação (latexmk, scripts/)
- Limpeza (latexmk -c / latexmk -C)
- Integração Contínua (exemplo GitHub Actions)
- Boas práticas de versionamento e .gitignore
- Dicas de troubleshooting e ferramentas úteis

---

## 1. Estrutura de diretórios recomendada

Abaixo há duas sugestões, a mínima e a ideal para projetos maiores.

### Projeto mínimo (suficiente para um artigo curto)
```
/my-paper
├─ exemplo.tex
├─ bib/referencias.bib
├─ figures/
│  ├─ inovacao.jpeg
├─ latexmkrc
├─ scripts/
│  └─ build.ps1
├─ README.md
└─ GUIDE.md
```

### Projeto com modularização (tese / livro)
```
/my-thesis
├─ README.md
├─ GUIDE.md
├─ latexmkrc
├─ scripts/
│  ├─ build.ps1
│  └─ Makefile
├─ styles/
│  └─ preamble.tex
├─ chapters/
│  ├─ 01-intro.tex
│  └─ 02-methods.tex
├─ figures/
│  ├─ plots/
│  └─ photos/
├─ bib/
│  └─ referencias.bib
├─ tables/
├─ build/           # opcional para saída separada
└─ .gitignore
```

Racional: separar preâmbulo, capítulos, figuras e referências facilita o trabalho em equipe, facilita compilação por capítulo e mantém o repositório limpo.

---

## 2. Como compilar

### Recomendado: XeLaTeX (suporta fontspec e fontes do sistema)
Comandos manuais (PowerShell):
```powershell
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
bibtex exemplo
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
```

### Alternativa automática (latexmk) — recomendado
```powershell
latexmk -xelatex -pdf exemplo.tex
```

### LuaLaTeX (se preferir):
```powershell
lualatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
bibtex exemplo
lualatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
lualatex -interaction=nonstopmode -halt-on-error -synctex=1 exemplo.tex
```

### pdflatex (quando não usar `fontspec`)
Remova `\usepackage{fontspec}` e adicione:
```tex
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{lmodern}
```
Em seguida, compile com pdflatex/bibtex:
```powershell
pdflatex -interaction=nonstopmode -halt-on-error exemplo.tex
bibtex exemplo
pdflatex -interaction=nonstopmode -halt-on-error exemplo.tex
pdflatex -interaction=nonstopmode -halt-on-error exemplo.tex
```

---

## 3. Automação e scripts

Arquivos incluídos no projeto:
- `latexmkrc` — configurações do `latexmk` (neste repositório, já configurado para forçar XeLaTeX).
- `scripts/build.ps1` — script PowerShell que executa a rotina do `latexmk` com `-xelatex -pdf`. Também aceita `-clean` para limpeza leve.
- `scripts/Makefile` — versão para ambientes Unix-like.

Exemplo (PowerShell):
```powershell
# Compilar
.\scripts\build.ps1
# Limpar intermediários (light): preserva o PDF
.\scripts\build.ps1 -light
# Limpar (full): remove o PDF
.\scripts\build.ps1 -clean
```

Opcionalmente, você pode manter cópias por engine e/ou definir qual engine terá a versão final `pdf`:

```powershell
# Gerar `MeuProjeto.xelatex.pdf` além de `MeuProjeto.pdf`
.\scripts\build.ps1 -engine xelatex -KeepEnginePdf

# Gerar `MeuProjeto.lualatex.pdf` além de `MeuProjeto.pdf`
.\scripts\build.ps1 -engine lualatex -KeepEnginePdf

# Usar a versão `MeuProjeto.xelatex.pdf` como final (copia para `MeuProjeto.pdf`)
.\scripts\build.ps1 -FinalizeAs xelatex
```

### Criar um novo projeto com a estrutura do template
Você pode criar um projeto com a mesma estrutura deste template usando o script `init-project.ps1`:

```powershell
.\scripts\init-project.ps1 -Name MeuProjeto -Path . -Force
```

Você também pode passar o engine padrão do projeto usando `-DefaultEngine` ao criar o projeto:

```powershell
.\scripts\init-project.ps1 -Name MeuProjeto -DefaultEngine lualatex
```

O comando criará a estrutura de pastas e arquivos em `./MeuProjeto`. Passe `-Path <caminho>` para especificar outra pasta de destino e `-Force` para sobrescrever.

---

## 4. Limpeza (disponível em latexmk)
- `latexmk -c` — limpa arquivos intermediários (aux, log, bbl etc.) e preserva o PDF.
- `latexmk -C` — limpa todos os arquivos gerados, inclusive o `pdf`.

Arquivos de limpeza comuns (ver `latexmkrc`):
```
aux, bbl, blg, brf, idx, ind, ilg, lof, lot, lol, out, toc, synctex.gz, fdb_latexmk, fls, run.xml, nav, snm, vrb, pdf
```

---

## 5. Integração Contínua (CI) - Exemplo GitHub Actions
Exemplo simples para compilar com TeX Live e salvar o PDF como artefato:
```yaml
name: build
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Install TeX Live (minimal)
        run: sudo apt-get update && sudo apt-get install -y texlive-full latexmk
      - name: Build PDF (XeLaTeX)
        run: latexmk -xelatex -pdf -quiet exemplo.tex
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: exemplo.pdf
          path: exemplo.pdf
```

Observação: instalar `texlive-full` consome muito espaço; em CI prefira builds mais seletivos (ou imagens Docker prontas com TeX Live).

Alternativa baseada em Docker:
```bash
docker run --rm -it -v $(pwd):/work -w /work blang/latex:ctanfull latexmk -xelatex -pdf exemplo.tex
```

---

## 6. Boas práticas de versionamento
- Versionar apenas fonte (`.tex`, `.sty`, `.cls`), `bib` e figuras originais (png/jpg/pdf/svg). Evite commitar artefatos gerados (aux, log, pdf). Defina `.gitignore` (ex.: no projeto há `.gitignore` com entradas padrão).
- Nomes de arquivos: use `kebab-case` ou `snake_case` (ex.: `chapters/01-intro.tex`).
- Documente macros e pacotes usados no `preamble.tex` ou `styles/`.
- Use `egin{document}` / `egin{document}` apenas no `main.tex` — arquivos de capítulo devem conter somente conteúdo.

---

## 7. Troubleshooting: erros comuns e como resolver
- "Fatal Package fontspec Error: The fontspec package requires either XeTeX or LuaTeX."  
  *Causa:* compilando com pdflatex.  
  *Solução:* mude a engine para XeLaTeX/LuaLaTeX ou remova `fontspec`.

- "The font 'Inconsolata' cannot be found" ou `mktextfm` log:  
  *Causa:* a fonte não está instalada no sistema.  
  *Solução:* instale a fonte no SO (Windows: clicar no .ttf/.otf e "Instalar") ou use fallback com `\IfFontExistsTF`.

- "Undefined references / citations":  
  *Causa:* faltou executar BibTeX/Biber ou múltiplas execuções.  
  *Solução:* rode BibTeX/Biber e compile 2x/3x ou use `latexmk`.

- "Underfull/Overfull \vbox/hbox":  
  *Causa:* problemas de layout (colunas, espaçamento).  
  *Solução:* ajustar texto, margens, `\vfill`/`\raggedbottom`, ou dividir o parágrafo/colunas.

- Arquivos não encontrados (`File 'name' not found`):  
  *Causa:* caminho incorreto ou arquivo ausente.  
  *Solução:* corrija o caminho relativo e verifique `\graphicspath`.

---

## 8. Ferramentas úteis
- `latexmk` — automatiza builds (recomendado).
- `latexindent` — formata o código LaTeX.
- `chktex` — lint para LaTeX.
- `biber`/`biblatex` — alternativa moderna para gerenciar bibliografia.
- Imagem vetorial preferida: PDF/SVG; raster para fotos (JPG/PNG).

---

## 9. Ações recomendadas para este repositório
- Mantenha `preamble.tex` e `styles/` para sincronização entre autores.
- Use `latexmk` para builds locais e configurar CI conforme o exemplo.
- Considere `biber` + `biblatex` para projetos com exigência de estilos de citação variados.

---

## Tutorial para iniciantes: primeiro documento LaTeX

Este tutorial passo a passo é para quem está começando com LaTeX. Ele cobre instalação, criar seu primeiro documento, compilar, adicionar figura e bibliografia.

### 1) Instalar um conjunto LaTeX
- Windows: instale TeX Live (https://tug.org/texlive/) ou MikTeX (https://miktex.org/). Eu recomendo TeX Live para maior compatibilidade.
- Linux: use o gerenciador de pacotes da sua distribuição (ex.: `sudo apt install texlive-full` no Ubuntu; para um install menor use `texlive-latex-recommended texlive-xetex latexmk`).
- macOS: use MacTeX (https://tug.org/mactex/).

### 2) Editor recomendado
- Visual Studio Code com extensão LaTeX Workshop (configurar receita para `xelatex`/`lualatex` via `latex-workshop.latex.tools`/`recipes`).
- TeXstudio, Overleaf (online) ou TeXmaker também são boas alternativas.

### 3) Criar um projeto mínimo
Crie uma pasta (ex.: `my-first-latex`) e dentro crie `main.tex` com o conteúdo a seguir:

```tex
% main.tex - documento mínimo
\documentclass[12pt]{article}
\usepackage[utf8]{inputenc} % apenas para pdflatex
% Para XeLaTeX/LuaLaTeX, use fontspec e remova inputenc
% \usepackage{fontspec}
\usepackage{graphicx}
\usepackage{amsmath}
\usepackage{natbib}

	itle{Meu primeiro documento LaTeX}
\author{Seu Nome}
\date{\today}

\begin{document}
\maketitle

\section{Introdução}
Olá, mundo! Este é um documento simples.

\section{Equação}
Exemplo de equação:
\begin{equation}
E = mc^2
\end{equation}

\section{Figura}
\begin{figure}[h!]
  \centering
  \includegraphics[width=0.5\linewidth]{figures/inovacao.jpeg}
  \caption{Exemplo}
  \label{fig:ex}
\end{figure}

\bibliographystyle{plainnat}
\bibliography{bib/referencias}

\end{document}
```

Crie também um `bib/referencias.bib` com pelo menos uma referência de teste:

```bibtex
@article{Einstein1905,
  author = {Albert Einstein},
  title = {Does the Inertia of a Body Depend Upon Its Energy-Content?},
  journal = {Annalen der Physik},
  volume = {18},
  number = {13},
  pages = {639--641},
  year = {1905}
}
```

Adicione uma figura de demonstração em `figures/inovacao.jpeg` (ou altere o nome no código).

### 4) Compilar o documento
Recomendado (usar `xelatex` para habilitar `fontspec`):

```powershell
# Executar no PowerShell na pasta do projeto
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 main.tex
bibtex main
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 main.tex
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 main.tex
```

Ou (automatizado) com `latexmk`:

```powershell
latexmk -xelatex -pdf main.tex
```

### 5) Compreender mensagens comuns
- Erro `fontspec`: você está usando `fontspec` com `pdflatex`. Mude para `xelatex` ou `lualatex` ou remova o pacote.
- `Undefined citations`: execute `bibtex` (ou `biber`) e rode o compilador novamente.
- `File '...not found'`: verifique caminhos (ex.: `figures/inovacao.jpeg`) e verifique o `\graphicspath` se usado.

### 6) Adicionar seções e capítulos
- Comece com `\section{}`, `\subsection{}` e `\subsubsection{}`.
- Para documentos maiores, modularize: crie `chapters/` e `\input{chapters/02-methods.tex}` no `main.tex`.

### 7) Dicas de produtividade
- Use `latexmk -pv` enquanto edita para abrir PDF automaticamente após cada build.
- Use `\includeonly{}` quando trabalhar em capítulos grandes para acelerar builds.
- Configure o LaTeX Workshop (VS Code) para `xelatex`/`lualatex` e `latexmk` como _recipe_.

Veja também: `CHEATSHEET.md` — referência rápida com os comandos e snippets mais usados em LaTeX.

### Clean scripts
You can use `scripts/clean.ps1` to remove intermediate files created by LaTeX. It attempts to use `latexmk -c`/`latexmk -C` when available and falls back to deleting common-file globs if not.

Examples:
```powershell
# light clean (preserves PDF)
.\scripts\clean.ps1

# full clean (removes PDFs)
.\scripts\clean.ps1 -Full

# force (no confirmation)
.\scripts\clean.ps1 -Full -Force
```
