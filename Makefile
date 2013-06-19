sourcedirs=input/chapter00 input/chapter01 input/chapter02 input/chapter03 input/chapter04 input/chapter05 input/chapter06 input/chapter07 input/chapter08 input/chapter09
figuredirs=input/chapter00/figures input/chapter01/figures input/chapter02/figures input/chapter03/figures input/chapter04/figures input/chapter05/figures input/chapter06/figures input/chapter07/figures input/chapter08/figures
imagedirs=input/chapter02/images

sources := $(foreach dir,$(sourcedirs),$(wildcard $(dir)/*.xml))
figures := $(foreach dir,$(figuredirs),$(wildcard $(dir)/*.xfig))
pngs := $(patsubst %.xfig,%.png,$(figures))
epss := $(patsubst %.xfig,%.eps,$(figures))
svgs := $(patsubst %.xfig,%.svg,$(figures))

pngs += $(foreach dir,$(imagedirs),$(wildcard $(dir)/*.png))
epss += $(foreach dir,$(imagedirs),$(wildcard $(dir)/*.eps))

html.output=html.output
html.css=css/csbu.css

saxon.classpath="saxon65/saxon.jar:docbook-xsl/extensions/saxon65.jar"
pdf.output=pdf.output
fop=fop-1.1/fop

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

$(pdf.output)/csbu.fo: validate input/csbu.xml $(sources)
	mkdir -p ./pdf.output
	#a bit hacky; copy all svg to be alongside .fo for fop to find
	# as image references are like "chapterXX/foo.svg"
	cd input ; cp -r --parents $(svgs:input/%=%) ../$(pdf.output)
	java -classpath $(saxon.classpath) \
		com.icl.saxon.StyleSheet \
		-o $(pdf.output)/csbu.fo \
		input/csbu.xml docbook-xsl/fo/docbook.xsl \
                use.extensions=1 \
		textinsert.extension=1

#html depends on having png figures around.
html: validate input/csbu.xml $(html.css) $(sources) $(pngs)
	mkdir -p ./html.output

	#copy all .c files into appropriate places
	echo $(sourcedirs:input/%=%)
	-cd input; \
	 for dir in $(sourcedirs:input/%=%); do \
		cp -r --parents $$dir/code/* ../$(html.output); \
		cp -r --parents $$dir/figures/*.png ../$(html.output); \
	done
	java -classpath $(saxon.classpath) \
		com.icl.saxon.StyleSheet \
		input/csbu.xml docbook-xsl/xhtml5/chunkfast.xsl \
		base.dir=$(html.output) \
		use.id.as.filename=1 \
		make.clean.html=1 \
		chunk.first.selection=1 \
		html.ext=".html"
	cp --parents $(pngs) $(html.output)
	cp $(html.css) draft.png $(html.output)
	cp google726839f49cefc875.html $(html.output)

.PHONY: validate
validate:
	cd input; xmllint --postvalid --noout csbu.xml

.PHONY: clean
clean:
	rm -rf $(html.output) $(pdf.output) $(pngs) $(epss) $(svgs)
