//
//  GPKGTileCreatorImageTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGTileCreatorImageTest.h"
#import "GPKGTestConstants.h"
#import "PROJProjectionConstants.h"
#import "GPKGTestUtils.h"
#import "PROJProjectionFactory.h"
#import "GPKGTileCreator.h"
#import "GPKGBoundingBox.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGImageConverter.h"
#import "PROJProjectionFactory.h"

@implementation GPKGTileCreatorImageTest

- (void)setUp {
    self.dbName = GPKG_TEST_TILES2_DB_NAME;
    self.file = GPKG_TEST_TILES2_DB_FILE_NAME;
    self.colorTolerance = 1;
    [super setUp];
}

-(void) testTileImage{
    
    GPKGTileDao * tileDao = [self.geoPackage tileDaoWithTableName:GPKG_TEST_TILES2_DB_TABLE_NAME];
    [GPKGTestUtils assertEqualWithValue:[tileDao.projection authority] andValue2:PROJ_AUTHORITY_EPSG];
    [GPKGTestUtils assertEqualIntWithValue:[tileDao.projection.code intValue] andValue2:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    PROJProjection * webMercator = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
    PROJProjection * wgs84 = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    NSNumber * width = [NSNumber numberWithInt:256];
    NSNumber * height = [NSNumber numberWithInt:256];
    GPKGTileCreator * webMercatorTileCreator = [[GPKGTileCreator alloc] initWithTileDao:tileDao andWidth:width andHeight:height andProjection:webMercator];
    GPKGTileCreator * wgs84TileCreator = [[GPKGTileCreator alloc] initWithTileDao:tileDao andWidth:width andHeight:height];
    
    GPKGBoundingBox * webMercatorBoundingBox = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithX:0 andY:4 andZoom:4];
    GPKGBoundingBox * wgs84BoundingBox = [webMercatorBoundingBox transform:[SFPGeometryTransform transformFromProjection:webMercator andToProjection:wgs84]];
    
    [GPKGTestUtils assertTrue:[webMercatorTileCreator hasTileWithBoundingBox:webMercatorBoundingBox]];
    [GPKGTestUtils assertTrue:[wgs84TileCreator hasTileWithBoundingBox:wgs84BoundingBox]];
    
    GPKGGeoPackageTile * webMercatorTile = [webMercatorTileCreator tileWithBoundingBox:webMercatorBoundingBox];
    GPKGGeoPackageTile * wgs84Tile = [wgs84TileCreator tileWithBoundingBox:wgs84BoundingBox];
    
    [GPKGTestUtils assertNotNil:webMercatorTile];
    [GPKGTestUtils assertEqualIntWithValue:[width intValue] andValue2:webMercatorTile.width];
    [GPKGTestUtils assertEqualIntWithValue:[height intValue] andValue2:webMercatorTile.height];
    
    [GPKGTestUtils assertNotNil:wgs84Tile];
    [GPKGTestUtils assertEqualIntWithValue:[width intValue] andValue2:wgs84Tile.width];
    [GPKGTestUtils assertEqualIntWithValue:[height intValue] andValue2:wgs84Tile.height];
    
    NSData * webMercatorTileData = webMercatorTile.data;
    [GPKGTestUtils assertNotNil:webMercatorTileData];
    UIImage * webMercatorImage = [GPKGImageConverter toImage:webMercatorTileData];
    
    NSData * wgs84TileData = wgs84Tile.data;
    [GPKGTestUtils assertNotNil:wgs84TileData];
    UIImage * wgs84Image = [GPKGImageConverter toImage:wgs84TileData];
    
    [GPKGTestUtils assertEqualIntWithValue:[width intValue] andValue2:webMercatorImage.size.width];
    [GPKGTestUtils assertEqualIntWithValue:[height intValue] andValue2:webMercatorImage.size.height];
    [self validateNoTransparency:webMercatorImage];
    
    [GPKGTestUtils assertEqualIntWithValue:[width intValue] andValue2:wgs84Image.size.width];
    [GPKGTestUtils assertEqualIntWithValue:[height intValue] andValue2:wgs84Image.size.height];
    [self validateNoTransparency:wgs84Image];
    
    
    NSString * webMercatorTestImagePath  = [[[NSBundle bundleForClass:[GPKGTileCreatorImageTest class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_TILES2_WEB_MERCATOR_TEST_IMAGE];
    UIImage * webMercatorTestImage = [UIImage imageWithContentsOfFile:webMercatorTestImagePath];
    
    NSString * wgs84TestImagePath  = [[[NSBundle bundleForClass:[GPKGTileCreatorImageTest class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_TILES2_WGS84_TEST_IMAGE];
    UIImage * wgs84TestImage = [UIImage imageWithContentsOfFile:wgs84TestImagePath];
    
    int redDiff = 0;
    int greenDiff = 0;
    int blueDiff = 0;

    int widthValue = [width intValue];
    int heightValue = [height intValue];
    
    unsigned char * webMercatorPixels = [self pixels:webMercatorImage];
    unsigned char * webMercatorTestPixels = [self pixels:webMercatorTestImage];
    unsigned char * wgs84Pixels = [self pixels:wgs84Image];
    unsigned char * wgs84TestPixels = [self pixels:wgs84TestImage];
    
    // Compare the image pixels with the expected test image pixels
    for (int x = 0; x < widthValue; x++) {
        for (int y = 0; y < heightValue; y++) {
            
            int webMercatorRed = webMercatorPixels[((y * widthValue) + x) * 4];
            int webMercatorGreen = webMercatorPixels[(((y * widthValue) + x) * 4) + 1];
            int webMercatorBlue = webMercatorPixels[(((y * widthValue) + x) * 4) + 2];
            int webMercatorAlpha = webMercatorPixels[(((y * widthValue) + x) * 4) + 3];
            
            int webMercatorTestRed = webMercatorTestPixels[((y * widthValue) + x) * 4];
            int webMercatorTestGreen = webMercatorTestPixels[(((y * widthValue) + x) * 4) + 1];
            int webMercatorTestBlue = webMercatorTestPixels[(((y * widthValue) + x) * 4) + 2];
            int webMercatorTestAlpha = webMercatorTestPixels[(((y * widthValue) + x) * 4) + 3];
            
            [GPKGTestUtils assertTrue:ABS(webMercatorRed - webMercatorTestRed) <= self.colorTolerance];
            [GPKGTestUtils assertTrue:ABS(webMercatorGreen - webMercatorTestGreen) <= self.colorTolerance];
            [GPKGTestUtils assertTrue:ABS(webMercatorBlue - webMercatorTestBlue) <= self.colorTolerance];
            [GPKGTestUtils assertTrue:ABS(webMercatorAlpha - webMercatorTestAlpha) <= self.colorTolerance];
            
            int wgs84Red = wgs84Pixels[((y * widthValue) + x) * 4];
            int wgs84Green = wgs84Pixels[(((y * widthValue) + x) * 4) + 1];
            int wgs84Blue = wgs84Pixels[(((y * widthValue) + x) * 4) + 2];
            int wgs84Alpha = wgs84Pixels[(((y * widthValue) + x) * 4) + 3];
            
            int wgs84TestRed = wgs84TestPixels[((y * widthValue) + x) * 4];
            int wgs84TestGreen = wgs84TestPixels[(((y * widthValue) + x) * 4) + 1];
            int wgs84TestBlue = wgs84TestPixels[(((y * widthValue) + x) * 4) + 2];
            int wgs84TestAlpha = wgs84TestPixels[(((y * widthValue) + x) * 4) + 3];
            
            [GPKGTestUtils assertTrue:ABS(wgs84Red - wgs84TestRed) <= self.colorTolerance];
            [GPKGTestUtils assertTrue:ABS(wgs84Green - wgs84TestGreen) <= self.colorTolerance];
            [GPKGTestUtils assertTrue:ABS(wgs84Blue - wgs84TestBlue) <= self.colorTolerance];
            [GPKGTestUtils assertTrue:ABS(wgs84Alpha - wgs84TestAlpha) <= self.colorTolerance];
            
            redDiff = MAX(redDiff, ABS(webMercatorRed - wgs84Red));
            greenDiff = MAX(greenDiff, ABS(webMercatorGreen - wgs84Green));
            blueDiff = MAX(blueDiff, ABS(webMercatorBlue - wgs84Blue));
        }
    }
    
    // Verify the web mercator and wgs84 images were different
    [GPKGTestUtils assertTrue:redDiff > self.colorTolerance];
    [GPKGTestUtils assertTrue:greenDiff > self.colorTolerance];
    [GPKGTestUtils assertTrue:blueDiff > self.colorTolerance];

    free(webMercatorPixels);
    free(webMercatorTestPixels);
    free(wgs84Pixels);
    free(wgs84TestPixels);
    
    // To save the images to user documents directory if the test images need to change
    /*
    NSString * saveLocation = @"/Users/osbornb/Documents/";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *webMercatorData = UIImagePNGRepresentation(webMercatorImage);
    [fileManager createFileAtPath:[NSString stringWithFormat:@"%@%@", saveLocation, GPKG_TEST_TILES2_WEB_MERCATOR_TEST_IMAGE] contents:webMercatorData attributes:nil];
    NSData *wgs84Data = UIImagePNGRepresentation(wgs84Image);
    [fileManager createFileAtPath:[NSString stringWithFormat:@"%@/%@", saveLocation, GPKG_TEST_TILES2_WGS84_TEST_IMAGE] contents:wgs84Data attributes:nil];
     */
    
}

-(unsigned char *) pixels: (UIImage *) image{
    
    int width = image.size.width;
    int height = image.size.height;
    
    CGImageRef tileImageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *pixels = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    CGContextRef context = CGBitmapContextCreate(pixels, width, height,
                                                 8, 4 * width, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), tileImageRef);
    CGContextRelease(context);
    
    return pixels;
}

-(void) validateNoTransparency: (UIImage *) image{
    
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
            
            //int red = pixels[((y * width) + x) * 4];
            //int green = pixels[(((y * width) + x) * 4) + 1];
            //int blue = pixels[(((y * width) + x) * 4) + 2];
            int alpha = pixels[(((y * width) + x) * 4) + 3];
            
            [GPKGTestUtils assertTrue:alpha > 0];
        }
    }
    
    free(pixels);
}

-(void) testTileImageProjections{
    
    GPKGTileDao *tileDao = [self.geoPackage tileDaoWithTableName:GPKG_TEST_TILES2_DB_TABLE_NAME];
    GPKGBoundingBox *boudingbox = [self.geoPackage boundingBoxOfTable:GPKG_TEST_TILES2_DB_TABLE_NAME];
    
    PROJProjection *wgs84 = [self.geoPackage projectionOfTable:GPKG_TEST_TILES2_DB_TABLE_NAME];
    PROJProjection *webMercator = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
    SFPGeometryTransform *toWebMercator = [SFPGeometryTransform transformFromProjection:wgs84 andToProjection:webMercator];
    SFPGeometryTransform *toWGS84 = [toWebMercator inverseTransformation];
    
    GPKGBoundingBox *webMercatorBoundingBox = [boudingbox transform:toWebMercator];
    
    NSNumber *width = [NSNumber numberWithInt:256];
    NSNumber *height = [NSNumber numberWithInt:256];
    GPKGTileCreator *webMercatorTileCreator = [[GPKGTileCreator alloc] initWithTileDao:tileDao andWidth:width andHeight:height andProjection:webMercator];
    GPKGTileCreator *wgs84TileCreator = [[GPKGTileCreator alloc] initWithTileDao:tileDao andWidth:width andHeight:height];
    
    double minLongitude = [webMercatorBoundingBox.minLongitude doubleValue];
    double maxLongitude = [webMercatorBoundingBox.maxLongitude doubleValue];
    double midLongitude = minLongitude + ((maxLongitude - minLongitude) / 2);
    
    double minLatitude = [webMercatorBoundingBox.minLatitude doubleValue];
    double maxLatitude = [webMercatorBoundingBox.maxLatitude doubleValue];
    double midLatitude = minLatitude + ((maxLatitude - minLatitude) / 2);
    
    double minWGS84Longitude = [boudingbox.minLongitude doubleValue];
    double maxWGS84Longitude = [boudingbox.maxLongitude doubleValue];
    double midWGS84Longitude = minWGS84Longitude + ((maxWGS84Longitude - minWGS84Longitude) / 2);
    
    double minWGS84Latitude = [boudingbox.minLatitude doubleValue];
    double maxWGS84Latitude = [boudingbox.maxLatitude doubleValue];
    double midWGS84Latitude = minWGS84Latitude + ((maxWGS84Latitude - minWGS84Latitude) / 2);
    
    GPKGBoundingBox *topLeft = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude
                                                              andMinLatitudeDouble:midLatitude
                                                             andMaxLongitudeDouble:midLongitude
                                                              andMaxLatitudeDouble:maxLatitude];
    GPKGBoundingBox *topLeftWGS84 = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minWGS84Longitude
                                                                   andMinLatitudeDouble:midWGS84Latitude
                                                                  andMaxLongitudeDouble:midWGS84Longitude
                                                                   andMaxLatitudeDouble:maxWGS84Latitude];
    [self createTilesWithWebMercatorCreate:webMercatorTileCreator andWebMercator:topLeft andWGS84Create:wgs84TileCreator andWGS84:topLeftWGS84];
    
    GPKGBoundingBox *topRight = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:midLongitude
                                                              andMinLatitudeDouble:midLatitude
                                                             andMaxLongitudeDouble:maxLongitude
                                                              andMaxLatitudeDouble:maxLatitude];
    GPKGBoundingBox *topRightWGS84 = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:midWGS84Longitude
                                                                   andMinLatitudeDouble:midWGS84Latitude
                                                                  andMaxLongitudeDouble:maxWGS84Longitude
                                                                   andMaxLatitudeDouble:maxWGS84Latitude];
    [self createTilesWithWebMercatorCreate:webMercatorTileCreator andWebMercator:topRight andWGS84Create:wgs84TileCreator andWGS84:topRightWGS84];
    
    GPKGBoundingBox *bottomLeft = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude
                                                              andMinLatitudeDouble:minLatitude
                                                             andMaxLongitudeDouble:midLongitude
                                                              andMaxLatitudeDouble:midLatitude];
    GPKGBoundingBox *bottomLeftWGS84 = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minWGS84Longitude
                                                                   andMinLatitudeDouble:minWGS84Latitude
                                                                  andMaxLongitudeDouble:midWGS84Longitude
                                                                   andMaxLatitudeDouble:midWGS84Latitude];
    [self createTilesWithWebMercatorCreate:webMercatorTileCreator andWebMercator:bottomLeft andWGS84Create:wgs84TileCreator andWGS84:bottomLeftWGS84];
    
    GPKGBoundingBox *bottomRight = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:midLongitude
                                                              andMinLatitudeDouble:minLatitude
                                                             andMaxLongitudeDouble:maxLongitude
                                                              andMaxLatitudeDouble:midLatitude];
    GPKGBoundingBox *bottomRightWGS84 = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:midWGS84Longitude
                                                                   andMinLatitudeDouble:minWGS84Latitude
                                                                  andMaxLongitudeDouble:maxWGS84Longitude
                                                                   andMaxLatitudeDouble:midWGS84Latitude];
    [self createTilesWithWebMercatorCreate:webMercatorTileCreator andWebMercator:bottomRight andWGS84Create:wgs84TileCreator andWGS84:bottomRightWGS84];
    
    double pixelXSize = (maxLongitude - minLongitude) / (2 * [width doubleValue]);
    double pixelYSize = (maxLatitude - minLatitude) / (2 * [height doubleValue]);
    
    double pixelXSizeWGS84 = (maxWGS84Longitude - minWGS84Longitude) / (2 * [width doubleValue]);
    double pixelYSizeWGS84 = (maxWGS84Latitude - minWGS84Latitude) / (2 * [height doubleValue]);
    
}

-(void) createTilesWithWebMercatorCreate: (GPKGTileCreator *) webMercatorCreator andWebMercator: (GPKGBoundingBox *) webMercator andWGS84Create: (GPKGTileCreator *) wgs84Creator andWGS84: (GPKGBoundingBox *) wgs84{
    
    PROJProjection *wgs84Projection = [self.geoPackage projectionOfTable:GPKG_TEST_TILES2_DB_TABLE_NAME];
    PROJProjection *webMercatorProjection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
    SFPGeometryTransform *toWebMercator = [SFPGeometryTransform transformFromProjection:wgs84Projection andToProjection:webMercatorProjection];
    SFPGeometryTransform *toWGS84 = [toWebMercator inverseTransformation];
    
    GPKGBoundingBox *wgs84WebMercator = [webMercator transform:toWGS84];
    double pixelXSize = ([wgs84WebMercator.maxLongitude doubleValue] - [wgs84WebMercator.minLongitude doubleValue]) / (1.0 * [[wgs84Creator width] doubleValue]);
    double pixelYSize = ([wgs84WebMercator.maxLatitude doubleValue] - [wgs84WebMercator.minLatitude doubleValue]) / (1.0 * [[wgs84Creator height] doubleValue]);
    
    GPKGGeoPackageTile *tile = [webMercatorCreator tileWithBoundingBox:webMercator];
    GPKGGeoPackageTile *wgs84WebMercatorTile = [wgs84Creator tileWithBoundingBox:wgs84WebMercator];
    GPKGGeoPackageTile *wgs84Tile = [wgs84Creator tileWithBoundingBox:wgs84];
    
    UIImage *image = [GPKGImageConverter toImage:tile.data];
    UIImage *wgs84WebMercatorImage = [GPKGImageConverter toImage:wgs84WebMercatorTile.data];
    UIImage *wgs84Image = [GPKGImageConverter toImage:wgs84Tile.data];

    [GPKGTestUtils assertEqualIntWithValue:image.size.width andValue2:wgs84WebMercatorImage.size.width];
    [GPKGTestUtils assertEqualIntWithValue:image.size.height andValue2:wgs84WebMercatorImage.size.height];
    [GPKGTestUtils assertEqualIntWithValue:image.size.width andValue2:wgs84Image.size.width];
    [GPKGTestUtils assertEqualIntWithValue:image.size.height andValue2:wgs84Image.size.height];
    
}

@end
