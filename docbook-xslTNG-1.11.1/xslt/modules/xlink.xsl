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
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f fp h m map mp t tp v vp xlink xs"
                version="3.0">

<!-- This module does some XLink processing. It doesn't generate fully
     explicit XLink elements, so it doesn't do exactly conformant
     XLink processing. -->

<xsl:key name="exlink" match="*" use="@xlink:type"/>
<xsl:key name="linkend" match="*" use="@linkend"/>
<xsl:key name="href" match="*" use="@xlink:href"/>

<!-- N.B. parens in the scheme expression are not handled! -->
<xsl:variable name="vp:xmlns-scheme"
              select="'^\s*xmlns\s*\(\s*(\c+)\s*=\s*(.*?)\)\s*$'"/>
<xsl:variable name="vp:xpath-scheme"
              select="'^\s*xpath\s*\((.*?)\)\s*$'"/>

<!-- Boy, do you wanna make sure this is cached if you have
     a lot of extended XLinks. This is going to get called for
     at least every inline. -->
<xsl:function name="fp:xlink-sources" as="document-node()" cache="yes">
  <xsl:param name="document" as="document-node()"/>
  <xsl:document>
    <xsl:apply-templates select="key('exlink', 'extended', $document)"
                         mode="mp:xlink-sources"/>
  </xsl:document>
</xsl:function>

<xsl:function name="fp:xlink-targets" as="document-node()" cache="yes">
  <xsl:param name="document" as="document-node()"/>
  <xsl:document>
    <xsl:apply-templates select="key('exlink', 'extended', $document)"
                         mode="mp:xlink-targets"/>
  </xsl:document>
</xsl:function>

<xsl:function name="f:xlink-style" as="xs:string">
  <xsl:param name="document" as="document-node()"/>

  <xsl:choose>
    <xsl:when test="$xlink-style != 'document'">
      <xsl:sequence select="$xlink-style"/>
    </xsl:when>
    <xsl:when test="$document/h:html">
      <!-- We're processing chunks, so look where we squirreled away
           the answer when we were processing the DocBook document. -->
      <xsl:sequence select="($document/h:html/h:div/@db-xlink/string(),
                             $xlink-style-default)[1]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence
          select="f:pi($document/*/db:info, 'xlink-style', $xlink-style-default)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:pmuj-enabled" as="xs:boolean" cache="yes">
  <xsl:param name="context" as="node()"/>
  <xsl:sequence select="f:is-true(f:pi(root($context)/*/db:info,
                                  'pmuj', $experimental-pmuj))"/>
</xsl:function>

<xsl:function name="fp:pmuj">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="id" as="xs:string"/>

  <xsl:variable name="sources" as="xs:string*">
    <xsl:for-each select="(key('linkend', $id, root($node)),
                           key('href', '#'||$id, root($node)))">
      <xsl:if test="not(@xlink:type='locator')">
        <xsl:sequence select="'#' || f:generate-id(.)"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:variable name="xlinks" select="fp:xlink-targets(root($node))"/>
    <xsl:variable name="sources" select="key('id', generate-id($node), $xlinks)"/>
    <xsl:if test="$sources">
      <xsl:variable name="locators" as="element()*">
        <xsl:apply-templates select="$node" mode="mp:out-of-line-pmuj">
          <xsl:with-param name="document" select="root($node)"/>
          <xsl:with-param name="locators" select="$sources"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:for-each select="$locators[self::db:locator]">
        <xsl:sequence select="@xlink:href/string()"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:variable>

  <xsl:for-each select="distinct-values($sources)">
    <a class="pmuj" href="{.}">◎</a>
  </xsl:for-each>
</xsl:function>

<xsl:template name="t:xlink">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>

  <xsl:if test="fp:pmuj-enabled(/)">
    <xsl:sequence select="@xml:id ! fp:pmuj(./parent::*, ./string())"/>
  </xsl:if>

  <xsl:variable name="xlinks" select="fp:xlink-sources(root(.))"/>

  <xsl:variable name="targets"
                select="key('id', generate-id(.), $xlinks)"/>

  <!-- Not handled: an explicitly extended link that is also
       the target of out-of-band links. -->

  <xsl:choose>
    <xsl:when test="@xlink:type = 'simple' or @xlink:href">
      <xsl:call-template name="tp:simple-xlink">
        <xsl:with-param name="content">
          <xsl:sequence select="$content"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="$targets">
      <xsl:call-template name="tp:out-of-line-xlink">
        <xsl:with-param name="document" select="root(.)"/>
        <xsl:with-param name="locators" select="$targets"/>
      </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
      <!-- It's just a normal, unlinked element -->
      <xsl:sequence select="$content"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[@xlink:type = 'extended']" priority="100">
  <xsl:choose>
    <xsl:when test="*[@xlink:type='resource']">
      <xsl:apply-templates select="*[@xlink:type='resource']"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message select="'Inline extended XLink with no resource:', ."/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="tp:simple-xlink">
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>

  <xsl:variable name="link">
    <xsl:choose>
      <xsl:when test="@xlink:href
                      and (not(@xlink:type)
                           or @xlink:type='simple')">
        <a>
          <xsl:if test="fp:pmuj-enabled(/)">
            <xsl:attribute name="id" select="f:generate-id(.)"/>
          </xsl:if>

          <xsl:if test="@xlink.title">
            <xsl:attribute name="title" select="@xlink:title"/>
          </xsl:if>

          <xsl:attribute name="href">
            <xsl:choose>
              <!-- if the href starts with # and does not contain an "(" -->
              <!-- or if the href starts with #xpointer(id(, it's just an ID -->
              <xsl:when test="starts-with(@xlink:href,'#')
                              and (not(contains(@xlink:href,'&#40;'))
                              or starts-with(@xlink:href,
                                             '#xpointer&#40;id&#40;'))">
                <xsl:variable name="idref" select="f:xpointer-idref(@xlink:href)"/>
                <xsl:variable name="target" select="key('id',$idref)[1]"/>

                <xsl:choose>
                  <xsl:when test="not($target)">
                    <xsl:message>
                      <xsl:text>XLink to nonexistent id: </xsl:text>
                      <xsl:sequence select="@xlink:href/string()"/>
                    </xsl:message>
                    <xsl:text>???</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="href" select="f:href(/,$target)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>

              <!-- otherwise it's a URI -->
              <xsl:otherwise>
                <xsl:sequence select="@xlink:href/string()"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:copy-of select="$content"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:sequence select="$link"/>
</xsl:template>

<!-- An "out-of-line" xlink. That is, this element is identified as the
     source of an arc. -->
<xsl:template name="tp:out-of-line-xlink">
  <xsl:param name="document" as="document-node()" required="yes"/>
  <xsl:param name="locators" as="element()+" required="yes"/>

  <xsl:variable name="context" select="."/>
  <xsl:variable name="arcs"
                select="$locators/@arc ! key('genid', ., $document)"/>

  <xsl:variable name="to" as="node()*">
    <xsl:for-each select="$arcs">
      <xsl:variable name="arc" select="."/>
      <xsl:variable name="locators"
                    select="$arc/../*[@xlink:label = $arc/@xlink:to]"/>
      <xsl:for-each select="$locators">
        <xsl:choose>
          <xsl:when test="@xlink:type = 'locator'">
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:when test="@xlink:type = 'resource'">
            <generated xlink:type="locator"
                       xlink:href="{f:href($context, .)}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="count($to) eq 1">
      <a href="{$to/@xlink:href}">
        <xsl:if test="$to/@xlink:title">
          <xsl:attribute name="title" select="$to/@xlink:title/string()"/>
        </xsl:if>
        <xsl:apply-templates/>
      </a>
    </xsl:when>
    <xsl:when test="f:xlink-style($document) = 'none'">
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
      <span class="xlink">
        <span class="source">
          <xsl:apply-templates/>
        </span>
        <span class="xlink-arc-list" db-arcs="{f:generate-id(.)}-arcs"/>
        <span class="nhrefs" id="{f:generate-id(.)}-arcs">
          <span class="xlink-arc-delim before">
            <xsl:sequence select="f:gentext(., 'separator', 'xlink-arclist-before')"/>
          </span>
          <span class="xlink-arc-title">
            <xsl:if test="$to/../@xlink:title">
              <xsl:sequence select="$to/../@xlink:title/string()"/>
            </xsl:if>
          </span>
          <xsl:if test="$to/../@xlink:title">
            <span class="xlink-arc-delim sep">
              <xsl:sequence select="f:gentext(., 'separator', 'xlink-arclist-titlesep')"/>
            </span>
          </xsl:if>
          <xsl:for-each select="$to">
            <xsl:if test="position() gt 1">
              <span class="xlink-arc-delim sep">
                <xsl:sequence select="f:gentext(., 'separator', 'xlink-arclist-sep')"/>
              </span>
            </xsl:if>
            <span class="arc">
              <a href="{@xlink:href}">
                <xsl:choose>
                  <xsl:when test="*[@xlink:type='title']">
                    <xsl:apply-templates select="*[@xlink:type='title'][1]"/>
                  </xsl:when>
                  <xsl:when test="@xlink:title">
                    <xsl:sequence select="@xlink:title/string()"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:message
                        select="'Warning: inline extended link locator without title', ."/>
                    <xsl:text>???</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </a>
            </span>
          </xsl:for-each>
          <span class="xlink-arc-delim after">
            <xsl:sequence select="f:gentext(., 'separator', 'xlink-arclist-after')"/>
          </span>
        </span>
      </span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- An "out-of-line" pmuj. That is, this element is identified as the
     target of an arc. -->
<xsl:template match="*" mode="mp:out-of-line-pmuj">
  <xsl:param name="document" as="document-node()" required="yes"/>
  <xsl:param name="locators" as="element()+" required="yes"/>

  <xsl:variable name="context" select="."/>
  <xsl:variable name="arcs"
                select="$locators/@arc ! key('genid', ., $document)"/>

  <xsl:variable name="from" as="node()*">
    <xsl:for-each select="$arcs">
      <xsl:variable name="arc" select="."/>
      <xsl:variable name="locators"
                    select="$arc/../*[@xlink:label = $arc/@xlink:from]"/>
      <xsl:for-each select="$locators">
        <xsl:choose>
          <xsl:when test="@xlink:type = 'locator'">
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:when test="@xlink:type = 'resource'">
            <generated xlink:type="locator"
                       xlink:href="{f:href($context, .)}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>

  <xsl:sequence select="$from"/>
</xsl:template>

<xsl:function name="f:xpointer-idref" as="xs:string?">
  <xsl:param name="xpointer"/>

  <xsl:choose>
    <xsl:when test="starts-with($xpointer, '#xpointer(id(')">
      <xsl:variable name="rest"
                    select="substring-after($xpointer, '#xpointer(id(')"/>
      <xsl:variable name="quote" select="substring($rest, 1, 1)"/>
      <xsl:sequence select="substring-before(substring-after($xpointer, $quote), $quote)"/>
    </xsl:when>
    <xsl:when test="starts-with($xpointer, '#')">
      <xsl:sequence select="substring-after($xpointer, '#')"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- otherwise it's a pointer to some other document -->
      <xsl:sequence select="()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:template match="*" mode="mp:xlink-sources">
  <xsl:for-each select="*[@xlink:type='arc' and @xlink:from and @xlink:to]">
    <xsl:variable name="arc" select="."/>
    <xsl:variable name="from-label" select="@xlink:from"/>
    <xsl:variable name="from-locator" select="../*[@xlink:label = $from-label]"/>

    <xsl:variable name="sources" as="element()*">
      <xsl:for-each select="$from-locator">
        <xsl:choose>
          <xsl:when test="@xlink:href">
            <xsl:sequence
                select="fp:find-xlink-nodes(root(.), @xlink:href, map { })"/>
          </xsl:when>
          <xsl:when test="@xlink:type='resource'">
            <source>
              <xsl:attribute name="xml:id" select="generate-id(.)"/>
            </source>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>
              <xsl:text>XLink locator without @xlink:href </xsl:text>
              <xsl:text>that isn’t a resource? </xsl:text>
              <xsl:sequence select="."/>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each select="$sources">
      <xsl:copy>
        <xsl:sequence select="@*"/>
        <xsl:attribute name="arc" select="generate-id($arc)"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<xsl:template match="*" mode="mp:xlink-targets">
  <xsl:for-each select="*[@xlink:type='arc' and @xlink:from and @xlink:to]">
    <xsl:variable name="arc" select="."/>
    <xsl:variable name="to-label" select="@xlink:to"/>
    <xsl:variable name="to-locator" select="../*[@xlink:label = $to-label]"/>

    <xsl:variable name="sources" as="element()*">
      <xsl:for-each select="$to-locator">
        <xsl:choose>
          <xsl:when test="@xlink:href">
            <xsl:sequence
                select="fp:find-xlink-nodes(root(.), @xlink:href, map { })"/>
          </xsl:when>
          <xsl:when test="@xlink:type='resource'">
            <source>
              <xsl:attribute name="xml:id" select="generate-id(.)"/>
            </source>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>
              <xsl:text>XLink locator without @xlink:href </xsl:text>
              <xsl:text>that isn’t a resource? </xsl:text>
              <xsl:sequence select="."/>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each select="$sources">
      <xsl:copy>
        <xsl:sequence select="@*"/>
        <xsl:attribute name="arc" select="generate-id($arc)"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="*" mode="mp:locator">
  <source>
    <xsl:attribute name="xml:id" select="generate-id(.)"/>
    <xsl:attribute name="hint"
                   select="node-name(.)
                           || (if (@xml:id) then '/' || @xml:id else '')
                           || ': '
                           || (if (string-length(string(.)) gt 10)
                               then substring(string(.), 1, 10) || '…'
                               else string(.))"/>
  </source>
</xsl:template>

<xsl:function name="fp:find-xlink-nodes">
  <xsl:param name="document" as="document-node()"/>
  <xsl:param name="locator" as="xs:string"/>
  <xsl:param name="nsmap" as="map(*)"/>

  <xsl:variable name="locator" select="normalize-space($locator)"/>

  <xsl:choose>
    <xsl:when test="$locator = ''"/>
    <xsl:when test="starts-with($locator, '#')">
      <xsl:variable name="id"
                    select="if (contains($locator, ' '))
                            then substring-before(substring($locator, 2), ' ')
                            else substring($locator, 2)"/>
      <xsl:apply-templates select="key('id', $id, $document)" mode="mp:locator"/>
    </xsl:when>
    <xsl:when test="matches($locator, '^\c+\s*\(.*?\)')">
      <xsl:variable name="scheme"
                    select="replace($locator, '^(\c+\s*\(.*?\)).*', '$1')"/>
      <xsl:variable name="rest"
                    select="substring($locator, string-length($scheme)+1)"/>
      <xsl:variable name="name"
                    select="replace($scheme, '^(\c+).*?$', '$1')"/>

      <xsl:choose>
        <xsl:when test="$name eq 'xmlns'">
          <xsl:sequence select="fp:xlink-xmlns-scheme($document, $locator, $nsmap, $scheme, $rest)"/>
        </xsl:when>
        <xsl:when test="$name eq 'xpath'">
          <xsl:sequence select="fp:xlink-xpath-scheme($document, $locator, $nsmap, $scheme, $rest)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message use-when="'xlink' = $v:debug"
                       select="'Ignoring unknown xpointer scheme: ' || $name"/>
          <xsl:sequence select="fp:find-xlink-nodes($document, $rest, $nsmap)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message use-when="'xlink' = $v:debug"
                   select="'Ignoring unrecognized xpointer: ' || $locator"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:xlink-xmlns-scheme">
  <xsl:param name="document" as="document-node()"/>
  <xsl:param name="locator" as="xs:string"/>
  <xsl:param name="nsmap" as="map(*)"/>
  <xsl:param name="scheme" as="xs:string"/>
  <xsl:param name="href" as="xs:string"/>

  <xsl:choose>
    <xsl:when test="matches($scheme, $vp:xmlns-scheme)">
      <xsl:variable name="prefix" select="replace($scheme, $vp:xmlns-scheme, '$1')"/>
      <xsl:variable name="uri" select="replace($scheme, $vp:xmlns-scheme, '$2')"/>

      <!-- You can't put : in URIs...? -->
      <xsl:variable name="uri" select="replace($uri, '%3A', ':', 'i')"/>

      <xsl:message use-when="'xlink' = $v:debug"
                   select="'xpointer: xmlns('||$prefix||'='||$uri||')'"/>
      <xsl:sequence
          select="fp:find-xlink-nodes($document, $href,
                                      map:merge(($nsmap, map:entry($prefix, $uri))))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message use-when="'xlink' = $v:debug"
                   select="'Unparseable xpointer scheme: ' || $scheme"/>
      <xsl:sequence select="fp:find-xlink-nodes($document, $href, $nsmap)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:xlink-xpath-scheme">
  <xsl:param name="document" as="document-node()"/>
  <xsl:param name="locator" as="xs:string"/>
  <xsl:param name="nsmap" as="map(*)"/>
  <xsl:param name="scheme" as="xs:string"/>
  <xsl:param name="href" as="xs:string"/>

  <xsl:choose>
    <xsl:when test="matches($scheme, $vp:xpath-scheme)">
      <xsl:variable name="expr" select="replace($scheme, $vp:xpath-scheme, '$1')"/>

      <!-- You can't put [ and ] in URIs; so they're escaped, so unescape them -->
      <xsl:variable name="expr" select="replace($expr, '%5B', '[', 'i')"/>
      <xsl:variable name="expr" select="replace($expr, '%5D', ']', 'i')"/>

      <xsl:message use-when="'xlink' = $v:debug"
                   select="'xpointer: xpath('||$expr||')'"/>

      <!-- Construct the namespace context -->
      <xsl:variable name="nscontext" as="element()">
        <context>
          <xsl:for-each select="map:keys($nsmap)">
            <xsl:namespace name="{.}" select="map:get($nsmap, .)"/>
          </xsl:for-each>
        </context>
      </xsl:variable>

      <xsl:variable name="found" as="node()*">
        <xsl:evaluate context-item="$document" xpath="$expr"
                      namespace-context="$nscontext"/>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="empty($found)">
          <xsl:message use-when="'xlink' = $v:debug"
                       select="'No nodes found for xpath scheme: ' || $expr"/>
          <xsl:sequence select="fp:find-xlink-nodes($document, $href, $nsmap)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$found" mode="mp:locator"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message use-when="'xlink' = $v:debug"
                   select="'Unparseable xpath scheme: ' || $scheme"/>
      <xsl:sequence select="fp:find-xlink-nodes($document, $href, $nsmap)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>
