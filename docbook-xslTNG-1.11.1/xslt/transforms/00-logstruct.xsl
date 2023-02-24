<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                exclude-result-prefixes="#all"
                version="3.0">

<!-- Replace @entityref media objects with @fileref. This is the first
     in a series of transformations. Because only the first document
     in a series of transformations has (guaranteed) access to the
     original base URI and any declarations provided in an internal or
     external subset, this stylesheet adds an xml:base attribute to
     the root element. -->

<xsl:output method="xml" encoding="utf-8" indent="no"/>

<xsl:param name="vp:starting-base-uri" as="xs:string?" select="()"/>

<xsl:template match="/*" priority="100">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:if test="not(@xml:base)">
      <xsl:attribute name="xml:base"
                     select="if (exists($vp:starting-base-uri))
                             then $vp:starting-base-uri
                             else base-uri(.)"/>
    </xsl:if>
    <xsl:apply-templates select="node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="db:imagedata[@entityref]
                     |db:textdata[@entityref]
                     |db:videodata[@entityref]
                     |db:audiodata[@entityref]">
  <xsl:copy>
    <xsl:apply-templates select="@* except @entityref"/>
    <xsl:if test="@entityref">
      <xsl:attribute name="fileref">
        <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="element()">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
