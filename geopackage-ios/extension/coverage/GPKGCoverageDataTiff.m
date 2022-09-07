//
//  GPKGCoverageDataTiff.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/29/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataTiff.h"
#import "GPKGCoverageDataTiffImage.h"
#import "TIFFConstants.h"
#import "TIFFReader.h"

/**
 * Single sample coverage data
 */
NSInteger const GPKG_TIFF_SAMPLES_PER_PIXEL = 1;

/**
 * Bits per value for floating point coverage data values
 */
NSInteger const GPKG_TIFF_BITS_PER_SAMPLE = 32;

@implementation GPKGCoverageDataTiff

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (PROJProjection *) requestProjection{
    self = [super initWithGeoPackage:geoPackage andTileDao:tileDao andWidth:width andHeight:height andProjection:requestProjection];
    return self;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao{
    return [self initWithGeoPackage:geoPackage andTileDao:tileDao andWidth:nil andHeight:nil andProjection:tileDao.projection];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andProjection: (PROJProjection *) requestProjection{
    return [self initWithGeoPackage:geoPackage andTileDao:tileDao andWidth:nil andHeight:nil andProjection:requestProjection];
}

-(NSObject<GPKGCoverageDataImage> *) createImageWithTileRow: (GPKGTileRow *) tileRow{
    return [[GPKGCoverageDataTiffImage alloc] initWithTileRow:tileRow];
}

-(double) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andTileRow: (GPKGTileRow *) tileRow andX: (int) x andY: (int) y{
    NSData *imageData = [tileRow tileData];
    NSDecimalNumber *value = [self valueWithGriddedTile: griddedTile andData: imageData andX: x andY: y];
    return value.doubleValue;
}

-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andCoverageDataImage: (NSObject<GPKGCoverageDataImage> *) image andX: (int) x andY: (int) y{
    GPKGCoverageDataTiffImage *tiffImage = (GPKGCoverageDataTiffImage *) image;
    NSDecimalNumber *value = [self valueWithGriddedTile:griddedTile andImage:tiffImage andX:x andY:y];
    return value;
}

-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andImage: (GPKGCoverageDataTiffImage *) image andX: (int) x andY: (int) y{
    NSDecimalNumber *value = nil;
    if ([image directory]  != nil) {
        float pixelValue = [image pixelAtX:x andY:y];
        value = [self valueWithGriddedTile:griddedTile andPixelFloatValue:pixelValue];
    } else {
        value = [self valueWithGriddedTile:griddedTile andData:[image imageData] andX:x andY:y];
    }
    return value;
}

-(float) pixelValueWithData: (NSData *) imageData andX: (int) x andY: (int) y{
    
    TIFFImage *tiffImage = [TIFFReader readTiffFromData:imageData];
    TIFFFileDirectory *directory = [tiffImage fileDirectory];
    [GPKGCoverageDataTiff validateImageType:directory];
    TIFFRasters *rasters = [directory readRasters];
    float pixelValue = [[rasters firstPixelSampleAtX:x andY:y] floatValue];

    return pixelValue;
}

-(NSArray *) pixelArrayValuesWithData: (NSData *) imageData{
    TIFFImage *tiffImage = [TIFFReader readTiffFromData:imageData];
    TIFFFileDirectory *directory = [tiffImage fileDirectory];
    [GPKGCoverageDataTiff validateImageType:directory];
    TIFFRasters *rasters = [directory readRasters];
    NSArray *values = [[rasters sampleValues] objectAtIndex:0];
    return values;
}
                     
-(float *) pixelValuesWithData: (NSData *) imageData{
    NSArray *values = [self pixelArrayValuesWithData: imageData];
    float *pixels = [self pixelValuesArrayToFloat:values];
    return pixels;
}
                     
+(void) validateImageType: (TIFFFileDirectory *) directory{
    if (directory == nil) {
        [NSException raise:@"Nil Image" format:@"The image is nil"];
    }
    
    int samplesPerPixel = [directory samplesPerPixel];
    NSNumber *bitsPerSample = nil;
    if ([directory bitsPerSample] != nil && [directory bitsPerSample].count > 0) {
        bitsPerSample = [[directory bitsPerSample] objectAtIndex:0];
    }
    NSNumber *sampleFormat = nil;
    if ([directory sampleFormat] != nil && [directory sampleFormat].count > 0) {
        sampleFormat = [[directory sampleFormat] objectAtIndex:0];
    }
    
    if (samplesPerPixel != GPKG_TIFF_SAMPLES_PER_PIXEL
        || bitsPerSample == nil || [bitsPerSample intValue] != GPKG_TIFF_BITS_PER_SAMPLE
        || sampleFormat == nil || [sampleFormat intValue] != TIFF_SAMPLE_FORMAT_FLOAT) {
        [NSException raise:@"Image Type" format:@"The coverage data tile is expected to be a single sample 32 bit float. Samples Per Pixel: %d, Bits Per Sample: %@, Sample Format: %@", samplesPerPixel, bitsPerSample, sampleFormat];
    }
}

-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andData: (NSData *) imageData andX: (int) x andY: (int) y{
    float pixelValue = [self pixelValueWithData: imageData andX: x andY: y];
    NSDecimalNumber *value = [self valueWithGriddedTile:griddedTile andPixelFloatValue:pixelValue];
    return value;
}

-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andData: (NSData *) imageData{
    NSArray *pixelValuesArray = [self pixelArrayValuesWithData: imageData];
    float *pixelValues = [self pixelValuesArrayToFloat:pixelValuesArray];
    NSArray *values = [self valuesWithGriddedTile:griddedTile andPixelFloatValues:pixelValues andCount:(int)pixelValuesArray.count];
    free(pixelValues);
    return values;
}

-(GPKGCoverageDataTiffImage *) drawTileWithFloatPixelValues: (float *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    
    GPKGCoverageDataTiffImage *image = [self createImageWithTileWidth:tileWidth andTileHeight:tileHeight];
    for (int y = 0; y < tileHeight; y++) {
        for (int x = 0; x < tileWidth; x++) {
            float pixelValue = pixelValues[(y * tileWidth) + x];
            [self setPixelValueWithImage:image andX:x andY:y andPixelValue:pixelValue];
        }
    }
    [image writeTiff];
    
    return image;
}

-(GPKGCoverageDataTiffImage *) drawTileWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    float *pixels = [self pixelValuesArrayToFloat:pixelValues];
    GPKGCoverageDataTiffImage *tileImage = [self drawTileWithFloatPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    GPKGCoverageDataTiffImage *image = [self drawTileWithPixelValues:pixelValues andTileWidth:tileWidth andTileHeight:tileHeight];
    NSData *data = [image imageData];
    return data;
}

-(GPKGCoverageDataTiffImage *) drawTileWithDoubleArrayPixelValues:(NSArray *)pixelValues{
    float *pixels = [self pixelValuesDoubleArrayToFloat:pixelValues];
    int tileWidth = (int)((NSArray *)[pixelValues objectAtIndex: 0]).count;
    int tileHeight = (int)pixelValues.count;
    GPKGCoverageDataTiffImage *tileImage = [self drawTileWithFloatPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithDoubleArrayPixelValues:(NSArray *)pixelValues{
    GPKGCoverageDataTiffImage *image = [self drawTileWithDoubleArrayPixelValues:pixelValues];
    NSData *data = [image imageData];
    return data;
}

-(GPKGCoverageDataTiffImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andValues: (NSArray *) values andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    float *pixels = [self pixelValuesOfValues:values withGriddedTile:griddedTile];
    GPKGCoverageDataTiffImage *tileImage = [self drawTileWithFloatPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andValues: (NSArray *) values andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    GPKGCoverageDataTiffImage *image = [self drawTileWithGriddedTile:griddedTile andValues:values andTileWidth:tileWidth andTileHeight:tileHeight];
    NSData *data = [image imageData];
    return data;
}

-(GPKGCoverageDataTiffImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayValues: (NSArray *) values{
    float *pixels = [self pixelValuesOfDoubleArrayValues:values withGriddedTile:griddedTile];
    int tileWidth = (int)((NSArray *)[values objectAtIndex: 0]).count;
    int tileHeight = (int)values.count;
    GPKGCoverageDataTiffImage *tileImage = [self drawTileWithFloatPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayValues: (NSArray *) values{
    GPKGCoverageDataTiffImage *image = [self drawTileWithGriddedTile:griddedTile andDoubleArrayValues:values];
    NSData *data = [image imageData];
    return data;
}

-(GPKGCoverageDataTiffImage *) createImageWithTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    
    TIFFRasters *rasters = [[TIFFRasters alloc] initWithWidth:tileWidth andHeight:tileHeight andSamplesPerPixel:1 andSingleBitsPerSample:GPKG_TIFF_BITS_PER_SAMPLE];
    
    int rowsPerStrip = [rasters calculateRowsPerStripWithPlanarConfiguration:(int)TIFF_PLANAR_CONFIGURATION_CHUNKY];
    
    TIFFFileDirectory *fileDirectory = [[TIFFFileDirectory alloc] init];
    [fileDirectory setImageWidth: tileWidth];
    [fileDirectory setImageHeight: tileHeight];
    [fileDirectory setBitsPerSampleAsSingleValue: GPKG_TIFF_BITS_PER_SAMPLE];
    [fileDirectory setCompression: TIFF_COMPRESSION_NO];
    [fileDirectory setPhotometricInterpretation: TIFF_PHOTOMETRIC_INTERPRETATION_BLACK_IS_ZERO];
    [fileDirectory setSamplesPerPixel: GPKG_TIFF_SAMPLES_PER_PIXEL];
    [fileDirectory setRowsPerStrip: rowsPerStrip];
    [fileDirectory setPlanarConfiguration: TIFF_PLANAR_CONFIGURATION_CHUNKY];
    [fileDirectory setSampleFormatAsSingleValue: TIFF_SAMPLE_FORMAT_FLOAT];
    [fileDirectory setWriteRasters: rasters];
    
    GPKGCoverageDataTiffImage *image = [[GPKGCoverageDataTiffImage alloc] initWithFileDirectory: fileDirectory];
    
    return image;
}

-(void) setPixelValueWithImage: (GPKGCoverageDataTiffImage *) image andX: (int) x andY: (int) y andPixelValue: (float) pixelValue{
    [[image rasters] setFirstPixelSampleAtX:x andY:y withValue:[[NSDecimalNumber alloc] initWithFloat:pixelValue]];
}

-(float) pixelIn: (float *) pixels withWidth: (int) width atX: (int) x andY: (int) y{
    return pixels[(y * width) + x];
}

-(NSArray *) pixelValuesFloatToArray: (float *) pixelValues withCount: (int) count{
    NSMutableArray *pixels = [NSMutableArray arrayWithCapacity:count];
    for(int i= 0; i < count; i++){
        float pixel = pixelValues[i];
        [pixels addObject:[NSNumber numberWithFloat:pixel]];
    }
    return pixels;
}

-(float *) pixelValuesArrayToFloat: (NSArray *) pixelValues{
    float *pixels = [self allocatePixelsWithCount:(int)pixelValues.count];
    for(int i = 0; i < pixelValues.count; i++){
        NSNumber *pixel = [pixelValues objectAtIndex:i];
        pixels[i] = [pixel floatValue];
    }
    return pixels;
}

-(float *) pixelValuesDoubleArrayToFloat: (NSArray *) pixelValues{
    
    int tileWidth = (int)((NSArray *)[pixelValues objectAtIndex: 0]).count;
    int tileHeight = (int)pixelValues.count;
    
    float *pixels = [self allocatePixelsWithWidth:tileWidth andHeight:tileHeight];
    for(int y = 0; y < tileHeight; y++){
        NSArray *rowValues = [pixelValues objectAtIndex:y];
        for(int x = 0; x < tileWidth; x++){
            NSNumber *pixel = [rowValues objectAtIndex:x];
            pixels[(y * tileWidth) + x] = [pixel floatValue];
        }
    }
    return pixels;
}

-(float *) pixelValuesOfValues: (NSArray *) values withGriddedTile: (GPKGGriddedTile *) griddedTile{
    float *pixels = [self allocatePixelsWithCount:(int)values.count];
    for(int i = 0; i < values.count; i++){
        NSDecimalNumber *value = [values objectAtIndex:i];
        float pixelValue = [self pixelValueWithGriddedTile:griddedTile andValue:value];
        pixels[i] = pixelValue;
    }
    return pixels;
}

-(float *) pixelValuesOfDoubleArrayValues: (NSArray *) values withGriddedTile: (GPKGGriddedTile *) griddedTile{
    
    int tileWidth = (int)((NSArray *)[values objectAtIndex: 0]).count;
    int tileHeight = (int)values.count;
    
    float *pixels = [self allocatePixelsWithWidth:tileWidth andHeight:tileHeight];
    for(int y = 0; y < tileHeight; y++){
        NSArray *rowValues = [values objectAtIndex:y];
        for(int x = 0; x < tileWidth; x++){
            NSDecimalNumber *value = [rowValues objectAtIndex:x];
            float pixelValue = [self pixelValueWithGriddedTile:griddedTile andValue:value];
            pixels[(y * tileWidth) + x] = pixelValue;
        }
    }
    return pixels;
}

-(float *) allocatePixelsWithWidth: (int) width andHeight: (int) height{
    return [self allocatePixelsWithCount:width * height];
}

-(float *) allocatePixelsWithCount: (int) count{
    return calloc(count, sizeof(float));
}

+(GPKGCoverageDataTiff *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andMetadata: (GPKGTileTableMetadata *) metadata{
    return (GPKGCoverageDataTiff *) [GPKGCoverageData createTileTableWithGeoPackage:geoPackage andMetadata:metadata andDataType:GPKG_GCDT_FLOAT];
}

@end
