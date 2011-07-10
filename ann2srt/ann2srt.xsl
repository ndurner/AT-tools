<?xml version="1.0" encoding="UTF-8"?>

<!--
  Copyright (c) 2011 Nils Durner
  
  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
  
  @brief Transforms youtube annotations (speech bubbles and notes) to the SRT format
  @example youtube-dl I28ISfxKtNM
                    wget -O I28ISfxKtNM.xml "http://www.youtube.com/api/reviews/y/read2?feat=TCS&video_id=I28ISfxKtNM"
                    xsltproc ann2srt.xsl I28ISfxKtNM.xml > I28ISfxKtNM.srt
                    vlc I28ISfxKtNM.mp4 I28ISfxKtNM.srt
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
  <xsl:output method="text" />

<xsl:template name="formatTimestamp">
  <xsl:param name="annT" />

  <xsl:variable name="msecs" select="substring-after($annT, '.')" />
  <xsl:variable name="msecs000" select="substring(concat($msecs, '000'), 1, 3)" />
  
  <xsl:value-of select="concat(substring-before($annT, '.'), ',', $msecs000)" />
 </xsl:template>

  <xsl:template match="/document/annotations">
    <xsl:for-each select="annotation">
      <xsl:sort select="segment[1]/movingRegion[1]/rectRegion[1]/@t | segment[1]/movingRegion[1]/anchoredRegion[1]/@t" />
      <xsl:sort select="segment[1]/movingRegion[1]/rectRegion[2]/@t | segment[1]/movingRegion[1]/anchoredRegion[2]/@t" />
      <xsl:call-template name="annotation" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="annotation">
    <!-- ID -->
    <xsl:value-of select="position()" />
    <xsl:text>
</xsl:text>

    <!-- Start/End time -->
    <xsl:for-each select="segment[1]/movingRegion[1]">
      <xsl:choose>
        <xsl:when test="count(rectRegion) &gt; 0">
          <xsl:call-template name="formatTimestamp">
            <xsl:with-param name="annT" select="rectRegion[1]/@t" />
          </xsl:call-template>
          
          <xsl:text> --> </xsl:text>
          
          <xsl:call-template name="formatTimestamp">
            <xsl:with-param name="annT" select="rectRegion[2]/@t" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="count(anchoredRegion) &gt; 0">
          <xsl:call-template name="formatTimestamp">
            <xsl:with-param name="annT" select="anchoredRegion[1]/@t" />
          </xsl:call-template>
          
          <xsl:text> --> </xsl:text>

          <xsl:call-template name="formatTimestamp">
            <xsl:with-param name="annT" select="anchoredRegion[2]/@t" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">neither rectRegion nor anchoredRegion found</xsl:message>
        </xsl:otherwise>
      </xsl:choose>    
         
    </xsl:for-each> 
    <xsl:text>
</xsl:text>

    <!-- Text -->
    <xsl:value-of select="TEXT" />

    <xsl:text>

</xsl:text>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:apply-templates />  
  </xsl:template>  
  
</xsl:stylesheet>
