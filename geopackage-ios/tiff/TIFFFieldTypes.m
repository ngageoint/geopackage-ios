//
//  TIFFFieldTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFFieldTypes.h"

@implementation TIFFFieldTypes

+(int) value: (enum TIFFFieldType) fieldType{
    return (int) fieldType;
}

+(int) bytes: (enum TIFFFieldType) fieldType{
    
    int bytes = 0;
    
    switch (fieldType) {
        case TIFF_FIELD_BYTE:
            bytes = 1;
            break;
        case TIFF_FIELD_ASCII:
            bytes = 1;
            break;
        case TIFF_FIELD_SHORT:
            bytes = 2;
            break;
        case TIFF_FIELD_LONG:
            bytes = 4;
            break;
        case TIFF_FIELD_RATIONAL:
            bytes = 8;
            break;
        case TIFF_FIELD_SBYTE:
            bytes = 1;
            break;
        case TIFF_FIELD_UNDEFINED:
            bytes = 1;
            break;
        case TIFF_FIELD_SSHORT:
            bytes = 2;
            break;
        case TIFF_FIELD_SLONG:
            bytes = 4;
            break;
        case TIFF_FIELD_SRATIONAL:
            bytes = 8;
            break;
        case TIFF_FIELD_FLOAT:
            bytes = 4;
            break;
        case TIFF_FIELD_DOUBLE:
            bytes = 8;
            break;
        default:
            [NSException raise:@"Unsupported Field" format:@"Unsupported Field Type %u", fieldType];
            break;
    }
    
    return bytes;
}

+(enum TIFFFieldType) typeByValue: (int) value{
    return (enum TIFFFieldType) value;
}

@end
