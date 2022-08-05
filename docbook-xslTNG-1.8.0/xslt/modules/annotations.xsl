<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:ghost="http://docbook.org/ns/docbook/ephemeral"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f ghost m v xs"
                version="3.0">

<xsl:template match="ghost:annotation">
  <xsl:variable name="number"
                select="count(key('id', @linkend)/preceding::db:annotation)+1"/>
  <db-annotation-marker target="{@linkend}"
                        placement="{@placement}"
                        db-annotation="{$number}">
    <a class="annomark" href="#{@linkend}"
       db-annotation="{@linkend}">
      <xsl:sequence select="$annotation-mark"/>
      <sup class="num">
        <xsl:value-of select="$number"/>
      </sup>
    </a>
  </db-annotation-marker>
</xsl:template>

<xsl:template match="db:annotation">
  <db-annotation id="{f:generate-id(.)}"
                 db-annotation="{count(preceding::db:annotation)+1}">
    <xsl:apply-templates select="." mode="m:annotation-content"/>
  </db-annotation>
</xsl:template>

<xsl:template match="db:annotation" mode="m:annotation-content">
  <div>
    <xsl:apply-templates select="." mode="m:attributes">
    </xsl:apply-templates>
    <div class="annotation-body">
      <div class="annotation-header">
        <div class="annotation-close">
        </div>
        <div class="annotation-title">
          <span class="annomark">
            <xsl:sequence select="$annotation-mark"/>
            <sup class="num">
              <xsl:value-of select="count(preceding::db:annotation)+1"/>
            </sup>
            <xsl:text> </xsl:text>
          </span>
          <xsl:apply-templates select="." mode="m:headline-title"/>
        </div>
      </div>
      <div class="annotation-content">
        <xsl:apply-templates/>
      </div>
    </div>
  </div>
</xsl:template>

</xsl:stylesheet>
