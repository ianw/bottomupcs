<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:trans="http://docbook.org/ns/transclusion"
	        xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="db f fp map mp tp trans xlink xs"
                version="3.0">

<xsl:import href="../environment.xsl"/>

<!-- Separator for auto generated prefixes in transclusion -->
<xsl:param name="psep" select="$transclusion-prefix-separator"/>
<xsl:param name="idfixup" select="$transclusion-id-fixup"/>
<xsl:param name="linkscope" select="$transclusion-link-scope"/>
<xsl:param name="suffix" select="$transclusion-suffix"/>

<xsl:variable name="idref-list"
              select="(xs:QName('linkend'), xs:QName('linkends'), xs:QName('otherterm'),
                       xs:QName('zone'), xs:QName('startref'), xs:QName('arearefs'),
                       xs:QName('targetptr'), xs:QName('endterm'))"/>

<xsl:key name="id" match="*" use="@xml:id"/>

<xsl:template match="/" as="document-node()">
  <xsl:if test="not($idfixup = 'suffix') and $suffix != ''">
    <xsl:message>Invalid idfixup/suffix combination; ignoring initial suffix.</xsl:message>
  </xsl:if>
  <xsl:document>
    <xsl:apply-templates mode="mp:transclude"/>
  </xsl:document>
</xsl:template>

<xsl:template match="node()" mode="mp:transclude">
  <xsl:if test="@trans:idfixup = 'suffix' and not(@trans:suffix)">
    <xsl:message>Invalid idfixup/suffix combination; suffix is undefined.</xsl:message>
  </xsl:if>
  <xsl:if test="@trans:suffix and not(@trans:idfixup = 'suffix')">
    <xsl:message>Invalid idfixup/suffix combination; suffix will be ignored.</xsl:message>
  </xsl:if>

  <xsl:if test="@trans:idfixup and not(@trans:idfixup = ('none', 'auto', 'suffix'))">
    <xsl:message select="'Unsupported @trans:idfixup value ' || @trans:idfixup
                         || '; results are undefined.'"/>
  </xsl:if>

  <xsl:copy>
    <xsl:apply-templates select="@*,node()" mode="mp:transclude"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@*" priority="10" mode="mp:transclude">
  <xsl:copy/>
</xsl:template>

<xsl:template match="@xml:id" priority="100" mode="mp:transclude">
  <xsl:sequence select="fp:new-xml-id(parent::*)"/>
</xsl:template>

<xsl:template match="@trans:*" priority="100" mode="mp:transclude">
  <!-- remove -->
</xsl:template>

<xsl:template match="@*[node-name(.) = $idref-list]" priority="20" mode="mp:transclude">
  <xsl:variable name="fixedup-values" as="xs:string*">
    <xsl:call-template name="tp:fixup-ids">
      <xsl:with-param name="idlist" select="."/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:attribute name="{node-name(.)}" select="string-join($fixedup-values, ' ')"/>
</xsl:template>

<xsl:template match="@xlink:href[starts-with(., '#')]" priority="20" mode="mp:transclude">
  <xsl:variable name="fixedup-values" as="xs:string*">
    <xsl:call-template name="tp:fixup-ids">
      <xsl:with-param name="idlist" select="substring(., 2)"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:attribute name="{node-name(.)}" select="'#' || string-join($fixedup-values, ' ')"/>
</xsl:template>

<xsl:template name="tp:fixup-ids" as="xs:string*">
  <xsl:param name="idlist" as="xs:string" required="yes"/>

  <xsl:variable name="this" select="parent::*"/>

  <xsl:variable name="linkscope" select="fp:linkscope($this)"/>

  <xsl:for-each select="tokenize($idlist, '\s+')">
    <xsl:variable name="id" select="."/>
    <xsl:choose>
      <xsl:when test="$linkscope = 'user'">
        <xsl:sequence select="$id"/>
      </xsl:when>
      <xsl:when test="$linkscope = 'local'">
        <xsl:sequence select="$id || fp:suffix($this)"/>
      </xsl:when>
      <xsl:when test="$linkscope = 'near'">
        <xsl:variable name="nearest" select="fp:nearest-element-with-id($this, $id)"/>
        <xsl:choose>
          <xsl:when test="exists($nearest)">
            <xsl:sequence select="fp:new-id($nearest)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message select="'No element with id ' || $id"/>
            <xsl:sequence select="$id"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise> <!-- global -->
        <xsl:variable name="first" select="key('id', $id, root($this))[1]"/>
        <xsl:choose>
          <xsl:when test="exists($first)">
            <xsl:sequence select="fp:new-id($first)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message select="'No element with id ' || $id"/>
            <xsl:sequence select="$id"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:function name="fp:idfixup" as="xs:string">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence
      select="($node/ancestor-or-self::*[@trans:idfixup][1]/@trans:idfixup, $idfixup)[1]"/>
</xsl:function>

<xsl:function name="fp:linkscope" as="xs:string">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence
      select="($node/ancestor-or-self::*[@trans:linkscope][1]/@trans:linkscope, $linkscope)[1]"/>
</xsl:function>

<xsl:function name="fp:suffix" as="xs:string">
  <xsl:param name="node" as="element()"/>

  <xsl:variable name="relevant-ancestors"
                select="$node/ancestor-or-self::*[@trans:suffix or @trans:idfixup]"/>
  <xsl:iterate select="$relevant-ancestors">
    <xsl:param name="suffix" select="''"/>
    <xsl:on-completion select="$suffix"/>
    <xsl:choose>
      <xsl:when test="@trans:idfixup = 'none'">
        <xsl:next-iteration>
          <xsl:with-param name="suffix" select="''"/>
        </xsl:next-iteration>
      </xsl:when>
      <xsl:when test="@trans:suffix">
        <xsl:next-iteration>
          <xsl:with-param name="suffix" select="$suffix || @trans:suffix"/>
        </xsl:next-iteration>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-iteration>
          <xsl:with-param name="suffix" select="$suffix"/>
        </xsl:next-iteration>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:iterate>
</xsl:function>

<xsl:function name="fp:new-xml-id" as="attribute()?">
  <xsl:param name="node" as="element()"/>

  <xsl:if test="$node/@xml:id">
    <xsl:variable name="idfixup" select="fp:idfixup($node)"/>
    <xsl:choose>
      <xsl:when test="$idfixup = 'suffix'">
        <xsl:attribute name="xml:id" select="$node/@xml:id || fp:suffix($node)"/>
      </xsl:when>
      <xsl:when test="$idfixup = 'auto'">
        <xsl:attribute name="xml:id" select="$node/@xml:id || $psep || f:unique-id($node)"/>
      </xsl:when>
      <xsl:otherwise> <!-- none -->
        <xsl:sequence select="$node/@xml:id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:function>

<xsl:function name="fp:new-id" as="xs:string?">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="string(fp:new-xml-id($node))"/>
</xsl:function>

<xsl:function name="fp:nearest-element-with-id" as="node()?">
  <xsl:param name="context" as="node()"/>
  <xsl:param name="id" as="xs:string"/>

  <xsl:choose>
    <xsl:when test="empty($context)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:when test="exists($context//*[@xml:id=$id])">
      <xsl:sequence select="($context//*[@xml:id=$id])[1]"/>
    </xsl:when>
    <xsl:when test="empty($context/parent::*)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fp:nearest-element-with-id($context/parent::*, $id)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>
