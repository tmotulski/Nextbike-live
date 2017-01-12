<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
    <xsl:template match="markers">
        <xsl:text disable-output-escaping="yes"><![CDATA[<?xml version="1.0" encoding="UTF-8"?>]]></xsl:text>
        <places>
            <xsl:apply-templates>
                <xsl:sort select="@country_name" />
                <xsl:sort select="@city" />
                <xsl:sort select="@place" />
            </xsl:apply-templates>
        </places>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space()" />
    </xsl:template>
    <xsl:template match="country/city/place">
        <place>
            <xsl:attribute name="country">
                <xsl:value-of select="../../@country_name" />
            </xsl:attribute>
            <xsl:attribute name="country_company">
                <xsl:value-of select="../../@name" />
            </xsl:attribute>
            <xsl:attribute name="city">
                <xsl:value-of select="../@name" />
            </xsl:attribute>
            <xsl:attribute name="place">
                <xsl:value-of select="@name" />
            </xsl:attribute>
            <xsl:attribute name="lat">
                <xsl:value-of select="@lat" />
            </xsl:attribute>
            <xsl:attribute name="lng">
                <xsl:value-of select="@lng" />
            </xsl:attribute>
            <xsl:attribute name="bike_numbers">
                <xsl:value-of select="@bike_numbers" />
            </xsl:attribute>
        </place>
    </xsl:template>
</xsl:stylesheet>
