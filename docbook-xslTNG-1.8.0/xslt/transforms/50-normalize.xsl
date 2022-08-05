<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:ghost="http://docbook.org/ns/docbook/ephemeral"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="db f ghost mp tp vp xs"
                version="3.0">

<xsl:import href="../modules/gentext.xsl"/>

<xsl:param name="glossary-collection" as="xs:string?" select="()"/>
<xsl:param name="bibliography-collection" as="xs:string?" select="()"/>
<xsl:param name="annotation-collection" as="xs:string?" select="()"/>

<!-- ============================================================ -->

<xsl:key name="id" match="*" use="@xml:id"/>

<xsl:variable name="vp:docbook-namespace" select="'http://docbook.org/ns/docbook'"/>
<xsl:variable name="vp:unify-table-titles" select="false()"/>

<!-- ============================================================ -->

<xsl:template match="/*" priority="100">
  <xsl:variable name="body" as="element()">
    <xsl:next-match/>
  </xsl:variable>

  <xsl:element name="{local-name($body)}"
               namespace="{namespace-uri($body)}">
    <xsl:copy-of select="$body/@*, $body/namespace-node()"/>
    <xsl:copy-of select="$body/node()"/>
    <!-- only copy top-level annotations -->
    <xsl:sequence select="$vp:external-annotations/*/db:annotation"/>
  </xsl:element>
</xsl:template>

<!-- ============================================================ -->
<!-- normalize content -->

<xsl:variable name="vp:external-glossary">
  <xsl:choose>
    <xsl:when test="$glossary-collection = ''">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:try select="document($glossary-collection)">
        <xsl:catch>
          <xsl:message>Failed to load $glossary-collection:</xsl:message>
          <xsl:message select="'    ' || $glossary-collection"/>
          <xsl:message select="'    ('||resolve-uri($glossary-collection)||')'"/>
          <xsl:sequence select="()"/>
        </xsl:catch>
      </xsl:try>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="vp:external-bibliography">
  <xsl:choose>
    <xsl:when test="$bibliography-collection = ''">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:try select="document($bibliography-collection)">
        <xsl:catch>
          <xsl:message>Failed to load $bibliography.collection:</xsl:message>
          <xsl:message select="'    ' || $bibliography-collection"/>
          <xsl:message select="'    ('||resolve-uri($bibliography-collection)||')'"/>
          <xsl:sequence select="()"/>
        </xsl:catch>
      </xsl:try>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="vp:external-annotations">
  <xsl:choose>
    <xsl:when test="$annotation-collection = ''">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:try select="document($annotation-collection)">
        <xsl:catch>
          <xsl:message>Failed to load $annotation.collection:</xsl:message>
          <xsl:message select="'    ' || $annotation-collection"/>
          <xsl:message select="'    ('||resolve-uri($annotation-collection)||')'"/>
          <xsl:sequence select="()"/>
        </xsl:catch>
      </xsl:try>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:template name="tp:normalize-movetitle">
  <xsl:copy>
    <xsl:copy-of select="@*"/>

    <xsl:choose>
      <xsl:when test="db:info">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="db:title|db:subtitle|db:titleabbrev">
        <xsl:element name="info" namespace="{$vp:docbook-namespace}">
          <xsl:call-template name="tp:normalize-dbinfo">
            <xsl:with-param name="copynodes"
                            select="db:title|db:subtitle|db:titleabbrev"/>
          </xsl:call-template>
        </xsl:element>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:copy>
</xsl:template>

<xsl:template match="db:title|db:subtitle|db:titleabbrev">
  <xsl:if test="parent::db:info
                |parent::db:biblioentry
                |parent::db:bibliomixed
                |parent::db:bibliomset
                |parent::db:biblioset">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:if>
</xsl:template>

<xsl:template match="db:bibliography|db:revhistory">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:bibliomixed|db:biblioentry">
  <xsl:choose>
    <xsl:when test="empty(node())"> <!-- totally empty -->
      <xsl:variable name="id" select="@xml:id"/>
      <xsl:choose>
        <xsl:when test="not($id)">
          <xsl:message>
            <xsl:text>Error: </xsl:text>
            <xsl:text>empty </xsl:text>
            <xsl:value-of select="local-name(.)"/>
            <xsl:text> with no id.</xsl:text>
          </xsl:message>
        </xsl:when>
        <xsl:when test="$vp:external-bibliography/key('id', $id)">
          <xsl:apply-templates select="$vp:external-bibliography/key('id', $id)"
                              />
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>Error: </xsl:text>
            <xsl:text>$bibliography-collection doesn't contain </xsl:text>
            <xsl:value-of select="$id"/>
          </xsl:message>
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>???</xsl:text>
          </xsl:copy>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:glossary">
  <xsl:variable name="glossary">
    <xsl:call-template name="tp:normalize-generated-title">
      <xsl:with-param name="title-key" select="local-name(.)"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$glossary/db:glossary[@role='auto']">
      <xsl:if test="not($vp:external-glossary)">
        <xsl:message>
          <xsl:text>Warning: processing automatic glossary </xsl:text>
          <xsl:text>without an external glossary.</xsl:text>
        </xsl:message>
      </xsl:if>

      <xsl:element name="glossary" namespace="{$vp:docbook-namespace}">
        <xsl:for-each select="$glossary/db:glossary/@*">
          <xsl:if test="name(.) != 'role'">
            <xsl:copy-of select="."/>
          </xsl:if>
        </xsl:for-each>
        <xsl:copy-of select="$glossary/db:glossary/db:info"/>

        <xsl:variable name="seealsos" as="element()*">
          <xsl:for-each select="$vp:external-glossary//db:glossseealso">
            <xsl:copy-of select="if (key('id', @otherterm))
                                  then key('id', @otherterm)[1]
                                  else key('glossterm', string(.))"/>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="divs"
                      select="$glossary//db:glossary/db:glossdiv"/>

        <xsl:choose>
          <xsl:when test="$divs and $vp:external-glossary//db:glossdiv">
            <xsl:apply-templates select="$vp:external-glossary//db:glossdiv"
                                 mode="mp:copy-external-glossary">
              <xsl:with-param name="terms"
                              select="//db:glossterm[not(parent::db:glossdef)]
                                      |//db:firstterm
                                      |$seealsos"/>
              <xsl:with-param name="divs" select="$divs"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$vp:external-glossary//db:glossentry"
                                 mode="mp:copy-external-glossary">
              <xsl:with-param name="terms"
                              select="//db:glossterm[not(parent::db:glossdef)]
                                      |//db:firstterm
                                      |$seealsos"/>
              <xsl:with-param name="divs" select="$divs"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$glossary"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:index">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:setindex">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:abstract">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:legalnotice">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:dedication|db:acknowledgements">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:note">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:tip">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:caution">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:warning">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:danger">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:important">
  <xsl:call-template name="tp:normalize-generated-title">
    <xsl:with-param name="title-key" select="local-name(.)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="db:dialogue|db:colophon|db:partintro|db:productionset
                     |db:calloutlist|db:orderedlist|db:itemizedlist
                     |db:qandaset|db:qandadiv|db:qandaentry
                     |db:bibliolist|db:glosslist|db:segmentedlist
                     |db:equation|db:poetry|db:blockquote|db:refentry
                     |db:screenshot|db:procedure|db:step|db:stepalternatives">
  <xsl:call-template name="tp:normalize-optional-title"/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="tp:normalize-generated-title">
  <xsl:param name="title-key"/>

  <xsl:choose>
    <xsl:when test="db:title|db:info/db:title">
      <xsl:call-template name="tp:normalize-movetitle"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="@*"/>

        <xsl:choose>
          <xsl:when test="db:info">
            <xsl:element name="info" namespace="{$vp:docbook-namespace}">
              <xsl:copy-of select="db:info/@*"/>
              <xsl:element name="title" namespace="{$vp:docbook-namespace}">
                <xsl:apply-templates select="." mode="tp:normalized-title">
                  <xsl:with-param name="title-key" select="$title-key"/>
                </xsl:apply-templates>
              </xsl:element>
              <xsl:copy-of select="db:info/preceding-sibling::node()"/>
              <xsl:copy-of select="db:info/*"/>
            </xsl:element>

            <xsl:apply-templates select="db:info/following-sibling::node()"/>
          </xsl:when>

          <xsl:otherwise>
            <xsl:variable name="node-tree">
              <xsl:element name="title" namespace="{$vp:docbook-namespace}">
                <xsl:attribute name="ghost:title" select="'yes'"/>
                <xsl:apply-templates select="." mode="tp:normalized-title">
                  <xsl:with-param name="title-key" select="$title-key"/>
                </xsl:apply-templates>
              </xsl:element>
            </xsl:variable>

            <xsl:element name="info" namespace="{$vp:docbook-namespace}">
              <xsl:call-template name="tp:normalize-dbinfo">
                <xsl:with-param name="copynodes" select="$node-tree/*"/>
              </xsl:call-template>
            </xsl:element>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="tp:normalized-title">
  <xsl:param name="title-key"/>
  <xsl:sequence select="f:gentext(., 'title', local-name(.))"/>
</xsl:template>

<xsl:template match="db:info">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:if test="not(db:title)">
      <xsl:copy-of select="preceding-sibling::db:title"/>
    </xsl:if>
    <xsl:call-template name="tp:normalize-dbinfo"/>
  </xsl:copy>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="tp:normalize-optional-title">
  <xsl:choose>
    <xsl:when test="db:title|db:info/db:title">
      <xsl:call-template name="tp:normalize-movetitle"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="@*"/>

        <xsl:choose>
          <xsl:when test="db:info">
            <xsl:element name="info" namespace="{$vp:docbook-namespace}">
              <xsl:copy-of select="db:info/@*"/>
              <xsl:copy-of select="db:info/preceding-sibling::node()"/>
              <xsl:copy-of select="db:info/*"/>
            </xsl:element>

            <xsl:apply-templates select="db:info/following-sibling::node()"
                                />
          </xsl:when>

          <xsl:otherwise>
            <xsl:element name="info" namespace="{$vp:docbook-namespace}">
              <xsl:call-template name="tp:normalize-dbinfo"/>
            </xsl:element>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<xsl:template name="tp:normalize-dbinfo">
  <xsl:param name="copynodes"/>

  <xsl:for-each select="$copynodes">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:for-each>

  <xsl:if test="self::db:info">
    <xsl:apply-templates/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:inlinemediaobject
                     [(parent::db:programlisting
                       or parent::db:screen
                       or parent::db:literallayout
                       or parent::db:address
                       or parent::db:funcsynopsisinfo)
                     and db:imageobject
                     and db:imageobject/db:imagedata[@format='linespecific']]">
  <xsl:variable name="data"
                select="(db:imageobject
                         /db:imagedata[@format='linespecific'])[1]"/>
  <xsl:choose>
    <xsl:when test="$data/@entityref">
      <xsl:value-of select="unparsed-text(unparsed-entity-uri($data/@entityref))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of
          select="unparsed-text(resolve-uri($data/@fileref, base-uri(.)))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:textobject
                     [parent::db:programlisting
                      or parent::db:screen
                      or parent::db:literallayout
                      or parent::db:address
                      or parent::db:funcsynopsisinfo]">
  <xsl:choose>
    <xsl:when test="db:textdata/@entityref">
      <xsl:value-of select="unparsed-text(unparsed-entity-uri(db:textdata/@entityref))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="unparsed-text(resolve-uri(db:textdata/@fileref, base-uri(.)))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*">
  <xsl:choose>
    <xsl:when test="db:title|db:subtitle|db:titleabbrev|db:info/db:title">
      <xsl:choose>
        <xsl:when test="parent::db:biblioentry
                        |parent::db:bibliomixed
                        |parent::db:bibliomset
                        |parent::db:biblioset">
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
          </xsl:copy>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="tp:normalize-movetitle"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()|attribute()">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->
<!-- copy external glossary -->

<xsl:template match="db:glossdiv" mode="mp:copy-external-glossary">
  <xsl:param name="terms"/>
  <xsl:param name="divs"/>

  <xsl:variable name="entries" as="element()*">
    <xsl:apply-templates select="db:glossentry" mode="mp:copy-external-glossary">
      <xsl:with-param name="terms" select="$terms"/>
      <xsl:with-param name="divs" select="$divs"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:if test="$entries">
    <xsl:choose>
      <xsl:when test="$divs">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:copy-of select="db:info"/>
          <xsl:copy-of select="$entries"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$entries"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="db:glossentry" mode="mp:copy-external-glossary">
  <xsl:param name="terms"/>
  <xsl:param name="divs"/>

  <xsl:variable name="include"
                select="for $dterm in $terms
                           return
                              for $gterm in db:glossterm
                                 return
                                    if (string($dterm) = string($gterm)
                                        or $dterm/@baseform = string($gterm))
                                    then 'x'
                                    else ()"/>

  <xsl:if test="$include != ''">
    <xsl:copy-of select="."/>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="mp:copy-external-glossary">
  <xsl:param name="terms"/>
  <xsl:param name="divs"/>

  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="mp:copy-external-glossary">
      <xsl:with-param name="terms" select="$terms"/>
      <xsl:with-param name="divs" select="$divs"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:informaltable[db:tr]
                     |db:table[db:tr]"
              xmlns="http://docbook.org/ns/docbook">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>

    <xsl:for-each-group select="*" group-by="node-name(.)">
      <xsl:choose>
        <xsl:when test="current-group()[1]/self::db:tr">
          <tbody>
            <xsl:sequence select="current-group()"/>
          </tbody>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="current-group()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:copy>
</xsl:template>

<!-- If we're unifying titles, turn the caption into a title. -->
<xsl:template match="db:table/db:caption"
              xmlns="http://docbook.org/ns/docbook">
  <xsl:choose>
    <xsl:when test="$vp:unify-table-titles">
      <info>
        <title>
          <xsl:apply-templates select="@*,node()"/>
        </title>
      </info>
    </xsl:when>
    <xsl:otherwise>
      <xsl:next-match/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
