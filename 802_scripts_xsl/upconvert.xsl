<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:param name="debug">false</xsl:param>
    
    <xsl:variable name="edition" select="//tei:docEdition"/>
    <xsl:variable name="pubYear" select="//tei:docImprint/tei:date"/>
    <xsl:variable name="publisher" select="//tei:docImprint/tei:publisher"/>
    
<!--    <xsl:strip-space elements="*"/>-->
<!--    <xsl:output method="xml" indent="yes"/>    -->
    <xsl:template match="/">
        <xsl:variable name="group_cits">
            <xsl:apply-templates mode="group_cits"/>
        </xsl:variable>
        <xsl:variable name="p1">
            <xsl:apply-templates select="$group_cits" mode="p1"/>
        </xsl:variable>
        <xsl:variable name="p2">
            <xsl:apply-templates select="$p1" mode="p2"/>
        </xsl:variable>
        <xsl:variable name="p3">
            <xsl:apply-templates select="$p2" mode="p3"/>
        </xsl:variable>
        <xsl:sequence select="$p3"/>
        <xsl:if test="$debug = 'true'">
                
            <xsl:result-document href="upconvert-group_cits.xml">
                <xsl:sequence select="$group_cits"/>
            </xsl:result-document>
            <xsl:result-document href="upconvert-p1.xml">
                <xsl:sequence select="$p1"/>
            </xsl:result-document>
            <xsl:result-document href="upconvert-p2.xml">
                <xsl:sequence select="$p2"/>
            </xsl:result-document>
            <xsl:result-document href="upconvert.xml">
                <xsl:sequence select="$p3"/>
            </xsl:result-document>
                
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>        
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:teiHeader" mode="p1">
        <xsl:apply-templates select="doc('teiHeaderTemplate.xml')" mode="populateHeaderTmpl"/>
    </xsl:template>
    
    <xsl:template match="tei:sourceDesc//tei:edition" mode="populateHeaderTmpl">
        <xsl:variable name="orinals" as="item()+">
            <n n="01" en="first">erste</n>
            <n n="02" en="second">zweite</n>
            <n n="03" en="third">dritte</n>
            <n n="04" en="fourth">vierte</n>
            <n n="05" en="fifth">fünfte</n>
            <n n="06" en="sixth">sechste</n>
            <n n="07" en="seventh">siebente</n>
            <n n="08" en="eigth">achte</n>
            <n n="09" en="ninth">neunte</n>
            <n n="10" en="tenth">zehnte</n>
        </xsl:variable>
        <xsl:variable name="edNo" as="item()">
            <xsl:choose>
                <xsl:when test="exists($orinals[contains(lower-case($edition), .)])">
                    <xsl:sequence select="$orinals[contains(lower-case($edition), .)]"/>
                </xsl:when>
                <xsl:when test="not(exists($edition))">
                    <xsl:sequence select="$orinals[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <n n="xx" en="UNKNOWN">UNKNOWN</n>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <edition n="{$edNo/@n}"><xsl:value-of select="$edNo/@en"/> edition</edition>
    </xsl:template>
    
    <xsl:template match="tei:sourceDesc//tei:imprint/tei:date" mode="populateHeaderTmpl">
        <date when="{$pubYear}"><xsl:value-of select="$pubYear"/></date>
    </xsl:template>

    
    <xsl:template match="tei:sourceDesc//tei:imprint/tei:publisher" mode="populateHeaderTmpl">
        <xsl:copy><xsl:value-of select="$publisher"/></xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[count(tei:cit) gt 1]" mode="group_cits">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each-group select="node()" group-adjacent="local-name()">
                <xsl:choose>
                    <xsl:when test="every $e in current-group() satisfies $e instance of element(tei:cit)">
                        <cit><quote><xsl:sequence select="current-group()/node()"/></quote></cit>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()" mode="#current"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:ref[tei:title|tei:persName|tei:placeName]" mode="p1">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:title[parent::tei:ref]|tei:placeName[parent::tei:ref]|tei:persName[parent::tei:ref]" mode="p1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="ref" select="parent::tei:ref/@target"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:title[tei:ref]|tei:placeName[tei:ref]|tei:persName[tei:ref]" mode="p1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="ref" select="tei:ref/@target"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:p[tokenize(@rend, ' ') = ('center','bold')][matches(.,'^[IV]+\.$')]" mode="p1">
        <head><xsl:apply-templates select="@*|node()" mode="#current"/></head>
    </xsl:template>
    
    <xsl:template match="tei:div[tei:titlePart]" mode="p1">
        <titlePage>
            <docTitle>
                <xsl:apply-templates select="tei:titlePart" mode="#current"/>
            </docTitle>
            <xsl:apply-templates select="node() except tei:titlePart" mode="#current"/>
        </titlePage>
    </xsl:template>
    
    <xsl:template match="tei:titlePart" mode="p1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="if (position() eq 1) then 'main' else 'sub'"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:div[starts-with(tei:head[1],'Inhalt')]" mode="p1">
        <div type="toc"/>
    </xsl:template>
    
    <xsl:template match="tei:body" mode="p1">
        <xsl:variable name="frontDivs" select="tei:div[tei:titlePart or starts-with(tei:head[1], 'Inhalt')]"/>
        <front>
            <xsl:apply-templates select="$frontDivs" mode="#current"/>
        </front>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="* except $frontDivs" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:p[matches(.,'^\*+$')]" mode="p1">
        <milestone rendition="#asterisk" unit="section"/>
    </xsl:template>
    
    <xsl:template match="tei:pb[following-sibling::*[1]/self::tei:anchor][following-sibling::*[2]/self::tei:pb]" mode="p1">
        <pb><xsl:value-of select="following-sibling::*[2]"/></pb><xsl:sequence select="following-sibling::*[1]"></xsl:sequence>
    </xsl:template>
    
    
    
    <xsl:template match="text()[ends-with(.,'-')][following-sibling::node()[1]/self::tei:pb]" mode="p2">
        <xsl:value-of select="substring-before(.,'-')"/>
    </xsl:template>
    
    
  
    <xsl:template match="tei:pb[matches(., '^(-)?(\[([IVX]+|(\d+))\])$')]" mode="p2">
        <xsl:variable name="preceding-text" select="preceding-sibling::node()[1][self::text()]"/>
        <xsl:analyze-string select="." regex="(-)?(\[([IVX]+|(\d+))\])">
            <xsl:matching-substring>
                <xsl:if test="regex-group(1)!='' or ends-with($preceding-text,'-')">
<!--                    <pc>-</pc>-->
                </xsl:if>
                <pb n="{regex-group(2)}">
                    <xsl:if test="regex-group(1)!=''or ends-with($preceding-text,'-')">
                        <xsl:attribute name="break">no</xsl:attribute>
                    </xsl:if>
                </pb>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="*[matches(local-name(),'^q_.+$')]" mode="p1">
        <q xml:lang="{substring-after(local-name(.),'_')}"><xsl:apply-templates mode="#current"/></q>
    </xsl:template>
    
    <xsl:template match="tei:persFict" mode="p1">
        <persName xml:id="{generate-id()}" type="fictional"><xsl:apply-templates mode="#current"/></persName>
    </xsl:template>
    
    
    <xsl:template match="tei:cit[not(tei:quote)]" mode="p1">
        <xsl:copy><xsl:copy-of select="@*"/><quote><xsl:apply-templates mode="#current"></xsl:apply-templates></quote></xsl:copy>
    </xsl:template>
    <xsl:template match="tei:note[@place = 'foot'][tei:p]" mode="p1">
        <xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates select="tei:p/node()"/></xsl:copy>
    </xsl:template>
    
    <!--
    <xsl:template match="tei:cit/text()" mode="p3">
        <xsl:analyze-string select="." regex="„(.+)“">
            <xsl:matching-substring>
                <quote><xsl:value-of select="regex-group(1)"/></quote>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>-->
    
    <xsl:template match="tei:hi[@rend = 'Zitat_mit_Nachweis']" mode="p2">
        <xsl:choose>
            <xsl:when test="matches(normalize-space(.),'^„(.+)“\s*\(.+\)$')">
                <xsl:analyze-string select="." regex="„(.+)“\s\((.+)\)">
                   <xsl:matching-substring>
                       <cit>
                           <quote><xsl:value-of select="regex-group(1)"/></quote>
                           <bibl><xsl:value-of select="regex-group(2)"/></bibl>
                       </cit>
                   </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="tei:graphic[not(parent::tei:figure)]" mode="p2">
        <notatedMusic>
            <xsl:copy><xsl:apply-templates select="@*|node()" mode="#current"/></xsl:copy>
        </notatedMusic>
    </xsl:template>
    
    <xsl:template match="tei:figure" mode="p2">
        <notatedMusic>
            <xsl:apply-templates mode="#current"/>
        </notatedMusic>
    </xsl:template>
    
    <xsl:template match="tei:graphic/@height" mode="p2"/>
    <xsl:template match="tei:graphic/@width" mode="p2"/>
    <xsl:template match="tei:graphic/@url" mode="p2">
        <xsl:variable name="edNo" select="root()//tei:sourceDesc//tei:edition/@n"/>
        <xsl:attribute name="url" select="concat('assets/media/',replace(.,'media',$edNo),'.jpg')"/>
    </xsl:template>
    
    <xsl:template match="tei:anchor" mode="p1"/>
    
    <xsl:template match="tei:figure/tei:p/tei:note/tei:date" mode="p2"/>
    
    <xsl:template match="tei:figure/tei:p/tei:note" mode="p2">
        <desc><xsl:value-of select="normalize-space(.)"/></desc>
    </xsl:template>
    
    
    <xsl:template match="tei:figure/tei:p/tei:graphic/tei:desc" mode="p2"/>
        
    <xsl:template match="tei:figure/tei:p" mode="p2">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend = 'ABSATZ-ID']" mode="p2">
        <xsl:attribute name="n" select="replace(.,'[\{\}]','')"/>
    </xsl:template>
    
    <xsl:template match="tei:hi" mode="p2" priority="0">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
        
    
    
    <xsl:template match="tei:hi[@rend = ('bold','italic')]" mode="p2">
        <xsl:next-match/>
    </xsl:template>
    
    <!-- p3 cleanup -->
    <xsl:template match="*[@ref]" mode="p3">
        <xsl:variable name="ln" select="local-name()"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:sequence select="preceding-sibling::node()[1][local-name() eq $ln]/node()"/>
            <xsl:sequence select="node()"/>
            <xsl:sequence select="following-sibling::node()[1][local-name() eq $ln]/node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[preceding-sibling::node()[1][@ref]]" mode="p3">
        <xsl:variable name="ln" select="local-name(preceding-sibling::node()[1])"/>
        <xsl:choose>
            <xsl:when test="local-name() eq $ln"/>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[following-sibling::node()[1][@ref]]" mode="p3">
        <xsl:variable name="ln" select="local-name(following-sibling::node()[1])"/>
        <xsl:choose>
            <xsl:when test="local-name() eq $ln"/>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="tei:p[count(tei:pb) eq count(*) and normalize-space() = '']" mode="p3">
        <xsl:sequence select="tei:pb"/>
    </xsl:template>
    
    <xsl:template match="tei:seg" mode="p3">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    
</xsl:stylesheet>