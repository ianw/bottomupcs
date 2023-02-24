<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                expand-text="yes"
                default-mode="m:epub-chunk"
                exclude-result-prefixes="h m xs"
                version="3.0">

<xsl:mode name="m:epub-chunk" on-no-match="shallow-copy"/>

<xsl:template match="h:html[@db-chunk]">
  <xsl:variable name="filename"
                select="tokenize(@db-chunk, '/')[last()]
                        ! replace(., '\.html$', '.xhtml')"/>

  <xsl:result-document href="OPS/{$filename}">
    <xsl:copy>
      <xsl:copy-of select="@* except @db-chunk"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:result-document>
</xsl:template>

<xsl:template match="@*[contains(local-name(.), '-')]"/>

<!-- ============================================================ -->
<!-- The very first chunk is special -->

<xsl:template match="/h:html/h:html[@db-chunk][1]" priority="10">
  <xsl:variable name="filename" select="tokenize(@db-chunk, '/')[last()]"/>
  <xsl:result-document href="OPS/{$filename}">
    <xsl:copy>
      <xsl:copy-of select="@* except @db-chunk"/>
      <xsl:apply-templates mode="m:epub-titlepage"/>
    </xsl:copy>
  </xsl:result-document>

  <xsl:variable name="toc">
    <xsl:copy>
      <xsl:copy-of select="@* except @db-chunk"/>
      <xsl:apply-templates mode="m:epub-toc"/>
    </xsl:copy>
  </xsl:variable>

  <xsl:result-document href="OPS/toc.xhtml" method="xml" indent="yes">
    <xsl:copy>
      <xsl:copy-of select="@* except @db-chunk"/>
      <xsl:copy-of select="$toc/h:html/h:head"/>
      <body>
        <nav xmlns:epub="http://www.idpf.org/2007/ops" epub:type="toc" id="toc">
          <xsl:copy-of select="($toc//h:ol[contains-token(@class, 'toc')])[1]"/>
        </nav>
      </body>
    </xsl:copy>
  </xsl:result-document>

  <xsl:apply-templates mode="m:root-chunk"/>
</xsl:template>

<xsl:mode name="m:epub-titlepage" on-no-match="shallow-copy"/>
<xsl:template match="h:html" mode="m:epub-titlepage"/>
<xsl:template match="h:div[contains-token(@class, 'list-of-titles')]"
              mode="m:epub-titlepage"/>

<xsl:mode name="m:epub-toc" on-no-match="shallow-copy"/>
<xsl:template match="h:html" mode="m:epub-toc"/>

<xsl:template match="h:article/h:header" mode="m:epub-toc"/>

<xsl:template match="h:ul" mode="m:epub-toc">
  <ol>
    <xsl:apply-templates select="@*,node()" mode="m:epub-toc"/>
  </ol>
</xsl:template>

<xsl:template match="h:span" mode="m:epub-toc">
  <xsl:apply-templates mode="m:epub-toc"/>
</xsl:template>

<xsl:mode name="m:root-chunk" on-no-match="shallow-skip"/>
<xsl:template match="h:html" mode="m:root-chunk">
  <xsl:apply-templates select="." mode="m:epub-chunk"/>
</xsl:template>

<!-- ============================================================ -->

</xsl:stylesheet>
