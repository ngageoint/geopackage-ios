//
//  GPKGCreateElevationTilesGeoPackageTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCreateElevationTilesGeoPackageTestCase.h"
#import "GPKGGeoPackageManager.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGTestConstants.h"
#import "GPKGTestUtils.h"
#import "GPKGProjectionConstants.h"
#import "GPKGElevationTilesPng.h"

@implementation GPKGCreateElevationTilesGeoPackageTestCase

-(instancetype) initWithAllowNils: (BOOL) allowNils{
    self = [super init];
    if(self != nil){
        self.allowNils = allowNils;
    }
    return self;
}

-(GPKGGeoPackage *) getGeoPackage{

    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    
    // Delete
    [manager delete:GPKG_TEST_CREATE_ELEVATION_TILES_DB_NAME];
    
    // Create
    [manager create:GPKG_TEST_CREATE_ELEVATION_TILES_DB_NAME];
    
    // Open
    GPKGGeoPackage * geoPackage = [manager open:GPKG_TEST_CREATE_ELEVATION_TILES_DB_NAME];
    [manager close];
    if(geoPackage == nil){
        [NSException raise:@"Failed to Open" format:@"Failed to open database"];
    }
    
    double minLongitude = -180.0 + (360.0 * [GPKGTestUtils randomDouble]);
    double maxLongitude = minLongitude + ((180.0 - minLongitude) * [GPKGTestUtils randomDouble]);
    double minLatitude = PROJ_WEB_MERCATOR_MIN_LAT_RANGE + ((PROJ_WEB_MERCATOR_MAX_LAT_RANGE - PROJ_WEB_MERCATOR_MIN_LAT_RANGE) * [GPKGTestUtils randomDouble]);
    double maxLatitude = minLatitude + ((PROJ_WEB_MERCATOR_MAX_LAT_RANGE - minLatitude) * [GPKGTestUtils randomDouble]);
    
    GPKGBoundingBox * bbox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMaxLongitudeDouble:maxLongitude andMinLatitudeDouble:minLatitude andMaxLatitudeDouble:maxLatitude];
    
    GPKGSpatialReferenceSystemDao * srsDao = [geoPackage getSpatialReferenceSystemDao];
    GPKGSpatialReferenceSystem * contentsSrs = [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM_GEOGRAPHICAL_3D]];
    GPKGSpatialReferenceSystem * tileMatrixSrs = [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    GPKGElevationTilesPng * elevationTiles = [GPKGElevationTilesPng createTileTableWithGeoPackage:geoPackage andTableName:GPKG_TEST_CREATE_ELEVATION_TILES_DB_TABLE_NAME andContentsBoundingBox:bbox andContentsSrsId:contentsSrs.srsId andTileMatrixSetBoundingBox:bbox andTileMatrixSetSrsId:tileMatrixSrs.srsId];
    GPKGTileDao * tileDao = elevationTiles.tileDao;
    GPKGTileMatrixSet * tileMatrixSet = [elevationTiles tileMatrixSet];
    
    GPKGGriddedCoverageDao * griddedCoverageDao = [elevationTiles griddedCoverageDao];
    
    GPKGGriddedCoverage * griddedCoverage = [[GPKGGriddedCoverage alloc] init];
    [griddedCoverage setTileMatrixSet:tileMatrixSet];
    [griddedCoverage setGriddedCoverageDataType:GPKG_GCDT_INTEGER];
    BOOL defaultScale = true;
    if([GPKGTestUtils randomDouble] < .5){
        [griddedCoverage setScale:[[NSDecimalNumber alloc] initWithDouble:100.0 * [GPKGTestUtils randomDouble]]];
        defaultScale = false;
    }
    BOOL defaultOffset = true;
    if([GPKGTestUtils randomDouble] < .5){
        [griddedCoverage setOffset:[[NSDecimalNumber alloc] initWithDouble:100.0 * [GPKGTestUtils randomDouble]]];
        defaultOffset = false;
    }
    BOOL defaultPrecision = true;
    if([GPKGTestUtils randomDouble] < .5){
        [griddedCoverage setPrecision:[[NSDecimalNumber alloc] initWithDouble:10.0 * [GPKGTestUtils randomDouble]]];
        defaultPrecision = false;
    }
    [griddedCoverage setDataNull:[[NSDecimalNumber alloc] initWithDouble:SHRT_MAX - SHRT_MIN]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)[griddedCoverageDao create:griddedCoverage]];
    
    NSNumber * gcId = griddedCoverage.id;
    griddedCoverage = (GPKGGriddedCoverage *)[griddedCoverageDao queryForIdObject:gcId];
    [GPKGTestUtils assertNotNil:griddedCoverage];
    if(defaultScale){
        [GPKGTestUtils assertEqualDoubleWithValue:1.0 andValue2:[griddedCoverage.scale doubleValue]];
    }else{
        [GPKGTestUtils assertTrue:[griddedCoverage.scale doubleValue] >= 0.0 && [griddedCoverage.scale doubleValue] <= 100.0];
    }
    if(defaultOffset){
        [GPKGTestUtils assertEqualDoubleWithValue:0.0 andValue2:[griddedCoverage.offset doubleValue]];
    }else{
        [GPKGTestUtils assertTrue:[griddedCoverage.offset doubleValue] >= 0.0 && [griddedCoverage.offset doubleValue] <= 100.0];
    }
    if(defaultPrecision){
        [GPKGTestUtils assertEqualDoubleWithValue:1.0 andValue2:[griddedCoverage.precision doubleValue]];
    }else{
        [GPKGTestUtils assertTrue:[griddedCoverage.precision doubleValue] >= 0.0 && [griddedCoverage.precision doubleValue] <= 10.0];
    }
    
    GPKGGriddedTile * commonGriddedTile = [[GPKGGriddedTile alloc] init];
    GPKGTileMatrixSetDao * tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
    [commonGriddedTile setContents:[tileMatrixSetDao getContents:tileMatrixSet]];
    BOOL defaultGTScale = true;
    if([GPKGTestUtils randomDouble] <.5){
        [commonGriddedTile setScale:[[NSDecimalNumber alloc] initWithDouble:100.0 * [GPKGTestUtils randomDouble]]];
        defaultGTScale = false;
    }
    BOOL defaultGTOffset = true;
    if([GPKGTestUtils randomDouble] <.5){
        [commonGriddedTile setOffset:[[NSDecimalNumber alloc] initWithDouble:100.0 * [GPKGTestUtils randomDouble]]];
        defaultGTOffset = false;
    }
    // The min, max, mean, and sd are just for testing and have
    // no association on the test tile created
    BOOL defaultGTMin = true;
    if([GPKGTestUtils randomDouble] <.5){
        [commonGriddedTile setMin:[[NSDecimalNumber alloc] initWithDouble:1000.0 * [GPKGTestUtils randomDouble]]];
        defaultGTMin = false;
    }
    BOOL defaultGTMax = true;
    if([GPKGTestUtils randomDouble] <.5){
        [commonGriddedTile setMax:[[NSDecimalNumber alloc] initWithDouble:1000.0 * [GPKGTestUtils randomDouble] + (commonGriddedTile.min == nil ? 0 : [commonGriddedTile.min doubleValue])]];
        defaultGTMax = false;
    }
    BOOL defaultGTMean = true;
    if([GPKGTestUtils randomDouble] <.5){
        double min = commonGriddedTile.min != nil ? [commonGriddedTile.min doubleValue] : 0;
        double max = commonGriddedTile.max != nil ? [commonGriddedTile.max doubleValue] : 2000.0;
        [commonGriddedTile setMean:[[NSDecimalNumber alloc] initWithDouble:((max - min) * [GPKGTestUtils randomDouble]) + min]];
        defaultGTMean = false;
    }
    BOOL defaultGTStandardDeviation = true;
    if([GPKGTestUtils randomDouble] <.5){
        double min = commonGriddedTile.min != nil ? [commonGriddedTile.min doubleValue] : 0;
        double max = commonGriddedTile.max != nil ? [commonGriddedTile.max doubleValue] : 2000.0;
        [commonGriddedTile setStandardDeviation:[[NSDecimalNumber alloc] initWithDouble:(max - min) * [GPKGTestUtils randomDouble]]];
        defaultGTStandardDeviation = false;
    }
    
    GPKGGriddedTileDao * griddedTileDao = [elevationTiles griddedTileDao];
    
    int width = 1 + (int) floor(([GPKGTestUtils randomDouble] * 4.0));
    int height = 1 + (int) floor(([GPKGTestUtils randomDouble] * 4.0));
    int tileWidth = 3 + (int) floor(([GPKGTestUtils randomDouble] * 126.0));
    int tileHeight = 3 + (int) floor(([GPKGTestUtils randomDouble] * 126.0));
    int minZoomLevel = (int) floor([GPKGTestUtils randomDouble] * 22.0);
    int maxZoomLevel = minZoomLevel + (int) floor([GPKGTestUtils randomDouble] * 4.0);
    
    // Just draw one image and re-use
    elevationTiles = [[GPKGElevationTilesPng alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
    NSData * imageData = [self drawTileWithElevationTiles:elevationTiles andTileWidth:tileWidth andTileHeight:tileHeight andGriddedCoverage:griddedCoverage andGriddedTile:commonGriddedTile];
    
    GPKGTileMatrixDao * tileMatrixDao = [geoPackage getTileMatrixDao];
    
    for (int zoomLevel = minZoomLevel; zoomLevel <= maxZoomLevel; zoomLevel++) {
        // TODO
    }
    
    return geoPackage;
}

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    
    // Close
    if (self.geoPackage != nil) {
        [self.geoPackage close];
    }
    
    [super tearDown];
}

-(NSData *) drawTileWithElevationTiles: (GPKGElevationTilesPng *) elevationTiles andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight andGriddedCoverage: (GPKGGriddedCoverage *) griddedCoverage andGriddedTile : (GPKGGriddedTile *) commonGriddedTile{
    return nil; // TODO
}

@end
