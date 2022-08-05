<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:ext="http://docbook.org/extensions/xslt"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                default-mode="m:docbook"
                exclude-result-prefixes="dbe ext f fp h m mp v xs"
                version="3.0">

<xsl:function name="f:syntax-highlight">
  <xsl:param name="source" as="xs:string"/>
  <xsl:sequence select="f:syntax-highlight($source, map{}, map{})"/>
</xsl:function>

<xsl:function name="f:syntax-highlight">
  <xsl:param name="source" as="xs:string"/>
  <xsl:param name="language" as="xs:string"/>
  <xsl:sequence
      select="f:syntax-highlight($source, $language, map{})"/>
</xsl:function>

<xsl:function name="f:syntax-highlight" as="node()*">
  <xsl:param name="source" as="xs:string"/>
  <xsl:param name="options"/>
  <xsl:param name="pyoptions" as="map(xs:string,xs:string)"/>

  <!-- Special case for just the language option -->
  <xsl:variable name="options" as="map(xs:string,xs:string)">
    <xsl:choose>
      <xsl:when test="$options instance of xs:string">
        <xsl:sequence select="map { 'language': $options }"/>
      </xsl:when>
      <xsl:when test="$options instance of attribute()">
        <xsl:sequence select="map { 'language': string($options) }"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$options"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:message use-when="'highlight' = $v:debug">
    <xsl:text use-when="not(function-available('ext:pygmentize'))
                          or not(function-available('ext:pygmentize-available'))"
              >Syntax highlighting is not configured</xsl:text>
    <xsl:text use-when="function-available('ext:pygmentize')
                        and function-available('ext:pygmentize-available')
                        and not(ext:pygmentize-available())"
              >Syntax highlighting is not available</xsl:text>
    <xsl:text use-when="function-available('ext:pygmentize')
                        and function-available('ext:pygmentize-available')
                        and ext:pygmentize-available()"
              >Syntax highlighting is available</xsl:text>
  </xsl:message>

  <!-- N.B. xsl:value-of is intentional here; this function returns a node -->
  <xsl:value-of use-when="not(function-available('ext:pygmentize'))
                          or not(function-available('ext:pygmentize-available'))"
                select="$source"/>

  <xsl:if use-when="function-available('ext:pygmentize')
                    and function-available('ext:pygmentize-available')"
          test="ext:pygmentize-available()">
    <xsl:sequence select="fp:syntax-highlight($source, $options, $pyoptions)"/>
  </xsl:if>

  <xsl:if use-when="function-available('ext:pygmentize')
                    and function-available('ext:pygmentize-available')"
          test="not(ext:pygmentize-available())">
    <xsl:value-of select="$source"/>
  </xsl:if>
</xsl:function>

<xsl:function use-when="function-available('ext:pygmentize')"
              name="fp:syntax-highlight" as="node()*">
  <xsl:param name="source" as="xs:string"/>
  <xsl:param name="options" as="map(xs:string,xs:string)"/>
  <xsl:param name="pyoptions" as="map(xs:string,xs:string)"/>

  <xsl:variable name="string"
                select="ext:pygmentize($source, $options, $pyoptions)"/>
  <xsl:variable name="html">
    <xsl:apply-templates select="parse-xml($string)/node()" mode="mp:fix-html"/>
  </xsl:variable>

  <xsl:sequence select="$html/h:div/h:pre/node()"/>
</xsl:function>

<xsl:function use-when="not(function-available('ext:pygmentize'))"
              name="fp:syntax-highlight" as="node()*">
  <xsl:sequence select="error($dbe:INTERNAL-HIGHLIGHT-ERROR,
                              'Syntax highlighting called when not available')"/>
</xsl:function>

<xsl:template match="element()" mode="mp:fix-html">
  <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*,node()" mode="mp:fix-html"/>
  </xsl:element>
</xsl:template>

<xsl:template match="span[empty(node()) and empty(@*)]" mode="mp:fix-html"/>

<xsl:template match="attribute()|text()|comment()|processing-instruction()" 
              mode="mp:fix-html">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
