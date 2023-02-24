<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:g="http://docbook.org/ns/docbook/ghost"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="#all"
                version="3.0">

<!-- N.B. There's no winning here. It would be nice to inject callouts
     into the pre-formatted sources, but if we do that, the sources
     don't get processed in the original document tree (so id/idref
     links and such won't work). If, instead, we process the tree
     first, then we have to do the flattening and other manipulations
     in the formatted HTML over which we have less control. But having
     the elements processed in the correct tree seems like a real
     requirement, so we'll do the flatting work in the formatted
     results.

     Note also: syntax highlighting is incompatible with embedded markup.
     If syntax highlighting is applied, it is applied to the string value
     of the verbatim region.
-->

<xsl:import href="highlight.xsl"/>

<!-- When counting characters in a line, these characters are
     invisible, just skip right past them.
     FIXME: get an authoritative list of invisible characters
     this is just a small selection of ones that occurred to me.
-->
<xsl:variable name="v:invisible-characters"
              select="('&#xFE00;', '&#xFE01;', '&#xFE02;', '&#xFE03;', 
                       '&#xFE04;', '&#xFE05;', '&#xFE06;', '&#xFE07;', 
                       '&#xFE08;', '&#xFE09;', '&#xFE0A;', '&#xFE0B;', 
                       '&#xFE0C;', '&#xFE0D;', '&#xFE0E;', '&#xFE0F;', 
                       '&#x200B;')"/>

<!-- FIXME: rename 'highlight' to 'callout' for consistency -->

<xsl:variable name="v:verbatim-properties" as="array(map(*))">
  <xsl:variable name="maps" as="map(*)+">
    <xsl:for-each select="('address', 'literallayout',
                           'programlisting', 'programlistingco',
                           'screen', 'screenco',
                           'synopsis', 'funcsynopsisinfo', 'classsynopsisinfo')">
      <xsl:variable name="style" select="if (. = $v:verbatim-table-style)
                                         then 'table'
                                         else if (. = $v:verbatim-line-style)
                                              then 'lines'
                                              else if (. = $v:verbatim-plain-style)
                                                   then 'plain'
                                                   else 'raw'"/>
      <xsl:map>
        <xsl:map-entry key="'xpath'" select="'self::db:' || ."/>
        <xsl:map-entry key="'style'" select="$style"/>
        <xsl:map-entry key="'highlight'"
                       select="if ($style = 'lines')
                               then $v:verbatim-callouts
                               else ()"/>
        <xsl:map-entry key="'numbered'"
                       select=". = $v:verbatim-numbered-elements"/>
      </xsl:map>
    </xsl:for-each>
  </xsl:variable>
  <xsl:sequence select="array { $maps }"/>
</xsl:variable>

<xsl:template match="db:programlistingco|db:screenco">
  <xsl:param name="style" as="xs:string" select="f:verbatim-style(.)"/>
  <xsl:param name="highlight" as="xs:string*" select="f:verbatim-highlight(.)"/>
  <xsl:param name="numbered" as="xs:boolean" select="f:verbatim-numbered(.)"/>
  <xsl:param name="trim-trailing" as="xs:boolean" select="f:verbatim-trim-trailing(.)"/>

  <xsl:variable name="areaspec" as="element(db:areaspec)?">
    <xsl:choose>
      <xsl:when test="$verbatim-syntax-highlighter != 'pygments'">
        <xsl:message select="'Processing', local-name(.), 'is only supported with Pygments'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="db:areaspec"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <p xsl:use-when="'render-verbatim' = $v:debug"
     class="debug" xsl:expand-text="yes">Verbatim environment formatted with
  <code>style={$style}</code>, <code>numbered={$numbered}</code>, and
  <code>highlight={string-join($highlight, ',')}</code>.</p>

  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>

    <xsl:apply-templates select="db:programlisting|db:screen">
      <xsl:with-param name="style" select="$style"/>
      <xsl:with-param name="highlight" select="$highlight"/>
      <xsl:with-param name="numbered" select="$numbered"/>
      <xsl:with-param name="inject" select="$areaspec"/>
      <xsl:with-param name="trim-trailing" select="$trim-trailing"/>
    </xsl:apply-templates>

    <xsl:apply-templates select="db:calloutlist"/>
  </div>
</xsl:template>

<xsl:template match="db:programlisting|db:screen
                     |db:synopsis
                     |db:funcsynopsisinfo
                     |db:classsynopsisinfo
                     |db:literallayout|db:address">
  <xsl:param name="style" as="xs:string" select="f:verbatim-style(.)"/>
  <xsl:param name="highlight" as="xs:string*" select="f:verbatim-highlight(.)"/>
  <xsl:param name="numbered" as="xs:boolean" select="f:verbatim-numbered(.)"/>
  <xsl:param name="trim-trailing" as="xs:boolean" select="f:verbatim-trim-trailing(.)"/>
  <xsl:param name="inject" as="item()?" select="()"/>

  <xsl:message use-when="'verbatim' = $v:debug"
               select="'Verbatim: ' || node-name(.)
                       || (if (@xml:id) then '/'||@xml:id else '')
                       || ' ' || $style
                       || ' : ' || string-join($highlight,',')
                       || ' : ' || $numbered"/>

  <!--
  <xsl:message>STY:<xsl:value-of select="$style"/></xsl:message>
  <xsl:message>CTX:<xsl:sequence select="."/></xsl:message>
  <xsl:message>INJ:<xsl:sequence select="$inject"/></xsl:message>
  -->

  <xsl:variable name="injectarr" select="fp:injection-array($inject)"/>

  <xsl:call-template name="tp:verbatim">
    <xsl:with-param name="style" select="$style"/>
    <xsl:with-param name="highlight" select="$highlight"/>
    <xsl:with-param name="numbered" select="$numbered"/>
    <xsl:with-param name="trim-trailing" select="$trim-trailing"/>
    <xsl:with-param name="inject" select="$injectarr"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="tp:verbatim" as="element()">
  <xsl:param name="style" as="xs:string" required="yes"/>
  <xsl:param name="highlight" as="xs:string*" required="yes"/>
  <xsl:param name="numbered" as="xs:boolean" required="yes"/>
  <xsl:param name="trim-trailing" as="xs:boolean" required="yes"/>
  <xsl:param name="inject" as="array(*)?" select="()"/>

  <xsl:choose>
    <xsl:when test="$style = 'plain'">
      <xsl:if test="exists($highlight)">
        <xsl:message>Verbatim plain processing doesn’t support highlighting</xsl:message>
      </xsl:if>
      <xsl:if test="$numbered">
        <xsl:message>Verbatim plain processing doesn’t support line numbering</xsl:message>
      </xsl:if>
      <xsl:call-template name="tp:verbatim-plain">
        <xsl:with-param name="highlight" select="$highlight"/>
        <xsl:with-param name="numbered" select="$numbered"/>
        <xsl:with-param name="trim-trailing" select="$trim-trailing"/>
        <xsl:with-param name="inject" select="$inject"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$style = 'table'">
      <xsl:call-template name="tp:verbatim-table">
        <xsl:with-param name="highlight" select="$highlight"/>
        <xsl:with-param name="numbered" select="$numbered"/>
        <xsl:with-param name="trim-trailing" select="$trim-trailing"/>
        <xsl:with-param name="inject" select="$inject"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$style = 'lines'">
      <xsl:call-template name="tp:verbatim-lines">
        <xsl:with-param name="highlight" select="$highlight"/>
        <xsl:with-param name="numbered" select="$numbered"/>
        <xsl:with-param name="trim-trailing" select="$trim-trailing"/>
        <xsl:with-param name="inject" select="$inject"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$style = 'raw'">
      <xsl:if test="exists($inject)">
        <xsl:message>Verbatim raw processing doesn’t support injections</xsl:message>
      </xsl:if>
      <xsl:if test="exists($highlight)">
        <xsl:message>Verbatim raw processing doesn’t support highlighting</xsl:message>
      </xsl:if>
      <xsl:if test="$numbered">
        <xsl:message>Verbatim raw processing doesn’t support line numbering</xsl:message>
      </xsl:if>
      <xsl:call-template name="tp:verbatim-raw">
        <xsl:with-param name="highlight" select="$highlight"/>
        <xsl:with-param name="trim-trailing" select="$trim-trailing"/>
        <xsl:with-param name="numbered" select="$numbered"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message expand-text="yes">Unrecognized verbatim-style: {$style}</xsl:message>
      <xsl:call-template name="tp:verbatim-plain">
        <xsl:with-param name="highlight" select="$highlight"/>
        <xsl:with-param name="numbered" select="$numbered"/>
        <xsl:with-param name="trim-trailing" select="$trim-trailing"/>
        <xsl:with-param name="inject" select="$inject"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="tp:verbatim-plain" as="element()">
  <xsl:param name="highlight" as="xs:string*" required="yes"/>
  <xsl:param name="numbered" as="xs:boolean" required="yes"/>
  <xsl:param name="trim-trailing" as="xs:boolean" required="yes"/>
  <xsl:param name="inject" as="array(*)?" select="()"/>

  <xsl:variable name="lines" as="array(*)">
    <xsl:call-template name="tp:verbatim-array">
      <xsl:with-param name="highlight" select="$highlight"/>
      <xsl:with-param name="numbered" select="$numbered"/>
      <xsl:with-param name="trim-trailing" select="$trim-trailing"/>
      <xsl:with-param name="inject" select="$inject"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="body" as="item()*">
    <xsl:for-each select="1 to array:size($lines)">
      <xsl:if test="position() gt 1">
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <xsl:for-each select="$lines(.)">
        <xsl:call-template name="tp:filter-callouts">
          <xsl:with-param name="highlight" select="$highlight"/>
          <xsl:with-param name="line" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>

  <div class="pre-wrap">
    <pre>
      <xsl:apply-templates select="." mode="m:attributes">
        <xsl:with-param name="style" select="'plain'"/>
        <xsl:with-param name="numbered" select="$numbered"/>
      </xsl:apply-templates>

      <xsl:copy-of select="@xml:space"/>
      <xsl:choose>
        <xsl:when test="self::db:address or self::db:literallayout">
          <xsl:sequence select="$body"/>
        </xsl:when>
        <xsl:otherwise>
          <code><xsl:sequence select="$body"/></code>
        </xsl:otherwise>
      </xsl:choose>
    </pre>
  </div>
</xsl:template>

<xsl:template name="tp:verbatim-raw" as="element()">
  <xsl:param name="highlight" as="xs:string*" required="yes"/>
  <xsl:param name="numbered" as="xs:boolean" required="yes"/>
  <xsl:param name="trim-trailing" as="xs:boolean" required="yes"/>

  <xsl:variable name="body" as="item()*">
    <xsl:apply-templates/>
  </xsl:variable>

  <div class="pre-wrap">
    <pre>
      <xsl:apply-templates select="." mode="m:attributes">
        <xsl:with-param name="style" select="'raw'"/>
        <xsl:with-param name="numbered" select="$numbered"/>
      </xsl:apply-templates>

      <xsl:choose>
        <xsl:when test="self::db:address or self::db:literallayout">
          <xsl:sequence select="$body"/>
        </xsl:when>
        <xsl:otherwise>
          <code><xsl:sequence select="$body"/></code>
        </xsl:otherwise>
      </xsl:choose>
    </pre>
  </div>
</xsl:template>

<xsl:template name="tp:verbatim-table" as="element()">
  <xsl:param name="highlight" as="xs:string*" required="yes"/>
  <xsl:param name="numbered" as="xs:boolean" required="yes"/>
  <xsl:param name="trim-trailing" as="xs:boolean" required="yes"/>
  <xsl:param name="inject" as="array(*)?" select="()"/>

  <xsl:variable name="lines" as="array(*)">
    <xsl:call-template name="tp:verbatim-array">
      <xsl:with-param name="highlight" select="$highlight"/>
      <xsl:with-param name="numbered" select="$numbered"/>
      <xsl:with-param name="trim-trailing" select="$trim-trailing"/>
      <xsl:with-param name="inject" select="$inject"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="no-code"
                select="self::db:address or self::db:literallayout"/>

  <xsl:variable name="starting-line-number" as="xs:integer">
    <xsl:choose>
      <xsl:when test="@startinglinenumber">
        <xsl:sequence select="xs:integer(@startinglinenumber)"/>
      </xsl:when>
      <xsl:when test="@continuation = 'continues'">
        <xsl:variable name="name" select="node-name(.)"/>
        <xsl:variable name="prec" select="preceding::*[node-name(.) = $name][1]"/>
        <xsl:choose>
          <xsl:when test="empty($prec)">
            <xsl:sequence select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="formatted" as="element()">
              <xsl:apply-templates select="$prec"/>
            </xsl:variable>
            <xsl:sequence select="if ($formatted/@db-startinglinenumber
                                      and $formatted/@db-numberoflines)
                                  then
                                    xs:integer($formatted/@db-startinglinenumber)
                                    + xs:integer($formatted/@db-numberoflines)
                                  else
                                    1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="every-nth" as="xs:integer">
    <xsl:choose>
      <xsl:when test="f:pi(., 'linenumbering-everyNth',
                           fp:verbatim-properties(.)?everyNth)">
        <xsl:sequence
            select="xs:integer(f:pi(., 'linenumbering-everyNth',
                               fp:verbatim-properties(.)?everyNth))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$v:verbatim-number-every-nth"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="number-first" as="xs:boolean">
    <xsl:choose>
      <xsl:when test="f:pi(., 'linenumbering-first',
                           fp:verbatim-properties(.)?first)">
        <xsl:sequence
            select="f:is-true(f:pi(., 'linenumbering-first',
                                   fp:verbatim-properties(.)?first))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$v:verbatim-number-first-line"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="minlines" as="xs:integer">
    <xsl:choose>
      <xsl:when test="f:pi(., 'linenumbering-minlines',
                           fp:verbatim-properties(.)?minlines)">
        <xsl:sequence
            select="xs:integer(f:pi(., 'linenumbering-minlines',
                               fp:verbatim-properties(.)?minlines))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$v:verbatim-number-minlines"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="syntax-highlight"
                select="f:highlight-verbatim(.)"/>

  <div class="pre-wrap{if ($syntax-highlight) then ' highlight' else ''}">
    <xsl:if test="$numbered">
      <xsl:attribute name="db-startinglinenumber" select="$starting-line-number"/>
      <xsl:attribute name="db-numberoflines" select="array:size($lines)"/>
    </xsl:if>

    <xsl:variable name="numwidth"
                  select="string-length(string(array:size($lines) + $starting-line-number - 1))"/>

    <table class="verbatim">
      <tr>
        <td>
          <pre>
            <xsl:apply-templates select="." mode="m:attributes">
              <xsl:with-param name="style" select="'lines'"/>
              <xsl:with-param name="numbered" select="$numbered"/>
              <xsl:with-param name="long"
                              select="array:size($lines) ge $minlines"/>
            </xsl:apply-templates>

            <xsl:for-each select="1 to array:size($lines)">
              <xsl:variable name="index" select="."/>
              <xsl:variable name="ln" select=". + $starting-line-number - 1"/>
              <span class="line">
                <span class="ln">
                  <xsl:sequence 
                      select="fp:line-number($ln, $numwidth,
                                             ($numbered
                                               and (array:size($lines) ge $minlines)
                                                    and (($index = 1 and $number-first)
                                                         or ($ln mod $every-nth = 0))))"/>
                  <xsl:if test="$verbatim-number-separator != ''">
                    <span class="nsep">
                      <xsl:sequence select="$verbatim-number-separator"/>
                    </span>
                  </xsl:if>
                </span>
              </span>
              <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
          </pre>
        </td>
        <td>
          <pre>
            <xsl:apply-templates select="." mode="m:attributes">
              <xsl:with-param name="style" select="'lines'"/>
              <xsl:with-param name="numbered" select="$numbered"/>
              <xsl:with-param name="long"
                              select="array:size($lines) ge $minlines"/>
            </xsl:apply-templates>

            <xsl:for-each select="1 to array:size($lines)">
              <!-- Make sure blank lines contain at least one space so that
                   they don't get collapsed into oblivion by the renderer. -->
              <xsl:variable name="line"
                            select="if (count($lines(.)) = 1 and $lines(.) = '')
                                    then ' '
                                    else $lines(.)"/>
              <span class="line">
                <span class="ld"><xsl:sequence select="$line"/></span>
              </span>
              <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
          </pre>
        </td>
      </tr>
    </table>
  </div>
</xsl:template>

<xsl:template name="tp:verbatim-lines" as="element()">
  <xsl:param name="highlight" as="xs:string*" required="yes"/>
  <xsl:param name="numbered" as="xs:boolean" required="yes"/>
  <xsl:param name="trim-trailing" as="xs:boolean" required="yes"/>
  <xsl:param name="inject" as="array(*)?" select="()"/>

  <xsl:variable name="lines" as="array(*)">
    <xsl:call-template name="tp:verbatim-array">
      <xsl:with-param name="highlight" select="$highlight"/>
      <xsl:with-param name="numbered" select="$numbered"/>
      <xsl:with-param name="trim-trailing" select="$trim-trailing"/>
      <xsl:with-param name="inject" select="$inject"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="no-code"
                select="self::db:address or self::db:literallayout"/>

  <xsl:variable name="starting-line-number" as="xs:integer">
    <xsl:choose>
      <xsl:when test="@startinglinenumber">
        <xsl:sequence select="xs:integer(@startinglinenumber)"/>
      </xsl:when>
      <xsl:when test="@continuation = 'continues'">
        <xsl:variable name="name" select="node-name(.)"/>
        <xsl:variable name="prec" select="preceding::*[node-name(.) = $name][1]"/>
        <xsl:choose>
          <xsl:when test="empty($prec)">
            <xsl:sequence select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="formatted" as="element()">
              <xsl:apply-templates select="$prec"/>
            </xsl:variable>
            <xsl:sequence select="if ($formatted/@db-startinglinenumber
                                      and $formatted/@db-numberoflines)
                                  then
                                    xs:integer($formatted/@db-startinglinenumber)
                                    + xs:integer($formatted/@db-numberoflines)
                                  else
                                    1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="every-nth" as="xs:integer">
    <xsl:choose>
      <xsl:when test="f:pi(., 'linenumbering-everyNth',
                           fp:verbatim-properties(.)?everyNth)">
        <xsl:sequence
            select="xs:integer(f:pi(., 'linenumbering-everyNth',
                               fp:verbatim-properties(.)?everyNth))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$v:verbatim-number-every-nth"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="number-first" as="xs:boolean">
    <xsl:choose>
      <xsl:when test="f:pi(., 'linenumbering-first',
                           fp:verbatim-properties(.)?first)">
        <xsl:sequence
            select="f:is-true(f:pi(., 'linenumbering-first',
                                   fp:verbatim-properties(.)?first))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$v:verbatim-number-first-line"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="minlines" as="xs:integer">
    <xsl:choose>
      <xsl:when test="f:pi(., 'linenumbering-minlines',
                           fp:verbatim-properties(.)?minlines)">
        <xsl:sequence
            select="xs:integer(f:pi(., 'linenumbering-minlines',
                               fp:verbatim-properties(.)?minlines))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$v:verbatim-number-minlines"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="syntax-highlight"
                select="f:highlight-verbatim(.)"/>

  <div class="pre-wrap{if ($syntax-highlight) then ' highlight' else ''}">
    <xsl:if test="$numbered">
      <xsl:attribute name="db-startinglinenumber" select="$starting-line-number"/>
      <xsl:attribute name="db-numberoflines" select="array:size($lines)"/>
    </xsl:if>
    <pre>
      <xsl:apply-templates select="." mode="m:attributes">
        <xsl:with-param name="style" select="'lines'"/>
        <xsl:with-param name="numbered" select="$numbered"/>
        <xsl:with-param name="long"
                        select="array:size($lines) ge $minlines"/>
      </xsl:apply-templates>

      <xsl:variable name="numwidth"
                    select="string-length(string(array:size($lines) + $starting-line-number - 1))"/>

      <xsl:for-each select="1 to array:size($lines)">
        <!-- Make sure blank lines contain at least one space so that
             they don't get collapsed into oblivion by the renderer. -->
        <xsl:variable name="index" select="."/>
        <xsl:variable name="ln" select=". + $starting-line-number - 1"/>
        <xsl:variable name="line"
                      select="if (count($lines(.)) = 1 and $lines(.) = '')
                              then ' '
                              else $lines(.)"/>

        <xsl:variable name="callouts"
                      select="$line[. instance of element()
                                    and contains-token(@class, 'callout-bug')]"/>

        <xsl:variable name="line" as="item()*">
          <xsl:for-each select="$line">
            <xsl:call-template name="tp:filter-callouts">
              <xsl:with-param name="highlight" select="$highlight"/>
              <xsl:with-param name="line" select="."/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="classes" as="xs:string+">
          <xsl:sequence select="'line'"/>
          <xsl:if test="(('lines' = $highlight)
                         and $callouts[.[contains-token(@class, 'defcol')]])
                        or
                        (('lineranges' = $highlight
                          or 'lineranges-first' = $highlight
                          or 'lineranges-all' = $highlight)
                        and $callouts[.[contains-token(@class, 'linerange')]])">
            <xsl:sequence select="'highlight'"/>
            <xsl:sequence select="'line'||."/>
          </xsl:if>
        </xsl:variable>

        <span class="{string-join($classes,' ')}" db-line="{.}">
          <span class="ln">
            <xsl:sequence
                select="fp:line-number($ln, $numwidth,
                                       ($numbered
                                         and (array:size($lines) ge $minlines)
                                              and (($index = 1 and $number-first)
                                                   or ($ln mod $every-nth = 0))))"/>
            <xsl:if test="$verbatim-number-separator != ''">
              <span class="nsep">
                <xsl:sequence select="$verbatim-number-separator"/>
              </span>
            </xsl:if>
          </span>
          <span class="ld">
            <xsl:choose>
              <xsl:when test="$no-code">
                <xsl:sequence select="$line"/>
              </xsl:when>
              <xsl:otherwise>
                <code><xsl:sequence select="$line"/></code>
              </xsl:otherwise>
            </xsl:choose>
          </span>
        </span>
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </pre>
  </div>
</xsl:template>

<xsl:template name="tp:filter-callouts">
  <xsl:param name="highlight" as="xs:string*" required="yes"/>
  <xsl:param name="line" as="item()*" required="yes"/>

  <xsl:for-each select="$line">
    <xsl:choose>
      <xsl:when test=". instance of element()
                      and contains-token(@class, 'callout-bug')">
        <xsl:choose>
          <xsl:when test="'lineranges-first' = $highlight
                          and .[contains-token(@class, 'linerange')]">
            <xsl:sequence select="if (.[contains-token(@class, 'firstline')])
                                  then .
                                  else ()"/>
          </xsl:when>
          <xsl:when test="'lineranges-all' = $highlight
                          and .[contains-token(@class, 'linerange')]">
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:when test="'lines' = $highlight
                          and .[contains-token(@class, 'defcol')]">
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:when test="'linecolumn' = $highlight
                          and .[not(contains-token(@class, 'defcol'))
                                and not(contains-token(@class, 'linerange'))]">
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template name="tp:verbatim-array" as="array(*)">
  <xsl:param name="highlight" as="xs:string*" required="yes"/>
  <xsl:param name="numbered" as="xs:boolean" required="yes"/>
  <xsl:param name="trim-trailing" as="xs:boolean" required="yes"/>
  <xsl:param name="inject" as="array(*)?" select="()"/>

  <xsl:variable name="syntax-highlight"
                select="f:highlight-verbatim(.)"/>

  <xsl:variable name="formatted" as="node()*">
    <xsl:choose>
      <xsl:when test="$syntax-highlight">
        <xsl:variable name="options" as="map(xs:string,xs:string)">
          <xsl:apply-templates select="." mode="m:highlight-options"/>
        </xsl:variable>

        <xsl:variable name="pyoptions" as="map(xs:string,xs:string)">
          <xsl:apply-templates select="." mode="m:pygments-options"/>
        </xsl:variable>

        <xsl:sequence select="f:syntax-highlight(string(.),
                              map:merge(($v:verbatim-syntax-highlight-options, $options)),
                              map:merge(($v:verbatim-syntax-highlight-pygments-options, $pyoptions)))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="flattened">
    <xsl:apply-templates select="$formatted" mode="mp:flatten-markup"/>
  </xsl:variable>

  <xsl:variable name="lines" select="fp:make-lines($flattened/node(), $trim-trailing)"/>
  <xsl:variable name="lines" select="fp:balance-markup($lines)"/>

  <xsl:variable name="lines" select="if (exists($inject))
                                     then fp:inject-array($lines, $inject)
                                     else $lines"/>

  <xsl:variable name="lines" select="fp:unflatten($lines)"/>

  <xsl:sequence select="$lines"/>
</xsl:template>

<xsl:function name="f:highlight-verbatim" as="xs:boolean">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="'*' = $v:verbatim-syntax-highlight-languages
                        or string($node/@language)
                           = $v:verbatim-syntax-highlight-languages"/>
</xsl:function>

<xsl:template match="*" as="map(xs:string, xs:string)" mode="m:highlight-options">
  <xsl:map>
    <xsl:if test="@language">
      <xsl:map-entry key="'language'" select="string(@language)"/>
    </xsl:if>
  </xsl:map>
</xsl:template>

<xsl:template match="*" as="map(xs:string, xs:string)" mode="m:pygments-options">
  <xsl:variable name="pyattr"
                select="f:pi-attributes(processing-instruction('db-pygments'))"/>
  <xsl:map>
    <xsl:for-each select="$pyattr/@*">
      <xsl:map-entry key="local-name(.)" select="string(.)"/>
    </xsl:for-each>
  </xsl:map>
</xsl:template>

<xsl:function name="fp:inject-array" as="array(*)">
  <xsl:param name="lines" as="array(*)" required="yes"/>
  <xsl:param name="inject" as="array(*)" required="yes"/>

  <xsl:choose>
    <xsl:when test="array:size($inject) = 0">
      <xsl:sequence select="$lines"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="newlines" as="array(*)"
           select="fp:inject($lines, $inject(1)?item, $inject(1)?line, $inject(1)?column)"/>
      <xsl:sequence select="fp:inject-array($newlines, array:remove($inject, 1))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:make-lines" as="array(*)">
  <xsl:param name="body" as="node()*"/>
  <xsl:param name="trim-trailing" as="xs:boolean"/>

  <xsl:variable name="lines" select="fp:make-lines($body, (), [])"/>
  <xsl:sequence select="if ($trim-trailing)
                        then fp:trim-trailing-blank-lines($lines)
                        else $lines"/>
</xsl:function>

<xsl:function name="fp:trim-trailing-blank-lines">
  <xsl:param name="lines" as="array(*)"/>
  <xsl:variable name="last" select="array:size($lines)"/>
  <xsl:choose>
    <xsl:when test="$last gt 0
                    and count(array:get($lines, $last)) = 1
                    and normalize-space(array:get($lines, $last)) = ''">
      <xsl:sequence select="fp:trim-trailing-blank-lines(
                               array:remove($lines, $last))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$lines"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:make-lines" as="array(*)">
  <xsl:param name="body" as="node()*"/>
  <xsl:param name="curline" as="item()*"/>
  <xsl:param name="linearray" as="array(*)"/>

  <xsl:variable name="car" select="subsequence($body, 1, 1)"/>
  <xsl:variable name="cdr" select="subsequence($body, 2)"/>

  <xsl:choose>
    <xsl:when test="empty($body)">
      <xsl:sequence select="if (empty($curline))
                            then $linearray
                            else array:append($linearray, $curline)"/>
    </xsl:when>
    <xsl:when test="$car/self::text()">
      <xsl:choose>
        <xsl:when test="contains($car, '&#10;')">
          <xsl:variable name="lines" select="tokenize($car, '&#10;')"/>
          <xsl:variable name="first" select="subsequence($lines, 1, 1)"/>
          <xsl:variable name="last"
                        select="if (count($lines) = 1)
                                then ()
                                else subsequence($lines, count($lines), 1)"/>
          <xsl:variable name="middle"
                        select="if (count($lines) lt 3)
                                then ()
                                else subsequence($lines, 2, count($lines) - 2)"/>
          <xsl:variable name="arr" select="array:append($linearray, ($curline, $first))"/>
          <xsl:variable name="arr" select="fp:array-append($arr, $middle)"/>
          <xsl:sequence select="fp:make-lines($cdr, $last, $arr)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="fp:make-lines($cdr, ($curline, $car), $linearray)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fp:make-lines($cdr, ($curline, $car), $linearray)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:balance-markup">
  <xsl:param name="lines" as="array(*)"/>
  <xsl:sequence select="fp:balance-markup($lines, (), [])"/>
</xsl:function>

<xsl:function name="fp:balance-markup">
  <xsl:param name="lines" as="array(*)"/>
  <xsl:param name="open" as="element()*"/>
  <xsl:param name="balanced" as="array(*)"/>

  <xsl:choose>
    <xsl:when test="array:size($lines) = 0">
      <xsl:sequence select="$balanced"/>
    </xsl:when>
    <xsl:otherwise>

      <!--
      <xsl:message>-OPEN: <xsl:sequence select="$open/@g:id/string()"/></xsl:message>
      <xsl:message> LINE: <xsl:sequence select="$lines(1)"/></xsl:message>
      -->

      <xsl:variable name="line" select="fp:balance-line($open, $lines(1))"/>

      <!--
      <xsl:message> BLNC: <xsl:sequence select="$line"/></xsl:message>
      -->

      <xsl:variable name="open" select="fp:open($open, ($open, $lines(1)))"/>

      <!--
      <xsl:message>+OPEN: <xsl:sequence select="$open/@g:id/string()"/></xsl:message>
      -->

      <xsl:sequence select="fp:balance-markup(array:remove($lines, 1),
                                              $open,
                                              array:append($balanced, $line))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:balance-line" as="item()*">
  <xsl:param name="open" as="element()*"/>
  <xsl:param name="line" as="item()*"/>

  <xsl:variable name="newline" as="item()*">
    <xsl:sequence select="$open"/>
    <xsl:sequence select="$line"/>
  </xsl:variable>

  <xsl:variable name="opened"
       select="$newline[. instance of element() and @g:id and not(@g:virtual)]"/>

  <xsl:variable name="closed"
       select="$newline[. instance of element()]/@g:start/string()"/>

  <!--
  <xsl:message> oped: <xsl:sequence select="$opened"/></xsl:message>
  <xsl:message> cled: <xsl:sequence select="$closed"/></xsl:message>
  -->

  <xsl:variable name="still-open" as="element()*">
    <xsl:for-each select="$open">
      <xsl:if test="not(@g:id = $closed)">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="$opened">
      <xsl:if test="not(@g:id = $closed)">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!--
  <xsl:message> BSTL: <xsl:sequence select="$still-open/@g:id/string()"/></xsl:message>
  -->

  <xsl:sequence select="$newline"/>
  <xsl:for-each select="reverse($still-open)">
    <xsl:element name="{node-name(.)}" namespace="{namespace-uri(.)}">
      <xsl:attribute name="g:start" select="@g:id"/>
      <xsl:attribute name="g:virtual" select="'true'"/>
    </xsl:element>
  </xsl:for-each>
</xsl:function>

<xsl:function name="fp:open" as="element()*">
  <xsl:param name="open" as="element()*"/>
  <xsl:param name="line" as="item()*"/>

  <xsl:variable name="closed"
       select="$line[. instance of element()]/@g:start/string()"/>

  <!--
  <xsl:message> CLOS: <xsl:sequence select="$closed"/></xsl:message>
  -->

  <xsl:variable name="still-open" as="element()*">
    <xsl:for-each select="$open">
      <xsl:if test="not(@g:id = $closed)">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!--
  <xsl:message> STIL: <xsl:sequence select="$still-open"/></xsl:message>
  -->

  <xsl:variable name="new-open" as="element()*">
    <xsl:for-each select="$line[. instance of element()
                                and @g:id
                                and not(@g:virtual)]">
      <xsl:if test="not(@g:id = $closed)">
        <xsl:element name="{node-name(.)}" namespace="{namespace-uri(.)}">
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="g:virtual" select="'true'"/>
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:sequence select="($still-open, $new-open)"/>
</xsl:function>

<xsl:function name="fp:unflatten" as="array(*)">
  <xsl:param name="lines" as="array(*)"/>
  <xsl:sequence select="fp:unflatten($lines, [])"/>
</xsl:function>

<xsl:function name="fp:unflatten" as="array(*)">
  <xsl:param name="lines" as="array(*)"/>
  <xsl:param name="newlines" as="array(*)"/>

  <xsl:choose>
    <xsl:when test="array:size($lines) = 0">
      <xsl:sequence select="$newlines"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="line"
                    select="fp:unflatten-line(array:get($lines,1))"/>
      <xsl:sequence select="fp:unflatten(array:remove($lines, 1),
                                         array:append($newlines, $line))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:unflatten-line" as="item()*">
  <xsl:param name="line" as="item()*"/>
  <!--
  <xsl:message>UNFLAT: <xsl:sequence select="$line"/></xsl:message>
  -->
  <xsl:sequence select="fp:unflatten-line($line, ())"/>
</xsl:function>

<xsl:function name="fp:unflatten-line" as="item()*">
  <xsl:param name="line" as="item()*"/>
  <xsl:param name="newline" as="item()*"/>

  <!--
  <xsl:message>LINE: <xsl:sequence select="$line"/></xsl:message>
  -->

  <xsl:choose>
    <xsl:when test="empty($line)">
      <xsl:sequence select="$newline"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="car" select="subsequence($line, 1, 1)"/>
      <xsl:variable name="cdr" select="subsequence($line, 2)"/>

      <!--
      <xsl:message>CAR: <xsl:sequence select="$car"/></xsl:message>
      <xsl:message>CDR: <xsl:sequence select="$cdr"/></xsl:message>
      -->

      <xsl:choose>
        <xsl:when test="$car instance of element()
                        and $car[@g:id]">
          <xsl:variable name="id" select="$car/@g:id"/>
          <!-- injecting items may have created more than one
               element with the same g:start value; we always
               want the "nearest" one.
          -->

          <!--
          <xsl:message>ID: <xsl:value-of select="$id"/></xsl:message>
          -->

          <xsl:variable name="rest"
                        select="if (fp:contains($line, $id))
                                then fp:following($line, $id)
                                else ()"/>
          <xsl:variable name="nodes"
                        select="if (fp:contains($line, $id))
                                then fp:up-to($cdr, $id)
                                else ()"/>

          <!--
          <xsl:message>REST: <xsl:value-of select="count($rest)"/>: <xsl:sequence select="$rest"/></xsl:message>
          <xsl:message>NODS: <xsl:value-of select="count($nodes)"/>: <xsl:sequence select="$nodes"/></xsl:message>
          -->

          <xsl:variable name="unflat" as="element()">
            <xsl:element name="{node-name($car)}"
                         namespace="{namespace-uri($car)}">
              <xsl:copy-of select="$car/@* except ($car/@g:*|$car/@id)"/>
              <xsl:if test="not($car/@g:virtual)">
                <xsl:copy-of select="$car/@id"/>
              </xsl:if>
              <xsl:sequence select="fp:unflatten-line($nodes)"/>
            </xsl:element>
          </xsl:variable>
          <xsl:sequence select="fp:unflatten-line($rest,
                                                  ($newline, $unflat))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="fp:unflatten-line($cdr, ($newline, $car))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:contains" as="xs:boolean">
  <xsl:param name="line" as="item()*"/>
  <xsl:param name="id" as="xs:string"/>
  <xsl:variable name="found" as="element()*">
    <xsl:for-each select="$line">
      <xsl:if test=". instance of element()
                    and @g:start = $id">
        <xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:sequence select="exists($found)"/>
</xsl:function>

<xsl:function name="fp:up-to">
  <xsl:param name="line" as="item()*"/>
  <xsl:param name="id" as="xs:string"/>

  <xsl:variable name="car" select="subsequence($line, 1, 1)"/>
  <xsl:variable name="cdr" select="subsequence($line, 2)"/>

  <xsl:choose>
    <xsl:when test="empty($line)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:when test="$car instance of element()
                    and $car/@g:start = $id">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="($car, fp:up-to($cdr, $id))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:following">
  <xsl:param name="line" as="item()*"/>
  <xsl:param name="id" as="xs:string"/>

  <xsl:variable name="car" select="subsequence($line, 1, 1)"/>
  <xsl:variable name="cdr" select="subsequence($line, 2)"/>

  <xsl:choose>
    <xsl:when test="empty($line)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:when test="$car instance of element()
                    and $car/@g:start = $id">
      <xsl:sequence select="$cdr"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fp:following($cdr, $id)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:array-append">
  <!-- Surely there must be a better way? -->
  <xsl:param name="array" as="array(*)"/>
  <xsl:param name="seq" as="item()*"/>
  <xsl:sequence
      select="if (empty($seq))
                  then $array
                  else fp:array-append(array:append($array, subsequence($seq, 1, 1)),
                                       subsequence($seq, 2))"/>
</xsl:function>

<xsl:function name="fp:inject" as="array(*)">
  <xsl:param name="lines" as="array(*)"/>
  <xsl:param name="item" as="item()"/>
  <xsl:param name="lineno" as="xs:integer"/>
  <xsl:param name="colno" as="xs:integer"/>

  <xsl:variable name="lines"
                select="if (array:size($lines) ge $lineno)
                        then $lines
                        else fp:array-pad($lines, $lineno)"/>

  <xsl:sequence
      select="fp:replace-element($lines, $lineno,
                 fp:inject-into-line($lines($lineno), $item, $colno))"/>
</xsl:function>

<xsl:function name="fp:array-pad">
  <xsl:param name="lines" as="array(*)"/>
  <xsl:param name="lineno" as="xs:integer"/>

  <xsl:choose>
    <xsl:when test="array:size($lines) ge $lineno">
      <xsl:sequence select="$lines"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fp:array-pad(array:append($lines, ''), $lineno)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:inject-into-line" as="item()*">
  <xsl:param name="line" as="item()*"/>
  <xsl:param name="item" as="item()"/>
  <xsl:param name="colno" as="xs:integer"/>

  <xsl:if test="$colno lt 0">
    <xsl:sequence select="error()"/>
  </xsl:if>

  <xsl:sequence
      select="fp:inject-into-chars(fp:line-to-chars($line), $item, $colno, 0, ())"/>
</xsl:function>

<xsl:function name="fp:inject-into-chars" as="item()*">
  <xsl:param name="chars" as="item()*"/>
  <xsl:param name="item" as="item()"/>
  <xsl:param name="colno" as="xs:integer"/>
  <xsl:param name="pos" as="xs:integer"/>
  <xsl:param name="open" as="element()*"/>

  <xsl:choose>
    <xsl:when test="$pos + 1 eq $colno">
      <xsl:for-each select="reverse($open)">
        <xsl:element name="{node-name(.)}" namespace="{namespace-uri(.)}">
          <xsl:attribute name="g:start" select="@g:id"/>
          <xsl:attribute name="g:virtual" select="'true'"/>
        </xsl:element>
      </xsl:for-each>
      <xsl:sequence select="$item"/>

      <xsl:for-each select="$open">
        <xsl:element name="{node-name(.)}" namespace="{namespace-uri(.)}">
          <xsl:attribute name="g:id" select="@g:id"/>
          <xsl:attribute name="g:virtual" select="'true'"/>
        </xsl:element>
      </xsl:for-each>
      <xsl:sequence select="$chars"/>
    </xsl:when>
    <xsl:when test="empty($chars)">
      <xsl:sequence
          select="($v:verbatim-space,
                   fp:inject-into-chars((), $item, $colno, $pos+1, $open))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="car" select="subsequence($chars, 1, 1)"/>
      <xsl:variable name="cdr" select="subsequence($chars, 2)"/>
      <xsl:choose>
        <xsl:when test="$car/self::text() and $car = $v:invisible-characters">
          <xsl:sequence
              select="($car, fp:inject-into-chars($cdr, $item, $colno, $pos, $open))"/>
        </xsl:when>
        <xsl:when test="$car/self::text()">
          <xsl:sequence
              select="($car, fp:inject-into-chars($cdr, $item, $colno, $pos+1, $open))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="open" as="element()*"
                        select="if ($car/@g:start)
                                then subsequence($open, 1, count($open) - 1)
                                else ($open, $car)"/>
          <xsl:sequence
              select="($car, fp:inject-into-chars($cdr, $item, $colno, $pos, $open))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:line-to-chars" as="item()*">
  <xsl:param name="line" as="item()*"/>
  <xsl:choose>
    <xsl:when test="empty($line)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="car" select="subsequence($line, 1, 1)"/>
      <xsl:variable name="cdr" select="subsequence($line, 2)"/>
      <xsl:choose>
        <xsl:when test="$car instance of xs:string or $car/self::text()">
          <xsl:for-each select="1 to string-length($car)">
            <!-- Use value-of so that they're text nodes -->
            <xsl:value-of select="substring($car, ., 1)"/>
          </xsl:for-each>
          <xsl:sequence select="fp:line-to-chars($cdr)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="($car, fp:line-to-chars($cdr))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:injection-array" as="array(*)?">
  <xsl:param name="inject" as="item()?"/>

  <xsl:choose>
    <xsl:when test="empty($inject)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:when test="$inject instance of array(*)">
      <xsl:sequence select="fp:validate-injection-array($inject)"/>
    </xsl:when>
    <xsl:when test="$inject instance of element(db:areaspec)">
      <xsl:variable name="maps" as="map(*)*">
        <xsl:apply-templates select="$inject/*" mode="mp:inj-map"/>
      </xsl:variable>
      <xsl:sequence select="fp:validate-injection-array(array { $maps })"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="error($dbe:INVALID-INJECT, 
                                 'Invalid type for $inject', $inject)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:template match="db:area" mode="mp:inj-map">
  <xsl:if test="@units and not(@units = ('linecolumn', 'linerange'))">
    <xsl:sequence select="error($dbe:INVALID-INJECT, 
                                'Invalid callout area: '
                                || @units || ' unsupported.')"/>
  </xsl:if>

  <xsl:variable name="coords"
                select="tokenize(normalize-space(@coords))"/>

  <xsl:if test="count($coords) lt 1 or count($coords) gt 2">
    <xsl:sequence select="error($dbe:INVALID-INJECT, 
                                'Invalid callout area: unparseable coordinates')"/>
  </xsl:if>

  <xsl:variable name="line" select="$coords[1]"/>
  <xsl:variable name="column" select="if (count($coords) gt 1
                                          and not(@units = 'linerange'))
                                      then $coords[2]
                                      else $callout-default-column"/>

  <xsl:variable name="content" as="node()+">
    <xsl:apply-templates select="." mode="mp:callout-in-verbatim">
      <xsl:with-param name="line" select="$line"/>
      <xsl:with-param name="column" select="$column"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="@units = 'linerange'">
      <xsl:variable name="fline" select="xs:integer($coords[1])"/>
      <xsl:variable name="lline" select="if ($coords[2])
                                         then xs:integer($coords[2])
                                         else $fline"/>
      <xsl:variable name="firstcontent" as="element()">
        <xsl:element name="span" namespace="http://www.w3.org/1999/xhtml">
          <xsl:copy-of select="$content/@* except $content/@class"/>
          <xsl:attribute name="class"
                         select="concat($content/@class, ' firstline')"/>
          <xsl:copy-of select="$content/node()"/>
        </xsl:element>
      </xsl:variable>

      <xsl:for-each select="$fline to $lline">
        <xsl:sequence select="map { 'line': .,
                                    'linerange': true(),
                                    'column': $column,
                                    'item': if (. = $fline)
                                            then $firstcontent
                                            else $content }"/>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="map { 'line': $line,
                                  'column': $column,
                                  'item': $content }"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:areaset" mode="mp:inj-map">
  <xsl:apply-templates mode="mp:inj-map"/>
</xsl:template>

<xsl:template match="*" mode="mp:inj-map">
  <xsl:sequence select="error($dbe:INVALID-INJECT, 
                              'Invalid type for $inject: '
                              || local-name(.))"/>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()"
              mode="mp:inj-map"/>

<xsl:template match="db:co">
  <a>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:callout-bug"/>
  </a>
</xsl:template>

<xsl:template match="db:co" mode="m:callout-bug">
  <xsl:variable name="conum">
    <xsl:choose>
      <xsl:when test="@label and @label castable as xs:decimal">
        <xsl:sequence select="@label"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:number count="db:co"
                    level="any"
                    format="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="codepoints-to-string($callout-unicode-start + xs:integer($conum))"/>
</xsl:template>

<xsl:template match="db:coref">
  <xsl:variable name="coid" as="xs:string?">
    <xsl:choose>
      <xsl:when test="@linkend">
        <xsl:sequence select="@linkend/string()"/>
      </xsl:when>
      <xsl:when test="@xlink:href[starts-with(., '#')]">
        <xsl:sequence select="substring(@xlink:href, 2)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="empty($coid)">
      <xsl:message>Cannot find callout ID on coref</xsl:message>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="co" select="key('id', $coid)"/>
      <xsl:if test="count($co) gt 1">
        <xsl:message>Callout ID on coref is not unique: <xsl:sequence select="$coid"/></xsl:message>
      </xsl:if>
      <xsl:variable name="co" select="$co[1]"/>
      <xsl:choose>
        <xsl:when test="empty($co)">
          <xsl:message>Callout ID on coref does not exist: <xsl:sequence select="$coid"/></xsl:message>
          <xsl:call-template name="t:inline"/>
        </xsl:when>
        <xsl:when test="not($co/self::db:co)">
          <xsl:message>
            <xsl:text>Callout ID on coref does not point to a co: </xsl:text>
            <xsl:sequence select="$coid"/>
          </xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$co"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:areaspec" mode="m:callout-bug" as="xs:integer">
  <xsl:param name="continues" as="xs:boolean" select="false()"/>

  <xsl:variable name="starting-pi"
                select="f:pi(., 'starting-callout-number')"/>

  <xsl:variable name="start-at-start" as="xs:integer">
    <xsl:choose>
      <xsl:when test="empty($starting-pi)">
        <xsl:sequence select="1"/>
      </xsl:when>
      <xsl:when test="$starting-pi[1] castable as xs:integer">
        <xsl:sequence select="$starting-pi[1] cast as xs:integer"/>
      </xsl:when>
      <xsl:when test="$starting-pi[1] = 'continues' and preceding::db:areaspec">
        <xsl:apply-templates select="preceding::db:areaspec[1]" mode="m:callout-bug">
          <xsl:with-param name="continues" select="true()"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$starting-pi[1] = 'continues'">
        <xsl:sequence select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="'Unsupported starting-callout-number: ', $starting-pi"/>
        <xsl:sequence select="1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:sequence select="if ($continues)
                        then $start-at-start + count(*)
                        else $start-at-start"/>
</xsl:template>

<xsl:template match="db:area" mode="m:callout-bug">
  <xsl:variable name="start-co-number" as="xs:integer">
    <xsl:apply-templates select="ancestor::db:areaspec[1]" mode="m:callout-bug"/>
  </xsl:variable>

  <xsl:variable name="num"
                select="if (parent::db:areaset)
                        then count(parent::*/preceding-sibling::*) + $start-co-number
                        else count(preceding-sibling::*) + $start-co-number"/>
  <xsl:value-of select="codepoints-to-string(9311 + $num)"/>
</xsl:template>

<xsl:template match="db:area" mode="mp:callout-in-verbatim">
  <xsl:param name="line" select="()"/>
  <xsl:param name="column" select="()"/>

  <xsl:variable name="class" as="xs:string+">
    <xsl:sequence select="'callout-bug'"/>
    <xsl:sequence select="if (@otherunits)
                          then 'other ' || @otherunits
                          else if (@units)
                               then @units
                               else 'linecolumn'"/>
    <xsl:sequence select="if ((not(@units) or @units='linecolumn')
                              and count(tokenize(@coords)) ne 2)
                          then 'defcol'
                          else ()"/>
  </xsl:variable>

  <a id="{ if (parent::db:areaset and empty(preceding-sibling::*))
           then f:generate-id(parent::*)
           else f:generate-id(.) }"
     class="{ string-join($class, ' ') }">
    <xsl:if test="@linkends">
      <xsl:attribute name="href"
                     select="'#' || tokenize(normalize-space(@linkends), '\s+')[1]"/>
    </xsl:if>
    <xsl:if test="exists($line)">
      <xsl:attribute name="db-line" select="$line"/>
    </xsl:if>
    <xsl:if test="exists($column)">
      <xsl:attribute name="db-column" select="$column"/>
    </xsl:if>
    <xsl:if test="db:alt">
      <xsl:attribute name="title" select="string(db:alt)"/>
    </xsl:if>
    <xsl:apply-templates select="." mode="m:callout-bug"/>
  </a>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="fp:validate-injection-array" as="array(*)">
  <xsl:param name="array" as="array(*)"/>

  <xsl:variable name="valid-maps" as="map(*)*">
    <xsl:for-each select="1 to array:size($array)">
      <xsl:variable name="map" select="$array(.)"/>
      <xsl:if test="empty($map?line)
                    or empty($map?column)
                    or empty($map?item)
                    or not($map?line castable as xs:integer)
                    or not($map?column castable as xs:integer)">
        <xsl:sequence select="error($dbe:INVALID-INJECT, 
                                    'Invalid map in $inject', $map)"/>
      </xsl:if>
      <xsl:sequence select="map { 'line': xs:integer($map?line),
                                  'column': xs:integer($map?column),
                                  'item': $map?item }"/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="sorted-maps" as="map(*)*">
    <xsl:for-each select="$valid-maps">
      <xsl:sort select=".?line" order="descending"/>
      <xsl:sort select=".?column" order="descending"/>
      <xsl:sequence select="."/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:sequence select="array { $sorted-maps }"/>
</xsl:function>

<!-- ============================================================ -->

<xsl:template match="element()" mode="mp:flatten-markup">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="g:id" select="generate-id(.)"/>
  </xsl:copy>
  <xsl:apply-templates select="node()" mode="mp:flatten-markup"/>
  <xsl:copy>
    <xsl:attribute name="g:start" select="generate-id(.)"/>
    <xsl:attribute name="g:virtual" select="'true'"/>
  </xsl:copy>
</xsl:template>

<!-- Don't flatten footnotes, they get rendered out-of-line -->
<xsl:template match="h:db-footnote" mode="mp:flatten-markup">
  <xsl:copy>
    <xsl:sequence select="@*,node()"/>
  </xsl:copy>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="attribute()|text()|comment()|processing-instruction()"
              mode="mp:flatten-markup">
  <xsl:copy/>
</xsl:template>

<xsl:function name="fp:verbatim-properties" as="map(*)">
  <xsl:param name="context" as="element()"/>

  <xsl:variable name="style"
                select="fp:properties($context, $v:verbatim-properties)"/>

  <xsl:sequence
      select="if (empty($style))
              then map { 'style': $verbatim-style-default,
                         'numbered': (local-name($context) = $v:verbatim-numbered-elements),
                         'highlight': $v:verbatim-callouts }
              else $style"/>
</xsl:function>

<xsl:function name="f:verbatim-style" as="xs:string">
  <xsl:param name="context" as="element()"/>
  <xsl:choose>
    <xsl:when test="$verbatim-syntax-highlighter != 'pygments'">
      <xsl:sequence select="'raw'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence
          select="f:pi($context, 'verbatim-style',
                       fp:verbatim-properties($context)?style)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:verbatim-highlight" as="xs:string*">
  <xsl:param name="context" as="element()"/>

  <!-- If we aren't using Pygments, or if there's a PI that explicitly
       selects plain formatting, disable highlighting automatically.
       This avoids a warning about highlighting not being supported.
  -->
  <xsl:variable name="value" as="xs:string*"
      select="if ($verbatim-syntax-highlighter != 'pygments'
                  or f:pi($context, 'verbatim-style') = 'plain')
              then ()
              else f:pi($context, 'verbatim-highlight',
                        fp:verbatim-properties($context)?highlight)"/>

  <xsl:for-each select="$value">
    <xsl:sequence select="if (contains(., ','))
                          then tokenize(., ',\s*') ! normalize-space(.)
                          else ."/>
  </xsl:for-each>
</xsl:function>

<xsl:function name="f:verbatim-numbered" as="xs:boolean">
  <xsl:param name="context" as="element()"/>

  <xsl:choose>
    <xsl:when test="$verbatim-syntax-highlighter != 'pygments'">
      <xsl:sequence select="false()"/>
    </xsl:when>
    <xsl:when test="$context/@linenumbering">
      <xsl:sequence select="$context/@linenumbering = 'numbered'"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="pi" select="f:pi($context, 'verbatim-numbered')"/>
      <!-- If there's a PI that explicitly selects plain formatting,
           disable numbering automatically. This avoids a warning
           about numbering not being supported. -->
      <xsl:sequence select="if (f:pi($context, 'verbatim-style') = 'plain')
                            then false()
                            else if ($pi)
                                 then f:is-true($pi)
                                 else fp:verbatim-properties($context)?numbered = true()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:verbatim-trim-trailing" as="xs:boolean">
  <xsl:param name="context" as="element()"/>
  <xsl:variable name="pi" select="f:pi($context, 'verbatim-trim-trailing')"/>
  <xsl:sequence select="if ($pi)
                        then f:is-true($pi)
                        else f:is-true($verbatim-trim-trailing-blank-lines)"/>
</xsl:function>

<xsl:function name="fp:line-number" as="xs:string">
  <xsl:param name="ln" as="xs:integer"/>
  <xsl:param name="width" as="xs:integer"/>
  <xsl:param name="display" as="xs:boolean"/>

  <!-- Padding for numbers in line numbering -->
  <xsl:variable name="vp:padding" select="'                        '"/>

  <xsl:choose>
    <xsl:when test="$display">
      <xsl:sequence select="substring($vp:padding, 1, $width - string-length(string($ln)))
                            || $ln
                            || substring($vp:padding, 1, 1)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="substring($vp:padding, 1, $width + 1)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>
