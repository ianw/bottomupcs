<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:ext="http://docbook.org/extensions/xslt"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="db ext f h m map mp t tp v vp xs"
                version="3.0">

<!-- This will all be in XProc 3.0 eventually, hack for now... -->
<xsl:import href="main.xsl"/>
<xsl:import href="drivers.xsl"/>

<xsl:output method="xhtml" encoding="utf-8" indent="no" html-version="5"
            omit-xml-declaration="yes"/>

<xsl:template match="*" as="element()">
  <xsl:variable name="document" as="document-node()">
    <xsl:document>
      <xsl:sequence select="."/>
    </xsl:document>
  </xsl:variable>
  <xsl:call-template name="tp:docbook">
    <xsl:with-param name="source" select="$document"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="/" name="tp:docbook">
  <xsl:param name="source" as="document-node()" select="."/>

  <xsl:variable name="source" as="document-node()">
    <xsl:call-template name="t:preprocess">
      <xsl:with-param name="source" select="$source"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="result" as="document-node()">
    <xsl:call-template name="t:process">
      <xsl:with-param name="source" select="$source"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="result" as="document-node()">
    <xsl:call-template name="t:chunk-cleanup">
      <xsl:with-param name="docbook" select="$source"/>
      <xsl:with-param name="source" select="$result"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="result" as="map(xs:string, item()*)">
    <xsl:call-template name="t:chunk-output">
      <xsl:with-param name="docbook" select="$source"/>
      <xsl:with-param name="source" select="$result"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:for-each select="map:keys($result)">
    <xsl:if test=". != 'output'">
      <xsl:apply-templates select="map:get($result, .)" mode="m:chunk-write">
        <xsl:with-param name="href" select="."/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:for-each>

  <xsl:choose>
    <xsl:when test="not($result?output/h:html)">
      <xsl:sequence select="$result?output"/>
    </xsl:when>
    <xsl:when test="f:is-true($generate-html-page)">
      <xsl:sequence select="$result?output"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$result?output/h:html/h:body/node()
                            except $result?output/h:html/h:body/h:script"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="node()" mode="m:chunk-write">
  <xsl:param name="href" as="xs:string" required="yes"/>

  <xsl:result-document href="{$href}">
    <xsl:choose>
      <xsl:when test="not(self::h:html)">
        <!-- If this happens not to be an h:html element, just output it. -->
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:when test="f:is-true($generate-html-page)">
        <!-- If this is an h:html element, and generate-html-page is true,
             output just output it. -->
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:otherwise>
        <!-- We got an h:html, but the user has requested 'raw' output.
             Attempt to strip out the generated html page wrapper. -->
        <xsl:sequence select="h:body/node() except h:body/h:script"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:result-document>
</xsl:template>

</xsl:stylesheet>
