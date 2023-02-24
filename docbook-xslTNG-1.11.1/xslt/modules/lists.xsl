<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db dbe f fp m t tp vp xs"
                version="3.0">

<xsl:template match="db:itemizedlist">
  <xsl:variable name="compact" as="xs:boolean"
                select="@spacing = 'compact'
                        and count(db:listitem/db:para) = count(db:listitem)
                        and empty(db:listitem/*[not(self::db:para)])"/>

  <xsl:choose>
    <xsl:when test="empty(db:info/*)
                    and empty(* except (db:info|db:listitem|db:annotation))">
      <ul>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:if test="@mark">
          <xsl:attribute name="db-mark" select="@mark"/>
        </xsl:if>
        <xsl:apply-templates select="node()">
          <xsl:with-param name="compact" select="$compact"/>
        </xsl:apply-templates>
      </ul>
    </xsl:when>
    <xsl:otherwise>
      <div>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates select="." mode="m:generate-titlepage"/>
        <xsl:apply-templates select="* except db:listitem"/>
        <ul>
          <xsl:if test="@mark">
            <xsl:attribute name="db-mark" select="@mark"/>
          </xsl:if>
          <xsl:apply-templates select="db:listitem">
            <xsl:with-param name="compact" select="$compact"/>
          </xsl:apply-templates>
        </ul>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:orderedlist">
  <xsl:variable name="compact" as="xs:boolean"
                select="@spacing = 'compact'
                        and count(db:listitem/db:para) = count(db:listitem)
                        and empty(db:listitem/*[not(self::db:para)])"/>

  <xsl:choose>
    <xsl:when test="empty(db:info/*)
                    and empty(* except (db:info|db:listitem|db:annotation))">
      <ol>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:call-template name="tp:orderedlist-properties"/>
        <xsl:apply-templates select="node()">
          <xsl:with-param name="compact" select="$compact"/>
        </xsl:apply-templates>
      </ol>
    </xsl:when>
    <xsl:otherwise>
      <div>
        <xsl:apply-templates select="." mode="m:attributes">
          <xsl:with-param name="exclude-classes"
                          select="if (@inheritnum = 'inherit')
                                  then 'inheritnum'
                                  else ()"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="." mode="m:generate-titlepage"/>
        <xsl:apply-templates select="* except db:listitem"/>
        <ol>
          <xsl:if test="@inheritnum = 'inherit'">
            <xsl:attribute name="class" select="'inheritnum'"/>
          </xsl:if>
          <xsl:call-template name="tp:orderedlist-properties"/>
          <xsl:apply-templates select="db:listitem">
            <xsl:with-param name="compact" select="$compact"/>
          </xsl:apply-templates>
        </ol>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="tp:orderedlist-properties">
  <xsl:if test="@startingnumber">
    <xsl:attribute name="start" select="@startingnumber"/>
  </xsl:if>
  <xsl:if test="@continuation='continues'">
    <xsl:attribute name="start" select="f:orderedlist-startingnumber(.)"/>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="empty(@numeration)">
      <xsl:attribute name="type"
                     select="f:orderedlist-item-numeration(db:listitem[1])"/>
    </xsl:when>
    <xsl:when test="@numeration='arabic'">
      <xsl:attribute name="type" select="'1'"/>
    </xsl:when>
    <xsl:when test="@numeration='upperalpha'">
      <xsl:attribute name="type" select="'A'"/>
    </xsl:when>
    <xsl:when test="@numeration='loweralpha'">
      <xsl:attribute name="type" select="'a'"/>
    </xsl:when>
    <xsl:when test="@numeration='upperroman'">
      <xsl:attribute name="type" select="'I'"/>
    </xsl:when>
    <xsl:when test="@numeration='lowerroman'">
      <xsl:attribute name="type" select="'i'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>Ignoring unexpected numeration: {@numeration}</xsl:message>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:if test="@inheritnum and not(@inheritnum = ('ignore', 'inherit'))">
    <xsl:message>Ignoring unexpected inheritnum: {@inheritnum}</xsl:message>
  </xsl:if>
</xsl:template>

<xsl:template match="db:listitem">
  <xsl:param name="compact" as="xs:boolean" select="false()"/>

  <xsl:variable name="gi" select="if (parent::db:varlistentry)
                                  then 'dd'
                                  else 'li'"/>

  <xsl:element name="{$gi}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:if test="@override">
      <xsl:choose>
        <xsl:when test="parent::db:orderedlist">
          <xsl:attribute name="value" select="@override"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="db-mark" select="@override"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$compact and count(*) = 1 and db:para">
        <xsl:apply-templates select="db:para/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="db:simplelist[@type='inline']">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:for-each select="db:member">
      <xsl:if test="position() gt 1">, </xsl:if>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
  </span>
</xsl:template>

<xsl:template match="db:simplelist">
  <xsl:variable name="cols" as="xs:integer">
    <xsl:choose>
      <xsl:when test="not(@columns)">
        <xsl:sequence select="1"/>
      </xsl:when>
      <xsl:when test="@columns castable as xs:integer">
        <xsl:sequence select="@columns cast as xs:integer"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Treating non-numeric columns ({@columns}) as 1</xsl:message>
        <xsl:sequence select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="@type = 'horiz'">
      <div>
        <xsl:apply-templates select="." mode="m:attributes">
          <xsl:with-param name="extra-classes" select="'simplelisthoriz'"/>
        </xsl:apply-templates>
        <xsl:for-each select="db:member">
          <xsl:if test="$cols eq 1 or position() mod $cols = 1">
            <xsl:variable name="member" select="."/>
            <xsl:variable name="row" as="element(db:member)+">
              <xsl:sequence select="$member"/>
              <xsl:if test="$cols gt 1">
                <xsl:sequence select="$member/following-sibling::db:member
                                      [position() lt $cols]"/>
              </xsl:if>
            </xsl:variable>
            <div class="row">
              <xsl:apply-templates select="$row"/>
            </div>
          </xsl:if>
        </xsl:for-each>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <div>
        <xsl:apply-templates select="." mode="m:attributes">
          <xsl:with-param name="extra-classes" select="'simplelistvert'"/>
        </xsl:apply-templates>

        <xsl:choose>
          <xsl:when test="$cols = 1">
            <!-- special case a single column... -->
            <xsl:for-each select="db:member">
              <div class="row">
                <xsl:apply-templates select="."/>
              </div>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="rows" select="(count(db:member) + $cols - 1) idiv $cols"/>
            <xsl:for-each select="subsequence(db:member, 1, $rows)">
              <div class="row">
                <xsl:apply-templates select="fp:select-vert-members(., $rows)"/>
              </div>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- 
  A B C D E => A D
               B E
               C
-->

<xsl:function name="fp:select-vert-members" as="element(db:member)*">
  <xsl:param name="member" as="element(db:member)?"/>
  <xsl:param name="rows" as="xs:integer"/>

  <xsl:variable name="next"
                select="$member/following-sibling::*[position() eq $rows]"/>

  <xsl:sequence select="$member"/>
  <xsl:if test="$next">
    <xsl:sequence select="fp:select-vert-members($next, $rows)"/>
  </xsl:if>
</xsl:function>

<xsl:template match="db:member">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:variablelist">
  <xsl:variable name="compact" as="xs:boolean"
                select="@spacing = 'compact'
                        and count(db:varlistentry/db:listitem/db:para)
                            = count(db:varlistentry/db:listitem)
                        and empty(db:varlistentry/db:listitem/*[not(self::db:para)])"/>
  <xsl:variable name="term-length"
                select="if (@termlength)
                        then @termlength/string()
                        else max((db:varlistentry ! fp:estimated-term-length(.)))"/>

  <xsl:choose>
    <xsl:when test="empty(db:info/*)
                    and empty(* except (db:info|db:varlistentry|db:annotation))">
      <dl>
        <xsl:apply-templates select="." mode="m:attributes">
          <xsl:with-param name="term-length" select="$term-length"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="node()">
          <xsl:with-param name="compact" select="$compact"/>
        </xsl:apply-templates>
      </dl>
    </xsl:when>
    <xsl:otherwise>
      <div>
        <xsl:apply-templates select="." mode="m:attributes">
          <xsl:with-param name="term-length" select="$term-length"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="." mode="m:generate-titlepage"/>
        <xsl:apply-templates select="* except db:varlistentry"/>
        <dl>
          <!-- repeat the class and other attributes for convenience -->
          <xsl:apply-templates select="." mode="m:attributes">
            <xsl:with-param name="term-length" select="$term-length"/>
            <xsl:with-param name="exclude-id" select="true()"/>
          </xsl:apply-templates>
          <xsl:apply-templates select="db:varlistentry">
            <xsl:with-param name="compact" select="$compact"/>
          </xsl:apply-templates>
        </dl>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:variable name="vp:term"
              select="QName('http://docbook.org/ns/docbook', 'term')"/>

<xsl:template match="db:varlistentry">
  <xsl:param name="compact" as="xs:boolean" select="false()"/>
  <dt>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="db:term[1]"/>
    <xsl:choose>
      <xsl:when test="count(db:term) = 1"/>
      <xsl:when test="count(db:term) = 2">
        <xsl:apply-templates select="db:term[2]">
          <xsl:with-param name="sep"
                          select="f:gentext(db:term[2], 'separator', 'term-sep2')"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="db:term[position() gt 1 and position() lt last()]">
          <xsl:with-param name="sep"
                          select="f:gentext(db:term[2], 'separator', 'term-sep')"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="db:term[last()]">
          <xsl:with-param name="sep"
                          select="f:gentext(db:term[2], 'separator', 'term-seplast')"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </dt>

  <xsl:apply-templates select="db:listitem">
    <xsl:with-param name="compact" select="$compact"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:term">
  <xsl:param name="sep" as="item()*" select="()"/>
  <xsl:if test="exists($sep) and preceding-sibling::db:term">
    <xsl:sequence select="$sep"/>
  </xsl:if>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:function name="fp:estimated-term-length">
  <xsl:param name="entry" as="element(db:varlistentry)"/>
  <xsl:value-of select="sum(($entry/db:term ! string-length(string(.))))"/>
</xsl:function>

<!-- ============================================================ -->

<xsl:template match="db:segmentedlist">
  <xsl:variable name="presentation"
                select="f:pi(., 'segmentedlist-style', $segmentedlist-style)"/>

  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>

    <xsl:choose>
      <xsl:when test="$presentation = 'table'">
        <xsl:apply-templates select="." mode="m:seglist-table"/>
      </xsl:when>
      <xsl:when test="$presentation = 'list'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="'Unrecognized segementedlist-style:', $presentation"/>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<xsl:template match="db:segtitle"/>

<xsl:template match="db:segtitle" mode="m:segtitle-in-seg">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:seglistitem">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:seg">
  <xsl:variable name="segnum" select="count(preceding-sibling::db:seg)+1"/>
  <xsl:variable name="seglist" select="ancestor::db:segmentedlist"/>
  <xsl:variable name="segtitles" select="$seglist/db:segtitle"/>

  <!--
     Note: segtitle is only going to be the right thing in a well formed
     SegmentedList.  If there are too many Segs or too few SegTitles,
     you'll get something odd...maybe an error
  -->

  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <strong>
      <span class="segtitle">
        <xsl:apply-templates select="$segtitles[$segnum=position()]"
                             mode="m:segtitle-in-seg"/>
        <xsl:text>: </xsl:text>
      </span>
    </strong>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:segmentedlist" mode="m:seglist-table">
  <xsl:variable name="table-summary"
                select="f:pi(., 'table-summary')"/>

  <table>
    <xsl:if test="$table-summary != '' and 'summary' = $table-accessibility">
      <xsl:attribute name="summary">
        <xsl:value-of select="$table-summary"/>
      </xsl:attribute>
    </xsl:if>
    <thead class="segtitles">
      <tr>
        <xsl:apply-templates select="db:segtitle" mode="m:seglist-table"/>
      </tr>
    </thead>
    <tbody>
      <xsl:apply-templates select="db:seglistitem" mode="m:seglist-table"/>
    </tbody>
  </table>
</xsl:template>

<xsl:template match="db:segtitle" mode="m:seglist-table">
  <th>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </th>
</xsl:template>

<xsl:template match="db:seglistitem" mode="m:seglist-table">
  <xsl:variable name="seglinum">
    <xsl:number from="db:segmentedlist" count="db:seglistitem"/>
  </xsl:variable>

  <tr>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:seglist-table"/>
  </tr>
</xsl:template>

<xsl:template match="db:seg" mode="m:seglist-table">
  <td>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </td>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:calloutlist">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:apply-templates select="* except db:callout"/>
    <dl>
      <xsl:apply-templates select="db:callout"/>
    </dl>
  </div>
</xsl:template>

<xsl:template match="db:callout">
  <xsl:variable name="context" select="."/>
  <dt>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:for-each select="tokenize(normalize-space(@arearefs), '\s+')">
      <xsl:variable name="id" select="."/>
      <xsl:variable name="area" select="key('id', $id, root($context))"/>
      <xsl:variable name="area"
                    select="if (empty($area))
                            then root($context)//*[@xml:id = $id]
                            else $area"/>

      <xsl:choose>
        <xsl:when test="$area/parent::db:areaset
                        and $area/preceding-sibling::db:area"/>
        <xsl:when test="$area/self::db:areaset">
          <xsl:apply-templates select="$area/db:area[1]"
                               mode="m:callout-link">
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="target" select="$area"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$area/self::db:area">
          <xsl:apply-templates select="$area"
                               mode="m:callout-link">
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="target" select="$area"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$area/self::db:co">
          <xsl:apply-templates select="$area"
                               mode="m:callout-link">
            <xsl:with-param name="id" select="$id"/>
            <xsl:with-param name="target" select="$area"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="error($dbe:INVALID-AREAREFS,
                                      'Invalid area in arearefs: ' || $id)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </dt>
  <dd>
    <xsl:apply-templates/>
  </dd>
</xsl:template>

<xsl:template match="*" mode="m:callout-link">
  <xsl:message select="'Error: processing ', node-name(.), ' in m:callout-link mode'"/>
  <span class="error">???</span>
</xsl:template>

<xsl:template match="db:area|db:co" mode="m:callout-link">
  <xsl:param name="id" as="xs:string"/>
  <xsl:param name="target" as="element()?"/>
  <a class="callout-bug" href="#{$id}">
    <xsl:apply-templates select="." mode="m:callout-bug">
      <xsl:with-param name="id" select="$id"/>
    </xsl:apply-templates>
  </a>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:procedure">
  <xsl:choose>
    <xsl:when test="empty(db:info/*)
                    and empty(* except (db:step|db:annotation))">
      <ol type="1">
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates select="db:step"/>
      </ol>
    </xsl:when>
    <xsl:otherwise>
      <div>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates select="." mode="m:generate-titlepage"/>
        <xsl:apply-templates select="child::* except (db:step|db:result)"/>
        <ol class="{local-name(.)}" type="1">
          <xsl:apply-templates select="db:step"/>
        </ol>
        <xsl:apply-templates select="db:result"/>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:step">
  <li>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:apply-templates/>
  </li>
</xsl:template>

<xsl:template match="db:substeps">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <ol class="procedure {local-name(.)}"
        type="{f:step-numeration(db:step[1])}">
      <xsl:apply-templates/>
    </ol>
  </div>
</xsl:template>

<xsl:template match="db:stepalternatives">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <ul class="procedure {local-name(.)}">
      <xsl:apply-templates/>
    </ul>
  </div>
</xsl:template>

<xsl:template match="db:result">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:task|db:tasksummary|db:taskprerequisites|db:taskrelated">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:apply-templates/>
  </div>
</xsl:template>

</xsl:stylesheet>
