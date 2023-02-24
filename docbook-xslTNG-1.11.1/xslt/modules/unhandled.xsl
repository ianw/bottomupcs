<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="f m xs"
                version="3.0">

<xsl:template match="*">
  <xsl:message
      select="'No template for ' || node-name(.) || ': ' || f:generate-id(.)"/>
  <xsl:variable name="inline-style"
                select="'font: monospace;
                         color: yellow;
                         background-color: red;
                         font-weight: bold;'"/>
  <xsl:variable name="block-style"
                select="'font: monospace;
                         color: yellow;
                         width: 100%;
                         background-color: red;
                         font-weight: bold;'"/>

  <xsl:variable name="inline"
                select="normalize-space(string-join(text(),'')) != ''"/>

  <xsl:element namespace="http://www.w3.org/1999/xhtml"
               name="{if ($inline) then 'span' else 'div'}">

    <xsl:element namespace="http://www.w3.org/1999/xhtml"
                 name="{if ($inline) then 'span' else 'div'}">
      <xsl:attribute name="style"
                     select="if ($inline) then $inline-style else $block-style"/>
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="node-name(.)"/>
      <xsl:text>&gt;</xsl:text>
    </xsl:element>

    <xsl:apply-templates/>

    <xsl:element namespace="http://www.w3.org/1999/xhtml"
                 name="{if ($inline) then 'span' else 'div'}">
      <xsl:attribute name="style"
                     select="if ($inline) then $inline-style else $block-style"/>
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="node-name(.)"/>
      <xsl:text>&gt;</xsl:text>
    </xsl:element>
  </xsl:element>

  <!--
    <xsl:message>
      <xsl:text>Unhandled element: </xsl:text>
      <xsl:value-of select="node-name(.)"/>
    </xsl:message>
  -->
</xsl:template>

<xsl:template xmlns:h="http://www.w3.org/1999/xhtml"
              match="h:*">
  <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates select="node()"/>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
