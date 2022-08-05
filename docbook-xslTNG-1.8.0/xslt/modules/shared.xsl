<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f m map vp xs"
                version="3.0">

<xsl:param name="generated-id-root" select="'R'"/>
<!-- Historically, this was ".", but if you do that, you can't find
     elements by ID using JavaScript querySelector because "." is
     a separator in CSS. -->
<xsl:param name="generated-id-sep" select="'_'"/>

<xsl:variable name="vp:gidmap" select="map {
  'acknowledgements': 'ack',
  'appendix': 'ap',
  'book': 'bo',
  'chapter': 'ch',
  'colophon': 'co',
  'dedication': 'ded',
  'equation': 'eq',
  'example': 'ex',
  'figure': 'fig',
  'part': 'part',
  'preface': 'p',
  'procedure': 'proc',
  'refentry': 're',
  'reference': 'ref',
  'refsect1': 'rs1',
  'refsect2': 'rs2',
  'refsect3': 'rs3',
  'sect1': 's1_',
  'sect2': 's2_',
  'sect3': 's3_',
  'sect4': 's4_',
  'sect5': 's5_',
  'section': 's',
  'table': 'tab',
  'glossary': 'g',
  'glossdiv': 'gd',
  'glossentry': 'ge',
  'glossterm': 'gt',
  'bibliography': 'bi',
  'bibliodiv': 'bd'
  }"/>

<xsl:function name="f:generate-id" as="xs:string" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="f:generate-id($node, true())"/>
</xsl:function>

<xsl:function name="f:generate-id" as="xs:string" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="use-xml-id" as="xs:boolean"/>
  <xsl:choose>
    <xsl:when test="$use-xml-id and $node/@xml:id">
      <xsl:sequence select="$node/@xml:id/string()"/>
    </xsl:when>
    <xsl:when test="empty($node/parent::*)">
      <xsl:sequence select="$generated-id-root"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="aid" select="f:generate-id($node/parent::*, $use-xml-id)"/>
      <xsl:variable name="type" select="(map:get($vp:gidmap, local-name($node)),
                                         local-name($node))[1]"/>
      <xsl:variable name="prec"
                    select="$node/preceding-sibling::*[node-name(.)=node-name($node)]"/>
      <xsl:sequence
          select="$aid || $generated-id-sep || $type || string(count($prec)+1)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:id" as="xs:string" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="if ($node/@xml:id)
                        then $node/@xml:id
                        else f:generate-id($node)"/>
</xsl:function>

<xsl:function name="f:unique-id" as="xs:string" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="f:generate-id($node, false())"/>
</xsl:function>

</xsl:stylesheet>
