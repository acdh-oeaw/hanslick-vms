<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:_="urn:acdh"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:function name="_:parsePNum">
        <xsl:param name="p" as="element(tei:p)"/>
        <xsl:analyze-string select="$p" regex="^\s*\{{(.+)}}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:p[matches(.,'^\s*\{')]">
        <xsl:copy>
            <xsl:attribute name="n" select="_:parsePNum(.)"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:p[matches(.,'^\s*\{')]/text()[matches(.,'^\s*\{')]">
        <xsl:value-of select="substring-after(.,'} ')"/>
    </xsl:template>
    
    <xsl:template match="tei:persName">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>