.PHONY : doc
doc:
	dune build @doc
	rm -rf docs
	cp -rf _build/default/_doc/_html docs
