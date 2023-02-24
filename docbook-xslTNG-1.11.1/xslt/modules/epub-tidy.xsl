<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                expand-text="yes"
                default-mode="m:epub-tidy"
                exclude-result-prefixes="h m xs"
                version="3.0">

<xsl:mode name="m:epub-tidy" on-no-match="shallow-copy"/>

<xsl:template match="h:link[@media and @media != 'screen']"/>
<xsl:template match="h:link[contains(@href, 'css/docbook.css') and @media = 'screen']">
  <xsl:copy>
    <xsl:copy-of select="@* except @href"/>
    <xsl:attribute name="href" select="replace(@href, 'docbook.css', 'docbook-epub.css')"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:script
                     | h:meta[not(@name)]
                     | h:nav[contains-token(@class, 'top')
                             or contains-token(@class, 'bottom')]"/>

<xsl:template match="h:header[ancestor::h:header]">
  <div class="header">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="@*[contains(local-name(.), '-')]"/>
<xsl:template match="h:span/@time"/>
<xsl:template match="h:html/@db-chunk" priority="10">
  <xsl:copy/>
</xsl:template>

<xsl:template match="h:details">
  <div>
    <xsl:apply-templates select="node() except h:summary"/>
  </div>
</xsl:template>

</xsl:stylesheet>
