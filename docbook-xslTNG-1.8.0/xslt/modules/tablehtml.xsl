<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f m t xs"
                version="3.0">

<xsl:template match="db:table[not(db:tgroup)]">
  <figure class="formalobject {local-name(.)}">
    <xsl:choose>
      <xsl:when test="@xml:id">
        <xsl:attribute name="id" select="@xml:id"/>
      </xsl:when>
      <xsl:when test="parent::*">
        <xsl:attribute name="id" select="f:generate-id(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- never mind -->
      </xsl:otherwise>
    </xsl:choose>

    <table>
      <xsl:apply-templates select="." mode="m:attributes"/>
      <xsl:apply-templates mode="m:htmltable"/>
    </table>
    <xsl:if test=".//db:footnote">
      <xsl:call-template name="t:table-footnotes">
        <xsl:with-param name="footnotes" select=".//db:footnote"/>
      </xsl:call-template>
    </xsl:if>
  </figure>
</xsl:template>

<xsl:template match="db:td/db:table[not(db:tgroup)]
                     |db:th/db:table[not(db:tgroup)]"
              priority="100">
  <table>
    <xsl:choose>
      <xsl:when test="@xml:id">
        <xsl:attribute name="id" select="@xml:id"/>
      </xsl:when>
      <xsl:when test="parent::*">
        <xsl:attribute name="id" select="f:generate-id(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- never mind -->
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:htmltable"/>
  </table>
</xsl:template>

<xsl:template match="db:informaltable[not(db:tgroup)]">
  <figure class="informalobject {local-name(.)}">
    <xsl:if test="@xml:id">
      <xsl:attribute name="id" select="@xml:id"/>
    </xsl:if>
    <table>
      <xsl:apply-templates select="." mode="m:attributes"/>
      <xsl:apply-templates select="node() except db:info" mode="m:htmltable"/>
    </table>
    <xsl:if test=".//db:footnote">
      <xsl:call-template name="t:table-footnotes">
        <xsl:with-param name="footnotes" select=".//db:footnote"/>
      </xsl:call-template>
    </xsl:if>
  </figure>
</xsl:template>

<xsl:template match="db:td/db:informaltable[not(db:tgroup)]
                     |db:th/db:informaltable[not(db:tgroup)]"
              priority="100">
  <table>
    <xsl:if test="@xml:id">
      <xsl:attribute name="id" select="@xml:id"/>
    </xsl:if>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="node() except db:info" mode="m:htmltable"/>
  </table>
</xsl:template>

<xsl:template match="db:tbody|db:thead|db:tfoot|db:tr|db:th|db:td|db:caption
                     |db:colgroup|db:col"
              mode="m:htmltable">
  <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="m:htmltable"/>
  </xsl:element>
</xsl:template>

<xsl:template match="*" mode="m:htmltable">
  <xsl:apply-templates select="."/>
</xsl:template>

</xsl:stylesheet>
