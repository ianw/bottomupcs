<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:l="http://docbook.org/ns/docbook/l10n"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db dbe f fp l m map mp t v vp xs"
                version="3.0">
<!--
    prefix, label, separator, title, suffix : context (title, lot)

                  Section 3.4 The Title
                ^    ^   ^^^ ^    ^     ^
                |    |   ||| |    |     +- the suffix
                |    |   ||| |    +- the title
                |    |   ||| +- the number separator
                |    |   ||+- the intra-number separator
                |    |   |+- the number (3.4)
                |    |   +- the label separator
                |    +- the label
                +- the prefix
-->

<!-- label defaults to false;
     number defaults to false;
     inherit is ignored if number is false -->

<xsl:variable name="v:user-title-properties" as="element()*"/>

<xsl:variable name="v:title-properties" as="element()+"
              xmlns:db="http://docbook.org/ns/docbook">
  <xsl:sequence select="$v:user-title-properties"/>

  <title xpath="self::db:section[ancestor::db:preface]"
         label="false"/>

  <title xpath="self::db:section[parent::db:section]"
         number-format="{$section-numbers}"
         inherit="{$section-numbers-inherit}"/>

  <title xpath="self::db:section"
         number-format="{$section-numbers}"
         inherit="{$component-numbers-inherit}"/>

  <title xpath="self::db:sect1"
         number-format="{$section-numbers}"
         inherit="{$component-numbers-inherit}"/>

  <title xpath="self::db:sect2|self::db:sect3|self::db:sect4|self::db:sect5"
         number-format="{$section-numbers}"
         inherit="{$section-numbers-inherit}"/>

  <title xpath="self::db:refsection|self::db:refsect1|self::db:refsect2|self::db:refsect3"/>

  <title xpath="self::db:article"/>

  <title xpath="self::db:preface"/>

  <title xpath="self::db:chapter"
         number-format="1"
         label="true"
         inherit="{$division-numbers-inherit}"/>

  <title xpath="self::db:appendix"
         number-format="A"
         label="true"
         inherit="{$division-numbers-inherit}"/>

  <title xpath="self::db:part"
         label="true"
         number="true"
         number-format="I"/>

  <title xpath="self::db:reference"
         number-format="I"/>

  <title xpath="self::db:figure|self::db:table|self::db:equation|self::db:example"
         label="true"
         number-format="1"
         inherit="true"/>

  <title xpath="self::db:formalgroup"
         label="true"
         number-format="1"
         inherit="true"/>

  <title xpath="self::db:step|self::db:listitem[parent::db:orderedlist]"
         label="false"
         number="false"
         inherit="true"/>

  <title xpath="self::db:glosssee|self::db:glossseealso"
         label="true"/>

  <title xpath="self::db:see|self::db:seealso"
         label="true"/>

  <title xpath="self::db:question|self::db:answer"
         label="true"
         title="true"/>

  <title xpath="self::*"/>
</xsl:variable>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:headline">
  <xsl:param name="purpose" as="xs:string" required="yes"/>

  <xsl:variable name="properties" select="fp:title-properties(.)"/>

  <!--
  <xsl:message select="path(.), ':'"/>
  <xsl:for-each select="map:keys($properties)">
    <xsl:message select="'  prop:', ., '=', map:get($properties, .)"/>
  </xsl:for-each>
  -->

  <xsl:variable name="title" as="node()*">
    <xsl:apply-templates select="." mode="m:headline-title">
      <xsl:with-param name="purpose" select="$purpose"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="number" as="node()*">
    <xsl:if test="$properties?number">
      <xsl:choose>
        <xsl:when test="@label">
          <xsl:value-of select="@label/string()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="m:headline-number">
            <xsl:with-param name="purpose" select="$purpose"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="label" as="item()*">
    <xsl:if test="($properties?label and $purpose ne 'lot')
                  or ($properties?label-toc and $purpose eq 'lot')">
      <xsl:apply-templates select="." mode="m:headline-label">
        <xsl:with-param name="purpose" select="$purpose"/>
        <xsl:with-param name="number" select="$number"/>
        <xsl:with-param name="title" select="$title"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:variable>

  <xsl:apply-templates select="." mode="m:headline-prefix">
    <xsl:with-param name="purpose" select="$purpose"/>
    <xsl:with-param name="label" select="$label"/>
    <xsl:with-param name="number" select="$number"/>
    <xsl:with-param name="title" select="$title"/>
  </xsl:apply-templates>

  <xsl:if test="not(empty($label))">
    <span class="label">
      <xsl:sequence select="$label"/>
      <xsl:variable name="sep" as="node()*">
        <xsl:apply-templates select="." mode="m:headline-label-separator">
          <xsl:with-param name="purpose" select="$purpose"/>
          <xsl:with-param name="label" select="$label"/>
          <xsl:with-param name="number" select="$number"/>
          <xsl:with-param name="title" select="$title"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:if test="not(empty($sep))">
        <span class="sep">
          <xsl:sequence select="$sep"/>
        </span>
      </xsl:if>
    </span>
  </xsl:if>

  <xsl:if test="not(empty($number))">
    <span class="number">
      <xsl:sequence select="$number"/>
      <xsl:apply-templates select="." mode="m:headline-number-separator">
        <xsl:with-param name="purpose" select="$purpose"/>
        <xsl:with-param name="number" select="$number"/>
        <xsl:with-param name="title" select="$title"/>
      </xsl:apply-templates>
    </span>
  </xsl:if>

  <xsl:sequence select="$title"/>

  <xsl:apply-templates select="." mode="m:headline-suffix">
    <xsl:with-param name="purpose" select="$purpose"/>
    <xsl:with-param name="title" select="$title"/>
  </xsl:apply-templates>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:headline-prefix">
  <xsl:param name="purpose" as="xs:string" required="yes"/>
  <xsl:param name="label" as="item()*" required="yes"/>
  <xsl:param name="number" as="item()*" required="yes"/>
  <xsl:param name="title" as="node()*" required="yes"/>
  <xsl:sequence select="()"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:headline-label">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:param name="number" as="node()*" required="yes"/>
  <xsl:param name="title" as="node()*" required="yes"/>
  <xsl:sequence select="f:gentext(., 'label')"/>
</xsl:template>

<xsl:template match="db:formalgroup
                     |db:figure|db:example|db:table
                     |db:equation|db:procedure"
              priority="20"
              mode="m:headline-label">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:param name="number" as="node()*" required="yes"/>
  <xsl:param name="title" as="node()*" required="yes"/>
  <xsl:choose>
    <xsl:when test="$purpose = 'lot'">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:next-match>
        <xsl:with-param name="purpose" select="$purpose"/>
        <xsl:with-param name="number" select="$number"/>
        <xsl:with-param name="title" select="$title"/>
      </xsl:next-match>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:formalgroup" priority="10"
              mode="m:headline-label">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:param name="number" as="node()*" required="yes"/>
  <xsl:param name="title" as="node()*" required="yes"/>

  <xsl:variable name="ctx"
                select="(db:figure|db:table
                         |db:example|db:equation)[1]"/>

  <xsl:sequence select="f:gentext(., 'label', local-name($ctx))"/>
</xsl:template>

<xsl:template match="db:figure|db:example|db:table|db:equation|db:procedure"
              priority="10"
              mode="m:headline-label">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:param name="number" as="node()*" required="yes"/>
  <xsl:param name="title" as="node()*" required="yes"/>

  <xsl:choose>
    <xsl:when test="empty(parent::db:formalgroup)">
      <xsl:next-match>
        <xsl:with-param name="purpose" select="$purpose"/>
        <xsl:with-param name="number" select="$number"/>
        <xsl:with-param name="title" select="$title"/>
      </xsl:next-match>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:gentext(., 'label',
                                      'sub' || local-name(.))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:qandaentry" mode="m:headline-label">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:param name="number" as="node()*"/>
  <xsl:param name="title" as="node()*"/>
  <xsl:apply-templates select="db:question" mode="m:headline-label">
    <xsl:with-param name="purpose" select="$purpose"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:question" mode="m:headline-label">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:param name="number" as="node()*"/>
  <xsl:param name="title" as="node()*"/>

  <xsl:variable name="label"
                select="ancestor::db:qandaset[@defaultlabel][1]/@defaultlabel/string()"/>
  <xsl:variable name="label"
                select="if ($label)
                        then $label
                        else $qandaset-default-label"/>

  <xsl:choose>
    <xsl:when test="db:label">
      <xsl:apply-templates select="db:label"/>
    </xsl:when>
    <xsl:when test="$label = 'none'"/>
    <xsl:when test="$label = 'number'">
      <xsl:number from="db:qandaset" level="multiple" select=".."
                  count="db:qandaentry|db:qandadiv"/>
      <xsl:sequence select="f:post-label-punctuation(.)"/>
    </xsl:when>
    <xsl:when test="$label = 'qanda'">
      <xsl:text>Q:</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message
          select="'Unexpected qandaset label: ' || $label || ', using qanda'"/>
      <xsl:text>Q:</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:answer" mode="m:headline-label">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:param name="number" as="node()*"/>
  <xsl:param name="title" as="node()*"/>

  <xsl:variable name="label"
                select="ancestor::db:qandaset[@defaultlabel][1]/@defaultlabel/string()"/>
  <xsl:variable name="label"
                select="if ($label)
                        then $label
                        else $qandaset-default-label"/>

  <xsl:choose>
    <xsl:when test="db:label">
      <xsl:apply-templates select="db:label"/>
    </xsl:when>
    <xsl:when test="$label = 'none' or $label='number'"/>
    <xsl:when test="$label = 'qanda'">
      <xsl:text>A:</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message
          select="'Unexpected qandaset label: ' || $label || ', using qanda'"/>
      <xsl:text>A:</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:headline-label-separator">
  <xsl:param name="purpose" as="xs:string" required="yes"/>
  <xsl:param name="label" as="item()*" required="yes"/>
  <xsl:param name="number" as="item()*" required="yes"/>
  <xsl:param name="title" as="node()*" required="yes"/>
  <xsl:sequence select="f:label-separator(.)"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:headline-number">
  <xsl:param name="purpose" as="xs:string" required="yes"/>

  <xsl:variable name="properties" select="fp:title-properties(.)"/>

  <xsl:if test="exists(parent::*) and $properties?inherit">
    <xsl:variable name="pnum" as="node()*">
      <xsl:apply-templates select=".." mode="m:headline-number">
        <xsl:with-param name="purpose" select="$purpose"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:if test="exists($pnum)">
      <xsl:sequence select="$pnum"/>
      <span class="sep">
        <xsl:sequence select="f:intra-number-separator(.)"/>
      </span>
    </xsl:if>
  </xsl:if>

  <xsl:variable name="number"
                select="count(preceding-sibling::*
                              [node-name(.)=node-name(current())]) + 1"/>

  <xsl:number value="$number" format="{$properties?number-format}"/>
</xsl:template>

<xsl:template match="db:section" mode="m:headline-number">
  <xsl:param name="purpose" as="xs:string" required="yes"/>

  <xsl:variable name="properties" select="fp:title-properties(.)"/>

  <xsl:if test="exists(parent::*) and $properties?inherit">
    <xsl:variable name="pnum" as="node()*">
      <xsl:apply-templates select=".." mode="m:headline-number">
        <xsl:with-param name="purpose" select="$purpose"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:if test="exists($pnum)">
      <xsl:sequence select="$pnum"/>
      <span class="sep">
        <xsl:sequence select="f:intra-number-separator(.)"/>
      </span>
    </xsl:if>
  </xsl:if>

  <xsl:variable name="number"
                select="count(preceding-sibling::db:section) + 1"/>

  <xsl:number value="$number" format="{$properties?number-format}"/>
</xsl:template>

<!-- if there's a single appendix, don't number it -->
<xsl:template match="db:appendix" mode="m:headline-number">
  <xsl:param name="purpose" as="xs:string" required="yes"/>

  <xsl:variable name="properties" select="fp:title-properties(.)"/>

  <xsl:choose>
    <xsl:when test="not(f:is-true($number-single-appendix))
                    and not($properties?label)
                    and empty(preceding-sibling::db:appendix)
                    and empty(following-sibling::db:appendix)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:next-match>
        <xsl:with-param name="purpose" select="$purpose"/>
      </xsl:next-match>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:step" mode="m:headline-number">
  <xsl:param name="purpose" as="xs:string" required="yes"/>

  <xsl:variable name="properties" select="fp:title-properties(.)"/>

  <xsl:if test="exists(ancestor::db:step) and $properties?inherit">
    <xsl:variable name="pnum" as="node()*">
      <xsl:apply-templates select="ancestor::db:step[1]"
                           mode="m:headline-number">
        <xsl:with-param name="purpose" select="$purpose"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:if test="exists($pnum)">
      <xsl:sequence select="$pnum"/>
      <span class="sep">
        <xsl:sequence select="f:intra-number-separator(.)"/>
      </span>
    </xsl:if>
  </xsl:if>

  <xsl:variable name="number"
                select="count(preceding-sibling::db:step) + 1"/>

  <xsl:number value="$number" format="{f:step-numeration(.)}"/>
</xsl:template>

<xsl:template match="db:listitem[parent::db:orderedlist]" mode="m:headline-number">
  <xsl:param name="purpose" as="xs:string" required="yes"/>

  <xsl:variable name="properties" select="fp:title-properties(.)"/>

  <xsl:if test="exists(ancestor::db:listitem[parent::db:orderedlist])
                and $properties?inherit">
    <xsl:variable name="pnum" as="node()*">
      <xsl:apply-templates
          select="ancestor::db:listitem[parent::db:orderedlist][1]"
          mode="m:headline-number">
        <xsl:with-param name="purpose" select="$purpose"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:if test="exists($pnum)">
      <xsl:sequence select="$pnum"/>
      <span class="sep">
        <xsl:sequence select="f:intra-number-separator(.)"/>
      </span>
    </xsl:if>
  </xsl:if>

  <xsl:variable name="number"
                select="count(preceding-sibling::db:listitem) + 1"/>

  <xsl:number value="$number" format="{f:orderedlist-item-numeration(.)}"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:headline-number-separator">
  <xsl:param name="purpose" as="xs:string" required="yes"/>
  <xsl:param name="number" as="node()*" required="yes"/>
  <xsl:param name="title" as="node()*" required="yes"/>
  <xsl:choose>
    <xsl:when test="self::db:set|self::db:book|self::db:part
                    |self::db:reference|self::db:chapter|self::db:appendix">
      <span class="sep">. </span>
    </xsl:when>
    <xsl:otherwise>
      <span class="sep"> </span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:headline-title">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>

  <xsl:choose>
    <xsl:when test="$purpose = 'title' or not(db:info/db:titleabbrev)">
      <xsl:apply-templates select="db:info/db:title" mode="m:title">
        <xsl:with-param name="purpose" select="$purpose"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="db:info/db:titleabbrev" mode="m:title">
        <xsl:with-param name="purpose" select="$purpose"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:refentry" mode="m:headline-title">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:choose>
    <xsl:when test="db:refmeta">
      <xsl:apply-templates select="db:refmeta" mode="m:headline-title">
        <xsl:with-param name="purpose" select="$purpose"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="db:refnamediv/db:refname[1]" mode="m:headline-title">
        <xsl:with-param name="purpose" select="$purpose"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:refmeta" mode="m:headline-title">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:apply-templates select="db:refentrytitle/node()"/>
  <xsl:apply-templates select="db:manvolnum"/>
</xsl:template>

<xsl:template match="db:refnamediv" mode="m:headline-title">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:apply-templates select="db:refname[1]" mode="m:headline-title">
    <xsl:with-param name="purpose" select="$purpose"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:refname" mode="m:headline-title">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:apply-templates mode="m:title">
    <xsl:with-param name="purpose" select="$purpose"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:question" mode="m:headline-title">
  <xsl:param name="purpose" as="xs:string" select="'title'"/>
  <xsl:apply-templates select="*[1]" mode="m:title">
    <xsl:with-param name="purpose" select="$purpose"/>
  </xsl:apply-templates>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:headline-suffix">
  <xsl:param name="purpose" as="xs:string" required="yes"/>
  <xsl:param name="title" as="node()*" required="yes"/>

  <xsl:sequence select="()"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="fp:document-title-properties" as="element()*" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="root($node)/*/db:info/v:title"/>
</xsl:function>

<xsl:function name="fp:title-properties" as="map(*)" cache="yes">
  <xsl:param name="node" as="element()"/>

  <!-- You might think it would be convenient to accumulate the properties,
       but that requires making every property explicit on every element
       in order to prevent broader matches from overriding narrower ones.
       So there wouldn't be any point. -->

  <xsl:variable name="prop" as="element()?">
    <xsl:iterate select="(fp:document-title-properties($node), $v:title-properties)">
      <xsl:variable name="test" as="element()*">
        <xsl:evaluate context-item="$node" xpath="@xpath"/>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$test">
          <xsl:sequence select="."/>
          <xsl:break/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:next-iteration/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:variable>

  <xsl:variable name="number" as="xs:boolean"
                select="exists($prop/@number-format)
                        and (not(exists($prop/@number)) or f:is-true($prop/@number))"/>

  <xsl:variable name="format" as="xs:string?"
                select="if ($number)
                        then ($prop/@number-format, '1')[1]
                        else ()"/>

  <xsl:variable name="label-toc" as="xs:boolean"
                select="if ($prop/@label-toc)
                        then f:is-true($prop/@label-toc)
                        else f:is-true($prop/@label)"/>

  <xsl:message use-when="false()"
               select="node-name($node), ' ', f:is-true($prop/@label), ' ', $number"/>
  <xsl:message use-when="false()"
               select="$prop"/>

  <xsl:sequence select="map {
    'label':         f:is-true($prop/@label),
    'label-toc':     $label-toc,
    'number':        $number,
    'number-format': $prop/@number-format/string(),
    'inherit':       f:is-true($prop/@inherit)
    }"/>
</xsl:function>

<!-- ============================================================ -->

<xsl:template match="db:title|db:titleabbrev" mode="m:title">
  <xsl:param name="purpose" as="xs:string" required="yes"/>

  <xsl:choose>
    <xsl:when test="$purpose = 'title'">
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="title" as="item()*">
        <xsl:apply-templates/>
      </xsl:variable>
      <xsl:apply-templates select="$title" mode="mp:strip-links"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template xmlns:h="http://www.w3.org/1999/xhtml"
              match="h:db-footnote|h:db-annotation" mode="mp:strip-links"/>

<xsl:template xmlns:h="http://www.w3.org/1999/xhtml"
              match="h:a" mode="mp:strip-links">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="element()" mode="mp:strip-links">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()" mode="mp:strip-links"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()"
              mode="mp:strip-links">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
