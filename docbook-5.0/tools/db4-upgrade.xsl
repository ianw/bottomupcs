<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
		xmlns:db = "http://docbook.org/ns/docbook"
		xmlns:xlink="http://www.w3.org/1999/xlink"
                exclude-result-prefixes="exsl db"
                version="1.0">

<!--
# ======================================================================
# This file is part of DocBook V5.0CR5
#
# Copyright 2005 Norman Walsh, Sun Microsystems, Inc., and the
# Organization for the Advancement of Structured Information
# Standards (OASIS).
#
# Release: $Id: db4-upgrade.xsl 7660 2008-02-06 13:48:36Z nwalsh $
#
# Permission to use, copy, modify and distribute this stylesheet
# and its accompanying documentation for any purpose and without fee
# is hereby granted in perpetuity, provided that the above copyright
# notice and this paragraph appear in all copies. The copyright
# holders make no representation about the suitability of the schema
# for any purpose. It is provided "as is" without expressed or implied
# warranty.
#
# Please direct all questions, bug reports, or suggestions for changes
# to the docbook@lists.oasis-open.org mailing list. For more
# information, see http://www.oasis-open.org/docbook/.
#
# ======================================================================
-->

<xsl:variable name="version" select="'1.0'"/>

<xsl:output method="xml" encoding="utf-8" indent="no" omit-xml-declaration="yes"/>

<xsl:preserve-space elements="*"/>
<xsl:param name="rootid">
  <xsl:choose>
  <xsl:when test="/*/@id">
    <xsl:value-of select="/*/@id"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>UNKNOWN</xsl:text>
  </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:param name="defaultDate" select="''"/>

<xsl:template match="/">
  <xsl:variable name="converted">
    <xsl:apply-templates/>
  </xsl:variable>
  <xsl:comment>
    <xsl:text> Converted by db4-upgrade version </xsl:text>
    <xsl:value-of select="$version"/>
    <xsl:text> </xsl:text>
  </xsl:comment>
  <xsl:text>&#10;</xsl:text>
  <xsl:apply-templates select="exsl:node-set($converted)/*" mode="addNS"/>
</xsl:template>

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
    <xsl:call-template name="copy.attributes"/>

    <!-- titles can be inside or outside or both. fix that -->
    <xsl:choose>
      <xsl:when test="title and following-sibling::title">
        <xsl:if test="title != following-sibling::title">
          <xsl:call-template name="emit-message">
            <xsl:with-param name="message">
              <xsl:text>Check </xsl:text>
              <xsl:value-of select="name(..)"/>
              <xsl:text> title.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="title" mode="copy"/>
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates select="title" mode="copy"/>
      </xsl:when>
      <xsl:when test="following-sibling::title">
        <xsl:apply-templates select="following-sibling::title" mode="copy"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="emit-message">
          <xsl:with-param name="message">
            <xsl:text>Check </xsl:text>
            <xsl:value-of select="name(..)"/>
            <xsl:text>: no title.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="titleabbrev and following-sibling::titleabbrev">
        <xsl:if test="titleabbrev != following-sibling::titleabbrev">
          <xsl:call-template name="emit-message">
            <xsl:with-param name="message">
              <xsl:text>Check </xsl:text>
              <xsl:value-of select="name(..)"/>
              <xsl:text> titleabbrev.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="titleabbrev" mode="copy"/>
      </xsl:when>
      <xsl:when test="titleabbrev">
        <xsl:apply-templates select="titleabbrev" mode="copy"/>
      </xsl:when>
      <xsl:when test="following-sibling::titleabbrev">
        <xsl:apply-templates select="following-sibling::titleabbrev" mode="copy"/>
      </xsl:when>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="subtitle and following-sibling::subtitle">
        <xsl:if test="subtitle != following-sibling::subtitle">
          <xsl:call-template name="emit-message">
            <xsl:with-param name="message">
              <xsl:text>Check </xsl:text>
              <xsl:value-of select="name(..)"/>
              <xsl:text> subtitle.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="subtitle" mode="copy"/>
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates select="subtitle" mode="copy"/>
      </xsl:when>
      <xsl:when test="following-sibling::subtitle">
        <xsl:apply-templates select="following-sibling::subtitle" mode="copy"/>
      </xsl:when>
    </xsl:choose>

    <xsl:apply-templates/>
  </info>
</xsl:template>

<xsl:template match="objectinfo|prefaceinfo|refsynopsisdivinfo
		     |screeninfo|sidebarinfo"
	      priority="200">
  <info>
    <xsl:call-template name="copy.attributes"/>

    <!-- titles can be inside or outside or both. fix that -->
    <xsl:choose>
      <xsl:when test="title and following-sibling::title">
        <xsl:if test="title != following-sibling::title">
          <xsl:call-template name="emit-message">
            <xsl:with-param name="message">
              <xsl:text>Check </xsl:text>
              <xsl:value-of select="name(..)"/>
              <xsl:text> title.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="title" mode="copy"/>
      </xsl:when>
      <xsl:when test="title">
        <xsl:apply-templates select="title" mode="copy"/>
      </xsl:when>
      <xsl:when test="following-sibling::title">
        <xsl:apply-templates select="following-sibling::title" mode="copy"/>
      </xsl:when>
      <xsl:otherwise>
	<!-- it's ok if there's no title on these -->
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="titleabbrev and following-sibling::titleabbrev">
        <xsl:if test="titleabbrev != following-sibling::titleabbrev">
          <xsl:call-template name="emit-message">
          <xsl:with-param name="message">
            <xsl:text>Check </xsl:text>
            <xsl:value-of select="name(..)"/>
            <xsl:text> titleabbrev.</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="titleabbrev" mode="copy"/>
      </xsl:when>
      <xsl:when test="titleabbrev">
        <xsl:apply-templates select="titleabbrev" mode="copy"/>
      </xsl:when>
      <xsl:when test="following-sibling::titleabbrev">
        <xsl:apply-templates select="following-sibling::titleabbrev" mode="copy"/>
      </xsl:when>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="subtitle and following-sibling::subtitle">
        <xsl:if test="subtitle != following-sibling::subtitle">
          <xsl:call-template name="emit-message">
            <xsl:with-param name="message">
              <xsl:text>Check </xsl:text>
              <xsl:value-of select="name(..)"/>
              <xsl:text> subtitle.</xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="subtitle" mode="copy"/>
      </xsl:when>
      <xsl:when test="subtitle">
        <xsl:apply-templates select="subtitle" mode="copy"/>
      </xsl:when>
      <xsl:when test="following-sibling::subtitle">
        <xsl:apply-templates select="following-sibling::subtitle" mode="copy"/>
      </xsl:when>
    </xsl:choose>

    <xsl:apply-templates/>
  </info>
</xsl:template>

<xsl:template match="refentryinfo"
              priority="200">
  <info>
    <xsl:call-template name="copy.attributes"/>

    <!-- titles can be inside or outside or both. fix that -->
    <xsl:if test="title">
      <xsl:call-template name="emit-message">
        <xsl:with-param name="message">
          <xsl:text>Discarding title from refentryinfo!</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="titleabbrev">
      <xsl:call-template name="emit-message">
        <xsl:with-param name="message">
          <xsl:text>Discarding titleabbrev from refentryinfo!</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="subtitle">
      <xsl:call-template name="emit-message">
        <xsl:with-param name="message">
          <xsl:text>Discarding subtitle from refentryinfo!</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <xsl:apply-templates/>
  </info>
</xsl:template>

<xsl:template match="refmiscinfo"
              priority="200">
  <refmiscinfo>
    <xsl:call-template name="copy.attributes">
      <xsl:with-param name="suppress" select="'class'"/>
    </xsl:call-template>
    <xsl:if test="@class">
      <xsl:choose>
	<xsl:when test="@class = 'source'
		        or @class = 'version'
		        or @class = 'manual'
		        or @class = 'sectdesc'
		        or @class = 'software'">
	  <xsl:attribute name="class">
	    <xsl:value-of select="@class"/>
	  </xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="class">
	    <xsl:value-of select="'other'"/>
	  </xsl:attribute>
	  <xsl:attribute name="otherclass">
	    <xsl:value-of select="@class"/>
	  </xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates/>
  </refmiscinfo>
</xsl:template>

<xsl:template match="corpauthor" priority="200">
  <author>
    <xsl:call-template name="copy.attributes"/>
    <orgname>
      <xsl:apply-templates/>
    </orgname>
  </author>
</xsl:template>

<xsl:template match="corpname" priority="200">
  <orgname>
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </orgname>
</xsl:template>

<xsl:template match="author[not(personname)]|editor[not(personname)]|othercredit[not(personname)]" priority="200">
  <xsl:copy>
    <xsl:call-template name="copy.attributes"/>
    <personname>
      <xsl:apply-templates select="honorific|firstname|surname|othername|lineage"/>
    </personname>
    <xsl:apply-templates select="*[not(self::honorific|self::firstname|self::surname
                                   |self::othername|self::lineage)]"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="address|programlisting|screen|funcsynopsisinfo
                     |classsynopsisinfo|literallayout" priority="200">
  <xsl:copy>
    <xsl:call-template name="copy.attributes">
      <xsl:with-param name="suppress" select="'format'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="productname[@class]" priority="200">
  <xsl:call-template name="emit-message">
    <xsl:with-param name="message">
      <xsl:text>Dropping class attribute from productname</xsl:text>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:copy>
    <xsl:call-template name="copy.attributes">
      <xsl:with-param name="suppress" select="'class'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="dedication|preface|chapter|appendix|part|partintro
                     |article|bibliography|glossary|glossdiv|index
		     |reference[not(referenceinfo)]
                     |book" priority="200">
  <xsl:choose>
    <xsl:when test="not(dedicationinfo|prefaceinfo|chapterinfo
		        |appendixinfo|partinfo
                        |articleinfo|artheader|bibliographyinfo
			|glossaryinfo|indexinfo
                        |bookinfo)">
      <xsl:copy>
        <xsl:call-template name="copy.attributes"/>
        <xsl:if test="title|subtitle|titleabbrev">
          <info>
            <xsl:apply-templates select="title" mode="copy"/>
            <xsl:apply-templates select="titleabbrev" mode="copy"/>
            <xsl:apply-templates select="subtitle" mode="copy"/>
            <xsl:apply-templates select="abstract" mode="copy"/>
          </info>
        </xsl:if>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:call-template name="copy.attributes"/>
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
        <xsl:call-template name="copy.attributes"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:call-template name="copy.attributes"/>

	<xsl:if test="title|titleabbrev|subtitle">
	  <info>
	    <xsl:apply-templates select="title" mode="copy"/>
	    <xsl:apply-templates select="titleabbrev" mode="copy"/>
	    <xsl:apply-templates select="subtitle" mode="copy"/>
	  </info>
	</xsl:if>

        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="equation" priority="200">
  <xsl:choose>
    <xsl:when test="not(title)">
      <xsl:call-template name="emit-message">
        <xsl:with-param
            name="message"
            >Convert equation without title to informal equation.</xsl:with-param>
      </xsl:call-template>
      <informalequation>
        <xsl:call-template name="copy.attributes"/>
        <xsl:apply-templates/>
      </informalequation>
    </xsl:when>
    <xsl:when test="blockinfo">
      <xsl:copy>
        <xsl:call-template name="copy.attributes"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:call-template name="copy.attributes"/>
        <info>
          <xsl:apply-templates select="title" mode="copy"/>
          <xsl:apply-templates select="titleabbrev" mode="copy"/>
          <xsl:apply-templates select="subtitle" mode="copy"/>
        </info>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="sect1|sect2|sect3|sect4|sect5|section"
	      priority="200">
  <section>
    <xsl:call-template name="copy.attributes"/>

    <xsl:if test="not(sect1info|sect2info|sect3info|sect4info|sect5info|sectioninfo)">
      <info>
        <xsl:apply-templates select="title" mode="copy"/>
        <xsl:apply-templates select="titleabbrev" mode="copy"/>
        <xsl:apply-templates select="subtitle" mode="copy"/>
        <xsl:apply-templates select="abstract" mode="copy"/>
      </info>
    </xsl:if>
    <xsl:apply-templates/>
  </section>
</xsl:template>

<xsl:template match="simplesect"
	      priority="200">
  <simplesect>
    <xsl:call-template name="copy.attributes"/>
    <info>
      <xsl:apply-templates select="title" mode="copy"/>
      <xsl:apply-templates select="titleabbrev" mode="copy"/>
      <xsl:apply-templates select="subtitle" mode="copy"/>
      <xsl:apply-templates select="abstract" mode="copy"/>
    </info>
    <xsl:apply-templates/>
  </simplesect>
</xsl:template>

<xsl:template match="refsect1|refsect2|refsect3|refsection" priority="200">
  <refsection>
    <xsl:call-template name="copy.attributes"/>

    <xsl:if test="not(refsect1info|refsect2info|refsect3info|refsectioninfo)">
      <info>
        <xsl:apply-templates select="title" mode="copy"/>
        <xsl:apply-templates select="titleabbrev" mode="copy"/>
        <xsl:apply-templates select="subtitle" mode="copy"/>
        <xsl:apply-templates select="abstract" mode="copy"/>
      </info>
    </xsl:if>
    <xsl:apply-templates/>
  </refsection>
</xsl:template>

<xsl:template match="imagedata|videodata|audiodata|textdata" priority="200">
  <xsl:copy>
    <xsl:call-template name="copy.attributes">
      <xsl:with-param name="suppress" select="'srccredit'"/>
    </xsl:call-template>
    <xsl:if test="@srccredit">
      <xsl:call-template name="emit-message">
        <xsl:with-param name="message">
          <xsl:text>Check conversion of srccredit </xsl:text>
          <xsl:text>(othercredit="srccredit").</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
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
    <xsl:call-template name="copy.attributes"/>
    <xsl:if test="@class = 'sgmlcomment'">
      <xsl:attribute name="class">comment</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </tag>
</xsl:template>

<xsl:template match="inlinegraphic[@format='linespecific']" priority="210">
  <textobject>
    <textdata>
      <xsl:call-template name="copy.attributes"/>
    </textdata>
  </textobject>
</xsl:template>

<xsl:template match="inlinegraphic" priority="200">
  <inlinemediaobject>
    <imageobject>
      <imagedata>
	<xsl:call-template name="copy.attributes"/>
      </imagedata>
    </imageobject>
  </inlinemediaobject>
</xsl:template>

<xsl:template match="graphic[@format='linespecific']" priority="210">
  <mediaobject>
    <textobject>
      <textdata>
	<xsl:call-template name="copy.attributes"/>
      </textdata>
    </textobject>
  </mediaobject>
</xsl:template>

<xsl:template match="graphic" priority="200">
  <mediaobject>
    <imageobject>
      <imagedata>
	<xsl:call-template name="copy.attributes"/>
      </imagedata>
    </imageobject>
  </mediaobject>
</xsl:template>

<xsl:template match="pubsnumber" priority="200">
  <biblioid class="pubsnumber">
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </biblioid>
</xsl:template>

<xsl:template match="invpartnumber" priority="200">
  <xsl:call-template name="emit-message">
    <xsl:with-param name="message">
      <xsl:text>Converting invpartnumber to biblioid otherclass="invpartnumber".</xsl:text>
    </xsl:with-param>
  </xsl:call-template>
  <biblioid class="other" otherclass="invpartnumber">
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </biblioid>
</xsl:template>

<xsl:template match="contractsponsor" priority="200">
  <xsl:variable name="contractnum"
                select="preceding-sibling::contractnum|following-sibling::contractnum"/>

  <xsl:call-template name="emit-message">
    <xsl:with-param name="message">
      <xsl:text>Converting contractsponsor to othercredit="contractsponsor".</xsl:text>
    </xsl:with-param>
  </xsl:call-template>

  <othercredit class="other" otherclass="contractsponsor">
    <orgname>
      <xsl:call-template name="copy.attributes"/>
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
    <xsl:call-template name="emit-message">
      <xsl:with-param name="message">
        <xsl:text>Converting contractnum to othercredit="contractnum".</xsl:text>
      </xsl:with-param>
    </xsl:call-template>

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
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </biblioid>
</xsl:template>

<xsl:template match="biblioid[count(*) = 1
		              and ulink
			      and normalize-space(text()) = '']" priority="200">
  <biblioid xlink:href="{ulink/@url}">
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates select="ulink/node()"/>
  </biblioid>
</xsl:template>

<xsl:template match="authorblurb" priority="200">
  <personblurb>
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </personblurb>
</xsl:template>

<xsl:template match="collabname" priority="200">
  <xsl:call-template name="emit-message">
    <xsl:with-param name="message">
      <xsl:text>Check conversion of collabname </xsl:text>
      <xsl:text>(orgname role="collabname").</xsl:text>
    </xsl:with-param>
  </xsl:call-template>
  <orgname role="collabname">
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </orgname>
</xsl:template>

<xsl:template match="modespec" priority="200">
  <xsl:call-template name="emit-message">
    <xsl:with-param name="message">
      <xsl:text>Discarding modespec (</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>).</xsl:text>
    </xsl:with-param>
  </xsl:call-template>
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
                     |bibliomixed/title" priority="400">
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
                     |bibliomixed/contrib" priority="200">
  <xsl:call-template name="emit-message">
    <xsl:with-param name="message">
      <xsl:text>Check conversion of contrib </xsl:text>
      <xsl:text>(othercontrib="contrib").</xsl:text>
    </xsl:with-param>
  </xsl:call-template>
  <othercredit class="other" otherclass="contrib">
    <orgname>???</orgname>
    <contrib>
      <xsl:call-template name="copy.attributes"/>
      <xsl:apply-templates/>
    </contrib>
  </othercredit>
</xsl:template>

<xsl:template match="link" priority="200">
  <xsl:copy>
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="ulink" priority="200">
  <xsl:choose>
    <xsl:when test="node()">
      <xsl:call-template name="emit-message">
        <xsl:with-param name="message">
          <xsl:text>Converting ulink to link.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>

      <link xlink:href="{@url}">
	<xsl:call-template name="copy.attributes">
	  <xsl:with-param name="suppress" select="'url'"/>
	</xsl:call-template>
	<xsl:apply-templates/>
      </link>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="emit-message">
        <xsl:with-param name="message">
          <xsl:text>Converting ulink to uri.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>

      <uri xlink:href="{@url}">
	<xsl:call-template name="copy.attributes">
	  <xsl:with-param name="suppress" select="'url'"/>
	</xsl:call-template>
	<xsl:value-of select="@url"/>
      </uri>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="olink" priority="200">
  <xsl:if test="@linkmode">
    <xsl:call-template name="emit-message">
      <xsl:with-param name="message">
        <xsl:text>Discarding linkmode on olink.</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="@targetdocent">
      <xsl:call-template name="emit-message">
        <xsl:with-param name="message">
          <xsl:text>Converting olink targetdocent to targetdoc.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>

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
                     |bibliomset/honorific" priority="200">
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
                                     |../honorific" mode="copy"/>
      </personname>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="areaset" priority="200">
  <xsl:copy>
    <xsl:call-template name="copy.attributes">
      <xsl:with-param name="suppress" select="'coords'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="date|pubdate" priority="200">
  <xsl:variable name="rp1" select="substring-before(normalize-space(.), ' ')"/>
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
      <xsl:when test="string($p1+1) != 'NaN' and string($p3+1) != 'NaN'">
	<xsl:choose>
	  <xsl:when test="$p2 = 'Jan' or $p2 = 'January'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-01-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p2 = 'Feb' or $p2 = 'February'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-02-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p2 = 'Mar' or $p2 = 'March'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-03-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p2 = 'Apr' or $p2 = 'April'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-04-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p2 = 'May'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-05-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p2 = 'Jun' or $p2 = 'June'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-06-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p2 = 'Jul' or $p2 = 'July'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-07-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p2 = 'Aug' or $p2 = 'August'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-08-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p2 = 'Sep' or $p2 = 'September'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-09-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p2 = 'Oct' or $p2 = 'October'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-10-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p2 = 'Nov' or $p2 = 'November'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-11-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p2 = 'Dec' or $p2 = 'December'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-12-</xsl:text>
	    <xsl:number value="$p1" format="01"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="string($p2+1) != 'NaN' and string($p3+1) != 'NaN'">
	<xsl:choose>
	  <xsl:when test="$p1 = 'Jan' or $p1 = 'January'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-01-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p1 = 'Feb' or $p1 = 'February'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-02-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p1 = 'Mar' or $p1 = 'March'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-03-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p1 = 'Apr' or $p1 = 'April'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-04-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p1 = 'May'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-05-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p1 = 'Jun' or $p1 = 'June'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-06-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p1 = 'Jul' or $p1 = 'July'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-07-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p1 = 'Aug' or $p1 = 'August'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-08-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p1 = 'Sep' or $p1 = 'September'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-09-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p1 = 'Oct' or $p1 = 'October'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-10-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p1 = 'Nov' or $p1 = 'November'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-11-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
	  </xsl:when>
	  <xsl:when test="$p1 = 'Dec' or $p1 = 'December'">
	    <xsl:number value="$p3" format="0001"/>
	    <xsl:text>-12-</xsl:text>
	    <xsl:number value="$p2" format="01"/>
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
      <xsl:call-template name="emit-message">
        <xsl:with-param name="message">
          <xsl:text>Converted </xsl:text>
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:text> into </xsl:text>
          <xsl:value-of select="$date"/>
          <xsl:text> for </xsl:text>
          <xsl:value-of select="name(.)"/>
        </xsl:with-param>
      </xsl:call-template>

      <xsl:copy>
	<xsl:copy-of select="@*"/>
	<xsl:value-of select="$date"/>
      </xsl:copy>
    </xsl:when>

    <xsl:when test="$defaultDate != ''">
      <xsl:call-template name="emit-message">
        <xsl:with-param name="message">
          <xsl:text>Unparseable date: </xsl:text>
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:text> in </xsl:text>
          <xsl:value-of select="name(.)"/>
          <xsl:text> (Using default: </xsl:text>
          <xsl:value-of select="$defaultDate"/>
          <xsl:text>)</xsl:text>
        </xsl:with-param>
      </xsl:call-template>

      <xsl:copy>
	<xsl:copy-of select="@*"/>
	<xsl:copy-of select="$defaultDate"/>
	<xsl:comment>
	  <xsl:value-of select="."/>
	</xsl:comment>
      </xsl:copy>
    </xsl:when>

    <xsl:otherwise>
      <!-- these don't really matter anymore
           <xsl:call-template name="emit-message">
           <xsl:with-param name="message">
           <xsl:text>Unparseable date: </xsl:text>
           <xsl:value-of select="normalize-space(.)"/>
           <xsl:text> in </xsl:text>
           <xsl:value-of select="name(.)"/>
           </xsl:with-param>
           </xsl:call-template>
      -->
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
    <xsl:call-template name="emit-message">
      <xsl:with-param name="message">
	<xsl:text>Check abstract; moved into info correctly?</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="indexterm">
  <!-- don't copy the defaulted significance='normal' attribute -->
  <indexterm>
    <xsl:call-template name="copy.attributes">
      <xsl:with-param name="suppress">
	<xsl:if test="@significance = 'normal'">significance</xsl:if>
      </xsl:with-param>
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
		     toclevel2|toclevel3|toclevel4|toclevel5|tocpart" priority="200">
  <tocdiv>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </tocdiv>
</xsl:template>

<xsl:template match="action" priority="200">
  <phrase remap="action">
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </phrase>
</xsl:template>

<xsl:template match="beginpage" priority="200">
  <xsl:comment> beginpage pagenum=<xsl:value-of select="@pagenum"/> </xsl:comment>
  <xsl:call-template name="emit-message">
    <xsl:with-param name="message">
      <xsl:text>Replacing beginpage with comment</xsl:text>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="structname|structfield" priority="200">
  <varname remap="{local-name(.)}">
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </varname>
</xsl:template>

<!-- ====================================================================== -->

<!-- 6 Feb 2008, ndw changed mode=copy so that it only copies the first level,
     then it switches back to "normal" mode so that other rewriting templates
     catch embedded fixes -->

<!--
<xsl:template match="ulink" priority="200" mode="copy">
  <xsl:choose>
    <xsl:when test="node()">
      <xsl:call-template name="emit-message">
        <xsl:with-param name="message">
          <xsl:text>Converting ulink to phrase.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>

      <phrase xlink:href="{@url}">
	<xsl:call-template name="copy.attributes">
	  <xsl:with-param name="suppress" select="'url'"/>
	</xsl:call-template>
	<xsl:apply-templates/>
      </phrase>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="emit-message">
        <xsl:with-param name="message">
          <xsl:text>Converting ulink to uri.</xsl:text>
        </xsl:with-param>
      </xsl:call-template>

      <uri xlink:href="{@url}">
	<xsl:call-template name="copy.attributes">
	  <xsl:with-param name="suppress" select="'url'"/>
	</xsl:call-template>
	<xsl:value-of select="@url"/>
      </uri>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="sgmltag" priority="200" mode="copy">
  <tag>
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </tag>
</xsl:template>
-->

<xsl:template match="*" mode="copy">
  <xsl:copy>
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<!--
<xsl:template match="comment()|processing-instruction()|text()" mode="copy">
  <xsl:copy/>
</xsl:template>
-->

<!-- ====================================================================== -->

<xsl:template match="*">
  <xsl:copy>
    <xsl:call-template name="copy.attributes"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()">
  <xsl:copy/>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template name="copy.attributes">
  <xsl:param name="src" select="."/>
  <xsl:param name="suppress" select="''"/>

  <xsl:for-each select="$src/@*">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'moreinfo'">
        <xsl:call-template name="emit-message">
          <xsl:with-param name="message">
            <xsl:text>Discarding moreinfo on </xsl:text>
            <xsl:value-of select="local-name($src)"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="local-name(.) = 'lang'">
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="local-name(.) = 'id'">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="$suppress = local-name(.)"/>
      <xsl:when test="local-name(.) = 'float'">
	<xsl:choose>
	  <xsl:when test=". = '1'">
            <xsl:call-template name="emit-message">
              <xsl:with-param name="message">
                <xsl:text>Discarding float on </xsl:text>
                <xsl:value-of select="local-name($src)"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="not($src/@floatstyle)">
	      <xsl:call-template name="emit-message">
                <xsl:with-param name="message">
                  <xsl:text>Adding floatstyle='normal' on </xsl:text>
                  <xsl:value-of select="local-name($src)"/>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:attribute name="floatstyle">
                <xsl:text>normal</xsl:text>
	      </xsl:attribute>
	    </xsl:if>
	  </xsl:when>
	  <xsl:when test=". = '0'">
	    <xsl:call-template name="emit-message">
              <xsl:with-param name="message">
                <xsl:text>Discarding float on </xsl:text>
                <xsl:value-of select="local-name($src)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="emit-message">
          <xsl:with-param name="message">
            <xsl:text>Discarding float on </xsl:text>
            <xsl:value-of select="local-name($src)"/>
          </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="not($src/@floatstyle)">
              <xsl:call-template name="emit-message">
                <xsl:with-param name="message">
                  <xsl:text>Adding floatstyle='</xsl:text>
                  <xsl:value-of select="."/>
                  <xsl:text>' on </xsl:text>
                  <xsl:value-of select="local-name($src)"/>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:attribute name="floatstyle">
		<xsl:value-of select="."/>
	      </xsl:attribute>
	    </xsl:if>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="local-name(.) = 'entityref'">
	<xsl:attribute name="fileref">
	  <xsl:value-of select="unparsed-entity-uri(@entityref)"/>
	</xsl:attribute>
      </xsl:when>

      <xsl:when test="local-name($src) = 'simplemsgentry'
	              and local-name(.) = 'audience'">
        <xsl:attribute name="msgaud">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="local-name($src) = 'simplemsgentry'
	              and local-name(.) = 'origin'">
        <xsl:attribute name="msgorig">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="local-name($src) = 'simplemsgentry'
	              and local-name(.) = 'level'">
        <xsl:attribute name="msglevel">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>

      <!-- * for upgrading XSL litprog params documentation -->
      <xsl:when test="local-name($src) = 'refmiscinfo'
                      and local-name(.) = 'role'
                      and . = 'type'
                      ">
        <xsl:call-template name="emit-message">
          <xsl:with-param name="message">
            <xsl:text>Converting refmiscinfo@role=type to </xsl:text>
            <xsl:text>@class=other,otherclass=type</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:attribute name="class">other</xsl:attribute>
        <xsl:attribute name="otherclass">type</xsl:attribute>
      </xsl:when>

      <xsl:otherwise>
        <xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template match="*" mode="addNS">
  <xsl:choose>
    <xsl:when test="namespace-uri(.) = ''">
      <xsl:element name="{local-name(.)}"
		   namespace="http://docbook.org/ns/docbook">
	<xsl:if test="not(parent::*)">
	  <xsl:attribute name="version">5.0</xsl:attribute>
	</xsl:if>
	<xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="addNS"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
	<xsl:if test="not(parent::*)">
	  <xsl:attribute name="version">5.0</xsl:attribute>
	</xsl:if>
	<xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="addNS"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()" mode="addNS">
  <xsl:copy/>
</xsl:template>

<!-- ====================================================================== -->

<xsl:template name="emit-message">
  <xsl:param name="message"/>
  <xsl:message>
    <xsl:value-of select="$message"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="$rootid"/>
    <xsl:text>)</xsl:text>
  </xsl:message>
</xsl:template>

</xsl:stylesheet>
