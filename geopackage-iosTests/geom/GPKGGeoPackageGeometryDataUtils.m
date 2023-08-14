//
//  GPKGGeoPackageGeometryDataUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageGeometryDataUtils.h"
#import "GPKGTestUtils.h"
#import "PROJProjectionConstants.h"
#import "SFWBGeometryCodes.h"
#import "SFWBGeometryWriter.h"
#import "SFWBGeometryReader.h"

@implementation GPKGGeoPackageGeometryDataUtils

static NSString *TABLE_NAME = @"features";
static NSString *COLUMN_NAME = @"geom";

+(void) testReadWriteBytesWithGeoPackage: (GPKGGeoPackage *) geoPackage andCompareGeometryBytes: (BOOL) compareGeometryBytes{
    
    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage geometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet *results = [geometryColumnsDao queryForAll];
        
        while([results moveToNext]){
            
            GPKGGeometryColumns *geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao object:results];
            
            GPKGFeatureDao *dao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
            [GPKGTestUtils assertNotNil:dao];

            GPKGResultSet *featureResults = [dao queryForAll];
            
            while([featureResults moveToNext]){
                
                GPKGFeatureRow *featureRow = [dao row:featureResults];
                GPKGGeometryData *geometryData = [featureRow geometry];
                
                if(geometryData != nil){
                    
                    NSData *geometryDataToBytes = [geometryData toData];
                    [GPKGTestUtils assertEqualIntWithValue:(int)[geometryData data].length andValue2:(int)geometryDataToBytes.length];
                    if(compareGeometryBytes){
                        [self compareByteArrayWithExpected:[geometryData data] andActual:geometryDataToBytes];
                    }
                    
                    GPKGGeometryData *geometryDataAfterToBytes = geometryData;
                    
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
                    [GPKGTestUtils assertFalse:[[geometryDataAfterToBytes data] isEqualToData:[geometryData data]]];
                    [self compareGeometriesWithExpected:geometryData.geometry andActual:geometryDataAfterToBytes.geometry];
                }
            }
            
            [featureResults close];
        }
        
        [results close];
    }
}

+(void) testGeometryProjectionTransform: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage geometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet *results = [geometryColumnsDao queryForAll];
        
        while([results moveToNext]){
            
            GPKGGeometryColumns *geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao object:results];
            
            GPKGFeatureDao *dao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGResultSet *featureResults = [dao queryForAll];
            
            while([featureResults moveToNext]){
                
                GPKGFeatureRow *featureRow = [dao row:featureResults];
                GPKGGeometryData *geometryData = [featureRow geometry];
                
                if(geometryData != nil){
                    
                    SFGeometry *geometry = geometryData.geometry;
                    
                    if(geometry != nil){
                        
                        GPKGSpatialReferenceSystemDao *srsDao = [geoPackage spatialReferenceSystemDao];
                        NSNumber *srsId = geometryData.srsId;
                        GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:srsId];
                        
                        PROJProjection *projection = [srs projection];
                        int toEpsg = -1;
                        if([srs.organizationCoordsysId intValue] == PROJ_EPSG_WORLD_GEODETIC_SYSTEM){
                            toEpsg = PROJ_EPSG_WEB_MERCATOR;
                        }else{
                            toEpsg = PROJ_EPSG_WORLD_GEODETIC_SYSTEM;
                        }
                        SFPGeometryTransform *transformTo = [SFPGeometryTransform transformFromProjection:projection andToEpsg:toEpsg];
                        SFPGeometryTransform *transformFrom = [SFPGeometryTransform transformFromProjection:transformTo.toProjection andToProjection:projection];

                        NSData *bytes = [geometryData wkb];
                        
                        SFGeometry *projectedGeometry = [transformTo transformGeometry:geometry];
                        NSData *projectedBytes = [GPKGGeometryData wkbFromGeometry:projectedGeometry];
                        
                        if([srs.organizationCoordsysId intValue] > 0){
                            [GPKGTestUtils assertFalse:[bytes isEqualToData:projectedBytes]];
                        }
                        
                        SFGeometry *restoredGeometry = [transformFrom transformGeometry:projectedGeometry];
                        [self compareGeometriesWithExpected:geometry andActual:restoredGeometry andDelta:.001];
                        
                        [transformTo destroy];
                        [transformFrom destroy];
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
    
    SFGeometry *expectedGeometry = expected.geometry;
    SFGeometry *actualGeometry = actual.geometry;
    
    NSData *expectedWKB = [expected wkb];
    NSData *actualWKB = [actual wkb];
    
    NSData *expectedData = [expected data];
    NSData *actualData = [actual data];
    
    if(expectedGeometry != nil && actualGeometry != nil && expectedGeometry.geometryType == SF_MULTILINESTRING){
        if(!([actualGeometry isKindOfClass:[SFMultiLineString class]])){
            SFGeometryCollection *geomCollection = (SFGeometryCollection *) actualGeometry;
            SFMultiLineString *multiLineString = [SFMultiLineString multiLineString];
            [multiLineString addGeometries:geomCollection.geometries];
            actualGeometry = multiLineString;
            int wkbLocation;
            int dataLocation;
            if(actual.byteOrder == CFByteOrderBigEndian){
                wkbLocation = 4;
                dataLocation = 12;
            }else{
                wkbLocation = 1;
                dataLocation = 9;
            }
            int code = [SFWBGeometryCodes codeFromGeometryType:SF_MULTICURVE];
            NSMutableData *actualWKBMutable = [[NSMutableData alloc] initWithData:actualWKB];
            NSMutableData *actualDataMutable = [[NSMutableData alloc] initWithData:actualData];
            [actualWKBMutable replaceBytesInRange:NSMakeRange(wkbLocation, 1) withBytes:(char*) &code];
            [actualDataMutable replaceBytesInRange:NSMakeRange(dataLocation, 1) withBytes:(char*) &code];
            actualWKB = actualWKBMutable;
            actualData = actualDataMutable;
        }
    }
    
    // Compare geometries
    [self compareGeometriesWithExpected:expectedGeometry andActual:actualGeometry andDelta:.00000001];

    // Compare well-known binary geometries
    [GPKGTestUtils assertEqualIntWithValue:(int)expectedWKB.length andValue2:(int)actualWKB.length];
    if(compareGeometryBytes){
        [self compareByteArrayWithExpected:expectedWKB andActual:actualWKB];
    }
    
    // Compare all bytes
    [GPKGTestUtils assertEqualIntWithValue:(int)expectedData.length andValue2:(int)actualData.length];
    if(compareGeometryBytes){
        [self compareByteArrayWithExpected:expectedData andActual:actualData];
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

+(void) testInsertGeometryBytesWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    int geometryCount = 100;
    int commitChunk = 10;

    NSMutableArray<NSData *> *geometries = [NSMutableArray array];

    for (int i = 0; i < geometryCount; i++) {
        [geometries addObject:[SFWBGeometryWriter writeGeometry:[GPKGTestUtils createPointWithHasZ:NO andHasM:NO]]];
    }

    GPKGFeatureDao *dao = [self createFeatureTableWithGeoPackage:geoPackage];

    [dao beginTransaction];
    
    @try {

        for (int count = 0; count < geometries.count; count++) {

            NSData *geometry = [geometries objectAtIndex:count];

            GPKGFeatureRow *row = [dao newRow];

            GPKGGeometryData *geometryData = [GPKGGeometryData create];
            [geometryData setGeometryData:geometry];

            [row setGeometry:geometryData];

            [dao insert:row];

            if (count % commitChunk == 0) {
                [dao commitTransaction];
                [dao beginTransaction];
            }
        }

        [dao commitTransaction];
    } @catch (NSException *exception) {
        [dao rollbackTransaction];
        @throw exception;
    }

    [GPKGTestUtils assertEqualIntWithValue:geometryCount andValue2:[dao count]];

    int count = 0;
    
    GPKGRowResultSet *features = [dao results:[dao query]];
    @try {
        for(GPKGFeatureRow *row in features){
            GPKGGeometryData *geometryData = [row geometry];
            NSData *geometryBytes = [geometries objectAtIndex:count++];
            SFGeometry *geometry = [SFWBGeometryReader readGeometryWithData:geometryBytes];
            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:[SFWBGeometryWriter writeGeometry:geometry] andActual:[geometryData wkb]];
            [GPKGTestUtils assertEqualWithValue:geometry andValue2:geometryData.geometry];
        }
    } @finally {
        [features close];
    }

}

+(void) testInsertHeaderBytesWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    int geometryCount = 100;
    int commitChunk = 7;

    NSMutableArray<SFGeometry *> *geometries = [NSMutableArray array];

    for (int i = 0; i < geometryCount; i++) {
        [geometries addObject:[GPKGTestUtils createLineStringWithHasZ:NO andHasM:NO andRing:NO]];
    }

    GPKGGeometryData *geomData = [GPKGGeometryData createWithSrsId:[NSNumber numberWithInt:1234]];
    [geomData setByteOrder:CFByteOrderBigEndian];
    [geomData setEmpty:NO];
    [geomData setExtended:NO];
    
    NSData *header = [geomData headerData];
    
    GPKGFeatureDao *dao = [self createFeatureTableWithGeoPackage:geoPackage];

    [dao beginTransaction];
    
    @try {

        for (int count = 0; count < geometries.count; count++) {

            SFGeometry *geometry = [geometries objectAtIndex:count];

            GPKGFeatureRow *row = [dao newRow];

            GPKGGeometryData *geometryData = [GPKGGeometryData createWithGeometry:geometry];
            [geometryData setHeaderData:header];

            [row setGeometry:geometryData];

            [dao insert:row];

            if (count % commitChunk == 0) {
                [dao commitTransaction];
                [dao beginTransaction];
            }
        }

        [dao commitTransaction];
    } @catch (NSException *exception) {
        [dao rollbackTransaction];
        @throw exception;
    }

    [GPKGTestUtils assertEqualIntWithValue:geometryCount andValue2:[dao count]];

    int count = 0;
    
    GPKGRowResultSet *features = [dao results:[dao query]];
    @try {
        for(GPKGFeatureRow *row in features){
            GPKGGeometryData *geometryData = [row geometry];
            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:header andActual:[geometryData headerData]];
            SFGeometry *geometry = [SFWBGeometryReader readGeometryWithData:[SFWBGeometryWriter writeGeometry:[geometries objectAtIndex:count++]]];
            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:[SFWBGeometryWriter writeGeometry:geometry] andActual:[geometryData wkb]];
            [GPKGTestUtils assertEqualWithValue:geometry andValue2:geometryData.geometry];
        }
    } @finally {
        [features close];
    }

}

+(void) testInsertHeaderAndGeometryBytesWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    int geometryCount = 100;
    int commitChunk = 13;

    NSMutableArray<NSData *> *geometries = [NSMutableArray array];

    for (int i = 0; i < geometryCount; i++) {
        [geometries addObject:[SFWBGeometryWriter writeGeometry:[GPKGTestUtils createPolygonWithHasZ:NO andHasM:NO]]];
    }

    GPKGGeometryData *geomData = [GPKGGeometryData createWithSrsId:[NSNumber numberWithInt:1234]];
    [geomData setByteOrder:CFByteOrderBigEndian];
    [geomData setEmpty:NO];
    [geomData setExtended:NO];
    
    NSData *header = [geomData headerData];
    
    GPKGFeatureDao *dao = [self createFeatureTableWithGeoPackage:geoPackage];

    [dao beginTransaction];
    
    @try {

        for (int count = 0; count < geometries.count; count++) {

            NSData *geometry = [geometries objectAtIndex:count];

            GPKGFeatureRow *row = [dao newRow];

            GPKGGeometryData *geometryData = [GPKGGeometryData create];
            [geometryData setHeaderData:header];
            [geometryData setGeometryData:geometry];

            [row setGeometry:geometryData];

            [dao insert:row];

            if (count % commitChunk == 0) {
                [dao commitTransaction];
                [dao beginTransaction];
            }
        }

        [dao commitTransaction];
    } @catch (NSException *exception) {
        [dao rollbackTransaction];
        @throw exception;
    }

    [GPKGTestUtils assertEqualIntWithValue:geometryCount andValue2:[dao count]];

    int count = 0;
    
    GPKGRowResultSet *features = [dao results:[dao query]];
    @try {
        for(GPKGFeatureRow *row in features){
            GPKGGeometryData *geometryData = [row geometry];
            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:header andActual:[geometryData headerData]];
            NSData *geometryBytes = [geometries objectAtIndex:count++];
            SFGeometry *geometry = [SFWBGeometryReader readGeometryWithData:geometryBytes];
            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:[SFWBGeometryWriter writeGeometry:geometry] andActual:[geometryData wkb]];
            [GPKGTestUtils assertEqualWithValue:geometry andValue2:geometryData.geometry];
        }
    } @finally {
        [features close];
    }

}

+(void) testInsertBytesWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    int geometryCount = 100;
    int commitChunk = 15;

    NSMutableArray<NSData *> *geometries = [NSMutableArray array];

    for (int i = 0; i < geometryCount; i++) {
        [geometries addObject:[[GPKGGeometryData createWithGeometry:[GPKGTestUtils createPolygonWithHasZ:NO andHasM:NO]] toData]];
    }
    
    GPKGFeatureDao *dao = [self createFeatureTableWithGeoPackage:geoPackage];

    [dao beginTransaction];
    
    @try {

        for (int count = 0; count < geometries.count; count++) {

            NSData *geometry = [geometries objectAtIndex:count];

            GPKGFeatureRow *row = [dao newRow];

            GPKGGeometryData *geometryData = [GPKGGeometryData create];
            [geometryData setData:geometry];

            [row setGeometry:geometryData];

            [dao insert:row];

            if (count % commitChunk == 0) {
                [dao commitTransaction];
                [dao beginTransaction];
            }
        }

        [dao commitTransaction];
    } @catch (NSException *exception) {
        [dao rollbackTransaction];
        @throw exception;
    }

    [GPKGTestUtils assertEqualIntWithValue:geometryCount andValue2:[dao count]];

    int count = 0;
    
    GPKGRowResultSet *features = [dao results:[dao query]];
    @try {
        for(GPKGFeatureRow *row in features){
            GPKGGeometryData *geometryData = [row geometry];
            GPKGGeometryData *geometryData2 = [GPKGGeometryData createWithData:[geometries objectAtIndex:count++]];
            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:[geometryData2 data] andActual:[geometryData data]];
            [GPKGTestUtils assertEqualWithValue:geometryData2.geometry andValue2:geometryData.geometry];
        }
    } @finally {
        [features close];
    }

}

+(GPKGFeatureDao *) createFeatureTableWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGSpatialReferenceSystem *srs = [[geoPackage spatialReferenceSystemDao] srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:TABLE_NAME];
    [geometryColumns setColumnName:COLUMN_NAME];
    [geometryColumns setGeometryType:SF_POLYGON];
    [geometryColumns setZ:[NSNumber numberWithInt:0]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrs:srs];

    GPKGFeatureTable *table = [geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andBoundingBox:[GPKGBoundingBox worldWGS84]]];
    
    return [geoPackage featureDaoWithTable:table];
}

@end
