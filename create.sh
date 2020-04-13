#!/bin/bash
function cpstamp () {
local src_file="$1"
local dst_file="$2"
#touch "$dst_file" -r "$src_file"
touch -d @$(stat -c "%Y" "$src_file") "$dst_file"
}
for i in ./images/Feats/*.svg; do
	if [[ ! -f "${i/.svg/.pdf}" || "$i" -nt "${i/.svg/.pdf}" ]] ; then
	inkscape -D -z "$i" --export-area-page --export-file="${i/.svg/.pdf}" --export-latex
	cpstamp "$i" "${i/.svg/.pdf}"
	cpstamp "$i" "${i/.svg/.pdf_tex}"
	fi
done
lualatex --shell-escape wod-archmodule.tex
lualatex --shell-escape wod-archmodule.tex
