<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ext="http://docbook.org/extensions/xslt"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="ext xs"
                version="3.0">

<xsl:output method="xml" encoding="utf-8" indent="no"/>

<xsl:template use-when="function-available('ext:xinclude')"
              xmlns:xi="http://www.w3.org/2001/XInclude"
              match="xi:include">
  <xsl:sequence select="ext:xinclude(.)"/>
</xsl:template>

<xsl:template match="element()">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
