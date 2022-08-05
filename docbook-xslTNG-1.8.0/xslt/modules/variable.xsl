<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:ext="http://docbook.org/extensions/xslt"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db ext f fp h m v vp xs"
                version="3.0">

<!-- Note: These are variables used by the stylesheet. Many are
     initialized by parsing parameters defined in param.xsl. They're
     in a separate stylesheet to make the pipelines cleaner. -->

<!-- Some them are initialized using content instead of a select
     attribute in order to make the reference page in the Guide work
     better. -->

<xsl:variable name="v:debug" static="yes" as="xs:string*"
              select="tokenize($debug, '[,\s]+') ! normalize-space(.)"/>

<xsl:variable name="v:verbatim-line-style"
              select="tokenize($verbatim-line-style, '\s+')"/>

<xsl:variable name="v:verbatim-plain-style" as="xs:string*"
              select="tokenize($verbatim-plain-style, '\s+')"/>

<xsl:variable name="v:verbatim-space" as="node()">
  <xsl:value-of select="substring($verbatim-space || ' ', 1, 1)"/>
</xsl:variable>

<xsl:variable name="v:verbatim-numbered-elements" as="xs:string*"
              select="tokenize($verbatim-numbered-elements, '\s+')"/>

<xsl:variable name="v:verbatim-number-minlines"
              select="xs:integer($verbatim-number-minlines)"/>

<xsl:variable name="v:verbatim-number-every-nth"
              select="xs:integer($verbatim-number-every-nth)"/>

<xsl:variable name="v:verbatim-number-first-line"
              select="f:is-true($verbatim-number-first-line)"/>

<xsl:variable name="v:verbatim-callouts" as="xs:string*"
              select="tokenize($verbatim-callouts, '\s+')"/>

<xsl:variable name="v:verbatim-syntax-highlight-languages"
              select="tokenize($verbatim-syntax-highlight-languages, '\s+')"/>
<xsl:variable name="v:verbatim-syntax-highlight-options"
           select="map { }"/>
<xsl:variable name="v:verbatim-syntax-highlight-pygments-options"
           select="map { }"/>

<xsl:variable name="v:mediaobject-input-base-uri" as="xs:string?">
  <xsl:message use-when="'mediaobject-uris' = $v:debug"
               select="'Mediaobject input base URI:',
                       if ($mediaobject-input-base-uri = '')
                       then ()
                       else resolve-uri($mediaobject-input-base-uri, static-base-uri())"/>
  <xsl:sequence select="if ($mediaobject-input-base-uri = '')
                        then ()
                        else resolve-uri($mediaobject-input-base-uri, static-base-uri())"/>
</xsl:variable>

<xsl:variable name="v:mediaobject-output-base-uri" as="xs:string?">
  <xsl:message use-when="'mediaobject-uris' = $v:debug"
               select="'Mediaobject output base URI:',
                       if ($mediaobject-output-base-uri = '')
                       then ()
                       else if (ends-with($mediaobject-output-base-uri, '/'))
                            then $mediaobject-output-base-uri
                            else $mediaobject-output-base-uri || '/'"/>
  <xsl:sequence select="if ($mediaobject-output-base-uri = '')
                        then ()
                        else if (ends-with($mediaobject-output-base-uri, '/'))
                             then $mediaobject-output-base-uri
                             else $mediaobject-output-base-uri || '/'"/>
</xsl:variable>

<xsl:variable name="v:personal-name-styles"
              select="('first-last', 'last-first', 'FAMILY-given')"/>

<xsl:variable name="v:formal-object-title-placement" as="map(xs:string,xs:string)"
              select="fp:parse-key-value-pairs(
                        tokenize($formal-object-title-placement, '\s+'))"/>

<xsl:variable name="v:arg-choice-opt-open-str"><span class="cmdpunct">[</span></xsl:variable>
<xsl:variable name="v:arg-choice-opt-close-str"><span class="cmdpunct">]</span></xsl:variable>
<xsl:variable name="v:arg-choice-req-open-str"><span class="cmdpunct">{</span></xsl:variable>
<xsl:variable name="v:arg-choice-req-close-str"><span class="cmdpunct">}</span></xsl:variable>
<xsl:variable name="v:arg-choice-plain-open-str"><xsl:text></xsl:text></xsl:variable>
<xsl:variable name="v:arg-choice-plain-close-str"><xsl:text></xsl:text></xsl:variable>
<xsl:variable name="v:arg-choice-def-open-str"><span class="cmdpunct">[</span></xsl:variable>
<xsl:variable name="v:arg-choice-def-close-str"><span class="cmdpunct">]</span></xsl:variable>
<xsl:variable name="v:arg-rep-repeat-str"><span class="cmdpunct">…</span></xsl:variable>
<xsl:variable name="v:arg-rep-norepeat-str"><xsl:text></xsl:text></xsl:variable>
<xsl:variable name="v:arg-rep-def-str"><xsl:text></xsl:text></xsl:variable>
<xsl:variable name="v:arg-or-sep"><span class="cmdpunct"> | </span></xsl:variable>

<xsl:variable name="vp:user-css-links"
              select="tokenize(normalize-space($user-css-links), '\s+')"/>

<xsl:variable name="v:chunk-renumber-footnotes" as="xs:boolean"
              select="f:is-true($chunk-renumber-footnotes)"/>

<xsl:variable name="v:chunk-filter-namespaces" as="namespace-node()*">
  <xsl:namespace name="db" select="'http://docbook.org/ns/docbook'"/>
</xsl:variable>

<xsl:variable name="v:admonition-icons">
  <db:tip>☞&#xFE0E;</db:tip>
  <db:note>🛈&#xFE0E;</db:note>
  <db:important>☝&#xFE0E;</db:important>
  <db:caution>⚠&#xFE0E;</db:caution>
  <db:warning>⯃&#xFE0E;</db:warning>
  <db:danger>⚡&#xFE0E;</db:danger>
</xsl:variable>

<xsl:variable name="v:annotation-close" as="element()">
  <span>╳</span>
</xsl:variable>

<xsl:variable name="v:nominal-page-width"
              select="f:parse-length($nominal-page-width)"/>
<xsl:variable name="v:image-nominal-width"
              select="f:parse-length($image-nominal-width)"/>
<xsl:variable name="v:image-nominal-height"
              select="f:parse-length($image-nominal-height)"/>

<xsl:variable name="v:toc-open" as="element()">
  <span>[toc]</span>
</xsl:variable>

<xsl:variable name="v:toc-close" as="element()">
  <span>╳</span>
</xsl:variable>

<xsl:variable name="v:olink-databases" as="element(h:targetdb)*">
  <xsl:if test="normalize-space($olink-databases) != ''">
    <xsl:for-each select="tokenize($olink-databases, ',\s*') ! normalize-space(.)">
      <xsl:variable name="db" select="."/>
      <xsl:try>
        <xsl:variable name="olinkdb" select="doc($db)/h:targetdb"/>
        <xsl:if test="empty($olinkdb)">
          <xsl:message select="'No targets in olinkdb:', $db"/>
        </xsl:if>
        <xsl:sequence select="$olinkdb"/>
        <xsl:catch>
          <xsl:message select="'Failed to load olinkdb:', $db"/>
        </xsl:catch>
      </xsl:try>
    </xsl:for-each>
  </xsl:if>
</xsl:variable>

<xsl:variable name="v:theme-list" as="element()*">
  <theme name="Materials dark" id="materials-dark" dark="true"/>
  <theme name="Materials light" id="materials-light" dark="false"/>
</xsl:variable>

<xsl:variable name="vp:js-controls" as="element()*">
  <xsl:variable name="chars"
                select="('a','b','c','d','e','f','_','_','_','1','2','3','4','5','6')"/>
  <xsl:variable name="random"
                select="string-join(random-number-generator()?permute($chars), '')"/>
  <span class="controls-open">☰</span>
  <div class="js-controls-wrapper">
    <xsl:if test="$v:theme-list[@dark='true']">
      <xsl:attribute name="db-dark-theme"
                     select="($v:theme-list[@dark='true'])[1]/@id"/>
    </xsl:if>
    <div class="js-controls-body">
      <div class="js-controls-header">
        <div class="js-controls-close">╳</div>
        <div class="js-controls-title">
          <xsl:text>Settings</xsl:text>
        </div>
      </div>
      <div class="js-controls-content">
        <fieldset db-random="{$random}" class="js-controls-toggles">
          <legend>Select options:</legend>
          <input id="db-js-annotations_{$random}" type="checkbox" value="js" />
          <label for="db-js-annotations_{$random}">JavaScript annotations</label><br/>
          <input id="db-js-xlinks_{$random}" type="checkbox" value="js" />
          <label for="db-js-xlinks_{$random}">JavaScript extended links</label><br/>
        </fieldset>
        <div id="db-js-controls-reload_{$random}" class="js-controls-reload"></div>
        <fieldset>
          <legend>Choose a theme:</legend>
          <input id="db-default-theme_{$random}" type="radio" name="db-theme" value="default" />
          <label for="db-default-theme_{$random}">Default</label><br/>
          <xsl:for-each select="$v:theme-list">
            <input id="db-theme-{@id}-{$random}"
                   type="radio" name="db-theme" value="{@id}" />
            <label for="db-theme-{@id}-{$random}">
              <xsl:sequence select="@name/string()"/>
            </label>
            <br/>
          </xsl:for-each>
        </fieldset>
      </div>
      <div class="js-controls-buttons">
        <button id="js-controls-cancel">✗</button>
        <xsl:text> </xsl:text>
        <button id="js-controls-ok">✓</button>
      </div>
    </div>
  </div>
</xsl:variable>

<!-- N.B. There's a bit of a hack in the variables below. We put the
     link and script elements in the same variable, but we use them in
     two different places so that the h:link element(s) precede the
     DocBook CSS files (in order to support overrides with cascade).
     -->

<xsl:variable name="v:highlight-js-head-elements" as="element()*">
  <link rel="stylesheet"
        href="{$resource-base-uri}css/highlight-11.6.0.min.css" />
  <script src="{$resource-base-uri}js/highlight-11.6.0.min.js"></script>
  <script>hljs.highlightAll();</script>
</xsl:variable>

<xsl:variable name="v:prism-js-head-elements" as="element()*">
  <link rel="stylesheet" href="{$resource-base-uri}css/prism.css"/>
  <script src="{$resource-base-uri}js/prism.js"></script>
</xsl:variable>

</xsl:stylesheet>
