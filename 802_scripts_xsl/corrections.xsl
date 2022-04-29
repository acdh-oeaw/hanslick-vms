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

    <xsl:template match="tei:notatedMusic">        
        <xsl:choose>
            <xsl:when test="child::tei:notatedMusic">
                <xsl:for-each select="./tei:notatedMusic">
                    <notatedMusic>
                        <xsl:apply-templates/>
                        <xsl:for-each select="parent::tei:notatedMusic/child::tei:desc">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </notatedMusic>
                </xsl:for-each>                              
            </xsl:when>
        </xsl:choose>    
    </xsl:template>
    
    <xsl:template match="tei:pb[not(@*)]">
        
    </xsl:template>
    
    <xsl:template match="tei:note[@place='comment']">
        
    </xsl:template>
    
    <xsl:template match="tei:q_french">
        <q xml:lang="french">
            <xsl:apply-templates/>       
        </q>
    </xsl:template>
    
    <xsl:template match="tei:q_latin">
        <q xml:lang="latin">
            <xsl:apply-templates/>       
        </q>
    </xsl:template>
    
    <xsl:template match="tei:q_greek">
        <q xml:lang="greek">
            <xsl:apply-templates/>       
        </q>
    </xsl:template>
    
    <xsl:template match="tei:persFict">
        <persName type="fictional">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="@xml:id"/><!-- verify if xml:id is missing or not -->
            </xsl:attribute>
            <xsl:attribute name="rendition">
                <xsl:value-of select="@rendition"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </persName>      
    </xsl:template>
    
    <xsl:template match="tei:bibl">
        <xsl:choose>
            <xsl:when test="ancestor::tei:body">
                <bibl>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="generate-id()"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </bibl>
            </xsl:when>
            <xsl:otherwise>
                <bibl>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </bibl>
            </xsl:otherwise>
        </xsl:choose>
            
    </xsl:template>
    
    <xsl:template match="tei:placeName">
        <xsl:choose>
            <xsl:when test="ancestor::tei:body">
                <placeName>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="generate-id()"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </placeName>
            </xsl:when>
            <xsl:otherwise>
                <placeName>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </placeName>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:orgName">
        <xsl:choose>
            <xsl:when test="ancestor::tei:body">
                <orgName>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="generate-id()"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </orgName>
            </xsl:when>
            <xsl:otherwise>
                <orgName>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </orgName>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>