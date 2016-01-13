<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  version="1.0">

<xsl:template match="glossary">
<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">

  <fo:layout-master-set>

    <fo:simple-page-master master-name="all"
            page-height="11.5in" 
            page-width="8.5in"
            margin-top="1in" 
            margin-bottom="1in"
            margin-left="0.75in" 
            margin-right="0.75in">
    <fo:region-body margin-top="1in" margin-bottom="0.75in"/>
    <fo:region-before extent="0.75in"/>
    <fo:region-after extent="0.5in"/>
  </fo:simple-page-master>

  </fo:layout-master-set>

  <fo:page-sequence master-reference="all" format="i">

    <!-- header with running glossary entries -->
    <fo:static-content flow-name="xsl-region-before">
    <fo:block text-align="start"
      font-size="10pt" font-family="serif" line-height="1em + 2pt">
      <fo:retrieve-marker retrieve-class-name="term"
      retrieve-boundary="page"
      retrieve-position="first-starting-within-page"/>
    <fo:leader leader-alignment="reference-area" leader-pattern="dots"
      leader-length="4in"/>
      <fo:retrieve-marker retrieve-class-name="term"
      retrieve-boundary="page"
      retrieve-position="last-ending-within-page"/>
      </fo:block>
    </fo:static-content>

    <fo:static-content flow-name="xsl-region-after">
    <fo:block text-align="start"
      font-size="10pt" font-family="serif" line-height="1em + 2pt">
      Page (<fo:page-number/>)
      </fo:block>
    </fo:static-content>

    <fo:flow flow-name="xsl-region-body">
    <xsl:apply-templates select="term-entry"/>
  </fo:flow>
  </fo:page-sequence>
</fo:root>
</xsl:template>

<xsl:template match="term-entry">
  <fo:block text-align="start" font-size="12pt" font-family="sans-serif">
    <xsl:apply-templates select="term"/>
    <xsl:apply-templates select="definition"/>
  </fo:block>
</xsl:template>

<xsl:template match="term">
  <fo:block color="blue" space-before.optimum="3pt"><fo:marker
    marker-class-name="term"><xsl:value-of select="."/></fo:marker>
    <xsl:value-of select="."/>
  </fo:block>
</xsl:template>

<xsl:template match="definition">
  <fo:block text-align="start" start-indent="2em">
    <xsl:value-of select="."/>
  </fo:block>
</xsl:template>

</xsl:stylesheet>

