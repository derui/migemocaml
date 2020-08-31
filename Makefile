.PHONY : doc
doc:
	dune build @doc
	rm -rf doc
	cp -rf _build/default/_doc/_html doc
