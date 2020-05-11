mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

SUFFIXES += .d

TEX_DEPS := ${current_dir}/tex-deps.pl

ALL_IMAGES := $(wildcard images/Feats/*.svg)
ALL_IMAGE_PDFS = $(subst .svg,.pdf,${ALL_IMAGES})

SOURCES:=$(shell find . -type f -name "*.tex" ! -iname 'index.tex')
INDICES:=$(shell find . -type d -name "*.tex")
DEPFILES:=$(patsubst %.tex,%.tex.d,$(SOURCES)) $(patsubst %.tex,%.tex/index.tex.d,$(INDICES))
NODEPS := clean

clean:
	find . \( -iname '*.part' -o -iname '*.d' -o -iname '*.pdf*' -o -iname '*.deps' -o -iname 'index.tex' \) -delete

ifeq (0, $(words $(findstring $(MAKECMDGOALS), $(NODEPS))))
-include ${DEPFILES}
# 	-include $(DEPFILES)
endif

%.pdf_tex: %.svg
	@inkscape $< --export-area-page --export-filename=$(subst .pdf_tex,.pdf,$@) --export-latex

%.tex.part: %.tex.d
	@echo "Analyzing $@: requires $<"
	@touch "$@"

%.tex.d: %.tex ${TEX_DEPS}
	@echo "Generate deps for $<"
	@${TEX_DEPS} "$@" "$<"

%/index.tex: .FORCE
	@echo "Generating index $@"
	@{ \
	  find "./$(subst index.tex,,$@)" -mindepth 1 -maxdepth 1 -iname '*.tex' -type d -printf '\\input{%p/index.tex}\n' ;\
	  find "./$(subst index.tex,,$@)" -mindepth 1 -maxdepth 1 -iname '*.tex' -type f ! -iname 'index.tex' -printf '\\input{%p}\n' ;\
	} | sed 's|\./||g' | sort > "$@.new"
	cmp -s "$@" "$@.new" || mv -f "$@.new" "$@"
	rm "$@.new"
# 	@find * -name '*.tex' -print0 | xargs -0 $(TEX_DEPS) Makefile.deps
# 	@${MAKE} Makefile.deps

# || ( cat $(subst pdf,log,$@) && false )

%.pdf: %.tex.part
	lualatex --shell-escape $(subst .part,,$<) < /dev/null > /dev/null
	lualatex --shell-escape $(subst .part,,$<) < /dev/null

.PHONY: .FORCE
.FORCE:
