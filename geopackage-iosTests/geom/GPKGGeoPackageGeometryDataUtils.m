//
//  GPKGGeoPackageGeometryDataUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageGeometryDataUtils.h"
#import "GPKGGeometryColumnsDao.h"
#import "WKBPoint.h"
#import "WKBLineString.h"
#import "WKBPolygon.h"
#import "WKBMultiPoint.h"
#import "WKBMultiLineString.h"
#import "WKBMultiPolygon.h"
#import "WKBGeometryCollection.h"
#import "WKBCircularString.h"
#import "WKBCompoundCurve.h"
#import "WKBCurvePolygon.h"
#import "WKBPolyhedralSurface.h"
#import "WKBTIN.h"
#import "WKBTriangle.h"

@implementation GPKGGeoPackageGeometryDataUtils

+(void) testReadWriteBytesWithTestCase: (GPKGBaseTestCase *) testCase andGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumnsDao * geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet * results = [geometryColumnsDao queryForAll];
        
        while([results moveToNext]){
            
            GPKGGeometryColumns * geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao getObject:results];
            
            GPKGFeatureDao * dao = [geoPackage getFeatureDaoWithGeometryColumns:geometryColumns];
            [testCase assertNotNil:dao];

            GPKGResultSet * featureResults = [dao queryForAll];
            
            while([featureResults moveToNext]){
                
                GPKGFeatureRow * featureRow = [dao getFeatureRow:featureResults];
                GPKGGeometryData * geometryData = [featureRow getGeometry];
                
                if(geometryData != nil){
                    
                    NSData * geometryBytes = geometryData.bytes;
                    NSData * geometryDataToBytes = [geometryData toData];
                    [self compareByteArrayWithTestCase:testCase andExpected:geometryBytes andActual:geometryDataToBytes];
                    
                    GPKGGeometryData * geometryDataAfterToBytes = geometryData;
                    
                    // Re-retrieve the original geometry data
                    geometryData = [featureRow getGeometry];
                    
                    // Compare the original with the toBytes geometry data
                    [self compareGeometryDataWithTestCase:testCase andExpected:geometryData andActual:geometryDataAfterToBytes];
                    
                    // Create a new geometry data from the bytes and compare
                    // with original
                    GPKGGeometryData * geometryDataFromBytes = [[GPKGGeometryData alloc] initWithData:geometryDataToBytes];
                    [self compareGeometryDataWithTestCase:testCase andExpected:geometryData andActual:geometryDataFromBytes];
                    
                    // Set the geometry empty flag and verify the geometry
                    // was not written / read
                    geometryDataAfterToBytes = [featureRow getGeometry];
                    [geometryDataAfterToBytes setEmpty:true];
                    geometryDataToBytes = [geometryDataAfterToBytes toData];
                    geometryDataFromBytes = [[GPKGGeometryData alloc] initWithData:geometryDataToBytes];
                    [testCase assertNil:geometryDataFromBytes.geometry];
                    [self compareByteArrayWithTestCase:testCase andExpected:[geometryDataAfterToBytes getHeaderData] andActual:[geometryDataFromBytes getHeaderData]];

                    // Flip the byte order and verify the header and bytes
                    // no longer matches the original, but the geometries
                    // still do
                    geometryDataAfterToBytes = [featureRow getGeometry];
                    [geometryDataAfterToBytes setByteOrder: (geometryDataAfterToBytes.byteOrder == CFByteOrderBigEndian ? CFByteOrderLittleEndian : CFByteOrderBigEndian)];
                    geometryDataToBytes = [geometryDataAfterToBytes toData];
                    geometryDataFromBytes = [[GPKGGeometryData alloc] initWithData:geometryDataToBytes];
                    [self compareGeometryDataWithTestCase:testCase andExpected:geometryDataAfterToBytes andActual:geometryDataFromBytes];
                    [testCase assertFalse:[[geometryDataAfterToBytes getHeaderData] isEqualToData:[geometryData getHeaderData]]];
                    [testCase assertFalse:[[geometryDataAfterToBytes getWkbData] isEqualToData:[geometryData getWkbData]]];
                    [testCase assertFalse:[geometryDataAfterToBytes.bytes isEqualToData:geometryData.bytes]];
                    [self compareGeometriesWithTestCase:testCase andExpected:geometryData.geometry andActual:geometryDataAfterToBytes.geometry];
                }
            }
            
            [featureResults close];
        }
        
        [results close];
    }
}

+(void) compareGeometryDataWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (GPKGGeometryData *) expected andActual: (GPKGGeometryData *) actual{
    
    // Compare geometry data attributes
    [testCase assertEqualBoolWithValue:expected.extended andValue2:actual.extended];
    [testCase assertEqualBoolWithValue:expected.empty andValue2:actual.empty];
    [testCase assertEqualIntWithValue:(int)expected.byteOrder andValue2:(int)actual.byteOrder];
    [testCase assertEqualWithValue:expected.srsId andValue2:actual.srsId];
    [self compareEnvelopesWithTestCase:testCase andExpected:expected.envelope andActual:actual.envelope];
    [testCase assertEqualIntWithValue:expected.wkbGeometryIndex andValue2:actual.wkbGeometryIndex];
    
    // Compare header bytes
    [self compareByteArrayWithTestCase:testCase andExpected:[expected getHeaderData] andActual:[actual getHeaderData]];
    
    // Compare geometries
    [self compareGeometriesWithTestCase:testCase andExpected:expected.geometry andActual:actual.geometry];

    // Compare well-known binary geometries
    [self compareByteArrayWithTestCase:testCase andExpected:[expected getWkbData] andActual:[actual getWkbData]];
    
    // Compare all bytes
    [self compareByteArrayWithTestCase:testCase andExpected:expected.bytes andActual:actual.bytes];
}

+(void) compareEnvelopesWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBGeometryEnvelope *) expected andActual: (WKBGeometryEnvelope *) actual{
 
    if(expected == nil){
        [testCase assertNil:actual];
    }else{
        [testCase assertNotNil:actual];
        
        [testCase assertEqualIntWithValue:[GPKGGeometryData getIndicatorWithEnvelope:expected] andValue2:[GPKGGeometryData getIndicatorWithEnvelope:actual]];
        [testCase assertEqualWithValue:expected.minX andValue2:actual.minX];
        [testCase assertEqualWithValue:expected.maxX andValue2:actual.maxX];
        [testCase assertEqualWithValue:expected.minY andValue2:actual.minY];
        [testCase assertEqualWithValue:expected.maxY andValue2:actual.maxY];
        [testCase assertEqualBoolWithValue:expected.hasZ andValue2:actual.hasZ];
        [testCase assertEqualWithValue:expected.minZ andValue2:actual.minZ];
        [testCase assertEqualWithValue:expected.maxZ andValue2:actual.maxZ];
        [testCase assertEqualBoolWithValue:expected.hasM andValue2:actual.hasM];
        [testCase assertEqualWithValue:expected.minM andValue2:actual.minM];
        [testCase assertEqualWithValue:expected.maxM andValue2:actual.maxM];
    }
    
}

+(void) compareGeometriesWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBGeometry *) expected andActual: (WKBGeometry *) actual{
    if(expected == nil){
        [testCase assertNil:actual];
    }else{
        [testCase assertNotNil:actual];
        
        enum WKBGeometryType geometryType = expected.geometryType;
        switch(geometryType){
            case WKB_GEOMETRY:
                [NSException raise:@"Unexpected Geometry Type" format:@"Unexpected Geometry Type of %@ which is abstract", [WKBGeometryTypes name:geometryType]];
            case WKB_POINT:
                [self comparePointWithTestCase:testCase andExpected:(WKBPoint *)expected andActual:(WKBPoint *)actual];
                break;
            case WKB_LINESTRING:
                [self compareLineStringWithTestCase:testCase andExpected:(WKBLineString *)expected andActual:(WKBLineString *)actual];
                break;
            case WKB_POLYGON:
                [self comparePolygonWithTestCase:testCase andExpected:(WKBPolygon *)expected andActual:(WKBPolygon *)actual];
                break;
            case WKB_MULTIPOINT:
                [self compareMultiPointWithTestCase:testCase andExpected:(WKBMultiPoint *)expected andActual:(WKBMultiPoint *)actual];
                break;
            case WKB_MULTILINESTRING:
                [self compareMultiLineStringWithTestCase:testCase andExpected:(WKBMultiLineString *)expected andActual:(WKBMultiLineString *)actual];
                break;
            case WKB_MULTIPOLYGON:
                [self compareMultiPolygonWithTestCase:testCase andExpected:(WKBMultiPolygon *)expected andActual:(WKBMultiPolygon *)actual];
                break;
            case WKB_GEOMETRYCOLLECTION:
                [self compareGeometryCollectionWithTestCase:testCase andExpected:(WKBGeometryCollection *)expected andActual:(WKBGeometryCollection *)actual];
                break;
            case WKB_CIRCULARSTRING:
                [self compareCircularStringWithTestCase:testCase andExpected:(WKBCircularString *)expected andActual:(WKBCircularString *)actual];
                break;
            case WKB_COMPOUNDCURVE:
                [self compareCompoundCurveWithTestCase:testCase andExpected:(WKBCompoundCurve *)expected andActual:(WKBCompoundCurve *)actual];
                break;
            case WKB_CURVEPOLYGON:
                [self compareCurvePolygonWithTestCase:testCase andExpected:(WKBCurvePolygon *)expected andActual:(WKBCurvePolygon *)actual];
                break;
            case WKB_MULTICURVE:
                [NSException raise:@"Unexpected Geometry Type" format:@"Unexpected Geometry Type of %@ which is abstract", [WKBGeometryTypes name:geometryType]];
                break;
            case WKB_MULTISURFACE:
                [NSException raise:@"Unexpected Geometry Type" format:@"Unexpected Geometry Type of %@ which is abstract", [WKBGeometryTypes name:geometryType]];
                break;
            case WKB_CURVE:
                [NSException raise:@"Unexpected Geometry Type" format:@"Unexpected Geometry Type of %@ which is abstract", [WKBGeometryTypes name:geometryType]];
                break;
            case WKB_SURFACE:
                [NSException raise:@"Unexpected Geometry Type" format:@"Unexpected Geometry Type of %@ which is abstract", [WKBGeometryTypes name:geometryType]];
                break;
            case WKB_POLYHEDRALSURFACE:
                [self comparePolyhedralSurfaceWithTestCase:testCase andExpected:(WKBPolyhedralSurface *)expected andActual:(WKBPolyhedralSurface *)actual];
                break;
            case WKB_TIN:
                [self compareTINWithTestCase:testCase andExpected:(WKBTIN *)expected andActual:(WKBTIN *)actual];
                break;
            case WKB_TRIANGLE:
                [self compareTriangleWithTestCase:testCase andExpected:(WKBTriangle *)expected andActual:(WKBTriangle *)actual];
                break;
            default:
                [NSException raise:@"Geometry Type Not Supported" format:@"Geometry Type not supported: %d", geometryType];
        }
    }
}

+(void) compareBaseGeometryAttributesWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBGeometry *) expected andActual: (WKBGeometry *) actual{
    [testCase assertEqualIntWithValue:expected.geometryType andValue2:actual.geometryType];
    [testCase assertEqualBoolWithValue:expected.hasZ andValue2:actual.hasZ];
    [testCase assertEqualBoolWithValue:expected.hasM andValue2:actual.hasM];
    [testCase assertEqualIntWithValue:[expected getWkbCode] andValue2:[actual getWkbCode]];
}

+(void) comparePointWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBPoint *) expected andActual: (WKBPoint *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:expected.x andValue2:actual.x];
    [testCase assertEqualWithValue:expected.y andValue2:actual.y];
    [testCase assertEqualWithValue:expected.z andValue2:actual.z];
    [testCase assertEqualWithValue:expected.m andValue2:actual.m];
}

+(void) compareLineStringWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBLineString *) expected andActual: (WKBLineString *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numPoints] andValue2:[actual numPoints]];
    for(int i = 0; i < [[expected numPoints] intValue]; i++){
        [self comparePointWithTestCase:testCase andExpected:[expected.points objectAtIndex:i] andActual:[actual.points objectAtIndex:i]];
    }
}

+(void) comparePolygonWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBPolygon *) expected andActual: (WKBPolygon *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numRings] andValue2:[actual numRings]];
    for(int i = 0; i < [[expected numRings] intValue]; i++){
        [self compareLineStringWithTestCase:testCase andExpected:[expected.rings objectAtIndex:i] andActual:[actual.rings objectAtIndex:i]];
    }
}

+(void) compareMultiPointWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBMultiPoint *) expected andActual: (WKBMultiPoint *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numPoints] andValue2:[actual numPoints]];
    for(int i = 0; i < [[expected numPoints] intValue]; i++){
        [self comparePointWithTestCase:testCase andExpected:[[expected getPoints] objectAtIndex:i] andActual:[[actual getPoints] objectAtIndex:i]];
    }
}

+(void) compareMultiLineStringWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBMultiLineString *) expected andActual: (WKBMultiLineString *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numLineStrings] andValue2:[actual numLineStrings]];
    for(int i = 0; i < [[expected numLineStrings] intValue]; i++){
        [self compareLineStringWithTestCase:testCase andExpected:[[expected getLineStrings] objectAtIndex:i] andActual:[[actual getLineStrings] objectAtIndex:i]];
    }
}

+(void) compareMultiPolygonWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBMultiPolygon *) expected andActual: (WKBMultiPolygon *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numPolygons] andValue2:[actual numPolygons]];
    for(int i = 0; i < [[expected numPolygons] intValue]; i++){
        [self comparePolygonWithTestCase:testCase andExpected:[[expected getPolygons] objectAtIndex:i] andActual:[[actual getPolygons] objectAtIndex:i]];
    }
}

+(void) compareGeometryCollectionWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBGeometryCollection *) expected andActual: (WKBGeometryCollection *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numGeometries] andValue2:[actual numGeometries]];
    for(int i = 0; i < [[expected numGeometries] intValue]; i++){
        [self compareGeometriesWithTestCase:testCase andExpected:[expected.geometries objectAtIndex:i] andActual:[actual.geometries objectAtIndex:i]];
    }
}

+(void) compareCircularStringWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBCircularString *) expected andActual: (WKBCircularString *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numPoints] andValue2:[actual numPoints]];
    for(int i = 0; i < [[expected numPoints] intValue]; i++){
        [self comparePointWithTestCase:testCase andExpected:[expected.points objectAtIndex:i] andActual:[actual.points objectAtIndex:i]];
    }
}

+(void) compareCompoundCurveWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBCompoundCurve *) expected andActual: (WKBCompoundCurve *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numLineStrings] andValue2:[actual numLineStrings]];
    for(int i = 0; i < [[expected numLineStrings] intValue]; i++){
        [self compareLineStringWithTestCase:testCase andExpected:[expected.lineStrings objectAtIndex:i] andActual:[actual.lineStrings objectAtIndex:i]];
    }
}

+(void) compareCurvePolygonWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBCurvePolygon *) expected andActual: (WKBCurvePolygon *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numRings] andValue2:[actual numRings]];
    for(int i = 0; i < [[expected numRings] intValue]; i++){
        [self compareGeometriesWithTestCase:testCase andExpected:[expected.rings objectAtIndex:i] andActual:[actual.rings objectAtIndex:i]];
    }
}

+(void) comparePolyhedralSurfaceWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBPolyhedralSurface *) expected andActual: (WKBPolyhedralSurface *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numPolygons] andValue2:[actual numPolygons]];
    for(int i = 0; i < [[expected numPolygons] intValue]; i++){
        [self compareGeometriesWithTestCase:testCase andExpected:[expected.polygons objectAtIndex:i] andActual:[actual.polygons objectAtIndex:i]];
    }
}

+(void) compareTINWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBTIN *) expected andActual: (WKBTIN *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numPolygons] andValue2:[actual numPolygons]];
    for(int i = 0; i < [[expected numPolygons] intValue]; i++){
        [self compareGeometriesWithTestCase:testCase andExpected:[expected.polygons objectAtIndex:i] andActual:[actual.polygons objectAtIndex:i]];
    }
}

+(void) compareTriangleWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (WKBTriangle *) expected andActual: (WKBTriangle *) actual{
    [self compareBaseGeometryAttributesWithTestCase:testCase andExpected:expected andActual:actual];
    [testCase assertEqualWithValue:[expected numRings] andValue2:[actual numRings]];
    for(int i = 0; i < [[expected numRings] intValue]; i++){
        [self compareLineStringWithTestCase:testCase andExpected:[expected.rings objectAtIndex:i] andActual:[actual.rings objectAtIndex:i]];
    }
}

+(void) compareByteArrayWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (NSData *) expected andActual: (NSData *) actual{
    
    [testCase assertTrue:([expected length] == [actual length])];
    
    [testCase assertTrue: [expected isEqualToData:actual]];
    
}

@end
