<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f m t v xs"
                version="3.0">

<xsl:template name="t:inline">
  <xsl:param name="namemap" select="'span'"/>
  <xsl:param name="class" as="xs:string*"/>
  <xsl:param name="local-name-as-class" as="xs:boolean" select="true()"/>
  <xsl:param name="extra-attributes" as="attribute()*" select="()"/>
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>

  <xsl:variable name="map"
                select="if ($namemap instance of map(xs:string, xs:string))
                        then $namemap
                        else map { '*': $namemap }"/>

  <xsl:variable name="roles" select="tokenize(normalize-space(@role))"/>

  <xsl:variable name="mapped-names" as="xs:string*">
    <xsl:for-each select="$roles">
      <xsl:if test="exists($map(.))">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="mapped-names" as="xs:string+"
                select="if (empty($mapped-names))
                        then '*'
                        else $mapped-names"/>

  <xsl:variable name="classes" as="xs:string*">
    <xsl:for-each select="$roles">
      <xsl:sequence select="."/>
    </xsl:for-each>
    <xsl:sequence select="$class"/>
    <xsl:if test="$local-name-as-class">
      <xsl:sequence select="local-name(.)"/>
    </xsl:if>
  </xsl:variable>

  <!-- sort them and make them unique -->
  <xsl:variable name="classes" as="xs:string*">
    <xsl:for-each select="distinct-values($classes)">
      <xsl:sort select="."/>
      <xsl:sequence select="."/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="attrs" as="attribute()*">
    <xsl:apply-templates select="@*"/>
  </xsl:variable>

  <xsl:element namespace="http://www.w3.org/1999/xhtml"
               name="{$map($mapped-names[1])}">
    <xsl:sequence select="f:attributes(., $attrs,
                                       if ($local-name-as-class)
                                       then (local-name(.), $classes)
                                       else $classes, ())"/>
    <xsl:sequence select="$extra-attributes"/>
    <xsl:apply-templates select="." mode="m:link">
      <xsl:with-param name="primary-markup" select="false()"/>
      <xsl:with-param name="content" select="$content"/>
    </xsl:apply-templates>
  </xsl:element>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:abbrev">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:accel">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:acronym">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:application">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:author">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="db:personname|db:orgname"/>
  </span>
</xsl:template>

<xsl:template match="db:buildtarget">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:citation">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:citebiblioid">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="class" select="@class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:citerefentry">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:citetitle">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'i'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:classname">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:code">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
    <xsl:with-param name="local-name-as-class" select="false()"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:command">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:computeroutput">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:constant">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
    <xsl:with-param name="class" select="@class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:database">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="class" select="@class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:date">
  <xsl:variable name="format" select="f:date-format(.)"/>
  <xsl:choose>
    <xsl:when test="$format = 'apply-templates'">
      <xsl:call-template name="t:inline"/>
    </xsl:when>
    <xsl:when test="string(.) castable as xs:dateTime">
      <xsl:call-template name="t:inline">
        <xsl:with-param name="content" as="xs:string">
          <!-- Don't attempt to use localization on Saxon HE -->
          <xsl:sequence
              use-when="system-property('xsl:product-name') = 'SAXON'
                        and not(
                           starts-with(system-property('xsl:product-version'), 'EE')
                           )"
              select="format-dateTime(xs:dateTime(.), $format)"/>

          <xsl:sequence
              use-when="not(system-property('xsl:product-name') = 'SAXON'
                            and not(
                              starts-with(system-property('xsl:product-version'), 'EE')
                              ))"
              select="format-dateTime(xs:dateTime(.), $format,
                                      f:language(.), (), ())"/>
        </xsl:with-param>
        <xsl:with-param name="extra-attributes" as="attribute()*">
          <xsl:attribute name="time" select="."/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="string(.) castable as xs:date">
      <xsl:call-template name="t:inline">
        <xsl:with-param name="content" as="xs:string">
          <!-- Don't attempt to use localization on Saxon HE -->
          <xsl:sequence
              use-when="system-property('xsl:product-name') = 'SAXON'
                        and not(
                           starts-with(system-property('xsl:product-version'), 'EE')
                           )"
              select="format-date(xs:date(.), $format)"/>
          <xsl:sequence
              use-when="not(system-property('xsl:product-name') = 'SAXON'
                            and not(
                              starts-with(system-property('xsl:product-version'), 'EE')
                              ))"
              select="format-date(xs:date(.), $format,
                                  f:language(.), (), ())"/>
        </xsl:with-param>
        <xsl:with-param name="extra-attributes" as="attribute()*">
          <xsl:attribute name="time" select="."/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="t:inline"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:editor">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:email">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:emphasis">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap"
                    select="map { '*': 'em',
                                  'strong': 'strong',
                                  'bold': 'strong' }"/>
    <xsl:with-param name="local-name-as-class" select="false()"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:enumidentifier">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:enumname">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:enumvalue">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:envar">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:errorcode">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:errorname">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:errortext">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:errortype">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:exceptionname">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:filename">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
    <xsl:with-param name="class" select="@class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:firstterm">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:foreignphrase">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:function">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:guibutton">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:guiicon">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:guilabel">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:guimenu">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:guimenuitem">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:guisubmenu">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:hardware">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:initializer">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:inlineequation">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:interfacename">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:jobtitle">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:keycap">
  <xsl:variable name="lookup"
                select="if (@function = 'other')
                        then @otherfunction/string()
                        else @function/string()"/>
  <xsl:choose>
    <xsl:when test="exists(node())">
      <xsl:call-template name="t:inline"/>
    </xsl:when>
    <xsl:when test="exists(f:check-gentext(., 'keycap', $lookup))">
      <xsl:call-template name="t:inline">
        <xsl:with-param name="content" as="item()*">
          <xsl:sequence select="f:gentext(., 'keycap', $lookup)"/>
        </xsl:with-param>
        <xsl:with-param name="class" select="$lookup"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message select="'No keycap for', $lookup"/>
      <xsl:call-template name="t:inline">
        <xsl:with-param name="content" as="item()*">
          <xsl:sequence select="'NOKEYCAP'"/>
        </xsl:with-param>
        <xsl:with-param name="class" select="$lookup"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:keycode">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:keycombo">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:keysym">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:literal">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:macroname">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:markup">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:mathphrase">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:medialabel">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'em'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:menuchoice">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:methodname">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:modifier">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:mousebutton">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:namespace">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:namespacename">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:ooclass">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:ooexception">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:oointerface">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:option">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:optional">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:org">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:orgname">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="class" select="@class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:package">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:parameter">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
    <xsl:with-param name="class" select="@class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:person">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:phrase">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:productname">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="class" select="@class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:productnumber">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:prompt">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:property">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:quote">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'q'"/>
    <xsl:with-param name="local-name-as-class" select="false()"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:replaceable">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'em'"/>
    <xsl:with-param name="class" select="@class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:returnvalue">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:revnumber">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:shortcut">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:structfield">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:subscript">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'sub'"/>
    <xsl:with-param name="local-name-as-class" select="false()"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:superscript">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'sup'"/>
    <xsl:with-param name="local-name-as-class" select="false()"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:symbol">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="class" select="@class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:systemitem">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
    <xsl:with-param name="class" select="@class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:tag">
  <xsl:variable name="class"
                select="if (@class)
                        then @class/string()
                        else 'element'"/>

  <xsl:variable name="content" as="item()*">
    <xsl:choose>
      <xsl:when test="$class='attribute'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$class='attvalue'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$class='element'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="$class='endtag'">
        <xsl:text>&lt;/</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='genentity'">
        <xsl:text>&amp;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='numcharref'">
        <xsl:text>&amp;#</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='paramentity'">
        <xsl:text>%</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='pi'">
        <xsl:text>&lt;?</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='xmlpi'">
        <xsl:text>&lt;?</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>?&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='starttag'">
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='emptytag'">
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>/&gt;</xsl:text>
      </xsl:when>
      <xsl:when test="$class='sgmlcomment'">
        <xsl:text>&lt;!--</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>--&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
    <xsl:with-param name="local-name-as-class" select="false()"/>
    <xsl:with-param name="class" select="'tag tag-' || $class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:task">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:templateid">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:templatename">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:termdef">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:token">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:trademark">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="class" select="@class"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:type">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:typedefname">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:unionname">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:uri">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
    <xsl:with-param name="class" select="@type"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:userinput">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:varname">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'code'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:wordasword">
  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'em'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="comment()|processing-instruction()">
  <!-- drop these on the floor -->
</xsl:template>

<xsl:template match="processing-instruction('DocBook-xslTNG-version')" as="text()">
  <xsl:value-of select="$v:VERSION"/>
</xsl:template>

<xsl:template match="processing-instruction('system-property')" as="text()">
  <xsl:value-of select="system-property(normalize-space(.))"/>
</xsl:template>

<xsl:template match="processing-instruction('current-dateTime')" as="text()">
  <xsl:variable name="attr" select="f:pi-attributes(.)"/>
  <xsl:variable name="then" as="xs:dateTime">
    <xsl:choose>
      <xsl:when test="empty($attr/@dateTime)">
        <xsl:sequence select="current-dateTime()"/>
      </xsl:when>
      <xsl:when test="$attr/@dateTime castable as xs:dateTime">
        <xsl:sequence select="xs:dateTime($attr/@dateTime)"/>
      </xsl:when>
      <xsl:when test="$attr/@dateTime castable as xs:date">
        <xsl:sequence select="xs:dateTime(xs:date($attr/@dateTime) + xs:dayTimeDuration('PT12H'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="'Cannot parse', $attr/@dateTime/string(), 'as a date/time'"/>
        <xsl:sequence select="current-dateTime()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="offset" as="xs:duration">
    <xsl:choose>
      <xsl:when test="empty($attr/@offset)">
        <xsl:sequence select="xs:dayTimeDuration('PT0S')"/>
      </xsl:when>
      <xsl:when test="$attr/@offset castable as xs:dayTimeDuration">
        <xsl:sequence select="xs:dayTimeDuration($attr/@offset)"/>
      </xsl:when>
      <xsl:when test="$attr/@offset castable as xs:yearMonthDuration">
        <xsl:sequence select="xs:yearMonthDuration($attr/@offset)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="'Cannot parse', $attr/@offset/string(), 'as a duration'"/>
        <xsl:sequence select="xs:dayTimeDuration('PT0S')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="format"
                select="($attr/@format, $date-dateTime-format)[1]"/>
  <xsl:value-of select="format-dateTime($then + $offset, $format)"/>
</xsl:template>

<xsl:template match="processing-instruction('eval')" as="item()*">
  <xsl:evaluate xpath="string(.)"
                context-item="."
                namespace-context="."/>
</xsl:template>

</xsl:stylesheet>
