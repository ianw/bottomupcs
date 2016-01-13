<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<!-- $Id: xml2pdf.xsl 426576 2006-07-28 15:44:37Z jeremias $ -->
<xsl:stylesheet
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:template match ="root">
  <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <!-- defines page layout -->
    <fo:layout-master-set>

      <fo:simple-page-master master-name="simple"
                    page-height="29.7cm"
                    page-width="21cm"
                    margin-top="1.5cm"
                    margin-bottom="1.5cm"
                    margin-left="2.5cm"
                    margin-right="2.5cm">
        <fo:region-body margin-top="1.5cm"/>
        <fo:region-before extent="1.5cm"/>
        <fo:region-after extent="1.5cm"/>
      </fo:simple-page-master>
    </fo:layout-master-set>

    <fo:page-sequence master-reference="simple">
      <fo:static-content flow-name="xsl-region-before">
        <fo:block text-align="end"
              font-size="10pt"
              font-family="serif"
              line-height="14pt" >
          xsl:fo short reference - p. <fo:page-number/>
        </fo:block>
      </fo:static-content>

      <fo:flow flow-name="xsl-region-body">


       <fo:block font-size="18pt"
                font-family="sans-serif"
                line-height="24pt"
                space-after.optimum="15pt"
                background-color="blue"
                color="white"
                text-align="center">
        xsl:fo short reference
         </fo:block>

<!-- generates table of contents and puts it into a table -->

         <fo:block font-size="10pt"
                  font-family="sans-serif"
                  line-height="10pt"
                  space-after.optimum="3pt"
                  font-weight="bold"
                  start-indent="15pt">
            Content
         </fo:block>

         <fo:table space-after.optimum="15pt">
            <fo:table-column column-width="1cm"/>
            <fo:table-column column-width="15cm"/>
            <fo:table-body font-size="10pt"
                           font-family="sans-serif">

            <xsl:for-each select="div0/head">
               <fo:table-row line-height="12pt">
                  <fo:table-cell>
                     <fo:block text-align="end" >
                        <xsl:number value="position()" format="1"/>)
                     </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                     <fo:block  text-align="start" >
                        <xsl:value-of select="."/>
                     </fo:block>
                  </fo:table-cell>
               </fo:table-row>
            </xsl:for-each>
            </fo:table-body>
         </fo:table>

      <xsl:apply-templates/>
         <fo:block font-size="10pt"
                  font-family="sans-serif"
                  line-height="11pt"
                  space-before.optimum="2cm">
            The explanation of the flow objects is based (mostly verbatim) on the section
            6.2 of the XSL W3C Candidate Recommendation 21 November 2000. More info at the beginning
            of the file xslfoRef.xml.
         </fo:block>

      </fo:flow>
    </fo:page-sequence>
  </fo:root>
</xsl:template>


<xsl:template match ="div">
   <fo:block font-size="14pt"
            font-family="sans-serif"
            space-before.optimum="3pt"
            space-after.optimum="3pt"
            text-align="center"
            padding-top="3pt"
            >
    <xsl:apply-templates/>
   </fo:block>
</xsl:template>

<xsl:template match ="div0/head">
   <fo:block font-size="16pt"
            line-height="18pt"
            text-align="center"
            padding-top="3pt"
            start-indent="2cm"
            end-indent="2cm"
            background-color="blue"
            color="white"
            space-before.optimum="5pt"
            space-after.optimum="5pt"
            >
     <xsl:value-of select="."/>
   </fo:block>
</xsl:template>


<xsl:template match ="div/fo">
   <fo:block font-size="13pt"
            line-height="14pt"
            text-align="start"
            >
     <xsl:value-of select="."/>
   </fo:block>
</xsl:template>

<xsl:template match ="explanation">
   <fo:block font-size="11pt"
             font-family="sans-serif"
             line-height="12pt"
             text-align="start"
             start-indent="0.5cm"
            >
    <xsl:apply-templates/>
   </fo:block>
</xsl:template>

<xsl:template match ="div/content">
   <fo:block font-size="10pt"
             font-family="Courier"
             start-indent="0.5cm"
             line-height="11pt"
             text-align="start"
             wrap-option="wrap">
       Content: <xsl:value-of select="."/>
   </fo:block>
</xsl:template>

<xsl:template match ="div/properties">
   <fo:block font-size="10pt"
             font-family="Courier"
             line-height="11pt"
             text-align="start"
             start-indent="0.5cm">
      Properties:
   </fo:block>
   <fo:block space-after.optimum="3pt">
     <xsl:apply-templates/>
   </fo:block>
</xsl:template>

<xsl:template match ="properties/property">
   <fo:block font-size="9pt"
             font-family="sans-serif"
             line-height="10pt"
             text-align="start"
             start-indent="1cm">
     <xsl:value-of select="."/>
   </fo:block>
</xsl:template>


<xsl:template match ="div/property-def">
   <fo:block font-size="13pt"
            line-height="14pt"
            text-align="start"
            >
     <xsl:value-of select="."/>
   </fo:block>
</xsl:template>


<xsl:template match ="div/values">
   <fo:block font-size="11pt"
             text-align="start"
             line-height="12pt">Values: <xsl:value-of select="."/>
   </fo:block>
</xsl:template>



</xsl:stylesheet>
