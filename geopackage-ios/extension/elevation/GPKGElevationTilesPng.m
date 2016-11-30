//
//  GPKGElevationTilesPng.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/29/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTilesPng.h"
#import "GPKGImageConverter.h"

@implementation GPKGElevationTilesPng

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

-(double) elevationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andTileRow: (GPKGTileRow *) tileRow andX: (int) x andY: (int) y{
    UIImage * image = [tileRow getTileDataImage];
    NSDecimalNumber * elevation = [self elevationValueWithGriddedTile: griddedTile andImage: image andX: x andY: y];
    return elevation.doubleValue;
}


-(NSDecimalNumber *) elevationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevationImage: (GPKGElevationImage *) image andX: (int) x andY: (int) y{
    return [self elevationValueWithGriddedTile: griddedTile andImage: [image image] andX: x andY: y];
}

-(unsigned short) pixelValueWithImage: (UIImage *) image andX: (int) x andY: (int) y{
    [self validateImageType:image];
    
    /*
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
     */
    return 0; //TODO
}

-(NSArray *) pixelValuesWithImage: (UIImage *) image{
    [self validateImageType:image];
    return nil; // TODO
}

-(void) validateImageType: (UIImage *) image{
    if (image == nil) {
        [NSException raise:@"Nil Image" format:@"The image is nil"];
    }
    // TODO more validation?
}

-(NSDecimalNumber *) elevationValueWithGriddedTile:(GPKGGriddedTile *)griddedTile andImage:(UIImage *)image andX:(int)x andY:(int)y{
    unsigned short pixelValue = [self pixelValueWithImage: image andX: x andY: y];
    NSDecimalNumber * elevation = [self elevationValueWithGriddedTile:griddedTile andPixelValue:pixelValue];
    return elevation;
}

-(NSArray *) elevationValuesWithGriddedTile:(GPKGGriddedTile *)griddedTile andImage:(UIImage *)image{
    NSArray * pixelValues = [self pixelValuesWithImage:image];
    NSArray * elevations = [self elevationValuesWithGriddedTile:griddedTile andPixelValues:pixelValues];
    return elevations;
}

-(UIImage *) drawTileWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    return nil; //TODO
}

-(NSData *) drawTileDataWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    UIImage * image = [self drawTileWithPixelValues:pixelValues andTileWidth:tileWidth andTileHeight:tileHeight];
    NSData * data = [self imageData:image];
    return data;
}

-(UIImage *) drawTileWithDoubleArrayPixelValues:(NSArray *)pixelValues{
    return nil; //TODO
}

-(NSData *) drawTileDataWithDoubleArrayPixelValues:(NSArray *)pixelValues{
    UIImage * image = [self drawTileWithDoubleArrayPixelValues:pixelValues];
    NSData * data = [self imageData:image];
    return data;
}

-(UIImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevations: (NSArray *) elevations andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    return nil; //TODO
}

-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevations: (NSArray *) elevations andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    UIImage * image = [self drawTileWithGriddedTile:griddedTile andElevations:elevations andTileWidth:tileWidth andTileHeight:tileHeight];
    NSData * data = [self imageData:image];
    return data;
}

-(UIImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayElevations: (NSArray *) elevations{
    return nil; //TODO
}

-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevations: (NSArray *) elevations{
    UIImage * image = [self drawTileWithGriddedTile:griddedTile andDoubleArrayElevations:elevations];
    NSData * data = [self imageData:image];
    return data;
}

-(UIImage *) createImageWithTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    return nil; //TODO
}

-(NSData *) imageData: (UIImage *) image{
    NSData * data = [GPKGImageConverter toData:image andFormat:GPKG_CF_PNG];
    return data;
}

// TODO setPixel method?

+(GPKGElevationTilesPng *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId{
    
    GPKGTileMatrixSet * tileMatrixSet = [GPKGElevationTilesCore createTileTableWithGeoPackage:geoPackage andTableName:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileMatrixSetBoundingBox:tileMatrixSetBoundingBox andTileMatrixSetSrsId:tileMatrixSetSrsId];
    
    GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
    GPKGElevationTilesPng * elevationTiles = [[GPKGElevationTilesPng alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
    [elevationTiles getOrCreate];
    
    return elevationTiles;
}


@end
