.PHONY: test check

build:
	dune build

bisect: bisect-clean
	-dune exec --instrument-with bisect_ppx --force test/main.exe
	bisect-ppx-report html

bisect-clean:
	rm -rf _coverage bisect*.coverage
	
code:
	-dune build
	code .
	! dune build --watch

install:
	opam install -y utop ounit2 ocamlformat ANSITerminal bisect

utop:
	OCAMLRUNPARAM=b dune utop src

processor:
	dune clean
	OCAMLRUNPARAM=b dune exec bin/system.exe

test:
	# OCAMLRUNPARAM=b dune exec test/main.exe
	OCAMLRUNPARAM=b dune exec --instrument-with bisect_ppx test/main.exe

clean:
	dune clean
	rm bisect*
	rm -f risc_v_processor_generator.zip

check:
	@bash check.sh

doc:
	dune build @doc

finalcheck:
	@bash check.sh final

opendoc: doc
	@bash opendoc.sh

zip:
	rm -f risc_v_processor_generator.zip
	zip -r risc_v_processor_generator.zip . -x@exclude.lst




