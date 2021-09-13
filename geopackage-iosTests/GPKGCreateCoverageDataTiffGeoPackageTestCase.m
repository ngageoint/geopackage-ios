//
//  GPKGCreateCoverageDataTiffGeoPackageTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCreateCoverageDataTiffGeoPackageTestCase.h"
#import "GPKGGeoPackageManager.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGTestConstants.h"
#import "GPKGTestUtils.h"
#import "PROJProjectionConstants.h"
#import "GPKGCoverageDataTiff.h"
#import "GPKGGeoPackageGeometryDataUtils.h"
#import "GPKGUtils.h"

@implementation GPKGCreateCoverageDataTiffGeoPackageTestCase


-(BOOL) shouldAllowNils{
    return YES;
}

-(GPKGGeoPackage *) createGeoPackage{
    
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory manager];
    
    // Delete
    [manager delete:GPKG_TEST_CREATE_COVERAGE_DATA_DB_NAME];
    
    // Create
    [manager create:GPKG_TEST_CREATE_COVERAGE_DATA_DB_NAME];
    
    // Open
    GPKGGeoPackage * geoPackage = [manager open:GPKG_TEST_CREATE_COVERAGE_DATA_DB_NAME];
    [manager close];
    if(geoPackage == nil){
        [NSException raise:@"Failed to Open" format:@"Failed to open database"];
    }
    
    double minLongitude = -180.0 + (360.0 * [GPKGTestUtils randomDouble]);
    double maxLongitude = minLongitude + ((180.0 - minLongitude) * [GPKGTestUtils randomDouble]);
    double minLatitude = PROJ_WEB_MERCATOR_MIN_LAT_RANGE + ((PROJ_WEB_MERCATOR_MAX_LAT_RANGE - PROJ_WEB_MERCATOR_MIN_LAT_RANGE) * [GPKGTestUtils randomDouble]);
    double maxLatitude = minLatitude + ((PROJ_WEB_MERCATOR_MAX_LAT_RANGE - minLatitude) * [GPKGTestUtils randomDouble]);
    
    GPKGBoundingBox * bbox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
    
    GPKGSpatialReferenceSystemDao * srsDao = [geoPackage spatialReferenceSystemDao];
    GPKGSpatialReferenceSystem * contentsSrs = [srsDao srsWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM_GEOGRAPHICAL_3D]];
    GPKGSpatialReferenceSystem * tileMatrixSetSrs = [srsDao srsWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM_GEOGRAPHICAL_3D]];
    
    GPKGCoverageDataTiff *coverageData = [GPKGCoverageDataTiff createTileTableWithGeoPackage:geoPackage andMetadata:[GPKGTileTableMetadata createWithTable:GPKG_TEST_CREATE_COVERAGE_DATA_DB_TABLE_NAME andContentsBoundingBox:bbox andContentsSrsId:contentsSrs.srsId andTileBoundingBox:bbox andTileSrsId:tileMatrixSetSrs.srsId]];
    GPKGTileDao * tileDao = coverageData.tileDao;
    GPKGTileMatrixSet * tileMatrixSet = [coverageData tileMatrixSet];
    
    GPKGGriddedCoverageDao * griddedCoverageDao = [coverageData griddedCoverageDao];
    
    GPKGGriddedCoverage * griddedCoverage = [[GPKGGriddedCoverage alloc] init];
    [griddedCoverage setTileMatrixSet:tileMatrixSet];
    [griddedCoverage setGriddedCoverageDataType:GPKG_GCDT_FLOAT];
    BOOL defaultPrecision = YES;
    if([GPKGTestUtils randomDouble] < .5){
        [griddedCoverage setPrecision:[[NSDecimalNumber alloc] initWithDouble:10.0 * [GPKGTestUtils randomDouble]]];
        defaultPrecision = NO;
    }
    [griddedCoverage setDataNull:[[NSDecimalNumber alloc] initWithDouble:FLT_MAX]];
    enum GPKGGriddedCoverageEncodingType encoding;
    double randomEncoding = [GPKGTestUtils randomDouble];
    if(randomEncoding < 1.0 / 3.0){
        encoding = GPKG_GCET_AREA;
    } else if(randomEncoding < 2.0 / 3.0){
        encoding = GPKG_GCET_CENTER;
    } else{
        encoding = GPKG_GCET_CORNER;
    }
    [griddedCoverage setGridCellEncodingType:encoding];
    int griddedCoverageId = (int)[griddedCoverageDao create:griddedCoverage];
    [GPKGTestUtils assertTrue:griddedCoverageId >= 0];
    
    NSNumber * gcId = griddedCoverage.id;
    [GPKGTestUtils assertEqualIntWithValue:griddedCoverageId andValue2:[gcId intValue]];
    griddedCoverage = (GPKGGriddedCoverage *)[griddedCoverageDao queryForIdObject:gcId];
    [GPKGTestUtils assertNotNil:griddedCoverage];
    [GPKGTestUtils assertEqualDoubleWithValue:1.0 andValue2:[griddedCoverage.scale doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.0 andValue2:[griddedCoverage.offset doubleValue]];
    
    if(defaultPrecision){
        [GPKGTestUtils assertEqualDoubleWithValue:1.0 andValue2:[griddedCoverage.precision doubleValue]];
    }else{
        [GPKGTestUtils assertTrue:[griddedCoverage.precision doubleValue] >= 0.0 && [griddedCoverage.precision doubleValue] <= 10.0];
    }
    [GPKGTestUtils assertEqualIntWithValue:encoding andValue2:[griddedCoverage gridCellEncodingType]];
    [GPKGTestUtils assertEqualWithValue:[GPKGGriddedCoverageEncodingTypes name:encoding] andValue2:griddedCoverage.gridCellEncoding];
    [GPKGTestUtils assertEqualWithValue:@"Height" andValue2:griddedCoverage.fieldName];
    [GPKGTestUtils assertEqualWithValue:@"Height" andValue2:griddedCoverage.quantityDefinition];
    
    GPKGGriddedTile * commonGriddedTile = [[GPKGGriddedTile alloc] init];
    GPKGTileMatrixSetDao * tileMatrixSetDao = [geoPackage tileMatrixSetDao];
    GPKGContents * contents = [tileMatrixSetDao contents:tileMatrixSet];
    [commonGriddedTile setContents:contents];
    
    // The min, max, mean, and sd are just for testing and have
    // no association on the test tile created
    BOOL defaultGTMin = YES;
    if([GPKGTestUtils randomDouble] <.5){
        [commonGriddedTile setMin:[[NSDecimalNumber alloc] initWithDouble:1000.0 * [GPKGTestUtils randomDouble]]];
        defaultGTMin = NO;
    }
    BOOL defaultGTMax = YES;
    if([GPKGTestUtils randomDouble] <.5){
        [commonGriddedTile setMax:[[NSDecimalNumber alloc] initWithDouble:1000.0 * [GPKGTestUtils randomDouble] + (commonGriddedTile.min == nil ? 0 : [commonGriddedTile.min doubleValue])]];
        defaultGTMax = NO;
    }
    BOOL defaultGTMean = YES;
    if([GPKGTestUtils randomDouble] <.5){
        double min = commonGriddedTile.min != nil ? [commonGriddedTile.min doubleValue] : 0;
        double max = commonGriddedTile.max != nil ? [commonGriddedTile.max doubleValue] : 2000.0;
        [commonGriddedTile setMean:[[NSDecimalNumber alloc] initWithDouble:((max - min) * [GPKGTestUtils randomDouble]) + min]];
        defaultGTMean = NO;
    }
    BOOL defaultGTStandardDeviation = YES;
    if([GPKGTestUtils randomDouble] <.5){
        double min = commonGriddedTile.min != nil ? [commonGriddedTile.min doubleValue] : 0;
        double max = commonGriddedTile.max != nil ? [commonGriddedTile.max doubleValue] : 2000.0;
        [commonGriddedTile setStandardDeviation:[[NSDecimalNumber alloc] initWithDouble:(max - min) * [GPKGTestUtils randomDouble]]];
        defaultGTStandardDeviation = NO;
    }
    
    GPKGGriddedTileDao * griddedTileDao = [coverageData griddedTileDao];
    
    int width = 1 + (int) floor(([GPKGTestUtils randomDouble] * 4.0));
    int height = 1 + (int) floor(([GPKGTestUtils randomDouble] * 4.0));
    int tileWidth = 3 + (int) floor(([GPKGTestUtils randomDouble] * 30.0));
    int tileHeight = 3 + (int) floor(([GPKGTestUtils randomDouble] * 30.0));
    int minZoomLevel = (int) floor([GPKGTestUtils randomDouble] * 22.0);
    int maxZoomLevel = minZoomLevel + (int) floor([GPKGTestUtils randomDouble] * 3.0);
    
    // Just draw one image and re-use
    coverageData = [[GPKGCoverageDataTiff alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
    NSData * imageData = [self drawTileWithCoverageData:coverageData andTileWidth:tileWidth andTileHeight:tileHeight andGriddedCoverage:griddedCoverage andGriddedTile:commonGriddedTile];
    
    GPKGTileMatrixDao * tileMatrixDao = [geoPackage tileMatrixDao];
    
    for (int zoomLevel = minZoomLevel; zoomLevel <= maxZoomLevel; zoomLevel++) {
        
        GPKGTileMatrix * tileMatrix = [[GPKGTileMatrix alloc] init];
        [tileMatrix setContents:contents];
        [tileMatrix setMatrixHeight:[NSNumber numberWithInt:height]];
        [tileMatrix setMatrixWidth:[NSNumber numberWithInt:width]];
        [tileMatrix setTileHeight:[NSNumber numberWithInt:tileHeight]];
        [tileMatrix setTileWidth:[NSNumber numberWithInt:tileWidth]];
        [tileMatrix setPixelXSizeValue:([bbox.maxLongitude doubleValue] - [bbox.minLongitude doubleValue]) / width / tileWidth];
        [tileMatrix setPixelYSizeValue:([bbox.maxLatitude doubleValue] - [bbox.minLatitude doubleValue]) / height / tileHeight];
        [tileMatrix setZoomLevel:[NSNumber numberWithInt:zoomLevel]];
        int tileMatrixId = (int)[tileMatrixDao create:tileMatrix];
        [GPKGTestUtils assertTrue:tileMatrixId >= 0];
        
        for (int row = 0; row < height; row++) {
            for (int column = 0; column < width; column++) {
                
                GPKGTileRow * tileRow = [tileDao newRow];
                [tileRow setTileColumn:column];
                [tileRow setTileRow:row];
                [tileRow setZoomLevel:zoomLevel];
                [tileRow setTileData:imageData];
                
                int tileId = (int)[tileDao create:tileRow];
                [GPKGTestUtils assertTrue:tileId > 0];
                
                GPKGGriddedTile * griddedTile = [[GPKGGriddedTile alloc] init];
                [griddedTile setContents:contents];
                [griddedTile setTableId:[NSNumber numberWithInt:tileId]];
                [griddedTile setScale:[[NSDecimalNumber alloc] initWithDouble:[commonGriddedTile scaleOrDefault]]];
                [griddedTile setOffset:[[NSDecimalNumber alloc] initWithDouble:[commonGriddedTile offsetOrDefault]]];
                [griddedTile setMin:commonGriddedTile.min];
                [griddedTile setMax:commonGriddedTile.max];
                [griddedTile setMean:commonGriddedTile.mean];
                [griddedTile setStandardDeviation:commonGriddedTile.standardDeviation];
                
                int gtCreateId = (int)[griddedTileDao create:griddedTile];
                [GPKGTestUtils assertTrue:gtCreateId >= 0];
                NSNumber * gtId = griddedTile.id;
                [GPKGTestUtils assertNotNil:gtId];
                [GPKGTestUtils assertTrue:[gtId intValue] >= 0];
                [GPKGTestUtils assertEqualIntWithValue:gtCreateId andValue2:[gtId intValue]];
                
                griddedTile = (GPKGGriddedTile *)[griddedTileDao queryForIdObject:gtId];
                [GPKGTestUtils assertNotNil:griddedTile];
                [GPKGTestUtils assertEqualDoubleWithValue:1.0 andValue2:[griddedTile.scale doubleValue]];
                [GPKGTestUtils assertEqualDoubleWithValue:0.0 andValue2:[griddedTile.offset doubleValue]];
                if(defaultGTMin){
                    [GPKGTestUtils assertNil:griddedTile.min];
                }else{
                    [GPKGTestUtils assertTrue:[griddedTile.min doubleValue] >= 0.0 && [griddedTile.min doubleValue] <= 1000.0];
                }
                if(defaultGTMax){
                    [GPKGTestUtils assertNil:griddedTile.max];
                }else{
                    [GPKGTestUtils assertTrue:[griddedTile.max doubleValue] >= 0.0 && [griddedTile.max doubleValue] <= 2000.0];
                }
                if(defaultGTMean){
                    [GPKGTestUtils assertNil:griddedTile.mean];
                }else{
                    [GPKGTestUtils assertTrue:[griddedTile.mean doubleValue] >= 0.0 && [griddedTile.mean doubleValue] <= 2000.0];
                }
                if(defaultGTStandardDeviation){
                    [GPKGTestUtils assertNil:griddedTile.standardDeviation];
                }else{
                    [GPKGTestUtils assertTrue:[griddedTile.standardDeviation doubleValue] >= 0.0 && [griddedTile.standardDeviation doubleValue] <= 2000.0];
                }
            }
            
        }
        height *= 2;
        width *= 2;
    }
    
    return geoPackage;
}

- (void)setUp {
    [super setUp];
    
    self.allowNils = [self shouldAllowNils];
}

- (void)tearDown {
    
    // Close
    if (self.geoPackage != nil) {
        [self.geoPackage close];
    }
    
    [super tearDown];
}

-(NSData *) drawTileWithCoverageData: (GPKGCoverageDataTiff *) coverageData andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight andGriddedCoverage: (GPKGGriddedCoverage *) griddedCoverage andGriddedTile : (GPKGGriddedTile *) commonGriddedTile{
    
    GPKGCoverageDataValues * values = [[GPKGCoverageDataValues alloc] init];
    values.tilePixels = [NSMutableArray arrayWithCapacity:tileHeight];
    values.coverageData = [NSMutableArray arrayWithCapacity:tileHeight];
    values.tilePixelsFlat = [NSMutableArray arrayWithCapacity:tileHeight * tileWidth];
    values.coverageDataFlat = [NSMutableArray arrayWithCapacity:tileHeight * tileWidth];
    
    GPKGGriddedTile * griddedTile = [[GPKGGriddedTile alloc] init];
    [griddedTile setScale:[[NSDecimalNumber alloc] initWithDouble:[commonGriddedTile scaleOrDefault]]];
    [griddedTile setOffset:[[NSDecimalNumber alloc] initWithDouble:[commonGriddedTile offsetOrDefault]]];
    [griddedTile setMin:commonGriddedTile.min];
    [griddedTile setMax:commonGriddedTile.max];
    [griddedTile setMean:commonGriddedTile.mean];
    [griddedTile setStandardDeviation:commonGriddedTile.standardDeviation];
    
    float minValue = 8850.0;
    float maxValue = 10994.0;
    
    // Create the image and graphics
    for (int y = 0; y < tileHeight; y++) {
        
        NSMutableArray * tilePixelsRow = [NSMutableArray arrayWithCapacity:tileWidth];
        [values.tilePixels addObject:tilePixelsRow];
        
        NSMutableArray * coverageDataRow = [NSMutableArray arrayWithCapacity:tileWidth];
        [values.coverageData addObject:coverageDataRow];
        
        for (int x = 0; x < tileWidth; x++) {
            float pixelValue;
            if (self.allowNils && [GPKGTestUtils randomDouble] < .05) {
                pixelValue = [griddedCoverage.dataNull floatValue];
            } else {
                pixelValue = (float)(([GPKGTestUtils randomDouble] * (maxValue - minValue)) + minValue);
            }
            
            NSNumber * pixelValueNumber = [[NSDecimalNumber alloc] initWithFloat:pixelValue];
            [tilePixelsRow addObject:pixelValueNumber];
            NSDecimalNumber * value = [coverageData valueWithGriddedTile:griddedTile andPixelFloatValue:pixelValue];
            [GPKGUtils addObject:value toArray:coverageDataRow];
            
            [values.tilePixelsFlat addObject:pixelValueNumber];
            [GPKGUtils addObject:value toArray:values.coverageDataFlat];
        }
    }
    
    NSData * imageData = [coverageData drawTileDataWithDoubleArrayPixelValues:values.tilePixels];
    
    //NSData * imageData2 = [coverageData drawTileDataWithGriddedTile:griddedTile andDoubleArrayValues:values.coverageData];
    //[GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:imageData andActual:imageData2];
    
    NSData * imageData3 = [coverageData drawTileDataWithPixelValues:values.tilePixelsFlat andTileWidth:tileWidth andTileHeight:tileHeight];
    [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:imageData andActual:imageData3];
    
    //NSData * imageData4 = [coverageData drawTileDataWithGriddedTile:griddedTile andValues:values.coverageDataFlat andTileWidth:tileWidth andTileHeight:tileHeight];
    //[GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:imageData andActual:imageData4];
    
    self.coverageDataValues = values;
    
    return imageData;
}

@end
