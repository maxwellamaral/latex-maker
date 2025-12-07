# Cheatsheet LaTeX — atalhos e snippets rápidos

Este cheatsheet traz os comandos e trechos mais comuns e úteis para quem trabalha com LaTeX: estrutura, compilações, figuras, tabelas, equações, referências e dicas práticas.

---

## 1. Estrutura mínima de um documento
```tex
\documentclass[12pt]{article}
\usepackage[utf8]{inputenc} % para pdflatex
% Para XeLaTeX/LuaLaTeX, use fontspec:
% \usepackage{fontspec}
\usepackage{graphicx}
\usepackage{amsmath}
\usepackage{natbib}
\begin{document}
\title{Título}
\author{Nome}
\date{\today}
\maketitle
\section{Introdução}
Texto...
\end{document}
```

---

## 2. Compilação — comandos essenciais
- XeLaTeX (recomendado para fontspec):
```powershell
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 main.tex
bibtex main
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 main.tex
xelatex -interaction=nonstopmode -halt-on-error -synctex=1 main.tex
```
- LuaLaTeX:
```powershell
lualatex -interaction=nonstopmode -halt-on-error -synctex=1 main.tex
bibtex main
lualatex -interaction=nonstopmode -halt-on-error -synctex=1 main.tex
```
- pdflatex (sem fontspec):
```powershell
pdflatex -interaction=nonstopmode -halt-on-error main.tex
bibtex main
pdflatex -interaction=nonstopmode -halt-on-error main.tex
```
- Automatizado com latexmk:
```powershell
latexmk -xelatex -pdf main.tex
latexmk -c   # limpa intermediários
latexmk -C   # limpeza completa (remove PDF)

## 12. Criar novo projeto a partir do template
```powershell
# Gera um novo projeto com estrutura, arquivos e scripts básicos
.\scripts\init-project.ps1 -Name MeuProjeto -Path .
```

## 13. Guardar versão por engine e definir final
```powershell
# Guardar cópia por engine
.\scripts\build.ps1 -engine xelatex -KeepEnginePdf
.\scripts\build.ps1 -engine lualatex -KeepEnginePdf

# Tornar xelatex a versão final
.\scripts\build.ps1 -FinalizeAs xelatex
```
```

---

## 3. Comandos básicos rápidos
- Título, autor: `\title{}`, `\author{}`, `\date{}`
- Seções: `\section{}`, `\subsection{}`, `\subsubsection{}`
- Parágrafos: deixe uma linha em branco para novo parágrafo
- Quebra de linha: `\\` (usar com moderação)
- Texto em negrito/itálico: `\textbf{}`, `\textit{}`, `\emph{}`
- Linha horizontal: `\hrulefill`

---

## 4. Figuras e caminhos
- Definir caminho padrão para figuras no preâmbulo:
```tex
\graphicspath{{figures/}}
```
- Inserir figura:
```tex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.6\linewidth]{fig.png}
  \caption{Legenda}
  \label{fig:example}
\end{figure}
```
- Referência: `\ref{fig:example}` ou `\autoref{fig:example}` (se hyperref)

---

## 5. Tabelas rápidas
```tex
\begin{table}[htbp]
\centering
\caption{Minha tabela}
\label{tab:sample}
\begin{tabular}{|l|c|r|}
\hline
Nome & Idade & Cidade \\
\hline
Alice & 30 & Porto \\
\hline
\end{tabular}
\end{table}
```

---

## 6. Equações (AMS)
- Inline mode: `$E=mc^2$`
- Displayed (numered):
```tex
\begin{equation}
E = mc^2
\end{equation}
```
- Alinhado (sem numeração):
```tex
\begin{align*}
a &= b + c \\
E &= mc^2
\end{align*}
```
- Referenciar equação: `\label{eq:one}` e `\eqref{eq:one}`

---

## 7. Referências bibliográficas (natbib/BibTeX)
- No preâmbulo: `\usepackage{natbib}`
- No texto: `\citep{key}` (parentético) ou `\citet{key}` (narrativo)
- Arquivo: `referencias.bib` com conteúdo BibTeX.
- Comandos de compilação: veja seção Compilação acima.

---

## 8. Código com listings
```tex
\usepackage{listings}
\begin{lstlisting}[language=Python, numbers=left]
def hello():
    print('Olá')
\end{lstlisting}
```

---

## 9. Pacotes úteis
- `geometry` — margens
- `fontspec` — fontes do sistema (XeTeX/LuaTeX)
- `babel` — idioma/documento (pt-BR/portuguese)
- `amsmath` — ferramentas matemáticas
- `graphicx` — inserir imagens
- `hyperref` — links, referências clicáveis
- `biblatex` + `biber` — alternativa moderna ao BibTeX

---

## 10. Erros comuns e correções rápidas
- `fontspec requires XeTeX or LuaTeX` → mude para xelatex/lualatex ou remova fontspec
- `Undefined references/citations` → rode bibtex/biber e recompile 2-3x ou use latexmk
- `File not found` → verifique caminhos (ex.: `figures/...`) e `\graphicspath`
- `Underfull/Overfull (h/v)box` → é aviso de layout; ajustar conteúdo ou usar `\raggedbottom` / `\raggedright`

---

## 11. Dicas de produtividade
- Use `latexmk` para automação. Adicione `latexmkrc` para customizar flags.
- Use `latexindent` para formatar arquivos LaTeX.
- `\includeonly{}` para compilar partes do documento (capítulos) rapidamente.
- Mantenha macros e configurações no `preamble.tex` em `styles/` para equipes.
- Use `\graphicspath{{figures/}}` para centralizar figuras.

---

## Mais recursos
- Tutoriais: TeX Stack Exchange, Overleaf documentation, TeX Live docs.
- Ferramentas: Texmaker, TeXstudio, VS Code + LaTeX Workshop.
