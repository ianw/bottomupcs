<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f fp m t vp xs"
                version="3.0">

<xsl:template match="db:refentry">
  <xsl:variable name="gi" select="if (parent::*)
                                  then 'div'
                                  else 'article'"/>
  <xsl:element name="{$gi}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:apply-templates select="." mode="m:toc"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:refnamediv[preceding-sibling::db:refnamediv]"/>
<xsl:template match="db:refnamediv[not(preceding-sibling::db:refnamediv)]">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>

    <xsl:choose>
      <xsl:when test="$refentry-generate-name">
        <h2>
          <xsl:sequence
              select="f:gentext(., 'label', 'refname')"/>
        </h2>
      </xsl:when>

      <xsl:when test="$refentry-generate-title">
        <h2>
          <xsl:choose>
            <xsl:when test="../db:refmeta/db:refentrytitle">
              <xsl:apply-templates select="../db:refmeta/db:refentrytitle"/>
            </xsl:when>
            <xsl:when test="db:refdescriptor">
              <xsl:apply-templates select="db:refdescriptor"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="db:refname[1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </h2>
      </xsl:when>
    </xsl:choose>
    <p>
      <xsl:choose>
        <xsl:when test="db:refdescriptor">
          <xsl:apply-templates select="db:refdescriptor"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="db:refname"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="* except (db:refdescriptor|db:refname)"/>
    </p>
    <xsl:for-each select="following-sibling::db:refnamediv">
      <p>
        <xsl:choose>
          <xsl:when test="db:refdescriptor">
            <xsl:apply-templates select="db:refdescriptor"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="db:refname"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="* except (db:refdescriptor|db:refname)"/>
      </p>
    </xsl:for-each>
  </div>
</xsl:template>

<xsl:template match="db:refmeta|db:refclass"/>

<xsl:template match="db:refdescriptor">
  <xsl:param name="purpose" select="''"/>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="db:manvolnum">
  <span class="manvolnum">
    <span class="sep">(</span>
    <xsl:apply-templates/>
    <span class="sep">)</span>
  </span>
</xsl:template>

<xsl:template match="db:refentrytitle">
  <xsl:param name="purpose" select="''"/>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="db:refname">
  <xsl:param name="purpose" select="''"/>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>
  <xsl:if test="not($purpose = 'lot') and following-sibling::db:refname">
    <span class="refname-sep">
      <xsl:sequence
          select="f:gentext(., 'separator', 'refname-sep')"/>
    </span>
  </xsl:if>
</xsl:template>

<xsl:template match="db:refpurpose">
  <xsl:param name="purpose" select="''"/>
  <span>
    <xsl:choose>
      <xsl:when test="$purpose = 'lot'">
        <xsl:attribute name="class" select="local-name(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="m:attributes"/>
      </xsl:otherwise>
    </xsl:choose>
    <span class="refpurpose-sep">
      <xsl:sequence
          select="f:gentext(., 'separator', 'refpurpose-sep')"/>
    </span>
    <span class="refpurpose-text">
      <xsl:apply-templates/>
    </span>
    <xsl:if test="not($purpose = 'lot')
                  and not(matches(normalize-space(.), '\p{P}$'))">
      <span class="refpurpose-punc">
        <xsl:text>.</xsl:text>
      </span>
    </xsl:if>
  </span>
</xsl:template>

<xsl:template match="db:refsynopsisdiv">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>

    <h2>
      <xsl:choose>
        <xsl:when test="db:info/db:title">
          <xsl:apply-templates select="db:info/db:title"
                               mode="m:titlepage-mode"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Synopsis</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </h2>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:refsection|db:refsect1|db:refsect2|db:refsect3">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:apply-templates/>
  </div>
</xsl:template>

</xsl:stylesheet>
