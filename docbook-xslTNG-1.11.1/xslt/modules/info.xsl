<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db dbe f fp m t v vp xs"
                version="3.0">

<xsl:template match="db:info">
  <xsl:apply-templates select="db:indexterm"/>
</xsl:template>

<xsl:template match="db:copyright">
  <xsl:variable name="gi" select="if (parent::db:info)
                                  then 'div'
                                  else 'span'"/>
  <xsl:element name="{$gi}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:text>Copyright © </xsl:text>
    <xsl:apply-templates select="db:year[1]" mode="m:copyright-years"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="db:holder"/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:year" mode="m:copyright-years">
  <xsl:param name="prevyear" select="()"/>
  <xsl:param name="range" select="()"/>

  <xsl:choose>
    <xsl:when test="not($copyright-collapse-years)">
      <span>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates/>
      </span>
      <xsl:if test="following-sibling::db:year">
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="(following-sibling::db:year)[1]"/>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fp:collapse-years((., following-sibling::db:year))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:function name="fp:collapse-years">
  <xsl:param name="years" as="element(db:year)*"/>

  <span class="copyright-years">
    <xsl:choose>
      <xsl:when test="count($years) = 1">
        <xsl:apply-templates select="$years"/>
      </xsl:when>
      <xsl:when test="count($years) = 2">
        <xsl:choose>
          <xsl:when test="$years[1] castable as xs:integer
                          and $years[2] castable as xs:integer
                          and xs:integer($years[2]) = xs:integer($years[1]) + 1">
            <xsl:apply-templates select="$years[1]"/>
            <xsl:sequence select="$copyright-year-range-separator"/>
            <xsl:apply-templates select="$years[2]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$years[1]"/>
            <xsl:sequence select="$copyright-year-separator"/>
            <xsl:apply-templates select="$years[2]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="fp:collapse-years($years, true(), (), ())"/>
      </xsl:otherwise>
    </xsl:choose>
  </span>
</xsl:function>

<xsl:function name="fp:collapse-years">
  <xsl:param name="years" as="element(db:year)*"/>
  <xsl:param name="first" as="xs:boolean"/>
  <xsl:param name="prevyear" as="element(db:year)?"/>
  <xsl:param name="constructed" as="item()*"/>

  <!--
  <xsl:message select="'[', $prevyear/string(), ']:', $years ! string(.)"/>
  <xsl:message select="'X:', $first, $constructed"/>
  -->

  <xsl:choose>
    <xsl:when test="empty($prevyear)">
      <xsl:sequence
          select="fp:collapse-years(subsequence($years, 2), $first, $years[1], ())"/>
    </xsl:when>
    <xsl:when test="empty($years)">
      <xsl:choose>
        <xsl:when test="empty($constructed)">
          <xsl:if test="not($first)">
            <xsl:sequence select="$copyright-year-separator"/>
          </xsl:if>
          <xsl:apply-templates select="$prevyear"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="not($first)">
            <xsl:sequence select="$copyright-year-separator"/>
          </xsl:if>
          <xsl:sequence select="$constructed"/>
          <xsl:sequence select="$copyright-year-range-separator"/>
          <xsl:apply-templates select="$prevyear"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$prevyear castable as xs:integer
                    and $years[1] castable as xs:integer
                    and xs:integer($years[1]) = xs:integer($prevyear) + 1">
      <xsl:choose>
        <xsl:when test="empty($constructed)">
          <xsl:variable name="firstitem" as="item()*">
            <xsl:apply-templates select="$prevyear"/>
          </xsl:variable>
          <xsl:sequence
              select="fp:collapse-years(subsequence($years, 2),
                         $first, $years[1], $firstitem)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence
              select="fp:collapse-years(subsequence($years, 2),
                         $first, $years[1], $constructed)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="empty($constructed)">
          <xsl:if test="not($first)">
            <xsl:sequence select="$copyright-year-separator"/>
          </xsl:if>
          <xsl:apply-templates select="$prevyear"/>
          <xsl:sequence
              select="fp:collapse-years(subsequence($years, 2), false(), $years[1], ())"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="not($first)">
            <xsl:sequence select="$copyright-year-separator"/>
          </xsl:if>
          <xsl:sequence select="$constructed"/>
          <xsl:sequence select="$copyright-year-range-separator"/>
          <xsl:apply-templates select="$prevyear"/>
          <xsl:sequence
              select="fp:collapse-years(subsequence($years, 2), false(), $years[1], ())"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:template match="db:holder|db:year">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="db:abstract|db:legalnotice
                     |db:authorgroup[parent::db:info]">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:honorific|db:firstname|db:othername
                     |db:surname|db:givenname|db:lineage">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="db:personname">
  <xsl:variable name="node" select="."/>

  <xsl:variable name="style" as="xs:string?">
    <xsl:for-each select="$v:personal-name-styles">
      <xsl:if test="contains-token($node/@role, .)">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="style" as="xs:string?">
    <xsl:choose>
      <xsl:when test="empty($style)
                      and (parent::db:author
                           or parent::db:editor
                           or parent::db:othercredit)
                      and parent::*/@role">
        <xsl:for-each select="$v:personal-name-styles">
          <xsl:if test="contains-token($node/parent::*/@role, .)">
            <xsl:sequence select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$style"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="style" as="xs:string?"
                select="if (empty($style))
                        then if (f:check-gentext(., 'style', 'personname'))
                             then  f:gentext(., 'style', 'personname')
                             else  $default-personal-name-style
                        else $style"/>

  <span>
    <xsl:apply-templates select="." mode="m:attributes">
      <xsl:with-param name="style" select="$style"/>
    </xsl:apply-templates>
    <xsl:call-template name="t:person-name">
      <xsl:with-param name="style" select="$style"/>
    </xsl:call-template>
  </span>
</xsl:template>

<xsl:template name="t:person-name">
  <xsl:param name="style" as="xs:string" required="yes"/>

  <xsl:variable name="node" select="."/>

  <xsl:choose>
    <xsl:when test="not(*)">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:when>
    <xsl:when test="$style = 'FAMILY-given'">
      <xsl:call-template name="t:person-name-family-given"/>
    </xsl:when>
    <xsl:when test="$style = 'last-first'">
      <xsl:call-template name="t:person-name-last-first"/>
    </xsl:when>
    <xsl:when test="$style = 'first-last'">
      <xsl:call-template name="t:person-name-first-last"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="error($dbe:INVALID-NAME-STYLE,
        'Invalid name style: ' || $style)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="t:person-name-family-given">
  <!-- The family-given style applies a convention for identifying given -->
  <!-- and family names in locales where it may be ambiguous -->
  <xsl:variable name="surname">
    <xsl:apply-templates select="db:surname[1]"/>
  </xsl:variable>

  <xsl:apply-templates select="$surname/node()" mode="m:to-uppercase"/>

  <xsl:if test="db:surname and (db:firstname or db:givenname)">
    <xsl:text> </xsl:text>
  </xsl:if>

  <xsl:apply-templates select="(db:firstname|db:givenname)[1]"/>

  <xsl:text> [FAMILY Given]</xsl:text>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="/" mode="m:to-uppercase">
  <xsl:apply-templates mode="m:to-uppercase"/>
</xsl:template>

<xsl:template match="*" mode="m:to-uppercase">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="m:to-uppercase"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="processing-instruction()|comment()" mode="m:to-uppercase">
  <xsl:copy/>
</xsl:template>

<xsl:template match="text()" mode="m:to-uppercase">
  <xsl:value-of select="upper-case(.)"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="t:person-name-last-first">
  <xsl:apply-templates select="db:surname[1]"/>

  <xsl:if test="db:surname and (db:firstname or db:givenname)">
    <xsl:text>, </xsl:text>
  </xsl:if>

  <xsl:apply-templates select="(db:firstname|db:givenname)[1]"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="t:person-name-first-last">
  <xsl:if test="db:honorific">
    <xsl:apply-templates select="db:honorific[1]"/>
  </xsl:if>

  <xsl:if test="db:firstname or db:givenname">
    <xsl:if test="db:honorific">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="(db:firstname|db:givenname)[1]"/>
  </xsl:if>

  <xsl:if test="db:othername and f:is-true($othername-in-middle)">
    <xsl:if test="db:honorific or db:firstname or db:givenname">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="db:othername[1]"/>
  </xsl:if>

  <xsl:if test="db:surname">
    <xsl:if test="db:honorific or db:firstname or db:givenname
                  or (db:othername and f:is-true($othername-in-middle))">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="db:surname[1]"/>
  </xsl:if>

  <xsl:if test="db:lineage">
    <xsl:text>, </xsl:text>
    <xsl:apply-templates select="db:lineage[1]"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:city|db:country|db:email|db:fax|db:phone
                     |db:pob|db:postcode|db:state|db:street|db:otheraddr">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="t:person-name-list">
  <!-- Return a formatted string representation of the contents of
       the current element. The current element must contain one or
       more AUTHORs, CORPAUTHORs, OTHERCREDITs, and/or EDITORs.

       John Doe
     or
       John Doe and Jane Doe
     or
       John Doe, Jane Doe, and A. Nonymous
  -->
  <xsl:param name="person.list"
             select="db:author|db:corpauthor|db:othercredit|db:editor"/>
  <xsl:param name="person.count" select="count($person.list)"/>
  <xsl:param name="count" select="1"/>

  <xsl:choose>
    <xsl:when test="$count &gt; $person.count"></xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$person.list[position()=$count]"/>

      <xsl:choose>
        <xsl:when test="$person.count = 2 and $count = 1">
          <xsl:sequence select="f:gentext(., 'separator', 'author-sep2')"/>
        </xsl:when>
        <xsl:when test="$person.count &gt; 2 and $count+1 = $person.count">
          <xsl:sequence select="f:gentext(., 'separator', 'author-seplast')"/>
        </xsl:when>
        <xsl:when test="$count &lt; $person.count">
          <xsl:sequence select="f:gentext(., 'separator', 'author-sep')"/>
        </xsl:when>
      </xsl:choose>

      <xsl:call-template name="t:person-name-list">
        <xsl:with-param name="person.list" select="$person.list"/>
        <xsl:with-param name="person.count" select="$person.count"/>
        <xsl:with-param name="count" select="$count+1"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:publishername
                     |db:seriesvolnums|db:volumenum|db:issuenum
                     |db:artpagenums|db:authorinitials|db:edition|db:pagenums
                     |db:contractnum|db:contractsponsor">
  <xsl:call-template name="t:inline"/>
</xsl:template>

<xsl:template match="db:pubdate">
  <xsl:variable name="format" select="f:pi(., 'format')"/>

  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'time'"/>
    <xsl:with-param name="content">
      <xsl:apply-templates/>
    </xsl:with-param>
    <xsl:with-param name="extra-attributes" as="attribute()*">
      <xsl:choose>
        <xsl:when test="*"/>
        <xsl:when test="string(.) castable as xs:dateTime">
          <xsl:attribute name="datetime" select="."/>
        </xsl:when>
        <xsl:when test="string(.) castable as xs:date">
          <xsl:attribute name="datetime" select="."/>
        </xsl:when>
        <xsl:when test="string(.) castable as xs:integer">
          <xsl:attribute name="datetime" select="."/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:info/db:pubdate">
  <xsl:variable name="format" select="f:pi(., 'format')"/>

  <xsl:call-template name="t:inline">
    <xsl:with-param name="namemap" select="'time'"/>
    <xsl:with-param name="content">
      <xsl:choose>
        <xsl:when test="*">
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:when test="string(.) castable as xs:dateTime">
          <xsl:variable name="date" select="xs:dateTime(string(.))"/>
          <xsl:choose>
            <xsl:when test="$format">
              <xsl:sequence select="format-dateTime($date, $format)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="format-dateTime($date, $date-dateTime-format)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="string(.) castable as xs:date">
          <xsl:variable name="date" select="xs:date(string(.))"/>
          <xsl:choose>
            <xsl:when test="$format">
              <xsl:sequence select="format-date($date, $format)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="format-date($date, $date-date-format)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="extra-attributes" as="attribute()*">
      <xsl:choose>
        <xsl:when test="*"/>
        <xsl:when test="string(.) castable as xs:dateTime">
          <xsl:attribute name="datetime" select="."/>
        </xsl:when>
        <xsl:when test="string(.) castable as xs:date">
          <xsl:attribute name="datetime" select="."/>
        </xsl:when>
        <xsl:when test="string(.) castable as xs:integer">
          <xsl:attribute name="datetime" select="."/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>
</xsl:stylesheet>
