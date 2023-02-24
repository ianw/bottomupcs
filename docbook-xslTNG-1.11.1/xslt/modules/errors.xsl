<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:dbe="http://docbook.org/ns/docbook/errors"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                default-mode="m:docbook"
                exclude-result-prefixes="db dbe f m xs"
                version="3.0">

<xsl:variable name="dbe:INVALID-INJECT" select="xs:QName('dbe:INVALID-INJECT')"/>
<xsl:variable name="dbe:INVALID-CALS" select="xs:QName('dbe:INVALID-CALS')"/>
<xsl:variable name="dbe:INVALID-AREAREFS" select="xs:QName('dbe:INVALID-AREAREFS')"/>
<xsl:variable name="dbe:INVALID-PRODUCTIONRECAP"
              select="xs:QName('dbe:INVALID-PRODUCTIONRECAP')"/>
<xsl:variable name="dbe:INVALID-CONSTRAINT"
              select="xs:QName('dbe:INVALID-CONSTRAINT')"/>
<xsl:variable name="dbe:INVALID-TEMPLATE"
              select="xs:QName('dbe:INVALID-TEMPLATE')"/>
<xsl:variable name="dbe:INTERNAL-RENUMBER-ERROR"
              select="xs:QName('dbe:INTERNAL-RENUMBER-ERROR')"/>
<xsl:variable name="dbe:INTERNAL-HIGHLIGHT-ERROR"
              select="xs:QName('dbe:INTERNAL-HIGHLIGHT-ERROR')"/>
<xsl:variable name="dbe:INVALID-NAME-STYLE"
              select="xs:QName('dbe:INVALID-NAME-STYLE')"/>
<xsl:variable name="dbe:DYNAMIC-PROFILE-SYNTAX-ERROR"
              select="xs:QName('dbe:DYNAMIC-PROFILE-SYNTAX-ERROR')"/>
<xsl:variable name="dbe:DYNAMIC-PROFILE-EVAL-ERROR"
              select="xs:QName('dbe:DYNAMIC-PROFILE-EVAL-ERROR')"/>
<xsl:variable name="dbe:INVALID-DYNAMIC-PROFILE-ERROR"
              select="xs:QName('dbe:INVALID-DYNAMIC-PROFILE-ERROR')"/>
<xsl:variable name="dbe:INVALID-TRANSFORM"
              select="xs:QName('dbe:INVALID-TRANSFORM')"/>
<xsl:variable name="dbe:INVALID-RESULTS-REQUESTED"
              select="xs:QName('dbe:INVALID-RESULTS-REQUESTED')"/>

</xsl:stylesheet>
