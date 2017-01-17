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
#import "TIFFRawCompression.h"
#import "TIFFLZWCompression.h"
#import "TIFFDeflateCompression.h"
#import "TIFFPackbitsCompression.h"

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
    
    NSMutableArray *stripOffsets = [[NSMutableArray alloc] initWithCapacity:strips];
    NSMutableArray *stripByteCounts = [[NSMutableArray alloc] initWithCapacity:strips];
    for (int i = 0; i < strips; i++){
        [stripOffsets addObject: [NSNumber numberWithUnsignedLong: 0]];
        [stripByteCounts addObject: [NSNumber numberWithUnsignedShort: 0]];
    }
    [fileDirectory setStripOffsetsAsLongs:stripOffsets];
    [fileDirectory setStripByteCounts:stripByteCounts];
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
    
    TIFFRasters * rasters = [fileDirectory writeRasters];
    if (rasters == nil) {
        [NSException raise:@"Writer Rasters Required" format:@"File Directory Writer Rasters is required to create a TIFF"];
    }
    
    // Get the sample field types
    NSMutableArray<NSNumber *> * sampleFieldTypes = [[NSMutableArray alloc] initWithCapacity:[rasters samplesPerPixel]];
    for (int sample = 0; sample < [rasters samplesPerPixel]; sample++) {
        [sampleFieldTypes addObject:[NSNumber numberWithInt:[fileDirectory fieldTypeForSample:sample]]];
    }
    
    // Get the compression encoder
    NSObject<TIFFCompressionEncoder> * encoder = [self encoderWithFileDirectory:fileDirectory];
    
    // Byte writer to write the raster
    TIFFByteWriter * writer = [[TIFFByteWriter alloc] initWithByteOrder:byteOrder];
    
    // Write the rasters
    if ([fileDirectory rowsPerStrip] != nil) {
        [self writeStripRastersWithWriter:writer andFileDirectory:fileDirectory andOffset:offset andFieldTypes:sampleFieldTypes andEncoder:encoder];
    } else {
        [NSException raise:@"Not Supported" format:@"Tiled images are not supported"];
    }
    
    // Return the rasters bytes
    NSData * data = [writer getData];
    [writer close];
    
    return data;
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
+(void) writeStripRastersWithWriter: (TIFFByteWriter *) writer andFileDirectory: (TIFFFileDirectory *) fileDirectory andOffset: (int) offset andFieldTypes: (NSArray<NSNumber *> *) sampleFieldTypes andEncoder: (NSObject<TIFFCompressionEncoder> *) encoder{
    
    TIFFRasters * rasters = [fileDirectory writeRasters];
    
    // Get the row and strip counts
    int rowsPerStrip = [[fileDirectory rowsPerStrip] intValue];
    int maxY = [[fileDirectory imageHeight] intValue];
    int stripsPerSample = ceil((double)maxY / (double) rowsPerStrip);

    int strips = stripsPerSample;
    if ([[fileDirectory planarConfiguration] intValue] == TIFF_PLANAR_CONFIGURATION_PLANAR) {
        strips *= [[fileDirectory samplesPerPixel] intValue];
    }
    
    // Build the strip offsets and byte counts
    NSMutableArray<NSNumber *> * stripOffsets = [[NSMutableArray alloc] init];
    NSMutableArray<NSNumber *> * stripByteCounts = [[NSMutableArray alloc] init];
    
    // Write each strip
    for (int strip = 0; strip < strips; strip++) {
        
        int startingY;
        NSNumber * sample = nil;
        if ([[fileDirectory planarConfiguration] intValue] == TIFF_PLANAR_CONFIGURATION_PLANAR) {
            sample = [NSNumber numberWithInt:strip / stripsPerSample];
            startingY = (strip % stripsPerSample) * rowsPerStrip;
        } else {
            startingY = strip * rowsPerStrip;
        }
        
        // Write the strip of bytes
        TIFFByteWriter * stripWriter = [[TIFFByteWriter alloc] initWithByteOrder:writer.byteOrder];
        
        int endingY = MIN(startingY + rowsPerStrip, maxY);
        for (int y = startingY; y < endingY; y++) {
            
            TIFFByteWriter * rowWriter = [[TIFFByteWriter alloc] initWithByteOrder:writer.byteOrder];
            
            for (int x = 0; x < [[fileDirectory imageWidth] intValue]; x++) {
                
                if (sample != nil) {
                    NSNumber * value = [rasters pixelSampleAtSample:[sample intValue] andX:x andY:y];
                    enum TIFFFieldType fieldType = [[sampleFieldTypes objectAtIndex:[sample intValue]] intValue];
                    [self writeValueWithWriter:rowWriter andFieldType:fieldType andValue:value];
                } else {
                    NSArray<NSNumber *> * values = [rasters pixelAtX:x andY:y];
                    for (int sampleIndex = 0; sampleIndex < values.count; sampleIndex++) {
                        NSNumber * value = [values objectAtIndex:sampleIndex];
                        enum TIFFFieldType fieldType = [[sampleFieldTypes objectAtIndex:sampleIndex] intValue];
                        [self writeValueWithWriter:rowWriter andFieldType:fieldType andValue:value];
                    }
                }
            }
            
            // Get the row bytes and encode if needed
            NSData * rowData = [rowWriter getData];
            [rowWriter close];
            if ([encoder rowEncoding]) {
                rowData = [encoder encodeData:rowData withByteOrder:writer.byteOrder];
            }
            
            // Write the row
            [stripWriter writeBytesWithData:rowData];
        }
        
        // Get the strip bytes and encode if needed
        NSData * stripData = [stripWriter getData];
        [stripWriter close];
        if (![encoder rowEncoding]) {
            stripData = [encoder encodeData:stripData withByteOrder:writer.byteOrder];
        }
        
        // Write the strip bytes
        [writer writeBytesWithData:stripData];
        
        // Add the strip byte count
        NSUInteger bytesWritten = stripData.length;
        [stripByteCounts addObject:[NSNumber numberWithUnsignedInteger:bytesWritten]];
        
        // Add the strip offset
        [stripOffsets addObject:[NSNumber numberWithInt:offset]];
        offset += bytesWritten;
        
    }
    
    // Set the strip offsets and byte counts
    [fileDirectory setStripOffsetsAsLongs:stripOffsets];
    [fileDirectory setStripByteCounts:stripByteCounts];

}

/**
 * Get the compression encoder
 *
 * @param fileDirectory
 *            file directory
 * @return encoder
 */
+(NSObject<TIFFCompressionEncoder> *) encoderWithFileDirectory: (TIFFFileDirectory *) fileDirectory{
    
    NSObject<TIFFCompressionEncoder> * encoder = nil;
    
    // Determine the encoder based upon the compression
    NSNumber * compression = [fileDirectory compression];
    if (compression == nil) {
        compression = [NSNumber numberWithInteger:TIFF_COMPRESSION_NO];
    }
    
    NSInteger compressionInteger = [compression integerValue];
    if(compressionInteger == TIFF_COMPRESSION_NO){
        encoder = [[TIFFRawCompression alloc] init];
    }else if(compressionInteger == TIFF_COMPRESSION_CCITT_HUFFMAN){
        [NSException raise:@"Not Supported" format:@"CCITT Huffman compression not supported: %@", compression];
    }else if(compressionInteger == TIFF_COMPRESSION_T4){
        [NSException raise:@"Not Supported" format:@"T4-encoding compression not supported: %@", compression];
    }else if(compressionInteger == TIFF_COMPRESSION_T6){
        [NSException raise:@"Not Supported" format:@"T6-encoding compression not supported: %@", compression];
    }else if(compressionInteger == TIFF_COMPRESSION_LZW){
        encoder = [[TIFFLZWCompression alloc] init];
    }else if(compressionInteger == TIFF_COMPRESSION_JPEG_OLD || compressionInteger == TIFF_COMPRESSION_JPEG_NEW){
        [NSException raise:@"Not Supported" format:@"JPEG compression not supported: %@", compression];
    }else if(compressionInteger == TIFF_COMPRESSION_DEFLATE){
        encoder = [[TIFFDeflateCompression alloc] init];
    }else if(compressionInteger == TIFF_COMPRESSION_PACKBITS){
        encoder = [[TIFFPackbitsCompression alloc] init];
    }else{
        [NSException raise:@"Not Supported" format:@"Unknown compression method identifier: %@", compression];
    }
    
    return encoder;
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
    
    switch (fieldType) {
        case TIFF_FIELD_BYTE:
            [writer writeUnsignedByte:[value unsignedCharValue]];
            break;
        case TIFF_FIELD_SHORT:
            [writer writeUnsignedShort:[value unsignedShortValue]];
            break;
        case TIFF_FIELD_LONG:
            [writer writeUnsignedInt:[value unsignedIntValue]];
            break;
        case TIFF_FIELD_SBYTE:
             [writer writeByte:[value charValue]];
            break;
        case TIFF_FIELD_SSHORT:
            [writer writeShort:[value shortValue]];
            break;
        case TIFF_FIELD_SLONG:
            [writer writeInt:[value intValue]];
            break;
        case TIFF_FIELD_FLOAT:
            [writer writeFloat:[value floatValue]];
            break;
        case TIFF_FIELD_DOUBLE:
            [writer writeDouble:[value doubleValue]];
            break;
        default:
            [NSException raise:@"Unsupported Type" format:@"Unsupported raster field type: %d", fieldType];
    }

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
    
    NSArray * valuesList = nil;
    if([entry typeCount] == 1
       && ![TIFFFieldTagTypes isArray:[entry fieldTag]]
       && !([entry fieldType] == TIFF_FIELD_RATIONAL || [entry fieldType] == TIFF_FIELD_SRATIONAL)){
        valuesList = [[NSArray alloc] initWithObjects:[entry values], nil];
    } else {
        valuesList = (NSArray *)[entry values];
    }
    
    int bytesWritten = 0;
    
    for (NSObject * value in valuesList) {
        
        switch ([entry fieldType]) {
            case TIFF_FIELD_ASCII:
                bytesWritten += [writer writeString:(NSString *)value];
                if (bytesWritten < [entry typeCount]) {
                    [self writerFillerBytesWithWriter:writer andCount:1];
                    bytesWritten++;
                }
                break;
            case TIFF_FIELD_BYTE:
            case TIFF_FIELD_UNDEFINED:
                [writer writeNumberAsUnsignedByte:(NSNumber *)value];
                bytesWritten += 1;
                break;
            case TIFF_FIELD_SBYTE:
                [writer writeNumberAsByte:(NSNumber *) value];
                bytesWritten += 1;
                break;
            case TIFF_FIELD_SHORT:
                [writer writeNumberAsUnsignedShort:(NSNumber *) value];
                bytesWritten += 2;
                break;
            case TIFF_FIELD_SSHORT:
                [writer writeNumberAsShort:(NSNumber *) value];
                bytesWritten += 2;
                break;
            case TIFF_FIELD_LONG:
                [writer writeNumberAsUnsignedInt:(NSNumber *) value];
                bytesWritten += 4;
                break;
            case TIFF_FIELD_SLONG:
                [writer writeNumberAsInt:(NSNumber *) value];
                bytesWritten += 4;
                break;
            case TIFF_FIELD_RATIONAL:
                [writer writeNumberAsUnsignedInt:(NSNumber *) value];
                bytesWritten += 4;
                break;
            case TIFF_FIELD_SRATIONAL:
                [writer writeNumberAsInt:(NSNumber *) value];
                bytesWritten += 4;
                break;
            case TIFF_FIELD_FLOAT:
                [writer writeNumberAsFloat:(NSDecimalNumber *) value];
                bytesWritten += 4;
                break;
            case TIFF_FIELD_DOUBLE:
                [writer writeNumberAsDouble:(NSDecimalNumber *) value];
                bytesWritten += 8;
                break;
            default:
                [NSException raise:@"Invalid Type" format:@"Invalid field type: %d", [entry fieldType]];
        }
        
    }
    
    return bytesWritten;
}

@end
