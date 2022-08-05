# XML sources
sourcedirs=input/chapter00 input/chapter01 input/chapter02 input/chapter03 input/chapter04 input/chapter05 input/chapter06 input/chapter07 input/chapter08

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

pdf.output=pdf.output
epub.output=pdf.output

#rules to convert xfigs to png/eps
%.png : %.xfig
	fig2dev -L png $< $@

%.eps : %.xfig
	fig2dev -L eps $< $@

%.svg : %.xfig
	fig2dev -L svg $< $@

.PHONY: pdf
pdf: $(pdf.output)/csbu.pdf

$(pdf.output)/csbu.pdf: $(svgs) $(pdf.output)/csbu.html $(pdf.output)/csbu.html
	cd $(pdf.output); prince -o csbu.pdf csbu.html

$(pdf.output)/csbu.html :  input/csbu.xml csbu-pdf.xsl $(html.css) $(sources) $(pngs) $(svgs)
	rm -rf $(pdf.output)
	mkdir -p $(pdf.output)

	#copy all .c files into appropriate places
	-cd input; \
	 for dir in $(sourcedirs:input/%=%); do \
		cp -r --parents $$dir/code/* ../$(pdf.output); \
		cp -r --parents $$dir/figures/*.png ../$(pdf.output); \
		cp -r --parents $$dir/images/*.png ../$(pdf.output); \
		cp -r --parents $$dir/figures/*.svg ../$(pdf.output); \
		cp -r --parents $$dir/images/*.svg ../$(pdf.output); \
	done
	xmllint --relaxng ./docbook-5.0.1/docbook.rng --xinclude --noent --output $(pdf.output)/csbu.xml ./input/csbu.xml
	cd $(pdf.output); ../docbook-xslTNG-1.8.0/bin/docbook \
	  --resources:. \
	  ./csbu.xml -xsl:../csbu-pdf.xsl -o:csbu.html

.PHONY: epub
epub: $(epub.output)/csbu.epub

$(epub.output)/csbu.epub: $(pdf.output)/csbu.html
	cd $(epub.output); ebook-convert csbu.html csbu.epub

.PHONY: html
html: $(html.output)/index.html

$(html.output)/index.html: input/csbu.xml csbu-html.xsl $(sources) $(pngs) $(svgs)
	rm -rf ./html.output
	mkdir -p ./html.output

	#copy all .c files into appropriate places
	-cd input; \
	 for dir in $(sourcedirs:input/%=%); do \
		cp -r --parents $$dir/code/* ../$(html.output); \
		cp -r --parents $$dir/figures/*.png ../$(html.output); \
		cp -r --parents $$dir/images/*.png ../$(html.output); \
		cp -r --parents $$dir/figures/*.svg ../$(html.output); \
		cp -r --parents $$dir/images/*.svg ../$(html.output); \
	done
	xmllint --relaxng ./docbook-5.0.1/docbook.rng --xinclude --noent --output $(html.output)/csbu.xml ./input/csbu.xml
	cd $(html.output); ../docbook-xslTNG-1.8.0/bin/docbook \
	  --resources:. \
	  ./csbu.xml -xsl:../csbu-html.xsl

	cp $(html.css) $(html.output)/css
	cp google726839f49cefc875.html $(html.output)

.PHONY: clean
clean:
	rm -rf $(html.output) $(pdf.output) $(epub.output) $(gen_pngs) $(gen_epss) $(gen_svgs)
