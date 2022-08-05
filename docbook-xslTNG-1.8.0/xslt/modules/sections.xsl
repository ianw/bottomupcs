<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f m map t v xs"
                version="3.0">

<xsl:template match="db:sect1|db:sect2|db:sect3|db:sect4|db:sect5
                     |db:section|db:simplesect">
  <section>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:apply-templates/>
  </section>
</xsl:template>

<xsl:variable name="v:bridgehead-map" as="map(*)">
  <xsl:map>
    <xsl:map-entry key="'sect1'" select="'h2'"/>
    <xsl:map-entry key="'sect2'" select="'h3'"/>
    <xsl:map-entry key="'sect3'" select="'h4'"/>
    <xsl:map-entry key="'sect4'" select="'h5'"/>
    <xsl:map-entry key="'sect5'" select="'h5'"/>
    <xsl:map-entry key="'sect6'" select="'h5'"/>
    <xsl:map-entry key="'block'" select="'div'"/>
  </xsl:map>
</xsl:variable>

<xsl:template match="db:bridgehead">
  <xsl:variable name="renderas" as="xs:string">
    <xsl:choose>
      <xsl:when test="@renderas">
        <xsl:sequence select="@renderas/string()"/>
      </xsl:when>
      <xsl:when test="parent::db:section">
        <xsl:sequence select="'sect' || (count(ancestor::db:section)+1)"/>
      </xsl:when>
      <xsl:when test="parent::db:refsection">
        <xsl:sequence select="'sect' || (count(ancestor::db:refsection)+1)"/>
      </xsl:when>
      <xsl:when test="parent::db:sect5">
        <xsl:sequence select="'sect5'"/>
      </xsl:when>
      <xsl:when test="parent::db:sect1|parent::db:sect2|parent::db:sect3|parent::db:sect4">
        <xsl:sequence select="'sect' ||
                               (xs:integer(substring(local-name(parent::*), 5, 1)) + 1)"/>
      </xsl:when>
      <xsl:when test="parent::db:refsect1|parent::db:refsect2|parent::db:refsect3">
        <xsl:sequence select="'sect' ||
                               (xs:integer(substring(local-name(parent::*), 8, 1)) + 1)"/>
      </xsl:when>
      <xsl:when test="parent::db:article|parent::db:chapter|parent::db:appendix
                      |parent::db:preface|parent::db:partintro
                      |parent::db:part|parent::db:reference">
        <xsl:sequence select="'sect1'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'block'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="empty(map:get($v:bridgehead-map, $renderas))">
      <xsl:message select="'Unknown bridgehead renderas:', $renderas"/>
      <div>
        <xsl:apply-templates select="." mode="m:attributes">
          <xsl:with-param name="extra-classes" select="('title')"/>
        </xsl:apply-templates>
        <xsl:apply-templates/>
      </div>
    </xsl:when>
    <xsl:when test="map:get($v:bridgehead-map, $renderas) = 'div'">
      <div>
        <xsl:apply-templates select="." mode="m:attributes">
          <xsl:with-param name="extra-classes" select="('title')"/>
        </xsl:apply-templates>
        <xsl:apply-templates/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="{map:get($v:bridgehead-map, $renderas)}"
                   namespace="http://www.w3.org/1999/xhtml">
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
