<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db = "http://docbook.org/ns/docbook"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="db fp mp t tp xlink xs"
                version="3.0">

<xsl:import href="../environment.xsl"/>

<!-- This stylesheet attempts to convert DocBook V4.x into DocBook V5.x -->
<xsl:param name="version" as="xs:string" select="'1.0'"/>
<xsl:param name="base-uri" as="xs:string?" select="()"/>

<xsl:variable name="verbose" as="xs:boolean" select="'db4to5' = $debug"/>

<xsl:output method="xml" encoding="utf-8" indent="no"/>

<!-- Let the next phase deal with where space is insignificant -->
<xsl:preserve-space elements="*"/>

<xsl:template match="/" name="t:main">
  <xsl:param name="context" select="."/>
  <xsl:variable name="context-as-document" as="document-node()">
    <xsl:document>
      <xsl:sequence select="$context"/>
    </xsl:document>
  </xsl:variable>

  <xsl:variable name="converted" as="document-node()">
    <xsl:document>
      <xsl:apply-templates select="$context-as-document" mode="mp:root"/>
    </xsl:document>
  </xsl:variable>

  <xsl:apply-templates select="$converted" mode="mp:addNS"/>
</xsl:template>

<xsl:template match="/" mode="mp:root">
  <xsl:comment>
    <xsl:text> DocBook V4.x converted to DocBook V5.x</xsl:text>
    <xsl:text> by 10-db4to5.xsl version </xsl:text>
    <xsl:value-of select="$version"/>
    <xsl:text> </xsl:text>
  </xsl:comment>
  <xsl:text>&#10;</xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="bookinfo|chapterinfo|articleinfo|artheader|appendixinfo
                     |blockinfo
                     |bibliographyinfo|glossaryinfo|indexinfo|setinfo
                     |setindexinfo
                     |sect1info|sect2info|sect3info|sect4info|sect5info
                     |sectioninfo
                     |refsect1info|refsect2info|refsect3info|refsectioninfo
                     |referenceinfo|partinfo"
              priority="200">
  <info>
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:call-template name="tp:fix-titles"/>
    <xsl:apply-templates/>
  </info>
</xsl:template>

<xsl:template match="objectinfo|prefaceinfo|refsynopsisdivinfo
                     |screeninfo|sidebarinfo"
              priority="200">
  <info>
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:call-template name="tp:fix-titles">
      <xsl:with-param name="optional-title" select="true()"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </info>
</xsl:template>

<xsl:template name="tp:fix-titles">
  <xsl:param name="optional-title" as="xs:boolean" select="false()"/>

  <!-- titles can be inside or outside or both. fix that -->
  <xsl:choose>
    <xsl:when test="title and following-sibling::title">
      <xsl:if test="title != following-sibling::title">
        <xsl:if test="$verbose">
          <xsl:message select="'Check', name(..), 'title'"/>
        </xsl:if>
        <xsl:apply-templates select="title" mode="mp:copy"/>
      </xsl:if>
    </xsl:when>
    <xsl:when test="title">
      <xsl:apply-templates select="title" mode="mp:copy"/>
    </xsl:when>
    <xsl:when test="following-sibling::title">
      <xsl:apply-templates select="following-sibling::title" mode="mp:copy"/>
    </xsl:when>
    <xsl:when test="$optional-title"/>
    <xsl:otherwise>
        <xsl:if test="$verbose">
          <xsl:message select="'Check', name(..), ': no title'"/>
        </xsl:if>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="titleabbrev and following-sibling::titleabbrev">
      <xsl:if test="titleabbrev != following-sibling::titleabbrev">
        <xsl:if test="$verbose">
          <xsl:message select="'Check', name(..), 'titleabbrev'"/>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select="titleabbrev" mode="mp:copy"/>
    </xsl:when>
    <xsl:when test="titleabbrev">
      <xsl:apply-templates select="titleabbrev" mode="mp:copy"/>
    </xsl:when>
    <xsl:when test="following-sibling::titleabbrev">
      <xsl:apply-templates select="following-sibling::titleabbrev" mode="mp:copy"/>
    </xsl:when>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="subtitle and following-sibling::subtitle">
      <xsl:if test="subtitle != following-sibling::subtitle">
        <xsl:if test="$verbose">
          <xsl:message select="'Check', name(..), 'subtitle'"/>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select="subtitle" mode="mp:copy"/>
    </xsl:when>
    <xsl:when test="subtitle">
      <xsl:apply-templates select="subtitle" mode="mp:copy"/>
    </xsl:when>
    <xsl:when test="following-sibling::subtitle">
      <xsl:apply-templates select="following-sibling::subtitle" mode="mp:copy"/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="refentryinfo"
              priority="200">
  <info>
    <xsl:call-template name="tp:copy-attributes"/>

    <xsl:if test="title">
        <xsl:if test="$verbose">
          <xsl:message select="'Discarding title from refentryinfo'"/>
        </xsl:if>
    </xsl:if>

    <xsl:if test="titleabbrev">
        <xsl:if test="$verbose">
          <xsl:message select="'Discarding titleabbrev from refentryinfo'"/>
        </xsl:if>
    </xsl:if>

    <xsl:if test="subtitle">
        <xsl:if test="$verbose">
          <xsl:message select="'Discarding subtitle from refentryinfo'"/>
        </xsl:if>
    </xsl:if>

    <xsl:apply-templates/>
  </info>
</xsl:template>

<xsl:template match="refmiscinfo"
              priority="200">
  <refmiscinfo>
    <xsl:call-template name="tp:copy-attributes">
      <xsl:with-param name="suppress" select="'class'"/>
    </xsl:call-template>

    <xsl:if test="@class">
      <xsl:choose>
        <xsl:when test="@class = 'source'
                        or @class = 'version'
                        or @class = 'manual'
                        or @class = 'sectdesc'
                        or @class = 'software'">
          <xsl:copy-of select="@class"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class" select="'other'"/>
          <xsl:attribute name="otherclass" select="@class"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </refmiscinfo>
</xsl:template>

<xsl:template match="corpauthor"
              priority="200">
  <author>
    <xsl:call-template name="tp:copy-attributes"/>
    <orgname>
      <xsl:apply-templates/>
    </orgname>
  </author>
</xsl:template>

<xsl:template match="corpname"
              priority="200">
  <orgname>
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates/>
  </orgname>
</xsl:template>

<xsl:template match="author[not(personname)]
                     |editor[not(personname)]
                     |othercredit[not(personname)]"
              priority="200">
  <xsl:copy>
    <xsl:call-template name="tp:copy-attributes"/>
    <personname>
      <xsl:apply-templates select="honorific|firstname|surname|othername|lineage"/>
    </personname>
    <xsl:apply-templates select="*[not(self::honorific|self::firstname|self::surname
                                   |self::othername|self::lineage)]"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="address|programlisting|screen|funcsynopsisinfo
                     |classsynopsisinfo|literallayout"
              priority="200">
  <xsl:copy>
    <xsl:call-template name="tp:copy-attributes">
      <xsl:with-param name="suppress" select="'format'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="productname[@class]"
              priority="200">
        <xsl:if test="$verbose">
          <xsl:message select="'Dropping class attribute from productname'"/>
        </xsl:if>
  <xsl:copy>
    <xsl:call-template name="tp:copy-attributes">
      <xsl:with-param name="suppress" select="'class'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="dedication|preface|chapter|appendix|part|partintro
                     |article|bibliography|glossary|glossdiv|index
                     |reference[not(referenceinfo)]|book"
              priority="200">
  <xsl:choose>
    <xsl:when test="not(dedicationinfo|prefaceinfo|chapterinfo
                        |appendixinfo|partinfo
                        |articleinfo|artheader|bibliographyinfo
                        |glossaryinfo|indexinfo
                        |bookinfo)">
      <xsl:copy>
        <xsl:call-template name="tp:copy-attributes"/>
        <xsl:where-populated>
          <info>
            <xsl:apply-templates select="title" mode="mp:copy"/>
            <xsl:apply-templates select="titleabbrev" mode="mp:copy"/>
            <xsl:apply-templates select="subtitle" mode="mp:copy"/>
            <xsl:apply-templates select="abstract" mode="mp:copy"/>
          </info>
        </xsl:where-populated>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:call-template name="tp:copy-attributes"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="formalpara|figure|table[tgroup]|example|blockquote
                     |caution|important|note|warning|tip
                     |bibliodiv|glossarydiv|indexdiv
                     |orderedlist|itemizedlist|variablelist|procedure
                     |task|tasksummary|taskprerequisites|taskrelated
                     |sidebar"
              priority="200">
  <xsl:choose>
    <xsl:when test="blockinfo">
      <xsl:copy>
        <xsl:call-template name="tp:copy-attributes"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:call-template name="tp:copy-attributes"/>
        <xsl:where-populated>
          <info>
            <xsl:apply-templates select="title" mode="mp:copy"/>
            <xsl:apply-templates select="titleabbrev" mode="mp:copy"/>
            <xsl:apply-templates select="subtitle" mode="mp:copy"/>
          </info>
        </xsl:where-populated>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="equation" priority="200">
  <xsl:choose>
    <xsl:when test="not(title)">
        <xsl:if test="$verbose">
          <xsl:message select="'Convert equation without title to informal equation'"/>
        </xsl:if>
      <informalequation>
        <xsl:call-template name="tp:copy-attributes"/>
        <xsl:apply-templates/>
      </informalequation>
    </xsl:when>
    <xsl:when test="blockinfo">
      <xsl:copy>
        <xsl:call-template name="tp:copy-attributes"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:call-template name="tp:copy-attributes"/>
        <xsl:where-populated>
          <info>
            <xsl:apply-templates select="title" mode="mp:copy"/>
            <xsl:apply-templates select="titleabbrev" mode="mp:copy"/>
            <xsl:apply-templates select="subtitle" mode="mp:copy"/>
          </info>
        </xsl:where-populated>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="sect1|sect2|sect3|sect4|sect5|section" priority="200">
  <section>
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:if test="not(sect1info|sect2info|sect3info|sect4info|sect5info|sectioninfo)">
      <info>
        <xsl:apply-templates select="title" mode="mp:copy"/>
        <xsl:apply-templates select="titleabbrev" mode="mp:copy"/>
        <xsl:apply-templates select="subtitle" mode="mp:copy"/>
        <xsl:apply-templates select="abstract" mode="mp:copy"/>
      </info>
    </xsl:if>
    <xsl:apply-templates/>
  </section>
</xsl:template>

<xsl:template match="simplesect" priority="200">
  <simplesect>
    <xsl:call-template name="tp:copy-attributes"/>
    <info>
      <xsl:apply-templates select="title" mode="mp:copy"/>
      <xsl:apply-templates select="titleabbrev" mode="mp:copy"/>
      <xsl:apply-templates select="subtitle" mode="mp:copy"/>
      <xsl:apply-templates select="abstract" mode="mp:copy"/>
    </info>
    <xsl:apply-templates/>
  </simplesect>
</xsl:template>

<xsl:template match="refsect1|refsect2|refsect3|refsection"
              priority="200">
  <refsection>
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:if test="not(refsect1info|refsect2info|refsect3info|refsectioninfo)">
      <info>
        <xsl:apply-templates select="title" mode="mp:copy"/>
        <xsl:apply-templates select="titleabbrev" mode="mp:copy"/>
        <xsl:apply-templates select="subtitle" mode="mp:copy"/>
        <xsl:apply-templates select="abstract" mode="mp:copy"/>
      </info>
    </xsl:if>
    <xsl:apply-templates/>
  </refsection>
</xsl:template>

<xsl:template match="imagedata|videodata|audiodata|textdata"
              priority="200">
  <xsl:copy>
    <xsl:call-template name="tp:copy-attributes">
      <xsl:with-param name="suppress" select="'srccredit'"/>
    </xsl:call-template>
    <xsl:if test="@srccredit">
        <xsl:if test="$verbose">
          <xsl:message select="'Check conversion of srccredit (othercredit=srccredit)'"/>
        </xsl:if>
      <info>
        <othercredit class="other" otherclass="srccredit">
          <orgname>???</orgname>
          <contrib>
            <xsl:value-of select="@srccredit"/>
          </contrib>
        </othercredit>
      </info>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<xsl:template match="sgmltag" priority="200">
  <tag>
    <xsl:call-template name="tp:copy-attributes">
      <xsl:with-param name="suppress" select="'class'"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="not(@class)"/>
      <xsl:when test="@class = 'sgmlcomment'">
        <xsl:attribute name="class" select="'comment'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="@class"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
  </tag>
</xsl:template>

<xsl:template match="inlinegraphic[@format='linespecific']"
              priority="210">
  <textobject>
    <textdata>
      <xsl:call-template name="tp:copy-attributes"/>
    </textdata>
  </textobject>
</xsl:template>

<xsl:template match="inlinegraphic"
              priority="200">
  <inlinemediaobject>
    <imageobject>
      <imagedata>
        <xsl:call-template name="tp:copy-attributes"/>
      </imagedata>
    </imageobject>
  </inlinemediaobject>
</xsl:template>

<xsl:template match="graphic[@format='linespecific']"
              priority="210">
  <mediaobject>
    <textobject>
      <textdata>
        <xsl:call-template name="tp:copy-attributes"/>
      </textdata>
    </textobject>
  </mediaobject>
</xsl:template>

<xsl:template match="graphic" priority="200">
  <mediaobject>
    <imageobject>
      <imagedata>
        <xsl:call-template name="tp:copy-attributes"/>
      </imagedata>
    </imageobject>
  </mediaobject>
</xsl:template>

<xsl:template match="pubsnumber" priority="200">
  <biblioid class="pubsnumber">
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates/>
  </biblioid>
</xsl:template>

<xsl:template match="invpartnumber" priority="200">
        <xsl:if test="$verbose">
          <xsl:message select="'Converting invpartnumber to biblioid otherclass=invpartnumber'"/>
        </xsl:if>
  <biblioid class="other" otherclass="invpartnumber">
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates/>
  </biblioid>
</xsl:template>

<xsl:template match="contractsponsor" priority="200">
  <xsl:variable name="contractnum"
                select="preceding-sibling::contractnum|following-sibling::contractnum"/>

        <xsl:if test="$verbose">
          <xsl:message select="'Converting contractsponsor to othercredit=contractsponsor'"/>
        </xsl:if>

  <othercredit class="other" otherclass="contractsponsor">
    <orgname>
      <xsl:call-template name="tp:copy-attributes"/>
      <xsl:apply-templates/>
    </orgname>
    <xsl:for-each select="$contractnum">
      <contrib role="contractnum">
        <xsl:apply-templates select="node()"/>
      </contrib>
    </xsl:for-each>
  </othercredit>
</xsl:template>

<xsl:template match="contractnum" priority="200">
  <xsl:if test="not(preceding-sibling::contractsponsor
                    |following-sibling::contractsponsor)
                and not(preceding-sibling::contractnum)">
        <xsl:if test="$verbose">
          <xsl:message select="'Converting contractnum to othercredit=contractnum'"/>
        </xsl:if>
    <othercredit class="other" otherclass="contractnum">
      <orgname>???</orgname>
      <xsl:for-each select="self::contractnum
                            |preceding-sibling::contractnum
                            |following-sibling::contractnum">
        <contrib>
          <xsl:apply-templates select="node()"/>
        </contrib>
      </xsl:for-each>
    </othercredit>
  </xsl:if>
</xsl:template>

<xsl:template match="isbn|issn" priority="200">
  <biblioid class="{local-name(.)}">
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates/>
  </biblioid>
</xsl:template>

<xsl:template match="biblioid[count(*) = 1
                              and ulink
                              and normalize-space(text()) = '']"
              priority="200">
  <biblioid xlink:href="{ulink/@url}">
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates select="ulink/node()"/>
  </biblioid>
</xsl:template>

<xsl:template match="authorblurb" priority="200">
  <personblurb>
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates/>
  </personblurb>
</xsl:template>

<xsl:template match="collabname" priority="200">
        <xsl:if test="$verbose">
          <xsl:message select="'Check conversion of collabname (orgname role=collabname)'"/>
        </xsl:if>
  <orgname role="collabname">
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates/>
  </orgname>
</xsl:template>

<xsl:template match="modespec" priority="200">
        <xsl:if test="$verbose">
          <xsl:message select="'Discarding modespec (', string(.), ')'"/>
        </xsl:if>
</xsl:template>

<xsl:template match="mediaobjectco" priority="200">
  <mediaobject>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </mediaobject>
</xsl:template>

<xsl:template match="remark" priority="200">
  <!-- get rid of any embedded markup -->
  <remark>
    <xsl:copy-of select="@*"/>
    <xsl:value-of select="."/>
  </remark>
</xsl:template>

<xsl:template match="biblioentry/title
                     |bibliomset/title
                     |biblioset/title
                     |bibliomixed/title"
              priority="400">
  <citetitle>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </citetitle>
</xsl:template>

<xsl:template match="biblioentry/titleabbrev|biblioentry/subtitle
                     |bibliomset/titleabbrev|bibliomset/subtitle
                     |biblioset/titleabbrev|biblioset/subtitle
                     |bibliomixed/titleabbrev|bibliomixed/subtitle"
              priority="400">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="biblioentry/contrib
                     |bibliomset/contrib
                     |bibliomixed/contrib"
              priority="200">
        <xsl:if test="$verbose">
          <xsl:message select="'Check conversion of contrib (othercontrib=contrib)'"/>
        </xsl:if>
  <othercredit class="other" otherclass="contrib">
    <orgname>???</orgname>
    <contrib>
      <xsl:call-template name="tp:copy-attributes"/>
      <xsl:apply-templates/>
    </contrib>
  </othercredit>
</xsl:template>

<xsl:template match="link" priority="200">
  <xsl:copy>
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="ulink" priority="200">
  <xsl:choose>
    <xsl:when test="node()">
        <xsl:if test="$verbose">
          <xsl:message select="'Converting ulink to link'"/>
        </xsl:if>
      <link xlink:href="{@url}">
        <xsl:call-template name="tp:copy-attributes">
          <xsl:with-param name="suppress" select="'url'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
      </link>
    </xsl:when>
    <xsl:otherwise>
        <xsl:if test="$verbose">
          <xsl:message select="'Converting ulink to uri'"/>
        </xsl:if>
      <uri xlink:href="{@url}">
        <xsl:call-template name="tp:copy-attributes">
          <xsl:with-param name="suppress" select="'url'"/>
        </xsl:call-template>
        <xsl:value-of select="@url"/>
      </uri>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="olink" priority="200">
  <xsl:if test="@linkmode">
        <xsl:if test="$verbose">
          <xsl:message select="'Discarding linkmode on olink'"/>
        </xsl:if>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="@targetdocent">
        <xsl:if test="$verbose">
          <xsl:message select="'Converting olink targetdocent to targetdoc'"/>
        </xsl:if>

      <olink targetdoc="{unparsed-entity-uri(@targetdocent)}">
        <xsl:for-each select="@*">
          <xsl:if test="name(.) != 'targetdocent'
                        and name(.) != 'linkmode'">
            <xsl:copy/>
          </xsl:if>
        </xsl:for-each>
        <xsl:apply-templates/>
      </olink>
    </xsl:when>
    <xsl:otherwise>
      <olink>
        <xsl:for-each select="@*">
          <xsl:if test="name(.) != 'linkmode'">
            <xsl:copy/>
          </xsl:if>
        </xsl:for-each>
        <xsl:apply-templates/>
      </olink>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="biblioentry/firstname
                     |biblioentry/surname
                     |biblioentry/othername
                     |biblioentry/lineage
                     |biblioentry/honorific
                     |bibliomset/firstname
                     |bibliomset/surname
                     |bibliomset/othername
                     |bibliomset/lineage
                     |bibliomset/honorific"
              priority="200">
  <xsl:choose>
    <xsl:when test="preceding-sibling::firstname
                    |preceding-sibling::surname
                    |preceding-sibling::othername
                    |preceding-sibling::lineage
                    |preceding-sibling::honorific">
      <!-- nop -->
    </xsl:when>
    <xsl:otherwise>
      <personname>
        <xsl:apply-templates select="../firstname
                                     |../surname
                                     |../othername
                                     |../lineage
                                     |../honorific" mode="mp:copy"/>
      </personname>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="areaset" priority="200">
  <xsl:copy>
    <xsl:call-template name="tp:copy-attributes">
      <xsl:with-param name="suppress" select="'coords'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="date|pubdate" priority="200">
  <xsl:variable name="rp1"
                select="substring-before(normalize-space(.), ' ')"/>
  <xsl:variable name="rp2"
                select="substring-before(substring-after(normalize-space(.), ' '),
                                         ' ')"/>
  <xsl:variable name="rp3"
                select="substring-after(substring-after(normalize-space(.), ' '), ' ')"/>

  <xsl:variable name="p1">
    <xsl:choose>
      <xsl:when test="contains($rp1, ',')">
        <xsl:value-of select="substring-before($rp1, ',')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$rp1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="p2">
    <xsl:choose>
      <xsl:when test="contains($rp2, ',')">
        <xsl:value-of select="substring-before($rp2, ',')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$rp2"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="p3">
    <xsl:choose>
      <xsl:when test="contains($rp3, ',')">
        <xsl:value-of select="substring-before($rp3, ',')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$rp3"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="date">
    <xsl:choose>
      <xsl:when test="$p3 castable as xs:integer and $p1 castable as xs:integer">
        <xsl:choose>
          <xsl:when test="$p2 = 'Jan' or $p2 = 'January'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-01-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:when test="$p2 = 'Feb' or $p2 = 'February'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-02-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:when test="$p2 = 'Mar' or $p2 = 'March'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-03-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:when test="$p2 = 'Apr' or $p2 = 'April'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-04-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:when test="$p2 = 'May'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-05-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:when test="$p2 = 'Jun' or $p2 = 'June'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-06-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:when test="$p2 = 'Jul' or $p2 = 'July'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-07-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:when test="$p2 = 'Aug' or $p2 = 'August'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-08-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:when test="$p2 = 'Sep' or $p2 = 'September'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-09-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:when test="$p2 = 'Oct' or $p2 = 'October'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-10-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:when test="$p2 = 'Nov' or $p2 = 'November'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-11-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:when test="$p2 = 'Dec' or $p2 = 'December'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-12-</xsl:text>
            <xsl:number value="xs:integer($p1)" format="01"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$p2 castable as xs:integer and $p3 castable as xs:integer">
        <xsl:choose>
          <xsl:when test="$p1 = 'Jan' or $p1 = 'January'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-01-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:when test="$p1 = 'Feb' or $p1 = 'February'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-02-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:when test="$p1 = 'Mar' or $p1 = 'March'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-03-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:when test="$p1 = 'Apr' or $p1 = 'April'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-04-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:when test="$p1 = 'May'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-05-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:when test="$p1 = 'Jun' or $p1 = 'June'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-06-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:when test="$p1 = 'Jul' or $p1 = 'July'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-07-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:when test="$p1 = 'Aug' or $p1 = 'August'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-08-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:when test="$p1 = 'Sep' or $p1 = 'September'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-09-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:when test="$p1 = 'Oct' or $p1 = 'October'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-10-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:when test="$p1 = 'Nov' or $p1 = 'November'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-11-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:when test="$p1 = 'Dec' or $p1 = 'December'">
            <xsl:number value="xs:integer($p3)" format="0001"/>
            <xsl:text>-12-</xsl:text>
            <xsl:number value="xs:integer($p2)" format="01"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="normalize-space($date) != normalize-space(.)">
        <xsl:if test="$verbose">
          <xsl:message select="'Converted', normalize-space(.), 'into ',
                           $date, ' for', name(.)"/>
        </xsl:if>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:value-of select="$date"/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="title|subtitle|titleabbrev" priority="300">
  <!-- nop -->
</xsl:template>

<xsl:template match="abstract" priority="300">
  <xsl:if test="not(contains(name(parent::*),'info'))">
        <xsl:if test="$verbose">
          <xsl:message select="'Check abstract; moved into info correctly?'"/>
        </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="indexterm">
  <!-- don't copy the defaulted significance='normal' attribute -->
  <indexterm>
    <xsl:call-template name="tp:copy-attributes">
      <xsl:with-param name="suppress"
                      select="if (@significance = 'normal')
                              then 'significance'
                              else ()"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </indexterm>
</xsl:template>

<xsl:template match="ackno" priority="200">
  <acknowledgements>
    <xsl:copy-of select="@*"/>
    <para>
      <xsl:apply-templates/>
    </para>
  </acknowledgements>
</xsl:template>

<xsl:template match="lot|lotentry|tocback|tocchap|tocfront|toclevel1|
                     toclevel2|toclevel3|toclevel4|toclevel5|tocpart"
              priority="200">
  <tocdiv>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </tocdiv>
</xsl:template>

<xsl:template match="action" priority="200">
  <phrase remap="action">
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates/>
  </phrase>
</xsl:template>

<xsl:template match="beginpage" priority="200">
  <xsl:comment> beginpage pagenum=<xsl:value-of select="@pagenum"/> </xsl:comment>
  <xsl:if test="$verbose">
    <xsl:message select="'Replacing beginpage with comment'"/>
  </xsl:if>
</xsl:template>

<xsl:template match="structname|structfield" priority="200">
  <varname remap="{local-name(.)}">
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates/>
  </varname>
</xsl:template>

<xsl:template match="*" mode="mp:copy">
  <xsl:copy>
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template match="element()">
  <xsl:copy>
    <xsl:call-template name="tp:copy-attributes"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()">
  <xsl:copy/>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template name="tp:copy-attributes">
  <xsl:param name="src" as="element()" select="."/>
  <xsl:param name="suppress" as="xs:string?" select="()"/>

  <xsl:for-each select="$src/@*">
    <xsl:choose>
      <xsl:when test="$suppress = local-name(.)"/>
      <xsl:when test="local-name(.) = 'moreinfo'">
        <xsl:if test="$verbose">
          <xsl:message select="'Discarding moreinfo on', local-name($src)"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="local-name(.) = 'lang'">
        <xsl:attribute name="xml:lang" select="."/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'id'">
        <xsl:attribute name="xml:id" select="."/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'float'">
        <xsl:choose>
          <xsl:when test=". = '1'">
        <xsl:if test="$verbose">
          <xsl:message select="'Discarding float on', local-name($src)"/>
        </xsl:if>
            <xsl:if test="not($src/@floatstyle)">
              <xsl:attribute name="floatstyle" select="'normal'"/>
        <xsl:if test="$verbose">
          <xsl:message select="'Adding floatstyle=normal on', local-name($src)"/>
        </xsl:if>
            </xsl:if>
          </xsl:when>
          <xsl:when test=". = '0'">
        <xsl:if test="$verbose">
          <xsl:message select="'Discarding float on', local-name($src)"/>
        </xsl:if>
          </xsl:when>
          <xsl:otherwise>
        <xsl:if test="$verbose">
          <xsl:message select="'Discarding float on', local-name($src)"/>
        </xsl:if>
            <xsl:if test="not($src/@floatstyle)">
        <xsl:if test="$verbose">
          <xsl:message select="'Adding floatstyle=', ./string(), ' on ', local-name($src)"/>
        </xsl:if>
              <xsl:attribute name="floatstyle" select="."/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="local-name(.) = 'entityref'">
        <!-- This should never happen, but ... -->
        <xsl:attribute name="fileref" select="unparsed-entity-uri(.)"/>
      </xsl:when>

      <xsl:when test="local-name($src) = 'simplemsgentry'
                      and local-name(.) = 'audience'">
        <xsl:attribute name="msgaud" select="."/>
      </xsl:when>
      <xsl:when test="local-name($src) = 'simplemsgentry'
                      and local-name(.) = 'origin'">
        <xsl:attribute name="msgorig" select="."/>
      </xsl:when>
      <xsl:when test="local-name($src) = 'simplemsgentry'
                      and local-name(.) = 'level'">
        <xsl:attribute name="msglevel" select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template match="/" mode="mp:addNS">
  <xsl:copy>
    <xsl:apply-templates mode="mp:addNS"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="*" mode="mp:addNS">
  <xsl:choose>
    <xsl:when test="namespace-uri(.) = ''">
      <xsl:element name="{local-name(.)}"
                   namespace="http://docbook.org/ns/docbook">
        <xsl:copy-of select="@*"/>
        <xsl:if test="not(parent::*)">
          <xsl:attribute name="version">5.0</xsl:attribute>
          <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
          <xsl:if test="not(@xml:base) and not(empty($base-uri))">
            <xsl:attribute name="xml:base" select="$base-uri"/>
          </xsl:if>
        </xsl:if>
        <xsl:apply-templates mode="mp:addNS"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:if test="not(parent::*)">
          <xsl:attribute name="version">5.0</xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="mp:addNS"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()" mode="mp:addNS">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
