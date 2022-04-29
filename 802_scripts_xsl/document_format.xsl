<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:respStmt[2]">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <persName xml:id="dst">Daniel Stoxreiter</persName>
        </xsl:copy>        
    </xsl:template>
    
    <xsl:template match="tei:respStmt/tei:persName">
        <xsl:variable name="forename" select="tokenize(., '\s')[1]"/>
        <xsl:variable name="lastname" select="tokenize(., '\s')[2]"/>
        <persName>
            <xsl:attribute name="xml:id">                
                <xsl:value-of select="lower-case(concat(substring($forename, 1, 1), substring($lastname, 1, 1)))"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </persName>        
    </xsl:template>
    
    <xsl:template match="tei:revisionDesc/tei:listChange">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <change when="2021-09-22" who="#dst">manual corrections to citations</change>
            <change when="2021-10-12" who="#dst">automated corrections: <ref>corrections.xsl</ref></change>
            <change when="2022-04-25" who="#dst">automated corrections: <ref>document_format.xsl</ref></change>
        </xsl:copy>        
    </xsl:template>
    
    <xsl:template match="tei:application/tei:desc/tei:list">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <item>corrections.xsl</item>
            <item>document_format.xsl</item>
        </xsl:copy>        
    </xsl:template>
    
<!--    <xsl:template match="@rendition">
        
    </xsl:template>
    
    <xsl:template match="tei:item/text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>-->
    
<!--    <xsl:template match="@xml:id">
        <xsl:attribute name="{name()}">
            <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
    </xsl:template>-->
    
</xsl:stylesheet>