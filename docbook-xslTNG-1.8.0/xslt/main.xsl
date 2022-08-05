<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f fp h m map mp t v vp xs"
                version="3.0">

<xsl:output method="xhtml" encoding="utf-8" indent="no" html-version="5"
            omit-xml-declaration="yes"/>

<xsl:key name="id" match="*" use="@xml:id"/>
<xsl:key name="genid" match="*" use="generate-id(.)"/>
<xsl:key name="targetptr" match="*" use="@targetptr"/>

<xsl:param name="output-media" select="'screen'"/>

<xsl:import href="param.xsl"/>
<xsl:import href="parameter-maps.xsl"/>
<xsl:import href="VERSION.xsl"/>
<xsl:import href="modules/variable.xsl"/>
<xsl:import href="modules/space.xsl"/>
<xsl:import href="modules/unhandled.xsl"/>
<xsl:import href="modules/errors.xsl"/>
<xsl:import href="modules/head.xsl"/>
<xsl:import href="modules/titles.xsl"/>
<xsl:import href="modules/units.xsl"/>
<xsl:import href="modules/shared.xsl"/>
<xsl:import href="modules/gentext.xsl"/>
<xsl:import href="modules/functions.xsl"/>
<xsl:import href="modules/toc.xsl"/>
<xsl:import href="modules/divisions.xsl"/>
<xsl:import href="modules/components.xsl"/>
<xsl:import href="modules/refentry.xsl"/>
<xsl:import href="modules/bibliography.xsl"/>
<xsl:import href="modules/glossary.xsl"/>
<xsl:import href="modules/index.xsl"/>
<xsl:import href="modules/sections.xsl"/>
<xsl:import href="modules/templates.xsl"/>
<xsl:import href="modules/titlepage.xsl"/>
<xsl:import href="modules/info.xsl"/>
<xsl:import href="modules/lists.xsl"/>
<xsl:import href="modules/blocks.xsl"/>
<xsl:import href="modules/admonitions.xsl"/>
<xsl:import href="modules/programming.xsl"/>
<xsl:import href="modules/msgset.xsl"/>
<xsl:import href="modules/objects.xsl"/>
<xsl:import href="modules/footnotes.xsl"/>
<xsl:import href="modules/verbatim.xsl"/>
<xsl:import href="modules/tablecals.xsl"/>
<xsl:import href="modules/tablehtml.xsl"/>
<xsl:import href="modules/inlines.xsl"/>
<xsl:import href="modules/xlink.xsl"/>
<xsl:import href="modules/links.xsl"/>
<xsl:import href="modules/xref.xsl"/>
<xsl:import href="modules/attributes.xsl"/>
<xsl:import href="modules/publishers.xsl"/>
<xsl:import href="modules/annotations.xsl"/>
<xsl:import href="modules/profile.xsl"/>
<xsl:import href="modules/chunk.xsl"/>
<xsl:import href="modules/chunk-cleanup.xsl"/>
<xsl:import href="modules/chunk-output.xsl"/>

<xsl:template match="/" mode="m:docbook">
  <xsl:document>
    <html>
      <xsl:attribute name="xml:base" select="base-uri(/*)"/>
      <xsl:apply-templates select="(/*/db:info,/*)[1]" mode="m:html-head"/>
      <!-- N.B. Any filename specified in a PI is ignored for the root -->
      <div db-chunk="{$chunk}"
           db-xlink="{f:xlink-style(/)}">
        <xsl:sequence select="fp:chunk-navigation(/*)"/>
        <xsl:apply-templates/>
      </div>

      <xsl:if test="f:is-true($theme-picker) and $vp:js-controls">
        <db-script>
          <script type="text/html" id="db-js-controls">
            <xsl:sequence select="$vp:js-controls"/>
          </script>
        </db-script>
      </xsl:if>

      <!-- These get copied into the chunks that need them... -->
      <xsl:if test="exists($resource-base-uri)">
        <db-annotation-script>
          <script type="text/html" class="annotation-close">
            <xsl:sequence select="$v:annotation-close"/>
          </script>
          <script src="{$resource-base-uri}{$annotations-js}"/>
        </db-annotation-script>
        <db-xlink-script>
          <xsl:if test="$xlink-icon-open">
            <script type="text/html" class="xlink-icon-open">
              <xsl:sequence select="$xlink-icon-open"/>
            </script>
          </xsl:if>
          <xsl:if test="$xlink-icon-closed">
            <script type="text/html" class="xlink-icon-closed">
              <xsl:sequence select="$xlink-icon-closed"/>
            </script>
          </xsl:if>
          <script src="{$resource-base-uri}{$xlink-js}"/>
        </db-xlink-script>
        <db-toc-script>
          <script src="{$resource-base-uri}{$persistent-toc-js}"/>
        </db-toc-script>
        <db-mathml-script>
          <script src="{if (starts-with($mathml-js, 'http:')
                            or starts-with($mathml-js, 'https:'))
                        then $mathml-js
                        else $resource-base-uri || $mathml-js}"/>
        </db-mathml-script>
        <db-script>
          <xsl:if test="exists($chunk) and f:is-true($chunk-nav)">
            <script src="{$resource-base-uri}{$chunk-nav-js}"/>
          </xsl:if>
          <xsl:if test="f:is-true($theme-picker) and $vp:js-controls">
            <script src="{$resource-base-uri}{$control-js}"/>
          </xsl:if>
        </db-script>
      </xsl:if>
    </html>
  </xsl:document>
</xsl:template>

<xsl:template match="text()">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
