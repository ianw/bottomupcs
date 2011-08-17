<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY docbook.dsl PUBLIC "-//Norman Walsh//DOCUMENT DocBook HTML Stylesheet//EN" CDATA dsssl>
]>
<style-sheet>

<style-specification id="html" use="docbook">
<style-specification-body> 

(define %stylesheet% 
  "csbu.css")

(define %generate-legalnotice-link%
  ;; put legal notice in separate file
  #t)

(define %admon-graphics%
  #t)

(define %funcsynopsis-decoration%
  ;; make funcsynopsis look pretty
  #t)

(define %html-ext%
  ;; html extension
  ".html")

(define %generate-book-titlepage%
  #t)

(define %root-filename%
  "index")

(define ($html-body-start$)
  (make element gi: "script"
	attributes: '(("language" "JavaScript")
		      ("type" "text/javascript"))
	(make formatting-instruction 
	  data: (string-append "<" "!--
 var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-25195980-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
// --" ">"))))

(define ($html-body-content-end$)
  (make element gi: "div"
	attributes: '(("id" "disqus_thread"))
	(make formatting-instruction
	  data: (string-append "<" "script type=\"text/javascript\"" ">"
			       "var disqus_shortname = 'bottomupcs';"
			       "(function() { "
			       "var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;"
			       "dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';"
			       "(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);"
			       "})();"
			       "<" "/script" ">"
			       ))))

(define %callout-graphics-path%
  "images/callouts/")

(define %admon-graphics-path%
  "images/")

</style-specification-body>
</style-specification>

<external-specification id="docbook" document="docbook.dsl">

</style-sheet>
