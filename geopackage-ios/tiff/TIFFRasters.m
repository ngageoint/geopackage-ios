//
//  TIFFRasters.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFRasters.h"

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

-(NSArray *) pixelAtX: (int) x andY: (int) y{
    return nil; // TODO
}

-(void) setPixelAtX: (int) x andY: (int) y withValues: (NSArray *) values{
    // TODO
}

-(NSObject *) pixelSampleAtSample: (int) sample andX: (int) x andY: (int) y{
    return nil; // TODO
}

-(void) setPixelSampleAtSample: (int) sample andX: (int) x andY: (int) y withValue: (NSObject *) value{
    //TODO
}

-(NSObject *) firstPixelSampleAtX: (int) x andY: (int) y{
    return nil; // TODO
}

-(void) setFirstPixelSampleAtX: (int) x andY: (int) y withValue: (NSObject *) value{
    //TODO
}

-(int) sampleIndexAtX: (int) x andY: (int) y{
    return -1; //TODO
}

-(int) interleaveIndexAtX: (int) x andY: (int) y{
    return -1; //TODO
}

-(int) size{
    return -1; // TODO
}

-(int) sizePixel{
    return -1; // TODO
}

-(int) sizeSample: (int) sample{
    return -1; // TODO
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
    // TODO
}

-(void) validateSample: (int) sample{
    // TODO
}

-(int) calculateRowsPerStripWithPlanarConfiguration: (int) planarConfiguration{
    return -1; //TODO
}

-(int) calculateRowsPerStripWithPlanarConfiguration: (int) planarConfiguration andMaxBytesPerStrip: (int) maxBytesPerStrip{
    return -1; //TODO
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
    return -1; // TODO
}

@end
