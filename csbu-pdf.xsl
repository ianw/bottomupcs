<?xml version='1.0'?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    version="1.0">

<xsl:import href="docbook-xsl-ns-1.79.0/fo/docbook.xsl"/>

<xsl:param name="body.font.family">Helvetica</xsl:param>
<xsl:param name="body.font.size">11pt</xsl:param>

<xsl:attribute-set name="monospace.verbatim.properties">
  <xsl:attribute name="font-size">0.7em</xsl:attribute>
</xsl:attribute-set>

<xsl:param name="shade.verbatim" select="1" />
<xsl:attribute-set name="shade.verbatim.style">
  <xsl:attribute name="background-color">#F8F8F8</xsl:attribute>
  <xsl:attribute name="border-width">0.5pt</xsl:attribute>
  <xsl:attribute name="border-style">solid</xsl:attribute>
  <xsl:attribute name="border-color">#575757</xsl:attribute>
  <xsl:attribute name="padding">2pt</xsl:attribute>
</xsl:attribute-set>

</xsl:stylesheet>
