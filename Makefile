sourcedirs=wk0 wk1 wk2 wk3 wk4 wk5 wk6 wk7 wk8 wk9
imagedirs=wk0/figures wk1/figures wk2/figures wk3/figures wk4/figures wk5/figures wk6/figures wk7/figures wk8/figures

sources := $(foreach dir,$(sourcedirs),$(wildcard $(dir)/*.sgml))
images := $(foreach dir,$(imagedirs),$(wildcard $(dir)/*.xfig))
pngs := $(patsubst %.xfig,%.png,$(images))
epss := $(patsubst %.xfig,%.eps,$(images))


#rules to convert xfigs to png/eps
%.png : %.xfig
	fig2dev -L png $< $@

%.eps : %.xfig
	fig2dev -L eps $< $@

#pdf depends on having eps figures around.
.PHONY: pdf 
pdf: $(epss) csbu.pdf 

csbu.pdf : csbu.sgml $(sources)
	docbook2dvi $<
	dvipdf csbu.dvi $@

#html depends on having png figures around.
html: csbu.sgml $(sources) $(pngs)
	mkdir -p ./html
#copy all .c files into appropriate places
	-for dir in $(sourcedirs); do \
	cp -r --parents $$dir/code/* html; \
	done
	jw -o html -d csbu.dsl -f docbook -b html -l /usr/share/xml/declaration/xml.dcl csbu.sgml
	cp --parents $(pngs) html
	cp csbu.css draft.png html

.PHONY: upload
upload:
	rsync -avz html/ \
	delsarto@shell.sourceforge.net:/home/groups/b/bo/bottomupcs/htdocs/csbu

.PHONY: clean
clean:	
	rm -rf html csbu.pdf csbu.dvi $(pngs) $(epss)
