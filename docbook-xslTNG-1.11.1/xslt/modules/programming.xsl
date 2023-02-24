<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db dbe f m t tp v xs"
                version="3.0">

<xsl:template match="db:productionset">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <div class="productions">
      <xsl:apply-templates/>
    </div>
  </div>
</xsl:template>

<xsl:template match="db:production">
  <xsl:param name="recap" select="false()"/>
  <xsl:apply-templates select="db:lhs">
    <xsl:with-param name="recap" select="$recap"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:productionrecap[@linkend]">
  <xsl:variable name="prod" select="key('id', @linkend)"/>
  <xsl:choose>
    <xsl:when test="empty($prod)">
      <xsl:message select="'Failed to find production: ' || @linkend"/>
    </xsl:when>
    <xsl:when test="$prod/self::db:production">
      <xsl:apply-templates select="$prod">
        <xsl:with-param name="recap" select="true()"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="error($dbe:INVALID-PRODUCTIONRECAP,
                                  'Not a production: ' || @linkend)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:lhs">
  <xsl:param name="recap" select="false()"/>
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <span class="lhs">
      <xsl:apply-templates select=".." mode="m:production-number">
        <xsl:with-param name="recap" select="$recap"/>
      </xsl:apply-templates>
      <xsl:apply-templates/>
    </span>
    <span class="lhssep lhs1sep">
      <xsl:sequence select="$productionset-lhs-rhs-separator"/>
    </span>
    <xsl:apply-templates select="(following-sibling::db:rhs)[1]"/>
  </div>
  <xsl:apply-templates
      select="(following-sibling::db:rhs)[1]/following-sibling::db:rhs"/>
</xsl:template>

<xsl:template match="db:production" mode="m:production-number">
  <xsl:param name="recap" select="false()"/>
  <span class="number">
    <xsl:if test="not($recap)">
      <xsl:attribute name="id" select="f:generate-id(.)"/>
    </xsl:if>
    <xsl:text>[</xsl:text>
    <xsl:number from="/" level="any"/>
    <xsl:text>] </xsl:text>
  </span>
</xsl:template>

<!-- the first rhs -->
<xsl:template match="db:rhs[not(preceding-sibling::db:rhs)]"
              priority="10">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>
  <span class="constraint">
    <xsl:apply-templates select="../db:constraint"/>
  </span>
</xsl:template>

<!-- all the other rhs -->
<xsl:template match="db:rhs">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <span class="lhs ghost"></span>
    <span class="lhssep"></span>
    <span class="rhs">
      <xsl:apply-templates/>
    </span>
    <span class="constraint"></span>
  </div>
</xsl:template>

<xsl:template match="db:constraint[@linkend]">
  <xsl:variable name="cons" select="key('id', @linkend)"/>
  <xsl:choose>
    <xsl:when test="empty($cons)">
      <xsl:message select="'Failed to find constraint: ' || @linkend"/>
    </xsl:when>
    <xsl:when test="$cons/self::db:constraintdef">
      <a href="#{@linkend}">
        <xsl:sequence select="@linkend/string()"/>
      </a>
      <xsl:text> </xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="error($dbe:INVALID-CONSTRAINT,
                                  'Not a constraintdef: ' || @linkend)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:lineannotation">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="db:sbr">
  <br/>
</xsl:template>

<xsl:template match="db:nonterminal">
  <a href="{@def}">
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </a>
</xsl:template>

<xsl:template match="db:constraintdef">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:funcsynopsis">
  <xsl:variable name="style"
                select="f:pi(., 'funcsynopsis-style', $funcsynopsis-default-style)"/>
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>

    <xsl:choose>
      <xsl:when test="$style = 'kr'">
        <xsl:apply-templates mode="m:kr"/>
      </xsl:when>
      <xsl:when test="$style = 'ansi'">
        <xsl:apply-templates mode="m:ansi"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="'Unrecognized funcsynopsis style: ' || $style"/>
        <xsl:apply-templates mode="m:kr"/>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="element()" mode="m:kr">
  <xsl:message
      select="'Unexpected funcsynopsis element in kr: ' || node-name(.)"/>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr"/>
  </span>
</xsl:template>

<xsl:template match="db:funcsynopsisinfo" mode="m:kr">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="db:funcprototype" mode="m:kr">
  <xsl:variable name="width"
                select="sum(.//text() ! string-length(normalize-space(.)))"/>

  <xsl:choose>
    <xsl:when test="$width gt $funcsynopsis-table-threshold">
      <xsl:apply-templates select="." mode="m:kr-table"/>
    </xsl:when>
    <xsl:otherwise>
      <div>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <div>
          <xsl:apply-templates select="db:funcdef" mode="m:kr"/>
          <span class="arglist">
            <xsl:text>(</xsl:text>
            <xsl:apply-templates select="db:funcdef/following-sibling::*" mode="m:kr-args"/>
            <xsl:text>)</xsl:text>
            <xsl:sequence select="$funcsynopsis-trailing-punctuation"/>
          </span>
        </div>
        <xsl:apply-templates select="db:funcdef/following-sibling::*" mode="m:kr"/>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:funcdef" mode="m:kr">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr"/>
  </span>
</xsl:template>

<xsl:template match="db:type" mode="m:kr">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr"/>
  </span>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="db:function" mode="m:kr">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr"/>
  </span>
</xsl:template>

<xsl:template match="db:void" mode="m:kr-args">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
  </span>
</xsl:template>

<xsl:template match="db:varargs" mode="m:kr-args">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:text>...</xsl:text>
  </span>
</xsl:template>

<xsl:template match="db:paramdef" mode="m:kr-args">
  <span>
    <xsl:apply-templates select="db:parameter" mode="m:kr-args"/>
    <xsl:if test="following-sibling::db:paramdef">
      <span>, </span>
    </xsl:if>
  </span>
</xsl:template>

<xsl:template match="db:parameter" mode="m:kr-args">
  <span class="{local-name(.)}">
    <xsl:apply-templates mode="m:kr"/>
  </span>
</xsl:template>

<xsl:template match="db:void" mode="m:kr"/>
<xsl:template match="db:varargs" mode="m:kr"/>

<xsl:template match="db:paramdef" mode="m:kr">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr"/>
    <xsl:text>;</xsl:text>
  </div>
</xsl:template>

<xsl:template match="db:parameter" mode="m:kr">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr"/>
  </span>
</xsl:template>

<xsl:template match="db:funcparams" mode="m:kr">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr"/>
  </span>
</xsl:template>

<xsl:template match="text()" mode="m:kr">
  <xsl:sequence select="if (normalize-space(.) = '')
                        then ()
                        else ."/>
</xsl:template>

<xsl:template match="comment()|processing-instruction()" mode="m:kr"/>
<xsl:template match="attribute()" mode="m:kr">
  <xsl:copy/>
</xsl:template>

<xsl:template match="text()" mode="m:kr-args">
  <xsl:sequence select="if (normalize-space(.) = '')
                        then ()
                        else ."/>
</xsl:template>

<xsl:template match="comment()|processing-instruction()" mode="m:kr-args"/>
<xsl:template match="attribute()" mode="m:kr-args">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="element()" mode="m:kr-table">
  <xsl:message
      select="'Unexpected funcsynopsis element in kr-table: ' || node-name(.)"/>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr-table"/>
  </span>
</xsl:template>

<xsl:template match="db:funcsynopsisinfo" mode="m:kr-table">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="db:funcprototype" mode="m:kr-table">
  <xsl:variable name="rowspan" select="count(*) - 2"/>

  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <table class="prototype">
      <tbody>
        <tr>
          <td>
            <xsl:apply-templates select="db:funcdef" mode="m:kr-table"/>
            <xsl:text>(</xsl:text>
          </td>
          <xsl:apply-templates select="db:funcdef/following-sibling::*[1]"
                               mode="m:kr-table-args"/>
        </tr>
        <xsl:for-each select="db:funcdef/following-sibling::*[position() gt 1]">
          <tr>
            <xsl:if test="position() = 1">
              <td rowspan="{$rowspan}"/>
            </xsl:if>
            <xsl:apply-templates select="." mode="m:kr-table-args"/>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
    <table class="params">
      <tbody>
        <xsl:apply-templates select="db:paramdef" mode="m:kr-table"/>
      </tbody>
    </table>
  </div>
</xsl:template>

<xsl:template match="db:funcdef" mode="m:kr-table">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr-table"/>
  </span>
</xsl:template>

<xsl:template match="db:type" mode="m:kr-table">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr-table"/>
  </span>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="db:function" mode="m:kr-table">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr-table"/>
  </span>
</xsl:template>

<xsl:template match="db:void" mode="m:kr-table-args">
  <td>
    <span>
      <xsl:apply-templates select="." mode="m:attributes"/>
    </span>
    <xsl:text>)</xsl:text>
    <xsl:sequence select="$funcsynopsis-trailing-punctuation"/>
  </td>
</xsl:template>

<xsl:template match="db:varargs" mode="m:kr-table-args">
  <td>
    <span>
      <xsl:apply-templates select="." mode="m:attributes"/>
      <xsl:text>...</xsl:text>
    </span>
    <xsl:text>)</xsl:text>
    <xsl:sequence select="$funcsynopsis-trailing-punctuation"/>
  </td>
</xsl:template>

<xsl:template match="db:parameter" mode="m:kr-table-args">
  <span class="{local-name(.)}">
    <xsl:apply-templates mode="m:kr-table"/>
  </span>
</xsl:template>

<xsl:template match="db:void" mode="m:kr-table"/>
<xsl:template match="db:varargs" mode="m:kr-table"/>

<xsl:template match="db:paramdef" mode="m:kr-table-args">
  <td>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="db:parameter" mode="m:kr-table-args"/>
    <xsl:sequence select="if (following-sibling::db:paramdef)
                          then ','
                          else ')' || $funcsynopsis-trailing-punctuation"/>
  </td>
</xsl:template>

<xsl:template match="db:paramdef" mode="m:kr-table">
  <xsl:variable name="split" select="if (db:funcparams)
                                     then db:funcparams
                                     else db:parameter"/>
  <tr>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <td>
      <xsl:apply-templates select="$split/preceding-sibling::node()"
                           mode="m:kr-table"/>
    </td>
    <td>
      <xsl:apply-templates select="$split"
                           mode="m:kr-table"/>
      <xsl:apply-templates select="$split/following-sibling::node()"
                           mode="m:kr-table"/>
    </td>
  </tr>
</xsl:template>

<xsl:template match="db:parameter" mode="m:kr-table">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr-table"/>
  </span>
</xsl:template>

<xsl:template match="db:funcparams" mode="m:kr-table">
  <xsl:text>(</xsl:text>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:kr-table"/>
  </span>
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="text()" mode="m:kr-table">
  <xsl:sequence select="if (normalize-space(.) = '')
                        then ()
                        else ."/>
</xsl:template>

<xsl:template match="comment()|processing-instruction()" mode="m:kr-table"/>
<xsl:template match="attribute()" mode="m:kr-table">
  <xsl:copy/>
</xsl:template>

<xsl:template match="text()" mode="m:kr-table-args">
  <xsl:sequence select="if (normalize-space(.) = '')
                        then ()
                        else ."/>
</xsl:template>

<xsl:template match="comment()|processing-instruction()" mode="m:kr-table-args"/>
<xsl:template match="attribute()|text()" mode="m:kr-table-args">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="element()" mode="m:ansi">
  <xsl:message
      select="'Unexpected funcsynopsis element in kr: ' || node-name(.)"/>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi"/>
  </span>
</xsl:template>

<xsl:template match="db:funcsynopsisinfo" mode="m:ansi">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="db:funcprototype" mode="m:ansi">
  <xsl:variable name="width"
                select="sum(.//text() ! string-length(normalize-space(.)))"/>

  <xsl:choose>
    <xsl:when test="$width gt $funcsynopsis-table-threshold">
      <xsl:apply-templates select="." mode="m:ansi-table"/>
    </xsl:when>
    <xsl:otherwise>
      <div>
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates select="db:funcdef" mode="m:ansi"/>
        <span class="arglist">
          <xsl:text>(</xsl:text>
          <xsl:apply-templates
              select="db:funcdef/following-sibling::*" mode="m:ansi"/>
          <xsl:text>)</xsl:text>
          <xsl:sequence select="$funcsynopsis-trailing-punctuation"/>
        </span>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:funcdef" mode="m:ansi">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi"/>
  </span>
</xsl:template>

<xsl:template match="db:type" mode="m:ansi">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi"/>
  </span>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="db:function" mode="m:ansi">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi"/>
  </span>
</xsl:template>

<xsl:template match="db:void" mode="m:ansi">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:text>void</xsl:text>
  </span>
</xsl:template>

<xsl:template match="db:varargs" mode="m:ansi">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:text>...</xsl:text>
  </span>
</xsl:template>

<xsl:template match="db:paramdef" mode="m:ansi">
  <span>
    <xsl:apply-templates mode="m:ansi"/>
    <xsl:if test="following-sibling::db:paramdef">
      <span>, </span>
    </xsl:if>
  </span>
</xsl:template>

<xsl:template match="db:parameter" mode="m:ansi">
  <span class="{local-name(.)}">
    <xsl:apply-templates mode="m:ansi"/>
  </span>
</xsl:template>

<xsl:template match="db:funcparams" mode="m:ansi">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi"/>
  </span>
</xsl:template>

<xsl:template match="text()" mode="m:ansi">
  <xsl:sequence select="if (normalize-space(.) = '')
                        then ()
                        else ."/>
</xsl:template>

<xsl:template match="comment()|processing-instruction()" mode="m:ansi"/>
<xsl:template match="attribute()" mode="m:ansi">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="element()" mode="m:ansi-table">
  <xsl:message
      select="'Unexpected funcsynopsis element in kr-table: ' || node-name(.)"/>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi-table"/>
  </span>
</xsl:template>

<xsl:template match="db:funcsynopsisinfo" mode="m:ansi-table">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="db:funcprototype" mode="m:ansi-table">
  <xsl:variable name="rowspan" select="count(*) - 2"/>

  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <table class="prototype">
      <tbody>
        <tr>
          <td>
            <xsl:apply-templates select="db:funcdef" mode="m:ansi-table"/>
            <xsl:text>(</xsl:text>
          </td>
          <xsl:apply-templates select="db:funcdef/following-sibling::*[1]"
                               mode="m:ansi-table"/>
        </tr>
        <xsl:for-each select="db:funcdef/following-sibling::*[position() gt 1]">
          <tr>
            <xsl:if test="position() = 1">
              <td rowspan="{$rowspan}"/>
            </xsl:if>
            <xsl:apply-templates select="." mode="m:ansi-table"/>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>
  </div>
</xsl:template>

<xsl:template match="db:funcdef" mode="m:ansi-table">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi-table"/>
  </span>
</xsl:template>

<xsl:template match="db:type" mode="m:ansi-table">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi-table"/>
  </span>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="db:function" mode="m:ansi-table">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi-table"/>
  </span>
</xsl:template>

<xsl:template match="db:void" mode="m:ansi-table">
  <td>
    <span>
      <xsl:apply-templates select="." mode="m:attributes"/>
      <xsl:apply-templates mode="m:ansi-table"/>
    </span>
    <xsl:text>)</xsl:text>
    <xsl:sequence select="$funcsynopsis-trailing-punctuation"/>
  </td>
</xsl:template>

<xsl:template match="db:varargs" mode="m:ansi-table">
  <td>
    <span>
      <xsl:apply-templates select="." mode="m:attributes"/>
      <xsl:text>...</xsl:text>
    </span>
    <xsl:text>)</xsl:text>
    <xsl:sequence select="$funcsynopsis-trailing-punctuation"/>
  </td>
</xsl:template>

<xsl:template match="db:paramdef" mode="m:ansi-table">
  <td>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi-table"/>
    <xsl:sequence select="if (following-sibling::*)
                          then ','
                          else ')' || $funcsynopsis-trailing-punctuation"/>
  </td>
</xsl:template>

<xsl:template match="db:parameter" mode="m:ansi-table">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi-table"/>
  </span>
</xsl:template>

<xsl:template match="db:funcparams" mode="m:ansi-table">
  <xsl:text>(</xsl:text>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:ansi-table"/>
  </span>
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="text()" mode="m:ansi-table">
  <xsl:sequence select="if (normalize-space(.) = '')
                        then ()
                        else ."/>
</xsl:template>

<xsl:template match="comment()|processing-instruction()" mode="m:ansi-table"/>
<xsl:template match="attribute()" mode="m:ansi-table">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:packagesynopsis
                     |db:classsynopsis
                     |db:fieldsynopsis
                     |db:methodsynopsis
                     |db:constructorsynopsis
                     |db:destructorsynopsis
                     |db:enumsynopsis"
              priority="100">
  <xsl:if test="@language and @language ne 'java'">
    <xsl:message select="'Warning: no explicit support for', @language, 'synopses.'"/>
  </xsl:if>
  <xsl:next-match/>
</xsl:template>

<xsl:template match="db:packagesynopsis">
  <xsl:param name="indent" select="''"/>

  <xsl:variable name="package" select="db:package"/>
  <xsl:if test="count($package) != 1">
    <xsl:message>Malformed packagesynopisis.</xsl:message>
  </xsl:if>

  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <pre>
      <xsl:apply-templates select="$package/preceding-sibling::*" mode="m:synopsis"/>
      <xsl:text>package </xsl:text>
      <xsl:apply-templates select="db:package"/>
      <xsl:text>;&#10;</xsl:text>
    </pre>
    <xsl:apply-templates select="$package/following-sibling::*">
      <xsl:with-param name="indent" select="$indent || $classsynopsis-indent"/>
    </xsl:apply-templates>
  </div>
</xsl:template>

<xsl:template match="db:classsynopsis">
  <xsl:param name="indent" select="''"/>
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="db:classsynopsisinfo"/>
    <pre>
      <xsl:apply-templates select="db:ooclass/db:modifier" mode="m:synopsis"/>
      <xsl:text>class </xsl:text>
      <xsl:apply-templates select="db:ooclass/db:classname" mode="m:synopsis"/>
      <xsl:text> {</xsl:text>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates select="* except (db:ooclass|db:classsynopsisinfo)"
                           mode="m:synopsis">
        <xsl:with-param name="indent" select="$indent || $classsynopsis-indent"/>
      </xsl:apply-templates>
      <xsl:text>&#10;</xsl:text>
      <xsl:text>}</xsl:text>
    </pre>
  </div>
</xsl:template>

<xsl:template match="db:fieldsynopsis">
  <xsl:param name="indent" select="''"/>
  <pre class="synopsis">
    <xsl:apply-templates select="." mode="m:synopsis"/>
  </pre>
</xsl:template>

<xsl:template match="db:fieldsynopsis" mode="m:synopsis">
  <xsl:param name="indent" select="''"/>

  <xsl:apply-templates
      select="db:synopsisinfo[empty(preceding-sibling::* except preceding-sibling::db:synopsisinfo)]"
      mode="m:synopsis"/>

  <xsl:sequence select="$indent"/>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="db:modifier|db:type" mode="m:synopsis"/>
    <xsl:apply-templates select="db:varname" mode="m:synopsis"/>
    <xsl:apply-templates select="db:initializer" mode="m:synopsis"/>
  </span>
  <xsl:text>&#10;</xsl:text>

  <xsl:apply-templates
      select="db:synopsisinfo[empty(following-sibling::* except following-sibling::db:synopsisinfo)]"
      mode="m:synopsis"/>

</xsl:template>

<xsl:template match="db:varname" mode="m:synopsis">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:synopsis"/>
    <xsl:if test="not(following-sibling::db:initializer)">;</xsl:if>
  </span>
</xsl:template>

<xsl:template match="db:initializer" mode="m:synopsis">
  <xsl:text> = </xsl:text>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates mode="m:synopsis"/>
  </span>
  <xsl:text>;</xsl:text>
</xsl:template>

<xsl:template match="db:methodsynopsis
                     |db:constructorsynopsis
                     |db:destructorsynopsis">
  <xsl:param name="indent" select="''"/>
  <pre class="synopsis">
    <xsl:apply-templates select="." mode="m:synopsis"/>
  </pre>
</xsl:template>

<xsl:template match="db:methodsynopsis
                     |db:constructorsynopsis
                     |db:destructorsynopsis"
              mode="m:synopsis">
  <xsl:param name="indent" select="''"/>

  <xsl:apply-templates
      select="db:synopsisinfo[empty(preceding-sibling::* except preceding-sibling::db:synopsisinfo)]"
      mode="m:synopsis"/>

  <xsl:sequence select="$indent"/>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:variable name="line" as="node()*">
      <xsl:apply-templates select="db:modifier|db:type" mode="m:synopsis"/>
      <xsl:apply-templates select="db:methodname" mode="m:synopsis"/>
      <xsl:text>(</xsl:text>
    </xsl:variable>
    <xsl:sequence select="$line"/>
    <xsl:apply-templates select="db:methodparam[1]" mode="m:synopsis">
      <xsl:with-param name="indent" select="''"/>
    </xsl:apply-templates>
    <xsl:choose>
      <xsl:when test="count(db:methodparam) gt 1">
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select="db:methodparam[position() gt 1]"
                             mode="m:synopsis">
          <xsl:with-param name="indent" select="$indent || f:spaces($line)"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="count(db:methodparam) eq 0">
        <xsl:text>)</xsl:text>
        <xsl:sequence select="$funcsynopsis-trailing-punctuation"/>
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- nop -->
      </xsl:otherwise>
    </xsl:choose>
  </span>

  <xsl:apply-templates
      select="db:synopsisinfo[empty(following-sibling::* except following-sibling::db:synopsisinfo)]"
      mode="m:synopsis"/>
</xsl:template>

<xsl:template match="db:methodparam" mode="m:synopsis">
  <xsl:param name="indent" select="''"/>

  <xsl:sequence select="$indent"/>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="db:modifier|db:type" mode="m:synopsis"/>
    <xsl:apply-templates select="db:parameter" mode="m:synopsis"/>
  </span>
  <xsl:sequence select="if (following-sibling::db:methodparam)
                        then ','
                        else ')' || $funcsynopsis-trailing-punctuation"/>
</xsl:template>

<xsl:template match="db:modifier|db:type" mode="m:synopsis">
  <xsl:apply-templates/>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="db:classname|db:methodname|db:parameter" mode="m:synopsis">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:synopsisinfo" mode="m:synopsis">
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="db:enumsynopsis">
  <xsl:param name="indent" select="''"/>
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="db:synopsisinfo"/>
    <pre>
      <xsl:apply-templates select="db:modifier" mode="m:synopsis"/>
      <xsl:text>enum </xsl:text>
      <xsl:apply-templates select="db:enumname" mode="m:synopsis"/>
      <xsl:text> {</xsl:text>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates select="db:enumitem" mode="m:synopsis">
        <xsl:with-param name="indent" select="$indent || $classsynopsis-indent"/>
      </xsl:apply-templates>
      <xsl:text>}</xsl:text>
    </pre>
  </div>
</xsl:template>

<xsl:template match="db:enumitem" mode="m:synopsis">
  <xsl:param name="indent" select="''"/>
  <xsl:sequence select="$indent"/>
  <xsl:apply-templates select="db:enumidentifier" mode="m:synopsis"/>
  <xsl:if test="following-sibling::db:enumitem">,</xsl:if>
  <xsl:if test="db:enumitemdescription">
    <xsl:variable name="width"
                  select="sum((string-length($indent),
                               string-length(db:enumidentifier),
                               (if (following-sibling::db:enumitem) then 1 else 0)))"/>
    <xsl:variable
        name="pad"
        select="max((2, 30 - $width))"/>
    <xsl:sequence select="substring('                              ', 1, $pad)"/>
    <xsl:sequence select="'// '"/>
    <xsl:apply-templates select="db:enumitemdescription" mode="m:synopsis"/>
  </xsl:if>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="db:enumitemdescription" mode="m:synopsis">
  <xsl:apply-templates mode="m:synopsis"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:cmdsynopsis">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:synopfragment">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:synopfragment-bug"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match="db:synopfragmentref">
  <xsl:variable name="target" select="f:target(@linkend, .)"/>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <a href="{f:href(., $target)}">
      <xsl:apply-templates select="$target" mode="m:synopfragment-bug"/>
    </a>
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
  </span>
</xsl:template>

<xsl:template match="db:synopfragment" mode="m:synopfragment-bug">
  <xsl:variable name="number" as="item()*">
    <xsl:number from="db:cmdsynopsis" level="any"/>
  </xsl:variable>
  <xsl:variable name="number" select="xs:integer($number)"/>
  <span class="synopfragmentref-number">
    <xsl:sequence
        select="codepoints-to-string($callout-unicode-start + $number)"/>
  </span>
</xsl:template>

<xsl:template match="db:cmdsynopsis/db:command">
  <xsl:if test="preceding-sibling::*[1]">
    <br/>
  </xsl:if>
  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
  </span>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="db:group|db:arg" name="tp:group-or-arg">
  <xsl:variable name="choice" select="@choice/string()"/>
  <xsl:variable name="rep" select="@rep/string()"/>
  <xsl:variable name="sepchar"
                select="if (ancestor-or-self::*/@sepchar)
                        then ancestor-or-self::*/@sepchar/string()
                        else ' '"/>

  <xsl:if test="position() gt 1">
    <xsl:sequence select="$sepchar"/>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="$choice='plain'">
      <xsl:sequence select="$v:arg-choice-plain-open-str"/>
    </xsl:when>
    <xsl:when test="$choice='req'">
      <xsl:sequence select="$v:arg-choice-req-open-str"/>
    </xsl:when>
    <xsl:when test="$choice='opt'">
      <xsl:sequence select="$v:arg-choice-opt-open-str"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$v:arg-choice-def-open-str"/>
    </xsl:otherwise>
  </xsl:choose>

  <span>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates/>
  </span>

  <xsl:choose>
    <xsl:when test="$rep='repeat'">
      <xsl:sequence select="$v:arg-rep-repeat-str"/>
    </xsl:when>
    <xsl:when test="$rep='norepeat'">
      <xsl:sequence select="$v:arg-rep-norepeat-str"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$v:arg-rep-def-str"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="$choice='plain'">
      <xsl:sequence select="$v:arg-choice-plain-close-str"/>
    </xsl:when>
    <xsl:when test="$choice='req'">
      <xsl:sequence select="$v:arg-choice-req-close-str"/>
    </xsl:when>
    <xsl:when test="$choice='opt'">
      <xsl:sequence select="$v:arg-choice-opt-close-str"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$v:arg-choice-def-close-str"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:group/db:arg">
  <xsl:variable name="choice" select="@choice"/>
  <xsl:variable name="rep" select="@rep"/>
  <xsl:if test="position()>1">
    <xsl:sequence select="$v:arg-or-sep"/>
  </xsl:if>
  <xsl:call-template name="tp:group-or-arg"/>
</xsl:template>

</xsl:stylesheet>
