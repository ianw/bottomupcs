<?xml version="1.0" encoding="UTF-8"?>
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
<!-- $Id: atstamp.xsl 426576 2006-07-28 15:44:37Z jeremias $ -->
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>
  <!-- ========================= -->
  <!-- stamping...               -->
  <!-- ========================= -->
  <xsl:template match="flow">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      
      <!-- Stamp a big "SPECIMEN" text over the whole page using an area tree fragment inserted at the right place... -->
      <block ipd="595275" bpd="841889" is-viewport-area="true" left-position="0" top-position="0" ctm="[1.0 0.0 0.0 1.0 0.0 0.0]" positioning="fixed">
        <block ipd="595275" bpd="841889" is-reference-area="true">
          <block ipd="595275" bpd="841889">
            <lineArea ipd="595275" bpd="841889">
              <viewport ipd="595275" bpd="841889" offset="0" pos="0 0 595275 841889">
                <foreignObject ipd="0" bpd="0" ns="http://www.w3.org/2000/svg">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
                    <g transform="rotate(-50 50 50)">
                      <text x="50" y="60" style="font-size:20;fill:#dfdfdf;stroke:none;font-family:sans-serif" text-anchor="middle">SPECIMEN</text>
                    </g>
                  </svg>
                </foreignObject>
              </viewport>
            </lineArea>
          </block>
        </block>
      </block>
      
      <xsl:apply-templates select="child::*"/>
    </xsl:copy>
  </xsl:template>
  <!-- ========================= -->
  <!-- identity transformation   -->
  <!-- ========================= -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
