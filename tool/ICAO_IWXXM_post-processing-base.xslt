<?xml version="1.0" encoding="UTF-8"?>

<!--
	XSLT to post-process XSDs generated by EA MDG Technology for GML

	Created by B.L. Choy (blchoy.hko@gmail.com).  First created on 29 March 2016.  Last updated on 16 July 2021.

	To be installed under "Resources/Stylesheets" and activited by selecting the stylesheet in "Generate GML Application Schema" window

	Tested with EA 12.1 Build 1224
-->

<!--
	EA GML transformation issues:

	(1) For UML classes of stereotype <<codeList>>, as their XSD counterparts are solely for inclusion as XSD attributes, only the types defined are required but not the element
	(2) Missing 'use="required"' in XSD attributes whose UML counterparts has a multiplicity of [1] (i.e.mandatory)
	(3) Even though an attribute of an UML class or the target role of an association has a tagged value 'nillable="true"', this was not reflected in its XSD counterpart (see Section 8.2.3.2 of ISO 19136:2007)
	(4) Generalizatiosn to GML primitives are ignored.  This is not a bug but being able to do this is an "illegal convenience"
	(5) (Tagged value 'xsdAsAttribute="true"') The types of UML object able to be serialized as XSD attributes are somewhat limited.  Currently this is rectified by CMLClassMapping.xml
	(6) Notes to an attribute of an UML object is not copied to the corresponding XSD attribute.  This is not a GML requirement (see Section E.2.4.12 of ISO19136:2007 documentation) but essential to schema readers
	(7) xsl:namespace is not working in the stylesheet processor of EA12.1, even though it is claimed to conform to XSLT 2.0 requirements
	(8) Self associations of an UML class are not transformed to their XSD counterparts
	(9) The METCE specific serialization of <quantity> element implemented in EA covers UML classes with stereotype <<Type>> and <<DataType>> only
-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2001/XMLSchema" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes=" xs"> 

	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- Identity transform with removal of default namespace xs: -->
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2001/XMLSchema" match="xs:*">
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select='namespace::*[not(. = namespace-uri(current()))]' />
			<xsl:apply-templates select='@*|node()' />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:gml="http://www.opengis.net/gml/3.2" match="*">
		<xsl:element name="{name()}">
			<xsl:copy-of select='namespace::*[not(namespace-uri(.) = "")][not(. = "http://www.w3.org/2001/XMLSchema")]' />
			<xsl:apply-templates select='@*|node()' />
		</xsl:element>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:attribute name="{local-name()}">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="@type[substring(.,1,3)='xs:']">
		<xsl:attribute name="type">
			<xsl:value-of select="substring-after(.,'xs:')"/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="@base[substring(.,1,3)='xs:']">
		<xsl:attribute name="base">
			<xsl:value-of select="substring-after(.,'xs:')"/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="text() | processing-instruction()">
        	<xsl:copy/>
	</xsl:template>

	<!-- Add disclaimer -->
	<!-- Disabled as the text has been included in the model already -->
	<!--
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:schema/xs:annotation/xs:documentation">
		<documentation>References to WMO and ICAO Technical Regulations within this XML schema shall have no formal status and are for information purposes only. Where there are differences between the Technical Regulations and the schema, the Technical Regulations shall take precedence. Technical Regulations may impose requirements that are not described in this schema.</documentation>
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select='namespace::*[not(. = namespace-uri(current()))]' />
			<xsl:apply-templates select='@*|node()' />
		</xsl:element>
	</xsl:template>
	-->

	<!-- Remove substitutionGroup and replace extension base under AngleWithNilReason, LengthWithNilReason, DistanceWithNilReason, MeasureWithNilReason, VelocityWithNilReason and StringWithNilReason (EA GML transformation Issue 4) -->
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:element[@name='AngleWithNilReason']">
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select="@*[not(name() = 'substitutionGroup')]"/>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='AngleWithNilReasonType']/xs:complexContent">
		<xsl:element name='simpleContent' >
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='AngleWithNilReasonType']/xs:complexContent/xs:extension">
		<xsl:element name='{local-name()}' >
			<xsl:attribute name="base">
				<xsl:value-of select="'gml:AngleType'"/>
			</xsl:attribute>
			<xsl:element name="attribute">
				<xsl:attribute name="name">
					<xsl:value-of select="'nilReason'"/>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:value-of select="'gml:NilReasonType'"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:element[@name='DistanceWithNilReason']">
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select="@*[not(name() = 'substitutionGroup')]"/>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='DistanceWithNilReasonType']/xs:complexContent">
		<xsl:element name='simpleContent' >
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='DistanceWithNilReasonType']/xs:complexContent/xs:extension">
		<xsl:element name='{local-name()}' >
			<xsl:attribute name="base">
				<xsl:value-of select="'gml:LengthType'"/>
			</xsl:attribute>
			<xsl:element name="attribute">
				<xsl:attribute name="name">
					<xsl:value-of select="'nilReason'"/>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:value-of select="'gml:NilReasonType'"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:element[@name='LengthWithNilReason']">
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select="@*[not(name() = 'substitutionGroup')]"/>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='LengthWithNilReasonType']/xs:complexContent">
		<xsl:element name='simpleContent' >
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='LengthWithNilReasonType']/xs:complexContent/xs:extension">
		<xsl:element name='{local-name()}' >
			<xsl:attribute name="base">
				<xsl:value-of select="'gml:LengthType'"/>
			</xsl:attribute>
			<xsl:element name="attribute">
				<xsl:attribute name="name">
					<xsl:value-of select="'nilReason'"/>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:value-of select="'gml:NilReasonType'"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:element[@name='MeasureWithNilReason']">
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select="@*[not(name() = 'substitutionGroup')]"/>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='MeasureWithNilReasonType']/xs:complexContent">
		<xsl:element name='simpleContent' >
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='MeasureWithNilReasonType']/xs:complexContent/xs:extension">
		<xsl:element name='{local-name()}' >
			<xsl:attribute name="base">
				<xsl:value-of select="'gml:MeasureType'"/>
			</xsl:attribute>
			<xsl:element name="attribute">
				<xsl:attribute name="name">
					<xsl:value-of select="'nilReason'"/>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:value-of select="'gml:NilReasonType'"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:element[@name='VelocityWithNilReason']">
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select="@*[not(name() = 'substitutionGroup')]"/>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='VelocityWithNilReasonType']/xs:complexContent">
		<xsl:element name='simpleContent' >
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='VelocityWithNilReasonType']/xs:complexContent/xs:extension">
		<xsl:element name='{local-name()}' >
			<xsl:attribute name="base">
				<xsl:value-of select="'gml:SpeedType'"/>
			</xsl:attribute>
			<xsl:element name="attribute">
				<xsl:attribute name="name">
					<xsl:value-of select="'nilReason'"/>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:value-of select="'gml:NilReasonType'"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:element[@name='StringWithNilReason']">
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select="@*[not(name() = 'substitutionGroup')]"/>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='StringWithNilReasonType']/xs:complexContent">
		<xsl:element name='simpleContent' >
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='StringWithNilReasonType']/xs:complexContent/xs:extension">
		<xsl:element name='{local-name()}' >
			<xsl:attribute name="base">
				<xsl:value-of select="'string'"/>
			</xsl:attribute>
			<xsl:element name="attribute">
				<xsl:attribute name="name">
					<xsl:value-of select="'nilReason'"/>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:value-of select="'gml:NilReasonType'"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- Replace substitutionGroup and extension base of elements TropicalCycloneSIGMETEvolvingConditionCollection, VolcanicAshSIGMETEvolvingConditionCollection, TropicalCycloneSIGMETPositionCollection and VolcanicAshSIGMETPositionCollection -->
	<!--
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:element[@name='TropicalCycloneSIGMETEvolvingConditionCollection' or @name='VolcanicAshSIGMETEvolvingConditionCollection']">
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select="@*[not(name() = 'substitutionGroup')]"/>
			<xsl:attribute name="substitutionGroup">
				<xsl:value-of select="'iwxxm:SIGMETEvolvingConditionCollection'"/>
			</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='TropicalCycloneSIGMETEvolvingConditionCollectionType' or @name='VolcanicAshSIGMETEvolvingConditionCollectionType']/xs:complexContent/xs:extension">
		<xsl:element name='{local-name()}' >
			<xsl:attribute name="base">
				<xsl:value-of select="'iwxxm:SIGMETEvolvingConditionCollectionType'"/>
			</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:element[@name='TropicalCycloneSIGMETPositionCollection' or @name='VolcanicAshSIGMETPositionCollection']">
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select="@*[not(name() = 'substitutionGroup')]"/>
			<xsl:attribute name="substitutionGroup">
				<xsl:value-of select="'iwxxm:SIGMETPositionCollection'"/>
			</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='TropicalCycloneSIGMETPositionCollectionType' or @name='VolcanicAshSIGMETPositionCollectionType']/xs:complexContent/xs:extension">
		<xsl:element name='{local-name()}' >
			<xsl:attribute name="base">
				<xsl:value-of select="'iwxxm:SIGMETPositionCollectionType'"/>
			</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	-->

	<!-- Remove empty sequence tags under SPECIType, METARType, AerodromeSurfaceWindForecastType, LengthWithNilReason and DistanceWithNilReason.  A possible EA implementation issue -->
	<!-- Update: This is probably correct, as indicated in ISO19136 documentation
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='SPECIType']/xs:complexContent/xs:extension/xs:sequence"/>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='METARType']/xs:complexContent/xs:extension/xs:sequence"/>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='AerodromeSurfaceWindForecastType']/xs:complexContent/xs:extension/xs:sequence"/>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='DistanceWithNilReasonType']/xs:complexContent/xs:extension/xs:sequence"/>
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:complexType[@name='LengthWithNilReasonType']/xs:complexContent/xs:extension/xs:sequence"/>
	-->

	<!-- Additional imports required for common.xsd (EA will not import a schema if none of its elements/types is referenced) -->
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:schema/xs:import[1]">
		<!-- Import for localized AIXM property types to reference the AIXM schemas.  Make sure that the schema involved is common.xsd -->
		<xsl:if xmlns:xs="http://www.w3.org/2001/XMLSchema" test="../xs:element[@name='Report']">
			<xsl:element name='import' >
				<xsl:attribute name="namespace">
					<xsl:value-of select="'http://www.aixm.aero/schema/5.1.1'"/>
				</xsl:attribute>
				<xsl:attribute name="schemaLocation">
					<!-- <xsl:value-of select="'http://www.aixm.aero/schema/5.1.1_profiles/AIXM_WX/5.1.1b/AIXM_Features.xsd'"/> -->
					<xsl:value-of select="'http://www.aixm.aero/schema/5.1.1/AIXM_Features.xsd'"/>
				</xsl:attribute>
				<xsl:apply-templates />
			</xsl:element>
		</xsl:if>
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select='namespace::*[not(. = namespace-uri(current()))]' />
			<xsl:apply-templates select='@*|node()' />
		</xsl:element>
	</xsl:template>
	<!-- Not working in EA12.1
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:schema">
		<xsl:element name='{local-name()}'>
			<xsl:if xmlns:xs="http://www.w3.org/2001/XMLSchema" test="./xs:element[@name='Report']">
				<xsl:namespace name="aixm" select="'http://www.aixm.aero/schema/5.1.1'"/>
			</xsl:if>
			<xsl:copy-of select='namespace::*[not(. = namespace-uri(current()))]' />
			<xsl:apply-templates select='@*|node()' />
		</xsl:element>
	</xsl:template>
	-->

	<!-- Insert complex types to common.xsd which cannot be handled by UML -->
	<xsl:template xmlns:xs="http://www.w3.org/2001/XMLSchema" match="xs:schema/*[last()]">
		<xsl:param name="name"/>
		<xsl:param name="base"/>
		<xsl:param name="ref"/>
		<xsl:element name='{local-name()}' >
			<xsl:copy-of select='namespace::*[not(. = namespace-uri(current()))]' />
			<xsl:apply-templates select='@*|node()' />
		</xsl:element>

		<!-- Make sure that the schema involved is common.xsd -->
		<xsl:if xmlns:xs="http://www.w3.org/2001/XMLSchema" test="../xs:element[@name='Report']">

			<!-- Insert IWXXM property types to common.xsd to get around with AIXM's broken property types -->
			<xsl:call-template name="propertyType">
				<xsl:with-param name="name" select="'UnitPropertyType'"/>
				<xsl:with-param name="base" select="'aixm:AbstractAIXMFeatureType'"/>
				<xsl:with-param name="ref" select="'aixm:Unit'"/>
			</xsl:call-template>
			<xsl:call-template name="propertyType">
				<xsl:with-param name="name" select="'AirspacePropertyType'"/>
				<xsl:with-param name="base" select="'aixm:AbstractAIXMFeatureType'"/>
				<xsl:with-param name="ref" select="'aixm:Airspace'"/>
			</xsl:call-template>
			<xsl:call-template name="propertyType">
				<xsl:with-param name="name" select="'AirspaceLayerPropertyType'"/>
				<xsl:with-param name="base" select="'aixm:AbstractAIXMFeatureType'"/>
				<xsl:with-param name="ref" select="'aixm:AirspaceLayer'"/>
			</xsl:call-template>
			<xsl:call-template name="propertyType">
				<xsl:with-param name="name" select="'AirspaceVolumePropertyType'"/>
				<xsl:with-param name="base" select="'aixm:AbstractAIXMFeatureType'"/>
				<xsl:with-param name="ref" select="'aixm:AirspaceVolume'"/>
			</xsl:call-template>
			<xsl:call-template name="propertyType">
				<xsl:with-param name="name" select="'AirportHeliportPropertyType'"/>
				<xsl:with-param name="base" select="'aixm:AbstractAIXMFeatureType'"/>
				<xsl:with-param name="ref" select="'aixm:AirportHeliport'"/>
			</xsl:call-template>
			<xsl:call-template name="propertyType">
				<xsl:with-param name="name" select="'RunwayDirectionPropertyType'"/>
				<xsl:with-param name="base" select="'aixm:AbstractAIXMFeatureType'"/>
				<xsl:with-param name="ref" select="'aixm:RunwayDirection'"/>
			</xsl:call-template>

			<!-- Insert "ValDistanceVerticalType" to get around with AIXM's problematic nilReason -->
			<xsl:element name="complexType">
				<xsl:attribute name="name">
					<xsl:value-of select="'ValDistanceVerticalType'"/>
				</xsl:attribute>
				<xsl:element name="simpleContent">
					<xsl:element name="extension">
						<xsl:attribute name="base">
							<xsl:value-of select="'aixm:ValDistanceVerticalBaseType'"/>
						</xsl:attribute>
						<xsl:element name="attribute">
							<xsl:attribute name="name">
								<xsl:value-of select="'uom'"/>
							</xsl:attribute>
							<xsl:attribute name="type">
								<xsl:value-of select="'aixm:UomDistanceVerticalType'"/>
							</xsl:attribute>
						</xsl:element>
						<xsl:element name="attribute">
							<xsl:attribute name="name">
								<xsl:value-of select="'nilReason'"/>
							</xsl:attribute>
							<xsl:attribute name="type">
								<xsl:value-of select="'gml:NilReasonType'"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Insert missing AbstractTimeObjectPropertyType of GML -->
			<xsl:element name="complexType">
				<xsl:attribute name="name">
					<xsl:value-of select="'AbstractTimeObjectPropertyType'"/>
				</xsl:attribute>
				<xsl:element name="sequence">
					<xsl:attribute name="minOccurs">
						<xsl:value-of select="0"/>
					</xsl:attribute>
					<xsl:element name="element">
						<xsl:attribute name="ref">
							<xsl:value-of select="'gml:AbstractTimeObject'"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:element>
				<xsl:element name="attributeGroup">
					<xsl:attribute name="ref">
						<xsl:value-of select="'gml:AssociationAttributeGroup'"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:element>

			<!-- Insert IWXXM extention type to common.xsd to ensure that extended content always has a web accessible schema definition -->
			<xsl:element name="complexType">
				<xsl:attribute name="name">
					<xsl:value-of select="'ExtensionType'"/>
				</xsl:attribute>
				<xsl:element name="sequence">
					<xsl:element name="any">
						<xsl:attribute name="processContents">
							<xsl:value-of select="'strict'"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:element>
			</xsl:element>

		</xsl:if>
	
	</xsl:template>
	<xsl:template name="propertyType">
		<xsl:param name="name"/>
		<xsl:param name="base"/>
		<xsl:param name="ref"/>
		<xsl:element name="complexType">
			<xsl:attribute name="name">
				<xsl:value-of select="$name"/>
			</xsl:attribute>
			<!-- Extension based removed per Aaron-Choy discussion -->
			<!--
			<xsl:element name="complexContent">
				<xsl:element name="extension">
					<xsl:attribute name="base">
						<xsl:value-of select="$base"/>
					</xsl:attribute>
			-->
					<xsl:element name="sequence">
						<xsl:attribute name="minOccurs">
							<xsl:value-of select="0"/>
						</xsl:attribute>
						<xsl:element name="element">
							<xsl:attribute name="ref">
								<xsl:value-of select="$ref"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:element>
					<xsl:element name="attributeGroup">
						<xsl:attribute name="ref">
							<xsl:value-of select="'gml:AssociationAttributeGroup'"/>
						</xsl:attribute>
					</xsl:element>
					<xsl:element name="attributeGroup">
						<xsl:attribute name="ref">
							<xsl:value-of select="'gml:OwnershipAttributeGroup'"/>
						</xsl:attribute>
					</xsl:element>
			<!--
				</xsl:element>
			</xsl:element>
			-->
		</xsl:element>
	</xsl:template>

	<!-- Attributes manipulation fragment from external XSLT AttributeNotesFromXMI_IWXXM.xslt -->
	<!-- Start -->

	<!-- End -->

</xsl:stylesheet>
