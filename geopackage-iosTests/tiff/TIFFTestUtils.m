//
//  TIFFTestUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFTestUtils.h"

#define ARC4RANDOM_MAX      0x100000000

@implementation TIFFTestUtils

+(void)assertNil:(id) value{
    if(value != nil){
        [NSException raise:@"Assert Nil" format:@"Value is not nil: %@", value];
    }
}

+(void)assertNotNil:(id) value{
    if(value == nil){
        [NSException raise:@"Assert Not Nil" format:@"Value is nil: %@", value];
    }
}

+(void)assertTrue: (BOOL) value{
    if(!value){
        [NSException raise:@"Assert True" format:@"Value is false"];
    }
}

+(void)assertFalse: (BOOL) value{
    if(value){
        [NSException raise:@"Assert False" format:@"Value is true"];
    }
}

+(void)assertEqualWithValue:(NSObject *) value andValue2: (NSObject *) value2{
    if(value == nil){
        if(value2 != nil){
            [NSException raise:@"Assert Equal" format:@"Value 1: '%@' is not equal to Value 2: '%@'", value, value2];
        }
    } else if(![value isEqual:value2]){
        [NSException raise:@"Assert Equal" format:@"Value 1: '%@' is not equal to Value 2: '%@'", value, value2];
    }
}

+(void)assertEqualBoolWithValue:(BOOL) value andValue2: (BOOL) value2{
    if(value != value2){
        [NSException raise:@"Assert Equal BOOL" format:@"Value 1: '%d' is not equal to Value 2: '%d'", value, value2];
    }
}

+(void)assertEqualIntWithValue:(int) value andValue2: (int) value2{
    if(value != value2){
        [NSException raise:@"Assert Equal int" format:@"Value 1: '%d' is not equal to Value 2: '%d'", value, value2];
    }
}

+(void)assertEqualDoubleWithValue:(double) value andValue2: (double) value2{
    if(value != value2){
        [NSException raise:@"Assert Equal double" format:@"Value 1: '%f' is not equal to Value 2: '%f'", value, value2];
    }
}

+(NSDecimalNumber *) roundDouble: (double) value{
    return [self roundDouble:value withScale:1];
}

+(NSDecimalNumber *) roundDouble: (double) value withScale: (int) scale{
    NSDecimalNumberHandler *rounder = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:scale raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    return [[[NSDecimalNumber alloc] initWithDouble:value] decimalNumberByRoundingAccordingToBehavior:rounder];
}

+(int) randomIntLessThan: (int) max{
    return arc4random() % max;
}

+(double) randomDouble{
    return ((double)arc4random() / ARC4RANDOM_MAX);
}

+(double) randomDoubleLessThan: (double) max{
    return [self randomDouble] * max;
}

+(BOOL) coinFlip{
    return [self randomDouble] < .5;
}

+(void) compareTIFFImagesWithImage1: (TIFFImage *) tiffImage1 andImage2: (TIFFImage *) tiffImage2{
    [self compareTIFFImagesWithImage1:tiffImage1 andImage2:tiffImage2 andExactType:true andSameBitsPerSample:true];
}

+(void) compareTIFFImagesWithImage1: (TIFFImage *) tiffImage1 andImage2: (TIFFImage *) tiffImage2 andExactType: (BOOL) exactType andSameBitsPerSample: (BOOL) sameBitsPerSample{
    
    [self assertNotNil:tiffImage1];
    [self assertNotNil:tiffImage2];
    [self assertEqualIntWithValue:(int)[tiffImage1 fileDirectories].count andValue2:(int)[tiffImage2 fileDirectories].count];
    for (int i = 0; i < [tiffImage1 fileDirectories].count; i++) {
        TIFFFileDirectory * fileDirectory1 = [tiffImage1 fileDirectoryAtIndex:i];
        TIFFFileDirectory * fileDirectory2 = [tiffImage2 fileDirectoryAtIndex:i];
        
        TIFFRasters * sampleRasters1 = [fileDirectory1 readRasters];
        [self compareFileDirectory:fileDirectory1 andRastersMetadata:sampleRasters1];
        TIFFRasters * sampleRasters2 = [fileDirectory2 readRasters];
        [self compareFileDirectory:fileDirectory2 andRastersMetadata:sampleRasters2];
        [self compareRastersSampleValuesWithRasters1:sampleRasters1 andRasters2:sampleRasters2 andExactType:exactType andSameBitsPerSample:sameBitsPerSample];
        
        TIFFRasters * interleaveRasters1 = [fileDirectory1 readInterleavedRasters];
        [self compareFileDirectory:fileDirectory1 andRastersMetadata:interleaveRasters1];
        TIFFRasters * interleaveRasters2 = [fileDirectory2 readInterleavedRasters];
        [self compareFileDirectory:fileDirectory2 andRastersMetadata:interleaveRasters2];
        [self compareRastersSampleValuesWithRasters1:interleaveRasters1 andRasters2:interleaveRasters2 andExactType:exactType andSameBitsPerSample:sameBitsPerSample];
        
        [self compareRastersWithFileDirectory1:fileDirectory1 andRasters1:sampleRasters1 andFileDirectory2:fileDirectory2 andRasters2:interleaveRasters2 andExactType:exactType andSameBitsPerSample:sameBitsPerSample];
        [self compareRastersWithFileDirectory1:fileDirectory1 andRasters1:interleaveRasters1 andFileDirectory2:fileDirectory2 andRasters2:sampleRasters2 andExactType:exactType andSameBitsPerSample:sameBitsPerSample];
    }
    
}

/**
 * Compare the metadata between a file directory and rasters
 *
 * @param fileDirectory
 *            file directory
 * @param rasters
 *            rasters
 */
+(void) compareFileDirectory: (TIFFFileDirectory *) fileDirectory andRastersMetadata: (TIFFRasters *) rasters{
    [self assertEqualIntWithValue:[[fileDirectory imageWidth] intValue] andValue2:[rasters width]];
    [self assertEqualIntWithValue:[[fileDirectory imageHeight] intValue] andValue2:[rasters height]];
    [self assertEqualIntWithValue:[[fileDirectory samplesPerPixel] intValue] andValue2:[rasters samplesPerPixel]];
    [self assertEqualIntWithValue:(int)[fileDirectory bitsPerSample].count andValue2:(int)[rasters bitsPerSample].count];
    for (int i = 0; i < [fileDirectory bitsPerSample].count; i++) {
        [self assertEqualWithValue:[[fileDirectory bitsPerSample] objectAtIndex:i] andValue2:[[rasters bitsPerSample] objectAtIndex:i]];
    }
}

+(void) compareRastersSampleValuesWithRasters1: (TIFFRasters *) rasters1 andRasters2: (TIFFRasters *) rasters2{
    [self compareRastersSampleValuesWithRasters1:rasters1 andRasters2:rasters2 andExactType:true andSameBitsPerSample:true];
}

+(void) compareRastersSampleValuesWithRasters1: (TIFFRasters *) rasters1 andRasters2: (TIFFRasters *) rasters2 andExactType: (BOOL) exactType andSameBitsPerSample: (BOOL) sameBitsPerSample{
    
    [self compareRastersMetadataWithRasters1:rasters1 andRasters2:rasters2 andSameBitsPerSample:sameBitsPerSample];
    
    [self assertNotNil:[rasters1 sampleValues]];
    [self assertNotNil:[rasters2 sampleValues]];
    [self assertEqualIntWithValue:(int)[rasters1 sampleValues].count andValue2:(int)[rasters2 sampleValues].count];
    
    for (int i = 0; i < [rasters1 sampleValues].count; i++) {
        [self assertEqualIntWithValue:(int)[[rasters1 sampleValues] objectAtIndex:i].count andValue2:(int)[[rasters2 sampleValues] objectAtIndex:i].count];
        for (int j = 0; j < [[rasters2 sampleValues] objectAtIndex:i].count; j++) {
            [self compareNumbersWithNumber1:[[[rasters1 sampleValues] objectAtIndex:i] objectAtIndex:j] andNumber2:[[[rasters2 sampleValues] objectAtIndex:i] objectAtIndex:j] andExactType:exactType];
        }
    }
}

+(void) compareRastersInterleaveValuesWithRasters1: (TIFFRasters *) rasters1 andRasters2: (TIFFRasters *) rasters2{
    [self compareRastersInterleaveValuesWithRasters1:rasters1 andRasters2:rasters2 andExactType:true andSameBitsPerSample:true];
}

+(void) compareRastersInterleaveValuesWithRasters1: (TIFFRasters *) rasters1 andRasters2: (TIFFRasters *) rasters2 andExactType: (BOOL) exactType andSameBitsPerSample: (BOOL) sameBitsPerSample{
    
    [self compareRastersMetadataWithRasters1:rasters1 andRasters2:rasters2 andSameBitsPerSample:sameBitsPerSample];
    
    [self assertNotNil:[rasters1 interleaveValues]];
    [self assertNotNil:[rasters2 interleaveValues]];
    [self assertEqualIntWithValue:(int)[rasters1 interleaveValues].count andValue2:(int)[rasters2 interleaveValues].count];
    
    for (int i = 0; i < [rasters1 interleaveValues].count; i++) {
        [self compareNumbersWithNumber1:[[rasters1 interleaveValues] objectAtIndex:i] andNumber2:[[rasters2 interleaveValues] objectAtIndex:i] andExactType:exactType];
    }
}

+(void) compareRastersWithFileDirectory1: (TIFFFileDirectory *) fileDirectory1 andRasters1: (TIFFRasters *) rasters1 andFileDirectory2: (TIFFFileDirectory *) fileDirectory2 andRasters2: (TIFFRasters *) rasters2 andExactType: (BOOL) exactType andSameBitsPerSample: (BOOL) sameBitsPerSample{
    
    [self compareRastersMetadataWithRasters1:rasters1 andRasters2:rasters2 andSameBitsPerSample:sameBitsPerSample];
    
    int randomX = (int) ([self randomDouble] * [rasters1 width]);
    int randomY = (int) ([self randomDouble] * [rasters1 height]);
    
    for (int x = 0; x < [rasters1 width]; x++) {
        for (int y = 0; y < [rasters1 height]; y++) {
            
            NSArray<NSNumber *> * pixel1 = [rasters1 pixelAtX:x andY:y];
            NSArray<NSNumber *> * pixel2 = [rasters2 pixelAtX:x andY:y];
            
            TIFFRasters * rasters3 = nil;
            TIFFRasters * rasters4 = nil;
            if ((x == 0 && y == 0) || (x == [rasters1 width] - 1 && y == [rasters1 height] - 1) || (x == randomX && y == randomY)) {
                TIFFImageWindow * window = [[TIFFImageWindow alloc] initWithX:x andY:y];
                rasters3 = [fileDirectory1 readRastersWithWindow:window];
                [self assertEqualIntWithValue:1 andValue2:[rasters3 numPixels]];
                rasters4 = [fileDirectory2 readInterleavedRastersWithWindow:window];
                [self assertEqualIntWithValue:1 andValue2:[rasters4 numPixels]];
            }
            
            for (int sample = 0; sample < [rasters1 samplesPerPixel]; sample++) {
                NSNumber * sample1 = [rasters1 pixelSampleAtSample:sample andX:x andY:y];
                NSNumber * sample2 = [rasters2 pixelSampleAtSample:sample andX:x andY:y];
                [self compareNumbersWithNumber1:sample1 andNumber2:sample2 andExactType:exactType];
                [self compareNumbersWithNumber1:[pixel1 objectAtIndex:sample] andNumber2:sample1 andExactType:exactType];
                [self compareNumbersWithNumber1:[pixel1 objectAtIndex:sample] andNumber2:[pixel2 objectAtIndex:sample] andExactType:exactType];
                
                if (rasters3 != nil) {
                    NSNumber * sample3 = [rasters3 pixelSampleAtSample:sample andX:0 andY:0];
                    NSNumber * sample4 = [rasters4 pixelSampleAtSample:sample andX:0 andY:0];
                    [self compareNumbersWithNumber1:[pixel1 objectAtIndex:sample] andNumber2:sample3 andExactType:exactType];
                    [self compareNumbersWithNumber1:[pixel1 objectAtIndex:sample] andNumber2:sample4 andExactType:exactType];
                }
            }
        }
    }
}

/**
 * Compare the rasters metadata
 *
 * @param rasters1
 *            rasters 1
 * @param rasters2
 *            rasters 2
 * @param sameBitsPerSample
 *            true if should have the same bits per sample
 */
+(void) compareRastersMetadataWithRasters1: (TIFFRasters *) rasters1 andRasters2: (TIFFRasters *) rasters2 andSameBitsPerSample: (BOOL) sameBitsPerSample{
    [self assertNotNil:rasters1];
    [self assertNotNil:rasters2];
    [self assertEqualIntWithValue:[rasters1 width] andValue2:[rasters2 width]];
    [self assertEqualIntWithValue:[rasters1 height] andValue2:[rasters2 height]];
    [self assertEqualIntWithValue:[rasters1 numPixels] andValue2:[rasters2 numPixels]];
    [self assertEqualIntWithValue:(int)[rasters1 bitsPerSample].count andValue2:(int)[rasters2 bitsPerSample].count];
    if(sameBitsPerSample){
        for (int i = 0; i < [rasters1 bitsPerSample].count; i++) {
            [self assertEqualWithValue:[[rasters1 bitsPerSample] objectAtIndex:i] andValue2:[[rasters2 bitsPerSample] objectAtIndex:i]];
        }
    }
}

/**
 * Compare the two numbers, either exactly or as double values
 *
 * @param number1
 *            number 1
 * @param number2
 *            number 2
 * @param exactType
 *            true if matching the exact data type
 */
+(void) compareNumbersWithNumber1: (NSNumber *) number1 andNumber2: (NSNumber *) number2 andExactType: (BOOL) exactType{
    if (exactType) {
        [self assertEqualWithValue:number1 andValue2:number2];
    } else {
        [self assertEqualDoubleWithValue:[number1 doubleValue] andValue2:[number2 doubleValue]];
    }
}

+(NSString *) getTestFileWithName: (NSString *) fileName{
    return [[[NSBundle bundleForClass:[TIFFTestUtils class]] resourcePath] stringByAppendingPathComponent:fileName];
}

@end
