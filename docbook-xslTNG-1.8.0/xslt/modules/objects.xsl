<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:ext="http://docbook.org/extensions/xslt"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:tp="http://docbook.org/ns/docbook/templates/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db dbe ext f fp h m map mp svg t tp v xlink xs"
                version="3.0">

<!-- ============================================================ -->

<xsl:template match="db:textobject[db:phrase]" mode="m:details-attribute">
  <xsl:param name="attribute" select="'summary'"/>
  <xsl:attribute name="{$attribute}" select="normalize-space(.)"/>
</xsl:template>

<xsl:template match="db:alt" mode="m:details-attribute">
  <xsl:param name="attribute" select="'summary'"/>
  <xsl:attribute name="{$attribute}" select="normalize-space(.)"/>
</xsl:template>

<xsl:template match="db:mediaobject|db:inlinemediaobject"
              mode="m:details-attribute">
  <xsl:param name="attribute" select="'summary'"/>
  <xsl:apply-templates select="(db:alt,db:textobject[db:phrase])[1]"
                       mode="m:details-attribute">
    <xsl:with-param name="attribute" select="$attribute"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="*" mode="m:details-attribute"/>

<!-- ============================================================ -->

<xsl:template match="db:textobject[db:phrase]" mode="m:details">
  <xsl:attribute name="summary" select="normalize-space(.)"/>
</xsl:template>

<xsl:template match="db:alt" mode="m:details">
  <summary>
    <xsl:apply-templates/>
  </summary>
</xsl:template>

<xsl:template match="db:textobject[not(db:phrase)]" mode="m:details">
  <details>
    <xsl:apply-templates select="db:alt[1]" mode="m:details"/>
    <xsl:apply-templates select="node() except db:alt"/>
  </details>
</xsl:template>

<xsl:template match="db:mediaobject|db:inlinemediaobject">
  <xsl:variable name="pi-properties"
                select="f:pi-attributes(./processing-instruction('db'))"/>
  <xsl:variable name="gi" select="if (self::db:mediaobject)
                                  then 'div'
                                  else 'span'"/>
  <xsl:element name="{$gi}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:copy-of select="$pi-properties/@style"/>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:if test="('summary' = $mediaobject-accessibility
                   and (db:alt or db:textobject/db:phrase))">
      <xsl:if test="db:alt or exists(* except db:textobject)">
        <xsl:choose>
          <xsl:when test="db:alt">
            <xsl:attribute name="summary" select="normalize-space(db:alt)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="(db:textobject[db:phrase])[1]"
                                 mode="m:details"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
    <xsl:if test="('details' = $mediaobject-accessibility)">
      <xsl:apply-templates select="db:textobject[not(db:phrase)]"
                           mode="m:details"/>
    </xsl:if>
    <xsl:apply-templates select="f:select-mediaobject(*)"/>
  </xsl:element>
</xsl:template>

<!--
<xsl:template match="db:inlinemediaobject">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="f:select-mediaobject-data(*)"/>
  </div>
-->

<xsl:template match="db:imageobject|db:audioobject|db:videoobject">
  <xsl:element name="{if (ancestor::db:inlinemediaobject) then 'span' else 'div'}"
               namespace="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="." mode="m:attributes"/>
    <xsl:apply-templates select="f:select-mediaobject-data(*, true())"/>
  </xsl:element>
</xsl:template>

<xsl:template match="svg:*">
  <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates select="node()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:imageobjectco">
  <xsl:choose>
    <xsl:when test="db:calloutlist">
      <div class="{local-name(.)}">
        <xsl:apply-templates
            select="f:select-mediaobject(* except db:calloutlist)"/>
        <xsl:apply-templates select="db:calloutlist"/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="f:select-mediaobject(*)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:textobject">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:audiodata">
  <xsl:call-template name="tp:process-object"/>
</xsl:template>

<xsl:template match="db:videodata">
  <xsl:call-template name="tp:process-object"/>
</xsl:template>

<xsl:template match="db:textdata">
  <xsl:message>FIXME: db:textdata</xsl:message>
</xsl:template>

<xsl:template match="db:imagedata">
  <xsl:call-template name="tp:process-object"/>
</xsl:template>

<xsl:template match="db:multimediaparam">
  <xsl:attribute name="{@name}" select="@value"/>
</xsl:template>

<xsl:template name="tp:process-object">
  <!-- When this template is called, the current node should be  -->
  <!-- a graphic, inlinegraphic, imagedata, or videodata. All    -->
  <!-- those elements have the same set of attributes, so we can -->
  <!-- handle them all in one place.                             -->

  <xsl:variable name="href" select="resolve-uri(@fileref, base-uri(.))"/>

  <xsl:if use-when="'mediaobject-uris' = $v:debug"
          test="@fileref">
    <xsl:message select="'1: m/o fileref:', base-uri(.)"/>
    <xsl:message select="'              +', @fileref/string()"/>
    <xsl:message select="'              →', $href"/>
  </xsl:if>

  <!-- imagedata, videodata, audiodata -->
  <xsl:variable name="uri" as="xs:string?">
    <xsl:choose>
      <xsl:when test="not(@fileref)">
        <xsl:sequence select="()"/>
      </xsl:when>
      <xsl:when test="exists($v:mediaobject-input-base-uri)">
        <xsl:sequence select="resolve-uri($href, $v:mediaobject-input-base-uri)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="resolve-uri($href, base-uri(.))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if use-when="'mediaobject-uris' = $v:debug"
          test="@fileref">
    <xsl:message select="'2: m/o input:', @fileref/string()"/>
    <xsl:message select="'            →', $uri"/>
  </xsl:if>

  <xsl:variable name="filename"
                select="if (empty($uri))
                        then ()
                        else f:resolve-object-uri($uri)"/>

  <xsl:variable name="imageproperties" as="map(*)"
                select="if (./self::db:imagedata and @fileref)
                        then f:object-properties($uri)
                        else map { }"/>

  <xsl:variable name="intrinsicwidth"
                select="if (map:contains($imageproperties, 'width'))
                        then f:make-length($imageproperties?width, 'px')
                        else $v:image-nominal-width"/>

  <xsl:variable name="intrinsicheight"
                select="if (map:contains($imageproperties, 'height'))
                        then f:make-length($imageproperties?height, 'px')
                        else $v:image-nominal-height"/>

  <xsl:variable name="width" select="f:object-width(.)"/>
  <xsl:variable name="height" select="f:object-height(.)"/>

  <!-- Convert % widths into absolute widths if we can -->

  <xsl:variable name="width" select="if ($width?unit = '%'
                                         and not(f:is-empty-length($intrinsicwidth)))
                                     then
                                       f:make-length(
                                         $intrinsicwidth?magnitude
                                         * $width?magnitude
                                         div 100.0,
                                         $intrinsicwidth?unit)
                                     else
                                       $width"/>

  <xsl:variable name="height" select="if ($height?unit = '%'
                                         and not(f:is-empty-length($intrinsicheight)))
                                     then
                                       f:make-length(
                                         $intrinsicheight?magnitude
                                         * $height?magnitude
                                         div 100.0,
                                         $intrinsicheight?unit)
                                     else
                                       $height"/>

  <xsl:variable name="scalefit" select="f:object-scalefit(.)"/>
  <xsl:variable name="scale" select="f:object-scale(.)"/>

  <xsl:variable name="cw" select="f:object-contentwidth(., $intrinsicwidth)"/>

  <xsl:variable name="cw" select="if (f:is-empty-length($cw))
                                  then $intrinsicwidth
                                  else $cw"/>

  <xsl:variable name="contentwidth"
                select="if ($scalefit)
                        then $width
                        else $cw"/>

  <xsl:variable name="cw" select="if (f:is-empty-length($contentwidth))
                                  then $v:image-nominal-width
                                  else $contentwidth"/>

  <xsl:variable name="contentwidth"
                select="if ($scale ne 1.0)
                        then f:make-length($cw?magnitude * $scale, $cw?unit)
                        else $contentwidth"/>

  <xsl:variable name="contentwidth"
                select="if (f:equal-lengths($contentwidth, $intrinsicwidth))
                        then ()
                        else $contentwidth"/>

<!-- ======================================== -->

  <xsl:variable name="ch" select="f:object-contentheight(., $intrinsicheight)"/>

  <xsl:variable name="ch" select="if (f:is-empty-length($ch))
                                  then $intrinsicheight
                                  else $ch"/>

  <xsl:variable name="contentheight"
                select="if ($scalefit)
                        then $height
                        else $ch"/>

  <xsl:variable name="ch" select="if (f:is-empty-length($contentheight))
                                  then $v:image-nominal-height
                                  else $contentheight"/>

  <xsl:variable name="contentheight" as="map(*)?">
    <xsl:choose>
      <xsl:when test="exists(@contentdepth)">
        <xsl:sequence select="$contentheight"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="if (f:is-empty-length($contentwidth)
                                  and $scale ne 1.0)
                              then f:make-length($ch?magnitude * $scale, $ch?unit)
                              else if (f:is-empty-length($contentwidth))
                                   then $contentheight
                                   else ()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="contentheight"
                select="if (f:equal-lengths($contentheight, $intrinsicheight))
                        then ()
                        else $contentheight"/>

  <xsl:variable name="align" select="f:object-align(.)"/>

  <!-- There's no point doing valign if there's no height -->
  <xsl:variable name="valign" select="if (f:is-empty-length($height)
                                          and f:is-empty-length($contentheight))
                                      then ()
                                      else f:object-valign(.)"/>

  <xsl:if test="true()" use-when="'objects' = $v:debug">
    <xsl:message select="$filename, ':'"/>
    <xsl:message select="' iwidth : ', f:length-string($intrinsicwidth)"/>
    <xsl:message select="' iheight: ', f:length-string($intrinsicheight)"/>
    <xsl:message select="'  width : ', f:length-string($width)"/>
    <xsl:message select="'  height: ', f:length-string($height)"/>
    <xsl:message select="' cwidth : ', f:length-string($contentwidth)"/>
    <xsl:message select="' cheight: ', f:length-string($contentheight)"/>
    <xsl:message select="'  scale : ', $scale, ' ', $scalefit"/>
    <xsl:message select="'   align: ', $align"/>
    <xsl:message select="'  valign: ', $valign"/>
  </xsl:if>

  <xsl:variable name="viewport" as="element(h:span)">
    <xsl:call-template name="tp:viewport">
      <xsl:with-param name="class" select="'viewport-table'"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="height" select="$height"/>
      <xsl:with-param name="pi-properties"
                      select="f:pi-attributes(../processing-instruction('db'))"/>
      <xsl:with-param name="content" as="element()+">
        <span class="viewport-row">
          <xsl:call-template name="tp:viewport">
            <xsl:with-param name="class" select="'viewport-cell'"/>
            <xsl:with-param name="align" select="$align"/>
            <xsl:with-param name="valign" select="$valign"/>
            <xsl:with-param name="pi-properties"
                            select="f:pi-attributes(processing-instruction('db'))"/>
            <xsl:with-param name="content" as="element()+">
              <span class="viewport">
                <xsl:apply-templates select="." mode="mp:imagedata">
                  <xsl:with-param name="filename" select="$filename"/>
                  <xsl:with-param name="width" select="$contentwidth"/>
                  <xsl:with-param name="height" select="$contentheight"/>
                  <xsl:with-param name="imageproperties" select="$imageproperties"/>
                </xsl:apply-templates>
              </span>
            </xsl:with-param>
          </xsl:call-template>
        </span>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:element name="{if (ancestor::db:inlinemediaobject) then 'span' else 'div'}"
               namespace="http://www.w3.org/1999/xhtml">
    <xsl:attribute name="class" select="'media'"/>
    <xsl:choose>
      <xsl:when test="empty($viewport/@* except $viewport/@class)
                      and empty($viewport/h:span/@*
                                except $viewport/h:span/@class)
                      and empty($viewport/h:span/h:span/@*
                                except $viewport/h:span/h:span/@class)
                      and empty($viewport/h:span/h:span/h:span/@*
                                except $viewport/h:span/h:span/h:span/@class)">
        <xsl:sequence select="$viewport/h:span/h:span/h:span/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$viewport"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>

  <xsl:if test="ancestor::db:imageobjectco
                and exists($imageproperties)">
    <xsl:call-template name="t:imagemap">
      <xsl:with-param name="intrinsicwidth" select="$intrinsicwidth"/>
      <xsl:with-param name="intrinsicheight" select="$intrinsicheight"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="t:imagemap">
  <xsl:param name="intrinsicwidth" required="yes"/>
  <xsl:param name="intrinsicheight" required="yes"/>

  <map name="{f:id(ancestor::db:imageobjectco)}">
    <xsl:for-each select="ancestor::db:imageobjectco/db:areaspec//db:area">
      <xsl:variable name="units" as="xs:string"
                    select="if (@units) then @units
                            else if (../@units) then ../@units
                            else 'calspair'"/>

      <xsl:choose>
        <xsl:when test="$units = 'calspair'">
          <xsl:variable name="coords"
                        select="tokenize(normalize-space(@coords),
                                '[\s,]+')"/>

          <xsl:variable name="x1p"
                        select="xs:decimal($coords[1]) div 100.0"/>
          <xsl:variable name="y1p"
                        select="xs:decimal($coords[2]) div 100.0"/>
          <xsl:variable name="x2p"
                        select="xs:decimal($coords[3]) div 100.0"/>
          <xsl:variable name="y2p"
                        select="xs:decimal($coords[4]) div 100.0"/>

          <area shape="rect">
            <xsl:apply-templates select="." mode="m:attributes"/>
            <xsl:choose>
              <xsl:when test="@linkends
                              or (parent::db:areaset and ../@linkends)">
                <xsl:variable name="idrefs"
                              select="if (@linkends)
                                      then normalize-space(@linkends)
                                      else normalize-space(../@linkends)"/>

                <xsl:variable name="target"
                              select="key('id', tokenize($idrefs, '[\s]'))[1]"/>

                <xsl:if test="$target">
                  <xsl:attribute name="href" select="f:href(., $target)"/>
                </xsl:if>
              </xsl:when>
              <xsl:when test="@xlink:href">
                <xsl:attribute name="href" select="@xlink:href"/>
              </xsl:when>
            </xsl:choose>

            <xsl:attribute name="coords">
              <xsl:sequence
                  select="round($x1p * $intrinsicwidth?magnitude div 100.0)"/>
              <xsl:text>,</xsl:text>
              <xsl:sequence
                  select="round($intrinsicheight?magnitude
                          - ($y1p * $intrinsicheight?magnitude div 100.0))"/>
              <xsl:text>,</xsl:text>
              <xsl:sequence
                  select="round($x2p * $intrinsicwidth?magnitude div 100.0)"/>
              <xsl:text>,</xsl:text>
              <xsl:sequence
                  select="round($intrinsicheight?magnitude
                          - ($y2p * $intrinsicheight?magnitude div 100.0))"/>
            </xsl:attribute>
          </area>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>Warning: only calspair supported </xsl:text>
            <xsl:text>in imageobjectco</xsl:text>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </map>
</xsl:template>

<xsl:template name="tp:viewport">
  <xsl:param name="class" as="xs:string" select="'viewport'"/>
  <xsl:param name="width" as="map(*)?"/>
  <xsl:param name="height" as="map(*)?"/>
  <xsl:param name="align" as="xs:string?"/>
  <xsl:param name="valign" as="xs:string?"/>
  <xsl:param name="pi-properties" as="element()?"/>
  <xsl:param name="content" as="element()+"/>

  <xsl:variable name="valign" select="f:css-property('vertical-align', $valign)"/>
  <xsl:variable name="width" select="f:css-length('width', $width)"/>
  <xsl:variable name="height" select="f:css-length('height', $height)"/>
  <xsl:variable name="align" select="f:css-property('text-align', $align)"/>

  <xsl:variable name="pi-styles"
                select="tokenize($pi-properties/@style, '\s*;\s*')"/>

  <xsl:variable name="styles" as="xs:string*">
    <xsl:sequence select="($width, $height, $align, $valign)"/>
    <xsl:for-each select="$pi-styles">
      <xsl:choose>
        <xsl:when test="normalize-space(.) = ''"/>
        <xsl:when test="starts-with(., 'width:')
                        or starts-with(., 'height:')
                        or starts-with(., 'text-align:')
                        or starts-with(., 'vertical-align:')">
          <xsl:message expand-text="yes"
                       >Ignoring ?db style property: {.}</xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>

  <span>
    <xsl:attribute name="class" select="$class"/>
    <xsl:if test="exists($styles)">
      <xsl:attribute name="style" select="string-join($styles, ';')||';'"/>
    </xsl:if>
    <xsl:sequence select="$content"/>
  </span>
</xsl:template>

<xsl:template match="*" mode="mp:imagedata">
  <xsl:param name="filename" required="yes"/>
  <xsl:param name="width" select="()"/>
  <xsl:param name="height" select="()"/>
  <xsl:param name="imageproperties" select="()"/>

  <xsl:variable name="width" select="f:css-length('width', $width)"/>
  <xsl:variable name="height" select="f:css-length('height', $height)"/>

  <xsl:variable name="styles" as="xs:string*">
    <xsl:for-each select="($width, $height)">
      <xsl:sequence select="."/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:choose>
    <!-- attempt to handle audio data -->
    <xsl:when test="self::db:audiodata">
      <audio controls="controls"
             src="{$filename}">
        <xsl:apply-templates select="db:multimediaparam"/>
        <span>The <code>audio</code> element is not supported.</span>
      </audio>
    </xsl:when>

    <!-- attempt to handle video data -->
    <xsl:when test="self::db:videodata">
      <iframe src="{$filename}">
        <!-- Width and height, if present, will be in CSS terms as px. -->
        <xsl:if test="$width">
          <xsl:attribute name="width"
                         select="substring-after($width, 'width:') =&gt; substring-before('px')"/>
        </xsl:if>
        <xsl:if test="$height">
          <xsl:attribute name="height"
                         select="substring-after($height, 'height:') =&gt; substring-before('px')"/>
        </xsl:if>
        <xsl:apply-templates select="db:multimediaparam"/>
      </iframe>
    </xsl:when>

    <xsl:when test="svg:*">
      <div class="svg">
        <xsl:if test="exists($styles)">
          <xsl:attribute name="style" select="string-join($styles, ';')||';'"/>
        </xsl:if>
        <xsl:apply-templates/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <img src="{$filename}">
        <xsl:apply-templates select="." mode="m:attributes"/>
        <xsl:apply-templates
            select="ancestor::db:mediaobject
                    |ancestor::db:inlinemediaobject"
            mode="m:details-attribute">
          <xsl:with-param name="attribute" select="'alt'"/>
        </xsl:apply-templates>
        <xsl:if test="exists($styles)">
          <xsl:attribute name="style" select="string-join($styles, ';')||';'"/>
        </xsl:if>

        <xsl:if test="ancestor::db:imageobjectco">
          <xsl:variable name="co"
                        select="ancestor::db:imageobjectco"/>
          <xsl:choose>
            <xsl:when test="empty($imageproperties)">
              <xsl:message>
                <xsl:text>Imagemaps require image </xsl:text>
                <xsl:text>intrinsics extension</xsl:text>
              </xsl:message>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="usemap"
                             select="concat('#', f:id($co))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </img>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:function name="f:object-width" as="map(*)">
  <xsl:param name="object" as="element()"/>
  <xsl:choose>
    <xsl:when test="$image-ignore-scaling">
      <xsl:sequence select="f:empty-length()"/>
    </xsl:when>
    <xsl:when test="$object/@width">
      <xsl:sequence select="f:parse-length($object/@width)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:empty-length()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:object-height" as="map(*)">
  <xsl:param name="object" as="element()"/>
  <xsl:choose>
    <xsl:when test="$image-ignore-scaling or not($object/@depth)">
      <xsl:sequence select="f:empty-length()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:parse-length($object/@depth)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:object-contentwidth" as="map(*)">
  <xsl:param name="object" as="element()"/>
  <xsl:param name="intrinsicwidth" as="map(*)"/>

  <xsl:choose>
    <xsl:when test="$image-ignore-scaling">
      <xsl:sequence select="f:empty-length()"/>
    </xsl:when>
    <xsl:when test="$object/@contentwidth">
      <xsl:variable name="width"
                    select="f:parse-length($object/@contentwidth)"/>
      <xsl:sequence
          select="if ($width?unit = '%')
                  then f:make-length($width?magnitude
                                     * $intrinsicwidth?magnitude
                                     div 100.0,
                                     $intrinsicwidth?unit)
                  else $width"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:empty-length()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:object-contentheight" as="map(*)">
  <xsl:param name="object" as="element()"/>
  <xsl:param name="intrinsicheight" as="map(*)"/>

  <xsl:choose>
    <xsl:when test="$image-ignore-scaling">
      <xsl:sequence select="f:empty-length()"/>
    </xsl:when>
    <xsl:when test="$object/@contentdepth">
      <xsl:variable name="depth"
                    select="f:parse-length($object/@contentdepth)"/>
      <xsl:sequence
          select="if ($depth?unit = '%')
                  then f:make-length($depth?magnitude
                                     * $intrinsicheight?magnitude
                                     div 100.0,
                                     $intrinsicheight?unit)
                  else $depth"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:empty-length()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:css-length" as="xs:string?">
  <xsl:param name="property" as="xs:string"/>
  <xsl:param name="length" as="map(*)?"/>
  <xsl:sequence
      select="if (exists($length) and $length?unit)
              then f:css-property($property, string(f:absolute-length($length))||'px')
              else ()"/>
</xsl:function>

<xsl:function name="f:css-property" as="xs:string?">
  <xsl:param name="property" as="xs:string"/>
  <xsl:param name="value" as="xs:string?"/>
  <xsl:sequence
      select="if (exists($value))
              then $property || ':' || $value
              else ()"/>
</xsl:function>

<xsl:function name="f:object-scalefit" as="xs:boolean">
  <xsl:param name="object" as="element()"/>
  <xsl:choose>
    <xsl:when test="$image-ignore-scaling
                    or $object/@contentwidth
                    or $object/@contentdepth">
      <xsl:sequence select="false()"/>
    </xsl:when>
    <xsl:when test="$object/@scale">
      <xsl:sequence select="false()"/>
    </xsl:when>
    <xsl:when test="$object/@scalefit">
      <xsl:sequence select="$object/@scalefit != '0'"/>
    </xsl:when>
    <xsl:when test="f:object-width($object)?magnitude
                    or f:object-height($object)?magnitude">
      <!-- this is for backwards compatibility -->
      <xsl:sequence select="true()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:object-scale" as="xs:double">
  <xsl:param name="object" as="element()"/>
  <xsl:choose>
    <xsl:when test="$image-ignore-scaling or not($object/@scale)">
      <xsl:sequence select="1.0"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="xs:double($object/@scale) div 100.0"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:object-align" as="xs:string?">
  <xsl:param name="object" as="element()"/>
  <xsl:sequence select="$object/@align/string()"/>
</xsl:function>

<xsl:function name="f:object-valign" as="xs:string?">
  <xsl:param name="object" as="element()"/>
  <!-- Historically, middle seems to have been the default -->
  <xsl:sequence select="if ($object/@valign)
                        then $object/@valign/string()
                        else 'middle'"/>
</xsl:function>

<xsl:function name="f:object-properties" as="map(xs:string, xs:anyAtomicType)">
  <xsl:param name="uri" as="xs:string"/>

  <xsl:variable name="properties" as="map(xs:string, xs:anyAtomicType)"
                use-when="function-available('ext:image-metadata')">
    <xsl:sequence select="ext:image-metadata($uri)"/>
  </xsl:variable>

  <xsl:variable name="properties" as="map(xs:string, xs:anyAtomicType)"
                use-when="function-available('ext:image-properties')
                          and not(function-available('ext:image-metadata'))">
    <xsl:sequence select="ext:image-properties($uri)"/>
  </xsl:variable>

  <xsl:variable name="properties" as="map(xs:string, xs:anyAtomicType)"
                use-when="not(function-available('ext:image-properties'))
                          and not(function-available('ext:image-properties'))"
                select="map {}"/>

  <xsl:if use-when="not(function-available('ext:image-properties'))
                    and not(function-available('ext:image-properties'))"
          test="$image-property-warning">
    <xsl:message>
      <xsl:text>Cannot read image properties (no extension)</xsl:text>
    </xsl:message>
  </xsl:if>

  <xsl:message use-when="$debug = 'image-properties'"
               select="$uri"/>
  <xsl:for-each use-when="$debug = 'image-properties'"
                select="map:keys($properties)">
    <xsl:message select="., '=', map:get($properties, .)"/>
  </xsl:for-each>

  <xsl:sequence select="$properties"/>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="f:resolve-object-uri" as="xs:string">
  <xsl:param name="uri" as="xs:string"/>

  <xsl:variable name="expected-location"
                select="exists($v:mediaobject-input-base-uri)
                        and starts-with($uri, $v:mediaobject-input-base-uri)"/>

  <xsl:variable name="input-uri"
                select="if ($expected-location)
                        then substring-after($uri, $v:mediaobject-input-base-uri)
                        else $uri"/>

  <xsl:message use-when="'mediaobject-uris' = $v:debug"
               select="'3: m/o input-uri:', $input-uri"/>

  <xsl:variable name="output-uri"
                select="if (exists($v:mediaobject-output-base-uri)
                            and $expected-location)
                        then $v:mediaobject-output-base-uri || $input-uri
                        else $input-uri"/>

  <xsl:message use-when="'mediaobject-uris' = $v:debug"
               select="'5: mediaobject output:', $uri, '→', $output-uri"/>

  <xsl:sequence select="$output-uri"/>
</xsl:function>

<xsl:function name="f:select-mediaobject" as="element()">
  <xsl:param name="objects" as="element()+"/>

  <xsl:variable name="possible" as="element()*">
    <xsl:apply-templates select="$objects" mode="m:acceptable-mediaobject"/>
  </xsl:variable>

  <xsl:sequence select="if (exists($possible))
                        then $possible[1]
                        else $objects[1]"/>
</xsl:function>

<xsl:template match="db:audioobject
                     |db:imageobject
                     |db:imageobjectco
                     |db:videoobject"
              as="element()?"
              mode="m:acceptable-mediaobject">
  <xsl:sequence select="if (exists(f:select-mediaobject-data(*)))
                        then .
                        else ()"/>
</xsl:template>

<xsl:function name="f:select-mediaobject-data" as="element()?">
  <xsl:param name="data" as="element()*"/>
  <xsl:sequence select="f:select-mediaobject-data($data, false())"/>
</xsl:function>

<xsl:function name="f:select-mediaobject-data" as="element()?">
  <xsl:param name="data" as="element()*"/>
  <xsl:param name="force" as="xs:boolean"/>

  <xsl:variable name="selected" as="element()*">
    <xsl:apply-templates select="$data"
                         mode="m:acceptable-mediaobject-data"/>
  </xsl:variable>

  <xsl:if test="$force and empty($selected)">
    <xsl:message select="'No acceptable media type, using ',
                         $data[1]/@fileref/string()"/>
  </xsl:if>

  <xsl:sequence select="if (exists($selected))
                        then $selected[1]
                        else if ($force)
                             then $data[1]
                             else ()"/>
</xsl:function>

<xsl:template match="db:textobject"
              as="element()?"
              mode="m:acceptable-mediaobject">
  <xsl:sequence select="."/>
</xsl:template>

<xsl:template match="db:info|db:alt|db:caption|db:areaspec"
              mode="m:acceptable-mediaobject"/>

<xsl:template match="*" mode="m:acceptable-mediaobject">
  <xsl:message expand-text="yes"
               >Unexpected mediaobject: {local-name(.)}</xsl:message>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:audiodata|db:imagedata|db:videodata"
              as="element()*"
              mode="m:acceptable-mediaobject-data">
  <xsl:variable name="data" select="."/>
  <xsl:variable name="exclude" as="xs:string*">
    <xsl:for-each select="$mediaobject-exclude-extensions">
      <xsl:sequence select="if (ends-with($data/@fileref, .))
                            then .
                            else ()"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:if test="empty($exclude)">
    <xsl:sequence select="."/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:imageobject" mode="m:acceptable-mediaobject-data">
  <xsl:apply-templates select="db:imagedata"/>
</xsl:template>

<xsl:template match="db:info|db:areaspec|db:calloutlist"
              mode="m:acceptable-mediaobject-data"/>

<xsl:template match="*" mode="m:acceptable-mediaobject-data">
  <xsl:message expand-text="yes"
               >Unexpected mediaobject child: {local-name(.)}</xsl:message>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="db:alt"/>

</xsl:stylesheet>
