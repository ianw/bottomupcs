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
<!-- $Id: ifstamp.xsl 830257 2009-10-27 17:37:14Z vhennebert $ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:if="http://xmlgraphics.apache.org/fop/intermediate">
  <xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>
  <!-- ========================= -->
  <!-- stamping...               -->
  <!-- ========================= -->
  <xsl:template match="if:content">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      
      <!-- Stamp a big "SPECIMEN" text over the whole page using an area tree fragment inserted at the right place... -->
      <if:g transform="translate(100000, 750000) rotate(-55)">
        <if:font family="sans-serif" style="normal" weight="400" variant="normal" size="160000"
          color="#dfdfdf"/>
        <if:text xml:space="preserve" x="0" y="0">SPECIMEN</if:text>
      </if:g>
      <!-- Note: The free transformation above will not work with AFP output. In such a case,
        using an embedded SVG graphic is better. -->
      
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
