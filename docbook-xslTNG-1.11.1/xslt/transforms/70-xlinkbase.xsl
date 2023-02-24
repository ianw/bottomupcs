<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="db mp v vp xlink xs"
                version="3.0">

<xsl:import href="../environment.xsl"/>

<xsl:variable name="vp:lb" select="'http://www.w3.org/1999/xlink/properties/linkbase'"/>

<xsl:template match="/">
  <xsl:document>
    <xsl:apply-templates/>
  </xsl:document>
</xsl:template>

<xsl:template match="db:info/db:extendedlink[*[@xlink:type='arc'
                                             and @xlink:arcrole=$vp:lb]]">
  <xsl:apply-templates select="*[@xlink:type='arc' and @xlink:arcrole=$vp:lb
                                 and @xlink:actuate='onLoad'
                                 and @xlink:from and @xlink:to]"
                       mode="mp:load-linkbase"/>
</xsl:template>

<xsl:template match="*" mode="mp:load-linkbase">
  <xsl:variable name="from" select="@xlink:from"/>
  <xsl:variable name="to" select="@xlink:to"/>

  <xsl:variable name="lfrom"
                select="(../*[@xlink:type='locator' and @xlink:label=$from])"/>
  <xsl:variable name="lto"
                select="(../*[@xlink:type='locator' and @xlink:label=$to])[1]"/>

  <xsl:for-each select="$lfrom">
    <xsl:if test="$lto and $lto/@xlink:href=''">
      <xsl:variable name="fn"
                    select="resolve-uri($lfrom/@xlink:href, base-uri($lfrom))"/>
      <xsl:message use-when="'linkbase' = $debug"
                   select="'Load linkbase:', $fn"/>
      <xsl:sequence
          select="doc(resolve-uri($lfrom/@xlink:href, base-uri($lfrom)))
                     //*[@xlink:type='extended']"/>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template match="element()">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
