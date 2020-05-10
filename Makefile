SUFFIXES += .d

TEX_DEPS := ./tex-deps.pl

ALL_IMAGES := $(wildcard images/Feats/*.svg)
ALL_IMAGE_PDFS = $(subst .svg,.pdf,${ALL_IMAGES})

SOURCES:=$(shell find . -name "*.tex")
DEPFILES:=$(patsubst %.tex,%.tex.d,$(SOURCES))

all: wod-archmodule.pdf

-include $(DEPFILES)

%.pdf_tex: %.svg
	inkscape $< --export-area-page --export-filename=$(subst .pdf_tex,.pdf,$@) --export-latex

%.tex.part: %.tex %.tex.d
	@echo "Analyzing $(subst .part,,$@)"
	@touch $@

%.tex.d: %.tex ${TEX_DEPS}
	@echo "Generate deps for $<"
	@${TEX_DEPS} $< > $@

#%/index.tex: $(wildcard %/prefix.txt) Makefile
#	cat $< > $@
#	find "$(subst index.tex,,$@)" -type d -o \( -iname '*.tex' ! -iname 'index.tex' \) -printf '\input{%p}\n' | sed 's|/$$|/index.tex|' >> $@

wod-archmodule.pdf: wod-archmodule.tex wod-archmodule.tex.part
	lualatex --shell-escape $< < /dev/null
	lualatex --shell-escape $< < /dev/null
