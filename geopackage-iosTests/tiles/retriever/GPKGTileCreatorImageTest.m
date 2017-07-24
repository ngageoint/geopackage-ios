//
//  GPKGTileCreatorImageTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGTileCreatorImageTest.h"
#import "GPKGTestConstants.h"
#import "GPKGProjectionConstants.h"
#import "GPKGTestUtils.h"
#import "GPKGProjectionFactory.h"
#import "GPKGTileCreator.h"
#import "GPKGBoundingBox.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGImageConverter.h"
#import "GPKGProjectionFactory.h"
#import "GPKGProjectionTransform.h"

@implementation GPKGTileCreatorImageTest

- (void)setUp {
    self.dbName = GPKG_TEST_TILES2_DB_NAME;
    self.file = GPKG_TEST_TILES2_DB_FILE_NAME;
    self.colorTolerance = 0;
    [super setUp];
}

-(void) testTileImage{
    
    GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTableName:GPKG_TEST_TILES2_DB_TABLE_NAME];
    [GPKGTestUtils assertEqualWithValue:[tileDao.projection authority] andValue2:PROJ_AUTHORITY_EPSG];
    [GPKGTestUtils assertEqualIntWithValue:[tileDao.projection.code intValue] andValue2:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    GPKGProjection * webMercator = [GPKGProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
    GPKGProjection * wgs84 = [GPKGProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    NSNumber * width = [NSNumber numberWithInt:256];
    NSNumber * height = [NSNumber numberWithInt:256];
    GPKGTileCreator * webMeractorTileCreator = [[GPKGTileCreator alloc] initWithTileDao:tileDao andWidth:width andHeight:height andProjection:webMercator];
    GPKGTileCreator * wgs84TileCreator = [[GPKGTileCreator alloc] initWithTileDao:tileDao andWidth:width andHeight:height];
    
    GPKGBoundingBox * webMercatorBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithX:0 andY:4 andZoom:4];
    GPKGBoundingBox * wgs84BoundingBox = [[[GPKGProjectionTransform alloc] initWithFromProjection:webMercator andToProjection:wgs84] transformWithBoundingBox:webMercatorBoundingBox];
    
    [GPKGTestUtils assertTrue:[webMeractorTileCreator hasTileWithBoundingBox:webMercatorBoundingBox]];
    [GPKGTestUtils assertTrue:[wgs84TileCreator hasTileWithBoundingBox:wgs84BoundingBox]];
    
    GPKGGeoPackageTile * webMercatorTile = [webMeractorTileCreator getTileWithBoundingBox:webMercatorBoundingBox];
    GPKGGeoPackageTile * wgs84Tile = [wgs84TileCreator getTileWithBoundingBox:wgs84BoundingBox];
    
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
    
    unsigned char * webMercatorPixels = [self getPixels:webMercatorImage];
    unsigned char * webMercatorTestPixels = [self getPixels:webMercatorTestImage];
    unsigned char * wgs84Pixels = [self getPixels:wgs84Image];
    unsigned char * wgs84TestPixels = [self getPixels:wgs84TestImage];
    
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

-(unsigned char *) getPixels: (UIImage *) image{
    
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

@end
