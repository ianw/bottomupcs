<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="h m t tp xs"
                version="3.0">

<xsl:import href="docbook.xsl"/>

<xsl:param name="output-base-uri" select="''"/>
<xsl:param name="olink-targetdoc" as="xs:string" required="yes"/>

<xsl:output method="xml" encoding="utf-8" indent="no"/>

<!-- ============================================================ -->

<xsl:template match="/" priority="1000">
  <xsl:variable name="html">
    <xsl:call-template name="t:docbook"/>
  </xsl:variable>
  <targetdb targetdoc="{$olink-targetdoc}">
    <xsl:apply-templates select="$html/*"/>
  </targetdb>
</xsl:template>

<xsl:template match="node()" mode="m:chunk-write">
  <xsl:param name="href" as="xs:string" required="yes"/>
  <chunk href="{$href}">
    <xsl:sequence select="."/>
  </chunk>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="h:div[contains-token(@class, 'annotations')]"
              priority="100">
  <!-- there's no practical way to point to an annotation -->
</xsl:template>

<xsl:template match="h:span[contains-token(@class, 'indexterm')]"
              priority="100">
  <!-- there's no practical way to point to index terms -->
</xsl:template>

<xsl:template match="*[@id]">
  <xsl:call-template name="object"/>
</xsl:template>

<xsl:template match="*">
  <xsl:apply-templates select="*"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="division">
  <xsl:call-template name="element">
    <xsl:with-param name="gi" select="'div'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="object">
  <xsl:call-template name="element">
    <xsl:with-param name="gi" select="'obj'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="element">
  <xsl:param name="gi" as="xs:string" required="yes"/>
  <xsl:param name="attr" as="attribute()*"/>

  <xsl:variable name="href" select="ancestor::h:chunk[1]/@href/string()"/>

  <xsl:element name="{$gi}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:attribute name="element" select="local-name(.)"/>
    <xsl:sequence select="@class"/>
    <xsl:attribute name="href" select="$href || '#' || @id"/>
    <xsl:attribute name="targetptr" select="@id"/>
    <xsl:attribute name="number">
      <xsl:choose>
        <xsl:when test="@label">
          <xsl:value-of select="@label/string()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="m:headline-number">
            <xsl:with-param name="purpose" select="'title'"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:sequence select="$attr"/>
    <xsl:apply-templates select="h:header" mode="parts"/>
    <xsl:apply-templates select="." mode="xreftext"/>
    <xsl:apply-templates select="*"/>
  </xsl:element>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="h:header" mode="parts">
  <xsl:variable name="title"
                select="h:h1|h:h2|h:h3|h:h4|h:h5|h:div[contains-token(@class,'title')]"/>
  <xsl:apply-templates select="$title[1]" mode="part-label"/>
  <xsl:apply-templates select="$title[1]" mode="part-number"/>
  <xsl:apply-templates select="$title[1]" mode="part-title"/>
</xsl:template>

<xsl:template match="*" mode="part-label">
  <xsl:variable name="part"
                select="h:span[@class='label']/node()"/>
  <xsl:variable name="last" select="$part[last()]"/>
  <xsl:variable name="part"
                select="if ($last/self::h:span and contains-token($last/@class, 'sep'))
                        then $part[position() lt last()]
                        else $part"/>
  <xsl:variable name="part" select="string-join($part, '')"/>
  <xsl:if test="normalize-space($part) ne ''">
    <xsl:attribute name="label" select="normalize-space($part)"/>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="part-number">
  <xsl:variable name="part"
                select="h:span[@class='number']/node()"/>
  <xsl:variable name="last" select="$part[last()]"/>
  <xsl:variable name="part"
                select="if ($last/self::h:span and contains-token($last/@class, 'sep'))
                        then $part[position() lt last()]
                        else $part"/>
  <xsl:variable name="part" select="string-join($part, '')"/>
  <xsl:if test="normalize-space($part) ne ''">
    <xsl:attribute name="number" select="normalize-space($part)"/>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="part-title">
  <xsl:attribute name="title" select="normalize-space(string(.))"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="xreftext">
  <xsl:variable name="xref" as="item()*">
    <xsl:choose>
      <xsl:when test="h:header">
        <xsl:apply-templates select="h:header" mode="xreftext"/>
      </xsl:when>
      <xsl:when test="empty(node())"/>
      <xsl:otherwise>
        <xsl:apply-templates mode="cleanup"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="exists($xref)">
    <xreftext><xsl:sequence select="$xref"/></xreftext>
  </xsl:if>
</xsl:template>

<xsl:template match="h:p[contains-token(@class, 'bibliomixed')]" mode="xreftext">
  <xsl:choose>
    <xsl:when test="h:span[contains-token(@class, 'abbrev')]">
      <xreftext>
        <xsl:apply-templates select="(h:span[contains-token(@class, 'abbrev')])[1]/node()"
                             mode="cleanup"/>
      </xreftext>
    </xsl:when>
    <xsl:otherwise>
      <xsl:next-match/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="h:div[contains-token(@class, 'refentry')]" mode="xreftext">
  <xreftext>
    <xsl:apply-templates select="(.//h:span[contains-token(@class, 'refname')])[1]/node()"
                             mode="cleanup"/>
  </xreftext>
</xsl:template>

<xsl:template match="h:*[contains-token(@class, 'informalfigure')]
                     |h:*[contains-token(@class, 'informalexample')]
                     |h:*[contains-token(@class, 'informalequation')]
                     |h:*[contains-token(@class, 'informaltable')]"
              mode="xreftext">
  <!-- have no xreftext -->
</xsl:template>

<xsl:template match="h:header" mode="xreftext">
  <xsl:variable name="title"
                select="h:h1|h:h2|h:h3|h:h4|h:h5|h:div[contains-token(@class,'title')]"/>
  <xsl:choose>
    <xsl:when test="$title">
      <xsl:apply-templates select="$title[1]/node()" mode="cleanup"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>???</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="element()" mode="cleanup">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()" mode="cleanup"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:a" mode="cleanup">
  <xsl:apply-templates select="node()" mode="cleanup"/>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()"
              mode="cleanup">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
