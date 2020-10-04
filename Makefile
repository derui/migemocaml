.PHONY : doc dict dat clean-dict
doc:
	dune build @doc
	rm -rf docs
	cp -rf _build/default/_doc/_html docs

SKK_JISYO_URL=https://skk-dev.github.io/dict/SKK-JISYO.L.gz
DICT_DIR=dict
SKK_JISYO_FILE=${DICT_DIR}/SKK-JISYO.L

${SKK_JISYO_FILE}:
	mkdir -p ${DICT_DIR}
	curl -L -o ${SKK_JISYO_FILE}.gz ${SKK_JISYO_URL}
	gunzip ${SKK_JISYO_FILE}.gz

dict: ${SKK_JISYO_FILE} dat
	dune build
	mkdir -p ${DICT_DIR}
	./_build/install/default/bin/skk_to_migemo ${SKK_JISYO_FILE} > ${DICT_DIR}/tmp-dict
	./_build/install/default/bin/optimize_dict ${DICT_DIR}/tmp-dict > ${DICT_DIR}/migemo-dict
	rm -f ${DICT_DIR}/tmp-dict

${DICT_DIR}/cmigemo:
	git clone --depth 1 https://github.com/koron/cmigemo ${DICT_DIR}/cmigemo

dat-files: ${DICT_DIR}/roma2hira.dat ${DICT_DIR}/hira2kata.dat ${DICT_DIR}/zen2han.dat ${DICT_DIR}/han2zen.dat

dat: ${DICT_DIR}/cmigemo dat-files

${DICT_DIR}/roma2hira.dat: dict/cmigemo
	./_build/install/default/bin/sjis_to_utf8 dict/cmigemo/dict/roma2hira.dat > $@
${DICT_DIR}/hira2kata.dat: dict/cmigemo
	./_build/install/default/bin/sjis_to_utf8 dict/cmigemo/dict/hira2kata.dat > $@
${DICT_DIR}/zen2han.dat: dict/cmigemo
	./_build/install/default/bin/sjis_to_utf8 dict/cmigemo/dict/zen2han.dat > $@
${DICT_DIR}/han2zen.dat: dict/cmigemo
	./_build/install/default/bin/sjis_to_utf8 dict/cmigemo/dict/han2zen.dat > $@

clean-dict:
	rm -rf ${DICT_DIR}
