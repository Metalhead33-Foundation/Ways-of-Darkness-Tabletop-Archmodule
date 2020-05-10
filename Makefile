ALL_IMAGES := $(wildcard images/Feats/*.svg)
ALL_IMAGE_PDFS = $(subst .svg,.pdf,${ALL_IMAGES})

all: wod-archmodule.pdf

%.pdf: %.svg
	inkscape $< --export-area-page --export-filename=$@ --export-latex

wod-archmodule.pdf: wod-archmodule.tex ${ALL_IMAGE_PDFS}
	lualatex --shell-escape $<
	lualatex --shell-escape $<
