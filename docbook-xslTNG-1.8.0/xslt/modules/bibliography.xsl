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

<xsl:template match="db:bibliography|db:bibliodiv|db:bibliolist">
  <xsl:variable name="gi" select="if (parent::*)
                                  then 'div'
                                  else 'article'"/>
  <xsl:element name="{$gi}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:biblioentry">
  <p>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:call-template name="t:biblioentry"/>
  </p>
</xsl:template>

<xsl:template match="db:bibliomixed">
  <p>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:choose>
      <xsl:when test="@xml:id and not(child::*[1]/self::db:abbrev)">
        <xsl:sequence select="'[' || @xml:id || '] '"/>
        <xsl:apply-templates mode="m:bibliomixed"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="m:bibliomixed"/>
      </xsl:otherwise>
    </xsl:choose>
  </p>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:bibliomset" mode="m:bibliomixed">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:bibliomixed"/>
  </span>
</xsl:template>

<xsl:template match="db:abbrev" mode="m:bibliomixed">
  <xsl:choose>
    <xsl:when test="empty(preceding-sibling::*)
                    and (normalize-space(preceding-sibling::text()) = '')">
      <!-- this is the citation -->
      <xsl:text>[</xsl:text>
      <span>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates mode="m:bibliomixed"/>
      </span>
      <xsl:text>] </xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <span>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates mode="m:bibliomixed"/>
      </span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:title" mode="m:bibliomixed">
  <xsl:choose>
    <xsl:when test="parent::db:bibliomset[@relation='article']">
      <q>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates/>
      </q>
    </xsl:when>
    <xsl:otherwise>
      <cite>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates/>
      </cite>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:address|db:publisher" mode="m:bibliomixed">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:bibliomixed"/>
  </span>
</xsl:template>

<xsl:template match="*" mode="m:bibliomixed">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="text()" mode="m:bibliomixed">
  <xsl:choose>
    <xsl:when test="parent::db:address">
      <!-- explicitly xsl:value-of because we need a text node -->
      <xsl:value-of select="replace(string(.), '&#10;', ' / ')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:releaseinfo" mode="m:bibliomixed">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:biblioentry"/>
  </span>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:biblioset" mode="m:biblioentry">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="db:title" mode="m:biblioentry">
  <xsl:choose>
    <xsl:when test="parent::db:biblioset[@relation='article']">
      <q>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates/>
      </q>
    </xsl:when>
    <xsl:otherwise>
      <cite>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates/>
      </cite>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:subtitle" mode="m:biblioentry">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:address|db:publisher" mode="m:biblioentry">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:biblioentry"/>
  </span>
</xsl:template>

<xsl:template match="db:collab|db:othercredit" mode="m:biblioentry">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="db:personname|db:orgname"
                         mode="m:biblioentry"/>
  </span>
</xsl:template>

<xsl:template match="db:confgroup" mode="m:biblioentry">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:biblioentry"/>
  </span>
</xsl:template>

<xsl:template match="db:confdates|db:conftitle|db:confsponsor|db:confnum"
              mode="m:biblioentry">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:biblioentry"/>
  </span>
  <xsl:text>. </xsl:text>
</xsl:template>

<xsl:template match="db:contractnum|db:contractsponsor
                     |db:edition|db:volumenum" mode="m:biblioentry">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:biblioentry"/>
  </span>
</xsl:template>

<xsl:template match="db:releaseinfo" mode="m:biblioentry">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:biblioentry"/>
  </span>
</xsl:template>

<xsl:template match="*" mode="m:biblioentry">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="text()" mode="m:biblioentry">
  <xsl:choose>
    <xsl:when test="parent::db:address">
      <!-- explicitly xsl:value-of because we need a text node -->
      <xsl:value-of select="replace(string(.), '&#10;', ' / ')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:authorgroup[not(parent::db:info)]">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:call-template name="t:person-name-list"/>
  </span>
</xsl:template>

<xsl:template match="db:biblioid|db:orgname|db:orgdiv|db:bibliosource
                     |db:bibliomisc|db:subtitle">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<!-- ============================================================ -->

</xsl:stylesheet>
