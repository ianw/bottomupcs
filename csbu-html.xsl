<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:f="http://docbook.org/ns/docbook/functions"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:m="http://docbook.org/ns/docbook/modes"
    xmlns:t="http://docbook.org/ns/docbook/templates"
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

  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  
  <link rel="stylesheet" href="css/csbu.css"/>

    <script type="text/javascript"
          src="https://kit.fontawesome.com/c94d537c36.js" crossorigin="anonymous"/>
</xsl:template>


<xsl:template name="t:top-nav">
  <xsl:param name="docbook" as="node()" tunnel="yes"/>
  <xsl:param name="node" as="element()"/>
  <xsl:param name="prev" as="element()?"/>
  <xsl:param name="next" as="element()?"/>
  <xsl:param name="up" as="element()?"/>
  <xsl:param name="top" as="element()?"/>

  <span class="nav">
    <a title="{$docbook/db:book/db:info/db:title}" href="{$top/@db-chunk/string()}">
      <i class="fas fa-home"></i>
    </a>
    <xsl:text>&#160;</xsl:text>

    <xsl:choose>
      <xsl:when test="exists($prev)">
        <a href="{$prev/@db-chunk/string()}" title="{f:title-content($prev)}">
          <i class="fas fa-arrow-left"></i>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="inactive">
          <i class="fas fa-arrow-left"></i>
        </span>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#160;</xsl:text>

    <xsl:choose>
      <xsl:when test="exists($up)">
        <a title="{f:title-content($up)}" href="{$up/@db-chunk/string()}">
          <i class="fas fa-arrow-up"></i>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="inactive">
          <i class="fas fa-arrow-up"></i>
        </span>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#160;</xsl:text>

    <xsl:choose>
      <xsl:when test="exists($next)">
        <a title="{f:title-content($next)}"
           href="{$next/@db-chunk/string()}">
          <i class="fas fa-arrow-right"></i>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="inactive">
          <i class="fas fa-arrow-right"></i>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </span>
  
  <span class="title">
    <i class="title"><xsl:value-of select="/h:html/h:head/h:title"/></i>
  </span>

  <span class="logo">
    <!-- no logo -->
  </span>
</xsl:template>


<xsl:function name="f:title-content" as="node()*">
  <xsl:param name="node" as="element()?"/>

  <xsl:variable name="header" select="($node/h:header, $node/h:article/h:header)[1]"/>

  <xsl:variable name="title" as="element()?"
                select="($header/h:h1,
                         $header/h:h2,
                         $header/h:h3,
                         $header/h:h4,
                         $header/h:h5)[1]"/>

  <xsl:variable name="title" as="element()?"
                select="if (exists($title))
                        then $title
                        else ($node/h:div[@class='refnamediv']
                                 /h:p/h:span[@class='refname'])[1]"/>
 
  <xsl:sequence select="$title/node()"/>
</xsl:function>

</xsl:stylesheet>
