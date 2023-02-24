<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db dbe f fp h m mp t v xs"
                version="3.0">

<xsl:function name="f:chunk" as="attribute()*">
  <xsl:param name="node" as="element()"/>

  <xsl:if test="$v:chunk">
    <xsl:if test="fp:chunk-include($node) and not(fp:chunk-exclude($node))">
      <xsl:attribute name="db-chunk"
                     select="f:chunk-filename($node)"/>
      <xsl:attribute name="db-id" select="generate-id($node)"/>
      <xsl:sequence select="fp:chunk-navigation($node)"/>
    </xsl:if>
  </xsl:if>
</xsl:function>

<xsl:function name="fp:chunk-include" as="xs:boolean">
  <xsl:param name="node" as="element()"/>
  <xsl:choose>
    <xsl:when test="fp:matches-expr($node, $chunk-include)">
      <xsl:choose>
        <xsl:when test="$node/self::db:sect1">
          <xsl:sequence select="$chunk-section-depth gt 0"/>
        </xsl:when>
        <xsl:when test="$node/self::db:sect2">
          <xsl:sequence select="$chunk-section-depth gt 1"/>
        </xsl:when>
        <xsl:when test="$node/self::db:sect3">
          <xsl:sequence select="$chunk-section-depth gt 2"/>
        </xsl:when>
        <xsl:when test="$node/self::db:sect3">
          <xsl:sequence select="$chunk-section-depth gt 3"/>
        </xsl:when>
        <xsl:when test="$node/self::db:sect4">
          <xsl:sequence select="$chunk-section-depth gt 4"/>
        </xsl:when>
        <xsl:when test="$node/self::db:sect5">
          <xsl:sequence select="$chunk-section-depth gt 5"/>
        </xsl:when>
        <xsl:when test="$node/self::db:section">
          <xsl:variable name="depth"
                        select="count($node/ancestor::db:section)"/>
          <xsl:sequence select="$chunk-section-depth gt $depth"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="true()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:chunk-exclude" as="xs:boolean">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="fp:matches-expr($node, $chunk-exclude)"/>
</xsl:function>
  
<xsl:function name="fp:matches-expr" as="xs:boolean">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="expr" as="xs:string*"/>

  <xsl:variable name="nscontext" as="element()">
    <ns>
      <xsl:copy-of select="$v:chunk-filter-namespaces"/>
    </ns>
  </xsl:variable>

  <xsl:variable name="matched" as="xs:boolean?">
    <xsl:iterate select="$expr">
      <xsl:variable name="match" as="element()?">
        <xsl:evaluate context-item="$node" xpath="."
                      namespace-context="$nscontext"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$match">
          <xsl:sequence select="true()"/>
          <xsl:break/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:next-iteration/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:variable>

  <xsl:sequence select="exists($matched)"/>
</xsl:function>

<xsl:function name="f:chunk-filename" as="xs:string">
  <xsl:param name="node" as="element()"/>

  <xsl:variable name="pi-filename" as="xs:string?">
    <xsl:choose>
      <xsl:when test="f:pi($node, 'filename')">
        <xsl:sequence select="f:pi($node, 'filename')"/>
      </xsl:when>
      <xsl:when test="f:pi($node/db:info, 'filename')">
        <xsl:sequence select="f:pi($node/db:info, 'filename')"/>
      </xsl:when>
      <!-- href is commonly used instead of filename -->
      <xsl:when test="f:pi($node, 'href')">
        <xsl:sequence select="f:pi($node, 'href')"/>
      </xsl:when>
      <xsl:when test="f:pi($node/db:info, 'href')">
        <xsl:sequence select="f:pi($node/db:info, 'href')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="exists($pi-filename)">
      <xsl:sequence select="if (contains($pi-filename, '.'))
                            then $pi-filename
                            else $pi-filename || $html-extension"/>
    </xsl:when>
    <xsl:when test="f:pi($node, 'basename')">
      <xsl:sequence select="f:pi($node, 'basename') || $html-extension"/>
    </xsl:when>
    <xsl:when test="f:pi($node/db:info, 'basename')">
      <xsl:sequence select="f:pi($node/db:info, 'basename') || $html-extension"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="name" as="xs:string?">
        <xsl:apply-templates select="$node" mode="m:chunk-filename"/>
      </xsl:variable>
      <xsl:sequence select="if (empty($name))
                            then f:generate-id($node) || $html-extension
                            else $name || $html-extension"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="fp:chunk-navigation" as="attribute()*">
  <xsl:param name="node" as="element()"/>

  <xsl:variable name="nav" select="(f:pi($node, 'navigation'),
                                    f:pi($node/db:info, 'navigation'))[1]"/>
  <xsl:if test="$nav">
    <xsl:attribute name="db-navigation" select="$nav"/>
  </xsl:if>

  <xsl:variable name="nav" select="(f:pi($node, 'top-navigation'),
                                    f:pi($node/db:info, 'top-navigation'))[1]"/>
  <xsl:if test="$nav">
    <xsl:attribute name="db-top-navigation" select="$nav"/>
  </xsl:if>

  <xsl:variable name="nav" select="(f:pi($node, 'bottom-navigation'),
                                    f:pi($node/db:info, 'bottom-navigation'))[1]"/>
  <xsl:if test="$nav">
    <xsl:attribute name="db-bottom-navigation" select="$nav"/>
  </xsl:if>
</xsl:function>


<xsl:function name="fp:trim-common-prefix" as="xs:string" cache="yes">
  <xsl:param name="source" as="xs:string"/>
  <xsl:param name="target" as="xs:string"/>

  <xsl:variable name="tail"
                select="fp:trim-common-parts(
                           tokenize($source, '/'),
                           tokenize($target, '/'))"/>

  <xsl:sequence select="string-join($tail, '/')"/>
</xsl:function>

<xsl:function name="fp:trim-common-parts" as="xs:string*">
  <xsl:param name="source" as="xs:string*"/>
  <xsl:param name="target" as="xs:string*"/>

  <xsl:choose>
    <xsl:when test="empty($source) or empty($target)">
      <xsl:sequence select="$source"/>
    </xsl:when>
    <xsl:when test="$source[1] ne $target[1]">
      <xsl:sequence select="$source"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fp:trim-common-parts(subsequence($source, 2),
                                                 subsequence($target, 2))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:root-base-uri" as="xs:anyURI" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="resolve-uri($chunk-output-base-uri, base-uri(root($node)/*))"/>
</xsl:function>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:chunk-filename">
  <xsl:value-of select="f:generate-id(.)"/>
</xsl:template>

<xsl:template match="db:set" mode="m:chunk-filename">
  <xsl:if test="preceding-sibling::* or following-sibling::*">
    <xsl:variable name="number" as="xs:string">
      <xsl:number format="01" level="single"/>
    </xsl:variable>
    <xsl:sequence select="'set'||$number"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:book" mode="m:chunk-filename">
  <xsl:if test="preceding-sibling::* or following-sibling::*">
    <xsl:variable name="number" as="xs:string">
      <xsl:number format="01" level="single"/>
    </xsl:variable>
    <xsl:variable name="parent" as="xs:string?">
      <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
    </xsl:variable>
    <xsl:sequence select="string-join(($parent, 'bk', $number), '')"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:acknowledgements" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'ack', $number), '')"/>
</xsl:template>

<xsl:template match="db:appendix" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="a" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'app', $number), '')"/>
</xsl:template>

<xsl:template match="db:article" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'ar', $number), '')"/>
</xsl:template>

<xsl:template match="db:bibliography" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'bib', $number), '')"/>
</xsl:template>

<xsl:template match="db:chapter" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'ch', $number), '')"/>
</xsl:template>

<xsl:template match="db:colophon" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'col', $number), '')"/>
</xsl:template>

<xsl:template match="db:dedication" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'ded', $number), '')"/>
</xsl:template>

<xsl:template match="db:glossary" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'gloss', $number), '')"/>
</xsl:template>

<xsl:template match="db:index" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'idx', $number), '')"/>
</xsl:template>

<xsl:template match="db:part" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="i" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'part', $number), '')"/>
</xsl:template>

<xsl:template match="db:preface" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'pf', $number), '')"/>
</xsl:template>

<xsl:template match="db:reference" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'ref', $number), '')"/>
</xsl:template>

<xsl:template match="db:refentry" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="001" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'mp', $number), '')"/>
</xsl:template>

<xsl:template match="db:topic" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="001" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 'top', $number), '')"/>
</xsl:template>

<xsl:template match="db:sect1|db:sect2|db:sect3|db:sect4|db:sect5"
                     mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 's', $number), '')"/>
</xsl:template>

<xsl:template match="db:section" mode="m:chunk-filename">
  <xsl:variable name="number" as="xs:string">
    <xsl:number format="01" level="single"
                count="db:section"/>
  </xsl:variable>
  <xsl:variable name="parent" as="xs:string?">
    <xsl:apply-templates select="parent::*" mode="m:chunk-filename"/>
  </xsl:variable>
  <xsl:sequence select="string-join(($parent, 's', $number), '')"/>
</xsl:template>

<!-- ============================================================ -->

</xsl:stylesheet>
