//
//  TIFFRasters.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFRasters.h"
#import "TIFFConstants.h"

@interface TIFFRasters()

/**
 * Width of pixels
 */
@property (nonatomic) int width;

/**
 * Height of pixels
 */
@property (nonatomic) int height;

/**
 * Samples of pixels
 */
@property (nonatomic) int samplesPerPixel;

/**
 * Bits per sample
 */
@property (nonatomic, strong) NSMutableArray<NSNumber *> *bitsPerSample;

/**
 * Values separated by sample
 */
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *sampleValues;

/**
 * Interleaved pixel sample values
 */
@property (nonatomic, strong) NSMutableArray *interleaveValues;

@end

@implementation TIFFRasters

-(instancetype) initWithWidth: (int) width andHeight: (int) height andSamplesPerPixel: (int) samplesPerPixel andBitsPerSample: (NSMutableArray<NSNumber *> *) bitsPerSample andSampleValues: (NSMutableArray<NSMutableArray *> *) sampleValues{
    return [self initWithWidth:width andHeight:height andSamplesPerPixel:samplesPerPixel andBitsPerSample:bitsPerSample andSampleValues:sampleValues andInterleaveValues:nil];
}
-(instancetype) initWithWidth: (int) width andHeight: (int) height andSamplesPerPixel: (int) samplesPerPixel andBitsPerSample: (NSMutableArray<NSNumber *> *) bitsPerSample andInterleaveValues: (NSMutableArray *) interleaveValues{
    return [self initWithWidth:width andHeight:height andSamplesPerPixel:samplesPerPixel andBitsPerSample:bitsPerSample andSampleValues:nil andInterleaveValues:interleaveValues];
}
-(instancetype) initWithWidth: (int) width andHeight: (int) height andSamplesPerPixel: (int) samplesPerPixel andBitsPerSample: (NSMutableArray<NSNumber *> *) bitsPerSample andSampleValues: (NSMutableArray<NSMutableArray *> *) sampleValues andInterleaveValues: (NSMutableArray *) interleaveValues{
    self = [super init];
    if(self != nil){
        self.width = width;
        self.height = height;
        self.samplesPerPixel = samplesPerPixel;
        self.bitsPerSample = bitsPerSample;
        self.interleaveValues = interleaveValues;
        [self validateValues];
        for (NSNumber * bits in bitsPerSample) {
            if (([bits intValue] % 8) != 0) {
                [NSException raise:@"Not Supported" format:@"Sample bit-width of %d is not supported", [bits intValue]];
            }
        }
    }
    return self;
}

-(instancetype) initWithWidth: (int) width andHeight: (int) height andSamplesPerPixel: (int) samplesPerPixel andBitsPerSample: (NSMutableArray<NSNumber *> *) bitsPerSample{
    return [self initWithWidth:width andHeight:height andSamplesPerPixel:samplesPerPixel andBitsPerSample:bitsPerSample andSampleValues:[TIFFRasters createEmptySampleValuesWithSamplesPerPixel:samplesPerPixel andWidth:width andHeight:height]];
}

-(instancetype) initWithWidth: (int) width andHeight: (int) height andSamplesPerPixel: (int) samplesPerPixel andSingleBitsPerSample: (int) bitsPerSample{
    return [self initWithWidth:width andHeight:height andSamplesPerPixel:samplesPerPixel andBitsPerSample:[[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:bitsPerSample], nil]];
}

-(void) validateValues{
    if(self.sampleValues != nil && self.interleaveValues != nil){
        [NSException raise:@"Invalid Results" format:@"Results must be sample and/or interleave based"];
    }
}

-(BOOL) hasSampleValues{
    return self.sampleValues != nil;
}

-(BOOL) hasInterleaveValues{
    return self.interleaveValues != nil;
}

-(void) addSampleValue: (NSObject *) value toIndex: (int) sampleIndex andCoordinate: (int) coordinate{
    [[_sampleValues objectAtIndex:sampleIndex] replaceObjectAtIndex:coordinate withObject:value];
}

-(void) addInterleaveValue: (NSObject *) value toCoordinate: (int) coordinate{
    [_interleaveValues replaceObjectAtIndex:coordinate withObject:value];
}

-(int) width{
    return _width;
}

-(int) height{
    return _height;
}

-(int) numPixels{
    return _width * _height;
}

-(int) samplesPerPixel{
    return _samplesPerPixel;
}

-(NSArray<NSNumber *> *) bitsPerSample{
    return _bitsPerSample;
}

-(NSArray<NSArray *> *) sampleValues{
    return _sampleValues;
}

-(void) setSampleValuesAndValidate: (NSMutableArray<NSMutableArray *> *) sampleValues{
    _sampleValues = sampleValues;
    [self validateValues];
}

-(NSArray *) interleaveValues{
    return _interleaveValues;
}

-(void) setInterleaveValuesAndValidate: (NSMutableArray *) interleaveValues{
    _interleaveValues = interleaveValues;
    [self validateValues];
}

/**
 * Get the sample value for the sample and index
 *
 * @param sample
 *            pixel sample
 * @param index
 *            pixel index
 * @return value
 */
-(NSNumber *) sampleValueAtSample: (int) sample andIndex: (int) index{
    NSArray * singleSampleValues = [self.sampleValues objectAtIndex:sample];
    NSObject * objectValue = [singleSampleValues objectAtIndex:index];
    NSNumber * value = [self numberValue: objectValue];
    return value;
}

/**
 * Get the interleave value for the index
 *
 * @param index
 *            pixel index
 * @return value
 */
-(NSNumber *) interleaveValueAtIndex: (int) index{
    NSObject * objectValue = [self.interleaveValues objectAtIndex:index];
    NSNumber * value = [self numberValue: objectValue];
    return value;
}

/**
 * Get the number value from the object value if not null
 *
 * @param objectValue
 *            object value
 * @return value
 */
-(NSNumber *) numberValue: (NSObject *) objectValue{
    NSNumber * value = nil;
    if(objectValue != nil && ![objectValue isEqual:[NSNull null]]){
        value = (NSNumber *) objectValue;
    }
    return value;
}

-(NSArray *) pixelAtX: (int) x andY: (int) y{
    
    [self validateCoordinatesAtX:x andY:y];
    
    // Pixel with each sample value
    NSMutableArray * pixel = [[NSMutableArray alloc] initWithCapacity:self.samplesPerPixel];
    
    // Get the pixel values from each sample
    if (self.sampleValues != nil) {
        int sampleIndex = [self sampleIndexAtX:x andY:y];
        for (int i = 0; i < self.samplesPerPixel; i++) {
            [pixel addObject:[self sampleValueAtSample:i andIndex:sampleIndex]];
        }
    } else {
        int interleaveIndex = [self interleaveIndexAtX:x andY:y];
        for (int i = 0; i < self.samplesPerPixel; i++) {
            [pixel addObject: [self interleaveValueAtIndex:interleaveIndex++]];
        }
    }
    
    return pixel;
}

-(void) setPixelAtX: (int) x andY: (int) y withValues: (NSArray *) values{
    
    [self validateCoordinatesAtX:x andY:y];
    [self validateSample:(int)values.count + 1];
    
    // Set the pixel values from each sample
    if (self.sampleValues != nil) {
        int sampleIndex = [self sampleIndexAtX:x andY:y];
        for (int i = 0; i < self.samplesPerPixel; i++) {
            NSMutableArray * singleSampleValues = [_sampleValues objectAtIndex:i];
            [singleSampleValues replaceObjectAtIndex:sampleIndex withObject:[values objectAtIndex: i]];
        }
    } else {
        int interleaveIndex = [self interleaveIndexAtX:x andY:y];
        for (int i = 0; i < self.samplesPerPixel; i++) {
            [_interleaveValues replaceObjectAtIndex:interleaveIndex++ withObject:[values objectAtIndex: i]];
        }
    }
}

-(NSObject *) pixelSampleAtSample: (int) sample andX: (int) x andY: (int) y{
    
    [self validateCoordinatesAtX:x andY:y];
    [self validateSample:sample];
    
    // Pixel sample value
    NSNumber * pixelSample = nil;
    
    // Get the pixel sample
    if (self.sampleValues != nil) {
        int sampleIndex = [self sampleIndexAtX:x andY:y];
        pixelSample = [self sampleValueAtSample:sample andIndex:sampleIndex];
    } else {
        int interleaveIndex = [self interleaveIndexAtX:x andY:y];
        pixelSample = [self interleaveValueAtIndex:interleaveIndex + sample];
    }
    
    return pixelSample;
}

-(void) setPixelSampleAtSample: (int) sample andX: (int) x andY: (int) y withValue: (NSObject *) value{
    
    [self validateCoordinatesAtX:x andY:y];
    [self validateSample:sample];
    
    // Set the pixel sample
    if (self.sampleValues != nil) {
        int sampleIndex = [self sampleIndexAtX:x andY:y];
        NSMutableArray * singleSampleValues = [_sampleValues objectAtIndex:sample];
        [singleSampleValues replaceObjectAtIndex:sampleIndex withObject:value];
    }
    if (self.interleaveValues != nil) {
        int interleaveIndex = [self interleaveIndexAtX:x andY:y];
        [_interleaveValues replaceObjectAtIndex:interleaveIndex + sample withObject:value];
    }
}

-(NSObject *) firstPixelSampleAtX: (int) x andY: (int) y{
    return [self pixelSampleAtSample:0 andX:x andY:y];
}

-(void) setFirstPixelSampleAtX: (int) x andY: (int) y withValue: (NSObject *) value{
    [self setPixelSampleAtSample:0 andX:x andY:y withValue:value];
}

-(int) sampleIndexAtX: (int) x andY: (int) y{
    return y * self.width + x;
}

-(int) interleaveIndexAtX: (int) x andY: (int) y{
    return (y * self.width * self.samplesPerPixel) + (x * self.samplesPerPixel);
}

-(int) size{
    return [self numPixels] * [self sizePixel];
}

-(int) sizePixel{
    int size = 0;
    for (int i = 0; i < self.samplesPerPixel; i++) {
        size += [self sizeSample:i];
    }
    return size;
}

-(int) sizeSample: (int) sample{
    return [[self.bitsPerSample objectAtIndex:sample] intValue] / 8;
}

/**
 * Validate the coordinates range
 *
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 */
-(void) validateCoordinatesAtX: (int) x andY: (int) y{
    if (x < 0 || x >= self.width || y < 0 || y > self.height) {
        [NSException raise:@"Pixel Out Of Bounds" format:@"Pixel outside of raster range. Width: %d, Height: %d, x: %d, y: %d", self.width, self.height, x, y];
    }
}

/**
 * Validate the sample index
 *
 * @param sample
 *            sample index
 */
-(void) validateSample: (int) sample{
    if (sample < 0 || sample >= self.samplesPerPixel) {
        [NSException raise:@"Pixel Sample Out Of Bounds" format:@"Pixel sample out of bounds. sample: %d, samples per pixel: %d", sample, self.samplesPerPixel];
    }
}

-(int) calculateRowsPerStripWithPlanarConfiguration: (int) planarConfiguration{
    return [self calculateRowsPerStripWithPlanarConfiguration:planarConfiguration andMaxBytesPerStrip:(int)TIFF_DEFAULT_MAX_BYTES_PER_STRIP];
}

-(int) calculateRowsPerStripWithPlanarConfiguration: (int) planarConfiguration andMaxBytesPerStrip: (int) maxBytesPerStrip{
    
    NSNumber * rowsPerStrip = nil;
    
    if (planarConfiguration == TIFF_PLANAR_CONFIGURATION_CHUNKY) {
        int bitsPerPixel = 0;
        for (NSNumber * sampleBits in self.bitsPerSample) {
            bitsPerPixel += [sampleBits intValue];
        }
        rowsPerStrip = [NSNumber numberWithInt:[self rowsPerStripWithBitsPerPixel:bitsPerPixel andMaxBytesPerStrip:maxBytesPerStrip]];
    } else {
        
        for (NSNumber * sampleBits in self.bitsPerSample) {
            int rowsPerStripForSample = [self rowsPerStripWithBitsPerPixel:[sampleBits intValue] andMaxBytesPerStrip:maxBytesPerStrip];
            if (rowsPerStrip == nil || rowsPerStripForSample < [rowsPerStrip intValue]) {
                rowsPerStrip = [NSNumber numberWithInt:rowsPerStripForSample];
            }
        }
    }
    
    return [rowsPerStrip intValue];
}

+(NSMutableArray<NSMutableArray *> *) createEmptySampleValuesWithSamplesPerPixel: (int) samplesPerPixel andWidth: (int) width andHeight: (int) height{
    return [self createEmptySampleValuesWithSamplesPerPixel:samplesPerPixel andPixels:width * height];
}

+(NSMutableArray<NSMutableArray *> *) createEmptySampleValuesWithSamplesPerPixel: (int) samplesPerPixel andPixels: (int) pixels{
    NSMutableArray<NSMutableArray *> * sampleValues = [[NSMutableArray alloc] initWithCapacity:samplesPerPixel];
    for(int i = 0; i < samplesPerPixel; i++){
        NSMutableArray * samplePixels = [[NSMutableArray alloc] initWithCapacity:pixels];
        for(int j = 0; j < pixels; j++){
            [samplePixels addObject:[NSNull null]];
        }
        [sampleValues addObject:samplePixels];
    }
    return sampleValues;
}

+(NSMutableArray *) createEmptyInterleaveValuesWithSamplesPerPixel: (int) samplesPerPixel andWidth: (int) width andHeight: (int) height{
    return [self createEmptyInterleaveValuesWithSamplesPerPixel:samplesPerPixel andPixels:width * height];
}

+(NSMutableArray *) createEmptyInterleaveValuesWithSamplesPerPixel: (int) samplesPerPixel andPixels: (int) pixels{
    int count = samplesPerPixel * pixels;
    NSMutableArray * interleaveValues = [[NSMutableArray alloc] initWithCapacity:count];
    for(int i = 0; i < count; i++){
        [interleaveValues addObject:[NSNull null]];
    }
    return interleaveValues;
}

-(int) rowsPerStripWithBitsPerPixel: (int) bitsPerPixel andMaxBytesPerStrip: (int) maxBytesPerStrip{
    
    int bytesPerPixel = ceil(bitsPerPixel / 8.0);
    int bytesPerRow = bytesPerPixel * self.width;
    
    int rowsPerStrip = MAX(1, maxBytesPerStrip / bytesPerRow);
    
    return rowsPerStrip;
}

@end
