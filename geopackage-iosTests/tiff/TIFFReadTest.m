//
//  TIFFReadTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFReadTest.h"
#import "TIFFTestUtils.h"
#import "TIFFTestConstants.h"
#import "TIFFReader.h"

@implementation TIFFReadTest

/**
 * Test the stripped TIFF file vs the same data tiled
 */
-(void) testStrippedVsTiled{
    
    NSString * strippedFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_STRIPPED];
    TIFFImage * strippedTiff = [TIFFReader readTiffFromFile:strippedFile];
    
    NSString * tiledFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_TILED];
    TIFFImage * tiledTiff = [TIFFReader readTiffFromFile:tiledFile];
    
    [TIFFTestUtils compareTIFFImagesWithImage1:strippedTiff andImage2:tiledTiff];

}

/**
 * Test the stripped TIFF file vs the same data as int 32
 */
-(void) testStrippedVsInt32{
    
    NSString * strippedFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_STRIPPED];
    TIFFImage * strippedTiff = [TIFFReader readTiffFromFile:strippedFile];
    
    NSString * int32File = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_INT32];
    TIFFImage * int32Tiff = [TIFFReader readTiffFromFile:int32File];
    
    [TIFFTestUtils compareTIFFImagesWithImage1:strippedTiff andImage2:int32Tiff andExactType:true andSameBitsPerSample:false];
    
}

/**
 * Test the stripped TIFF file vs the same data as unsigned int 32
 */
-(void) testStrippedVsUInt32{
    
    NSString * strippedFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_STRIPPED];
    TIFFImage * strippedTiff = [TIFFReader readTiffFromFile:strippedFile];
    
    NSString * uint32File = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_UINT32];
    TIFFImage * uint32Tiff = [TIFFReader readTiffFromFile:uint32File];
    
    [TIFFTestUtils compareTIFFImagesWithImage1:strippedTiff andImage2:uint32Tiff andExactType:false andSameBitsPerSample:false];
    
}

/**
 * Test the stripped TIFF file vs the same data as float 32
 */
-(void) testStrippedVsFloat32{
    
    NSString * strippedFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_STRIPPED];
    TIFFImage * strippedTiff = [TIFFReader readTiffFromFile:strippedFile];
    
    NSString * float32File = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_FLOAT32];
    TIFFImage * float32Tiff = [TIFFReader readTiffFromFile:float32File];
    
    [TIFFTestUtils compareTIFFImagesWithImage1:strippedTiff andImage2:float32Tiff andExactType:false andSameBitsPerSample:false];
    
}

/**
 * Test the stripped TIFF file vs the same data as float 64
 */
-(void) testStrippedVsFloat64{
    
    NSString * strippedFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_STRIPPED];
    TIFFImage * strippedTiff = [TIFFReader readTiffFromFile:strippedFile];
    
    NSString * float64File = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_FLOAT64];
    TIFFImage * float64Tiff = [TIFFReader readTiffFromFile:float64File];
    
    [TIFFTestUtils compareTIFFImagesWithImage1:strippedTiff andImage2:float64Tiff andExactType:false andSameBitsPerSample:false];
    
}

/**
 * Test the stripped TIFF file vs the same data compressed as LZW
 */
-(void) testStrippedVsLzw{
    
    NSString * strippedFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_STRIPPED];
    TIFFImage * strippedTiff = [TIFFReader readTiffFromFile:strippedFile];
    
    NSString * lzwFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_LZW];
    TIFFImage * lzwTiff = [TIFFReader readTiffFromFile:lzwFile];
    
    [TIFFTestUtils compareTIFFImagesWithImage1:strippedTiff andImage2:lzwTiff];
    
}

/**
 * Test the stripped TIFF file vs the same data compressed as Packbits
 */
-(void) testStrippedVsPackbits{
    
    NSString * strippedFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_STRIPPED];
    TIFFImage * strippedTiff = [TIFFReader readTiffFromFile:strippedFile];
    
    NSString * packbitsFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_PACKBITS];
    TIFFImage * packbitsTiff = [TIFFReader readTiffFromFile:packbitsFile];
    
    [TIFFTestUtils compareTIFFImagesWithImage1:strippedTiff andImage2:packbitsTiff];
    
}

/**
 * Test the stripped TIFF file vs the same data as interleaved
 */
-(void) testStrippedVsInterleave{
    
    NSString * strippedFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_STRIPPED];
    TIFFImage * strippedTiff = [TIFFReader readTiffFromFile:strippedFile];
    
    NSString * interleaveFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_INTERLEAVE];
    TIFFImage * interleaveTiff = [TIFFReader readTiffFromFile:interleaveFile];
    
    [TIFFTestUtils compareTIFFImagesWithImage1:strippedTiff andImage2:interleaveTiff];
    
}

/**
 * Test the stripped TIFF file vs the same data as tiled planar
 */
-(void) testStrippedVsTiledPlanar{
    
    NSString * strippedFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_STRIPPED];
    TIFFImage * strippedTiff = [TIFFReader readTiffFromFile:strippedFile];
    
    NSString * tiledPlanarFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_TILED_PLANAR];
    TIFFImage * tiledPlanarTiff = [TIFFReader readTiffFromFile:tiledPlanarFile];
    
    [TIFFTestUtils compareTIFFImagesWithImage1:strippedTiff andImage2:tiledPlanarTiff];
    
}


@end
