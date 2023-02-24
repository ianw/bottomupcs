<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tmp="http://docbook.org/ns/docbook/templates"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db dbe f fp h m mp t tmp v vp xs"
                version="3.0">

<!-- It's a real shame that you can't have mode variables ... -->

<xsl:strip-space elements="tmp:*"/>

<!-- The default value is an empty document, it's for customizations to override -->
<xsl:variable name="v:templates" as="document-node()">
  <xsl:document/>
</xsl:variable>

<xsl:variable name="vp:templates" as="document-node()">
  <!-- Yes, this is basically fold-left done the hard way,
       but it avoids an EE feature in Saxon 9. -->
  <xsl:document>
    <xsl:sequence
        select="fp:construct-templates(($v:templates/*, doc('templates.xml')/*/*),
                                        ())"/>
  </xsl:document>
</xsl:variable>

<xsl:function name="fp:construct-templates">
  <xsl:param name="templates" as="element()*"/>
  <xsl:param name="list" as="element()*"/>

  <xsl:variable name="car" select="subsequence($templates, 1, 1)"/>
  <xsl:variable name="cdr" select="subsequence($templates, 2)"/>

  <xsl:choose>
    <xsl:when test="empty($templates)">
      <xsl:sequence select="$list"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="template" as="element()">
        <xsl:apply-templates select="$car" mode="mp:expand-template">
          <xsl:with-param name="list" select="$list"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:sequence select="fp:construct-templates($cdr, ($list, $template))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:template match="element()" mode="mp:expand-template">
  <xsl:param name="list" as="element()*" required="yes"/>
  <xsl:copy>
    <xsl:apply-templates select="@*, node()"
                         mode="mp:expand-template">
      <xsl:with-param name="list" select="$list"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<xsl:template match="tmp:insert" mode="mp:expand-template">
  <xsl:param name="list" as="element()*" required="yes"/>

  <xsl:variable name="name"
                select="QName('http://docbook.org/ns/docbook/templates', @ref)"/>
  <xsl:variable name="template"
                select="($list[node-name(.)=$name])[1]"/>

  <xsl:sequence select="if (empty($template))
                        then error($dbe:INVALID-TEMPLATE,
                                   'No such template: ' || @ref)
                        else $template/*"/>
</xsl:template>

<xsl:template match="attribute()|text()|comment()|processing-instruction()"
              mode="mp:expand-template">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:function name="f:template" as="element()">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="default" as="element()"/>

  <xsl:variable name="xpath" select="'/db:' || local-name($context)"/>
  <xsl:variable name="template" as="element()*">
    <xsl:evaluate context-item="$vp:templates" xpath="$xpath"/>
  </xsl:variable>

  <xsl:variable name="template" as="element()*">
    <xsl:sequence select="if (empty($template))
                          then $default
                          else $template"/>
  </xsl:variable>

  <xsl:sequence select="if (count($template) gt 1)
                        then fp:pick-template($context, $template)
                        else $template"/>
</xsl:function>

<xsl:function name="fp:pick-template" as="element()">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="templates" as="element()+"/>

  <xsl:if test="not($templates[1]/@context) and (count($templates) gt 1)"
          use-when="'templates' = $v:debug">
    <xsl:message select="'A template without context should be last.'"/>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="count($templates) eq 1 or not($templates[1]/@context)">
      <xsl:sequence select="$templates[1]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="items" as="item()*">
        <xsl:evaluate context-item="$context"
                      xpath="$templates[1]/@context"/>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="count($items) = 1 and $items instance of xs:boolean">
          <xsl:sequence
              select="if ($items)
                      then $templates[1]
                      else fp:pick-template($context, subsequence($templates, 2))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="if (empty($items))
                                then fp:pick-template($context, subsequence($templates, 2))
                                else $templates[1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:variable name="v:titlepage-default" as="element()">
  <tmp:titlepage-default>
    <header>
      <tmp:apply-templates select="db:title">
        <div class="title"><tmp:content/></div>
      </tmp:apply-templates>
    </header>
  </tmp:titlepage-default>
</xsl:variable>

<xsl:template match="*" mode="m:generate-titlepage">
  <xsl:if test="fp:pmuj-enabled(/)">
    <xsl:sequence select="@xml:id ! fp:pmuj(./parent::*, ./string())"/>
  </xsl:if>

  <xsl:variable name="template"
                select="if (db:info/tmp:titlepage-template)
                        then db:info/tmp:titlepage-template
                        else f:template(., $v:titlepage-default)"/>

  <xsl:if test="empty(db:info)" use-when="'templates' = $v:debug">
    <xsl:message terminate="yes" select="'No db:info in', local-name(.)"/>
  </xsl:if>

  <xsl:variable name="empty-info" as="element(db:info)">
    <info xmlns="http://docbook.org/ns/docbook"/>
  </xsl:variable>

  <xsl:variable name="info"
                select="if (empty(db:info)) then $empty-info else db:info"/>

  <xsl:variable name="titlepage" as="node()*">
    <xsl:apply-templates select="$template/node()" mode="mp:construct-titlepage">
      <xsl:with-param name="info" select="$info"/>
      <xsl:with-param name="context" select="$info"/>
      <xsl:with-param name="template" select="$template/*"/>
      <xsl:with-param name="content" select="()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:sequence select="if (count($titlepage) = 1
                            and $titlepage/self::*
                            and empty($titlepage/node())
                            and empty($titlepage/@*))
                        then ()
                        else $titlepage"/>
</xsl:template>

<xsl:template match="tmp:apply-templates" mode="mp:construct-titlepage">
  <xsl:param name="info" required="yes"/>
  <xsl:param name="context" required="yes"/>
  <xsl:param name="template" required="yes"/>
  <xsl:param name="content" required="yes"/>

  <xsl:variable name="content" select="node()"/>

  <xsl:variable use-when="'templates' = $v:debug"
                name="select" select="@select/string()"/>

  <xsl:variable name="elements" as="element()*">
    <xsl:evaluate xpath="@select" context-item="$context"/>
  </xsl:variable>

  <xsl:for-each select="$elements">
    <xsl:message use-when="'templates-matches' = $v:debug"
                 select="'Template:', $select, 'matched', node-name(.)"/>

    <xsl:choose>
      <xsl:when test="empty($content)">
        <xsl:apply-templates select="." mode="m:titlepage"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$content" mode="mp:construct-titlepage">
          <xsl:with-param name="info" select="$info"/>
          <xsl:with-param name="context" select="."/>
          <xsl:with-param name="template" select="$template"/>
          <xsl:with-param name="content" select="."/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template match="tmp:content" mode="mp:construct-titlepage">
  <xsl:param name="info" required="yes"/>
  <xsl:param name="context" required="yes"/>
  <xsl:param name="template" required="yes"/>
  <xsl:param name="content" required="yes"/>

  <xsl:apply-templates select="$content" mode="m:titlepage"/>
</xsl:template>

<xsl:template match="element()" mode="mp:construct-titlepage">
  <xsl:param name="info" required="yes"/>
  <xsl:param name="context" required="yes"/>
  <xsl:param name="template" required="yes"/>
  <xsl:param name="content" required="yes"/>

  <!-- For some reason, exclude-result-prefixes isn't
       excluding them, so just don't copy them. -->
  <xsl:element name="{node-name(.)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*,node()"
                         mode="mp:construct-titlepage">
      <xsl:with-param name="info" select="$info"/>
      <xsl:with-param name="context" select="$context"/>
      <xsl:with-param name="template" select="$template"/>
      <xsl:with-param name="content" select="$content"/>
    </xsl:apply-templates>
  </xsl:element>
</xsl:template>

<xsl:template match="text()" mode="mp:construct-titlepage">
  <!-- whitespace in templates is ignored -->
  <xsl:param name="info" required="yes"/>
  <xsl:param name="context" required="yes"/>
  <xsl:param name="template" required="yes"/>
  <xsl:param name="content" required="yes"/>
  <xsl:if test="normalize-space(.) != ''">
    <xsl:copy/>
  </xsl:if>
</xsl:template>

<xsl:template match="attribute()|comment()|processing-instruction()"
              mode="mp:construct-titlepage">
  <xsl:param name="info" required="yes"/>
  <xsl:param name="context" required="yes"/>
  <xsl:param name="template" required="yes"/>
  <xsl:param name="content" required="yes"/>
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="t:biblioentry">
  <!-- For many elements, there's a default template if the user fails
       to provide one. There's so much variation in biblioentry, it's
       not even worth trying. -->
  <xsl:variable name="biblioentry-default" as="element()">
    <tmp:biblioentry-default>
      <div>ERROR: No template for biblioentry</div>
    </tmp:biblioentry-default>
  </xsl:variable>
  <xsl:variable name="template" select="f:template(., $biblioentry-default)"/>
  <xsl:variable name="entry" as="node()*">
    <xsl:apply-templates select="$template/node()" mode="mp:construct-biblioentry">
      <xsl:with-param name="info" select="."/>
      <xsl:with-param name="context" select="."/>
      <xsl:with-param name="template" select="$template/*"/>
      <xsl:with-param name="content" select="()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:sequence select="if (count($entry) = 1
                            and $entry/self::*
                            and empty($entry/node())
                            and empty($entry/@*))
                        then ()
                        else $entry"/>
</xsl:template>

<xsl:template match="tmp:apply-templates" mode="mp:construct-biblioentry">
  <xsl:param name="info" required="yes"/>
  <xsl:param name="context" required="yes"/>
  <xsl:param name="template" required="yes"/>
  <xsl:param name="content" required="yes"/>

  <xsl:variable name="content" select="node()"/>

  <xsl:variable use-when="'templates' = $v:debug"
                name="select" select="@select/string()"/>

  <xsl:variable name="elements" as="element()*">
    <xsl:evaluate xpath="@select" context-item="$context"/>
  </xsl:variable>

  <xsl:for-each select="$elements">
    <xsl:message use-when="'templates-matches' = $v:debug"
                 select="'Template:', $select, 'matched', node-name(.)"/>

    <xsl:choose>
      <xsl:when test="empty($content)">
        <xsl:apply-templates select="." mode="m:biblioentry"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$content" mode="mp:construct-biblioentry">
          <xsl:with-param name="info" select="$info"/>
          <xsl:with-param name="context" select="."/>
          <xsl:with-param name="template" select="$template"/>
          <xsl:with-param name="content" select="."/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template match="tmp:content" mode="mp:construct-biblioentry">
  <xsl:param name="info" required="yes"/>
  <xsl:param name="context" required="yes"/>
  <xsl:param name="template" required="yes"/>
  <xsl:param name="content" required="yes"/>

  <xsl:apply-templates select="$content" mode="m:biblioentry"/>
</xsl:template>

<xsl:template match="element()" mode="mp:construct-biblioentry">
  <xsl:param name="info" required="yes"/>
  <xsl:param name="context" required="yes"/>
  <xsl:param name="template" required="yes"/>
  <xsl:param name="content" required="yes"/>

  <!-- For some reason, exclude-result-prefixes isn't
       excluding them, so just don't copy them. -->
  <xsl:element name="{node-name(.)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="@*,node()"
                         mode="mp:construct-biblioentry">
      <xsl:with-param name="info" select="$info"/>
      <xsl:with-param name="context" select="$context"/>
      <xsl:with-param name="template" select="$template"/>
      <xsl:with-param name="content" select="$content"/>
    </xsl:apply-templates>
  </xsl:element>
</xsl:template>

<xsl:template match="text()" mode="mp:construct-biblioentry">
  <!-- whitespace in templates is ignored -->
  <xsl:param name="info" required="yes"/>
  <xsl:param name="context" required="yes"/>
  <xsl:param name="template" required="yes"/>
  <xsl:param name="content" required="yes"/>
  <xsl:if test="normalize-space(.) != ''">
    <xsl:copy/>
  </xsl:if>
</xsl:template>

<xsl:template match="attribute()|comment()|processing-instruction()"
              mode="mp:construct-biblioentry">
  <xsl:param name="info" required="yes"/>
  <xsl:param name="context" required="yes"/>
  <xsl:param name="template" required="yes"/>
  <xsl:param name="content" required="yes"/>
  <xsl:copy/>
</xsl:template>


</xsl:stylesheet>
