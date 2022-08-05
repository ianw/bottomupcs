<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f h m mp t tp xs"
                version="3.0">

<xsl:template match="*" mode="m:toc">
  <xsl:message select="'Unexpected in m:toc:', node-name(.)"/>
</xsl:template>

<xsl:template match="*" mode="mp:toc">
  <xsl:param name="nested" as="xs:boolean" required="yes"/>
  <xsl:param name="entries" as="element()*" required="yes"/>

  <!-- FIXME: what's the right way to go about this? -->
  <xsl:variable name="nscontext" as="element()">
    <xsl:element name="nscontext">
      <xsl:namespace name="f" select="'http://docbook.org/ns/docbook/functions'"/>
      <xsl:namespace name="v" select="'http://docbook.org/ns/docbook/variables'"/>
      <xsl:namespace name="vp" select="'http://docbook.org/ns/docbook/variables/private'"/>
      <xsl:namespace name="f" select="'http://docbook.org/ns/docbook/functions'"/>
      <xsl:namespace name="db" select="'http://docbook.org/ns/docbook'"/>
    </xsl:element>
  </xsl:variable>

  <xsl:variable name="toc" as="item()?">
    <xsl:choose xmlns:vp="http://docbook.org/ns/docbook/variables/private">
      <xsl:when test="$nested">
        <xsl:evaluate context-item="." xpath="$generate-nested-toc"
                      namespace-context="$nscontext">
          <xsl:with-param name="vp:section-toc-depth"
                          select="$vp:section-toc-depth"/>
        </xsl:evaluate>
      </xsl:when>
      <xsl:otherwise>
        <xsl:evaluate context-item="." xpath="$generate-toc"
                      namespace-context="$nscontext">
          <xsl:with-param name="vp:section-toc-depth"
                          select="$vp:section-toc-depth"/>
        </xsl:evaluate>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$toc and exists($entries)
                and f:is-true(f:pi(db:info, 'toc', 'true'))">
    <xsl:call-template name="tp:toc">
      <xsl:with-param name="entries" select="$entries"/>
      <xsl:with-param name="nested" select="$nested"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="db:set|db:book|db:part|db:reference" mode="m:toc">
  <xsl:param name="nested" select="false()"/>
  <xsl:apply-templates select="." mode="mp:toc">
    <xsl:with-param name="nested" select="$nested"/>
    <xsl:with-param name="entries"
                    select="db:book|db:preface|db:chapter|db:appendix|db:article
                            |db:topic|db:part|db:reference|db:refentry|db:dedication
                            |db:bibliography|db:index|db:glossary
                            |db:acknowledgements|db:colophon"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:partintro|db:acknowledgements
                     |db:bibliodiv|db:glossdiv|db:indexdiv
                     |db:dedication|db:colophon"
              mode="m:toc">
  <xsl:param name="nested" select="false()"/>
  <!-- these don't get a ToC -->
</xsl:template>

<xsl:template match="db:formalgroup
                     |db:figure|db:table|db:example|db:equation|db:procedure"
              mode="m:toc">
  <!-- these don't nest -->
</xsl:template>

<xsl:template match="db:article" mode="m:toc">
  <xsl:param name="nested" select="false()"/>
  <xsl:apply-templates select="." mode="mp:toc">
    <xsl:with-param name="nested" select="$nested"/>
    <xsl:with-param name="entries"
                    select="db:section|db:sect1|db:appendix
                            |db:bibliography|db:index|db:glossary
                            |db:acknowledgements|db:colophon|db:dedication
                            |db:refentry"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:topic" mode="m:toc">
  <xsl:param name="nested" select="false()"/>
  <xsl:apply-templates select="." mode="mp:toc">
    <xsl:with-param name="nested" select="$nested"/>
    <xsl:with-param name="entries"
                    select="db:bibliography|db:glossary|db:index
                            |db:section|db:sect1|db:simplesect
                            |db:refentry"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:preface|db:chapter|db:appendix"
              mode="m:toc">
  <xsl:param name="nested" select="false()"/>
  <xsl:apply-templates select="." mode="mp:toc">
    <xsl:with-param name="nested" select="$nested"/>
    <xsl:with-param name="entries"
                    select="db:section|db:sect1|db:article
                            |db:topic|db:appendix"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:bibliography|db:glossary|db:index"
              mode="m:toc">
  <xsl:param name="nested" select="false()"/>
  <xsl:apply-templates select="." mode="mp:toc">
    <xsl:with-param name="nested" select="$nested"/>
    <xsl:with-param name="entries"
                    select="db:bibliodiv|db:glossdiv|db:indexdiv"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:refentry" mode="m:toc">
  <xsl:param name="nested" select="false()"/>
  <xsl:apply-templates select="." mode="mp:toc">
    <xsl:with-param name="nested" select="$nested"/>
    <xsl:with-param name="entries" select="db:refsection|db:refsect1"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:refsection|db:refsect1|db:refsect2|db:refsect3"
              mode="m:toc">
  <xsl:param name="nested" select="false()"/>
  <xsl:apply-templates select="." mode="mp:toc">
    <xsl:with-param name="nested" select="$nested"/>
    <xsl:with-param name="entries"
                    select="db:refsection|db:refsect1|db:refsect2|db:refsect3"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:section|db:sect1|db:sect2|db:sect3
                     |db:sect4|db:sect5"
              mode="m:toc">
  <xsl:param name="nested" select="false()"/>
  <xsl:apply-templates select="." mode="mp:toc">
    <xsl:with-param name="nested" select="$nested"/>
    <xsl:with-param name="entries"
                select="db:section|db:sect1
                        |db:sect2|db:sect3|db:sect4|db:sect5"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:refsection|db:refsect1|db:refsect2|db:refsect3"
              mode="m:toc">
  <xsl:param name="nested" select="false()"/>
  <!-- these don't get a ToC -->
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="m:list-of-figures"/>
<xsl:template match="db:set|db:book" mode="m:list-of-figures">
  <xsl:if test="f:is-true($lists-of-figures)">
    <xsl:variable name="entries" as="element(h:li)*">
      <xsl:apply-templates select=".//db:figure[not(ancestor::db:formalgroup)]
                                   |.//db:formalgroup[db:figure]"
                           mode="m:toc-entry"/>
    </xsl:variable>
    <xsl:if test="$entries">
      <div class="list-of-figures lot">
        <div class="title">
          <xsl:sequence select="f:gentext(., 'title', 'listoffigures')"/>
        </div>
        <ul class="toc">
          <xsl:sequence select="$entries"/>
        </ul>
      </div>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="m:list-of-tables"/>
<xsl:template match="db:set|db:book" mode="m:list-of-tables">
  <xsl:if test="f:is-true($lists-of-tables)">
    <xsl:variable name="entries" as="element(h:li)*">
      <xsl:apply-templates select=".//db:table[not(ancestor::db:formalgroup)]
                                   |.//db:formalgroup[db:table]" mode="m:toc-entry"/>
    </xsl:variable>
    <xsl:if test="$entries">
      <div class="list-of-tables lot">
        <div class="title">
          <xsl:sequence select="f:gentext(., 'title', 'listoftables')"/>
        </div>
        <ul class="toc">
          <xsl:sequence select="$entries"/>
        </ul>
      </div>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="m:list-of-examples"/>
<xsl:template match="db:set|db:book" mode="m:list-of-examples">
  <xsl:if test="f:is-true($lists-of-examples)">
    <xsl:variable name="entries" as="element(h:li)*">
      <xsl:apply-templates select=".//db:example[not(ancestor::db:formalgroup)]
                                   |.//db:formalgroup[db:example]" mode="m:toc-entry"/>
    </xsl:variable>
    <xsl:if test="$entries">
      <div class="list-of-examples lot">
        <div class="title">
          <xsl:sequence select="f:gentext(., 'title', 'listofexamples')"/>
        </div>
        <ul class="toc">
          <xsl:sequence select="$entries"/>
        </ul>
      </div>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="m:list-of-equations"/>
<xsl:template match="db:set|db:book" mode="m:list-of-equations">
  <xsl:if test="f:is-true($lists-of-equations)">
    <xsl:variable name="entries" as="element(h:li)*">
      <xsl:apply-templates select=".//db:equation[not(ancestor::db:formalgroup)]
                                   |.//db:formalgroup[db:figure]" mode="m:toc-entry"/>
    </xsl:variable>
    <xsl:if test="$entries">
      <div class="list-of-equations lot">
        <div class="title">
          <xsl:sequence select="f:gentext(., 'title', 'listofequations')"/>
        </div>
        <ul class="toc">
          <xsl:sequence select="$entries"/>
        </ul>
      </div>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="m:list-of-procedures"/>
<xsl:template match="db:set|db:book" mode="m:list-of-procedures">
  <xsl:if test="f:is-true($lists-of-procedures)">
    <xsl:variable name="entries" as="element(h:li)*">
      <xsl:apply-templates select=".//db:procedure" mode="m:toc-entry"/>
    </xsl:variable>
    <xsl:if test="$entries">
      <div class="list-of-procedures lot">
        <div class="title">
          <xsl:sequence select="f:gentext(., 'title', 'listofprocedures')"/>
        </div>
        <ul class="toc">
          <xsl:sequence select="$entries"/>
        </ul>
      </div>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template name="tp:toc">
  <xsl:param name="entries" as="element()+" required="yes"/>
  <xsl:param name="nested" as="xs:boolean" required="yes"/>
  <xsl:choose>
    <xsl:when test="$nested">
      <xsl:variable name="entries" as="element(h:li)*">
        <xsl:apply-templates select="$entries" mode="m:toc-entry"/>
      </xsl:variable>
      <xsl:if test="$entries">
        <ul class="toc">
          <xsl:sequence select="$entries"/>
        </ul>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="entries" as="element(h:li)*">
        <xsl:apply-templates select="$entries" mode="m:toc-entry"/>
      </xsl:variable>
      <xsl:variable name="l-o-f" as="element(h:div)?">
        <xsl:apply-templates select="." mode="m:list-of-figures"/>
      </xsl:variable>
      <xsl:variable name="l-o-t" as="element(h:div)?">
        <xsl:apply-templates select="." mode="m:list-of-tables"/>
      </xsl:variable>
      <xsl:variable name="l-o-ex" as="element(h:div)?">
        <xsl:apply-templates select="." mode="m:list-of-examples"/>
      </xsl:variable>
      <xsl:variable name="l-o-eq" as="element(h:div)?">
        <xsl:apply-templates select="." mode="m:list-of-equations"/>
      </xsl:variable>
      <xsl:variable name="l-o-p" as="element(h:div)?">
        <xsl:apply-templates select="." mode="m:list-of-procedures"/>
      </xsl:variable>
      <xsl:if test="f:is-true($generate-trivial-toc)
                    or count($entries/descendant-or-self::h:li) gt 1
                    or $l-o-f or $l-o-t or $l-o-ex or $l-o-eq or $l-o-p">
        <div class="list-of-titles">
          <xsl:if test="$entries">
            <div class="lot toc">
              <div class="title">
                <xsl:sequence select="f:gentext(., 'title', 'tableofcontents')"/>
              </div>
              <ul class="toc">
                <xsl:sequence select="$entries"/>
              </ul>
            </div>
          </xsl:if>
          <xsl:sequence select="$l-o-f"/>
          <xsl:sequence select="$l-o-t"/>
          <xsl:sequence select="$l-o-ex"/>
          <xsl:sequence select="$l-o-eq"/>
          <xsl:sequence select="$l-o-p"/>
        </div>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:refentry" mode="m:toc-entry" priority="100">
  <xsl:variable name="refmeta" select=".//db:refmeta"/>
  <xsl:variable name="refentrytitle" select="$refmeta//db:refentrytitle"/>
  <xsl:variable name="refnamediv" select=".//db:refnamediv"/>
  <xsl:variable name="refname" select="$refnamediv//db:refname"/>

  <xsl:variable name="title">
    <xsl:choose>
      <xsl:when test="$refentrytitle">
        <xsl:apply-templates select="$refentrytitle[1]">
          <xsl:with-param name="purpose" select="'lot'"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$refnamediv/db:refdescriptor">
        <xsl:apply-templates select="($refnamediv/db:refdescriptor)[1]">
          <xsl:with-param name="purpose" select="'lot'"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$refname">
        <xsl:apply-templates select="$refname[1]">
          <xsl:with-param name="purpose" select="'lot'"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <li>
    <span class='refentrytitle'>
      <a href="#{f:id(.)}">
        <xsl:sequence select="$title"/>
      </a>
    </span>
    <xsl:if test="f:is-true($annotate-toc)">
      <xsl:apply-templates select="(db:refnamediv/db:refpurpose)[1]">
        <xsl:with-param name="purpose" select="'lot'"/>
      </xsl:apply-templates>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template match="*" mode="m:toc-entry">
  <li>
    <a href="#{f:id(.)}">
      <xsl:apply-templates select="." mode="m:headline">
        <xsl:with-param name="purpose" select="'lot'"/>
      </xsl:apply-templates>
    </a>
    <xsl:apply-templates select="." mode="m:toc">
      <xsl:with-param name="nested" select="true()"/>
    </xsl:apply-templates>
  </li>
</xsl:template>

<xsl:template match="*[not(db:info/db:title)]" mode="m:toc-entry"
              priority="10">
  <!-- things without titles don't appear in the, uh, lists of titles -->
  <!-- preface, dedication, acknowledgements, colophon, equation,
       and procedure spring to mind... -->
</xsl:template>

<xsl:template match="db:colophon|db:bibliodiv|db:glossdiv|db:indexdiv"
              mode="m:toc-entry">
  <!-- by default, these don't appear in the ToC -->
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:toc|db:tocdiv">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:choose>
      <xsl:when test="db:tocentry">
        <ul>
          <xsl:apply-templates select="db:tocentry"/>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<xsl:template match="db:tocentry">
  <ul>
    <xsl:apply-templates/>
  </ul>
</xsl:template>

</xsl:stylesheet>
