TEX_FILES := $(wildcard *.tex)
PDF_FILES := $(TEX_FILES:.tex=.pdf)

all: $(PDF_FILES)

%.pdf: %.tex
	pdflatex $<

clean:
	rm -f *.aux *.bbl *.blg *.cut *.dvi *.log *.out *.synctex.gz *.pdf *.fdb_latexmk *.fls *.toc *.nav *.snm *.vrb