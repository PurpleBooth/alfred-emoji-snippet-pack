.DEFAULT_GOAL := show-help
THIS_FILE := $(lastword $(MAKEFILE_LIST))
ROOT_DIR:=$(shell dirname $(realpath $(THIS_FILE)))

.PHONY: show-help
# See <https://gist.github.com/klmr/575726c7e05d8780505a> for explanation.
## This help screen
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)";echo;sed -ne"/^## /{h;s/.*//;:d" -e"H;n;s/^## //;td" -e"s/:.*//;G;s/\\n## /---/;s/\\n/ /g;p;}" ${MAKEFILE_LIST}|LC_ALL='C' sort -f|awk -F --- -v n=$$(tput cols) -v i=29 -v a="$$(tput setaf 6)" -v z="$$(tput sgr0)" '{printf"%s%*s%s ",a,-i,$$1,z;m=split($$2,w," ");l=n-i;for(j=1;j<=m;j++){l-=length(w[j])+1;if(l<= 0){l=n-i-length(w[j])-1;printf"\n%*s ",-i," ";}printf"%s ",w[j];}printf"\n";}'

build/html/out.html:
	mkdir -p build/html
	curl "https://unicode.org/emoji/charts/full-emoji-list.html" -o build/html/out.html

build/normalised-html/out.html: build/html/out.html
	mkdir -p build/normalised-html
	hxnormalize -l 240 -x "build/html/out.html" > build/normalised-html/out.html

build/json: build/normalised-html/out.html
	rm -rf build/json
	mkdir -p build/json
	# Ignoring failures so new Unicode emoji don't break everything
	-hxselect -s '\0' 'tr' < "build/normalised-html/out.html" | xargs -n1 -0 bin/fragment-to-json

build/Emoji.alfredsnippets: build/json
	zip -r -j build/Emoji.alfredsnippets build/json/ icon.png

.PHONY: build
## Build the Emoji Pack
build: build/Emoji.alfredsnippets

.PHONY: clean
## Clean the build directory
clean:
	rm -rf build/