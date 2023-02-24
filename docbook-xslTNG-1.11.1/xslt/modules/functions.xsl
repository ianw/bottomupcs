<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:fp="http://docbook.org/ns/docbook/functions/private"
                xmlns:l="http://docbook.org/ns/docbook/l10n"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:mp="http://docbook.org/ns/docbook/modes/private"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="array db f fp l m map mp v vp xs"
                version="3.0">

<xsl:key name="id" match="*" use="@xml:id"/>
<xsl:key name="genid" match="*" use="generate-id(.)"/>

<xsl:function name="f:attributes" as="attribute()*">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="attributes" as="attribute()*"/>
  <xsl:sequence select="f:attributes($node, $attributes, local-name($node), ())"/>
</xsl:function>

<xsl:function name="f:attributes" as="attribute()*">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="attributes" as="attribute()*"/>
  <xsl:param name="extra-classes" as="xs:string*"/>
  <xsl:param name="exclude-classes" as="xs:string*"/>

  <!--
  <xsl:message>
    <xsl:text>f:attributes(</xsl:text>
    <xsl:value-of select="node-name($node)"/>
    <xsl:text>,</xsl:text>
    <xsl:sequence select="$attributes"/>
    <xsl:text>,</xsl:text>
    <xsl:sequence select="$extra-classes"/>
    <xsl:text>,</xsl:text>
    <xsl:sequence select="$exclude-classes"/>
    <xsl:text>)</xsl:text>
  </xsl:message>
  -->

  <!-- combine duplicates -->
  <xsl:variable name="names"
                select="distinct-values($attributes/node-name())"/>
  <xsl:for-each select="$names">
    <xsl:variable name="name" select="."/>
    <xsl:variable name="values" as="xs:string*"
                  select="$attributes[node-name()=$name]/string()"/>
    <xsl:if test="exists($values)">
      <xsl:attribute name="{$name}"
                     select="string-join($values, ' ')"/>
    </xsl:if>
  </xsl:for-each>

  <!-- if there isn't a class attribute, manufacture one -->
  <xsl:if test="not(QName('', 'class') = $attributes/node-name())">
    <xsl:variable name="roles"
                  select="(tokenize(normalize-space(string-join($extra-classes, ' '))),
                           tokenize(normalize-space($node/@role)),
                           if ($node/@revisionflag)
                           then 'rev'||$node/@revisionflag
                           else ())"/>
    <xsl:variable name="exclude" 
                  select="tokenize(normalize-space(string-join($exclude-classes, ' ')))"/>
    <!-- sort them and make them unique -->
    <xsl:variable name="classes" as="xs:string*">
      <xsl:for-each select="distinct-values($roles)">
        <xsl:sort select="."/>
        <xsl:if test="not(. = $exclude)">
          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:if test="exists($classes)">
      <xsl:attribute name="class" select="string-join($classes, ' ')"/>
    </xsl:if>
  </xsl:if>
</xsl:function>

<xsl:function name="f:is-true" as="xs:boolean" visibility="public">
  <xsl:param name="value"/>

  <xsl:choose>
    <xsl:when test="empty($value)">
      <xsl:value-of select="false()"/>
    </xsl:when>
    <xsl:when test="$value castable as xs:boolean">
      <xsl:value-of select="xs:boolean($value)"/>
    </xsl:when>
    <xsl:when test="$value castable as xs:integer">
      <xsl:value-of select="xs:integer($value) != 0"/>
    </xsl:when>
    <xsl:when test="string($value) = ('true', 'yes')">
      <xsl:value-of select="true()"/>
    </xsl:when>
    <xsl:when test="string($value) = ('false', 'no')">
      <xsl:value-of select="false()"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message expand-text="yes"
                   >Warning: interpreting ‘{$value}’ as true.</xsl:message>
      <xsl:value-of select="true()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:orderedlist-startingnumber" as="xs:integer">
  <xsl:param name="list" as="element(db:orderedlist)"/>

  <xsl:choose>
    <xsl:when test="not($list/@continuation = 'continues')">
      <xsl:sequence select="1"/>
    </xsl:when>
    <xsl:when test="empty($list/preceding::db:orderedlist)">
      <xsl:message>
        <xsl:text>Warning: orderedlist continuation=continues, </xsl:text>
        <xsl:text>but no preceding list</xsl:text>
      </xsl:message>
      <xsl:sequence select="1"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- Hat tip to Gerrit for the fix here -->
      <xsl:variable name="plist"
                    select="$list/outermost(preceding::db:orderedlist)[last()]"/>

      <xsl:sequence select="f:orderedlist-startingnumber($plist)
                            + count($plist/db:listitem)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:l10n-language" as="xs:string">
  <xsl:param name="target" as="element()"/>

  <xsl:variable name="mc-language" as="xs:string"
                select="($gentext-language,
                        $target/ancestor-or-self::*[@xml:lang][1]/@xml:lang,
                        $default-language)[1]"/>

  <xsl:variable name="language" select="translate($mc-language,
                                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                                        'abcdefghijklmnopqrstuvwxyz')"/>

  <xsl:variable name="adjusted-language"
                select="if (contains($language, '-'))
                        then substring-before($language, '-')
                             || '_' || substring-after($language, '-')
                        else $language"/>

  <xsl:choose>
    <xsl:when test="fp:localization($target, $adjusted-language, false())">
      <xsl:sequence select="$adjusted-language"/>
    </xsl:when>
    <!-- try just the lang code without country -->
    <xsl:when test="fp:localization($target, substring-before($adjusted-language,'_'), false())">
      <xsl:sequence select="substring-before($adjusted-language,'_')"/>
    </xsl:when>
    <!-- or use the default -->
    <xsl:otherwise>
      <xsl:message>
        <xsl:text>No localization exists for "</xsl:text>
        <xsl:sequence select="$adjusted-language"/>
        <xsl:text>" or "</xsl:text>
        <xsl:sequence select="substring-before($adjusted-language,'_')"/>
        <xsl:text>". Using default "</xsl:text>
        <xsl:sequence select="$default-language"/>
        <xsl:text>".</xsl:text>
      </xsl:message>
      <xsl:sequence select="$default-language"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:check-gentext" as="item()*">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="context" as="xs:string"/>
  <xsl:param name="key" as="xs:string"/>
  <xsl:sequence select="fp:gentext($node, $context, $key, false())"/>
</xsl:function>

<xsl:function name="f:gentext-letters" as="element(l:letters)">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="f:gentext-letters-for-language($node)"/>
</xsl:function>

<xsl:function name="f:gentext-letters-for-language" as="element(l:letters)">
  <xsl:param name="node" as="element()"/>

  <xsl:variable name="lang" select="f:language($node)"/>

  <xsl:variable name="l10n"
                select="fp:existing-localization($node)"/>

  <xsl:variable name="letters"
                select="$l10n/l:letters"/>

  <xsl:if test="empty($letters)">
    <xsl:message select="'No letters for', $lang"/>
  </xsl:if>

  <xsl:if test="count($letters) gt 1">
    <xsl:message
        select="'Multiple letters for localization:', $lang"/>
  </xsl:if>

  <xsl:sequence select="$letters[1]"/>
</xsl:function>

<xsl:function name="fp:properties" as="map(*)">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="properties" as="array(map(*))"/>

  <xsl:variable name="props" as="map(*)*">
    <xsl:for-each select="1 to array:size($properties)">
      <xsl:variable name="map" select="array:get($properties, .)"/>
      <xsl:variable name="nodes" as="node()*">
        <xsl:evaluate context-item="$context" xpath="$map?xpath"/>
      </xsl:variable>
      <xsl:if test="exists($nodes)">
        <xsl:sequence select="$map"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="empty($props)">
      <xsl:message use-when="'properties' = $v:debug"
          select="'No properties for ' || local-name($context)"/>
      <xsl:sequence select="map { }"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$props[1]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:date-format" as="xs:string">
  <xsl:param name="context" as="element()"/>

  <xsl:variable name="format"
                select="f:pi($context, 'date-format')"/>

  <xsl:choose>
    <xsl:when test="$context/*">
      <xsl:sequence select="'apply-templates'"/>
    </xsl:when>
    <xsl:when test="string($context) castable as xs:dateTime">
      <xsl:choose>
        <xsl:when test="$format">
          <xsl:sequence select="$format"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$date-dateTime-format"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="string($context) castable as xs:date">
      <xsl:choose>
        <xsl:when test="$format">
          <xsl:sequence select="$format"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$date-date-format"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="'apply-templates'"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="f:post-label-punctuation" as="xs:string?">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="f:post-label-punctuation($node, ())"/>
</xsl:function>

<xsl:function name="f:post-label-punctuation" as="xs:string?">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="context" as="xs:string?"/>
  <xsl:sequence select="if ($context = 'xref')
                        then ()
                        else '.'"/>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="fp:replace-element" as="array(*)">
  <xsl:param name="lines" as="array(*)"/>
  <xsl:param name="elemno" as="xs:integer"/>
  <xsl:param name="new-elem" as="item()*"/>
  <xsl:sequence
      select="fp:replace-element($lines, $elemno, 1, $new-elem, [])"/>
</xsl:function>

<xsl:function name="fp:replace-element" as="array(*)">
  <!-- See https://saxonica.plan.io/issues/4500 -->
  <!-- reimplement this with array:join when that but is fixed -->
  <xsl:param name="array" as="array(*)"/>
  <xsl:param name="elemno" as="xs:integer"/>
  <xsl:param name="count" as="xs:integer"/>
  <xsl:param name="new-elem" as="item()*"/>
  <xsl:param name="newarray" as="array(*)"/>

  <xsl:choose>
    <xsl:when test="$count gt array:size($array)">
      <xsl:sequence select="$newarray"/>
    </xsl:when>
    <xsl:when test="$count = $elemno">
      <xsl:sequence
          select="fp:replace-element($array, $elemno, $count+1, $new-elem,
                                     array:append($newarray, $new-elem))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence
          select="fp:replace-element($array, $elemno, $count+1, $new-elem,
                                     array:append($newarray, $array($count)))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:target" as="element()*" cache="yes">
  <xsl:param name="id" as="xs:string"/>
  <xsl:param name="context" as="node()"/>
  <xsl:sequence select="key('id', $id, root($context))"/>
</xsl:function>

<xsl:function name="f:href" as="xs:string" cache="yes">
  <xsl:param name="context" as="node()"/>
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="'#' || f:generate-id($node)"/>
</xsl:function>

<xsl:variable name="vp:gidmap" select="map {
  'acknowledgements': 'ack',
  'appendix': 'ap',
  'book': 'bo',
  'chapter': 'ch',
  'colophon': 'co',
  'dedication': 'ded',
  'equation': 'eq',
  'example': 'ex',
  'figure': 'fig',
  'part': 'part',
  'preface': 'p',
  'procedure': 'proc',
  'refentry': 're',
  'reference': 'ref',
  'refsect1': 'rs1',
  'refsect2': 'rs2',
  'refsect3': 'rs3',
  'sect1': 's1_',
  'sect2': 's2_',
  'sect3': 's3_',
  'sect4': 's4_',
  'sect5': 's5_',
  'section': 's',
  'table': 'tab',
  'glossary': 'g',
  'glossdiv': 'gd',
  'glossentry': 'ge',
  'glossterm': 'gt',
  'bibliography': 'bi',
  'bibliodiv': 'bd'
  }"/>

<xsl:function name="f:generate-id" as="xs:string" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="f:generate-id($node, true())"/>
</xsl:function>

<xsl:function name="f:generate-id" as="xs:string" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="use-xml-id" as="xs:boolean"/>
  <xsl:choose>
    <xsl:when test="$use-xml-id and $node/@xml:id">
      <xsl:sequence select="$node/@xml:id/string()"/>
    </xsl:when>
    <xsl:when test="empty($node/parent::*)">
      <xsl:sequence select="$generated-id-root"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="aid" select="f:generate-id($node/parent::*, $use-xml-id)"/>
      <xsl:variable name="type" select="(map:get($vp:gidmap, local-name($node)),
                                         local-name($node))[1]"/>
      <xsl:variable name="prec"
                    select="$node/preceding-sibling::*[node-name(.)=node-name($node)]"/>
      <xsl:sequence
          select="$aid || $generated-id-sep || $type || string(count($prec)+1)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:id" as="xs:string" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="if ($node/@xml:id)
                        then $node/@xml:id/string()
                        else f:generate-id($node)"/>
</xsl:function>

<xsl:function name="f:unique-id" as="xs:string" cache="yes">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="f:generate-id($node, false())"/>
</xsl:function>

<xsl:function name="f:pi" as="xs:string?" visibility="public">
  <xsl:param name="context" as="node()?"/>
  <xsl:param name="property" as="xs:string"/>
  <xsl:sequence select="f:pi($context, $property, ())"/>
</xsl:function>

<xsl:function name="f:pi" as="xs:string*" visibility="public">
  <xsl:param name="context" as="node()?"/>
  <xsl:param name="property" as="xs:string"/>
  <xsl:param name="default" as="xs:string*"/>

  <xsl:choose>
    <xsl:when test="empty($context)">
      <xsl:sequence select="$default"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fp:pi-from-list(($context/processing-instruction('db'),
                                             root($context)/processing-instruction('db')),
                                            $property, $default)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="fp:pi-from-list" as="xs:string*">
  <xsl:param name="pis" as="processing-instruction()*"/>
  <xsl:param name="property" as="xs:string"/>
  <xsl:param name="default" as="xs:string*"/>

  <xsl:variable name="value"
                select="f:pi-attributes($pis)/@*[local-name(.) = $property]/string()"/>

  <xsl:sequence select="if (empty($value))
                        then $default
                        else $value"/>
</xsl:function>

<xsl:function name="f:pi-attributes" as="element()?">
  <xsl:param name="pis" as="processing-instruction()*"/>

  <xsl:variable name="attributes"
                select="fp:pi-attributes($pis, map { })"/>

  <xsl:element name="pis" namespace="">
    <xsl:for-each select="map:keys($attributes)">
      <xsl:attribute name="{.}" select="map:get($attributes, .)"/>
    </xsl:for-each>
  </xsl:element>
</xsl:function>

<xsl:function name="fp:pi-attributes" as="map(*)?">
  <xsl:param name="pis" as="processing-instruction()*"/>
  <xsl:param name="pimap" as="map(*)"/>

  <xsl:choose>
    <xsl:when test="empty($pis)">
      <xsl:sequence select="$pimap"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="map" select="fp:pi-pi-attributes($pimap,
                                          normalize-space($pis[1]))"/>
      <xsl:sequence select="fp:pi-attributes(subsequence($pis, 2), $map)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:variable name="vp:pi-match"
              select="'^.*?(\c+)=[''&quot;](.*?)[''&quot;](.*)$'"/>
<xsl:function name="fp:pi-pi-attributes" as="map(*)">
  <xsl:param name="pimap" as="map(*)"/>
  <xsl:param name="text" as="xs:string"/>

  <xsl:choose>
    <xsl:when test="matches($text, $vp:pi-match)">
      <xsl:variable name="aname" select="replace($text, $vp:pi-match, '$1')"/>
      <xsl:variable name="avalue" select="replace($text, $vp:pi-match, '$2')"/>
      <xsl:variable name="rest" select="replace($text, $vp:pi-match, '$3')"/>
      <xsl:sequence select="fp:pi-pi-attributes(map:put($pimap, $aname, $avalue),
                                                $rest)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$pimap"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:spaces" as="xs:string?">
  <xsl:param name="length" as="item()*"/>

  <xsl:choose>
    <xsl:when test="empty($length)"/>
    <xsl:when test="count($length) gt 1">
      <xsl:sequence
          select="f:spaces(string-join($length ! string(.), ''))"/>
    </xsl:when>
    <xsl:when test="$length castable as xs:integer">
      <xsl:variable name="length" select="xs:integer($length)"/>
      <xsl:choose>
        <xsl:when test="$length lt 0"/>
        <xsl:when test="$length lt 10">
          <xsl:sequence select="substring('          ', 1, $length)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'          ' || f:spaces($length - 10)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:spaces(string-length(string($length)))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<xsl:function name="fp:lookup-string" as="node()*">
  <xsl:param name="context" as="element()"/>
  <xsl:param name="lookup" as="element()"/>
  <xsl:param name="table-name" as="xs:string"/>

  <xsl:variable name="value"
                select="$lookup/*[node-name(.)=node-name($context)]"/>

  <xsl:if test="count($value) gt 1">
    <xsl:message expand-text="yes"
                 >Duplicate {$table-name} for {node-name($context)}</xsl:message>
  </xsl:if>

  <xsl:sequence select="if (empty($value))
                        then $lookup/db:_default/node()
                        else $value[1]/node()"/>
</xsl:function>

<xsl:function name="fp:separator" as="node()*">
  <xsl:param name="node" as="element()"/>
  <xsl:param name="context" as="xs:string"/>
  <xsl:choose>
    <xsl:when test="f:check-gentext($node, $context, local-name($node))">
      <xsl:sequence
          select="f:gentext($node, $context, local-name($node))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence
          select="f:gentext($node, $context, '_default')"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:label-separator" as="node()*">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="fp:separator($node, 'label-separator')"/>
</xsl:function>

<xsl:function name="f:number-separator" as="node()*">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="fp:separator($node, 'number-separator')"/>
</xsl:function>

<xsl:function name="f:intra-number-separator" as="node()*">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="fp:separator($node, 'intra-number-separator')"/>
</xsl:function>

<xsl:function name="fp:label-format" as="node()*">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="fp:separator($node, 'label-format')"/>
</xsl:function>

<xsl:function name="fp:parse-key-value-pairs" as="map(xs:string,xs:string)">
  <xsl:param name="strings" as="xs:string*"/>
  <xsl:sequence select="fp:parse-key-value-pairs($strings, map { })"/>
</xsl:function>

<xsl:function name="fp:parse-key-value-pairs" as="map(xs:string,xs:string)">
  <xsl:param name="strings" as="xs:string*"/>
  <xsl:param name="map" as="map(xs:string,xs:string)"/>

  <xsl:variable name="car" select="$strings[1]"/>
  <xsl:variable name="cdr" select="subsequence($strings, 2)"/>

  <xsl:variable name="key" select="if (contains($car, ':'))
                                   then substring-before($car, ':')
                                   else '_default'"/>
  <xsl:variable name="value" select="if (contains($car, ':'))
                                     then substring-after($car, ':')
                                     else $car"/>

  <xsl:choose>
    <xsl:when test="empty($car)">
      <xsl:sequence select="$map"/>
    </xsl:when>
    <xsl:when test="map:contains($map, $key)">
      <xsl:message select="'Warning: ignoring duplicate key:', $key"/>
      <xsl:sequence select="fp:parse-key-value-pairs($cdr, $map)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="fp:parse-key-value-pairs($cdr,
                               map:put($map, $key, $value))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:refsection" as="xs:boolean">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="$node/self::db:refsection
                        or $node/self::db:refsect1
                        or $node/self::db:refsect2
                        or $node/self::db:refsect3"/>
</xsl:function> 

<xsl:function name="f:section" as="xs:boolean" visibility="public">
  <xsl:param name="node" as="element()"/>
  <xsl:sequence select="$node/self::db:section
                        or $node/self::db:sect1
                        or $node/self::db:sect2
                        or $node/self::db:sect3
                        or $node/self::db:sect4
                        or $node/self::db:sect5
                        or f:refsection($node)"/>
</xsl:function>

<xsl:function name="f:section-depth" as="xs:integer" visibility="public">
  <xsl:param name="node" as="element()?"/>
  <xsl:choose>
    <xsl:when test="empty($node)">
      <xsl:value-of select="0"/>
    </xsl:when>
    <xsl:when test="$node/self::db:section">
      <xsl:value-of select="count($node/ancestor::db:section) + 1"/>
    </xsl:when>
    <xsl:when test="$node/self::db:sect1 or $node/self::db:sect2
                    or $node/self::db:sect3 or $node/self::db:sect4
                    or $node/self::db:sect5">
      <xsl:value-of select="xs:integer(substring(local-name($node), 5))"/>
    </xsl:when>
    <xsl:when test="$node/self::db:refsection">
      <xsl:value-of select="count($node/ancestor::db:refsection)+1"/>
    </xsl:when>
    <xsl:when test="$node/self::db:refsect1 or $node/self::db:refsect2
                    or $node/self::db:refsect3">
      <xsl:value-of select="xs:integer(substring(local-name($node), 8))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:section-depth($node/parent::*)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="f:step-number" as="xs:integer+">
  <xsl:param name="node" as="element(db:step)"/>
  <xsl:iterate select="reverse($node/ancestor-or-self::*)">
    <xsl:param name="number" select="()"/>
    <xsl:choose>
      <xsl:when test="self::db:procedure">
        <xsl:sequence select="$number"/>
        <xsl:break/>
      </xsl:when>
      <xsl:when test="self::db:step">
        <xsl:next-iteration>
          <xsl:with-param name="number"
                          select="(count(preceding-sibling::db:step)+1, $number)"/>
        </xsl:next-iteration>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-iteration>
          <xsl:with-param name="number" select="$number"/>
        </xsl:next-iteration>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:iterate>
</xsl:function>

<xsl:function name="f:step-numeration" as="xs:string">
  <xsl:param name="node" as="element(db:step)"/>
  <xsl:variable name="depth"
                select="count(f:step-number($node))"/>
  <xsl:variable name="depth"
                select="$depth
                        mod string-length($procedure-step-numeration)"/>
  <xsl:variable name="depth"
                select="if ($depth eq 0)
                        then string-length($procedure-step-numeration)
                        else $depth"/>
  <xsl:sequence select="substring($procedure-step-numeration, $depth, 1)"/>
</xsl:function>

<xsl:function name="f:orderedlist-item-number" as="xs:integer+">
  <xsl:param name="node" as="element(db:listitem)"/>
  <xsl:iterate select="reverse($node/ancestor-or-self::*)">
    <xsl:param name="number" select="()"/>
    <xsl:on-completion select="$number"/>
    <xsl:choose>
      <xsl:when test="self::db:listitem[parent::db:orderedlist]">
        <xsl:next-iteration>
          <xsl:with-param name="number"
                          select="(count(preceding-sibling::db:listitem)
                                   + f:orderedlist-startingnumber(parent::db:orderedlist),
                                   $number)"/>
        </xsl:next-iteration>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-iteration>
          <xsl:with-param name="number" select="$number"/>
        </xsl:next-iteration>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:iterate>
</xsl:function>

<xsl:function name="f:orderedlist-item-numeration" as="xs:string">
  <xsl:param name="node" as="element(db:listitem)"/>
  <xsl:variable name="depth"
                select="count(f:orderedlist-item-number($node))"/>
  <xsl:variable name="depth"
                select="$depth
                        mod string-length($orderedlist-item-numeration)"/>
  <xsl:variable name="depth"
                select="if ($depth eq 0)
                        then string-length($orderedlist-item-numeration)
                        else $depth"/>
  <xsl:sequence select="substring($orderedlist-item-numeration, $depth, 1)"/>
</xsl:function>

<xsl:function name="f:tokenize-on-char" as="xs:string*">
  <xsl:param name="string" as="xs:string"/>
  <xsl:param name="char" as="xs:string"/>

  <xsl:variable name="ch" select="substring($char||' ', 1, 1)"/>

  <xsl:variable name="tchar"
                select="if ($ch = ('.', '?', '*', '{', '}', '\', '\[', '\]'))
                        then '\' || $ch
                        else $ch"/>

  <xsl:sequence select="tokenize($string, $tchar)"/>
</xsl:function>

</xsl:stylesheet>
