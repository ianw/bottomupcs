<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ext="http://docbook.org/extensions/xslt"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="ext xs"
                version="3.0">

<xsl:output method="xml" encoding="utf-8" indent="no"/>

<xsl:template match="/" as="document-node()"
              use-when="function-available('ext:xinclude')">
  <xsl:sequence select="ext:xinclude(.)"/>
</xsl:template>

<xsl:template match="/" as="document-node()"
              use-when="not(function-available('ext:xinclude'))">
  <xsl:message>XInclude extension function unavailable</xsl:message>
  <xsl:sequence select="."/>
</xsl:template>

</xsl:stylesheet>
