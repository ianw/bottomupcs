<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f m map v vp xs"
                version="3.0">

<xsl:variable name="v:unit-scale" as="map(*)">
  <xsl:map>
    <xsl:map-entry key="'px'" select="1.0"/>
    <xsl:map-entry key="'in'" select="$pixels-per-inch"/>
    <xsl:map-entry key="'m'" select="$pixels-per-inch div 2.54 * 100.0"/>
    <xsl:map-entry key="'cm'" select="$pixels-per-inch div 2.54"/>
    <xsl:map-entry key="'mm'" select="$pixels-per-inch div 25.4"/>
    <xsl:map-entry key="'pt'" select="$pixels-per-inch div 72.0"/>
    <xsl:map-entry key="'pc'" select="$pixels-per-inch div 6.0"/>
    <xsl:map-entry key="'em'" select="$pixels-per-inch div 6.0"/>
    <xsl:map-entry key="'barleycorn'" select="$pixels-per-inch div 3.0"/>
  </xsl:map>
</xsl:variable>

<xsl:variable name="vp:length-regex" select="'^(\d+(\.\d+)?)\s*(\S+)?$'"/>
<xsl:variable name="vp:percent-regex" select="'^(\d+(\.\d+)?)\s*%$'"/>
<xsl:variable name="vp:relative-regex" select="'^(\d+(\.\d+)?)\s*\*(\s*\+\s*(.*))?$'"/>

<xsl:function name="f:parse-length" as="map(*)">
  <xsl:param name="length" as="xs:string?"/>

  <xsl:choose>
    <xsl:when test="empty($length)">
      <xsl:sequence select="f:empty-length()"/>
    </xsl:when>
    <xsl:otherwise>
      <!--
      <xsl:variable name="x" select="'3*+0.25pt'"/>
      <xsl:message select="'matches: ' || $x, matches($x, $vp:relative-regex)"/>
      <xsl:message select="'matches: ', $vp:relative-regex"/>
      <xsl:message select="'matches: ' || $x,
                           matches($x, '^(\d+(\.\d+)?)\s*\*\s*(\+\s*(.*)$)')"/>
      -->

      <xsl:variable name="length" select="normalize-space($length)"/>

      <xsl:variable name="parsed"
                    select="if (matches($length, $vp:relative-regex))
                            then map { 'relative':
                                        xs:decimal(replace($length, $vp:relative-regex, '$1'))
                                     }
                            else map { 'relative': 0.0 }"/>

      <xsl:variable name="length"
                    select="if (matches($length, $vp:relative-regex))
                            then replace($length, $vp:relative-regex, '$4')
                            else $length"/>

      <xsl:choose>
        <xsl:when test="$parsed?relative and $length = ''">
          <xsl:sequence select="map:put($parsed, 'magnitude', 0)
                                => map:put('unit', 'px')"/>
        </xsl:when>
        <xsl:when test="matches($length, $vp:length-regex)">
          <xsl:variable name="mag"
                        select="xs:double(replace($length, $vp:length-regex, '$1'))"/>
          <xsl:variable name="unit"
                        select="replace($length, $vp:length-regex, '$3')"/>
          <xsl:variable name="unit"
                        select="if ($unit = '')
                                then 'px'
                                else $unit"/>

          <xsl:choose>
            <xsl:when test="map:contains($v:unit-scale, $unit) or $unit = '%'">
              <xsl:sequence select="map:put($parsed, 'magnitude', $mag)
                                    => map:put('unit', $unit)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message expand-text="yes"
                           >Unrecognized unit {$unit}, using default length</xsl:message>
              <xsl:sequence select="map:put($parsed, 'magnitude', $default-length-magnitude)
                                    => map:put('unit', $default-length-unit)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message expand-text="yes"
                       >Unparsable length {$length}, using default length</xsl:message>
          <xsl:sequence select="map:put($parsed, 'magnitude', $default-length-magnitude)
                                => map:put('unit', $default-length-unit)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:length-units" as="xs:string?">
  <xsl:param name="length" as="xs:string?"/>
  <xsl:sequence select="if (exists($length))
                        then f:parse-length($length)?unit
                        else ()"/>
</xsl:function>

<xsl:function name="f:absolute-length" as="xs:double">
  <xsl:param name="length" as="map(*)"/>
  <xsl:choose>
    <xsl:when test="exists($length?magnitude) and exists($length?unit)
                    and map:contains($v:unit-scale, $length?unit)">
      <xsl:sequence select="round($length?magnitude * map:get($v:unit-scale, $length?unit))"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- this should never happen, but ... -->
      <xsl:message>
        <xsl:text>Invalid length (</xsl:text>
        <xsl:value-of select="concat($length?magnitude, $length?unit)"/>
        <xsl:text>), returning 0 for absolute-length</xsl:text>
      </xsl:message>
      <xsl:sequence select="0"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:relative-length" as="xs:double">
  <xsl:param name="length" as="map(*)"/>
  <xsl:sequence select="if ($length?relative)
                        then $length?relative
                        else 0.0"/>
</xsl:function>

<xsl:function name="f:empty-length" as="map(*)">
  <xsl:sequence select="map { }"/>
</xsl:function>

<xsl:function name="f:is-empty-length" as="xs:boolean">
  <xsl:param name="length" as="map(*)?"/>
  <xsl:sequence select="empty($length)
                        or (not($length?relative) and not($length?magnitude))"/>
</xsl:function>

<xsl:function name="f:equal-lengths" as="xs:boolean">
  <xsl:param name="a" as="map(*)?"/>
  <xsl:param name="b" as="map(*)?"/>
  <xsl:choose>
    <xsl:when test="f:is-empty-length($a) and f:is-empty-length($b)">
      <xsl:sequence select="true()"/>
    </xsl:when>
    <xsl:when test="f:is-empty-length($a) and not(f:is-empty-length($b))
                    or f:is-empty-length($b) and not(f:is-empty-length($a))">
      <xsl:sequence select="false()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$a?relative eq $b?relative
                            and $a?magnitude eq $b?magnitude
                            and $a?unit eq $b?unit"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:make-length" as="map(*)">
  <xsl:param name="relative" as="xs:double"/>
  <xsl:sequence select="map {
    'relative': $relative
    }"/>
</xsl:function>

<xsl:function name="f:make-length" as="map(*)">
  <xsl:param name="magnitude" as="xs:double"/>
  <xsl:param name="unit" as="xs:string"/>
  <xsl:sequence select="f:make-length(0.0, $magnitude, $unit)"/>
</xsl:function>

<xsl:function name="f:make-length" as="map(*)">
  <xsl:param name="relative" as="xs:double"/>
  <xsl:param name="magnitude" as="xs:double"/>
  <xsl:param name="unit" as="xs:string"/>
  <xsl:sequence select="map {
    'relative': 0.0,
    'magnitude': $magnitude,
    'unit': $unit
    }"/>
</xsl:function>

<xsl:function name="f:length-string" as="xs:string?">
  <xsl:param name="length" as="map(*)?"/>
  <xsl:if test="exists($length)">
    <xsl:variable name="rel"
                  select="if ($length?relative and $length?relative != 0.0)
                          then concat($length?relative, '*')
                          else ''"/>
    <xsl:sequence select="$rel || $length?magnitude || $length?unit"/>
  </xsl:if>
</xsl:function>

</xsl:stylesheet>
