//
//  GPKGCoverageDataPng.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/29/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataPng.h"
#import "GPKGImageConverter.h"
#import "GPKGCoverageDataPngImage.h"

@implementation GPKGCoverageDataPng

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (GPKGProjection *) requestProjection{
    self = [super initWithGeoPackage:geoPackage andTileDao:tileDao andWidth:width andHeight:height andProjection:requestProjection];
    return self;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao{
    return [self initWithGeoPackage:geoPackage andTileDao:tileDao andWidth:nil andHeight:nil andProjection:tileDao.projection];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andProjection: (GPKGProjection *) requestProjection{
    return [self initWithGeoPackage:geoPackage andTileDao:tileDao andWidth:nil andHeight:nil andProjection:requestProjection];
}

-(NSObject<GPKGCoverageDataImage> *) createImageWithTileRow: (GPKGTileRow *) tileRow{
    return [[GPKGCoverageDataPngImage alloc] initWithTileRow:tileRow];
}

-(double) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andTileRow: (GPKGTileRow *) tileRow andX: (int) x andY: (int) y{
    UIImage * image = [tileRow getTileDataImage];
    NSDecimalNumber * value = [self valueWithGriddedTile: griddedTile andImage: image andX: x andY: y];
    return value.doubleValue;
}

-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andCoverageDataImage: (NSObject<GPKGCoverageDataImage> *) image andX: (int) x andY: (int) y{
    GPKGCoverageDataPngImage * pngImage = (GPKGCoverageDataPngImage *) image;
    return [self valueWithGriddedTile: griddedTile andImage: [pngImage image] andX: x andY: y];
}

-(unsigned short) pixelValueWithImage: (UIImage *) image andX: (int) x andY: (int) y{
    
    int width = (int) image.size.width;
    unsigned short * pixels = [self pixelValuesWithImage:image];
    unsigned short pixel = [self pixelIn:pixels withWidth:width atX:x andY:y];
    free(pixels);
    return pixel;
}

-(unsigned short *) pixelValuesWithImage: (UIImage *) image{
    [GPKGCoverageDataPng validateImageType:image];

    int width = (int) image.size.width;
    int height = (int) image.size.height;
     
    CGImageRef tileImageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    unsigned short *pixels = [self allocatePixelsWithWidth:width andHeight:height];
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 16, 2 * width, colorSpace, kCGImageAlphaNone | kCGBitmapByteOrder16Host);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), tileImageRef);
    CGContextRelease(context);

    return pixels;
}

+(void) validateImageType: (UIImage *) image{
    if (image == nil) {
        [NSException raise:@"Nil Image" format:@"The image is nil"];
    }
    if(CGImageGetBitsPerComponent(image.CGImage) != 16 || CGImageGetBitsPerPixel(image.CGImage) != 16){
        [NSException raise:@"Invalid Image" format:@"The coverage data tile is expected to be a single channel 16 bit unsigned short (16 bits per component & 16 bits per pixel), bits per component: %zu, bits per pixel: %zu", CGImageGetBitsPerComponent(image.CGImage), CGImageGetBitsPerPixel(image.CGImage)];
    }
}

-(NSDecimalNumber *) valueWithGriddedTile:(GPKGGriddedTile *)griddedTile andImage:(UIImage *)image andX:(int)x andY:(int)y{
    unsigned short pixelValue = [self pixelValueWithImage: image andX: x andY: y];
    NSDecimalNumber * value = [self valueWithGriddedTile:griddedTile andPixelValue:pixelValue];
    return value;
}

-(NSArray *) valuesWithGriddedTile:(GPKGGriddedTile *)griddedTile andImage:(UIImage *)image{
    unsigned short * pixelValues = [self pixelValuesWithImage:image];
    NSArray * values = [self valuesWithGriddedTile:griddedTile andPixelValues:pixelValues andCount:image.size.width * image.size.height];
    free(pixelValues);
    return values;
}

-(UIImage *) drawTileWithUnsignedShortPixelValues: (unsigned short *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(&pixelValues[0], tileWidth, tileHeight, 16, 2 * tileWidth, colorSpace, kCGImageAlphaNone | kCGBitmapByteOrder16Host);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage * tileImage = [[UIImage alloc] initWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return tileImage;
}

-(UIImage *) drawTileWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    unsigned short * pixels = [self pixelValuesArrayToUnsignedShort:pixelValues];
    UIImage * tileImage = [self drawTileWithUnsignedShortPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    UIImage * image = [self drawTileWithPixelValues:pixelValues andTileWidth:tileWidth andTileHeight:tileHeight];
    NSData * data = [self imageData:image];
    return data;
}

-(UIImage *) drawTileWithDoubleArrayPixelValues:(NSArray *)pixelValues{
    unsigned short * pixels = [self pixelValuesDoubleArrayToUnsignedShort:pixelValues];
    int tileWidth = (int)((NSArray *)[pixelValues objectAtIndex: 0]).count;
    int tileHeight = (int)pixelValues.count;
    UIImage * tileImage = [self drawTileWithUnsignedShortPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithDoubleArrayPixelValues:(NSArray *)pixelValues{
    UIImage * image = [self drawTileWithDoubleArrayPixelValues:pixelValues];
    NSData * data = [self imageData:image];
    return data;
}

-(UIImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andValues: (NSArray *) values andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    unsigned short * pixels = [self pixelValuesOfValues:values withGriddedTile:griddedTile];
    UIImage * tileImage = [self drawTileWithUnsignedShortPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andValues: (NSArray *) values andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    UIImage * image = [self drawTileWithGriddedTile:griddedTile andValues:values andTileWidth:tileWidth andTileHeight:tileHeight];
    NSData * data = [self imageData:image];
    return data;
}

-(UIImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayValues: (NSArray *) values{
    unsigned short * pixels = [self pixelValuesOfDoubleArrayValues:values withGriddedTile:griddedTile];
    int tileWidth = (int)((NSArray *)[values objectAtIndex: 0]).count;
    int tileHeight = (int)values.count;
    UIImage * tileImage = [self drawTileWithUnsignedShortPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayValues: (NSArray *) values{
    UIImage * image = [self drawTileWithGriddedTile:griddedTile andDoubleArrayValues:values];
    NSData * data = [self imageData:image];
    return data;
}

-(NSData *) imageData: (UIImage *) image{
    NSData * data = [GPKGImageConverter toData:image andFormat:GPKG_CF_PNG];
    return data;
}

-(unsigned short) pixelIn: (unsigned short *) pixels withWidth: (int) width atX: (int) x andY: (int) y{
    return pixels[(y * width) + x];
}

-(NSArray *) pixelValuesUnsignedShortToArray: (unsigned short *) pixelValues withCount: (int) count{
    NSMutableArray * pixels = [[NSMutableArray alloc] initWithCapacity:count];
    for(int i= 0; i < count; i++){
        unsigned short pixel = pixelValues[i];
        [pixels addObject:[NSNumber numberWithUnsignedShort:pixel]];
    }
    return pixels;
}

-(unsigned short *) pixelValuesArrayToUnsignedShort: (NSArray *) pixelValues{
    unsigned short * pixels = [self allocatePixelsWithCount:(int)pixelValues.count];
    for(int i = 0; i < pixelValues.count; i++){
        NSNumber * pixel = [pixelValues objectAtIndex:i];
        pixels[i] = [pixel unsignedShortValue];
    }
    return pixels;
}

-(unsigned short *) pixelValuesDoubleArrayToUnsignedShort: (NSArray *) pixelValues{
    
    int tileWidth = (int)((NSArray *)[pixelValues objectAtIndex: 0]).count;
    int tileHeight = (int)pixelValues.count;
    
    unsigned short * pixels = [self allocatePixelsWithWidth:tileWidth andHeight:tileHeight];
    for(int y = 0; y < tileHeight; y++){
        NSArray * rowValues = [pixelValues objectAtIndex:y];
        for(int x = 0; x < tileWidth; x++){
            NSNumber * pixel = [rowValues objectAtIndex:x];
            pixels[(y * tileWidth) + x] = [pixel unsignedShortValue];
        }
    }
    return pixels;
}

-(unsigned short *) pixelValuesOfValues: (NSArray *) values withGriddedTile: (GPKGGriddedTile *) griddedTile{
    unsigned short * pixels = [self allocatePixelsWithCount:(int)values.count];
    for(int i = 0; i < values.count; i++){
        NSDecimalNumber * value = [values objectAtIndex:i];
        unsigned short pixelValue = [self pixelValueWithGriddedTile:griddedTile andValue:value];
        pixels[i] = pixelValue;
    }
    return pixels;
}

-(unsigned short *) pixelValuesOfDoubleArrayValues: (NSArray *) values withGriddedTile: (GPKGGriddedTile *) griddedTile{
    
    int tileWidth = (int)((NSArray *)[values objectAtIndex: 0]).count;
    int tileHeight = (int)values.count;
    
    unsigned short * pixels = [self allocatePixelsWithWidth:tileWidth andHeight:tileHeight];
    for(int y = 0; y < tileHeight; y++){
        NSArray * rowValues = [values objectAtIndex:y];
        for(int x = 0; x < tileWidth; x++){
            NSDecimalNumber * value = [rowValues objectAtIndex:x];
            unsigned short pixelValue = [self pixelValueWithGriddedTile:griddedTile andValue:value];
            pixels[(y * tileWidth) + x] = pixelValue;
        }
    }
    return pixels;
}

-(unsigned short *) allocatePixelsWithWidth: (int) width andHeight: (int) height{
    return [self allocatePixelsWithCount:width * height];
}

-(unsigned short *) allocatePixelsWithCount: (int) count{
    return calloc(count, sizeof(unsigned short));
}

+(GPKGCoverageDataPng *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId{
    
    GPKGTileMatrixSet * tileMatrixSet = [GPKGCoverageData createTileTableWithGeoPackage:geoPackage andTableName:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileMatrixSetBoundingBox:tileMatrixSetBoundingBox andTileMatrixSetSrsId:tileMatrixSetSrsId];
    
    GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
    GPKGCoverageDataPng * coverageData = [[GPKGCoverageDataPng alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
    [coverageData getOrCreate];
    
    return coverageData;
}


@end
