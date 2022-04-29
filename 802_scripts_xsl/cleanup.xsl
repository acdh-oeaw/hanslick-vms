<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:_="urn:acdh"
    exclude-result-prefixes="xs tei"
    version="3.0">
    <xsl:output method="xml" indent="no"/>
    <xsl:param name="debug">false</xsl:param>
    <xsl:strip-space elements="tei:p"/>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="_:toTEI">
        <xsl:param name="i" as="item()"/>
        <xsl:choose>
            <xsl:when test="$i instance of element()">
                <xsl:element name="{name($i)}" xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="$i/@*"/>
                    <xsl:for-each select="$i/node()">
                        <xsl:sequence select="_:toTEI(.)"/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$i instance of document-node()">
                <xsl:for-each select="$i/node()">
                    <xsl:sequence select="_:toTEI(.)"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$i"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <xsl:template match="/" mode="#default">
        <xsl:variable name="pass1" as="element()">
            <xsl:apply-templates mode="pass1"/>
        </xsl:variable>
        <xsl:variable name="p2">
            <xsl:apply-templates select="$pass1" mode="pass2"/>
        </xsl:variable>
        <xsl:apply-templates select="$pass1" mode="pass3"/>
        <xsl:if test="$debug = 'true'">
            <xsl:result-document href="cleanup.xml">
                <xsl:sequence select="$p2"/>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>
    
<xsl:template name="wrap">
    <xsl:param name="eltNames"/>
    <xsl:variable name="elt" select="substring-after($eltNames[1],'TEI ')"/>
    <xsl:variable name="wrapped" as="element()">
        <xsl:choose>
            <xsl:when test="$elt = 'q_french'">
                <q xml:lang="fr"><xsl:sequence select="."></xsl:sequence></q>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{$elt}">
                    <xsl:sequence select="."/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="count($eltNames) eq 1">
            <xsl:sequence select="$wrapped"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:for-each select="$wrapped">
                <xsl:call-template name="wrap">
                    <xsl:with-param name="eltNames" select="subsequence($eltNames,2)"/>
                    
                </xsl:call-template>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
    
    <xsl:template match="tei:note[starts-with(normalize-space(.),'&lt;ref ')]" mode="pass1">
        <xsl:variable name="parsed">
            <xsl:sequence select="_:toTEI(parse-xml-fragment(.))"/>
        </xsl:variable>
        <xsl:sequence select="$parsed"/>
        <!--<xsl:variable name="type" xmlns="">
            <xsl:analyze-string select="." regex="type=&quot;(.+?)&quot;">
                <xsl:matching-substring><type><xsl:value-of select="regex-group(1)"/></type></xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="." regex="target=&quot;(.+?)&quot;">
                        <xsl:matching-substring><target><xsl:value-of select="regex-group(1)"/></target></xsl:matching-substring>
                        <xsl:non-matching-substring/>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <ptr>
            <xsl:if test="$type/type != ''">
                <xsl:attribute name="type" select="$type/type"></xsl:attribute>
            </xsl:if>
            <xsl:if test="$type/target != ''">
                <xsl:attribute name="target" select="$type/target"></xsl:attribute>
            </xsl:if>
        </ptr>-->
    </xsl:template>
    
    <xsl:template match="tei:persName[following-sibling::*[1]/self::tei:persName[. = '']]" mode="pass1">
         <xsl:choose>
             <xsl:when test="following-sibling::*[2]/self::tei:note[starts-with(normalize-space(.), 'TEI')]">
                 <xsl:variable name="eltNames" select="tokenize(following-sibling::*[2],'\s*(,|und)\s*')"/>
                 <xsl:call-template name="wrap">
                     <xsl:with-param name="eltNames" select="$eltNames"/>
                 </xsl:call-template>
            </xsl:when>
             <xsl:otherwise>
                 <xsl:copy>
                     <xsl:copy-of select="@*"/>
                     <xsl:apply-templates/>
                 </xsl:copy>
             </xsl:otherwise>
         </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:persName[.=''][preceding-sibling::*[1]/self::tei:persName]" mode="pass1"/>
    
    <xsl:template match="tei:note[starts-with(normalize-space(.),'TEI')][preceding-sibling::*[1]/self::tei:persName[.='']][preceding-sibling::*[2]/self::tei:persName]" mode="pass1"/>
        
    <xsl:template match="tei:emph[count(node()) eq 1 and tei:persName]" mode="pass2">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:persName[parent::tei:emph][not(following-sibling::node()) and not(preceding-sibling::node())]" mode="pass2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="rendition">#i</xsl:attribute>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
   <!-- +**** -->
    
    
    
    <xsl:template match="tei:placeName[following-sibling::*[1]/self::tei:placeName[. = '']]" mode="pass1">
        <xsl:choose>
            <xsl:when test="following-sibling::*[2]/self::tei:note[starts-with(normalize-space(.), 'TEI')]">
                <xsl:variable name="eltNames" select="tokenize(following-sibling::*[2],'\s*(,|und)\s*')"/>
                <xsl:call-template name="wrap">
                    <xsl:with-param name="eltNames" select="$eltNames"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:placeName[.=''][preceding-sibling::*[1]/self::tei:placeName]" mode="pass1"/>
    
    <xsl:template match="tei:note[starts-with(normalize-space(.),'TEI')][preceding-sibling::*[1]/self::tei:placeName[.='']][preceding-sibling::*[2]/self::tei:placeName]" mode="pass1"/>
    
    <xsl:template match="tei:emph[count(node()) eq 1 and tei:placeName]" mode="pass2">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:placeName[parent::tei:emph][not(following-sibling::node()) and not(preceding-sibling::node())]" mode="pass2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="rendition">#i</xsl:attribute>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- orgName -->
    <xsl:template match="tei:orgName[following-sibling::*[1]/self::tei:orgName[. = '']]" mode="pass1">
        <xsl:choose>
            <xsl:when test="following-sibling::*[2]/self::tei:note[starts-with(normalize-space(.), 'TEI')]">
                <xsl:variable name="eltNames" select="tokenize(following-sibling::*[2],'\s*(,|und)\s*')"/>
                <xsl:call-template name="wrap">
                    <xsl:with-param name="eltNames" select="$eltNames"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:orgName[.=''][preceding-sibling::*[1]/self::tei:orgName]" mode="pass1"/>
    
    <xsl:template match="tei:note[starts-with(normalize-space(.),'TEI')][preceding-sibling::*[1]/self::tei:orgName[.='']][preceding-sibling::*[2]/self::tei:orgName]" mode="pass1"/>
    
    <xsl:template match="tei:emph[count(node()) eq 1 and tei:orgName]" mode="pass2">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:orgName[parent::tei:emph][not(following-sibling::node()) and not(preceding-sibling::node())]" mode="pass2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="rendition">#i</xsl:attribute>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:title[.=''][following-sibling::*[1]/self::tei:ref]" mode="pass2"/>
    
    <xsl:template match="tei:title[following-sibling::*[2]/self::tei:ref[. = current()]]" mode="pass2"/>
        
    <xsl:template match="tei:persName[following-sibling::node()[normalize-space(.) != ''][1]/self::tei:persName[@rendition]]" mode="p3">
        <xsl:copy>
            <xsl:copy-of select="@*"/><xsl:text> </xsl:text>
            <hi>
                <xsl:copy-of select="following-sibling::node()[normalize-space(.) != ''][1]/self::tei:persName[@rendition]/(@rendition|node())"/>
            </hi>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>