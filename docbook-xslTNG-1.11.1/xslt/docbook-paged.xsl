<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="db f fp h m mp t tp xlink xs"
                version="3.0">

<xsl:param name="annotations" select="'inline'"/>
<xsl:param name="xlink-style-default" select="'inline'"/>
<xsl:param name="paper-size" select="'A4'"/>

<!-- ============================================================ -->

<xsl:template name="t:chunk-footnotes">
  <xsl:param name="footnotes" as="element()*"/>
  <xsl:param name="docbook" as="node()"/>
</xsl:template>

<xsl:template name="t:imagemap">
  <xsl:param name="intrinsicwidth" required="yes"/>
  <xsl:param name="intrinsicheight" required="yes"/>
</xsl:template>

<xsl:template match="db:area|db:co" mode="m:callout-link">
  <xsl:param name="id" as="xs:string"/>
  <xsl:param name="target" as="element()?"/>

  <xsl:choose>
    <xsl:when test="$target/ancestor::db:imageobjectco">
      <xsl:apply-templates select="." mode="m:callout-bug">
        <xsl:with-param name="id" select="$id"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <a class="callout-bug" href="#{$id}">
        <xsl:apply-templates select="." mode="m:callout-bug">
          <xsl:with-param name="id" select="$id"/>
        </xsl:apply-templates>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[@xlink:href]" mode="m:docbook">
  <xsl:next-match/>
  <xsl:if test="exists(node()) and string(.) != @xlink:href">
    <xsl:text> (</xsl:text>
    <xsl:value-of select="@xlink:href"/>
    <xsl:text>)</xsl:text>
  </xsl:if>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*[@db-chunk]" mode="m:chunk-cleanup" priority="10">
  <xsl:variable name="self" select="."/>

  <xsl:message use-when="'chunk-cleanup' = $debug"
               select="'Chunk cleanup (print override):',
                       local-name(.), @db-chunk/string()"/>

  <xsl:variable name="head" select="/h:html/h:head"/>

  <xsl:variable name="rbu" select="fp:root-base-uri(.)"/>
  <xsl:variable name="cbu" select="fp:chunk-output-filename(.)"/>

  <html db-chunk="{fp:chunk-output-filename(.)}">
    <xsl:variable name="class-list" as="xs:string+">
      <!-- class=no-js is a hook for setting CSS styles when js isn't
           available; see the script element a few lines below. -->
      <xsl:sequence select="'no-js'"/>
      <xsl:sequence select="normalize-space($paper-size)"/>
      <xsl:sequence select="if ($page-style != '')
                            then normalize-space($page-style) || '-style'
                            else ()"/>
    </xsl:variable>

    <xsl:attribute name="class"
                   select="normalize-space(string-join($class-list, ' '))"/>

    <xsl:variable name="ctype" select="$head/h:meta[@http-equiv='Content-Type']"/>
    <xsl:variable name="title" select="$head/h:title"/>
    <head>
      <xsl:apply-templates select="$ctype" mode="m:chunk-cleanup"/>
      <title>
        <xsl:value-of select="f:chunk-title(.)"/>
      </title>
      <script>
        <xsl:text>(function(H){H.className=H.className.replace(/\bno-js\b/,'js')})</xsl:text>
        <xsl:text>(document.documentElement)</xsl:text>
      </script>
      <xsl:apply-templates select="$head/node() except ($ctype|$title)"
                           mode="m:chunk-cleanup">
        <xsl:with-param name="rootbaseuri" select="$rbu"/>
        <xsl:with-param name="chunkbaseuri" select="$cbu"/>
      </xsl:apply-templates>
      <xsl:if test="exists(.//mml:*)"
              xmlns:mml="http://www.w3.org/1998/Math/MathML">
        <xsl:apply-templates select="/h:html/h:db-mathml-script/*"
                             mode="m:chunk-cleanup">
          <xsl:with-param name="rootbaseuri" select="$rbu"/>
          <xsl:with-param name="chunkbaseuri" select="$cbu"/>
        </xsl:apply-templates>
      </xsl:if>
    </head>
    <body>
      <xsl:copy-of select="*/@*"/>
      <xsl:apply-templates select="*/h:header" mode="m:chunk-cleanup"/>
      <main>
        <xsl:apply-templates select="*/* except */h:header"
                             mode="m:chunk-cleanup"/>
      </main>
    </body>
  </html>
</xsl:template>

<xsl:template match="h:a[contains-token(@class, 'indexref')]"
              mode="m:chunk-cleanup">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <!-- explicitly don't copy the content -->
  </xsl:copy>
</xsl:template>

<xsl:template match="h:sup[contains-token(@class, 'footnote-number')]"
              mode="m:chunk-cleanup"/>

<xsl:template match="h:div[contains-token(@class, 'footnote-number')]"
              mode="m:chunk-cleanup"/>

<xsl:template match="h:div[contains-token(@class, 'footnote-body')]"
              mode="m:chunk-cleanup">
  <!-- If the footnote consists of a single para, throw away the block
       wrappers. This is a very common case and avoids an issue where
       PrinceXML doesn't seem to like block markup in footnotes. -->
  <xsl:choose>
    <xsl:when test="count(*) = 1 and h:p">
      <xsl:apply-templates select="h:p/node()" mode="m:chunk-cleanup"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:apply-templates select="@*,node()" mode="m:chunk-cleanup"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="h:db-footnote" mode="m:chunk-cleanup">
  <xsl:if test="not(ancestor::h:table)">
    <span class="footnote" id="{@id}">
      <!-- n.b. the db-footnote is a wrapper around the div
           that we don't need either -->
      <xsl:apply-templates select="h:div/node()" mode="m:chunk-cleanup"/>
    </span>
  </xsl:if>
</xsl:template>

<xsl:template match="h:db-annotation-marker" mode="m:chunk-cleanup">
  <xsl:variable name="target" select="key('hid', @target)"/>
  <span class="footnote">
    <xsl:apply-templates
        select="$target//h:div[contains-token(@class, 'annotation-content')]/*"
        mode="m:chunk-cleanup"/>
  </span>
</xsl:template>

</xsl:stylesheet>
