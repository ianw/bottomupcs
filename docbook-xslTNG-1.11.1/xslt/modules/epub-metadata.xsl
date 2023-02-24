<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:epub='http://docbook.org/ns/docbook/epub'
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.idpf.org/2007/opf"
                exclude-result-prefixes="#all"
                expand-text="yes"
                default-mode="m:epub-metadata"
                version="3.0">

<!-- N.B. The default namespace in this module is not HTML -->

<xsl:mode name="m:epub-metadata" on-no-match="shallow-skip"/>

<xsl:template match="/*/db:info">
  <xsl:if test="empty(dc:title)">
    <xsl:variable name="inline">
      <xsl:apply-templates select="/*" mode="m:headline-title"/>
    </xsl:variable>
    <xsl:variable name="id" select="(db:title/@xml:id,generate-id(.))[1]"/>

    <dc:title id="{$id}">{string($inline)}</dc:title>
    <meta refines="#{$id}" property="title-type">main</meta>
  </xsl:if>

  <xsl:if test="empty(dc:language)">
    <dc:language>{f:language(..)}</dc:language>
  </xsl:if>

  <meta property="dcterms:modified">
    <xsl:variable name="Z" select="xs:dayTimeDuration('PT0H')"/>
    <xsl:sequence select="format-dateTime(
                          adjust-dateTime-to-timezone(current-dateTime(), $Z),
                          '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
  </meta>

  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="epub:meta|epub:link">
  <xsl:element name="{local-name(.)}" namespace="http://www.idpf.org/2007/opf">
    <xsl:copy-of select="@*"/>
    <xsl:value-of select="."/>
  </xsl:element>
</xsl:template>

<xsl:template match="dc:title" priority="10">
  <xsl:variable name="id" select="(@xml:id,@id,generate-id(.))[1]"/>
  <xsl:element name="dc:{local-name(.)}" namespace="http://purl.org/dc/elements/1.1/">
    <xsl:copy-of select="@* except (@xml:id | @id)"/>
    <xsl:attribute name="id" select="$id"/>
    <xsl:value-of select="."/>
  </xsl:element>
  <meta refines="#{$id}" property="title-type">main</meta>
</xsl:template>

<xsl:template match="dc:*">
  <xsl:element name="dc:{local-name(.)}" namespace="http://purl.org/dc/elements/1.1/">
    <xsl:copy-of select="@*"/>
    <xsl:value-of select="."/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:publisher">
  <dc:publisher>{string(db:publishername)}</dc:publisher>
</xsl:template>

<xsl:template match="db:authorgroup">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:author">
  <xsl:variable name="inline">
    <xsl:apply-templates select="db:personname|db:orgname" mode="m:docbook"/>
  </xsl:variable>
  <xsl:variable name="id" select="(@xml:id,generate-id(.))[1]"/>
  <dc:creator id="{$id}">
    <xsl:text>{string($inline)}</xsl:text>
  </dc:creator>
  <meta refines="#{$id}" property="role" scheme="marc:relators">aut</meta>
</xsl:template>

<xsl:template match="db:editor">
  <xsl:variable name="inline">
    <xsl:apply-templates select="db:personname|db:orgname" mode="m:docbook"/>
  </xsl:variable>
  <xsl:variable name="id" select="(@xml:id,generate-id(.))[1]"/>
  <dc:contributor id="{$id}">
    <xsl:text>{string($inline)}</xsl:text>
  </dc:contributor>
  <meta refines="#{$id}" property="role" scheme="marc:relators">edt</meta>
</xsl:template>

<xsl:template match="db:othercredit">
  <xsl:variable name="inline">
    <xsl:apply-templates select="db:personname|db:orgname" mode="m:docbook"/>
  </xsl:variable>
  <xsl:variable name="id" select="(@xml:id,generate-id(.))[1]"/>
  <dc:contributor id="{$id}">
    <xsl:text>{string($inline)}</xsl:text>
  </dc:contributor>
  <xsl:choose>
    <xsl:when test="@class = 'copyeditor'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">edt</meta>
    </xsl:when>
    <xsl:when test="@class = 'graphicdesigner'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">bkd</meta>
    </xsl:when>
    <xsl:when test="@class = 'productioneditor'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">edt</meta>
    </xsl:when>
    <xsl:when test="@class = 'technicaleditor'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">edt</meta>
    </xsl:when>
    <xsl:when test="@class = 'translator'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">trl</meta>
    </xsl:when>
    <xsl:when test="@class = 'indexer'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">edt</meta>
    </xsl:when>
    <xsl:when test="@class = 'proofreader'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">pfr</meta>
    </xsl:when>
    <xsl:when test="@class = 'coverdesigner'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">cov</meta>
    </xsl:when>
    <xsl:when test="@class = 'interiordesigner'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">bkd</meta>
    </xsl:when>
    <xsl:when test="@class = 'illustrator'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">ill</meta>
    </xsl:when>
    <xsl:when test="@class = 'reviewer'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">rev</meta>
    </xsl:when>
    <xsl:when test="@class = 'typesetter'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">cmt</meta>
    </xsl:when>
    <xsl:when test="@class = 'conversion'">
      <meta refines="#{$id}" property="role" scheme="marc:relators">trc</meta>
    </xsl:when>
    <xsl:when test="@class = 'other'">
      <meta refines="#{$id}" property="role">{@otherclass/string()}</meta>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message select="'Unexpected class on othercredit: ' || @class"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
