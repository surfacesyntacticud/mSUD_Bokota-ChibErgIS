# Universal variables
GREW=grew
GRS_CONVERT=/Users/guillaum/github/surfacesyntacticud/tools/converter/grs
UD_TOOLS=/Users/guillaum/github/UniversalDependencies/tools
SUD_TOOLS=/Users/guillaum/github/surfacesyntacticud/tools

# Corpus specific variables
LANG=sab
UD_FOLDER=/Users/guillaum/github/UniversalDependencies/UD_Bokota-ChibErgIS
SUD_FOLDER=/Users/guillaum/github/surfacesyntacticud/DATA/mSUD_Bokota-ChibErgIS/SUD_Bokota-ChibErgIS

doc:
	@echo "make norm     ---> normalise with Grew"
	@echo "make sud      ---> build word-based SUD version"
	@echo "make ud       ---> build the UD conversion"
	@echo "make validate ---> validate the Word-based UD version"

norm:
	for file in partial*.conllu ; do \
		${GREW} transform -i $$file -o tmp ; \
		mv -f tmp $$file ; \
	done

sud:
	mkdir -p ${SUD_FOLDER}
	for infile in *.conllu ; do \
		outfile=${SUD_FOLDER}/$$infile ; \
		echo "$$infile --> $$outfile" ; \
		${GREW} transform -config sud -grs ${SUD_TOOLS}/converter/grs/mSUD_to_SUD.grs -strat mSUD_to_SUD_main -i $$infile -o $$outfile ; \
	done

ud:
	mkdir -p ${UD_FOLDER}/not-to-release
	for infile in *.conllu ; do \
		outfile=${UD_FOLDER}/not-to-release/$$infile ; \
		echo "$$infile --> $$outfile" ; \
		${GREW} transform -config sud -text_from_tokens -grs ${SUD_TOOLS}/converter/grs/sab_SUD_to_UD.grs -strat sab_SUD_to_UD_main -i ${SUD_FOLDER}/$$infile -o $$outfile ; \
	done
	@make build_ud

build_ud:
	echo "# global.columns = ID FORM LEMMA UPOS XPOS FEATS HEAD DEPREL DEPS MISC" > ${UD_FOLDER}/sab_chibergis-ud-test.conllu
	for file in *.conllu ; do \
		cat ${UD_FOLDER}/not-to-release/$$file | grep -v "# global.columns" >> ${UD_FOLDER}/sab_chibergis-ud-test.conllu ; \
	done

validate:
	${UD_TOOLS}/validate.py --max-err=0 --lang=fr ${UD_FOLDER}/sab_chibergis-ud-test.conllu


# ======================================================================================

run:
	for infile in partial*.conllu ; do \
		${GREW} transform -config sud -grs xxx.grs -i $$infile -o tmp ; \
		mv -f tmp $$infile ; \
	done

GE:
	grep GE partial*.conllu | cut -f 10 | tr "|" "\n" | grep GE | sed "s/^GE=//" | sort -u > GE.list

MGloss:
	grep MGloss word_based/partial*.conllu | cut -f 10 | tr "|" "\n" | grep MGloss | sed "s/^GE=//" | sort -u
