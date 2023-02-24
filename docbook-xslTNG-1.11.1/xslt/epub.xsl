<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:epub='http://docbook.org/ns/docbook/epub'
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                expand-text="yes"
                exclude-result-prefixes="#all"
                version="3.0">

<xsl:import href="docbook.xsl"/>
<xsl:import href="modules/epub-tidy.xsl"/>
<xsl:import href="modules/epub-chunk.xsl"/>
<xsl:import href="modules/epub-metadata.xsl"/>

<xsl:param name="pub-id" as="xs:string?" select="()"/>
<xsl:param name="manifest-extra" as="xs:string?" select="()"/>

<xsl:param name="chunk" select="'titlepage.xhtml'"/>
<xsl:param name="html-extension" select="'.xhtml'"/>
<xsl:param name="table-accessibility" select="()"/>
<xsl:param name="mediaobject-accessibility" select="()"/>
<xsl:param name="annotate-toc" select="'false'"/>

<xsl:output method="xhtml" html-version="5" encoding="utf-8" indent="no"
            omit-xml-declaration="yes"/>

<xsl:template match="/" mode="m:epub">
  <xsl:call-template name="t:epub"/>
</xsl:template>

<xsl:template match="/" name="t:epub">
  <xsl:variable name="results" as="map(xs:string, item())">
    <xsl:call-template name="t:docbook">
      <xsl:with-param name="return" select="'raw-results'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="html">
    <xsl:apply-templates select="$results?output" mode="m:epub-tidy"/>
  </xsl:variable>

  <xsl:document>application/epub+zip</xsl:document>

  <xsl:result-document href="META-INF/container.xml">
    <container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
      <rootfiles>
        <rootfile full-path="OPS/package.opf" media-type="application/oebps-package+xml"/>
      </rootfiles>
    </container>
  </xsl:result-document>

  <xsl:variable name="info" select="$results?document/*/db:info"/>
  <xsl:variable name="head" select="$html/h:html/h:html[1]/h:head"/>

  <xsl:variable name="package-pub-id" as="xs:string">
    <xsl:choose>
      <xsl:when test="exists($pub-id)">
        <xsl:sequence select="$pub-id"/>
      </xsl:when>
      <xsl:when test="$info/epub:pub-id">
        <xsl:sequence select="string($info/epub:pub-id)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>No pub-id specified, generating random id.</xsl:message>
        <xsl:iterate select="1 to 32">
          <xsl:param name="random" select="random-number-generator()"/>
          <xsl:param name="id" as="xs:string" select="'random-'"/>
          <xsl:on-completion select="$id"/>
          <xsl:next-iteration>
            <xsl:with-param name="random" select="$random?next()"/>
            <xsl:with-param name="id" as="xs:string">
              <xsl:variable name="digit" select="floor($random?number * 16)"/>
              <xsl:sequence select="$id || ',' || substring('0123456789abcdef', $digit+1, 1)"/>
            </xsl:with-param>
          </xsl:next-iteration>
        </xsl:iterate>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:result-document href="OPS/package.opf" method="xml" indent="yes">
    <package xmlns="http://www.idpf.org/2007/opf"
             version="3.0" xml:lang="en"
             unique-identifier="pub-id"
             prefix="cc: http://creativecommons.org/ns#">
      <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
        <dc:identifier id="pub-id">{$package-pub-id}</dc:identifier>
        <xsl:apply-templates select="$info" mode="m:epub-metadata"/>
      </metadata>
      <manifest>
        <item id="toc" properties="nav" href="toc.xhtml" media-type="application/xhtml+xml"/>
        <item id="titlepage" href="titlepage.xhtml" media-type="application/xhtml+xml"/>

        <xsl:for-each select="($html//h:html[@db-chunk])[position() gt 1]">
          <xsl:variable name="filename"
                        select="tokenize(@db-chunk, '/')[last()]
                                ! replace(., '\.html$', '.xhtml')"/>
          <xsl:variable name="id" select="'x' || replace($filename, '\.', '_')"/>
          <item id="{$id}" href="{$filename}" media-type="application/xhtml+xml"/>
        </xsl:for-each>

        <xsl:if test="exists($manifest-extra)">
          <xsl:variable name="extra" select="doc($manifest-extra)"/>
          <xsl:sequence select="$extra/*/*"/>
        </xsl:if>
      </manifest>
      <spine>
        <!--
        <itemref idref="cover" linear="no"/>
        -->
        <itemref idref="titlepage" linear="yes"/>
        <!--
        <itemref idref="brief-toc" linear="yes"/>
        -->
        <xsl:for-each select="($html//h:html[@db-chunk])[position() gt 1]">
          <xsl:variable name="filename" select="tokenize(@db-chunk, '/')[last()]"/>
          <xsl:variable name="id" select="'x' || replace($filename, '\.', '_')"/>
          <itemref linear="yes" idref="{$id}"/>
        </xsl:for-each>
        <!--
        <itemref idref="copyright" linear="yes"/>
        -->
        <itemref idref="toc" linear="no"/>
      </spine>
    </package>
  </xsl:result-document>

  <xsl:apply-templates select="$html/h:html/h:html" mode="m:epub-chunk"/>
</xsl:template>

</xsl:stylesheet>
