#!/bin/bash
for i in ./images/Feats/*.svg; do
	inkscape -D -z "$i" --export-file="${i/.svg/.pdf}" --export-latex
done
lualatex --shell-escape wod-archmodule.tex
lualatex --shell-escape wod-archmodule.tex
