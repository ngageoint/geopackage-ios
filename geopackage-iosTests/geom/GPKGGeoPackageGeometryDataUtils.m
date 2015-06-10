//
//  GPKGGeoPackageGeometryDataUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageGeometryDataUtils.h"
#import "GPKGGeometryColumnsDao.h"

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
                
                break;
            case WKB_LINESTRING:
                
                break;
            case WKB_POLYGON:
                
                break;
            case WKB_MULTIPOINT:
                
                break;
            case WKB_MULTILINESTRING:
                
                break;
            case WKB_MULTIPOLYGON:
                
                break;
            case WKB_GEOMETRYCOLLECTION:
                
                break;
            case WKB_CIRCULARSTRING:
                
                break;
            case WKB_COMPOUNDCURVE:
                
                break;
            case WKB_CURVEPOLYGON:
                
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
                
                break;
            case WKB_TIN:
                
                break;
            case WKB_TRIANGLE:
                
                break;
            default:
                [NSException raise:@"Geometry Type Not Supported" format:@"Geometry Type not supported: %d", geometryType];
        }
    }
}

+(void) compareByteArrayWithTestCase: (GPKGBaseTestCase *) testCase andExpected: (NSData *) expected andActual: (NSData *) actual{
    
    [testCase assertTrue:([expected length] == [actual length])];
    
    [testCase assertTrue: [expected isEqualToData:actual]];
    
}

@end
