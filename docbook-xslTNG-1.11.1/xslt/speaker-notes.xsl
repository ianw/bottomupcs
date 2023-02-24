<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="db f h m mp t v xs"
                version="3.0">

<xsl:import href="docbook.xsl"/>

<xsl:param name="xlink-style-default" select="'javascript'"/>

<xsl:param name="chunk" select="'index.html'"/>

<xsl:param name="persistent-toc" select="'true'"/>

<xsl:param name="chunk-include" as="xs:string*"
           select="('parent::db:book',
                    'parent::db:part')"/>

<xsl:variable name="v:user-title-properties" as="element()*">
  <title xpath="self::db:section"
         number="false"/>
</xsl:variable>

<!-- ============================================================ -->

<xsl:template match="db:article" mode="m:docbook">
  <xsl:variable name="notes"
                select="*[contains-token(@role, 'speaker-notes')]"/>
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <div class="foil">
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:apply-templates select="." mode="m:toc"/>
    <xsl:apply-templates select="node() except $notes" mode="m:docbook"/>
    </div>
    <div class="speaker-notes">
      <div class="foil-wrapper">
        <div class="foil">
          <xsl:apply-templates select="." mode="m:generate-titlepage"/>
          <xsl:apply-templates select="." mode="m:toc"/>
          <xsl:apply-templates select="node() except $notes" mode="m:docbook"/>
        </div>
      </div>
      <div class="notes">
        <xsl:apply-templates select="$notes" mode="m:docbook"/>
      </div>
    </div>
  </div>
</xsl:template>

<xsl:template match="db:article" mode="m:attributes" as="attribute()*">
  <xsl:variable name="class" select="QName('', 'class')"/>
  <xsl:variable name="attr" as="attribute()*">
    <xsl:next-match/>
  </xsl:variable>
  <xsl:for-each select="$attr">
    <xsl:choose>
      <xsl:when test="node-name(.) = $class">
        <xsl:attribute name="class" select="'foil ' || string(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template match="db:article" mode="m:toc">
  <xsl:param name="nested" select="false()"/>
  <xsl:apply-templates select="." mode="mp:toc">
    <xsl:with-param name="nested" select="$nested"/>
    <xsl:with-param name="entries" select="()"/>
  </xsl:apply-templates>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:html-head-links">
  <link rel="stylesheet" href="css/speaker-notes.css"/>
  <xsl:next-match/>
</xsl:template>

</xsl:stylesheet>
