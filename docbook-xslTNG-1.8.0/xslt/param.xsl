<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:ext="http://docbook.org/extensions/xslt"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db ext f m v vp xs"
                version="3.0">

<!-- Note: Some of these parameters are initialized using content
     instead of a select attribute in order to make the reference page
     in the Guide work better. -->

<!-- Many of these parameters are shadowed by variables (see
     variable.xsl) for use in the stylesheets. Often, they're defined
     as strings here and as more useful data types in the variables. -->

<!-- 'pipeline', 'objects', 'templates', 'template-matches', 'tables',
     'callouts', 'verbatim', 'render-verbatim', 'highlight', 'profile', 'properties',
     'xlink' 'chunks', 'chunk-cleanup', 'intra-chunk-refs', 'intra-chunk-links',
     'structure', 'mediaobject-uris', 'cals-align-char', 'image-properties',
     'db4to5' 'profile-suppress', 'dynamic-profile', 'dynamic-profile-suppress' -->
<xsl:param name="debug" static="yes" as="xs:string"
           select="''"/>

<!-- This parameter is only true when the stylesheets are being run by XSpec -->
<xsl:param name="xspec" as="xs:string" select="'false'"/>

<xsl:param name="gentext-language" select="()"/>

<xsl:param name="verbatim-line-style"
           select="'programlisting programlistingco
                    screen screenco synopsis'"/>

<xsl:param name="verbatim-plain-style" as="xs:string"
           select="'address literallayout funcsynopsisinfo classsynopsisinfo'"/>

<xsl:param name="verbatim-space" select="' '"/>

<xsl:param name="verbatim-trim-trailing-blank-lines" select="'true'"/>
<xsl:param name="verbatim-style-default" select="'lines'"/>

<!-- the parameter is a list of names so it's easier to specify
     from the command line or through a parameter API. -->
<xsl:param name="verbatim-numbered-elements"
           select="'programlisting programlistingco'"/>

<xsl:param name="verbatim-number-minlines" select="'5'"/>

<xsl:param name="verbatim-number-every-nth" select="5"/>

<xsl:param name="verbatim-number-first-line" select="'true'"/>

<!-- 'linecolumn', 'lines', 'lineranges-first', 'lineranges-all' -->
<xsl:param name="verbatim-callouts" as="xs:string"
           select="'linecolumn lines lineranges-first'"/>

<xsl:param name="verbatim-syntax-highlighter" as="xs:string" select="'pygments'"/>
<xsl:param name="verbatim-syntax-highlight-languages"
           select="'python perl html xml xslt xquery javascript json'"/>

<xsl:param name="callout-default-column" select="60"/>

<xsl:param name="pixels-per-inch" select="96.0"/>
<xsl:param name="nominal-page-width" select="'6in'"/>
<xsl:param name="default-length-magnitude" select="25.0"/>
<xsl:param name="default-length-unit" select="'%'"/>

<xsl:param name="table-accessibility" as="xs:string*"
           select="('summary', 'details')"/>
<xsl:param name="mediaobject-accessibility" as="xs:string*"
           select="('summary', 'details')"/>

<xsl:param name="align-char-default" as="xs:string" select="'.'"/>
<xsl:param name="align-char-width" select="2"/>
<xsl:param name="align-char-pad" select="'&#x2002;'"/> <!-- en space -->

<xsl:param name="mediaobject-exclude-extensions"
           select="('.eps', '.ps', '.pdf')"/>

<xsl:param name="mediaobject-input-base-uri" as="xs:string">
  <xsl:sequence use-when="function-available('ext:cwd')"
                select="resolve-uri(ext:cwd(), static-base-uri())"/>
  <xsl:sequence use-when="not(function-available('ext:cwd'))"
                select="''"/>
</xsl:param>

<xsl:param name="mediaobject-output-base-uri" as="xs:string"
           select="''"/>

<xsl:param name="image-ignore-scaling" as="xs:boolean" select="false()"/>
<xsl:param name="image-property-warning" select="true()"/>
<xsl:param name="image-nominal-width" select="$nominal-page-width"/>
<xsl:param name="image-nominal-height" select="'4in'"/>

<xsl:param name="default-personal-name-style" select="'first-last'"/>
<xsl:param name="othername-in-middle" select="'true'"/>

<xsl:param name="productionset-lhs-rhs-separator" select="':='"/>

<xsl:param name="date-date-format"
           select="'[D01] [MNn,*-3] [Y0001]'"/>
<xsl:param name="date-dateTime-format"
           select="'[H01]:[m01] [D01] [MNn,*-3] [Y0001]'"/>

<xsl:param name="qandaset-default-toc" select="'true'"/>
<xsl:param name="qandadiv-default-toc" select="$qandaset-default-toc"/>
<xsl:param name="qandaset-default-label" select="'number'"/>

<xsl:param name="funcsynopsis-default-style" select="'kr'"/>
<xsl:param name="funcsynopsis-table-threshold" select="40"/>
<xsl:param name="funcsynopsis-trailing-punctuation" select="';'"/>

<xsl:param name="classsynopsis-indent" select="'  '"/>

<xsl:param name="copyright-collapse-years" select="true()"/>
<xsl:param name="copyright-year-separator" select="', '"/>
<xsl:param name="copyright-year-range-separator" select="'–'"/>

<xsl:param name="division-numbers-inherit" as="xs:string" select="'false'"/>
<xsl:param name="component-numbers-inherit" as="xs:string" select="'false'"/>
<xsl:param name="section-numbers" as="xs:string" select="'1'"/>
<xsl:param name="section-numbers-inherit" select="'true'"/>

<xsl:param name="number-single-appendix" select="'true'"/>

<xsl:param name="generate-toc" as="xs:string">
  (empty(parent::*) and self::db:article)
  or self::db:set or self::db:book
  or self::db:part or self::db:reference
</xsl:param>

<xsl:param name="generate-nested-toc" as="xs:string">
  not(f:section(.))
  or (f:section(.) and f:section-depth(.) le $vp:section-toc-depth)
</xsl:param>

<xsl:param name="generate-trivial-toc" as="xs:string" select="'false'"/>

<xsl:param name="section-toc-depth" select="'unbounded'"/>
<xsl:param name="vp:section-toc-depth" as="xs:integer">
  <xsl:choose>
    <xsl:when test="$section-toc-depth instance of xs:integer">
      <xsl:sequence select="max((0, $section-toc-depth))"/>
    </xsl:when>
    <xsl:when test="$section-toc-depth castable as xs:integer">
      <xsl:sequence select="max((0, xs:integer($section-toc-depth)))"/>
    </xsl:when>
    <xsl:when test="string($section-toc-depth) = 'unbounded'">
      <xsl:sequence select="2147483647"/> <!-- 0x7fffffff -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="0"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="annotation-style" select="'javascript'"/>
<xsl:param name="annotation-mark"><sup>⌖</sup></xsl:param>
<xsl:param name="annotation-placement" select="'after'"/>

<xsl:param name="xlink-style" select="'document'"/>
<xsl:param name="xlink-style-default" select="'inline'"/>
<xsl:param name="xlink-icon-open" select="()"/>
<xsl:param name="xlink-icon-closed" select="()"/>

<!-- 'list' or 'table' -->
<xsl:param name="revhistory-style" select="'table'"/>

<xsl:param name="segmentedlist-style" select="'table'"/>

<xsl:param name="formal-object-title-placement"
           select="'after formalgroup:before'"/>

<xsl:param name="lists-of-figures" as="xs:string" select="'true'"/>
<xsl:param name="lists-of-tables" as="xs:string" select="'true'"/>
<xsl:param name="lists-of-examples" as="xs:string" select="'true'"/>
<xsl:param name="lists-of-equations" as="xs:string" select="'false'"/>
<xsl:param name="lists-of-procedures" as="xs:string" select="'false'"/>

<xsl:param name="variablelist-termlength-threshold" select="20"/>
<xsl:param name="procedure-step-numeration" select="'1aiAI'"/>
<xsl:param name="orderedlist-item-numeration" select="'1aiAI'"/>

<xsl:param name="refentry-generate-name" select="true()"/>
<xsl:param name="refentry-generate-title" select="true()"/>
<xsl:param name="annotate-toc" select="'true'"/>

<xsl:param name="callout-unicode-start" select="9311"/>

<xsl:param name="index-show-entries" select="()"/> <!-- '🔖' -->
<xsl:param name="generate-index" select="'true'"/>
<xsl:param name="index-on-role" select="'true'"/>
<xsl:param name="index-on-type" select="'true'"/>
<xsl:param name="indexed-section-groups" select="'true'"/>

<xsl:param name="glossary-sort-entries" select="true()"/>

<xsl:param name="sort-collation"
           select="'http://www.w3.org/2005/xpath-functions/collation/html-ascii-case-insensitive'"/>

<xsl:param name="default-float-style" select="'left'"/>

<xsl:param name="show-remarks" select="'false'"/>
<xsl:param name="sidebar-as-aside" select="false()"/>

<xsl:param name="resource-base-uri" select="'./'"/>

<xsl:param name="use-docbook-css" select="'true'"/>
<xsl:param name="oxy-markup" select="'false'"/>

<xsl:param name="verbatim-syntax-highlight-css"
           select="'css/pygments.css'"/>
<xsl:param name="persistent-toc-css"
           select="'css/docbook-toc.css'"/>
<xsl:param name="oxy-markup-css"
           select="'css/oxy-markup.css'"/>
<xsl:param name="user-css-links"
           select="()"/>

<xsl:param name="annotations-js" select="'js/annotations.js'"/>
<xsl:param name="xlink-js" select="'js/xlink.js'"/>
<xsl:param name="persistent-toc-js" select="'js/persistent-toc.js'"/>
<xsl:param name="mathml-js"
           select="'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=MML_CHTML'"/>

<xsl:param name="control-js" as="xs:string" select="'js/controls.js'"/>
<xsl:param name="theme-picker" as="xs:string" select="'false'"/>

<xsl:param name="chunk" as="xs:string?" select="()"/>
<xsl:param name="chunk-nav" as="xs:string" select="'true'"/>
<xsl:param name="chunk-nav-js" as="xs:string" select="'js/chunk-nav.js'"/>

<xsl:variable name="v:chunk" as="xs:boolean"
              select="not(normalize-space($chunk) = '')"/>

<xsl:param name="chunk-output-base-uri" as="xs:string">
  <xsl:choose>
    <xsl:when test="not($v:chunk)">
      <!-- it doesn't actually matter -->
      <xsl:sequence select="''"/>
    </xsl:when>
    <xsl:when use-when="function-available('ext:cwd')"
              test="true()">
      <xsl:message select="'Default output base uri:',
                           resolve-uri(ext:cwd(), static-base-uri())"/>
      <xsl:sequence select="resolve-uri(ext:cwd(), static-base-uri())"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message terminate="yes"
                   select="'You must specify the $chunk-output-base-uri'"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="chunk-section-depth" select="1"/>

<!-- N.B. this can lead to confusing numeration if you have
     footnoterefs that cross chunk boundaries! -->
<xsl:param name="chunk-renumber-footnotes" select="'true'"/>

<xsl:param name="chunk-include" as="xs:string*"
           select="('parent::db:set',
                    'parent::db:book',
                    'parent::db:part',
                    'parent::db:reference',
                    'self::db:refentry',
                    'self::db:section',
                    'self::db:sect1')"/>

<xsl:param name="chunk-exclude" as="xs:string*"
           select="('self::db:partintro',
                    'self::*[ancestor::db:partintro]',
                    'self::db:annotation',
                    'self::db:section[not(preceding-sibling::db:section)]',
                    'self::db:sect1[not(preceding-sibling::db:sect1)]',
                    'self::db:toc')"/>

<xsl:param name="html-extension" select="'.html'"/>

<!--
<xsl:param name="footnote-numeration" select="('*', '**', '†','‡', '§', '1')"/>
-->
<xsl:param name="footnote-numeration" select="('1')"/>
<xsl:param name="table-footnote-numeration" select="('a')"/>

<xsl:param name="persistent-toc" select="'false'"/>
<xsl:param name="persistent-toc-search" select="'true'"/>

<xsl:param name="profile-separator" select="';'"/>
<xsl:param name="profile-lang" select="''"/>
<xsl:param name="profile-revisionflag" select="''"/>
<xsl:param name="profile-role" select="''"/>
<xsl:param name="profile-arch" select="''"/>
<xsl:param name="profile-audience" select="''"/>
<xsl:param name="profile-condition" select="''"/>
<xsl:param name="profile-conformance" select="''"/>
<xsl:param name="profile-os" select="''"/>
<xsl:param name="profile-outputformat" select="''"/>
<xsl:param name="profile-revision" select="''"/>
<xsl:param name="profile-security" select="''"/>
<xsl:param name="profile-userlevel" select="''"/>
<xsl:param name="profile-vendor" select="''"/>
<xsl:param name="profile-wordsize" select="''"/>

<xsl:param name="annotation-collection" as="xs:string" select="''"/>
<xsl:param name="glossary-collection" as="xs:string" select="''"/>
<xsl:param name="bibliography-collection" as="xs:string" select="''"/>
<xsl:param name="olink-databases" as="xs:string" select="''"/>

<xsl:param name="docbook-transclusion" select="'false'"/>
<xsl:param name="transclusion-prefix-separator" select="'---'"/>

<xsl:param name="local-conventions" as="xs:string?" select="()"/>
<xsl:param name="relax-ng-grammar" as="xs:string?" select="()"/>

<xsl:param name="allow-eval" as="xs:string" select="'false'"/>
<xsl:param name="dynamic-profiles" as="xs:string" select="'false'"/>
<xsl:param name="dynamic-profile-error" select="'ignore'"/>

<xsl:param name="experimental-pmuj" select="'false'"/>

<xsl:param name="default-theme" as="xs:string" select="''"/>

<xsl:param name="generate-html-page" as="xs:string" select="'true'"/>

<xsl:param name="dc-metadata" as="xs:string" select="'true'"/>
<xsl:param name="generator-metadata" as="xs:string" select="'true'"/>

<xsl:param name="paper-size" as="xs:string?" select="()"/>
<xsl:param name="page-style" as="xs:string" select="'article'"/>

</xsl:stylesheet>
