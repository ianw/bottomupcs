<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:m="http://docbook.org/ns/docbook/modes"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="db xs"
    version="3.0">

<!-- This href has to point to your local copy
     of the stylesheets. -->

<xsl:import href="docbook-xslTNG-1.8.0/xslt/docbook.xsl"/>

<xsl:param name="chunk" select="'index.html'" />
<xsl:param name="chunk-output-base-uri" select="'.'" />
<xsl:param name="verbatim-syntax-highlighter" select="'highlight.js'" />
<xsl:param name="persistent-toc" select="'true'" />

<xsl:template match="*" mode="m:html-head-links">
  <xsl:next-match/>

  <link rel="stylesheet" href="css/csbu.css"/>
</xsl:template>

</xsl:stylesheet>
