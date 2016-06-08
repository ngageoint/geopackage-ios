//
//  GPKGTileCreatorGetTileTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGTileCreatorGetTileTest.h"
#import "GPKGTestConstants.h"
#import "GPKGProjectionConstants.h"
#import "GPKGTestUtils.h"
#import "GPKGProjectionFactory.h"
#import "GPKGTileCreator.h"
#import "GPKGBoundingBox.h"

@implementation GPKGTileCreatorGetTileTest

- (void)setUp {
    self.dbName = GPKG_TEST_TILES_DB_NAME;
    self.file = GPKG_TEST_TILES_DB_FILE_NAME;
    [super setUp];
}

/**
 *  Test get tile
 */
-(void) testGetTile{
    
    GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTableName:GPKG_TEST_TILES_DB_TABLE_NAME];
    [GPKGTestUtils assertEqualIntWithValue:[tileDao.projection.epsg intValue] andValue2:PROJ_EPSG_WEB_MERCATOR];
    
    [tileDao adjustTileMatrixLengths];
    
    GPKGProjection * wgs84 = [GPKGProjectionFactory getProjectionWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    NSNumber * width = [NSNumber numberWithInt:256];
    NSNumber * height = [NSNumber numberWithInt:140];
    GPKGTileCreator * tileCreator = [[GPKGTileCreator alloc] initWithTileDao:tileDao andWidth:width andHeight:height andProjection:wgs84];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] init];
    
    // TODO
}

@end
