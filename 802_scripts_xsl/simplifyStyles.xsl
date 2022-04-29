<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    xmlns:_="urn:acdh"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:preserve-space elements="tei:titlePart tei:p"/>
    <xsl:param name="debug">false</xsl:param>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:variable name="stylesRmd" as="item()">
            <xsl:apply-templates mode="rmStyles"/>
        </xsl:variable>
        <xsl:variable name="emptyHisRmd" as="item()">
            <xsl:apply-templates select="$stylesRmd" mode="rmEmptyHi"/>
        </xsl:variable>
        <xsl:variable name="nestedStylesMerged" as="item()">
            <xsl:apply-templates select="$emptyHisRmd" mode="mergeNestedRends"/>
        </xsl:variable>
        <xsl:variable name="rend2rendition">
            <xsl:apply-templates select="$nestedStylesMerged" mode="rend2rendition"/>
        </xsl:variable>
        <xsl:sequence select="$rend2rendition"/>
        <xsl:if test="$debug = 'true'">
            <xsl:result-document href="simplifyStyles.xml">
                <xsl:sequence select="$rend2rendition"/>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="_:parseStyles">
        <xsl:param name="style" as="attribute(style)"/>
        <xsl:for-each select="tokenize(normalize-space($style),';\s*')">
            <xsl:if test="normalize-space(.) != ''">
                <xsl:sequence select="_:parseStyleToken(.)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>

    <xsl:variable name="stylesToIgnore" select="('color')" as="xs:string*"/>
    
    <xsl:function name="_:parseStyleToken">
        <xsl:param name="string" as="xs:string"/>
        <xsl:if test="not(matches($string,'\w+:\w+'))">
            <xsl:message select="$string"/>
        </xsl:if>
        <xsl:variable name="key" select="normalize-space(substring-before($string,':'))"/>
        <xsl:variable name="value" select="normalize-space(substring-after($string,':'))"/>
        <xsl:element name="{$key}"><xsl:value-of select="$value"/></xsl:element>
    </xsl:function>
    
    <xsl:function name="_:formatStyles">
        <xsl:param name="styleElements" as="element()*"/>
        <xsl:for-each select="$styleElements">
            <xsl:choose>
                <xsl:when test="local-name() = $stylesToIgnore"/>
                <xsl:when test="local-name() = 'text-align' and . = 'left'"/>
                <xsl:when test="local-name() = 'font-size'">
                    <xsl:choose>
                        <xsl:when test=". = '16pt'">large</xsl:when>
                        <xsl:when test=". = '14pt'">medium</xsl:when>
                        <xsl:when test=". = '10pt'">small</xsl:when>
                        <xsl:when test=". = '12pt'"/>
                        <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    <!--
    <xsl:template match="tei:persName" mode="mergeNestedRends">
        <rs type="person"></rs>
         et alt.
    </xsl:template>-->
    
    <xsl:template match="tei:*[@rend|@style]" mode="rmStyles">
        <xsl:variable name="rend" as="xs:string*">
            <xsl:variable name="rendTokens" select="if (contains(@rend,' ')) then tokenize(@rend,'\s+') else @rend"/>
            <xsl:for-each select="$rendTokens"> 
                <xsl:choose>
                    <xsl:when test="matches(.,'^color\(.+\)$')"/>
                    <xsl:when test="matches(.,'^background')"/>
                    <xsl:when test=". = 'HTML_Cite'"/>
                    <xsl:when test=". = 'Normal'"/>
                   <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:if test="exists(@style)">
                <xsl:sequence select="_:formatStyles(_:parseStyles(@style))"/>
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="exists($rend)">
                <xsl:copy>
                    <xsl:apply-templates select="@* except (@rend|@style)" mode="#current"/>
                    <xsl:if test="exists($rend)">
                        <xsl:attribute name="rend" select="string-join($rend,' ')"/>
                    </xsl:if>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:sequence select="@* except (@style, @rend)"/>
                    <xsl:apply-templates mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:hi[not(@rend)]" mode="rmEmptyHi">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:*[count(node()[not(matches(.,'^\s+$'))]) eq 1 and (tei:hi or tei:seg)]" mode="mergeNestedRends">
        <xsl:copy>
            <xsl:copy-of select="@* except @rend"/>
            <xsl:if test="string-join((@rend, tei:hi/@rend, tei:seg/@rend),' ') != ''">
                <xsl:attribute name="rend" select="string-join((@rend, tei:hi/@rend, tei:seg/@rend),' ')"/>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:*[count(node()[not(matches(.,'^\s+$'))]) eq 1 and (tei:hi or tei:seg)]/*[local-name() = ('hi','seg')]" mode="mergeNestedRends">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="@rend" mode="rend2rendition">
        <xsl:attribute name="rendition">
            <xsl:choose>
                <xsl:when test="contains(., ' ')">
                    <xsl:variable name="vals" as="xs:string+">
                        <xsl:for-each select="tokenize(.,'\s+')">
                            <xsl:value-of select="concat('#',.)"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="string-join($vals,' ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('#',.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
</xsl:stylesheet>