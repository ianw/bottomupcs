<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:vp="http://docbook.org/ns/docbook/variables/private"
                 xmlns:xs="http://www.w3.org/2001/XMLSchema"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 version="3.0">
   <xsl:variable name="vp:static-parameters" as="map(xs:QName, item()*)">
      <xsl:map>
         <xsl:map-entry key="xs:QName('debug')" select="$debug"/>
      </xsl:map>
   </xsl:variable>
   <xsl:variable name="vp:dynamic-parameters" as="map(xs:QName, item()*)">
      <xsl:map>
         <xsl:map-entry key="xs:QName('xspec')" select="$xspec"/>
         <xsl:map-entry key="xs:QName('gentext-language')" select="$gentext-language"/>
         <xsl:map-entry key="xs:QName('verbatim-line-style')" select="$verbatim-line-style"/>
         <xsl:map-entry key="xs:QName('verbatim-plain-style')" select="$verbatim-plain-style"/>
         <xsl:map-entry key="xs:QName('verbatim-space')" select="$verbatim-space"/>
         <xsl:map-entry key="xs:QName('verbatim-trim-trailing-blank-lines')"
                         select="$verbatim-trim-trailing-blank-lines"/>
         <xsl:map-entry key="xs:QName('verbatim-style-default')"
                         select="$verbatim-style-default"/>
         <xsl:map-entry key="xs:QName('verbatim-numbered-elements')"
                         select="$verbatim-numbered-elements"/>
         <xsl:map-entry key="xs:QName('verbatim-number-minlines')"
                         select="$verbatim-number-minlines"/>
         <xsl:map-entry key="xs:QName('verbatim-number-every-nth')"
                         select="$verbatim-number-every-nth"/>
         <xsl:map-entry key="xs:QName('verbatim-number-first-line')"
                         select="$verbatim-number-first-line"/>
         <xsl:map-entry key="xs:QName('verbatim-callouts')" select="$verbatim-callouts"/>
         <xsl:map-entry key="xs:QName('verbatim-syntax-highlighter')"
                         select="$verbatim-syntax-highlighter"/>
         <xsl:map-entry key="xs:QName('verbatim-syntax-highlight-languages')"
                         select="$verbatim-syntax-highlight-languages"/>
         <xsl:map-entry key="xs:QName('callout-default-column')"
                         select="$callout-default-column"/>
         <xsl:map-entry key="xs:QName('pixels-per-inch')" select="$pixels-per-inch"/>
         <xsl:map-entry key="xs:QName('nominal-page-width')" select="$nominal-page-width"/>
         <xsl:map-entry key="xs:QName('default-length-magnitude')"
                         select="$default-length-magnitude"/>
         <xsl:map-entry key="xs:QName('default-length-unit')" select="$default-length-unit"/>
         <xsl:map-entry key="xs:QName('table-accessibility')" select="$table-accessibility"/>
         <xsl:map-entry key="xs:QName('mediaobject-accessibility')"
                         select="$mediaobject-accessibility"/>
         <xsl:map-entry key="xs:QName('align-char-default')" select="$align-char-default"/>
         <xsl:map-entry key="xs:QName('align-char-width')" select="$align-char-width"/>
         <xsl:map-entry key="xs:QName('align-char-pad')" select="$align-char-pad"/>
         <xsl:map-entry key="xs:QName('mediaobject-exclude-extensions')"
                         select="$mediaobject-exclude-extensions"/>
         <xsl:map-entry key="xs:QName('mediaobject-input-base-uri')"
                         select="$mediaobject-input-base-uri"/>
         <xsl:map-entry key="xs:QName('mediaobject-output-base-uri')"
                         select="$mediaobject-output-base-uri"/>
         <xsl:map-entry key="xs:QName('image-ignore-scaling')" select="$image-ignore-scaling"/>
         <xsl:map-entry key="xs:QName('image-property-warning')"
                         select="$image-property-warning"/>
         <xsl:map-entry key="xs:QName('image-nominal-width')" select="$image-nominal-width"/>
         <xsl:map-entry key="xs:QName('image-nominal-height')" select="$image-nominal-height"/>
         <xsl:map-entry key="xs:QName('default-personal-name-style')"
                         select="$default-personal-name-style"/>
         <xsl:map-entry key="xs:QName('othername-in-middle')" select="$othername-in-middle"/>
         <xsl:map-entry key="xs:QName('productionset-lhs-rhs-separator')"
                         select="$productionset-lhs-rhs-separator"/>
         <xsl:map-entry key="xs:QName('date-date-format')" select="$date-date-format"/>
         <xsl:map-entry key="xs:QName('date-dateTime-format')" select="$date-dateTime-format"/>
         <xsl:map-entry key="xs:QName('qandaset-default-toc')" select="$qandaset-default-toc"/>
         <xsl:map-entry key="xs:QName('qandadiv-default-toc')" select="$qandadiv-default-toc"/>
         <xsl:map-entry key="xs:QName('qandaset-default-label')"
                         select="$qandaset-default-label"/>
         <xsl:map-entry key="xs:QName('funcsynopsis-default-style')"
                         select="$funcsynopsis-default-style"/>
         <xsl:map-entry key="xs:QName('funcsynopsis-table-threshold')"
                         select="$funcsynopsis-table-threshold"/>
         <xsl:map-entry key="xs:QName('funcsynopsis-trailing-punctuation')"
                         select="$funcsynopsis-trailing-punctuation"/>
         <xsl:map-entry key="xs:QName('classsynopsis-indent')" select="$classsynopsis-indent"/>
         <xsl:map-entry key="xs:QName('copyright-collapse-years')"
                         select="$copyright-collapse-years"/>
         <xsl:map-entry key="xs:QName('copyright-year-separator')"
                         select="$copyright-year-separator"/>
         <xsl:map-entry key="xs:QName('copyright-year-range-separator')"
                         select="$copyright-year-range-separator"/>
         <xsl:map-entry key="xs:QName('division-numbers-inherit')"
                         select="$division-numbers-inherit"/>
         <xsl:map-entry key="xs:QName('component-numbers-inherit')"
                         select="$component-numbers-inherit"/>
         <xsl:map-entry key="xs:QName('section-numbers')" select="$section-numbers"/>
         <xsl:map-entry key="xs:QName('section-numbers-inherit')"
                         select="$section-numbers-inherit"/>
         <xsl:map-entry key="xs:QName('number-single-appendix')"
                         select="$number-single-appendix"/>
         <xsl:map-entry key="xs:QName('generate-toc')" select="$generate-toc"/>
         <xsl:map-entry key="xs:QName('generate-nested-toc')" select="$generate-nested-toc"/>
         <xsl:map-entry key="xs:QName('generate-trivial-toc')" select="$generate-trivial-toc"/>
         <xsl:map-entry key="xs:QName('section-toc-depth')" select="$section-toc-depth"/>
         <xsl:map-entry key="xs:QName('vp:section-toc-depth')" select="$vp:section-toc-depth"/>
         <xsl:map-entry key="xs:QName('annotation-style')" select="$annotation-style"/>
         <xsl:map-entry key="xs:QName('annotation-mark')" select="$annotation-mark"/>
         <xsl:map-entry key="xs:QName('annotation-placement')" select="$annotation-placement"/>
         <xsl:map-entry key="xs:QName('xlink-style')" select="$xlink-style"/>
         <xsl:map-entry key="xs:QName('xlink-style-default')" select="$xlink-style-default"/>
         <xsl:map-entry key="xs:QName('xlink-icon-open')" select="$xlink-icon-open"/>
         <xsl:map-entry key="xs:QName('xlink-icon-closed')" select="$xlink-icon-closed"/>
         <xsl:map-entry key="xs:QName('revhistory-style')" select="$revhistory-style"/>
         <xsl:map-entry key="xs:QName('segmentedlist-style')" select="$segmentedlist-style"/>
         <xsl:map-entry key="xs:QName('formal-object-title-placement')"
                         select="$formal-object-title-placement"/>
         <xsl:map-entry key="xs:QName('lists-of-figures')" select="$lists-of-figures"/>
         <xsl:map-entry key="xs:QName('lists-of-tables')" select="$lists-of-tables"/>
         <xsl:map-entry key="xs:QName('lists-of-examples')" select="$lists-of-examples"/>
         <xsl:map-entry key="xs:QName('lists-of-equations')" select="$lists-of-equations"/>
         <xsl:map-entry key="xs:QName('lists-of-procedures')" select="$lists-of-procedures"/>
         <xsl:map-entry key="xs:QName('variablelist-termlength-threshold')"
                         select="$variablelist-termlength-threshold"/>
         <xsl:map-entry key="xs:QName('procedure-step-numeration')"
                         select="$procedure-step-numeration"/>
         <xsl:map-entry key="xs:QName('orderedlist-item-numeration')"
                         select="$orderedlist-item-numeration"/>
         <xsl:map-entry key="xs:QName('refentry-generate-name')"
                         select="$refentry-generate-name"/>
         <xsl:map-entry key="xs:QName('refentry-generate-title')"
                         select="$refentry-generate-title"/>
         <xsl:map-entry key="xs:QName('annotate-toc')" select="$annotate-toc"/>
         <xsl:map-entry key="xs:QName('callout-unicode-start')" select="$callout-unicode-start"/>
         <xsl:map-entry key="xs:QName('index-show-entries')" select="$index-show-entries"/>
         <xsl:map-entry key="xs:QName('generate-index')" select="$generate-index"/>
         <xsl:map-entry key="xs:QName('index-on-role')" select="$index-on-role"/>
         <xsl:map-entry key="xs:QName('index-on-type')" select="$index-on-type"/>
         <xsl:map-entry key="xs:QName('indexed-section-groups')"
                         select="$indexed-section-groups"/>
         <xsl:map-entry key="xs:QName('glossary-sort-entries')" select="$glossary-sort-entries"/>
         <xsl:map-entry key="xs:QName('sort-collation')" select="$sort-collation"/>
         <xsl:map-entry key="xs:QName('default-float-style')" select="$default-float-style"/>
         <xsl:map-entry key="xs:QName('show-remarks')" select="$show-remarks"/>
         <xsl:map-entry key="xs:QName('sidebar-as-aside')" select="$sidebar-as-aside"/>
         <xsl:map-entry key="xs:QName('resource-base-uri')" select="$resource-base-uri"/>
         <xsl:map-entry key="xs:QName('use-docbook-css')" select="$use-docbook-css"/>
         <xsl:map-entry key="xs:QName('oxy-markup')" select="$oxy-markup"/>
         <xsl:map-entry key="xs:QName('verbatim-syntax-highlight-css')"
                         select="$verbatim-syntax-highlight-css"/>
         <xsl:map-entry key="xs:QName('persistent-toc-css')" select="$persistent-toc-css"/>
         <xsl:map-entry key="xs:QName('oxy-markup-css')" select="$oxy-markup-css"/>
         <xsl:map-entry key="xs:QName('user-css-links')" select="$user-css-links"/>
         <xsl:map-entry key="xs:QName('annotations-js')" select="$annotations-js"/>
         <xsl:map-entry key="xs:QName('xlink-js')" select="$xlink-js"/>
         <xsl:map-entry key="xs:QName('persistent-toc-js')" select="$persistent-toc-js"/>
         <xsl:map-entry key="xs:QName('mathml-js')" select="$mathml-js"/>
         <xsl:map-entry key="xs:QName('control-js')" select="$control-js"/>
         <xsl:map-entry key="xs:QName('theme-picker')" select="$theme-picker"/>
         <xsl:map-entry key="xs:QName('chunk')" select="$chunk"/>
         <xsl:map-entry key="xs:QName('chunk-nav')" select="$chunk-nav"/>
         <xsl:map-entry key="xs:QName('chunk-nav-js')" select="$chunk-nav-js"/>
         <xsl:map-entry key="xs:QName('chunk-output-base-uri')" select="$chunk-output-base-uri"/>
         <xsl:map-entry key="xs:QName('chunk-section-depth')" select="$chunk-section-depth"/>
         <xsl:map-entry key="xs:QName('chunk-renumber-footnotes')"
                         select="$chunk-renumber-footnotes"/>
         <xsl:map-entry key="xs:QName('chunk-include')" select="$chunk-include"/>
         <xsl:map-entry key="xs:QName('chunk-exclude')" select="$chunk-exclude"/>
         <xsl:map-entry key="xs:QName('html-extension')" select="$html-extension"/>
         <xsl:map-entry key="xs:QName('footnote-numeration')" select="$footnote-numeration"/>
         <xsl:map-entry key="xs:QName('table-footnote-numeration')"
                         select="$table-footnote-numeration"/>
         <xsl:map-entry key="xs:QName('persistent-toc')" select="$persistent-toc"/>
         <xsl:map-entry key="xs:QName('persistent-toc-search')" select="$persistent-toc-search"/>
         <xsl:map-entry key="xs:QName('profile-separator')" select="$profile-separator"/>
         <xsl:map-entry key="xs:QName('profile-lang')" select="$profile-lang"/>
         <xsl:map-entry key="xs:QName('profile-revisionflag')" select="$profile-revisionflag"/>
         <xsl:map-entry key="xs:QName('profile-role')" select="$profile-role"/>
         <xsl:map-entry key="xs:QName('profile-arch')" select="$profile-arch"/>
         <xsl:map-entry key="xs:QName('profile-audience')" select="$profile-audience"/>
         <xsl:map-entry key="xs:QName('profile-condition')" select="$profile-condition"/>
         <xsl:map-entry key="xs:QName('profile-conformance')" select="$profile-conformance"/>
         <xsl:map-entry key="xs:QName('profile-os')" select="$profile-os"/>
         <xsl:map-entry key="xs:QName('profile-outputformat')" select="$profile-outputformat"/>
         <xsl:map-entry key="xs:QName('profile-revision')" select="$profile-revision"/>
         <xsl:map-entry key="xs:QName('profile-security')" select="$profile-security"/>
         <xsl:map-entry key="xs:QName('profile-userlevel')" select="$profile-userlevel"/>
         <xsl:map-entry key="xs:QName('profile-vendor')" select="$profile-vendor"/>
         <xsl:map-entry key="xs:QName('profile-wordsize')" select="$profile-wordsize"/>
         <xsl:map-entry key="xs:QName('annotation-collection')" select="$annotation-collection"/>
         <xsl:map-entry key="xs:QName('glossary-collection')" select="$glossary-collection"/>
         <xsl:map-entry key="xs:QName('bibliography-collection')"
                         select="$bibliography-collection"/>
         <xsl:map-entry key="xs:QName('olink-databases')" select="$olink-databases"/>
         <xsl:map-entry key="xs:QName('docbook-transclusion')" select="$docbook-transclusion"/>
         <xsl:map-entry key="xs:QName('transclusion-prefix-separator')"
                         select="$transclusion-prefix-separator"/>
         <xsl:map-entry key="xs:QName('local-conventions')" select="$local-conventions"/>
         <xsl:map-entry key="xs:QName('relax-ng-grammar')" select="$relax-ng-grammar"/>
         <xsl:map-entry key="xs:QName('allow-eval')" select="$allow-eval"/>
         <xsl:map-entry key="xs:QName('dynamic-profiles')" select="$dynamic-profiles"/>
         <xsl:map-entry key="xs:QName('dynamic-profile-error')" select="$dynamic-profile-error"/>
         <xsl:map-entry key="xs:QName('experimental-pmuj')" select="$experimental-pmuj"/>
         <xsl:map-entry key="xs:QName('default-theme')" select="$default-theme"/>
         <xsl:map-entry key="xs:QName('generate-html-page')" select="$generate-html-page"/>
         <xsl:map-entry key="xs:QName('dc-metadata')" select="$dc-metadata"/>
         <xsl:map-entry key="xs:QName('generator-metadata')" select="$generator-metadata"/>
         <xsl:map-entry key="xs:QName('paper-size')" select="$paper-size"/>
         <xsl:map-entry key="xs:QName('page-style')" select="$page-style"/>
      </xsl:map>
   </xsl:variable>
</xsl:stylesheet>
