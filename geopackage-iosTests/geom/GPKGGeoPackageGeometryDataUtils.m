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

@implementation GPKGGeoPackageGeometryDataUtils

+(void) testReadWriteBytesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumnsDao * geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet * results = [geometryColumnsDao queryForAll];
        
        while([results moveToNext]){
            
            GPKGGeometryColumns * geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao getObject:results];
            
            GPKGFeatureDao * dao = [geoPackage getFeatureDaoWithGeometryColumns:geometryColumns];
            [GPKGTestUtils assertNotNil:dao];

            GPKGResultSet * featureResults = [dao queryForAll];
            
            while([featureResults moveToNext]){
                
                GPKGFeatureRow * featureRow = [dao getFeatureRow:featureResults];
                GPKGGeometryData * geometryData = [featureRow getGeometry];
                
                if(geometryData != nil){
                    
                    NSData * geometryBytes = geometryData.bytes;
                    NSData * geometryDataToBytes = [geometryData toData];
                    [self compareByteArrayWithExpected:geometryBytes andActual:geometryDataToBytes];
                    
                    GPKGGeometryData * geometryDataAfterToBytes = geometryData;
                    
                    // Re-retrieve the original geometry data
                    geometryData = [featureRow getGeometry];
                    
                    // Compare the original with the toBytes geometry data
                    [self compareGeometryDataWithExpected:geometryData andActual:geometryDataAfterToBytes];
                    
                    // Create a new geometry data from the bytes and compare
                    // with original
                    GPKGGeometryData * geometryDataFromBytes = [[GPKGGeometryData alloc] initWithData:geometryDataToBytes];
                    [self compareGeometryDataWithExpected:geometryData andActual:geometryDataFromBytes];
                    
                    // Set the geometry empty flag and verify the geometry
                    // was not written / read
                    geometryDataAfterToBytes = [featureRow getGeometry];
                    [geometryDataAfterToBytes setEmpty:true];
                    geometryDataToBytes = [geometryDataAfterToBytes toData];
                    geometryDataFromBytes = [[GPKGGeometryData alloc] initWithData:geometryDataToBytes];
                    [GPKGTestUtils assertNil:geometryDataFromBytes.geometry];
                    [self compareByteArrayWithExpected:[geometryDataAfterToBytes getHeaderData] andActual:[geometryDataFromBytes getHeaderData]];

                    // Flip the byte order and verify the header and bytes
                    // no longer matches the original, but the geometries
                    // still do
                    geometryDataAfterToBytes = [featureRow getGeometry];
                    [geometryDataAfterToBytes setByteOrder: (geometryDataAfterToBytes.byteOrder == CFByteOrderBigEndian ? CFByteOrderLittleEndian : CFByteOrderBigEndian)];
                    geometryDataToBytes = [geometryDataAfterToBytes toData];
                    geometryDataFromBytes = [[GPKGGeometryData alloc] initWithData:geometryDataToBytes];
                    [self compareGeometryDataWithExpected:geometryDataAfterToBytes andActual:geometryDataFromBytes];
                    [GPKGTestUtils assertFalse:[[geometryDataAfterToBytes getHeaderData] isEqualToData:[geometryData getHeaderData]]];
                    [GPKGTestUtils assertFalse:[[geometryDataAfterToBytes getWkbData] isEqualToData:[geometryData getWkbData]]];
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
    
    GPKGGeometryColumnsDao * geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet * results = [geometryColumnsDao queryForAll];
        
        while([results moveToNext]){
            
            GPKGGeometryColumns * geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao getObject:results];
            
            GPKGFeatureDao * dao = [geoPackage getFeatureDaoWithGeometryColumns:geometryColumns];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGResultSet * featureResults = [dao queryForAll];
            
            while([featureResults moveToNext]){
                
                GPKGFeatureRow * featureRow = [dao getFeatureRow:featureResults];
                GPKGGeometryData * geometryData = [featureRow getGeometry];
                
                if(geometryData != nil){
                    
                    SFGeometry * geometry = geometryData.geometry;
                    
                    if(geometry != nil){
                        
                        GPKGSpatialReferenceSystemDao * srsDao = [geoPackage getSpatialReferenceSystemDao];
                        NSNumber * srsId = geometryData.srsId;
                        GPKGSpatialReferenceSystem * srs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:srsId];
                        
                        SFPProjection * projection = [SFPProjectionFactory projectionWithSrs:srs];
                        int toEpsg = -1;
                        if([srs.organizationCoordsysId intValue] == PROJ_EPSG_WORLD_GEODETIC_SYSTEM){
                            toEpsg = PROJ_EPSG_WEB_MERCATOR;
                        }else{
                            toEpsg = PROJ_EPSG_WORLD_GEODETIC_SYSTEM;
                        }
                        SFPProjectionTransform * transformTo = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToEpsg:toEpsg];
                        SFPProjectionTransform * transformFrom = [[SFPProjectionTransform alloc] initWithFromProjection:transformTo.toProjection andToProjection:projection];

                        NSData * bytes = [geometryData getWkbData];
                        
                        SFGeometry * projectedGeometry = [transformTo transformWithGeometry:geometry];
                        GPKGGeometryData * projectedGeometryData = [[GPKGGeometryData alloc] initWithSrsId:[NSNumber numberWithInt:-1]];
                        [projectedGeometryData setGeometry:projectedGeometry];
                        [projectedGeometryData toData];
                        NSData * projectedBytes = [projectedGeometryData getWkbData];
                        
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
    
    // Compare geometry data attributes
    [GPKGTestUtils assertEqualBoolWithValue:expected.extended andValue2:actual.extended];
    [GPKGTestUtils assertEqualBoolWithValue:expected.empty andValue2:actual.empty];
    [GPKGTestUtils assertEqualIntWithValue:(int)expected.byteOrder andValue2:(int)actual.byteOrder];
    [GPKGTestUtils assertEqualWithValue:expected.srsId andValue2:actual.srsId];
    [self compareEnvelopesWithExpected:expected.envelope andActual:actual.envelope];
    [GPKGTestUtils assertEqualIntWithValue:expected.SFGeometryIndex andValue2:actual.SFGeometryIndex];
    
    // Compare header bytes
    [self compareByteArrayWithExpected:[expected getHeaderData] andActual:[actual getHeaderData]];
    
    // Compare geometries
    [self compareGeometriesWithExpected:expected.geometry andActual:actual.geometry];

    // Compare well-known binary geometries
    [self compareByteArrayWithExpected:[expected getWkbData] andActual:[actual getWkbData]];
    
    // Compare all bytes
    [self compareByteArrayWithExpected:expected.bytes andActual:actual.bytes];
}

+(void) compareEnvelopesWithExpected: (SFGeometryEnvelope *) expected andActual: (SFGeometryEnvelope *) actual{
 
    if(expected == nil){
        [GPKGTestUtils assertNil:actual];
    }else{
        [GPKGTestUtils assertNotNil:actual];
        
        [GPKGTestUtils assertEqualIntWithValue:[GPKGGeometryData getIndicatorWithEnvelope:expected] andValue2:[GPKGGeometryData getIndicatorWithEnvelope:actual]];
        [GPKGTestUtils assertEqualWithValue:expected.minX andValue2:actual.minX];
        [GPKGTestUtils assertEqualWithValue:expected.maxX andValue2:actual.maxX];
        [GPKGTestUtils assertEqualWithValue:expected.minY andValue2:actual.minY];
        [GPKGTestUtils assertEqualWithValue:expected.maxY andValue2:actual.maxY];
        [GPKGTestUtils assertEqualBoolWithValue:expected.hasZ andValue2:actual.hasZ];
        [GPKGTestUtils assertEqualWithValue:expected.minZ andValue2:actual.minZ];
        [GPKGTestUtils assertEqualWithValue:expected.maxZ andValue2:actual.maxZ];
        [GPKGTestUtils assertEqualBoolWithValue:expected.hasM andValue2:actual.hasM];
        [GPKGTestUtils assertEqualWithValue:expected.minM andValue2:actual.minM];
        [GPKGTestUtils assertEqualWithValue:expected.maxM andValue2:actual.maxM];
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
    [GPKGTestUtils assertEqualIntWithValue:[expected getWkbCode] andValue2:[actual getWkbCode]];
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
    [GPKGTestUtils assertEqualWithValue:[expected numPoints] andValue2:[actual numPoints]];
    for(int i = 0; i < [[expected numPoints] intValue]; i++){
        [self comparePointWithExpected:[expected.points objectAtIndex:i] andActual:[actual.points objectAtIndex:i] andDelta:delta];
    }
}

+(void) comparePolygonWithExpected: (SFPolygon *) expected andActual: (SFPolygon *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualWithValue:[expected numRings] andValue2:[actual numRings]];
    for(int i = 0; i < [[expected numRings] intValue]; i++){
        [self compareLineStringWithExpected:[expected.rings objectAtIndex:i] andActual:[actual.rings objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareMultiPointWithExpected: (SFMultiPoint *) expected andActual: (SFMultiPoint *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualWithValue:[expected numPoints] andValue2:[actual numPoints]];
    for(int i = 0; i < [[expected numPoints] intValue]; i++){
        [self comparePointWithExpected:[[expected getPoints] objectAtIndex:i] andActual:[[actual getPoints] objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareMultiLineStringWithExpected: (SFMultiLineString *) expected andActual: (SFMultiLineString *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualWithValue:[expected numLineStrings] andValue2:[actual numLineStrings]];
    for(int i = 0; i < [[expected numLineStrings] intValue]; i++){
        [self compareLineStringWithExpected:[[expected getLineStrings] objectAtIndex:i] andActual:[[actual getLineStrings] objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareMultiPolygonWithExpected: (SFMultiPolygon *) expected andActual: (SFMultiPolygon *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualWithValue:[expected numPolygons] andValue2:[actual numPolygons]];
    for(int i = 0; i < [[expected numPolygons] intValue]; i++){
        [self comparePolygonWithExpected:[[expected getPolygons] objectAtIndex:i] andActual:[[actual getPolygons] objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareGeometryCollectionWithExpected: (SFGeometryCollection *) expected andActual: (SFGeometryCollection *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualWithValue:[expected numGeometries] andValue2:[actual numGeometries]];
    for(int i = 0; i < [[expected numGeometries] intValue]; i++){
        [self compareGeometriesWithExpected:[expected.geometries objectAtIndex:i] andActual:[actual.geometries objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareCircularStringWithExpected: (SFCircularString *) expected andActual: (SFCircularString *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualWithValue:[expected numPoints] andValue2:[actual numPoints]];
    for(int i = 0; i < [[expected numPoints] intValue]; i++){
        [self comparePointWithExpected:[expected.points objectAtIndex:i] andActual:[actual.points objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareCompoundCurveWithExpected: (SFCompoundCurve *) expected andActual: (SFCompoundCurve *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualWithValue:[expected numLineStrings] andValue2:[actual numLineStrings]];
    for(int i = 0; i < [[expected numLineStrings] intValue]; i++){
        [self compareLineStringWithExpected:[expected.lineStrings objectAtIndex:i] andActual:[actual.lineStrings objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareCurvePolygonWithExpected: (SFCurvePolygon *) expected andActual: (SFCurvePolygon *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualWithValue:[expected numRings] andValue2:[actual numRings]];
    for(int i = 0; i < [[expected numRings] intValue]; i++){
        [self compareGeometriesWithExpected:[expected.rings objectAtIndex:i] andActual:[actual.rings objectAtIndex:i]];
    }
}

+(void) comparePolyhedralSurfaceWithExpected: (SFPolyhedralSurface *) expected andActual: (SFPolyhedralSurface *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualWithValue:[expected numPolygons] andValue2:[actual numPolygons]];
    for(int i = 0; i < [[expected numPolygons] intValue]; i++){
        [self compareGeometriesWithExpected:[expected.polygons objectAtIndex:i] andActual:[actual.polygons objectAtIndex:i]];
    }
}

+(void) compareTINWithExpected: (SFTIN *) expected andActual: (SFTIN *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualWithValue:[expected numPolygons] andValue2:[actual numPolygons]];
    for(int i = 0; i < [[expected numPolygons] intValue]; i++){
        [self compareGeometriesWithExpected:[expected.polygons objectAtIndex:i] andActual:[actual.polygons objectAtIndex:i]];
    }
}

+(void) compareTriangleWithExpected: (SFTriangle *) expected andActual: (SFTriangle *) actual andDelta: (double) delta{
    [self compareBaseGeometryAttributesWithExpected:expected andActual:actual];
    [GPKGTestUtils assertEqualWithValue:[expected numRings] andValue2:[actual numRings]];
    for(int i = 0; i < [[expected numRings] intValue]; i++){
        [self compareLineStringWithExpected:[expected.rings objectAtIndex:i] andActual:[actual.rings objectAtIndex:i] andDelta:delta];
    }
}

+(void) compareByteArrayWithExpected: (NSData *) expected andActual: (NSData *) actual{
    
    [GPKGTestUtils assertTrue:([expected length] == [actual length])];
    
    [GPKGTestUtils assertTrue: [expected isEqualToData:actual]];
    
}

@end
