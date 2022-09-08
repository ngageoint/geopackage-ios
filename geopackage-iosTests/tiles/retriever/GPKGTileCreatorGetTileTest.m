//
//  GPKGTileCreatorGetTileTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGTileCreatorGetTileTest.h"
#import "GPKGTestConstants.h"
#import "PROJProjectionConstants.h"
#import "GPKGTestUtils.h"
#import "PROJProjectionFactory.h"
#import "GPKGTileCreator.h"
#import "GPKGBoundingBox.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGImageConverter.h"

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
    
    GPKGTileDao *tileDao = [self.geoPackage tileDaoWithTableName:GPKG_TEST_TILES_DB_TABLE_NAME];
    [GPKGTestUtils assertEqualWithValue:[tileDao.projection authority] andValue2:PROJ_AUTHORITY_EPSG];
    [GPKGTestUtils assertEqualIntWithValue:[tileDao.projection.code intValue] andValue2:PROJ_EPSG_WEB_MERCATOR];
    
    [tileDao adjustTileMatrixLengths];
    
    PROJProjection *wgs84 = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    NSNumber *width = [NSNumber numberWithInt:256];
    NSNumber *height = [NSNumber numberWithInt:140];
    GPKGTileCreator *tileCreator = [[GPKGTileCreator alloc] initWithTileDao:tileDao andWidth:width andHeight:height andProjection:wgs84];
    
    GPKGBoundingBox *boundingBox = [GPKGBoundingBox worldWGS84];
    boundingBox = [GPKGTileBoundingBoxUtils boundWgs84BoundingBoxWithWebMercatorLimits:boundingBox];
    [GPKGTestUtils assertFalse:[tileCreator hasTileWithBoundingBox:boundingBox]];
    
    boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-180.0 andMinLatitudeDouble:0.0 andMaxLongitudeDouble:0.0 andMaxLatitudeDouble:90.0];
    boundingBox = [GPKGTileBoundingBoxUtils boundWgs84BoundingBoxWithWebMercatorLimits:boundingBox];
    [GPKGTestUtils assertTrue:[tileCreator hasTileWithBoundingBox:boundingBox]];
    
    GPKGGeoPackageTile *tile = [tileCreator tileWithBoundingBox:boundingBox];
    
    [GPKGTestUtils assertNotNil:tile];
    [GPKGTestUtils assertEqualIntWithValue:[width intValue] andValue2:tile.width];
    [GPKGTestUtils assertEqualIntWithValue:[height intValue] andValue2:tile.height];
    
    NSData *tileData = tile.data;
    [GPKGTestUtils assertNotNil:tileData];
    UIImage *image = [GPKGImageConverter toImage:tileData];
    
    [GPKGTestUtils assertEqualIntWithValue:[width intValue] andValue2:image.size.width];
    [GPKGTestUtils assertEqualIntWithValue:[height intValue] andValue2:image.size.height];
    [self validateImage:image];
    
    boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90.0 andMinLatitudeDouble:0.0 andMaxLongitudeDouble:0.0 andMaxLatitudeDouble:45.0];
    [GPKGTestUtils assertTrue:[tileCreator hasTileWithBoundingBox:boundingBox]];
    
    tile = [tileCreator tileWithBoundingBox:boundingBox];
    
    [GPKGTestUtils assertNotNil:tile];
    [GPKGTestUtils assertEqualIntWithValue:[width intValue] andValue2:tile.width];
    [GPKGTestUtils assertEqualIntWithValue:[height intValue] andValue2:tile.height];
    
    tileData = tile.data;
    [GPKGTestUtils assertNotNil:tileData];
    image = [GPKGImageConverter toImage:tileData];
    
    [GPKGTestUtils assertEqualIntWithValue:[width intValue] andValue2:image.size.width];
    [GPKGTestUtils assertEqualIntWithValue:[height intValue] andValue2:image.size.height];
    [self validateImage:image];

}

-(void) validateImage: (UIImage *) image{
    
    int width = (int) image.size.width;
    int height = (int) image.size.height;
    
    CGImageRef tileImageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *pixels = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    CGContextRef context = CGBitmapContextCreate(pixels, width, height,
                                                 8, 4 * width, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), tileImageRef);
    CGContextRelease(context);
    
    for (int x = 0; x < image.size.width; x++) {
        for (int y = 0; y < image.size.height; y++) {
            
            int red = pixels[((y * width) + x) * 4];
            int green = pixels[(((y * width) + x) * 4) + 1];
            int blue = pixels[(((y * width) + x) * 4) + 2];
            int alpha = pixels[(((y * width) + x) * 4) + 3];
            
            [GPKGTestUtils assertTrue:red > 0];
            [GPKGTestUtils assertTrue:green > 0];
            [GPKGTestUtils assertTrue:blue > 0];
            [GPKGTestUtils assertTrue:alpha > 0];
        }
    }
    
    free(pixels);
}

@end
