# Simple Makefile for Unix-like environments. On Windows, use build.ps1 or latexmk directly.
TEX = exemplo.tex
PDF = $(TEX:.tex=.pdf)
LATEXMK = latexmk
LATEXMK_FLAGS = -xelatex -pdf

all: $(PDF)

$(PDF): $(TEX)
	$(LATEXMK) $(LATEXMK_FLAGS) $(TEX)

clean:
ifdef SYSTEMROOT
	powershell -ExecutionPolicy Bypass -File scripts/clean.ps1 -Full -Force || latexmk -C
else
	latexmk -C
endif
	@rm -f *.synctex.gz

clean-light:
ifdef SYSTEMROOT
	powershell -ExecutionPolicy Bypass -File scripts/clean.ps1 -Force || latexmk -c
else
	latexmk -c
endif
