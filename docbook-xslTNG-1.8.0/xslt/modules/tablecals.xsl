<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fcals="http://docbook.org/ns/docbook/functions/private/cals"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="array db dbe f fcals fp m map mp t tp v xs"
                version="3.0">

<xsl:template match="db:table[db:tgroup]">
  <figure>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:if test="'details' = $table-accessibility">
      <xsl:apply-templates select="db:textobject[not(db:phrase)]" mode="m:details"/>
    </xsl:if>
    <xsl:apply-templates select="db:tgroup"/>
    <xsl:if test=".//db:footnote">
      <xsl:call-template name="t:table-footnotes">
        <xsl:with-param name="footnotes" select=".//db:footnote"/>
      </xsl:call-template>
    </xsl:if>
  </figure>
</xsl:template>

<xsl:template match="db:informaltable[db:tgroup]">
  <figure>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:if test="'details' = $table-accessibility">
      <xsl:apply-templates select="db:textobject[not(db:phrase)]" mode="m:details"/>
    </xsl:if>
    <xsl:apply-templates select="db:tgroup"/>
    <xsl:if test=".//db:footnote">
      <xsl:call-template name="t:table-footnotes">
        <xsl:with-param name="footnotes" select=".//db:footnote"/>
      </xsl:call-template>
    </xsl:if>
  </figure>
</xsl:template>

<xsl:template match="db:tgroup">
  <table>
    <xsl:if test="'summary' = $table-accessibility">
      <xsl:apply-templates select="../db:textobject[db:phrase]" mode="m:details"/>
    </xsl:if>
    <xsl:if test="db:colspec[@colwidth]">
      <xsl:call-template name="tp:cals-colspec"/>
    </xsl:if>
    <xsl:apply-templates select="db:thead"/>
    <xsl:apply-templates select="db:tfoot"/>
    <xsl:apply-templates select="db:tbody"/>
  </table>
</xsl:template>

<xsl:template match="db:tbody|db:thead|db:tfoot">
  <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:row">
  <xsl:variable name="row" select="."/>
  <xsl:variable name="overhang" select="fcals:overhang-into-row($row)"/>

  <xsl:variable name="cells" as="map(*)*">
    <xsl:for-each select="*">
      <xsl:variable name="colnum" select="fcals:column-number(., $overhang)"/>
      <xsl:variable name="colspan" select="fcals:colspan(., $colnum)"/>
      <xsl:variable name="rowspan" select="fcals:rowspan(., $colnum)"/>
      <xsl:sequence select="map {
        'row': $row,
        'node': .,
        'span': false(),
        'colspan': $colspan,
        'rowspan': $rowspan,
        'first-column': $colnum,
        'last-column': $colnum + $colspan - 1
      }"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:message use-when="'tables' = $debug"
               select="'========================================'"/>
  <tr>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:for-each select="1 to fcals:table-columns($row)">
      <xsl:variable name="cell" select="fcals:cell($row, ., $overhang, $cells)"/>
      <xsl:choose>
        <xsl:when test="$cell?span">
          <xsl:message use-when="'tables' = $debug"
                       select="., '--span--'"/>
        </xsl:when>
        <xsl:when test="empty($cell?node)">
          <xsl:message use-when="'tables' = $debug"
                       select="., '--empty--'"/>
          <xsl:call-template name="tp:cell">
            <xsl:with-param name="properties" select="map {
              'row': $row,
              'span': false(),
              'colspan': 1,
              'rowspan': 1,
              'first-column': .,
              'last-column': .
            }"/>
            <xsl:with-param name="td" select="if ($row/parent::db:thead) then 'th' else 'td'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message use-when="'tables' = $debug"
                       select="., $cell?node/string()
                                  =&gt; normalize-space()
                                  =&gt; substring(1, 10)"/>
          <xsl:apply-templates select="$cell?node">
            <xsl:with-param name="properties" select="$cell"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </tr>
</xsl:template>

<xsl:template match="db:entry|db:entrytbl">
  <xsl:param name="properties" as="map(*)"/>

  <xsl:call-template name="tp:cell">
    <xsl:with-param name="properties" select="$properties"/>
    <xsl:with-param name="pi-properties"
                    select="f:pi-attributes(./processing-instruction('db'))"/>
    <xsl:with-param name="td" select="if (parent::*/parent::db:thead) then 'th' else 'td'"/>
    <xsl:with-param name="content" as="item()*">
      <xsl:choose>
        <xsl:when test="self::db:entrytbl">
          <table>
            <xsl:if test="db:colspec[@colwidth]">
              <xsl:call-template name="tp:cals-colspec"/>
            </xsl:if>
            <xsl:apply-templates select="db:thead"/>
            <xsl:apply-templates select="db:tbody"/>
          </table>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$properties?align = 'char' and not(*)">
              <!-- This is all a bit fiddly. If you want to use ?db? PIs to
                   set the alignment details, they must follow the colspec for
                   the column in question. If there's no PI following the colspec,
                   we fall back to PIs following the tgroup. -->
              <xsl:variable name="piroot"
                            select="fcals:colspec-for-column(fcals:tgroup(.),
                                       $properties?first-column)"/>

              <xsl:variable name="pis"
                            select="if (empty($piroot)
                                        or empty($piroot/following-sibling::processing-instruction()))
                                    then fcals:tgroup(.)/node()
                                    else $piroot/following-sibling::node()"/>

              <xsl:variable name="pis" select="fp:only-initial-pis($pis)"/>

              <xsl:variable name="achar-width"
                            select="fp:pi-from-list($pis, 'align-char-width',
                                                    string($align-char-width))"/>

              <xsl:variable name="achar-width" as="xs:integer?">
                <xsl:choose>
                  <xsl:when test="empty($achar-width)">
                    <xsl:sequence select="()"/>
                  </xsl:when>
                  <xsl:when test="$achar-width castable as xs:integer">
                    <xsl:sequence select="xs:integer($achar-width)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:message select="'Ignoring align-char-width:', $achar-width"/>
                    <xsl:sequence select="$align-char-width"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:variable name="achar-pad"
                            select="substring(fp:pi-from-list($pis, 'align-char-pad',
                                                              $align-char-pad), 1, 1)"/>

              <xsl:variable name="content" select="normalize-space(.)"/>
              <xsl:variable name="char"
                            select="if ($properties?char)
                                    then $properties?char
                                    else $align-char-default"/>
              <xsl:variable name="width"
                            select="if (exists($achar-width))
                                    then $achar-width
                                    else $align-char-width"/>

              <xsl:variable name="parts"
                            select="f:tokenize-on-char($content, $char)"/>

              <xsl:variable name="before"
                            select="if (contains($content, $char))
                                    then string-join($parts[position() lt last()], $char)
                                    else $content"/>

              <!-- If the pad character is a form space of some sort, use it for
                   padding; otherwise use the alignment character. -->
              <xsl:variable name="before"
                            select="if (contains($content, $char))
                                    then $before || $char
                                    else if (matches($achar-pad, '\p{Zs}'))
                                         then $before || $achar-pad
                                         else $before || $char"/>

              <xsl:variable name="after"
                            select="if (contains($content, $char))
                                    then $parts[last()]
                                    else ''"/>

              <xsl:variable name="after"
                            select="fp:align-char-pad($after, $width, $achar-pad)"/>

              <xsl:value-of select="$before || $after"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="tp:cell">
  <xsl:param name="properties" as="map(*)"/>
  <xsl:param name="pi-properties" as="element()?"/>
  <xsl:param name="td" as="xs:string" select="'td'"/>
  <xsl:param name="content" as="item()*" select="()"/>

  <xsl:variable name="row" select="$properties?row"/>
  <xsl:variable name="table"
                select="($row/ancestor::db:table
                         |$row/ancestor::db:informaltable)[last()]"/>
  
  <xsl:variable name="table-part"
                select="($row/ancestor::db:thead
                         |$row/ancestor::db:tbody
                         |$row/ancestor::db:tfoot)[last()]"/>

  <xsl:variable name="frame" select="$table/@frame"/>
  <xsl:variable name="btop"
                select="$frame = 'all' or $frame = 'top' or $frame = 'topbot'"/>

  <!-- bbot:
       1. The frame includes the bottom border
       2. We're in the last row of a section and the cell has a rowsep
          and either this is a thead or it's a tbody and there is a tfoot
  -->
  <xsl:variable name="bbot"
                select="$frame = 'all' or $frame = 'bot' or $frame = 'topbot'
                        or ($properties?rowsep
                            and empty($row/following-sibling::db:row)
                            and ($table-part/self::db:thead
                                 or ($table-part/self::db:tbody
                                     and $table-part/preceding-sibling::db:tfoot)))"/>
  <xsl:variable name="bleft"
                select="$frame = 'all' or $frame = 'sides'"/>
  <xsl:variable name="bright"
                select="$frame = 'all' or $frame = 'sides'"/>

  <xsl:variable name="classes" as="xs:string*">
    <xsl:sequence select="if ($properties?first-column = 1 and $bleft)
                          then 'bleft'
                          else ()"/>
    <xsl:sequence select="if (empty($row/preceding-sibling::db:row) and $btop)
                          then 'btop'
                          else ()"/>
    <xsl:sequence select="f:cals-rowsep($row, $properties, $bbot)"/>
    <xsl:sequence select="f:cals-colsep($row, $properties, $bright)"/>
    <xsl:sequence select="if ($properties?node)
                          then ()
                          else 'empty'"/>
    <xsl:sequence select="$properties?align"/>
    <xsl:sequence select="$properties?valign"/>
    <xsl:if test="$properties?node/@role">
      <xsl:sequence select="tokenize($properties?node/@role, '\s+')"/>
    </xsl:if>
  </xsl:variable>

  <xsl:element name="{$td}" namespace="http://www.w3.org/1999/xhtml">
    <!-- Can't (easily) use the m:attributes mode here because we need
         to output the appropriate attributes even when there is no
         DocBook node. (For example, when a cell is omitted.) -->
    <xsl:if test="map:contains($properties, 'node')
                  and $properties?node/@xml:id">
      <xsl:attribute name="id" select="$properties?node/@xml:id"/>
    </xsl:if>
    <xsl:if test="exists($classes)">
      <xsl:variable name="sorted" as="xs:string+">
        <xsl:for-each select="$classes">
          <xsl:sort select="."/>
          <xsl:sequence select="."/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:attribute name="class" select="string-join($sorted, ' ')"/>
    </xsl:if>
    <xsl:if test="$properties?colspan gt 1">
      <xsl:attribute name="colspan" select="$properties?colspan"/>
    </xsl:if>
    <xsl:if test="$properties?rowspan gt 1">
      <xsl:attribute name="rowspan" select="$properties?rowspan"/>
    </xsl:if>
    <xsl:copy-of select="$pi-properties/@style"/>
    <xsl:sequence select="$content"/>
  </xsl:element>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="tp:cals-colspec">
  <xsl:variable name="tgroup" select="."/>

  <xsl:variable name="widths" as="map(*)*">
    <xsl:for-each select="1 to xs:integer($tgroup/@cols)">
      <xsl:variable name="colspec" select="fcals:colspec-for-column($tgroup, .)"/>
      <xsl:choose>
        <xsl:when test="exists($colspec)">
          <xsl:choose>
            <xsl:when test="$colspec/@colwidth">
              <xsl:sequence select="f:parse-length(string($colspec/@colwidth))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="f:parse-length('1*')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="f:parse-length('1*')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>

  <!--
  <xsl:for-each select="$widths">
    <xsl:message select="'R:' || .?relative || ' M:' || .?magnitude || ' U:' || .?units"/>
  </xsl:for-each>
  -->

  <xsl:variable name="absolute-width" as="xs:double"
                select="sum($widths ! f:absolute-length(.))"/>

  <xsl:variable name="relative-width" as="xs:double"
                select="sum($widths ! f:relative-length(.))"/>

  <xsl:variable name="absolute-remainder"
                select="f:absolute-length($v:nominal-page-width) - $absolute-width"/>

  <xsl:if test="$absolute-remainder le 0">
    <xsl:message>Table width exceeds nominal width, ignoring relative width</xsl:message>
  </xsl:if>

  <xsl:variable name="absolute-remainder"
                select="if ($absolute-remainder lt 0)
                        then 0
                        else $absolute-remainder"/>

  <xsl:choose>
    <xsl:when test="$relative-width gt 0">
      <xsl:variable name="percent-widths" as="xs:integer*">
        <xsl:for-each select="$widths">
          <xsl:variable name="rel-part"
                        select="if (.?relative and .?relative gt 0)
                                then $absolute-remainder div $relative-width * .?relative
                                else 0"/>
          <xsl:sequence select="xs:integer(floor(($rel-part + f:absolute-length(.))
                                                 div f:absolute-length($v:nominal-page-width)
                                                 * 100.0))"/>
        </xsl:for-each>
      </xsl:variable>

      <!-- because I'm fussy about the details; make sure the sum = 100% -->
      <xsl:variable name="first-width" as="xs:integer">
        <xsl:sequence select="$percent-widths[1] + (100 - sum($percent-widths))"/>
      </xsl:variable>

      <colgroup>
        <xsl:for-each select="($first-width, subsequence($percent-widths, 2))">
          <col style="width: {.}%"/>
        </xsl:for-each>
      </colgroup>
    </xsl:when>
    <xsl:otherwise>
      <colgroup>
        <xsl:for-each select="$widths">
          <col style="width: {f:absolute-length(.)}"/>
        </xsl:for-each>
      </colgroup>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:function name="fcals:colspec-for-column" as="element()?" cache="yes">
  <xsl:param name="tgroup" as="element()"/>
  <xsl:param name="colnum" as="xs:integer"/>
  <xsl:sequence select="fp:colspec-for-colnum($tgroup/db:colspec, $colnum, 1)"/>
</xsl:function>

<xsl:function name="fp:colspec-for-colnum" as="element()?" cache="yes">
  <xsl:param name="colspecs" as="element()*"/>
  <xsl:param name="colnum" as="xs:integer"/>
  <xsl:param name="curcol" as="xs:integer"/>

  <!--
  <xsl:message select="('c4c: ', $colnum, ', ', $curcol, ', ', $colspecs[1])"/>
  -->

  <xsl:choose>
    <xsl:when test="empty($colspecs)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:when test="normalize-space($colspecs[1]/@colnum) = string($colnum)">
      <xsl:sequence select="$colspecs[1]"/>
    </xsl:when>
    <xsl:when test="normalize-space($colspecs[1]/@colnum)">
      <xsl:sequence
          select="fp:colspec-for-colnum(subsequence($colspecs,2), $colnum,
                                        xs:integer($colspecs[1]/@colnum)+1)"/>
    </xsl:when>
    <xsl:when test="$colnum = $curcol">
      <xsl:sequence select="$colspecs[1]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence
          select="fp:colspec-for-colnum(subsequence($colspecs,2), $colnum, $curcol + 1)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="fcals:cell" as="map(*)" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:param name="column" as="xs:integer"/>
  <xsl:param name="overhang" as="array(xs:integer)"/>
  <xsl:param name="cells" as="map(*)*"/>

  <xsl:variable name="cell" as="map(*)*">
    <xsl:for-each select="$cells">
      <xsl:if test="$column ge .?first-column
                    and $column le .?last-column">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:if test="count($cell) gt 1">
    <xsl:variable name="rownum" select="count($row/preceding-sibling::db:row) + 1"/>
    <xsl:message terminate="yes"
                 select="'Overlapping cells in table at row '
                         || $rownum || ' for column ' || $column"/>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="array:get($overhang, $column) ne 0
                    or (exists($cell) and $cell?first-column ne $column)">
      <xsl:sequence select="map { 'span': true() }"/>
    </xsl:when>
    <xsl:when test="empty($cell)">
      <xsl:sequence select="fcals:cell-decoration($row, $cell?node, $column)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="map:merge(($cell,
                            fcals:cell-decoration($row, $cell?node, $column)))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:overhang-into-row" as="array(xs:integer)" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:choose>
    <xsl:when test="empty($row/preceding-sibling::*)">
      <xsl:sequence select="fcals:zeros($row)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fcals:overhang($row/preceding-sibling::db:row[1])"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:overhang" as="array(xs:integer)" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>

  <xsl:variable name="overhang"
                select="if (empty($row/preceding-sibling::*))
                        then fcals:zeros($row)
                        else fcals:decrement-overhang(fcals:overhang($row/preceding-sibling::*[1]))"/>

  <xsl:variable name="colmap" as="map(xs:integer, node())">
    <xsl:map>
      <xsl:for-each select="$row/*">
        <xsl:map-entry key="fcals:column-number(., $overhang)" select="."/>
      </xsl:for-each>
    </xsl:map>
  </xsl:variable>

  <xsl:variable name="newoverhang" as="xs:integer*">
    <xsl:for-each select="array:flatten($overhang)">
      <xsl:sequence select=". + fcals:cell-overhang($colmap, position())"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:sequence select="array { $newoverhang }"/>
</xsl:function>

<xsl:function name="fcals:cell-overhang" cache="yes">
  <xsl:param name="colmap" as="map(xs:integer, node())"/>
  <xsl:param name="column" as="xs:integer"/>

  <xsl:variable name="over" as="xs:integer?">
    <xsl:for-each select="map:keys($colmap)">
      <xsl:variable name="fcol" select="."/>
      <xsl:variable name="cell" select="map:get($colmap, .)"/>
      <xsl:variable name="width" select="fcals:colspan($cell, .)"/>
      <xsl:variable name="lcol" select="$fcol + $width - 1"/>
      <xsl:if test="$column ge $fcol and $column le $lcol">
        <xsl:sequence select="fcals:rowspan($cell, .)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:sequence select="if (exists($over)) then $over - 1 else 0"/>
</xsl:function>

<xsl:function name="fcals:next-empty-cell" cache="yes">
  <xsl:param name="column" as="xs:integer"/>
  <xsl:param name="overhang" as="array(xs:integer)"/>
  <xsl:choose>
    <xsl:when test="$column gt array:size($overhang)">
      <xsl:sequence select="error($dbe:INVALID-CALS, 'Columns exceed @cols')"/>
    </xsl:when>
    <xsl:when test="array:get($overhang, $column) eq 0">
      <xsl:sequence select="$column"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fcals:next-empty-cell($column + 1, $overhang)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:decrement-overhang" as="array(xs:integer)" cache="yes">
  <xsl:param name="overhang" as="array(xs:integer)"/>
  <xsl:sequence select="array {
    for $hang in array:flatten($overhang) return max((0, $hang - 1))
  }"/>
</xsl:function>

<xsl:function name="fcals:column-number" as="xs:integer" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="overhang" as="array(xs:integer)"/>

  <xsl:choose>
    <xsl:when test="$node/@namest">
      <xsl:sequence
          select="fcals:colspec-column-number(
                     fcals:colspec($node, $node/@namest))"/>
    </xsl:when>
    <xsl:when test="$node/@colname">
      <xsl:sequence
          select="fcals:colspec-column-number(
                     fcals:colspec($node, $node/@colname))"/>
    </xsl:when>
    <xsl:when test="$node/preceding-sibling::*">
      <xsl:variable name="pcell" select="$node/preceding-sibling::*[1]"/>
      <xsl:variable name="column"
                    select="fcals:column-number($pcell, $overhang)"/>
      <xsl:variable name="nextcolumn"
                    select="$column + fcals:colspan($pcell, $column)"/>
      <xsl:sequence select="fcals:next-empty-cell($nextcolumn, $overhang)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fcals:next-empty-cell(1, $overhang)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:colspec-column-number" as="xs:integer" cache="yes">
  <xsl:param name="colspec" as="element(db:colspec)" required="yes"/>

  <xsl:choose>
    <xsl:when test="$colspec/@colnum">
      <xsl:sequence select="xs:integer($colspec/@colnum)"/>
    </xsl:when>
    <xsl:when test="$colspec/preceding-sibling::db:colspec">
      <xsl:sequence
          select="fcals:colspec-column-number(
                     $colspec/preceding-sibling::db:colspec[1]) + 1 "/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="1"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:colspec" as="element(db:colspec)" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="colname" as="xs:string" required="yes"/>

  <xsl:variable name="colspec"
                select="fcals:tgroup($node)/db:colspec[@colname=$colname]"/>

  <xsl:if test="empty($colspec)">
    <xsl:sequence select="error($dbe:INVALID-CALS, 'No colspec named ' || $colname)"/>
  </xsl:if>

  <xsl:sequence select="$colspec"/>
</xsl:function>

<xsl:function name="fcals:spanspec" as="element(db:spanspec)" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="spanname" as="xs:string" required="yes"/>

  <xsl:variable name="spanspec"
                select="fcals:tgroup($node)/db:spanspec[@spanname=$spanname]"/>

  <xsl:if test="empty($spanspec)">
    <xsl:sequence select="error($dbe:INVALID-CALS, 'No spanspec named ' || $spanname)"/>
  </xsl:if>

  <xsl:sequence select="$spanspec"/>
</xsl:function>

<xsl:function name="fcals:colspan" as="xs:integer" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="colnum" as="xs:integer" required="yes"/>

  <xsl:choose>
    <xsl:when test="$node/@nameend">
      <xsl:variable name="last-colnum"
                    select="fcals:colspec-column-number(
                               fcals:colspec($node, $node/@nameend))"/>
      <xsl:sequence select="$last-colnum - $colnum + 1"/>
    </xsl:when>
    <xsl:when test="$node/@spanname">
      <xsl:variable name="spanspec" select="fcals:spanspec($node, $node/@spanname)"/>
      <xsl:variable name="last-colnum"
                    select="fcals:colspec-column-number(
                               fcals:colspec($node, $spanspec/@nameend))"/>
      <xsl:sequence select="$last-colnum - $colnum + 1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="1"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:rowspan" as="xs:integer" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="colnum" as="xs:integer" required="yes"/>

  <xsl:choose>
    <xsl:when test="$node/@morerows">
      <xsl:sequence select="xs:integer($node/@morerows) + 1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="1"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="fcals:cell-decoration" as="map(*)">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:param name="cell" as="element()?"/>
  <xsl:param name="column" as="xs:integer"/>
  <xsl:sequence select="map {
    'colsep': fcals:colsep($row, $cell, $column),
    'rowsep': fcals:rowsep($row, $cell, $column),
    'char': fcals:char($row, $cell, $column),
    'align': fcals:align($row, $cell, $column),
    'valign': fcals:valign($row, $cell)
  }"/>
<!--
-->
</xsl:function>

<xsl:function name="fcals:colsep" as="xs:boolean" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:param name="node" as="element()?"/>
  <xsl:param name="colnum" as="xs:integer"/>

  <xsl:variable name="tgroup" select="fcals:tgroup($row)"/>

  <xsl:choose>
    <xsl:when test="$node/@colsep">
      <xsl:sequence select="$node/@colsep = '1'"/>
    </xsl:when>
    <xsl:when test="$node/@nameend">
      <xsl:sequence select="fcals:colsep-colspec($node, $node/@nameend)"/>
    </xsl:when>
    <xsl:when test="$node/@colname">
      <xsl:sequence select="fcals:colsep-colspec($node, $node/@colname)"/>
    </xsl:when>
    <xsl:when test="$node/@spanname">
      <xsl:sequence select="fcals:colsep-spanspec($node, $node/@spanname)"/>
    </xsl:when>
    <xsl:when test="fcals:colspec-for-column($tgroup, $colnum)/@colsep">
      <xsl:sequence select="fcals:colspec-for-column($tgroup, $colnum)/@colsep = '1'"/>
    </xsl:when>
    <xsl:when test="$tgroup/@colsep">
      <xsl:sequence select="$tgroup/@colsep = '1'"/>
    </xsl:when>
    <!-- exclude entry parent of entrytbl -->
    <xsl:when test="$tgroup/parent::*[not(self::db:entry)]/@colsep">
      <xsl:sequence select="$tgroup/parent::*[not(self::db:entry)]/@colsep = '1'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:colsep-colspec" as="xs:boolean" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="name" as="xs:string" required="yes"/>

  <xsl:variable name="colspec" select="fcals:colspec($node, $name)"/>

  <xsl:variable name="tgroup" select="fcals:tgroup($node)"/>

  <xsl:choose>
    <xsl:when test="$colspec/@colsep">
      <xsl:sequence select="$colspec/@colsep = '1'"/>
    </xsl:when>
    <xsl:when test="$tgroup/@colsep">
      <xsl:sequence select="$tgroup/@colsep = '1'"/>
    </xsl:when>
    <!-- exclude entry parent of entrytbl -->
    <xsl:when test="$tgroup/parent::*[not(self::db:entry)]/@colsep">
      <xsl:sequence select="$tgroup/parent::*[not(self::db:entry)]/@colsep = '1'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:colsep-spanspec" as="xs:boolean" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="name" as="xs:string" required="yes"/>

  <xsl:variable name="spanspec" select="fcals:spanspec($node, $name)"/>

  <xsl:choose>
    <xsl:when test="$spanspec/@colsep">
      <xsl:sequence select="$spanspec/@colsep = '1'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fcals:colsep-colspec($node, $spanspec/@nameend)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:empty-cell-colsep" as="xs:boolean" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:param name="cell" as="map(*)"/>

  <xsl:variable name="tgroup" select="fcals:tgroup($row)"/>

  <xsl:choose>
    <xsl:when test="fcals:colspec-for-column($tgroup, $cell?first-column)/@colsep">
      <xsl:sequence select="fcals:colspec-for-column($tgroup, $cell?first-column)/@colsep = '1'"/>
    </xsl:when>
    <xsl:when test="$tgroup/@colsep">
      <xsl:sequence select="$tgroup/@colsep = '1'"/>
    </xsl:when>
    <xsl:when test="$tgroup/parent::*[not(self::db:entry)]/@colsep">
      <xsl:sequence select="$tgroup/parent::*[not(self::db:entry)]/@colsep = '1'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="fcals:rowsep" as="xs:boolean" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:param name="node" as="element()?"/>
  <xsl:param name="colnum" as="xs:integer"/>

  <xsl:variable name="tgroup" select="fcals:tgroup($row)"/>

  <xsl:choose>
    <xsl:when test="$node/@rowsep">
      <xsl:sequence select="$node/@rowsep = '1'"/>
    </xsl:when>
    <xsl:when test="$node/@nameend">
      <xsl:sequence select="fcals:rowsep-colspec($node, $node/@nameend)"/>
    </xsl:when>
    <xsl:when test="$node/@colname">
      <xsl:sequence select="fcals:rowsep-colspec($node, $node/@colname)"/>
    </xsl:when>
    <xsl:when test="$node/@spanname">
      <xsl:sequence select="fcals:rowsep-spanspec($node, $node/@spanname)"/>
    </xsl:when>
    <xsl:when test="$node/parent::db:row/@rowsep">
      <xsl:sequence select="$node/parent::db:row/@rowsep = '1'"/>
    </xsl:when>
    <xsl:when test="$tgroup/@rowsep">
      <xsl:sequence select="$tgroup/@rowsep = '1'"/>
    </xsl:when>
    <xsl:when test="$tgroup/parent::*[not(self::db:entry)]/@rowsep">
      <xsl:sequence select="$tgroup/parent::*[not(self::db:entry)]/@rowsep = '1'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:rowsep-colspec" as="xs:boolean" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="name" as="xs:string" required="yes"/>

  <xsl:variable name="colspec" select="fcals:colspec($node, $name)"/>

  <xsl:variable name="tgroup"
                select="($node/ancestor::db:tgroup
                         |$node/ancestor::db:entrytbl)[last()]"/>

  <xsl:choose>
    <xsl:when test="$colspec/@rowsep">
      <xsl:sequence select="$colspec/@rowsep = '1'"/>
    </xsl:when>
    <xsl:when test="$node/parent::db:row/@rowsep">
      <xsl:sequence select="$node/parent::db:row/@rowsep = '1'"/>
    </xsl:when>
    <xsl:when test="$tgroup/@rowsep">
      <xsl:sequence select="$tgroup/@rowsep = '1'"/>
    </xsl:when>
    <xsl:when test="$tgroup/parent::*[not(self::db:entry)]/@rowsep">
      <xsl:sequence select="$tgroup/parent::*[not(self::db:entry)]/@rowsep = '1'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:rowsep-spanspec" as="xs:boolean" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="name" as="xs:string" required="yes"/>

  <xsl:variable name="spanspec" select="fcals:spanspec($node, $name)"/>

  <xsl:choose>
    <xsl:when test="$spanspec/@rowsep">
      <xsl:sequence select="$spanspec/@rowsep = '1'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fcals:rowsep-colspec($node, $spanspec/@nameend)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:align" as="xs:string?" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:param name="node" as="element()?"/>
  <xsl:param name="colnum" as="xs:integer"/>

  <xsl:variable name="tgroup" select="fcals:tgroup($row)"/>
  <xsl:choose>
    <xsl:when test="$node/@align">
      <xsl:sequence select="$node/@align"/>
    </xsl:when>
    <xsl:when test="$node/@nameend">
      <xsl:sequence select="fcals:align-colspec($node, $node/@nameend)"/>
    </xsl:when>
    <xsl:when test="$node/@colname">
      <xsl:sequence select="fcals:align-colspec($node, $node/@colname)"/>
    </xsl:when>
    <xsl:when test="$node/@spanname">
      <xsl:sequence select="fcals:align-spanspec($node, $node/@spanname)"/>
    </xsl:when>
    <xsl:when test="fcals:colspec-for-column($tgroup, $colnum)/@align">
      <xsl:sequence select="fcals:colspec-for-column($tgroup, $colnum)/@align"/>
    </xsl:when>
    <xsl:when test="$tgroup/@align">
      <xsl:sequence select="$tgroup/@align"/>
    </xsl:when>
    <xsl:when test="$tgroup/parent::*[not(self::db:entry)]/@align">
      <xsl:sequence select="$tgroup/parent::*[not(self::db:entry)]/@align"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:align-colspec" as="xs:string?" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="name" as="xs:string" required="yes"/>

  <xsl:variable name="colspec" select="fcals:colspec($node, $name)"/>

  <xsl:variable name="tgroup"
                select="($node/ancestor::db:tgroup
                         |$node/ancestor::db:entrytbl)[last()]"/>

  <xsl:choose>
    <xsl:when test="$colspec/@align">
      <xsl:sequence select="$colspec/@align"/>
    </xsl:when>
    <xsl:when test="$tgroup/@align">
      <xsl:sequence select="$tgroup/@align"/>
    </xsl:when>
    <xsl:when test="$tgroup/parent::*[not(self::db:entry)]/@align">
      <xsl:sequence select="$tgroup/parent::*[not(self::db:entry)]/@align"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:align-spanspec" as="xs:string?" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="name" as="xs:string" required="yes"/>

  <xsl:variable name="spanspec" select="fcals:spanspec($node, $name)"/>

  <xsl:choose>
    <xsl:when test="$spanspec/@align">
      <xsl:sequence select="$spanspec/@align"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fcals:align-colspec($node, $spanspec/@nameend)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:char" as="xs:string?" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:param name="node" as="element()?"/>
  <xsl:param name="colnum" as="xs:integer"/>

  <xsl:variable name="tgroup" select="fcals:tgroup($row)"/>

  <xsl:choose>
    <xsl:when test="$node/@char">
      <xsl:sequence select="$node/@char"/>
    </xsl:when>
    <xsl:when test="$node/@nameend">
      <xsl:sequence select="fcals:char-colspec($node, $node/@nameend)"/>
    </xsl:when>
    <xsl:when test="$node/@colname">
      <xsl:sequence select="fcals:char-colspec($node, $node/@colname)"/>
    </xsl:when>
    <xsl:when test="$node/@spanname">
      <xsl:sequence select="fcals:char-spanspec($node, $node/@spanname)"/>
    </xsl:when>
    <xsl:when test="fcals:colspec-for-column($tgroup, $colnum)/@char">
      <xsl:sequence select="fcals:colspec-for-column($tgroup, $colnum)/@char"/>
    </xsl:when>
    <xsl:when test="$tgroup/@char">
      <xsl:sequence select="$tgroup/@char"/>
    </xsl:when>
    <xsl:when test="$tgroup/parent::*[not(self::db:entry)]/@char">
      <xsl:sequence select="$tgroup/parent::*[not(self::db:entry)]/@char"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:char-colspec" as="xs:string?" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="name" as="xs:string" required="yes"/>

  <xsl:variable name="colspec" select="fcals:colspec($node, $name)"/>

  <xsl:variable name="tgroup"
                select="($node/ancestor::db:tgroup
                         |$node/ancestor::db:entrytbl)[last()]"/>

  <xsl:choose>
    <xsl:when test="$colspec/@char">
      <xsl:sequence select="$colspec/@char"/>
    </xsl:when>
    <xsl:when test="$tgroup/@char">
      <xsl:sequence select="$tgroup/@char"/>
    </xsl:when>
    <xsl:when test="$tgroup/parent::*[not(self::db:entry)]/@char">
      <xsl:sequence select="$tgroup/parent::*[not(self::db:entry)]/@char"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:char-spanspec" as="xs:string?" cache="yes">
  <xsl:param name="node" as="element()" required="yes"/>
  <xsl:param name="name" as="xs:string" required="yes"/>

  <xsl:variable name="spanspec" select="fcals:spanspec($node, $name)"/>

  <xsl:choose>
    <xsl:when test="$spanspec/@char">
      <xsl:sequence select="$spanspec/@char"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fcals:char-colspec($node, $spanspec/@nameend)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fcals:valign" as="xs:string?" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:param name="node" as="element()?"/>

  <xsl:choose>
    <xsl:when test="$node/@valign">
      <xsl:sequence select="$node/@valign"/>
    </xsl:when>
    <xsl:when test="$node/parent::db:row/@valign">
      <xsl:sequence select="$node/parent::db:row/@valign"/>
    </xsl:when>
    <xsl:when test="$node/parent::db:row/parent::*/@valign">
      <xsl:sequence select="$node/parent::db:row/parent::*/@valign"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="f:cals-rowsep" as="xs:string?" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:param name="cell" as="map(*)"/>
  <xsl:param name="last-row-rowsep" as="xs:boolean"/>

  <xsl:variable name="last-row"
                select="count($row/following-sibling::db:row) lt $cell?rowspan"/>

  <xsl:variable name="rowsep"
                select="if ($cell?node)
                        then $cell?rowsep
                        else fcals:empty-cell-rowsep($row)"/>

  <xsl:if test="($rowsep and not($last-row))
                or ($last-row and $last-row-rowsep)">
    <xsl:sequence select="'rowsep'"/>
  </xsl:if>
</xsl:function>

<xsl:function name="f:cals-colsep" as="xs:string?" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:param name="cell" as="map(*)"/>
  <xsl:param name="last-col-colsep" as="xs:boolean"/>

  <xsl:variable name="last-col"
                select="$cell?first-column + $cell?colspan
                        gt fcals:table-columns($row)"/>

  <xsl:variable name="colsep"
                select="if ($cell?node)
                        then $cell?colsep
                        else fcals:empty-cell-colsep($row, $cell)"/>

  <xsl:if test="($colsep and not($last-col))
                or ($last-col and $last-col-colsep)">
    <xsl:sequence select="'colsep'"/>
  </xsl:if>
</xsl:function>

<xsl:function name="fcals:empty-cell-rowsep" as="xs:boolean" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>

  <xsl:variable name="tgroup" select="fcals:tgroup($row)"/>

  <xsl:choose>
    <xsl:when test="$row/@rowsep">
      <xsl:sequence select="$row/@rowsep = '1'"/>
    </xsl:when>
    <xsl:when test="$tgroup/@rowsep">
      <xsl:sequence select="$tgroup/@rowsep = '1'"/>
    </xsl:when>
    <xsl:when test="$tgroup/parent::*[not(self::db:entry)]/@rowsep">
      <xsl:sequence select="$tgroup/parent::*[not(self::db:entry)]/@rowsep = '1'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="fp:only-initial-pis" as="processing-instruction()*">
  <xsl:param name="nodes" as="node()*"/>

  <xsl:iterate select="$nodes">
    <xsl:param name="pis" select="()"/>
    <xsl:choose>
      <xsl:when test="self::processing-instruction()">
        <xsl:next-iteration>
          <xsl:with-param name="pis" select="($pis, .)"/>
        </xsl:next-iteration>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$pis"/>
        <xsl:break/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:iterate>
</xsl:function>

<xsl:function name="fp:align-char-pad" as="xs:string">
  <!-- FIXME: optimize this -->
  <xsl:param name="text" as="xs:string"/>
  <xsl:param name="width" as="xs:integer"/>
  <xsl:param name="pad" as="xs:string"/>
  <xsl:sequence select="if (string-length($text) lt $width)
                        then fp:align-char-pad($text||$pad, $width, $pad)
                        else $text"/>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="fcals:table-columns" as="xs:integer" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="xs:integer(fcals:tgroup($node)/@cols)"/>
</xsl:function>

<xsl:function name="fcals:tgroup" as="element()" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="($node/ancestor::db:tgroup
                         |$node/ancestor::db:entrytbl)[last()]"/>
</xsl:function>

<xsl:function name="fcals:zeros" cache="yes">
  <xsl:param name="row" as="element(db:row)"/>
  <xsl:variable name="cols" select="fcals:table-columns($row)"/>
  <xsl:sequence select="array { for $col in 1 to $cols return 0 }"/>
</xsl:function>

</xsl:stylesheet>
