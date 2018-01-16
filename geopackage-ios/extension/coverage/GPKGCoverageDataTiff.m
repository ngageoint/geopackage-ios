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
 * Single sample elevation
 */
NSInteger const GPKG_TIFF_SAMPLES_PER_PIXEL = 1;

/**
 * Bits per value for floating point elevations
 */
NSInteger const GPKG_TIFF_BITS_PER_SAMPLE = 32;

@implementation GPKGCoverageDataTiff

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

-(NSObject<GPKGCoverageDataImage> *) createElevationImageWithTileRow: (GPKGTileRow *) tileRow{
    return [[GPKGCoverageDataTiffImage alloc] initWithTileRow:tileRow];
}

-(double) elevationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andTileRow: (GPKGTileRow *) tileRow andX: (int) x andY: (int) y{
    NSData * imageData = [tileRow getTileData];
    NSDecimalNumber * elevation = [self elevationValueWithGriddedTile: griddedTile andData: imageData andX: x andY: y];
    return elevation.doubleValue;
}

-(NSDecimalNumber *) elevationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevationImage: (NSObject<GPKGCoverageDataImage> *) image andX: (int) x andY: (int) y{
    GPKGCoverageDataTiffImage * tiffImage = (GPKGCoverageDataTiffImage *) image;
    NSDecimalNumber * elevation = [self elevationValueWithGriddedTile:griddedTile andImage:tiffImage andX:x andY:y];
    return elevation;
}

-(NSDecimalNumber *) elevationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andImage: (GPKGCoverageDataTiffImage *) image andX: (int) x andY: (int) y{
    NSDecimalNumber * elevation = nil;
    if ([image directory]  != nil) {
        float pixelValue = [image pixelAtX:x andY:y];
        elevation = [self elevationValueWithGriddedTile:griddedTile andPixelFloatValue:pixelValue];
    } else {
        elevation = [self elevationValueWithGriddedTile:griddedTile andData:[image imageData] andX:x andY:y];
    }
    return elevation;
}

-(float) pixelValueWithData: (NSData *) imageData andX: (int) x andY: (int) y{
    
    TIFFImage * tiffImage = [TIFFReader readTiffFromData:imageData];
    TIFFFileDirectory * directory = [tiffImage fileDirectory];
    [GPKGCoverageDataTiff validateImageType:directory];
    TIFFRasters * rasters = [directory readRasters];
    float pixelValue = [[rasters firstPixelSampleAtX:x andY:y] floatValue];

    return pixelValue;
}

-(NSArray *) pixelArrayValuesWithData: (NSData *) imageData{
    TIFFImage * tiffImage = [TIFFReader readTiffFromData:imageData];
    TIFFFileDirectory * directory = [tiffImage fileDirectory];
    [GPKGCoverageDataTiff validateImageType:directory];
    TIFFRasters * rasters = [directory readRasters];
    NSArray * values = [[rasters sampleValues] objectAtIndex:0];
    return values;
}
                     
-(float *) pixelValuesWithData: (NSData *) imageData{
    NSArray * values = [self pixelArrayValuesWithData: imageData];
    float *pixels = [self pixelValuesArrayToFloat:values];
    return pixels;
}
                     
+(void) validateImageType: (TIFFFileDirectory *) directory{
    if (directory == nil) {
        [NSException raise:@"Nil Image" format:@"The image is nil"];
    }
    
    int samplesPerPixel = [directory samplesPerPixel];
    NSNumber * bitsPerSample = nil;
    if ([directory bitsPerSample] != nil && [directory bitsPerSample].count > 0) {
        bitsPerSample = [[directory bitsPerSample] objectAtIndex:0];
    }
    NSNumber * sampleFormat = nil;
    if ([directory sampleFormat] != nil && [directory sampleFormat].count > 0) {
        sampleFormat = [[directory sampleFormat] objectAtIndex:0];
    }
    
    if (samplesPerPixel != GPKG_TIFF_SAMPLES_PER_PIXEL
        || bitsPerSample == nil || [bitsPerSample intValue] != GPKG_TIFF_BITS_PER_SAMPLE
        || sampleFormat == nil || [sampleFormat intValue] != TIFF_SAMPLE_FORMAT_FLOAT) {
        [NSException raise:@"Image Type" format:@"The elevation tile is expected to be a single sample 32 bit float. Samples Per Pixel: %d, Bits Per Sample: %@, Sample Format: %@", samplesPerPixel, bitsPerSample, sampleFormat];
    }
}

-(NSDecimalNumber *) elevationValueWithGriddedTile:(GPKGGriddedTile *)griddedTile andData:(NSData *)imageData andX:(int)x andY:(int)y{
    float pixelValue = [self pixelValueWithData: imageData andX: x andY: y];
    NSDecimalNumber * elevation = [self elevationValueWithGriddedTile:griddedTile andPixelValue:pixelValue];
    return elevation;
}

-(NSArray *) elevationValuesWithGriddedTile:(GPKGGriddedTile *)griddedTile andData:(NSData *)imageData{
    NSArray * values = [self pixelArrayValuesWithData: imageData];
    float *pixelValues = [self pixelValuesArrayToFloat:values];
    NSArray * elevations = [self elevationValuesWithGriddedTile:griddedTile andPixelFloatValues:pixelValues andCount:(int)values.count];
    free(pixelValues);
    return elevations;
}

-(GPKGCoverageDataTiffImage *) drawTileWithFloatPixelValues: (float *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    
    GPKGCoverageDataTiffImage * image = [self createImageWithTileWidth:tileWidth andTileHeight:tileHeight];
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
    float * pixels = [self pixelValuesArrayToFloat:pixelValues];
    GPKGCoverageDataTiffImage * tileImage = [self drawTileWithFloatPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithPixelValues: (NSArray *) pixelValues andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    GPKGCoverageDataTiffImage * image = [self drawTileWithPixelValues:pixelValues andTileWidth:tileWidth andTileHeight:tileHeight];
    NSData * data = [image imageData];
    return data;
}

-(GPKGCoverageDataTiffImage *) drawTileWithDoubleArrayPixelValues:(NSArray *)pixelValues{
    float * pixels = [self pixelValuesDoubleArrayToFloat:pixelValues];
    int tileWidth = (int)((NSArray *)[pixelValues objectAtIndex: 0]).count;
    int tileHeight = (int)pixelValues.count;
    GPKGCoverageDataTiffImage * tileImage = [self drawTileWithFloatPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithDoubleArrayPixelValues:(NSArray *)pixelValues{
    GPKGCoverageDataTiffImage * image = [self drawTileWithDoubleArrayPixelValues:pixelValues];
    NSData * data = [image imageData];
    return data;
}

-(GPKGCoverageDataTiffImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevations: (NSArray *) elevations andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    float * pixels = [self pixelValuesOfElevations:elevations withGriddedTile:griddedTile];
    GPKGCoverageDataTiffImage * tileImage = [self drawTileWithFloatPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevations: (NSArray *) elevations andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    GPKGCoverageDataTiffImage * image = [self drawTileWithGriddedTile:griddedTile andElevations:elevations andTileWidth:tileWidth andTileHeight:tileHeight];
    NSData * data = [image imageData];
    return data;
}

-(GPKGCoverageDataTiffImage *) drawTileWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayElevations: (NSArray *) elevations{
    float * pixels = [self pixelValuesOfDoubleArrayElevations:elevations withGriddedTile:griddedTile];
    int tileWidth = (int)((NSArray *)[elevations objectAtIndex: 0]).count;
    int tileHeight = (int)elevations.count;
    GPKGCoverageDataTiffImage * tileImage = [self drawTileWithFloatPixelValues:pixels andTileWidth:tileWidth andTileHeight:tileHeight];
    free(pixels);
    return tileImage;
}

-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayElevations: (NSArray *) elevations{
    GPKGCoverageDataTiffImage * image = [self drawTileWithGriddedTile:griddedTile andDoubleArrayElevations:elevations];
    NSData * data = [image imageData];
    return data;
}

-(GPKGCoverageDataTiffImage *) createImageWithTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    
    TIFFRasters * rasters = [[TIFFRasters alloc] initWithWidth:tileWidth andHeight:tileHeight andSamplesPerPixel:1 andSingleBitsPerSample:GPKG_TIFF_BITS_PER_SAMPLE];
    
    int rowsPerStrip = [rasters calculateRowsPerStripWithPlanarConfiguration:(int)TIFF_PLANAR_CONFIGURATION_CHUNKY];
    
    TIFFFileDirectory * fileDirectory = [[TIFFFileDirectory alloc] init];
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
    
    GPKGCoverageDataTiffImage * image = [[GPKGCoverageDataTiffImage alloc] initWithFileDirectory: fileDirectory];
    
    return image;
}

-(void) setPixelValueWithImage: (GPKGCoverageDataTiffImage *) image andX: (int) x andY: (int) y andPixelValue: (float) pixelValue{
    [[image rasters] setFirstPixelSampleAtX:x andY:y withValue:[[NSDecimalNumber alloc] initWithFloat:pixelValue]];
}

-(float) pixelIn: (float *) pixels withWidth: (int) width atX: (int) x andY: (int) y{
    return pixels[(y * width) + x];
}

-(NSArray *) pixelValuesFloatToArray: (float *) pixelValues withCount: (int) count{
    NSMutableArray * pixels = [[NSMutableArray alloc] initWithCapacity:count];
    for(int i= 0; i < count; i++){
        float pixel = pixelValues[i];
        [pixels addObject:[NSNumber numberWithFloat:pixel]];
    }
    return pixels;
}

-(float *) pixelValuesArrayToFloat: (NSArray *) pixelValues{
    float * pixels = [self allocatePixelsWithCount:(int)pixelValues.count];
    for(int i = 0; i < pixelValues.count; i++){
        NSNumber * pixel = [pixelValues objectAtIndex:i];
        pixels[i] = [pixel floatValue];
    }
    return pixels;
}

-(float *) pixelValuesDoubleArrayToFloat: (NSArray *) pixelValues{
    
    int tileWidth = (int)((NSArray *)[pixelValues objectAtIndex: 0]).count;
    int tileHeight = (int)pixelValues.count;
    
    float * pixels = [self allocatePixelsWithWidth:tileWidth andHeight:tileHeight];
    for(int y = 0; y < tileHeight; y++){
        NSArray * rowValues = [pixelValues objectAtIndex:y];
        for(int x = 0; x < tileWidth; x++){
            NSNumber * pixel = [rowValues objectAtIndex:x];
            pixels[(y * tileWidth) + x] = [pixel floatValue];
        }
    }
    return pixels;
}

-(float *) pixelValuesOfElevations: (NSArray *) elevations withGriddedTile: (GPKGGriddedTile *) griddedTile{
    float * pixels = [self allocatePixelsWithCount:(int)elevations.count];
    for(int i = 0; i < elevations.count; i++){
        NSDecimalNumber * elevation = [elevations objectAtIndex:i];
        float pixelValue = [self pixelValueWithGriddedTile:griddedTile andElevation:elevation];
        pixels[i] = pixelValue;
    }
    return pixels;
}

-(float *) pixelValuesOfDoubleArrayElevations: (NSArray *) elevations withGriddedTile: (GPKGGriddedTile *) griddedTile{
    
    int tileWidth = (int)((NSArray *)[elevations objectAtIndex: 0]).count;
    int tileHeight = (int)elevations.count;
    
    float * pixels = [self allocatePixelsWithWidth:tileWidth andHeight:tileHeight];
    for(int y = 0; y < tileHeight; y++){
        NSArray * rowValues = [elevations objectAtIndex:y];
        for(int x = 0; x < tileWidth; x++){
            NSDecimalNumber * elevation = [rowValues objectAtIndex:x];
            float pixelValue = [self pixelValueWithGriddedTile:griddedTile andElevation:elevation];
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

+(GPKGCoverageDataTiff *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId{
    
    GPKGTileMatrixSet * tileMatrixSet = [GPKGCoverageDataCore createTileTableWithGeoPackage:geoPackage andTableName:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileMatrixSetBoundingBox:tileMatrixSetBoundingBox andTileMatrixSetSrsId:tileMatrixSetSrsId];
    
    GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
    GPKGCoverageDataTiff * coverageData = [[GPKGCoverageDataTiff alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
    [coverageData getOrCreate];
    
    return coverageData;
}

@end
