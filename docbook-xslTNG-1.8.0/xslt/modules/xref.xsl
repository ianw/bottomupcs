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

    section called Section 3.4 The Title

                             in Chapter 3, The Title,
                                                      in Book Title

                ^    ^   ^^^ ^    ^     ^
                |    |   ||| |    |     +- the suffix
                |    |   ||| |    +- the title
                |    |   ||| +- the number separator
                |    |   ||+- the intra-number separator
                |    |   |+- the number (3.4)
                |    |   +- the label separator
                |    +- the label
                +- the prefix

    Chapter 3
    Chapter 3 in Book Title
    Chapter 3, The Title

    Section 3.1
    Section 3.1, The Title
    Section 1 in Chapter 3
    Section 1 in Chapter 3, The Title
    Section 1, The Title in Chapter 3, The Title
    section called The Title in Chapter 3 in Book Title
    section called The Title in Chapter 3, The Title, in Book Title

    Figure 4.2
    Figure 4.2, The Title
    Figure 2 in Section 3.1
    Figure 2 in Section 1 in Chapter 3
    Figure 2, The Title in Chapter 3
-->

<!-- label defaults to false;
     number defaults to false;
     inherit is ignored if number is false -->

<xsl:variable name="v:user-xref-properties" as="element()*"/>

<xsl:variable name="v:xref-properties" as="element()+"
              xmlns:db="http://docbook.org/ns/docbook">
  <xsl:sequence select="$v:user-xref-properties"/>

  <crossref xpath="self::db:section[ancestor::db:preface]"
            prefix-key="sectioncalled"
            label="false"
            number="false"
            title="true"
            inherit="ancestor::db:preface[1]"
            inherit-separator="in the"/>

  <crossref xpath="self::db:section"
            label="true"
            number="true"
            title="true"/>

  <crossref xpath="self::db:preface|self::db:partintro"
            label="false"
            number="false"
            title="true"/>

  <crossref xpath="self::db:chapter|self::db:appendix"
            label="true"
            number="true"
            title="true"/>

  <crossref xpath="self::db:part|self::db:reference"
            label="true"
            number="true"
            title="true"/>

  <crossref xpath="self::db:figure|self::db:example|self::db:table
                   |self::db:procedure|self::db:equation
                   |self::db:formalgroup"
            label="true"
            number="true"
            title="true"/>

  <crossref xpath="self::db:listitem[parent::db:orderedlist]"
            label="false"
            number="true"
            title="false"/>

  <crossref xpath="self::db:question|self::db:answer"
            label="true"
            number="false"
            title="false"/>

  <crossref xpath="self::db:step"
            label="false"
            number="true"
            prefix-key="step"
            title="false"/>

  <crossref xpath="self::db:see"
            prefix-key="see"
            title="true"/>

  <crossref xpath="self::db:seealso"
            prefix-key="seealso"
            title="true"/>

  <crossref xpath="self::db:glosssee"
            prefix-key="glosssee"
            title="true"/>

  <crossref xpath="self::db:glossseealso"
            prefix-key="glossseealso"
            title="true"/>

  <crossref xpath="self::*"
            label="false"
            number="false"
            title="true"/>
</xsl:variable>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:crossref">
  <xsl:variable name="properties" select="fp:crossref-properties(.)"/>

  <xsl:if use-when="false()"
          test="self::db:section">
    <xsl:message select="path(.), ':'"/>
    <xsl:for-each select="map:keys($properties)">
      <xsl:message select="'  prop:', ., '=', map:get($properties, .)"/>
    </xsl:for-each>
  </xsl:if> 

  <xsl:variable name="title" as="item()*">
    <xsl:if test="$properties?title">
      <xsl:apply-templates select="." mode="m:crossref-title"/>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="number" as="item()*">
    <xsl:if test="$properties?number">
      <xsl:choose>
        <xsl:when test="@label">
          <xsl:value-of select="@label/string()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="m:crossref-number"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="label" as="item()*">
    <xsl:if test="$properties?label">
      <xsl:apply-templates select="." mode="m:crossref-label">
        <xsl:with-param name="number" select="$number"/>
        <xsl:with-param name="title" select="$title"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:variable>

<!--
  <xsl:message select="node-name(.), ' l:', $label,' n:', $number, ' t:', $title"/>
-->

  <xsl:variable name="link" as="element()">
    <span>
      <xsl:apply-templates select="." mode="m:crossref-prefix">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="number" select="$number"/>
        <xsl:with-param name="title" select="$title"/>
      </xsl:apply-templates>

      <xsl:if test="not(empty($label))">
        <span class="label">
          <xsl:sequence select="$label"/>
          <xsl:variable name="sep" as="item()*">
            <xsl:apply-templates select="." mode="m:crossref-label-separator">
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
          <xsl:if test="not(empty($title))">
            <xsl:apply-templates select="." mode="m:crossref-number-separator">
              <xsl:with-param name="number" select="$number"/>
              <xsl:with-param name="title" select="$title"/>
            </xsl:apply-templates>
          </xsl:if>
        </span>
      </xsl:if>

      <xsl:if test="not(empty($title))">
        <span class="xreftitle">
          <xsl:sequence select="$title"/>
        </span>
      </xsl:if>

      <xsl:apply-templates select="." mode="m:crossref-suffix">
        <xsl:with-param name="title" select="$title"/>
      </xsl:apply-templates>
    </span>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="normalize-space(string($link)) = ''">
      <span class="error broken-link">here</span>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$link"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:if test="$properties?inherit">
    <xsl:variable name="ancestor" as="element()?">
      <xsl:evaluate context-item="." xpath="$properties?inherit"/>
    </xsl:variable>
    <xsl:variable name="ancestor" as="item()*">
      <xsl:apply-templates select="$ancestor" mode="m:crossref"/>
    </xsl:variable>
    <xsl:if test="$ancestor">
      <xsl:apply-templates select="." mode="m:crossref-inherit-separator">
        <xsl:with-param name="title" select="$title"/>
        <xsl:with-param name="parent" select="parent"/>
      </xsl:apply-templates>
      <xsl:sequence select="$ancestor"/>
    </xsl:if>
  </xsl:if>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:crossref-prefix">
  <xsl:param name="label" as="item()*" required="yes"/>
  <xsl:param name="number" as="item()*" required="yes"/>
  <xsl:param name="title" as="item()*" required="yes"/>

  <xsl:variable name="properties" select="fp:crossref-properties(.)"/>

  <xsl:choose>
    <xsl:when test="$properties?prefix-key">
      <span class="prefix">
        <xsl:sequence select="f:gentext(., 'xref', $properties?prefix-key)"/>
        <span class="sep"> </span>
      </span>
    </xsl:when>
    <xsl:when test="$properties?prefix">
      <span class="prefix">
        <xsl:sequence select="$properties?prefix"/>
        <span class="sep"> </span>
      </span>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:crossref-label" as="item()*">
  <xsl:param name="number" as="item()*" required="yes"/>
  <xsl:param name="title" as="item()*" required="yes"/>
  <xsl:apply-templates select="." mode="m:headline-label">
    <xsl:with-param name="purpose" select="'crossref'"/>
    <xsl:with-param name="number" select="$number"/>
    <xsl:with-param name="title" select="$title"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:answer" mode="m:crossref-label" as="item()*">
  <xsl:param name="number" as="item()*" required="yes"/>
  <xsl:param name="title" as="item()*" required="yes"/>

  <xsl:variable name="label"
                select="ancestor::db:qandaset[@defaultlabel][1]/@defaultlabel/string()"/>
  <xsl:variable name="label"
                select="if ($label)
                        then $label
                        else $qandaset-default-label"/>

  <xsl:choose>
    <xsl:when test="$label = 'none' or $label='number'">
      <xsl:apply-templates select="preceding-sibling::db:question"
                           mode="m:crossref-label">
        <xsl:with-param name="number" select="$number"/>
        <xsl:with-param name="title" select="$title"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:next-match>
        <xsl:with-param name="number" select="$number"/>
        <xsl:with-param name="title" select="$title"/>
      </xsl:next-match>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:crossref-label-separator">
  <xsl:apply-templates select="." mode="m:headline-label-separator">
    <xsl:with-param name="purpose" select="'crossref'"/>
    <xsl:with-param name="label" select="()"/>
    <xsl:with-param name="number" select="()"/>
    <xsl:with-param name="title" select="()"/>
  </xsl:apply-templates>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:crossref-number">
  <xsl:apply-templates select="." mode="m:headline-number">
    <xsl:with-param name="purpose" select="'crossref'"/>
  </xsl:apply-templates>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:crossref-number-separator">
  <xsl:param name="number" as="item()*" required="yes"/>
  <xsl:param name="title" as="item()*" required="yes"/>
  <xsl:text>, </xsl:text>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:crossref-title">
  <xsl:apply-templates select="(db:info/db:titleabbrev, db:info/db:title)[1]"
                       mode="m:title">
    <xsl:with-param name="purpose" select="'crossref'"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:bridgehead" mode="m:crossref-title">
  <xsl:apply-templates select="." mode="m:title"/>
</xsl:template>

<xsl:template match="db:varlistentry" mode="m:crossref-title">
  <xsl:apply-templates select="db:term[1]" mode="m:title">
    <xsl:with-param name="purpose" select="'crossref'"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:glossentry" mode="m:crossref-title">
  <xsl:apply-templates select="db:glossterm[1]/node()"/>
</xsl:template>

<xsl:template match="db:glossterm" mode="m:crossref-title">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:see|db:seealso" mode="m:crossref-title">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:area|db:areaset|db:co" mode="m:crossref-title">
  <xsl:apply-templates select="." mode="m:callout-bug"/>
</xsl:template>

<xsl:template match="db:production" mode="m:crossref-title">
  <xsl:apply-templates select="db:lhs[1]" mode="m:title">
    <xsl:with-param name="purpose" select="'crossref'"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:refentry" mode="m:crossref-title">
  <xsl:apply-templates select="." mode="m:headline-title">
    <xsl:with-param name="purpose" select="'crossref'"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:refnamediv" mode="m:crossref-title">
  <xsl:apply-templates select="db:refname[1]" mode="m:headline-title">
    <xsl:with-param name="purpose" select="'crossref'"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:bibliomixed|db:biblioentry" mode="m:crossref-title">
  <xsl:choose>
    <xsl:when test="node()[1]/self::db:abbrev
                    or (node()[1]/text()
                        and normalize-space(node()[1]) = ''
                        and node()[2]/self::db:abbrev)">
      <xsl:apply-templates select="db:abbrev[1]"/>
    </xsl:when>
    <xsl:when test="@xml:id">
      <xsl:value-of select="@xml:id"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:crossref-suffix">
  <xsl:param name="title" as="item()*" required="yes"/>

  <xsl:sequence select="()"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:crossref-inherit-separator">
  <xsl:param name="title" as="item()*" required="yes"/>
  <xsl:param name="parent" as="item()*" required="yes"/>
  <xsl:variable name="properties" select="fp:crossref-properties(.)"/>
  <xsl:choose>
    <xsl:when test="$properties?inherit-separator-key">
      <xsl:sequence select="error((), 'bang')"/>
    </xsl:when>
    <xsl:when test="$properties?inherit-separator">
      <span class="sep">
        <xsl:text> </xsl:text>
        <xsl:sequence select="$properties?inherit-separator"/>
        <xsl:text> </xsl:text>
      </span>
    </xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="fp:document-crossref-properties" as="element()*" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="root($node)/*/db:info/v:crossref"/>
</xsl:function>

<xsl:function name="fp:crossref-properties" as="map(*)" cache="yes">
  <xsl:param name="node" as="element()"/>

  <xsl:variable name="prop" as="element()?">
    <xsl:iterate select="(fp:document-crossref-properties($node), $v:xref-properties)">
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
                select="(exists($prop/@number-format)
                         or (exists($prop/@number) and f:is-true($prop/@number)))
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

  <xsl:sequence select="map {
    'prefix': $prop/@prefix/string(),
    'prefix-key': $prop/@prefix-key/string(),
    'label': f:is-true($prop/@label),
    'label-toc': $label-toc,
    'number': $number,
    'number-format': $format,
    'title': f:is-true($prop/@title),
    'inherit': $prop/@inherit/string(),
    'inherit-separator': $prop/@inherit-separator/string(),
    'suffix': $prop/@suffix/string(),
    'suffix-key': $prop/@suffix-key/string()
    }"/> 
</xsl:function>

</xsl:stylesheet>
