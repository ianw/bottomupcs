<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:l="http://docbook.org/ns/docbook/l10n"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="#all"
                version="3.0">

<xsl:template match="db:indexterm">
  <span class="indexterm" id="{f:generate-id(.)}">
    <xsl:if test="not(empty($index-show-entries))">
      <xsl:attribute name="title" select="string-join(.//*, ', ')"/>
      <xsl:sequence select="$index-show-entries"/>
    </xsl:if>
  </span>
</xsl:template>

<xsl:template match="db:primary|db:secondary|db:tertiary|db:see|db:seealso"/>

<xsl:template match="db:setindex|db:index|db:indexdiv">
  <xsl:variable name="gi" select="if (parent::*)
                                  then 'div'
                                  else 'article'"/>
  <xsl:element name="{$gi}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="." mode="m:generate-titlepage"/>
    <xsl:apply-templates
        select="node() except (db:indexdiv|db:indexentry|db:segmentedlist)"/>

    <xsl:variable name="autoindex"
                  select="f:pi(., 'autoindex', $generate-index)"/>
    <xsl:if test="f:is-true($autoindex)">
      <div class="index-list">
        <xsl:choose>
          <xsl:when test="not(db:indexdiv|db:indexentry|db:segmentedlist)
                          and f:is-true(f:pi(., 'autoindex', 'true'))
                          and f:is-true($generate-index)">
            <xsl:call-template name="t:generate-index">
              <xsl:with-param name="scope" select="parent::*"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="db:indexdiv|db:indexentry|db:segmentedlist"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:if>
  </xsl:element>
</xsl:template>

<!-- ============================================================ -->

<xsl:key name="primary"
         match="db:indexterm"
         use="normalize-space(concat(db:primary/@sortas, db:primary[not(@sortas)]))"/>

<xsl:key name="endofrange"
         match="db:indexterm[@class='endofrange']"
         use="@startref"/>

<!-- ============================================================ -->

<xsl:function name="fp:primary" as="xs:string">
  <xsl:param name="indexterm" as="element(db:indexterm)"/>
  <xsl:sequence
      select="normalize-space(concat($indexterm/db:primary/@sortas,
                                     $indexterm/db:primary[not(@sortas)]))"/>
</xsl:function>

<xsl:function name="fp:secondary" as="xs:string">
  <xsl:param name="indexterm" as="element(db:indexterm)"/>
  <xsl:sequence
      select="normalize-space(concat($indexterm/db:secondary/@sortas,
                                     $indexterm/db:secondary[not(@sortas)]))"/>
</xsl:function>

<xsl:function name="fp:tertiary" as="xs:string">
  <xsl:param name="indexterm" as="element(db:indexterm)"/>
  <xsl:sequence
      select="normalize-space(concat($indexterm/db:tertiary/@sortas,
                                     $indexterm/db:tertiary[not(@sortas)]))"/>
</xsl:function>

<xsl:function name="fp:scope" as="xs:boolean">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="scope" as="element()"/>
  <xsl:param name="role" as="xs:string?"/>
  <xsl:param name="type" as="xs:string?"/>
  <xsl:sequence
      select="count($node/ancestor::node()|$scope) = count($node/ancestor::node())
                and ($role = $node/@role or $type = $node/@type or
                (string-length($role) = 0 and string-length($type) = 0))"/>
</xsl:function>

<xsl:function name="fp:nearest-section" as="element()">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="($node/ancestor-or-self::db:set
                         |$node/ancestor-or-self::db:book
                         |$node/ancestor-or-self::db:part
                         |$node/ancestor-or-self::db:reference
                         |$node/ancestor-or-self::db:partintro
                         |$node/ancestor-or-self::db:chapter
                         |$node/ancestor-or-self::db:appendix
                         |$node/ancestor-or-self::db:preface
                         |$node/ancestor-or-self::db:article
                         |$node/ancestor-or-self::db:section
                         |$node/ancestor-or-self::db:sect1
                         |$node/ancestor-or-self::db:sect2
                         |$node/ancestor-or-self::db:sect3
                         |$node/ancestor-or-self::db:sect4
                         |$node/ancestor-or-self::db:sect5
                         |$node/ancestor-or-self::db:refentry
                         |$node/ancestor-or-self::db:refsect1
                         |$node/ancestor-or-self::db:refsect2
                         |$node/ancestor-or-self::db:refsect3
                         |$node/ancestor-or-self::db:simplesect
                         |$node/ancestor-or-self::db:bibliography
                         |$node/ancestor-or-self::db:glossary
                         |$node/ancestor-or-self::db:index)[last()]"/>
</xsl:function>

<xsl:function name="fp:nearest-section-id" as="xs:string">
  <xsl:param name="indexterm" as="element(db:indexterm)"/>
  <xsl:sequence select="f:generate-id(fp:nearest-section($indexterm))"/>
</xsl:function>

<xsl:function name="fp:group-index">
  <xsl:param name="term" as="xs:string"/>
  <xsl:param name="node" as="element()"/>

  <xsl:variable name="letters"
                select="f:gentext-letters-for-language($node)"/>

  <xsl:variable name="long-letter-index"
                select="$letters/l:l[. = substring($term,1,2)]/@i"/>

  <xsl:variable name="short-letter-index"
                select="$letters/l:l[. = substring($term,1,1)]/@i"/>

  <xsl:sequence select="($long-letter-index, $short-letter-index, 0)[1]"/>
</xsl:function>

<xsl:function name="fp:group-label">
  <xsl:param name="index" as="xs:integer"/>
  <xsl:param name="node" as="element()"/>

  <xsl:variable name="letters"
                select="f:gentext-letters-for-language($node)"/>

  <xsl:value-of select="$letters/l:l[@i=$index][1]"/>
</xsl:function>

<!-- ============================================================ -->

<xsl:template name="t:generate-index">
  <xsl:param name="scope" select="(ancestor::db:book|/)[last()]"/>

  <xsl:variable name="role"
                select="if (f:is-true($index-on-role))
                        then @role
                        else ()"/>

  <xsl:variable name="type"
                select="if (f:is-true($index-on-type))
                        then @type
                        else ()"/>

  <div class="generated-index">
    <xsl:for-each-group select="//db:indexterm[fp:scope(., $scope, $role, $type)]
                                   [not(@class = 'endofrange')]"
                        group-by="fp:group-index(fp:primary(.), $scope)">
      <xsl:sort select="fp:group-index(fp:primary(.), $scope)" data-type="number"/>
      <xsl:apply-templates select="." mode="m:index-div">
        <xsl:with-param name="scope" select="$scope"/>
        <xsl:with-param name="role" select="$role"/>
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="lang" select="f:l10n-language($scope)"/>
        <xsl:with-param name="nodes" select="current-group()"/>
        <xsl:with-param name="group-index" select="current-grouping-key()"/>
      </xsl:apply-templates>
    </xsl:for-each-group>
  </div>
</xsl:template>

<xsl:template match="db:indexterm" mode="m:index-div">
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>
  <xsl:param name="lang" select="'en'"/>
  <xsl:param name="nodes" as="element()*"/>
  <xsl:param name="group-index"/>

  <xsl:if test="$nodes">
    <div class="generated-indexdiv">
      <header>
        <h3>
          <xsl:value-of select="fp:group-label($group-index, $scope)"/>
        </h3>
      </header>
      <ul>
        <xsl:for-each-group select="$nodes" group-by="fp:primary(.)">
          <xsl:sort select="fp:primary(.)" lang="{$lang}"/>
          <xsl:apply-templates select="current-group()[1]" mode="m:index-primary">
            <xsl:with-param name="scope" select="$scope"/>
            <xsl:with-param name="role" select="$role"/>
            <xsl:with-param name="type" select="$type"/>
            <xsl:with-param name="lang" select="$lang"/>
          </xsl:apply-templates>
        </xsl:for-each-group>
      </ul>
    </div>
  </xsl:if>
</xsl:template>

<xsl:template match="db:indexterm" mode="m:index-primary">
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>
  <xsl:param name="lang" select="'en'"/>

  <xsl:variable name="key" select="fp:primary(.)"/>
  <xsl:variable name="refs"
                select="key('primary', $key)[fp:scope(., $scope, $role, $type)]"/>
  <li>
    <xsl:value-of select="db:primary"/>
    <xsl:for-each-group select="$refs[not(db:secondary) and not(db:see)]"
                        group-by="concat(fp:primary(.), ' ', fp:nearest-section-id(.))">
      <xsl:call-template name="tp:indexed-section">
        <xsl:with-param name="nodes" select="current-group()"/>
        <xsl:with-param name="scope" select="$scope"/>
        <xsl:with-param name="role" select="$role"/>
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:call-template>
    </xsl:for-each-group>

    <xsl:if test="$refs[not(db:secondary)]/*[self::db:see]">
      <xsl:for-each-group select="$refs[db:see]"
                          group-by="concat(fp:primary(.), ' ', ' ', ' ', db:see)">
        <xsl:apply-templates select="." mode="m:index-see">
          <xsl:with-param name="scope" select="$scope"/>
          <xsl:with-param name="role" select="$role"/>
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="lang" select="$lang"/>
          <xsl:sort select="upper-case(db:see)" lang="{$lang}"/>
        </xsl:apply-templates>
      </xsl:for-each-group>
    </xsl:if>
    <xsl:if test="$refs/db:secondary or $refs[not(db:secondary)]/*[self::db:seealso]">
      <ul>
        <xsl:if test="count(db:seealso) &gt; 1">
          <xsl:message>Multiple see also's not supported: only using first</xsl:message>
        </xsl:if>

        <xsl:for-each-group select="$refs[db:seealso]"
                            group-by="concat(fp:primary(.), ' ', ' ', ' ', db:seealso[1])">
          <xsl:apply-templates select="." mode="m:index-seealso">
            <xsl:with-param name="scope" select="$scope"/>
            <xsl:with-param name="role" select="$role"/>
            <xsl:with-param name="type" select="$type"/>
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:sort select="upper-case(db:seealso[1])" lang="{$lang}"/>
          </xsl:apply-templates>
        </xsl:for-each-group>
        <xsl:for-each-group select="$refs[db:secondary]"
                            group-by="concat(fp:primary(.), ' ', fp:secondary(.))">
          <xsl:apply-templates select="." mode="m:index-secondary">
            <xsl:with-param name="scope" select="$scope"/>
            <xsl:with-param name="role" select="$role"/>
            <xsl:with-param name="type" select="$type"/>
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="refs" select="current-group()"/>
            <xsl:sort select="upper-case(fp:secondary(.))" lang="{$lang}"/>
          </xsl:apply-templates>
        </xsl:for-each-group>
      </ul>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template match="db:indexterm" mode="m:index-secondary">
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>
  <xsl:param name="refs" as="element()*"/>
  <xsl:param name="lang" select="'en'"/>

  <xsl:variable name="key" select="concat(fp:primary(.), ' ', fp:secondary(.))"/>
  <li>
    <xsl:value-of select="db:secondary"/>
    <xsl:for-each-group select="$refs[not(db:tertiary) and not(db:see)]"
                        group-by="concat($key, ' ', fp:nearest-section-id(.))">
      <xsl:call-template name="tp:indexed-section">
        <xsl:with-param name="nodes" select="current-group()"/>
        <xsl:with-param name="scope" select="$scope"/>
        <xsl:with-param name="role" select="$role"/>
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:call-template>
    </xsl:for-each-group>

    <xsl:if test="$refs[not(db:tertiary)]/*[self::db:see]">
      <xsl:for-each-group select="$refs[db:see]"
                          group-by="concat(fp:primary(.), ' ', fp:secondary(.), ' ', ' ', db:see)">
        <xsl:apply-templates select="." mode="m:index-see">
          <xsl:with-param name="scope" select="$scope"/>
          <xsl:with-param name="role" select="$role"/>
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="lang" select="$lang"/>
          <xsl:sort select="upper-case(db:see)" lang="{$lang}"/>
        </xsl:apply-templates>
      </xsl:for-each-group>
    </xsl:if>
    <xsl:if test="$refs/db:tertiary or $refs[not(db:tertiary)]/*[self::db:seealso]">
      <ul>
        <xsl:if test="count(db:seealso) &gt; 1">
          <xsl:message>Multiple see also's not supported: only using first</xsl:message>
        </xsl:if>

        <xsl:for-each-group select="$refs[db:seealso]"
                            group-by="concat(fp:primary(.), ' ', fp:secondary(.), ' ', ' ', db:seealso[1])">
          <xsl:apply-templates select="." mode="m:index-seealso">
            <xsl:with-param name="scope" select="$scope"/>
            <xsl:with-param name="role" select="$role"/>
            <xsl:with-param name="type" select="$type"/>
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:sort select="upper-case(db:seealso[1])" lang="{$lang}"/>
          </xsl:apply-templates>
        </xsl:for-each-group>

        <xsl:for-each-group select="$refs[db:tertiary]"
                            group-by="concat($key, ' ', fp:tertiary(.))">
          <xsl:apply-templates select="." mode="m:index-tertiary">
            <xsl:with-param name="scope" select="$scope"/>
            <xsl:with-param name="role" select="$role"/>
            <xsl:with-param name="type" select="$type"/>
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="refs" select="current-group()"/>
            <xsl:sort select="upper-case(fp:tertiary(.))" lang="{$lang}"/>
          </xsl:apply-templates>
        </xsl:for-each-group>
      </ul>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template match="db:indexterm" mode="m:index-tertiary">
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>
  <xsl:param name="lang" select="'en'"/>
  <xsl:param name="refs" as="element()*"/>

  <xsl:variable name="key" select="concat(fp:primary(.), ' ', fp:secondary(.), ' ', fp:tertiary(.))"/>
  <li>
    <xsl:value-of select="db:tertiary"/>
    <xsl:for-each-group select="$refs[not(db:see)]"
                        group-by="concat($key, ' ', fp:nearest-section-id(.))">
      <xsl:call-template name="tp:indexed-section">
        <xsl:with-param name="nodes" select="current-group()"/>
        <xsl:with-param name="scope" select="$scope"/>
        <xsl:with-param name="role" select="$role"/>
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:call-template>
    </xsl:for-each-group>

    <xsl:if test="$refs/db:see">
      <xsl:for-each-group select="$refs[db:see]"
                          group-by="concat(fp:primary(.), ' ', fp:secondary(.), ' ', fp:tertiary(.), ' ', db:see)">
        <xsl:apply-templates select="." mode="m:index-see">
          <xsl:with-param name="scope" select="$scope"/>
          <xsl:with-param name="role" select="$role"/>
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="lang" select="$lang"/>
          <xsl:sort select="upper-case(db:see)" lang="{$lang}"/>
        </xsl:apply-templates>
      </xsl:for-each-group>
    </xsl:if>
    <xsl:if test="$refs/db:seealso">
      <ul>
        <xsl:if test="count(db:seealso) &gt; 1">
          <xsl:message>Multiple see also's not supported: only using first</xsl:message>
        </xsl:if>

        <xsl:for-each-group select="$refs[db:seealso]"
                            group-by="concat(fp:primary(.), ' ', fp:secondary(.), ' ', fp:tertiary(.), ' ', db:seealso[1])">
          <xsl:apply-templates select="." mode="m:index-seealso">
            <xsl:with-param name="scope" select="$scope"/>
            <xsl:with-param name="role" select="$role"/>
            <xsl:with-param name="type" select="$type"/>
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:sort select="upper-case(db:seealso[1])" lang="{$lang}"/>
          </xsl:apply-templates>
        </xsl:for-each-group>
      </ul>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template name="tp:indexed-section">
  <xsl:param name="nodes" as="element()+" required="yes"/>
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>
  <xsl:param name="lang" select="'en'"/>

  <xsl:choose>
    <xsl:when test="f:is-true($indexed-section-groups)">
      <xsl:text>, </xsl:text>
      <xsl:variable name="tobject"
                    select="$nodes[1]/ancestor::*[db:title or db:info/db:title][1]"/>
      <span class="indexed-section">
        <xsl:attribute name="title">
          <xsl:apply-templates select="$tobject" mode="m:headline">
            <xsl:with-param name="purpose" select="'index-tooltip'"/>
          </xsl:apply-templates>
        </xsl:attribute>

        <xsl:for-each select="$nodes">
          <xsl:variable name="pos" select="position()"/>
          <xsl:variable name="last" select="count(current-group())"/>

          <xsl:apply-templates select="." mode="mp:reference">
            <xsl:with-param name="scope" select="$scope"/>
            <xsl:with-param name="role" select="$role"/>
            <xsl:with-param name="type" select="$type"/>
            <xsl:with-param name="lang" select="$lang"/>
            <xsl:with-param name="separator" select="if ($pos = 1) then '' else ', '"/>
            <xsl:with-param name="position" select="$pos"/>
            <xsl:with-param name="last" select="$last"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </span>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$nodes[1]" mode="mp:reference">
        <xsl:with-param name="scope" select="$scope"/>
        <xsl:with-param name="role" select="$role"/>
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:indexterm" mode="mp:reference">
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>
  <xsl:param name="lang" select="'en'"/>
  <xsl:param name="separator" select="', '"/>
  <xsl:param name="position" as="xs:integer?"/>
  <xsl:param name="last" as="xs:integer?"/>

  <xsl:value-of select="$separator"/>
  <xsl:choose>
    <xsl:when test="@zone">
      <xsl:call-template name="t:index-zone-reference">
        <xsl:with-param name="zones" select="tokenize(@zone, '\s+')"/>
        <xsl:with-param name="scope" select="$scope"/>
        <xsl:with-param name="role" select="$role"/>
        <xsl:with-param name="type" select="$type"/>
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="tobject"
                    select="ancestor::*[db:title or db:info/db:title][1]"/>
      <a class="indexref" href="{f:href(/,.)}">
        <xsl:if test="not(f:is-true($indexed-section-groups))">
          <xsl:attribute name="title">
            <xsl:apply-templates select="$tobject" mode="m:headline">
              <xsl:with-param name="purpose" select="'index-tooltip'"/>
            </xsl:apply-templates>
          </xsl:attribute>
        </xsl:if>
        <xsl:sequence select="($position, position())[1]"/>
      </a>

      <xsl:if test="key('endofrange', @xml:id)[fp:scope(., $scope, $role, $type)]">
        <xsl:apply-templates select="key('endofrange', @xml:id)[fp:scope(., $scope, $role, $type)][last()]"
                             mode="mp:reference">
          <xsl:with-param name="scope" select="$scope"/>
          <xsl:with-param name="role" select="$role"/>
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="lang" select="$lang"/>
          <xsl:with-param name="separator" select="'-'"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="t:index-zone-reference">
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>
  <xsl:param name="lang" select="'en'"/>
  <xsl:param name="zones" as="xs:string*"/>

  <xsl:choose>
    <xsl:when test="empty($zones)"/>
    <xsl:otherwise>
      <xsl:variable name="zone" select="$zones[1]"/>
      <xsl:variable name="target" select="key('id', $zone)
                                             [fp:scope(., $scope, $role, $type)]"/>
      <xsl:choose>
        <xsl:when test="$target">
          <a class="indexref" href="{f:href(/,$target[1])}">
            <xsl:apply-templates select="$target[1]" mode="m:headline">
              <xsl:with-param name="purpose" select="'index'"/>
            </xsl:apply-templates>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="'Warning: missing zone:', $zone"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="count($zones) gt 1">
        <xsl:text>, </xsl:text>
        <xsl:call-template name="t:index-zone-reference">
          <xsl:with-param name="zones" select="substring-after($zones, ' ')"/>
          <xsl:with-param name="scope" select="$scope"/>
          <xsl:with-param name="role" select="$role"/>
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="lang" select="$lang"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:indexterm" mode="m:index-see">
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>
  <xsl:param name="lang" select="'en'"/>

  <span class="sep"> (</span>
   <xsl:apply-templates select="db:see" mode="m:crossref"/>
  <span class="sep">)</span>
</xsl:template>

<xsl:template match="db:indexterm" mode="m:index-seealso">
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>
  <xsl:param name="lang" select="'en'"/>

  <xsl:for-each select="db:seealso">
    <xsl:sort select="upper-case(.)" lang="{$lang}"/>
    <li>
      <span class="sep">(</span>
      <xsl:apply-templates select="." mode="m:crossref"/>
      <span class="sep">)</span>
    </li>
  </xsl:for-each>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:indexentry">
  <xsl:apply-templates select="db:primaryie"/>
</xsl:template>

<xsl:template match="db:primaryie">
  <li>
    <xsl:apply-templates/>
    <xsl:choose>
      <xsl:when test="following-sibling::db:secondaryie">
        <ul>
          <xsl:apply-templates select="following-sibling::db:secondaryie"/>
        </ul>
      </xsl:when>
      <xsl:when test="following-sibling::db:seeie
                      |following-sibling::db:seealsoie">
        <ul>
          <xsl:apply-templates select="following-sibling::db:seeie
                                       |following-sibling::db:seealsoie"/>
        </ul>
      </xsl:when>
    </xsl:choose>
  </li>
</xsl:template>

<xsl:template match="db:secondaryie">
  <li>
    <xsl:apply-templates/>
    <xsl:choose>
      <xsl:when test="following-sibling::db:tertiaryie">
        <ul>
          <xsl:apply-templates select="following-sibling::db:tertiaryie"/>
        </ul>
      </xsl:when>
      <xsl:when test="following-sibling::db:seeie
                      |following-sibling::db:seealsoie">
        <ul>
          <xsl:apply-templates select="following-sibling::db:seeie
                                       |following-sibling::db:seealsoie"/>
        </ul>
      </xsl:when>
    </xsl:choose>
  </li>
</xsl:template>

<xsl:template match="db:tertiaryie">
  <li>
    <xsl:apply-templates/>
    <xsl:if test="following-sibling::db:seeie
                  |following-sibling::db:seealsoie">
      <ul>
        <xsl:apply-templates select="following-sibling::db:seeie
                                     |following-sibling::db:seealsoie"/>
      </ul>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template match="db:seeie">
  <li>
    <xsl:sequence select="f:gentext(., 'label', 'see')"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
  </li>
</xsl:template>

<xsl:template match="db:seealsoie">
  <li>
    <xsl:sequence select="f:gentext(., 'label', 'seealso')"/>
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
  </li>
</xsl:template>

</xsl:stylesheet>
