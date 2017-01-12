//
//  TIFFWriter.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFWriter.h"
#import "TIFFCompressionEncoder.h"
#import "TIFFIOUtils.h"
#import "TIFFConstants.h"

@implementation TIFFWriter

+(void) writeTiffWithFile: (NSString *) file andImage: (TIFFImage *) tiffImage{
    TIFFByteWriter * writer = [[TIFFByteWriter alloc] init];
    [self writeTiffWithFile:file andWriter:writer andImage:tiffImage];
    [writer close];
}

+(void) writeTiffWithFile: (NSString *) file andWriter: (TIFFByteWriter *) writer andImage: (TIFFImage *) tiffImage{
    NSData * data = [self writeTiffToDataWithWriter:writer andImage:tiffImage];
    NSInputStream * inputStream = [NSInputStream inputStreamWithData:data];
    [TIFFIOUtils copyInputStream:inputStream toFile:file];
}

+(NSData *) writeTiffToDataWithImage: (TIFFImage *) tiffImage{
    TIFFByteWriter * writer = [[TIFFByteWriter alloc] init];
    NSData * data = [self writeTiffToDataWithWriter:writer andImage:tiffImage];
    [writer close];
    return data;
}

+(NSData *) writeTiffToDataWithWriter: (TIFFByteWriter *) writer andImage: (TIFFImage *) tiffImage{
    [self writeTiffWithWriter:writer andImage:tiffImage];
    NSData * data = [writer getData];
    return data;
}

+(void) writeTiffWithWriter: (TIFFByteWriter *) writer andImage: (TIFFImage *) tiffImage{

    // Write the byte order (bytes 0-1)
    NSString * byteOrder = writer.byteOrder == CFByteOrderBigEndian ? TIFF_BYTE_ORDER_BIG_ENDIAN : TIFF_BYTE_ORDER_LITTLE_ENDIAN;
    [writer writeString:byteOrder];
    
    // Write the TIFF file identifier (bytes 2-3)
    [writer writeUnsignedShort:TIFF_FILE_IDENTIFIER];
    
    // Write the first IFD offset (bytes 4-7), set to start right away at
    // byte 8
    [writer writeUnsignedInt:(unsigned int)TIFF_HEADER_BYTES];
    
    // Write the TIFF Image
    [self writeImageFileDirectoriesWithWriter:writer andImage:tiffImage];
}

/**
 * Write the image file directories
 *
 * @param writer
 *            byte writer
 * @param tiffImage
 *            tiff image
 * @throws IOException
 */
+(void) writeImageFileDirectoriesWithWriter: (TIFFByteWriter *) writer andImage: (TIFFImage *) tiffImage{

    // Write each file directory
    for (int i = 0; i < [tiffImage fileDirectories].count; i++) {
        TIFFFileDirectory * fileDirectory = [tiffImage fileDirectoryAtIndex:i];
        
        // Populate strip entries with placeholder values so the sizes come
        // out correctly
        [self populateRasterEntriesWithFileDirectory:fileDirectory];
        
        // Track of the starting byte of this directory
        int startOfDirectory = [writer size];
        int afterDirectory = startOfDirectory + [fileDirectory size];
        int afterValues = startOfDirectory + [fileDirectory sizeWithValues];
        
        // Write the number of directory entries
        [writer writeUnsignedShort:[fileDirectory numEntries]];
        
        NSMutableArray<TIFFFileDirectoryEntry *> * entryValues = [[NSMutableArray alloc] init];
        
        // Byte to write the next values
        int nextByte = afterDirectory;
        
        NSMutableArray<NSNumber *> * valueBytesCheck = [[NSMutableArray alloc] init];
        
        // Write the raster bytes to temporary storage
        if ([fileDirectory rowsPerStrip] == nil) {
            [NSException raise:@"Not Supported" format:@"Tiled images are not supported"];
        }
        
        // Create the raster bytes, written to the stream later
        NSData * rastersBytes = [self writeRastersWithByteOrder:writer.byteOrder andFileDirectory:fileDirectory andOffset:afterValues];
        
        // Write each entry
        for (TIFFFileDirectoryEntry * entry in [fileDirectory entries]) {
            [writer writeUnsignedShort:[TIFFFieldTagTypes tagId:[entry fieldTag]]];
            [writer writeUnsignedShort:[TIFFFieldTypes value:[entry fieldType]]];
            [writer writeUnsignedInt:[entry typeCount]];
            int valueBytes = [TIFFFieldTypes bytes:[entry fieldType]] * [entry typeCount];
            if (valueBytes > 4) {
                // Write the value offset
                [entryValues addObject:entry];
                [writer writeUnsignedInt:nextByte];
                [valueBytesCheck addObject:[NSNumber numberWithInt:nextByte]];
                nextByte += [entry sizeOfValues];
            } else {
                // Write the value in the inline 4 byte space, left aligned
                int bytesWritten = [self writeValuesWithWriter:writer andFileDirectoryEntry:entry];
                if (bytesWritten != valueBytes) {
                    [NSException raise:@"Unexpected Bytes Written" format:@"Unexpected bytes written. Expected: %d, Actual: %d", valueBytes, bytesWritten];
                }
                [self writerFillerBytesWithWriter:writer andCount:4 - valueBytes];
            }
        }
        
        if (i + 1 == [tiffImage fileDirectories].count) {
            // Write 0's since there are not more file directories
            [self writerFillerBytesWithWriter:writer andCount:4];
        } else {
            // Write the start address of the next file directory
            int nextFileDirectory = afterValues + (int)rastersBytes.length;
            [writer writeUnsignedInt:nextFileDirectory];
        }
        
        // Write the external entry values
        for (int entryIndex = 0; entryIndex < entryValues.count; entryIndex++) {
            TIFFFileDirectoryEntry * entry = [entryValues objectAtIndex:entryIndex];
            int entryValuesByte = [[valueBytesCheck objectAtIndex:entryIndex] intValue];
            if (entryValuesByte != [writer size]) {
                [NSException raise:@"Byte Mismatch" format:@"Entry values byte does not match the write location. Entry Values Byte: %d, Current Byte: %d", entryValuesByte, [writer size]];
            }
            int bytesWritten = [self writeValuesWithWriter:writer andFileDirectoryEntry:entry];
            int valueBytes = [TIFFFieldTypes bytes:[entry fieldType]] * [entry typeCount];
            if (bytesWritten != valueBytes) {
                [NSException raise:@"Unexpected Bytes Written" format:@"Unexpected bytes written. Expected: %d, Actual: %d", valueBytes, bytesWritten];
            }
        }
        
        // Write the image bytes
        [writer writeBytesWithData:rastersBytes];
    }
    
}

/**
 * Populate the raster entry values with placeholder values for correct size
 * calculations
 *
 * @param fileDirectory
 *            file directory
 */
+(void) populateRasterEntriesWithFileDirectory: (TIFFFileDirectory *) fileDirectory{

    TIFFRasters * rasters = [fileDirectory writeRasters];
    if (rasters == nil) {
        [NSException raise:@"Rasters Required" format:@"File Directory Writer Rasters is required to create a TIFF"];
    }
    
    // Populate the raster entries
    if ([fileDirectory rowsPerStrip] != nil) {
        [self populateStripEntriesWithFileDirectory:fileDirectory];
    } else {
        [NSException raise:@"Not Supported" format:@"Tiled images are not supported"];
    }
}

/**
 * Populate the strip entries with placeholder values
 *
 * @param fileDirectory
 *            file directory
 * @param strips
 *            number of strips
 */
+(void) populateStripEntriesWithFileDirectory: (TIFFFileDirectory *) fileDirectory{

    int rowsPerStrip = [[fileDirectory rowsPerStrip] intValue];
    int stripsPerSample = ceil([[fileDirectory imageHeight] doubleValue] / rowsPerStrip);
    int strips = stripsPerSample;
    if ([[fileDirectory planarConfiguration] intValue] == TIFF_PLANAR_CONFIGURATION_PLANAR) {
        strips *= [[fileDirectory samplesPerPixel] intValue];
    }
    
    // TODO
    //fileDirectory.setStripOffsetsAsLongs(new ArrayList<>(Collections
    //                                                     .nCopies(strips, 0l)));
    //fileDirectory.setStripByteCounts(new ArrayList<>(Collections.nCopies(
     //                                                                    strips, 0)));
}

/**
 * Write the rasters as bytes
 *
 * @param byteOrder
 *            byte order
 * @param fileDirectory
 *            file directory
 * @param offset
 *            byte offset
 * @return rasters bytes
 */
+(NSData *) writeRastersWithByteOrder: (CFByteOrder) byteOrder andFileDirectory: (TIFFFileDirectory *) fileDirectory andOffset: (int) offset{
    return nil; // TODO
}

/**
 * Write the rasters as bytes
 *
 * @param writer
 *            byte writer
 * @param fileDirectory
 *            file directory
 * @param offset
 *            byte offset
 * @param sampleFieldTypes
 *            sample field types
 * @param encoder
 *            compression encoder
 */
+(void) writeStripRastersWithWriter: (TIFFByteWriter *) writer andFileDirectory: (TIFFFileDirectory *) fileDirectory andOffset: (int) offset andFieldTypes: (NSArray *) sampleFiledTypes andEncoder: (NSObject<TIFFCompressionEncoder> *) encoder{
    // TODO
}

/**
 * Get the compression encoder
 *
 * @param fileDirectory
 *            file directory
 * @return encoder
 */
+(NSObject<TIFFCompressionEncoder> *) encoderWithFileDirectory: (TIFFFileDirectory *) fileDirectory{
    return nil; // TODO
}

/**
 * Write the value according to the field type
 *
 * @param writer
 *            byte writer
 * @param fieldType
 *            field type
 */
+(void) writeValueWithWriter: (TIFFByteWriter *) writer andFieldType: (enum TIFFFieldType) fieldType andValue: (NSNumber *) value{
    // TODO
}

/**
 * Write filler 0 bytes
 *
 * @param writer
 *            byte writer
 * @param count
 *            number of 0 bytes to write
 */
+(void) writerFillerBytesWithWriter: (TIFFByteWriter *) writer andCount: (int) count{
    for (int i = 0; i < count; i++) {
        [writer writeUnsignedByte:0];
    }
}

/**
 * Write file directory entry values
 *
 * @param writer
 *            byte writer
 * @param entry
 *            file directory entry
 * @return bytes written
 */
+(int) writeValuesWithWriter: (TIFFByteWriter *) writer andFileDirectoryEntry: (TIFFFileDirectoryEntry *) entry{
    return 0; // TODO
}

@end
