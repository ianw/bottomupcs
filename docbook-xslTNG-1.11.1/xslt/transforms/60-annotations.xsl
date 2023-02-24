<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:ghost="http://docbook.org/ns/docbook/ephemeral"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="array db f ghost map mp xs"
                version="3.0">

<xsl:import href="../environment.xsl"/>

<xsl:key name="annotations" match="db:annotation" use="@xml:id"/>

<xsl:variable name="root" select="/"/>

<xsl:variable name="_annotation-targets" as="map(*)*">
  <xsl:for-each select="//db:annotation[@annotates]">
    <xsl:variable name="annotation" select="."/>

    <xsl:variable name="ids" as="xs:string*">
      <xsl:choose>
        <xsl:when test="contains(@annotates, 'xpath:')">
          <xsl:sequence
              select="tokenize(normalize-space(substring-before(@annotates, 'xpath:')), '\s+')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="tokenize(normalize-space(@annotates), '\s+')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:for-each select="$ids">
      <xsl:if test="not(. castable as xs:NCName)">
        <xsl:message select="'Warning: invalid token in annotates: ' || ."/>
      </xsl:if>
    </xsl:for-each>

    <!-- Ignore annotations that point to elements that don't exists -->
    <xsl:for-each select="$ids">
      <xsl:for-each select="key('id', ., $root)">
        <xsl:map>
          <xsl:map-entry key="generate-id(.)" select="generate-id($annotation)"/>
        </xsl:map>
      </xsl:for-each>
    </xsl:for-each>

    <xsl:if test="contains(@annotates, 'xpath:')">
      <xsl:variable name="expr" select="substring-after(@annotates, 'xpath:')"/>
      <xsl:variable name="targets" as="element()*">
        <xsl:evaluate xpath="$expr" as="element()*"
                      context-item="." namespace-context="."/>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="empty($targets)">
          <xsl:message select="'Warning: no matches for annotation: ' || $expr"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$targets">
            <xsl:map>
              <xsl:map-entry key="generate-id(.)" select="generate-id($annotation)"/>
            </xsl:map>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:for-each>

  <xsl:for-each select="//*[@annotations]">
    <xsl:variable name="target" select="."/>
    <xsl:for-each select="tokenize(normalize-space(@annotations), '\s+')">
      <xsl:choose>
        <xsl:when test="empty(key('id', ., $root))">
          <xsl:message select="'Warning: no annotations match: ' || ."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="key('id', ., $root)">
            <xsl:map>
              <xsl:map-entry key="generate-id($target)" select="generate-id(.)"/>
            </xsl:map>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:for-each>
</xsl:variable>

<xsl:variable name="annotation-targets" as="map(*)">
  <xsl:variable name="targets" as="xs:string*">
    <xsl:for-each select="$_annotation-targets">
      <xsl:sequence select="map:keys(.)"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:map>
    <xsl:for-each select="distinct-values($targets)">
      <xsl:variable name="target" select="."/>
      <xsl:variable name="annotations" as="xs:string*">
        <xsl:for-each select="$_annotation-targets">
          <xsl:if test="$target = map:keys(.)">
            <xsl:sequence select="map:get(., $target)"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:map-entry key="$target" select="array { distinct-values($annotations) }"/>
    </xsl:for-each>
  </xsl:map>
</xsl:variable>

<xsl:template match="/">
  <xsl:if test="$annotation-placement != 'before'
                and $annotation-placement != 'after'">
    <xsl:message terminate="yes"
                 >The $annotation-placement parameter must be ‘before’ or ‘after’</xsl:message>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="empty(//db:annotation)">
      <xsl:sequence select="."/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="doc">
        <xsl:apply-templates/>
      </xsl:variable>
      <xsl:document>
        <xsl:apply-templates select="$doc/node()" mode="mp:move-to-end">
          <xsl:with-param name="annotations" select="//db:annotation"/>
        </xsl:apply-templates>
      </xsl:document>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:annotation" priority="100"/>

<!-- Output a ghost:annotation everywhere an annotation is used -->
<xsl:template match="*[map:contains($annotation-targets, generate-id(.))]">
  <xsl:variable name="annotations" as="element(db:annotation)+">
    <xsl:for-each select="array:flatten(map:get($annotation-targets, generate-id(.)))">
      <xsl:sequence select="key('genid', ., $root)"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="before-annotations" as="element(db:annotation)*">
    <xsl:for-each select="$annotations">
      <xsl:if test="($annotation-placement = 'before' and not(contains-token(@role, 'after')))
                    or contains-token(@role, 'before')">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="after-annotations" as="element(db:annotation)*"
                select="$annotations except $before-annotations"/>

  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:for-each select="$before-annotations">
      <ghost:annotation linkend="{f:generate-id(.)}" placement="before"/>
    </xsl:for-each>
    <xsl:apply-templates select="node()"/>
    <xsl:for-each select="$after-annotations">
      <ghost:annotation linkend="{f:generate-id(.)}" placement="after"/>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

<!--
<xsl:template match="*[@xml:id] | *[@annotations]">
  <xsl:variable name="points-to-me"
                select="//db:annotation[tokenize(@annotates, '\s+')
                                        = current()/@xml:id]"/>
  <xsl:variable name="i-point-to"
                select="key('annotations', tokenize(@annotations, '\s+'))"/>

  <xsl:variable name="annotations" select="($points-to-me union $i-point-to)"/>

  <xsl:variable name="before-annotations" as="element(db:annotation)*">
    <xsl:for-each select="$annotations">
      <xsl:if test="$annotation-placement = 'before'
                    or (contains-token(@role, 'before')
                        and not(contains-token(@role, 'after')))">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="after-annotations" as="element(db:annotation)*"
                select="$annotations except $before-annotations"/>

  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:for-each select="$before-annotations">
      <ghost:annotation linkend="{f:generate-id(.)}" placement="before"/>
    </xsl:for-each>
    <xsl:apply-templates select="node()"/>
    <xsl:for-each select="$after-annotations">
      <ghost:annotation linkend="{f:generate-id(.)}" placement="after"/>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>
-->

<xsl:template match="element()">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="/*" priority="100" mode="mp:move-to-end">
  <xsl:param name="annotations" as="element(db:annotation)+"/>
  <xsl:copy>
    <xsl:apply-templates select="@*,node()" mode="mp:move-to-end"/>
    <xsl:for-each select="$annotations">
      <xsl:copy>
        <xsl:if test="empty(@xml:id)">
          <xsl:attribute name="xml:id" select="f:generate-id(.)"/>
        </xsl:if>
        <xsl:sequence select="@*,node()"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

<xsl:template match="element()" mode="mp:move-to-end">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()" mode="mp:move-to-end"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()"
              mode="mp:move-to-end">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
