sourcedirs=chapter00 chapter01 chapter02 chapter03 chapter04 chapter05 chapter06 chapter07 chapter08 chapter09
figuredirs=chapter00/figures chapter01/figures chapter02/figures chapter03/figures chapter04/figures chapter05/figures chapter06/figures chapter07/figures chapter08/figures
imagedirs=chapter02/images

sources := $(foreach dir,$(sourcedirs),$(wildcard $(dir)/*.sgml))
figures := $(foreach dir,$(figuredirs),$(wildcard $(dir)/*.xfig))
pngs := $(patsubst %.xfig,%.png,$(figures))
epss := $(patsubst %.xfig,%.eps,$(figures))

pngs += $(foreach dir,$(imagedirs),$(wildcard $(dir)/*.png))
epss += $(foreach dir,$(imagedirs),$(wildcard $(dir)/*.eps))

PREFIX?=/usr/local

#rules to convert xfigs to png/eps
%.png : %.xfig
	fig2dev -L png $< $@

%.eps : %.xfig
	fig2dev -L eps $< $@

#pdf depends on having eps figures around.
.PHONY: pdf 
pdf: $(epss) csbu.pdf 

csbu.pdf : csbu.sgml $(sources)
	jw -f docbook -b dvi -l ${PREFIX}/share/xml/declaration/xml.dcl $<
	dvipdf csbu.dvi $@

#html depends on having png figures around.
html: csbu.sgml csbu.css $(sources) $(pngs)
	mkdir -p ./html
#copy all .c files into appropriate places
	-for dir in $(sourcedirs); do \
	cp -r -p $$dir/code/* html; \
	done
	jw -o html -d csbu.dsl -f docbook -b html -l ${PREFIX}/share/xml/declaration/xml.dcl csbu.sgml
	cp -p $(pngs) html
	cp csbu.css draft.png html

.PHONY: clean
clean:	
	rm -rf html csbu.pdf csbu.dvi $(pngs) $(epss)
