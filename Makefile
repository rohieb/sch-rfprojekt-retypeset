# -------- General Definitions -------------------------------------------------
DOCUMENTS = eisen ziehklingen handsägen messer
OUTPUT_PDFS = $(addsuffix .pdf,$(DOCUMENTS))
INPUT_PDFS = $(addsuffix -input.pdf,$(DOCUMENTS))

all: extract preprocess $(OUTPUT_PDFS)

$(foreach d,$(DOCUMENTS), $(eval $(d): $(d)-preprocessed.txt $(d).pdf))

clean:
	rm -rf $(addsuffix -input,$(DOCUMENTS))
mrproper: clean
	rm $(INPUT_PDFS)

#
# -------- Getting the Input Files ---------------------------------------------
#
get: $(INPUT_PDFS)
define input-file =
$(1)-input.pdf:
	wget -O $$@ $(2)
endef
$(eval $(call input-file, eisen, \
	https://www.feinewerkzeuge.de/pdf/schaerf_stech_hob__2023_k1_230109.pdf))
$(eval $(call input-file, ziehklingen, \
	https://www.feinewerkzeuge.de/pdf/schaerfen_ziehklingen_fertig_veroeff_230823.pdf))
$(eval $(call input-file, handsägen, \
	https://www.feinewerkzeuge.de/pdf/schaerf_saeg_2023_k1_230109.pdf))
$(eval $(call input-file, messer, \
	https://www.feinewerkzeuge.de/pdf/Schaerfen_von_Messern_211207.pdf))

#
# -------- Extracting the Input Information ------------------------------------
# 
extract: $(addsuffix -input/text,$(DOCUMENTS)) $(addsuffix -input/images.stamp,$(DOCUMENTS))
%/text: %.pdf
	mkdir -p $$(dirname $@)
	pdftotext $< $@
%/images.stamp: %.pdf
	rm -f $@
	mkdir -p $$(dirname $@)
	pdfimages -png -j $*.pdf $*/image
	touch $@

#
# -------- Preprocessing the Input Text ----------------------------------------
#
preprocess: $(addsuffix -preprocessed.txt,$(DOCUMENTS))

%-preprocessed.txt: %-input/text
	echo TODO: preprocess $@

#
# -------- Leaving the Typesetting to the User ---------------------------------
#
%.markdown:
	@echo
	@echo ----------------------------------------------------------------
	@echo   Please typeset $@ manually, using the preprocessed 
	@echo   input text in $*-input/preprocessed.txt
	@echo   and the extracted images in $*-input/image\*.jpg
	@echo ----------------------------------------------------------------
	@echo

#
# -------- Creating Output Files From The Manually Typeset Documents -----------
#
%.pdf: %.markdown %-input/image*jpg
	pandoc -st latex -o $@ $<
