<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f fp m mp t xlink xs"
                version="3.0">

<xsl:template match="db:footnote">
  <sup id="{f:id(.)}-fref" db-footnote="{fp:footnote-number(.)}"
       class="footnote-number{
              if (ancestor::db:table or ancestor::db:informaltable)
              then ' table-footnote'
              else ()
              }">
    <a href="#{f:id(.)}-fnote">
      <xsl:apply-templates select="." mode="m:footnote-number"/>
    </a>
  </sup>
  <db-footnote id="{f:id(.)}-fnote" db-footnote="{fp:footnote-number(.)}">
    <xsl:apply-templates select="." mode="m:footnotes"/>
  </db-footnote>
</xsl:template>

<xsl:template match="db:footnoteref">
  <xsl:variable name="linkend"
                select="(@linkend,
                        if (starts-with(@xlink:href, '#'))
                        then substring-after(@xlink:href, '#')
                        else ())[1]"/>
  <xsl:variable name="target"
                select="if ($linkend)
                        then key('id', $linkend)[1]
                        else ()"/>
  <xsl:choose>
    <xsl:when test="empty($target)">
      <xsl:message select="'Footnote link to non-existent ID: ' || $linkend"/>
      <sup class="footnote-number">
        <xsl:sequence select="'[???' || $linkend || '???]'"/>
      </sup>
    </xsl:when>
    <xsl:otherwise>
      <sup id="{f:id(.)}-fref" db-footnote="{fp:footnote-number($target)}"
           class="footnote-number{
                  if ($target/ancestor::db:table or $target/ancestor::db:informaltable)
                  then ' table-footnote'
                  else ()
                  }">
        <a href="#{f:id($target)}-fnote">
          <xsl:apply-templates select="$target" mode="m:footnote-number"/>
        </a>
      </sup>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:function name="fp:footnote-number" as="xs:integer" cache="yes">
  <xsl:param name="node" as="element(db:footnote)"/>
  <xsl:apply-templates select="$node" mode="mp:footnote-number"/>
</xsl:function>

<xsl:template match="db:footnote" as="xs:integer" mode="mp:footnote-number">
  <xsl:variable name="nearest"
                select="(ancestor::db:table
                        |ancestor::db:informaltable)[last()]"/>

  <xsl:variable name="fnum" as="xs:string">
    <xsl:choose>
      <xsl:when test="empty($nearest)">
        <xsl:variable name="pfoot" select="count(preceding::db:footnote)"/>
        <xsl:variable name="ptfoot"
              select="count(preceding::db:footnote[ancestor::db:table])
                      + count(preceding::db:footnote[ancestor::db:informaltable])"/>
        <xsl:value-of select="$pfoot - $ptfoot + 1"/>
      </xsl:when>
      <xsl:when test="$nearest/self::db:informaltable">
        <xsl:number format="1" from="db:informaltable" level="any"/>
      </xsl:when>
      <xsl:when test="$nearest/self::db:table">
        <xsl:number format="1" from="db:table" level="any"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Error: failed to enumerate footnote:</xsl:message>
        <xsl:message select="."/>
        <xsl:sequence select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:sequence select="xs:integer($fnum)"/>
</xsl:template>

<xsl:template match="db:footnote" mode="m:footnote-number">
  <xsl:variable name="nearest"
                select="(ancestor::db:table
                        |ancestor::db:informaltable)[last()]"/>

  <xsl:variable name="fnum" select="fp:footnote-number(.)"/>

  <xsl:variable name="marks"
                select="if (empty($nearest))
                        then $footnote-numeration
                        else $table-footnote-numeration"/>

  <xsl:sequence select="fp:footnote-mark($fnum, $marks)"/>
</xsl:template>

<xsl:function name="fp:footnote-mark" as="xs:string">
  <xsl:param name="number" as="xs:integer"/>
  <xsl:param name="marks" as="xs:string+"/>

  <xsl:choose>
    <xsl:when test="$number lt count($marks)">
      <xsl:sequence select="$marks[$number]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:number value="$number" format="{$marks[count($marks)]}"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:template match="db:footnote" mode="m:footnotes">
  <div class="footnote" id="{f:id(.)}-fnote">
    <div class="footnote-number">
      <sup db-footnote="{fp:footnote-number(.)}"
           class="footnote-number{
                  if (ancestor::db:table or ancestor::db:informaltable)
                  then ' table-footnote'
                  else ()
                  }">
        <a href="#{f:id(.)}-fref">
          <xsl:apply-templates select="." mode="m:footnote-number"/>
        </a>
      </sup>
    </div>
    <div class="footnote-body">
      <xsl:apply-templates/>
    </div>
  </div>
</xsl:template>

<xsl:template name="t:table-footnotes">
  <xsl:param name="footnotes" as="element(db:footnote)+" required="yes"/>

  <div class="footnotes table-footnotes">
    <xsl:apply-templates select="$footnotes" mode="m:footnotes"/>
  </div>
</xsl:template>

</xsl:stylesheet>
