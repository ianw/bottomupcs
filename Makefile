# XML sources
sourcedirs=input/chapter00 input/chapter01 input/chapter02 input/chapter03 input/chapter04 input/chapter05 input/chapter06 input/chapter07 input/chapter08 input/chapter09

# xfig figures that are converted
figuredirs=input/chapter00/figures input/chapter01/figures input/chapter02/figures input/chapter03/figures input/chapter04/figures input/chapter05/figures input/chapter06/figures input/chapter07/figures input/chapter08/figures

# static image dirs -- images that aren't converted
imagedirs=input/chapter02/images

sources := $(foreach dir,$(sourcedirs),$(wildcard $(dir)/*.xml))
figures := $(foreach dir,$(figuredirs),$(wildcard $(dir)/*.xfig))
gen_pngs := $(patsubst %.xfig,%.png,$(figures))
gen_epss := $(patsubst %.xfig,%.eps,$(figures))
gen_svgs := $(patsubst %.xfig,%.svg,$(figures))

pngs := $(gen_pngs) $(foreach dir,$(imagedirs),$(wildcard $(dir)/*.png))
epss := $(gen_epss) $(foreach dir,$(imagedirs),$(wildcard $(dir)/*.eps))
svgs := $(gen_svgs) $(foreach dir,$(imagedirs),$(wildcard $(dir)/*.svg))

html.output=html.output
html.css=css/csbu.css

docbook.xsl=docbook-xsl-ns-1.79.0

saxon.classpath="../saxon65/saxon.jar:../$(docbook.xsl)/extensions/saxon65.jar"
pdf.output=pdf.output
fop=fop-2.0/fop

#rules to convert xfigs to png/eps
%.png : %.xfig
	fig2dev -L png $< $@

%.eps : %.xfig
	fig2dev -L eps $< $@

%.svg : %.xfig
	fig2dev -L svg $< $@

#pdf depends on having eps figures around.
.PHONY: pdf
pdf: $(svgs) $(pdf.output)/csbu.pdf

$(pdf.output)/csbu.pdf : $(pdf.output)/csbu.fo
	$(fop) $< $@

# general overview
#
#  use xmllint to build a .xml file (xmllint has xincludes support,
#  saxon doesn't.  xinclude seems more reliable for finding souce
#  files for .txt or .c examples)
#
#  use saxon to apply xsl and get final output

$(pdf.output)/csbu.fo: input/csbu.xml csbu-pdf.xsl $(sources)
	rm -rf ./pdf.output
	mkdir -p ./pdf.output
	#a bit hacky; copy all svg to be alongside .fo for fop to find
	#as image references are like "chapterXX/foo.svg"
	cd input ; cp -r --parents $(svgs:input/%=%) ../$(pdf.output)
	xmllint --xinclude --noent ./input/csbu.xml > $(pdf.output)/csbu.xml
	jing ./docbook-5.0/rng/docbookxi.rng $(pdf.output)/csbu.xml
	cd $(pdf.output) ; java -classpath $(saxon.classpath) \
		com.icl.saxon.StyleSheet \
		-o csbu.fo \
		csbu.xml ../csbu-pdf.xsl \
                use.extensions=1 \
		textinsert.extension=1

#html depends on having png figures around.
html: input/csbu.xml csbu-html.xsl $(html.css) $(sources) $(pngs)
	rm -rf ./html.output
	mkdir -p ./html.output

	#copy all .c files into appropriate places
	-cd input; \
	 for dir in $(sourcedirs:input/%=%); do \
		cp -r --parents $$dir/code/* ../$(html.output); \
		cp -r --parents $$dir/figures/*.png ../$(html.output); \
		cp -r --parents $$dir/images/*.png ../$(html.output); \
	done
	xmllint --xinclude --noent ./input/csbu.xml > $(html.output)/csbu.xml
	jing ./docbook-5.0/rng/docbookxi.rng $(html.output)/csbu.xml
	cd $(html.output); java -classpath $(saxon.classpath) \
		com.icl.saxon.StyleSheet \
		./csbu.xml ../csbu-html.xsl \
		base.dir=. \
		use.extensions=1 \
		textinsert.extension=1 \
		tablecolumns.extension=1

	cp $(html.css) draft.png $(html.output)
	cp google726839f49cefc875.html $(html.output)

.PHONY: clean
clean:
	rm -rf $(html.output) $(pdf.output) $(gen_pngs) $(gen_epss) $(gen_svgs)
