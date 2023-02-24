<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:ext="http://docbook.org/extensions/xslt"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xi='http://www.w3.org/2001/XInclude'
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="3.0">

<!-- This will all be in XProc 3.0 eventually, hack for now... -->
<xsl:import href="main.xsl"/>

<xsl:variable name="v:standard-transforms" as="map(*)*">
  <xsl:map>
    <xsl:map-entry key="'stylesheet-location'"
                   select="resolve-uri('transforms/00-logstruct.xsl', static-base-uri())"/>
  </xsl:map>
  <xsl:map>
    <xsl:map-entry key="'stylesheet-location'"
                   select="resolve-uri('transforms/10-xinclude.xsl', static-base-uri())"/>
    <xsl:map-entry key="'functions'" select="'Q{http://docbook.org/extensions/xslt}xinclude'"/>
    <xsl:map-entry key="'test'" select="'exists(//xi:include)'"/>
  </xsl:map>
  <xsl:map>
    <xsl:map-entry key="'stylesheet-location'"
                   select="resolve-uri('transforms/20-db4to5.xsl', static-base-uri())"/>
    <xsl:map-entry key="'test'">
      not(namespace-uri(/*) = 'http://docbook.org/ns/docbook')
    </xsl:map-entry>
    <xsl:map-entry key="'extra-params'"
                   select="map { QName('', 'base-uri'): 'base-uri(/*)' }"/>
  </xsl:map>
  <xsl:map>
    <xsl:map-entry key="'stylesheet-location'"
                   select="resolve-uri('transforms/30-transclude.xsl', static-base-uri())"/>
    <xsl:map-entry key="'test'" select="'f:is-true($docbook-transclusion)'"/>
  </xsl:map>
  <xsl:map>
    <xsl:map-entry key="'stylesheet-location'"
                   select="resolve-uri('transforms/40-profile.xsl', static-base-uri())"/>
    <xsl:map-entry key="'test'">
         f:is-true($dynamic-profiles)
      or $profile-lang != ''         or $profile-revisionflag != ''
      or $profile-role != ''         or $profile-arch != ''
      or $profile-audience != ''     or $profile-condition != ''
      or $profile-conformance != ''  or $profile-os != ''
      or $profile-outputformat != '' or $profile-revision != ''
      or $profile-security != ''     or $profile-userlevel != ''
      or $profile-vendor != ''       or $profile-wordsize != ''
    </xsl:map-entry>
  </xsl:map>
  <xsl:map>
    <xsl:map-entry key="'stylesheet-location'"
                   select="resolve-uri('transforms/50-normalize.xsl', static-base-uri())"/>
  </xsl:map>
  <xsl:map>
    <xsl:map-entry key="'stylesheet-location'"
                   select="resolve-uri('transforms/60-annotations.xsl', static-base-uri())"/>
    <xsl:map-entry key="'test'" select="'exists(//db:annotation)'"/>
  </xsl:map>
  <xsl:map>
    <xsl:map-entry key="'stylesheet-location'"
                   select="resolve-uri('transforms/70-xlinkbase.xsl', static-base-uri())"/>
  </xsl:map>
  <xsl:if test="exists($local-conventions)">
    <xsl:map>
      <xsl:map-entry key="'stylesheet-location'" select="$local-conventions"/>
    </xsl:map>
  </xsl:if>
  <xsl:map>
    <xsl:map-entry key="'stylesheet-location'"
                   select="resolve-uri('transforms/75-validate.xsl', static-base-uri())"/>
    <xsl:map-entry key="'functions'"
                   select="'Q{http://docbook.org/extensions/xslt}validate-with-relax-ng'"/>
    <xsl:map-entry key="'test'"
                   select="'normalize-space($relax-ng-grammar) != '''''"/>
  </xsl:map>
  <xsl:map>
    <xsl:map-entry key="'stylesheet-location'"
                   select="resolve-uri('transforms/80-oxy-markup.xsl', static-base-uri())"/>
    <xsl:map-entry key="'test'">
      f:is-true(f:pi(/*/db:info, 'oxy-markup', $oxy-markup))
      and exists(//processing-instruction()[starts-with(name(), 'oxy_')])
    </xsl:map-entry>
  </xsl:map>
</xsl:variable>

<xsl:variable name="vp:transforms" as="map(*)*">
  <xsl:for-each select="$transform-original">
    <xsl:choose>
      <xsl:when test=". instance of map(*)">
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:when test=". instance of xs:string">
        <xsl:sequence select="map {
            'stylesheet-location': resolve-uri(., base-uri(/))
          }"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="error($dbe:INVALID-TRANSFORM, 
                                    'Each $transform-original must be a string or a map')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>

  <xsl:sequence select="$v:standard-transforms"/>

  <xsl:for-each select="$transform-before">
    <xsl:choose>
      <xsl:when test=". instance of map(*)">
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:when test=". instance of xs:string">
        <xsl:sequence select="map {
            'stylesheet-location': resolve-uri(., base-uri(/))
          }"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="error($dbe:INVALID-TRANSFORM, 
                                    'Each $transform-preprocessed must be a string or a map')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:variable>

<!-- If a document or element is being processed in the default
     mode (and not the m:docbook mode), assume we're starting 
     a transformation. -->
<xsl:template match="/" name="t:docbook">
  <xsl:param name="vp:loop-count" select="0" tunnel="yes"/>
  <xsl:param name="return" as="xs:string" select="'main-document'"/>

  <xsl:if test="$vp:loop-count gt 0">
    <xsl:message terminate="yes">
      <xsl:text>Loop detected, perhaps a mode is missing?</xsl:text>
    </xsl:message>
  </xsl:if>

  <xsl:variable name="starting-base-uri" as="xs:string">
    <xsl:choose>
      <xsl:when test="true()" use-when="function-available('ext:cwd')">
        <xsl:sequence select="resolve-uri(base-uri(.),
                                          resolve-uri(ext:cwd(), static-base-uri()))"/>
      </xsl:when>
      <xsl:when test="true()">
        <xsl:sequence select="resolve-uri(base-uri(.), static-base-uri())"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  <!--
  <xsl:message select="'Starting base uri:', $starting-base-uri"/>
  -->

  <xsl:variable name="document" as="document-node()">
    <xsl:choose>
      <xsl:when test="./self::document-node()">
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:document>
          <xsl:sequence select="."/>
        </xsl:document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="document" as="document-node()">
    <xsl:sequence
        select="fp:run-transforms($document, $vp:transforms,
                                  map { xs:QName('vp:starting-base-uri'): $starting-base-uri })"/>
  </xsl:variable>

  <xsl:variable name="result" as="document-node()">
    <xsl:apply-templates select="$document" mode="m:docbook">
      <xsl:with-param name="vp:loop-count" select="1" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="result" as="document-node()">
    <xsl:call-template name="t:chunk-cleanup">
      <xsl:with-param name="docbook" select="$document"/>
      <xsl:with-param name="source">
        <xsl:apply-templates select="$document" mode="m:docbook">
          <xsl:with-param name="vp:loop-count" select="1" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="post-processing" as="map(*)*">
    <xsl:for-each select="$transform-after">
      <xsl:choose>
        <xsl:when test=". instance of map(*)">
          <xsl:sequence select="."/>
        </xsl:when>
        <xsl:when test=". instance of xs:string">
          <xsl:sequence select="map {
                                  'stylesheet-location': resolve-uri(., base-uri(/))
                                }"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="error($dbe:INVALID-TRANSFORM, 
                                      'Each $transform-preprocessed must be a string or a map')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="result" as="document-node()">
    <xsl:sequence select="fp:run-transforms($result, $post-processing)"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$return = 'raw-results'">
      <xsl:sequence select="map {
          'document': $document,
          'output': $result
        }"/>
    </xsl:when>
    <xsl:when test="$return = 'chunked-results'">
      <xsl:variable name="chunks" as="map(xs:string, item()*)">
        <xsl:call-template name="t:chunk-output">
          <xsl:with-param name="docbook" select="$document"/>
          <xsl:with-param name="source" select="$result"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:sequence select="map {
          'document': $document,
          'chunks': $chunks
        }"/>
    </xsl:when>
    <xsl:when test="$return = 'main-document'">
      <xsl:variable name="result" as="map(xs:string, item()*)">
        <xsl:call-template name="t:chunk-output">
          <xsl:with-param name="docbook" select="$document"/>
          <xsl:with-param name="source" select="$result"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:for-each select="map:keys($result)">
        <xsl:if test=". != 'output'">
          <xsl:apply-templates select="map:get($result, .)" mode="m:chunk-write">
            <xsl:with-param name="href" select="."/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:for-each>

      <xsl:choose>
        <xsl:when test="not($result?output/h:html)">
          <xsl:sequence select="$result?output"/>
        </xsl:when>
        <xsl:when test="f:is-true($generate-html-page)">
          <xsl:sequence select="$result?output"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$result?output/h:html/h:body/node()
                                except $result?output/h:html/h:body/h:script"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
        <xsl:sequence select="error($dbe:INVALID-RESULTS-REQUESTED,
                                    'Unexepcted return: ' || $return)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="t:chunk-cleanup" as="document-node()">
  <xsl:param name="source" as="document-node()" select="."/>
  <xsl:param name="docbook" as="document-node()" required="yes"/>

  <xsl:apply-templates select="$source" mode="m:chunk-cleanup">
    <xsl:with-param name="docbook" select="$docbook" tunnel="yes"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template name="t:chunk-output" as="map(xs:string, item()*)">
  <xsl:param name="source" as="document-node()" select="."/>
  <xsl:param name="docbook" as="document-node()" required="yes"/>

  <xsl:apply-templates select="$source" mode="m:chunk-output">
    <xsl:with-param name="docbook" select="$docbook" tunnel="yes"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="node()" mode="m:chunk-write">
  <xsl:param name="href" as="xs:string" required="yes"/>

  <xsl:result-document href="{$href}">
    <xsl:choose>
      <xsl:when test="not(self::h:html)">
        <!-- If this happens not to be an h:html element, just output it. -->
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:when test="f:is-true($generate-html-page)">
        <!-- If this is an h:html element, and generate-html-page is true,
             output just output it. -->
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:otherwise>
        <!-- We got an h:html, but the user has requested 'raw' output.
             Attempt to strip out the generated html page wrapper. -->
        <xsl:sequence select="h:body/node() except h:body/h:script"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:result-document>
</xsl:template>

<xsl:function name="fp:run-transforms" as="document-node()">
  <xsl:param name="document" as="document-node()"/>
  <xsl:param name="transforms" as="map(*)*"/>
  <xsl:sequence select="fp:run-transforms($document, $transforms, ())"/>
</xsl:function>

<xsl:function name="fp:run-transforms" as="document-node()">
  <xsl:param name="document" as="document-node()"/>
  <xsl:param name="transforms" as="map(*)*"/>
  <xsl:param name="extra-parameters" as="map(*)?"/>

  <xsl:choose>
    <xsl:when test="empty($transforms)">
      <xsl:sequence select="$document"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:iterate select="$transforms">
        <xsl:param name="document" as="document-node()" select="$document"/>
        <xsl:param name="extra-parameters" as="map(*)?" select="$extra-parameters"/>
        <xsl:on-completion select="$document"/>
        <xsl:next-iteration>
          <xsl:with-param name="document">
            <xsl:variable name="functions" as="xs:boolean*">
              <xsl:for-each select=".?functions">
                <xsl:sequence select="function-available(.)"/>
              </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="process" as="xs:boolean">
              <xsl:choose>
                <xsl:when test="exists($functions) and false() = $functions">
                  <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:when test="exists(.?test)">
                  <xsl:evaluate xpath=".?test" as="xs:boolean"
                                with-params="$vp:dynamic-parameters"
                                context-item="$document"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="true()"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:choose>
              <xsl:when test="exists($functions) and false() = $functions">
                <xsl:message use-when="'pipeline' = $v:debug"
                             select="'Unavailable: ' || .?stylesheet-location"/>
                <xsl:sequence select="$document"/>
              </xsl:when>
              <xsl:when test="not($process)">
                <xsl:message use-when="'pipeline' = $v:debug"
                             select="'Unnecessary: ' || .?stylesheet-location"/>
                <xsl:sequence select="$document"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message use-when="'pipeline' = $v:debug"
                             select="'Processing : ' || .?stylesheet-location"/>

                <xsl:sequence select="transform(map {
                                        'stylesheet-location': .?stylesheet-location,
                                        'source-node': $document,
                                        'static-params': $vp:static-parameters,
                                        'stylesheet-params': map:merge(($vp:dynamic-parameters,
                                                                        $extra-parameters,
                                                                        .?extra-params))
                                      })?output"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="extra-parameters" select="()"/>
        </xsl:next-iteration>
      </xsl:iterate>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>
