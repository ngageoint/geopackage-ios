//
//  TIFFReader.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFReader.h"
#import "TIFFIOUtils.h"
#import "TIFFConstants.h"

@implementation TIFFReader

+(TIFFImage *) readTiffFromFile: (NSString *) file{
    return [self readTiffFromFile:file andCache:false];
}


+(TIFFImage *) readTiffFromFile: (NSString *) file andCache: (BOOL) cache{
    NSData * data = [TIFFIOUtils fileData:file];
    TIFFImage * tiffImage = [self readTiffFromData:data andCache:cache];
    return tiffImage;
}


+(TIFFImage *) readTiffFromStream: (NSInputStream *) stream{
    return [self readTiffFromStream:stream andCache:false];
}


+(TIFFImage *) readTiffFromStream: (NSInputStream *) stream andCache: (BOOL) cache{
    NSData * data = [TIFFIOUtils streamData:stream];
    TIFFImage * tiffImage = [self readTiffFromData:data andCache:cache];
    return tiffImage;
}


+(TIFFImage *) readTiffFromData: (NSData *) data{
    return [self readTiffFromData:data andCache:false];
}


+(TIFFImage *) readTiffFromData: (NSData *) data andCache: (BOOL) cache{
    TIFFByteReader * reader = [[TIFFByteReader alloc] initWithData:data];
    TIFFImage * tiffImage = [self readTiffFromReader:reader andCache:cache];
    return tiffImage;
}


+(TIFFImage *) readTiffFromReader: (TIFFByteReader *) reader{
    return [self readTiffFromReader:reader andCache:false];
}

+(TIFFImage *) readTiffFromReader: (TIFFByteReader *) reader andCache: (BOOL) cache{

    // Read the 2 bytes of byte order
    NSString * byteOrderString = [reader readStringWithCount:2];
    
    // Determine the byte order
    CFByteOrder byteOrder;
    if([byteOrderString isEqualToString:TIFF_BYTE_ORDER_LITTLE_ENDIAN]){
        byteOrder = CFByteOrderLittleEndian;
    }else if([byteOrderString isEqualToString:TIFF_BYTE_ORDER_BIG_ENDIAN]){
        byteOrder = CFByteOrderBigEndian;
    }else{
        [NSException raise:@"Invalid" format:@"Invalid byte order: %@", byteOrderString];
    }
    [reader setByteOrder:byteOrder];
    
    // Validate the TIFF file identifier
    int tiffIdentifier = [[reader readUnsignedShort] unsignedShortValue];
    if (tiffIdentifier != TIFF_FILE_IDENTIFIER) {
        [NSException raise:@"Invalid" format:@"Invalid file identifier, not a TIFF: %d", tiffIdentifier];
    }
    
    // Get the offset in bytes of the first image file directory (IFD)
    int byteOffset = [[reader readUnsignedInt] unsignedIntValue];
    
    // Get the TIFF Image
    TIFFImage * tiffImage = [self parseTIFFImageWithReader:reader andByteOffset:byteOffset andCache:cache];
    
    return tiffImage;
}

/**
 * Parse the TIFF Image with file directories
 *
 * @param reader
 *            byte reader
 * @param byteOffset
 *            byte offset
 * @param cache
 *            true to cache tiles and strips
 * @return TIFF image
 */
+(TIFFImage *) parseTIFFImageWithReader: (TIFFByteReader *) reader andByteOffset: (int) byteOffset andCache: (BOOL) cache{

    TIFFImage * tiffImage = [[TIFFImage alloc] init];
    
    // Continue until the byte offset no longer points to another file
    // directory
    while (byteOffset != 0) {
        
        // Set the next byte to read from
        [reader setNextByte:byteOffset];
        
        // Create the new directory
        NSMutableOrderedSet<TIFFFileDirectoryEntry *> * entries = [[NSMutableOrderedSet alloc] init];
        
        // Read the number of directory entries
        int numDirectoryEntries = [[reader readUnsignedShort] unsignedShortValue];
        
        // Read each entry and the values
        for (short entryCount = 0; entryCount < numDirectoryEntries; entryCount++) {
            
            // Read the field tag, field type, and type count
            int fieldTagValue = [[reader readUnsignedShort] unsignedShortValue];
            enum TIFFFieldTagType fieldTag = [TIFFFieldTagTypes typeByTagId:fieldTagValue];
            int fieldTypeValue = [[reader readUnsignedShort] unsignedShortValue];
            enum TIFFFieldType fieldType = [TIFFFieldTypes typeByValue:fieldTypeValue];
            int typeCount = [[reader readUnsignedInt] unsignedIntValue];
            
            // Save off the next byte to read location
            int nextByte = [reader nextByte];
            
            // Read the field values
            NSObject * values = [self readFieldValuesWithReader:reader andFieldTag:fieldTag andFieldType:fieldType andTypeCount:typeCount];
            
            // Create and add a file directory
            TIFFFileDirectoryEntry * entry = [[TIFFFileDirectoryEntry alloc] initWithFieldTag:fieldTag andFieldType:fieldType andTypeCount:typeCount andValues:values];
            [entries addObject:entry];
            
            // Restore the next byte to read location
            [reader setNextByte:nextByte + 4];
        }
        
        // Add the file directory
        TIFFFileDirectory * fileDirectory = [[TIFFFileDirectory alloc] initWithEntries:entries andReader:reader andCacheData:cache];
        [tiffImage addFileDirectory:fileDirectory];
        
        // Read the next byte offset location
        byteOffset = [[reader readUnsignedInt] unsignedIntValue];
    }
    
    return tiffImage;
}

/**
 * Read the field values
 *
 * @param reader
 *            byte reader
 * @param fieldTag
 *            field tag type
 * @param fieldType
 *            field type
 * @param typeCount
 *            type count
 * @return values
 */
+(NSObject *) readFieldValuesWithReader: (TIFFByteReader *) reader andFieldTag: (enum TIFFFieldTagType) fieldTag andFieldType: (enum TIFFFieldType) fieldType andTypeCount: (int) typeCount{

    // If the value is larger and not stored inline, determine the offset
    if ([TIFFFieldTypes bytes:fieldType] * typeCount > 4) {
        int valueOffset = [[reader readUnsignedInt] unsignedIntValue];
        [reader setNextByte:valueOffset];
    }
    
    // Read the directory entry values
    NSArray * valuesList = [self valuesWithReader:reader andFieldType:fieldType andTypeCount:typeCount];
    
    // Get the single or array values
    NSObject * values = nil;
    if (typeCount == 1
        && ![TIFFFieldTagTypes isArray:fieldTag]
        && !(fieldType == TIFF_FIELD_RATIONAL || fieldType == TIFF_FIELD_SRATIONAL)) {
        values = [valuesList objectAtIndex:0];
    } else {
        values = valuesList;
    }
    
    return values;
}

/**
 * Get the directory entry values
 *
 * @param reader
 *            byte reader
 * @param fieldType
 *            field type
 * @param typeCount
 *            type count
 * @return values
 */
+(NSArray *) valuesWithReader: (TIFFByteReader *) reader andFieldType: (enum TIFFFieldType) fieldType andTypeCount: (int) typeCount{

    
    NSMutableArray * values = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < typeCount; i++) {
        
        switch (fieldType) {
            case TIFF_FIELD_ASCII:
                [values addObject:[reader readStringWithCount:1]];
                break;
            case TIFF_FIELD_BYTE:
            case TIFF_FIELD_UNDEFINED:
                [values addObject:[reader readUnsignedByte]];
                break;
            case TIFF_FIELD_SBYTE:
                [values addObject:[reader readByte]];
                break;
            case TIFF_FIELD_SHORT:
                [values addObject:[reader readUnsignedShort]];
                break;
            case TIFF_FIELD_SSHORT:
                [values addObject:[reader readShort]];
                break;
            case TIFF_FIELD_LONG:
                [values addObject:[reader readUnsignedInt]];
                break;
            case TIFF_FIELD_SLONG:
                [values addObject:[reader readInt]];
                break;
            case TIFF_FIELD_RATIONAL:
                [values addObject:[reader readUnsignedInt]];
                [values addObject:[reader readUnsignedInt]];
                break;
            case TIFF_FIELD_SRATIONAL:
                [values addObject:[reader readInt]];
                [values addObject:[reader readInt]];
                break;
            case TIFF_FIELD_FLOAT:
                [values addObject:[reader readFloat]];
                break;
            case TIFF_FIELD_DOUBLE:
                [values addObject:[reader readDouble]];
                break;
            default:
                [NSException raise:@"Invalid Field" format:@"Invalid field type: %u", fieldType];
        }
        
    }
    
    // If ASCII characters, combine the strings
    if (fieldType == TIFF_FIELD_ASCII) {
        NSMutableArray * stringValues = [[NSMutableArray alloc] init];
        NSMutableString * stringValue = [[NSMutableString alloc] init];
        for (NSObject * value in values) {
            if (value == nil) {
                if(stringValue.length > 0){
                    [stringValues addObject:stringValue];
                    stringValue = [[NSMutableString alloc] init];
                }
            } else {
                [stringValue appendString:(NSString *)value];
            }
        }
        values = stringValues;
    }
    
    return values;
}

@end
