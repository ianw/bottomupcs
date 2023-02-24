<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db f m t v xs"
                version="3.0">

<xsl:template match="db:note|db:tip|db:important|db:caution|db:warning|db:danger">
  <div>
    <xsl:apply-templates select="." mode="m:attributes"/>
    <div>
      <div class="icon">
        <xsl:apply-templates
            select="$v:admonition-icons/*[node-name(.) = node-name(current())]/node()"/>
      </div>
      <div class="body">
        <xsl:apply-templates select="." mode="m:generate-titlepage"/>
        <div>
          <xsl:apply-templates/>
        </div>
      </div>
    </div>
  </div>
</xsl:template>

</xsl:stylesheet>
