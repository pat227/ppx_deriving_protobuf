build:
	cp pkg/META.in pkg/META
	ocaml pkg/build.ml native=true native-dynlink=true

test: build
	rm _build/src_test/ -rf
	ocamlbuild -classic-display -use-ocamlfind src_test/test_ppx_protobuf.byte --

doc:
	ocamlbuild -use-ocamlfind doc/api.docdir/index.html \
						 -docflags -t -docflag "API reference for ppx_protobuf" \
						 -docflags '-colorize-code -short-functors -charset utf-8' \
						 -docflags '-css-style style.css'
	cp doc/style.css api.docdir/

clean:
	ocamlbuild -clean

.PHONY: build test doc clean

gh-pages: doc
	git clone `git config --get remote.origin.url` .gh-pages --reference .
	git -C .gh-pages checkout --orphan gh-pages
	git -C .gh-pages reset
	git -C .gh-pages clean -dxf
	cp -t .gh-pages/ api.docdir/*
	git -C .gh-pages add .
	git -C .gh-pages commit -m "Update Pages"
	git -C .gh-pages push origin gh-pages -f
	rm -rf .gh-pages

VERSION      := $$(opam query --version)
NAME_VERSION := $$(opam query --name-version)
ARCHIVE      := $$(opam query --archive)

release:
	git tag -a v$(VERSION) -m "Version $(VERSION)."
	git push origin v$(VERSION)
	opam publish prepare $(NAME_VERSION) $(ARCHIVE)
	opam publish submit $(NAME_VERSION)
	rm -rf $(NAME_VERSION)

.PHONY: gh-pages release
