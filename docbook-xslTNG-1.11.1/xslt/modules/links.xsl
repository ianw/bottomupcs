<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f fp h m t tp v xlink xs"
                version="3.0">

<xsl:template match="db:anchor">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:biblioref">
  <xsl:call-template name="tp:xref"/>
</xsl:template>

<xsl:template match="db:link">
  <xsl:choose>
    <xsl:when test="@linkend and empty(node())">
      <xsl:call-template name="tp:xref"/>
    </xsl:when>
    <xsl:when test="@linkend">
      <xsl:variable name="linkend"
                    select="(@linkend,
                            if (starts-with(@xlink:href, '#'))
                            then substring-after(@xlink:href, '#')
                            else ())[1]"/>
      <xsl:variable name="target"
                    select="if ($linkend)
                            then key('id', $linkend)[1]
                            else ()"/>
      <xsl:choose>
        <xsl:when test="empty($target)">
          <xsl:message select="'Link to non-existent ID: ' || $linkend"/>
          <xsl:sequence select="'[???' || $linkend || '???]'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="tp:link">
            <xsl:with-param name="href" select="f:href(., $target)"/>
            <xsl:with-param name="content" as="node()*">
              <xsl:apply-templates select="node()"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="tp:link">
        <xsl:with-param name="content" as="item()*">
          <xsl:choose>
            <xsl:when test="empty(node())">
              <xsl:sequence select="@xlink:href/string()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="m:link">
  <xsl:param name="primary-markup" select="false()"/>
  <xsl:param name="content" as="item()*"/>

  <xsl:choose>
    <xsl:when test="@linkend">
      <xsl:call-template name="tp:link">
        <xsl:with-param name="primary-markup" select="$primary-markup"/>
        <xsl:with-param name="href" select="'#' || @linkend"/>
        <xsl:with-param name="content" select="$content"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="@xlink:href">
      <xsl:call-template name="tp:link">
        <xsl:with-param name="primary-markup" select="$primary-markup"/>
        <xsl:with-param name="href" select="@xlink:href/string()"/>
        <xsl:with-param name="content" select="$content"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="t:xlink">
        <xsl:with-param name="content" select="$content"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:firstterm|db:glossterm" mode="m:link">
  <xsl:variable name="target"
                select="key('glossterm', (@baseform,normalize-space(.))[1])"/>

  <xsl:choose>
    <xsl:when test="empty($target)">
      <xsl:message select="'Gloss term has no entry:',
                           (@baseform/string(), normalize-space(.))[1]"/>
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="count($target) gt 1">
        <xsl:message select="'Gloss term has multiple entries:',
                             (@baseform/string(), normalize-space(.))[1]"/>
      </xsl:if>
      <xsl:call-template name="tp:link">
        <xsl:with-param name="primary-markup" select="false()"/>
        <xsl:with-param name="href" select="f:href(., $target)"/>
        <xsl:with-param name="content" as="item()*">
          <xsl:apply-templates/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="tp:link">
  <xsl:param name="title" select="db:alt[1]/string()" as="xs:string?"/>
  <xsl:param name="href" select="iri-to-uri(@xlink:href)" as="xs:string"/>
  <xsl:param name="content" as="item()*" required="yes"/>
  <xsl:param name="primary-markup" as="xs:boolean" select="true()"/>

  <xsl:choose>
    <xsl:when test="$href != ''">
      <a href="{$href}">
        <xsl:if test="$primary-markup">
          <xsl:apply-templates select="." mode="m:attributes"/>
        </xsl:if>
        <xsl:if test="fp:pmuj-enabled(/)">
          <xsl:attribute name="id" select="f:generate-id(.)"/>
        </xsl:if>
        <xsl:if test="exists($title)">
          <xsl:attribute name="title" select="$title"/>
        </xsl:if>
        <xsl:sequence select="$content"/>
      </a>
    </xsl:when>
    <xsl:when test="@linkend">
      <xsl:variable name="target" select="f:target(@linkend, .)"/>
      <xsl:choose>
        <xsl:when test="empty($target)">
          <xsl:message select="'Link to undefined ID:', string(@linkend)"/>
          <span class="markup-error">
            <xsl:if test="$primary-markup">
              <xsl:apply-templates select="." mode="m:attributes"/>
            </xsl:if>
            <xsl:if test="exists($title)">
              <xsl:attribute name="title" select="$title"/>
            </xsl:if>
            <xsl:sequence select="'@@LINKEND: ' || @linkend || '@@'"/>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <a href="{f:href(., $target)}">
            <xsl:if test="$primary-markup">
              <xsl:apply-templates select="." mode="m:attributes"/>
            </xsl:if>
            <xsl:if test="exists($title)">
              <xsl:attribute name="title" select="$title"/>
            </xsl:if>
            <xsl:sequence select="$content"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message select="'Link element with no target?', ."/>
      <span class="markup-error">
        <xsl:if test="$primary-markup">
          <xsl:apply-templates select="." mode="m:attributes"/>
        </xsl:if>
        <xsl:if test="exists($title)">
          <xsl:attribute name="title" select="$title"/>
        </xsl:if>
        <xsl:sequence select="$content"/>
      </span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:xref" name="tp:xref">
  <xsl:param name="linkend"
             select="(@linkend,
                     if (starts-with(@xlink:href, '#'))
                     then substring-after(@xlink:href, '#')
                     else ())[1]"/>

  <xsl:variable name="target"
                select="if ($linkend)
                        then key('id', $linkend)[1]
                        else ()"/>

  <xsl:choose>
    <xsl:when test="empty($target)">
      <xsl:message select="'Link to non-existent ID: ' || $linkend"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="content" as="item()*">
        <xsl:choose>
          <xsl:when test="@endterm">
            <xsl:variable name="label" select="key('id', @endterm)[1]"/>
            <xsl:choose>
              <xsl:when test="empty($label)">
                <xsl:message select="'Endterm to non-existent ID: '
                                     || @endterm/string()"/>
                <xsl:apply-templates select="$target" mode="m:crossref"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$label/node()"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$target/@xreflabel">
            <xsl:sequence select="$target/@xreflabel/string()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$target" mode="m:crossref"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <a href="#{f:id($target)}" class="xref xref-{local-name($target)}">
        <xsl:if test="fp:pmuj-enabled(/)">
          <xsl:attribute name="id" select="f:generate-id(.)"/>
        </xsl:if>
        <xsl:sequence select="$content"/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:olink">
  <xsl:variable name="targetdoc" select="@targetdoc/string()"/>
  <xsl:variable name="targetptr" select="@targetptr/string()"/>
  <xsl:variable name="targetdb" select="($v:olink-databases[@targetdoc = $targetdoc])[1]"/>
  <xsl:variable name="obj" select="key('targetptr', $targetptr, root($targetdb))"/>

  <xsl:choose>
    <xsl:when test="empty($targetdb)">
      <xsl:message select="'olink: no targetdoc:', $targetdoc"/>
      <span class="error">
        <xsl:sequence select="'olink: ' || $targetdoc || '/' || $targetptr"/>
      </span>
    </xsl:when>
    <xsl:when test="empty($obj)">
      <xsl:message select="'olink: no targetptr: ' || $targetdoc || '/' || $targetptr"/>
      <span class="error">
        <xsl:sequence select="'olink: ' || $targetdoc || '/' || $targetptr"/>
      </span>
    </xsl:when>
    <xsl:when test="empty(node())">
      <a href="{$obj/@href}">
        <xsl:sequence select="$obj/h:xreftext/node()"/>
      </a>
    </xsl:when>
    <xsl:otherwise>
      <a href="{$obj/@href}">
        <xsl:apply-templates/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
