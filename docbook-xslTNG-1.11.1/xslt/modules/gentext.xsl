<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:l="http://docbook.org/ns/docbook/l10n"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:n="http://docbook.org/ns/docbook/l10n/number"
                xmlns:t="http://docbook.org/ns/docbook/l10n/title"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f fp l m map n t v vp xs"
                version="3.0">

<xsl:key name="l:string" match="l:string" use="@key"/>
<xsl:key name="l:style" match="l:style" use="@key"/>
<xsl:key name="l:gentext" match="l:gentext" use="@name"/>
<xsl:key name="l:tokens" match="l:tokens" use="../@name || '/' || @key"/>

<xsl:function name="f:locales" as="xs:string+" cache="yes">
  <xsl:param name="context" as="document-node()"/>
  <xsl:sequence select="distinct-values(('en', $default-language, $context//@xml:lang))"/>
</xsl:function>  

<xsl:function name="fp:l10n" as="map(*)" cache="yes">
  <xsl:param name="context" as="document-node()"/>

  <xsl:variable name="localizations" as="map(*)+">
    <xsl:for-each select="f:locales($context)">
      <xsl:variable name="locale" select="."/>
      <xsl:variable name="doc" select="doc('../locale/' || $locale || '.xml')"/>
      <xsl:sequence select="map:entry($doc/l:l10n/@language, $doc)"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:sequence select="map:merge($localizations)"/>
</xsl:function>

<xsl:function name="f:language" as="xs:string" cache="yes">
  <xsl:param name="node" as="node()"/>

  <xsl:variable name="nearest-lang"
                select="$node/ancestor-or-self::*[@xml:lang][1]"/>

  <xsl:choose>
    <xsl:when test="$nearest-lang">
      <xsl:sequence select="$nearest-lang/@xml:lang/string()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="($default-language, 'en')[1]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:localization" as="element(l:l10n)?">
  <xsl:param name="node" as="node()"/>
  <xsl:sequence select="fp:localization($node, f:language($node), true())"/>
</xsl:function>

<xsl:function name="fp:localization" as="element(l:l10n)?">
  <xsl:param name="node" as="node()"/>
  <xsl:param name="lang" as="xs:string"/>
  <xsl:sequence select="fp:localization($node, $lang, true())"/>
</xsl:function>

<xsl:function name="fp:localization" as="element(l:l10n)?">
  <xsl:param name="node" as="node()"/>
  <xsl:param name="lang" as="xs:string"/>
  <xsl:param name="warn" as="xs:boolean"/>

  <xsl:variable name="l10n" select="map:get(fp:l10n($node/root()), $lang)/l:l10n"/>

  <xsl:if test="$warn and empty($l10n)">
    <xsl:message expand-text="yes">No localization data for {$lang}</xsl:message>
  </xsl:if>

  <xsl:sequence select="$l10n"/>
</xsl:function>

<xsl:function name="fp:existing-localization" as="element(l:l10n)">
  <xsl:param name="node" as="node()"/>

  <xsl:variable name="lang" select="f:language($node)"/>

  <xsl:variable name="l10n" select="fp:localization($node)"/>
  <xsl:variable name="l10n"
                select="if (empty($l10n) and $default-language ne $lang)
                        then fp:localization($node, $default-language)
                        else $l10n"/>
  <xsl:sequence select="if (empty($l10n))
                        then fp:localization($node, 'en')
                        else $l10n"/>
</xsl:function>

<xsl:function name="f:gentext" as="item()*">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="context" as="xs:string"/>
  <xsl:sequence select="fp:gentext($node, $context, local-name($node), true())"/>
</xsl:function>

<xsl:function name="f:gentext" as="item()*">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="context" as="xs:string"/>
  <xsl:param name="key" as="xs:string"/>
  <xsl:sequence select="fp:gentext($node, $context, $key, true())"/>
</xsl:function>

<xsl:function name="fp:gentext" as="item()*">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="context" as="xs:string"/>
  <xsl:param name="key" as="xs:string"/>
  <xsl:param name="report-errors" as="xs:boolean"/>

  <xsl:variable name="l10n"
                select="fp:existing-localization($node)"/>

  <xsl:variable name="tokens"
                select="key('l:tokens', $context || '/' || $key, root($l10n))"/>

  <xsl:if test="$report-errors and count($tokens) gt 1">
    <xsl:message
        select="'Multiple tokens match '
                || $context || '/' || $key
                || ' for ' || f:language($node)"/>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="empty($tokens) and not($report-errors)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:when test="empty($tokens)">
      <xsl:if test="$report-errors">
      <xsl:message select="'No tokens match '
                           || $context || '/' || $key
                           || ' for ' || f:language($node)
                           || ' using MISSING'"/>
      </xsl:if>
      <xsl:sequence select="'MISSING'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$tokens[1]/node()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>
