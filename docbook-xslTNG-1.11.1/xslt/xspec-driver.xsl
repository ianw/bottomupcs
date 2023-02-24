<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="db h m map t v vp xs"
                version="3.0">

<!-- This driver is used by the XSpec tests. It performs various small
     patches to the results to avoid spurious differences (for
     example, the version number of the stylesheets that produced the
     result).

     Note: XSpec tests that test formatting an element, rather than a
     document, check the body of the result, not the head. So if an
     element test is requested, only the body is returned.
 -->

<xsl:import href="docbook.xsl"/>

<!-- Set some parameters to values that make testing easier/more consistent -->
<xsl:param name="default-language" select="'en'"/>
<xsl:param name="additional-languages" select="'de en fr cs'"/>

<xsl:param name="xspec" select="'true'"/>
<xsl:param name="mediaobject-input-base-uri"
           select="resolve-uri('../../src/test/resources/media/')"/>
<xsl:param name="mediaobject-output-base-uri" select="'media/'"/>
<xsl:param name="pixels-per-inch" select="96.0"/>
<xsl:param name="nominal-page-width" select="'6in'"/>
<xsl:param name="default-length" select="144"/>
<xsl:param name="default-length-magnitude" select="25.0"/>
<xsl:param name="default-length-unit" select="'%'"/>
<xsl:param name="profile-os" select="'linux;win'"/>
<xsl:param name="profile-outputformat" select="'online'"/>
<xsl:param name="show-remarks" select="'true'"/>
<xsl:param name="table-accessibility" select="('summary', 'details')"/>
<xsl:param name="bibliography-collection"
           select="resolve-uri('../../src/test/resources/bibcollection.xml')"/>
<xsl:param name="glossary-collection"
           select="resolve-uri('../../src/test/resources/glosscollection.xml')"/>
<xsl:param name="annotation-collection"
           select="resolve-uri('../../src/test/resources/anncollection.xml')"/>
<xsl:param name="glossary-sort-entries" select="'true'"/>
<xsl:param name="verbatim-style-default" select="'plain'"/>

<!-- Configure dynamic profiling -->
<xsl:param name="dynamic-profiles" select="'true'"/>
<xsl:param name="dynamic-profile-variables" as="map(xs:QName, item()*)">
  <xsl:map>
    <xsl:map-entry key="QName('','thingy')" select="'enabled'"/>
    <xsl:map-entry key="QName('','istrue')" select="true()"/>
    <xsl:map-entry key="QName('','isfalse')" select="false()"/>
    <xsl:map-entry key="QName('','isempty')" select="()"/>
    <xsl:map-entry key="QName('','isthree')" select="3"/>
    <xsl:map-entry key="QName('','not-test-harness')" select="false()"/>
  </xsl:map>
</xsl:param>

<xsl:variable
    name="v:olink-databases"
    select="(doc(resolve-uri('../actual/guide.olinkdb'))/*,
             doc(resolve-uri('../actual/fit.001.olinkdb'))/*,
             doc(resolve-uri('../../src/website/resources/olinkdb/website.olinkdb'))/*)"/>

<xsl:template match="*">
  <!-- Turn the inital element into a document. -->
  <xsl:variable name="document">
    <xsl:sequence select="."/>
  </xsl:variable>

  <xsl:variable name="document" as="document-node()">
    <xsl:apply-templates select="$document"/>
  </xsl:variable>

  <xsl:sequence select="$document/h:html/h:body"/>
</xsl:template>

<xsl:template match="/" as="document-node()">
  <xsl:variable name="html" as="document-node()">
    <xsl:call-template name="t:docbook"/>
  </xsl:variable>

  <xsl:document>
    <xsl:apply-templates select="$html" mode="xspec-fixup"/>
  </xsl:document>
</xsl:template>

<xsl:template match="/" mode="xspec-fixup">
  <xsl:apply-templates mode="xspec-fixup"/>
</xsl:template>

<xsl:template match="element()" mode="xspec-fixup">
  <xsl:copy>
    <xsl:apply-templates select="@*,node()" mode="xspec-fixup"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:meta[@name='dc.modified']" mode="xspec-fixup">
  <!-- Assign a constant date -->
  <xsl:copy>
    <xsl:attribute name="content" select="'2011-04-22T17:02:00-06:00'"/>
    <xsl:apply-templates select="@name" mode="xspec-fixup"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="h:meta[@name='generator']" mode="xspec-fixup">
  <!-- Trim off the actual version information -->
  <xsl:copy>
    <xsl:attribute name="content" select="substring-before(@content, ' version')"/>
    <xsl:apply-templates select="@name" mode="xspec-fixup"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()"
              mode="xspec-fixup">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
