//
//  TIFFWriteTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFWriteTest.h"
#import "TIFFTestUtils.h"
#import "TIFFConstants.h"
#import "TIFFTestConstants.h"
#import "TIFFReader.h"
#import "TIFFWriter.h"

@implementation TIFFWriteTest

/**
 * Test writing and reading a stripped TIFF file
 */
-(void) testWriteStrippedChunky{

    NSString * strippedFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_STRIPPED];
    TIFFImage * strippedTiff = [TIFFReader readTiffFromFile:strippedFile];
    
    TIFFFileDirectory * fileDirectory = [strippedTiff fileDirectory];
    TIFFRasters * rasters = [fileDirectory readRasters];
    TIFFRasters * rastersInterleaved = [fileDirectory readInterleavedRasters];

    [fileDirectory setWriteRasters:rasters];
    [fileDirectory setCompression:TIFF_COMPRESSION_NO];
    [fileDirectory setPlanarConfiguration:TIFF_PLANAR_CONFIGURATION_CHUNKY];
    int rowsPerStrip = [rasters calculateRowsPerStripWithPlanarConfiguration:[[fileDirectory planarConfiguration] intValue]];
    [fileDirectory setRowsPerStrip:rowsPerStrip];
    NSData * tiffBytes = [TIFFWriter writeTiffToDataWithImage:strippedTiff];
    
    TIFFImage * readTiffImage = [TIFFReader readTiffFromData:tiffBytes];
    TIFFFileDirectory * fileDirectory2 = [readTiffImage fileDirectory];
    TIFFRasters * rasters2 = [fileDirectory2 readRasters];
    TIFFRasters * rasters2Interleaved = [fileDirectory2 readInterleavedRasters];
    
    [TIFFTestUtils compareRastersSampleValuesWithRasters1:rasters andRasters2:rasters2];
    [TIFFTestUtils compareRastersInterleaveValuesWithRasters1:rastersInterleaved andRasters2:rasters2Interleaved];
    
}

/**
 * Test writing and reading a stripped TIFF file
 */
-(void) testWriteStrippedPlanar{

    NSString * strippedFile = [TIFFTestUtils getTestFileWithName:TIFF_TEST_FILE_STRIPPED];
    TIFFImage * strippedTiff = [TIFFReader readTiffFromFile:strippedFile];
    
    TIFFFileDirectory * fileDirectory = [strippedTiff fileDirectory];
    TIFFRasters * rasters = [fileDirectory readRasters];
    TIFFRasters * rastersInterleaved = [fileDirectory readInterleavedRasters];
    
    [fileDirectory setWriteRasters:rasters];
    [fileDirectory setCompression:TIFF_COMPRESSION_NO];
    [fileDirectory setPlanarConfiguration:TIFF_PLANAR_CONFIGURATION_PLANAR];
    int rowsPerStrip = [rasters calculateRowsPerStripWithPlanarConfiguration:[[fileDirectory planarConfiguration] intValue]];
    [fileDirectory setRowsPerStrip:rowsPerStrip];
    NSData * tiffBytes = [TIFFWriter writeTiffToDataWithImage:strippedTiff];
    
    TIFFImage * readTiffImage = [TIFFReader readTiffFromData:tiffBytes];
    TIFFFileDirectory * fileDirectory2 = [readTiffImage fileDirectory];
    TIFFRasters * rasters2 = [fileDirectory2 readRasters];
    TIFFRasters * rasters2Interleaved = [fileDirectory2 readInterleavedRasters];
    
    [TIFFTestUtils compareRastersSampleValuesWithRasters1:rasters andRasters2:rasters2];
    [TIFFTestUtils compareRastersInterleaveValuesWithRasters1:rastersInterleaved andRasters2:rasters2Interleaved];
    
}

@end
