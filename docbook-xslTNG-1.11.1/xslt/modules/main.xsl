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
                exclude-result-prefixes="db f fp h m map mp t v vp xs"
                version="3.0">

<xsl:import href="../param.xsl"/>
<xsl:import href="../VERSION.xsl"/>
<xsl:import href="variable.xsl"/>
<xsl:import href="space.xsl"/>
<xsl:import href="unhandled.xsl"/>
<xsl:import href="errors.xsl"/>
<xsl:import href="head.xsl"/>
<xsl:import href="titles.xsl"/>
<xsl:import href="units.xsl"/>
<xsl:import href="shared.xsl"/>
<xsl:import href="gentext.xsl"/>
<xsl:import href="functions.xsl"/>
<xsl:import href="toc.xsl"/>
<xsl:import href="divisions.xsl"/>
<xsl:import href="components.xsl"/>
<xsl:import href="refentry.xsl"/>
<xsl:import href="bibliography.xsl"/>
<xsl:import href="glossary.xsl"/>
<xsl:import href="index.xsl"/>
<xsl:import href="sections.xsl"/>
<xsl:import href="templates.xsl"/>
<xsl:import href="titlepage.xsl"/>
<xsl:import href="info.xsl"/>
<xsl:import href="lists.xsl"/>
<xsl:import href="blocks.xsl"/>
<xsl:import href="admonitions.xsl"/>
<xsl:import href="programming.xsl"/>
<xsl:import href="msgset.xsl"/>
<xsl:import href="objects.xsl"/>
<xsl:import href="footnotes.xsl"/>
<xsl:import href="verbatim.xsl"/>
<xsl:import href="tablecals.xsl"/>
<xsl:import href="tablehtml.xsl"/>
<xsl:import href="inlines.xsl"/>
<xsl:import href="xlink.xsl"/>
<xsl:import href="links.xsl"/>
<xsl:import href="xref.xsl"/>
<xsl:import href="attributes.xsl"/>
<xsl:import href="publishers.xsl"/>
<xsl:import href="annotations.xsl"/>
<xsl:import href="profile.xsl"/>
<xsl:import href="chunk.xsl"/>
<xsl:import href="chunk-cleanup.xsl"/>
<xsl:import href="chunk-output.xsl"/>

<xsl:output method="xhtml" encoding="utf-8" indent="no" html-version="5"
            omit-xml-declaration="yes"/>

<xsl:key name="targetptr" match="*" use="@targetptr"/>

<xsl:param name="output-media" select="'screen'"/>

<xsl:template match="/" name="xsl:initial-template">
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
