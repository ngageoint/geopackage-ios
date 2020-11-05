//
//  GPKGGeoPackageGeometryDataUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageGeometryDataUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGGeometryColumnsDao.h"
#import "SFPoint.h"
#import "SFLineString.h"
#import "SFPolygon.h"
#import "SFMultiPoint.h"
#import "SFMultiLineString.h"
#import "SFMultiPolygon.h"
#import "SFGeometryCollection.h"
#import "SFCircularString.h"
#import "SFCompoundCurve.h"
#import "SFCurvePolygon.h"
#import "SFPolyhedralSurface.h"
#import "SFTIN.h"
#import "SFTriangle.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionConstants.h"
#import "SFPProjectionTransform.h"
#import "SFWBGeometryCodes.h"

@implementation GPKGGeoPackageGeometryDataUtils

+(void) testReadWriteBytesWithGeoPackage: (GPKGGeoPackage *) geoPackage andCompareGeometryBytes: (BOOL) compareGeometryBytes{
    
    GPKGGeometryColumnsDao * geometryColumnsDao = [geoPackage geometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet * results = [geometryColumnsDao queryForAll];
        
        while([results moveToNext]){
            
            GPKGGeometryColumns * geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao object:results];
            
            GPKGFeatureDao * dao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
            [GPKGTestUtils assertNotNil:dao];

            GPKGResultSet * featureResults = [dao queryForAll];
            
            while([featureResults moveToNext]){
                
                GPKGFeatureRow * featureRow = [dao featureRow:featureResults];
                GPKGGeometryData * geometryData = [featureRow geometry];
                
                if(geometryData != nil){
                    
                    NSData * geometryBytes = geometryData.bytes;
                    NSData * geometryDataToBytes = [geometryData toData];
                    [GPKGTestUtils assertEqualIntWithValue:(int)geometryBytes.length andValue2:(int)geometryDataToBytes.length];
                    if(compareGeometryBytes){
                        [self compareByteArrayWithExpected:geometryBytes andActual:geometryDataToBytes];
                    }
                    
                    GPKGGeometryData * geometryDataAfterToBytes = geometryData;
                    
                    // Re-retrieve the original geometry data
                    geometryData = [featureRow geometry];
                    
                    // Compare the original with the toBytes geometry data
                    [self compareGeometryDataWithExpected:geometryData andActual:geometryDataAfterToBytes andCompareGeometryBytes:compareGeometryBytes];
                    
                    // Create a new geometry data from the bytes and compare
                    // with original
                    GPKGGeometryData *geometryDataFromBytes = [GPKGGeometryData createWithData:geometryDataToBytes];
                    [self compareGeometryDataWithExpected:geometryData andActual:geometryDataFromBytes andCompareGeometryBytes:compareGeometryBytes];
                    
                    // Set the geometry empty flag and verify the geometry
                    // was not written / read
                    geometryDataAfterToBytes = [featureRow geometry];
                    [geometryDataAfterToBytes setEmpty:YES];
                    geometryDataToBytes = [geometryDataAfterToBytes toData];
                    geometryDataFromBytes = [GPKGGeometryData createWithData:geometryDataToBytes];
                    [GPKGTestUtils assertNil:geometryDataFromBytes.geometry];
                    [self compareByteArrayWithExpected:[geometryDataAfterToBytes headerData] andActual:[geometryDataFromBytes headerData]];

                    // Flip the byte order and verify the header and bytes
                    // no longer matches the original, but the geometries
                    // still do
                    geometryDataAfterToBytes = [featureRow geometry];
                    [geometryDataAfterToBytes setByteOrder: (geometryDataAfterToBytes.byteOrder == CFByteOrderBigEndian ? CFByteOrderLittleEndian : CFByteOrderBigEndian)];
                    geometryDataToBytes = [geometryDataAfterToBytes toData];
                    geometryDataFromBytes = [GPKGGeometryData createWithData:geometryDataToBytes];
                    [self compareGeometryDataWithExpected:geometryDataAfterToBytes andActual:geometryDataFromBytes andCompareGeometryBytes:compareGeometryBytes];
                    [GPKGTestUtils assertFalse:[[geometryDataAfterToBytes headerData] isEqualToData:[geometryData headerData]]];
                    [GPKGTestUtils assertFalse:[[geometryDataAfterToBytes wkb] isEqualToData:[geometryData wkb]]];
                    [GPKGTestUtils assertFalse:[geometryDataAfterToBytes.bytes isEqualToData:geometryData.bytes]];
                    [self compareGeometriesWithExpected:geometryData.geometry andActual:geometryDataAfterToBytes.geometry];
                }
            }
            
            [featureResults close];
        }
        
        [results close];
    }
}

+(void) testGeometryProjectionTransform: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumnsDao * geometryColumnsDao = [geoPackage geometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet * results = [geometryColumnsDao queryForAll];
        
        while([results moveToNext]){
            
            GPKGGeometryColumns * geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao object:results];
            
            GPKGFeatureDao * dao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGResultSet * featureResults = [dao queryForAll];
            
            while([featureResults moveToNext]){
                
                GPKGFeatureRow * featureRow = [dao featureRow:featureResults];
                GPKGGeometryData * geometryData = [featureRow geometry];
                
                if(geometryData != nil){
                    
                    SFGeometry * geometry = geometryData.geometry;
                    
                    if(geometry != nil){
                        
                        GPKGSpatialReferenceSystemDao * srsDao = [geoPackage spatialReferenceSystemDao];
                        NSNumber * srsId = geometryData.srsId;
                        GPKGSpatialReferenceSystem * srs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:srsId];
                        
                        SFPProjection * projection = [srs projection];
                        int toEpsg = -1;
                        if([srs.organizationCoordsysId intValue] == PROJ_EPSG_WORLD_GEODETIC_SYSTEM){
                            toEpsg = PROJ_EPSG_WEB_MERCATOR;
                        }else{
                            toEpsg = PROJ_EPSG_WORLD_GEODETIC_SYSTEM;
                        }
                        SFPProjectionTransform * transformTo = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToEpsg:toEpsg];
                        SFPProjectionTransform * transformFrom = [[SFPProjectionTransform alloc] initWithFromProjection:transformTo.toProjection andToProjection:projection];

                        NSData * bytes = [geometryData wkb];
                        
                        SFGeometry * projectedGeometry = [transformTo transformWithGeometry:geometry];
                        NSData *projectedBytes = [GPKGGeometryData wkbFromGeometry:projectedGeometry];
                        
                        if([srs.organizationCoordsysId intValue] > 0){
                            [GPKGTestUtils assertFalse:[bytes isEqualToData:projectedBytes]];
                        }
                        
                        SFGeometry * restoredGeometry = [transformFrom transformWithGeometry:projectedGeometry];
                        [self compareGeometriesWithExpected:geometry andActual:restoredGeometry andDelta:.001];
                    }
                }
            }
            
            [featureResults close];
        }
        
        [results close];
    }
}

+(void) compareGeometryDataWithExpected: (GPKGGeometryData *) expected andActual: (GPKGGeometryData *) actual{
    [self compareGeometryDataWithExpected:expected andActual:actual andCompareGeometryBytes:NO];
}

+(void) compareGeometryDataWithExpected: (GPKGGeometryData *) expected andActual: (GPKGGeometryData *) actual andCompareGeometryBytes: (BOOL) compareGeometryBytes{
    
    // Compare geometry data attributes
    [GPKGTestUtils assertEqualBoolWithValue:expected.extended andValue2:actual.extended];
    [GPKGTestUtils assertEqualBoolWithValue:expected.empty andValue2:actual.empty];
    [GPKGTestUtils assertEqualIntWithValue:(int)expected.byteOrder andValue2:(int)actual.byteOrder];
    [GPKGTestUtils assertEqualWithValue:expected.srsId andValue2:actual.srsId];
    [self compareEnvelopesWithExpected:expected.envelope andActual:actual.envelope];
    [GPKGTestUtils assertEqualIntWithValue:expected.wkbGeometryIndex andValue2:actual.wkbGeometryIndex];
    
    // Compare header bytes
    [self compareByteArrayWithExpected:[expected headerData] andActual:[actual headerData]];
    
    // Compare geometries
    [self compareGeometriesWithExpected:expected.geometry andActual:actual.geometry andDelta:.00000001];

    // Compare well-known binary geometries
    [GPKGTestUtils assertEqualIntWithValue:(int)[expected wkb].length andValue2:(int)[actual wkb].length];
    if(compareGeometryBytes){
        [self compareByteArrayWithExpected:[expected wkb] andActual:[actual wkb]];
    }
    
    // Compare all bytes
    [GPKGTestUtils assertEqualIntWithValue:(int)expected.bytes.length andValue2:(int)actual.bytes.length];
    if(compareGeometryBytes){
        [self compareByteArrayWithExpected:expected.bytes andActual:actual.bytes];
    }
}

+(void) compareEnvelopesWithExpected: (SFGeometryEnvelope *) expected andActual: (SFGeometryEnvelope *) actual{
 
    if(expected == nil){
        [GPKGTestUtils assertNil:actual];
    }else{
        [GPKGTestUtils assertNotNil:actual];
        
        [GPKGTestUtils assertEqualIntWithValue:[GPKGGeometryData indicatorWithEnvelope:expected] andValue2:[GPKGGeometryData indicatorWithEnvelope:actual]];
        [GPKGTestUtils assertEqualDecimalNumberWithValue:expected.minX andValue2:actual.minX andDelta:0.0000000000001];
        [GPKGTestUtils assertEqualDecimalNumberWithValue:expected.maxX andValue2:actual.maxX andDelta:0.0000000000001];
        [GPKGTestUtils assertEqualDecimalNumberWithValue:expected.minY andValue2:actual.minY andDelta:0.0000000000001];
        [GPKGTestUtils assertEqualDecimalNumberWithValue:expected.maxY andValue2:actual.maxY andDelta:0.0000000000001];
        [GPKGTestUtils assertEqualBoolWithValue:expected.hasZ andValue2:actual.hasZ];
        [GPKGTestUtils assertEqualDecimalNumberWithValue:expected.minZ andValue2:actual.minZ andDelta:0.0000000000001];
        [GPKGTestUtils assertEqualDecimalNumberWithValue:expected.maxZ andValue2:actual.maxZ andDelta:0.0000000000001];
        [GPKGTestUtils assertEqualBoolWithValue:expected.hasM andValue2:actual.hasM];
        [GPKGTestUtils assertEqualDecimalNumberWithValue:expected.minM andValue2:actual.minM andDelta:0.0000000000001];
        [GPKGTestUtils assertEqualDecimalNumberWithValue:expected.maxM andValue2:actual.maxM andDelta:0.0000000000001];
    }
    
}

+(void) compareGeometriesWithExpected: (SFGeometry *) expected andActual: (SFGeometry *) actual{
    [self compareGeometriesWithExpected:expected andActual:actual andDelta:0.0];
}

+(void) compareGeometriesWithExpected: (SFGeometry *) expected andActual: (SFGeometry *) actual andDelta: (double) delta{
    if(expected == nil){
        [GPKGTestUtils assertNil:actual];
    }else{
        [GPKGTestUtils assertNotNil:actual];
        
        enum SFGeometryType geometryType = expected.geometryType;
        switch(geometryType){
            case SF_GEOMETRY:
                [NSException raise:@"Unexpected Geometry Type" format:@"Unexpected Geometry Type of %@ which is abstract", [SFGeometryTypes name:geometryType]];
            case SF_POINT:
                [self comparePointWithExpected:(SFPoint *)expected andActual:(SFPoint *)actual andDelta:delta];
                break;
            case SF_LINESTRING:
                [self compareLineStringWithExpected:(SFLineString *)expected andActual:(SFLineString *)actual andDelta:delta];
                break;
            case SF_POLYGON:
                [self comparePolygonWithExpected:(SFPolygon *)expected andActual:(SFPolygon *)actual andDelta:delta];
                break;
            case SF_MULTIPOINT:
                [self compareMultiPointWithExpected:(SFMultiPoint *)expected andActual:(SFMultiPoint *)actual andDelta:delta];
                break;
            case SF_MULTILINESTRING:
                [self compareMultiLineStringWithExpected:(SFMultiLineString *)expected andActual:(SFMultiLineString *)actual andDelta:delta];
                break;
            case SF_MULTIPOLYGON:
                [self compareMultiPolygonWithExpected:(SFMultiPolygon *)expected andActual:(SFMultiPolygon *)actual andDelta:delta];
                break;
            case SF_GEOMETRYCOLLECTION:
                [self compareGeometryCollectionWithExpected:(SFGeometryCollection *)expected andActual:(SFGeometryCollection *)actual andDelta:delta];
                break;
            case SF_CIRCULARSTRING:
                [self compareCircularStringWithExpected:(SFCircularString *)expected andActual:(SFCircularString *)actual andDelta:delta];
                break;
            case SF_COMPOUNDCURVE:
                [self compareCompoundCurveWithExpected:(SFCompoundCurve *)expected andActual:(SFCompoundCurve *)actual andDelta:delta];
                break;
            case SF_CURVEPOLYGON:
                [self compareCurvePolygonWithExpected:(SFCurvePolygon *)expected andActual:(SFCurvePolygon *)actual andDelta:delta];
                break;
            case SF_MULTICURVE:
                [NSException raise:@"Unexpected Geometry Type" format:@"Unexpected Geometry Type of %@ which is abstract", [SFGeometryTypes name:geometryType]];
                break;
            case SF_MULTISURFACE:
                [NSException raise:@"Unexpected Geometry Type" format:@"Unexpected Geometry Type of %@ which is abstract", [SFGeometryTypes name:geometryType]];
                break;
            case SF_CURVE:
                [NSException raise:@"Unexpected Geometry Type" format:@"Unexpected Geometry Type of %@ which is abstract", [SFGeometryTypes name:geometryType]];
                break;
            case SF_SURFACE:
                [NSException raise:@"Unexpected Geometry Type" format:@"Unexpected Geometry Type of %@ which is abstract", [SFGeometryTypes name:geometryType]];
                break;
            case SF_POLYHEDRALSURFACE:
                [self comparePolyhedralSurfaceWithExpected:(SFPolyhedralSurface *)expected andActual:(SFPolyhedralSurface *)actual andDelta:delta];
                break;
            case SF_TIN:
                [self compareTINWithExpected:(SFTIN *)expected andActual:(SFTIN *)actual andDelta:delta];
                break;
            case SF_TRIANGLE:
                [self compareTriangleWithExpected:(SFTriangle *)expected andActual:(SFTriangle *)actual andDelta:delta];
                break;
            default:
                [NSException raise:@"Geometry Type Not Supported" format:@"Geometry Type not supported: %d", geometryType];
        }
    }
}

+(void) compareBaseGeometryAttributesWithExpected: (SFGeometry *) expected andActual: (SFGeometry *) actual{
    [GPKGTestUtils assertEqualIntWithValue:expected.geometryType andValue2:actual.geometryType];
    [GPKGTestUtils assertEqualBoolWithValue:expected.hasZ andValue2:actual.hasZ];
    [GPKGTestUtils assertEqualBoolWithValue:expected.hasM andValue2:actual.hasM];
    [GPKGTestUtils assertEqualIntWithValue:[SFWBGeometryCodes codeFromGeometry:expected] andValue2:[SFWBGeometryCodes codeFromGeometry:actual]];
}

+(void) comparePointWithExpected: (SFPoint *) expected andActual: (SFPoint *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualDoubleWithValue:[expected.x doubleValue] andValue2:[actual.x doubleValue] andDelta: delta];
    [GPKGTestUtils assertEqualDoubleWithValue:[expected.y doubleValue] andValue2:[actual.y doubleValue] andDelta: delta];
    if(expected.z == nil){
        [GPKGTestUtils assertEqualWithValue:expected.z andValue2:actual.z];
    }else{
        [GPKGTestUtils assertEqualDoubleWithValue:[expected.z doubleValue] andValue2:[actual.z doubleValue] andDelta: delta];
    }
    if(expected.m == nil){
        [GPKGTestUtils assertEqualWithValue:expected.m andValue2:actual.m];
    }else{
        [GPKGTestUtils assertEqualDoubleWithValue:[expected.m doubleValue] andValue2:[actual.m doubleValue] andDelta: delta];
    }
}

+(void) compareLineStringWithExpected: (SFLineString *) expected andActual: (SFLineString *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numPoints] andValue2:[actual numPoints]];
    for(int i = 0; i < [expected numPoints]; i++){
        [self comparePointWithExpected:[expected.points objectAtIndex:i] andActual:[actual.points objectAtIndex:i] andDelta:delta];
    }
}

+(void) comparePolygonWithExpected: (SFPolygon *) expected andActual: (SFPolygon *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numRings] andValue2:[actual numRings]];
    for(int i = 0; i < [expected numRings]; i++){
        [self compareLineStringWithExpected:[expected.lineStrings objectAtIndex:i] andActual:[actual.lineStrings objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareMultiPointWithExpected: (SFMultiPoint *) expected andActual: (SFMultiPoint *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numPoints] andValue2:[actual numPoints]];
    for(int i = 0; i < [expected numPoints]; i++){
        [self comparePointWithExpected:[[expected points] objectAtIndex:i] andActual:[[actual points] objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareMultiLineStringWithExpected: (SFMultiLineString *) expected andActual: (SFMultiLineString *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numLineStrings] andValue2:[actual numLineStrings]];
    for(int i = 0; i < [expected numLineStrings]; i++){
        [self compareLineStringWithExpected:[[expected lineStrings] objectAtIndex:i] andActual:[[actual lineStrings] objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareMultiPolygonWithExpected: (SFMultiPolygon *) expected andActual: (SFMultiPolygon *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numPolygons] andValue2:[actual numPolygons]];
    for(int i = 0; i < [expected numPolygons]; i++){
        [self comparePolygonWithExpected:[[expected polygons] objectAtIndex:i] andActual:[[actual polygons] objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareGeometryCollectionWithExpected: (SFGeometryCollection *) expected andActual: (SFGeometryCollection *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numGeometries] andValue2:[actual numGeometries]];
    for(int i = 0; i < [expected numGeometries]; i++){
        [self compareGeometriesWithExpected:[expected.geometries objectAtIndex:i] andActual:[actual.geometries objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareCircularStringWithExpected: (SFCircularString *) expected andActual: (SFCircularString *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numPoints] andValue2:[actual numPoints]];
    for(int i = 0; i < [expected numPoints]; i++){
        [self comparePointWithExpected:[expected.points objectAtIndex:i] andActual:[actual.points objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareCompoundCurveWithExpected: (SFCompoundCurve *) expected andActual: (SFCompoundCurve *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numLineStrings] andValue2:[actual numLineStrings]];
    for(int i = 0; i < [expected numLineStrings]; i++){
        [self compareLineStringWithExpected:[expected.lineStrings objectAtIndex:i] andActual:[actual.lineStrings objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareCurvePolygonWithExpected: (SFCurvePolygon *) expected andActual: (SFCurvePolygon *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numRings] andValue2:[actual numRings]];
    for(int i = 0; i < [expected numRings]; i++){
        [self compareGeometriesWithExpected:[expected.rings objectAtIndex:i] andActual:[actual.rings objectAtIndex:i] andDelta:delta];
    }
}

+(void) comparePolyhedralSurfaceWithExpected: (SFPolyhedralSurface *) expected andActual: (SFPolyhedralSurface *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numPolygons] andValue2:[actual numPolygons]];
    for(int i = 0; i < [expected numPolygons]; i++){
        [self compareGeometriesWithExpected:[expected.polygons objectAtIndex:i] andActual:[actual.polygons objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareTINWithExpected: (SFTIN *) expected andActual: (SFTIN *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numPolygons] andValue2:[actual numPolygons]];
    for(int i = 0; i < [expected numPolygons]; i++){
        [self compareGeometriesWithExpected:[expected.polygons objectAtIndex:i] andActual:[actual.polygons objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareTriangleWithExpected: (SFTriangle *) expected andActual: (SFTriangle *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualIntWithValue:[expected numRings] andValue2:[actual numRings]];
    for(int i = 0; i < [expected numRings]; i++){
        [self compareLineStringWithExpected:[expected.lineStrings objectAtIndex:i] andActual:[actual.lineStrings objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareByteArrayWithExpected: (NSData *) expected andActual: (NSData *) actual{
    
    [GPKGTestUtils assertTrue:([expected length] == [actual length])];
    
    [GPKGTestUtils assertTrue: [expected isEqualToData:actual]];
    
}

@end
