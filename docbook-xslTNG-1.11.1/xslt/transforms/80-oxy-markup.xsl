<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://docbook.org/ns/docbook"
                default-mode="m:oxy-markup"
                exclude-result-prefixes="db m xlink xs"
                version="3.0">

  <xsl:variable name="debug" as="xs:boolean" select="false()" static="true"/>

  <xsl:template match="/">
    <xsl:document>
      <xsl:apply-templates/>
    </xsl:document>
  </xsl:template>

  <!-- See https://www.oxygenxml.com/doc/versions/22.0/ug-editor/topics/track-changes-format.html -->

  <xsl:mode name="m:oxy-markup" on-no-match="shallow-copy"/>

  <xsl:template match="*[processing-instruction()[name() = ('oxy_comment_start', 'oxy_insert_start')]]">
    <xsl:param name="role" as="xs:string?"/>
    <xsl:param name="annotations" as="xs:string?"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="$role">
        <xsl:attribute name="role" select="$role, @role" separator=" "/>
        <xsl:attribute name="annotations" select="$annotations, @annotations" separator=" "/>
      </xsl:if>
      <xsl:call-template name="group-oxy">
        <xsl:with-param name="nodes" as="node()+" select="node()"/>
      </xsl:call-template>    
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="group-oxy">
    <xsl:param name="nodes" as="node()+"/>
    <xsl:param name="level" select="1" as="xs:integer"/>
    <!-- We assume start/end PIs that belong together to be siblings -->
    <xsl:variable name="innermost" as="processing-instruction()*" 
      select="$nodes/self::processing-instruction(oxy_comment_start)[following-sibling::processing-instruction()
                                                                        [not(name() = ('oxy_delete', 'oxy_attributes'))][1]
                                                                      /self::processing-instruction(oxy_comment_end)]
              union
              $nodes/self::processing-instruction(oxy_insert_start)[following-sibling::processing-instruction()
                                                                        [not(name() = ('oxy_delete', 'oxy_attributes'))][1]
                                                                     /self::processing-instruction(oxy_insert_end)]"/>
    <xsl:choose>
      <xsl:when test="exists($innermost)">
        <xsl:variable name="grouped" as="document-node()">
          <xsl:document>
          <xsl:for-each-group select="$nodes" group-starting-with="node()[exists(. intersect $innermost)]">
            <xsl:choose>
              <xsl:when test="exists(
                                  $nodes/self::processing-instruction()
                                          [. >> current()/self::processing-instruction(oxy_comment_start)]
                                          [not(name() = ('oxy_delete', 'oxy_attributes'))]
                                          [1]
                                            /self::processing-instruction(oxy_comment_end)
                                  union
                                  $nodes/self::processing-instruction()
                                          [. >> current()/self::processing-instruction(oxy_insert_start)]
                                          [not(name() = ('oxy_delete', 'oxy_attributes'))]
                                          [1]
                                            /self::processing-instruction(oxy_insert_end)
                              )">
                <xsl:variable name="end" as="processing-instruction()" 
                  select="following-sibling::processing-instruction()[not(name() = ('oxy_delete', 'oxy_attributes'))][1]"/>
                <xsl:choose>
                  <xsl:when test="self::processing-instruction(oxy_insert_start)">
                    <xsl:variable name="insert-content" as="node()*">
                      <xsl:sequence select="current-group()[position() gt 1][. &lt;&lt; $end]"/>
                    </xsl:variable>
                    <xsl:apply-templates select="$insert-content">
                      <xsl:with-param name="role" select="'oxy_insert'"/>
                      <xsl:with-param name="annotations" select="replace(., '&quot;', '''')"/>
                    </xsl:apply-templates>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:variable name="tmp" as="item()+">
                      <xsl:analyze-string select="." regex="\s*comment=&quot;([^&quot;]*)&quot;">
                        <xsl:matching-substring>
                          <para>
                            <xsl:sequence select="regex-group(1)"/>
                          </para>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                          <xsl:attribute name="annotations" select="replace(., '&quot;', '''')"/>
                        </xsl:non-matching-substring>
                      </xsl:analyze-string>  
                    </xsl:variable>
                    <annotation role="oxy_comment">
                      <xsl:sequence select="$tmp/self::attribute(), $tmp/self::*"/>
                    </annotation>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="current-group()[. >> $end]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="current-group()"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each-group>
          </xsl:document>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="exists($grouped/processing-instruction()[name() = ('oxy_comment_start', 'oxy_insert_start')])">
            <xsl:call-template name="group-oxy">
              <xsl:with-param name="nodes" select="$grouped/node()"/>
              <xsl:with-param name="level" select="$level + 1"></xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$grouped/node()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$nodes"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:param name="role" as="xs:string?"/>
    <xsl:param name="annotations" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$role">
        <phrase role="{$role}" annotations="{$annotations}">
          <xsl:sequence select="."/>
        </phrase>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="db:tgroup/text()">
    <!-- This can only be all-whitespace text, but a user (or oXygen) managed to add insertion PIs.
         There may be more contexts where phrase generation isn’t wanted. -->
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:param name="role" as="xs:string?"/>
    <xsl:param name="annotations" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$role">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:attribute name="role" select="$role, @role" separator=" "/>
          <xsl:attribute name="annotations" select="$annotations, @annotations" separator=" "/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="processing-instruction(oxy_delete)">
    <phrase role="oxy_delete">
      <xsl:variable name="tmp" as="item()+">
        <xsl:analyze-string select="." regex="\s*content=&quot;([^&quot;]*)&quot;">
          <xsl:matching-substring>
            <xsl:value-of select="regex-group(1)"/>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:attribute name="annotations" select="replace(., '&quot;', '''')"/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>  
      </xsl:variable>
      <xsl:sequence select="$tmp/self::attribute(), $tmp/self::text()"/>
    </phrase>
  </xsl:template>
  
  <!-- We’re not dealing with oxy_attributes yet -->
  
  
</xsl:stylesheet>
