<?xml version='1.0'?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    version="1.0">

<xsl:import href="docbook-xsl-ns-1.79.1/xhtml5/chunk.xsl"/>
<xsl:import href="docbook-xsl-ns-1.79.1/xhtml/highlight.xsl"/>

<xsl:param name="highlight.source" select="1" />
<xsl:param name="chunker.output.encoding" select="'UTF-8'"/>
<xsl:param name="make.clean.html" select="1"></xsl:param>
<xsl:param name="use.id.as.filename" select="1"></xsl:param>
<xsl:param name="chunk.first.selection" select="1"></xsl:param>
<!--<xsl:param name="html.ext">.html</xsl:param>-->
<xsl:param name="docbook.css.link" select="0"></xsl:param>
<xsl:param name="docbook.css.source"></xsl:param>
<xsl:param name="suppress.navigation" select="0"></xsl:param>
<xsl:param name="html.stylesheet">csbu.css</xsl:param>


<xsl:variable name="articleOpen">
<xsl:text disable-output-escaping="yes">
<![CDATA[
<article>
]]>
</xsl:text>
</xsl:variable>

<xsl:template name="user.header.content">
    <xsl:value-of select="$articleOpen" disable-output-escaping="yes"/>
</xsl:template>


<xsl:variable name="articleClose">
<xsl:text disable-output-escaping="yes">
<![CDATA[
</article>
]]>
</xsl:text>
</xsl:variable>

<xsl:template name="user.footer.content">
    <xsl:value-of select="$articleClose" disable-output-escaping="yes"/>
</xsl:template>


<xsl:template name="user.footer.navigation">
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-25195980-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

<div id="disqus_thread">&#160;</div>
    <script type="text/javascript">
        var disqus_shortname = 'bottomupcs'; // required: replace example with your forum shortname

        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
    </script>
    <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>

</xsl:template>


</xsl:stylesheet>
