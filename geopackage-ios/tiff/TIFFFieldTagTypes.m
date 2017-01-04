//
//  TIFFFieldTagType.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFFieldTagTypes.h"

@implementation TIFFFieldTagTypes

+(int) tagId: (enum TIFFFieldTagType) fieldTagType{
    
    int tagId = -1;
    
    switch (fieldTagType) {
        case TIFF_TAG_ARTIST:
            tagId = 315;
            break;
        case TIFF_TAG_BITS_PER_SAMPLE:
            tagId = 258;
            break;
        case TIFF_TAG_CELL_LENGTH:
            tagId = 265;
            break;
        case TIFF_TAG_CELL_WIDTH:
            tagId = 264;
            break;
        case TIFF_TAG_COLOR_MAP:
            tagId = 320;
            break;
        case TIFF_TAG_COMPRESSION:
            tagId = 259;
            break;
        case TIFF_TAG_COPYRIGHT:
            tagId = 33432;
            break;
        case TIFF_TAG_DATE_TIME:
            tagId = 306;
            break;
        case TIFF_TAG_EXTRA_SAMPLES:
            tagId = 338;
            break;
        case TIFF_TAG_FILL_ORDER:
            tagId = 266;
            break;
        case TIFF_TAG_FREE_BYTE_COUNTS:
            tagId = 289;
            break;
        case TIFF_TAG_FREE_OFFSETS:
            tagId = 288;
            break;
        case TIFF_TAG_GRAY_RESPONSE_CURVE:
            tagId = 291;
            break;
        case TIFF_TAG_GRAY_RESPONSE_UNIT:
            tagId = 290;
            break;
        case TIFF_TAG_HOST_COMPUTER:
            tagId = 316;
            break;
        case TIFF_TAG_IMAGE_DESCRIPTION:
            tagId = 270;
            break;
        case TIFF_TAG_IMAGE_LENGTH:
            tagId = 257;
            break;
        case TIFF_TAG_IMAGE_WIDTH:
            tagId = 256;
            break;
        case TIFF_TAG_MAKE:
            tagId = 271;
            break;
        case TIFF_TAG_MAX_SAMPLE_VALUE:
            tagId = 281;
            break;
        case TIFF_TAG_MIN_SAMPLE_VALUE:
            tagId = 280;
            break;
        case TIFF_TAG_MODEL:
            tagId = 272;
            break;
        case TIFF_TAG_NEW_SUBFILE_TYPE:
            tagId = 254;
            break;
        case TIFF_TAG_ORIENTATION:
            tagId = 274;
            break;
        case TIFF_TAG_PHOTOMETRIC_INTERPRETATION:
            tagId = 262;
            break;
        case TIFF_TAG_PLANAR_CONFIGURATION:
            tagId = 284;
            break;
        case TIFF_TAG_RESOLUTION_UNIT:
            tagId = 296;
            break;
        case TIFF_TAG_ROWS_PER_STRIP:
            tagId = 278;
            break;
        case TIFF_TAG_SAMPLES_PER_PIXEL:
            tagId = 277;
            break;
        case TIFF_TAG_SOFTWARE:
            tagId = 305;
            break;
        case TIFF_TAG_STRIP_BYTE_COUNTS:
            tagId = 279;
            break;
        case TIFF_TAG_STRIP_OFFSETS:
            tagId = 273;
            break;
        case TIFF_TAG_SUBFILE_TYPE:
            tagId = 255;
            break;
        case TIFF_TAG_THRESHOLDING:
            tagId = 263;
            break;
        case TIFF_TAG_X_RESOLUTION:
            tagId = 282;
            break;
        case TIFF_TAG_Y_RESOLUTION:
            tagId = 283;
            break;
        case TIFF_TAG_BAD_FAX_LINES:
            tagId = 326;
            break;
        case TIFF_TAG_CLEAN_FAX_DATA:
            tagId = 327;
            break;
        case TIFF_TAG_CLIP_PATH:
            tagId = 343;
            break;
        case TIFF_TAG_CONSECUTIVE_BAD_FAX_LINES:
            tagId = 328;
            break;
        case TIFF_TAG_DECODE:
            tagId = 433;
            break;
        case TIFF_TAG_DEFAULT_IMAGE_COLOR:
            tagId = 434;
            break;
        case TIFF_TAG_DOCUMENT_NAME:
            tagId = 269;
            break;
        case TIFF_TAG_DOT_RANGE:
            tagId = 336;
            break;
        case TIFF_TAG_HALFTONE_HINTS:
            tagId = 321;
            break;
        case TIFF_TAG_INDEXED:
            tagId = 346;
            break;
        case TIFF_TAG_JPEG_TABLES:
            tagId = 347;
            break;
        case TIFF_TAG_PAGE_NAME:
            tagId = 285;
            break;
        case TIFF_TAG_PAGE_NUMBER:
            tagId = 297;
            break;
        case TIFF_TAG_PREDICTOR:
            tagId = 317;
            break;
        case TIFF_TAG_PRIMARY_CHROMATICITIES:
            tagId = 319;
            break;
        case TIFF_TAG_REFERENCE_BLACK_WHITE:
            tagId = 532;
            break;
        case TIFF_TAG_SAMPLE_FORMAT:
            tagId = 339;
            break;
        case TIFF_TAG_S_MIN_SAMPLE_VALUE:
            tagId = 340;
            break;
        case TIFF_TAG_S_MAX_SAMPLE_VALUE:
            tagId = 341;
            break;
        case TIFF_TAG_STRIP_ROW_COUNTS:
            tagId = 559;
            break;
        case TIFF_TAG_SUB_IFDS:
            tagId = 330;
            break;
        case TIFF_TAG_T4_OPTIONS:
            tagId = 292;
            break;
        case TIFF_TAG_T6_OPTIONS:
            tagId = 293;
            break;
        case TIFF_TAG_TILE_BYTE_COUNTS:
            tagId = 325;
            break;
        case TIFF_TAG_TILE_LENGTH:
            tagId = 323;
            break;
        case TIFF_TAG_TILE_OFFSETS:
            tagId = 324;
            break;
        case TIFF_TAG_TILE_WIDTH:
            tagId = 322;
            break;
        case TIFF_TAG_TRANSFER_FUNCTION:
            tagId = 301;
            break;
        case TIFF_TAG_WHITE_POINT:
            tagId = 318;
            break;
        case TIFF_TAG_X_CLIP_PATH_UNITS:
            tagId = 344;
            break;
        case TIFF_TAG_X_POSITION:
            tagId = 286;
            break;
        case TIFF_TAG_Y_CB_CR_COEFFICIENTS:
            tagId = 529;
            break;
        case TIFF_TAG_Y_CB_CR_POSITIONING:
            tagId = 531;
            break;
        case TIFF_TAG_Y_CB_CR_SUB_SAMPLING:
            tagId = 530;
            break;
        case TIFF_TAG_Y_CLIP_PATH_UNITS:
            tagId = 345;
            break;
        case TIFF_TAG_Y_POSITION:
            tagId = 287;
            break;
        case TIFF_TAG_APERTURE_VALUE:
            tagId = 37378;
            break;
        case TIFF_TAG_COLOR_SPACE:
            tagId = 40961;
            break;
        case TIFF_TAG_DATE_TIME_DIGITIZED:
            tagId = 36868;
            break;
        case TIFF_TAG_DATE_TIME_ORIGINAL:
            tagId = 36867;
            break;
        case TIFF_TAG_EXIF_IFD:
            tagId = 34665;
            break;
        case TIFF_TAG_EXIF_VERSION:
            tagId = 36864;
            break;
        case TIFF_TAG_EXPOSURE_TIME:
            tagId = 33434;
            break;
        case TIFF_TAG_FILE_SOURCE:
            tagId = 41728;
            break;
        case TIFF_TAG_FLASH:
            tagId = 37385;
            break;
        case TIFF_TAG_FLASHPIX_VERSION:
            tagId = 40960;
            break;
        case TIFF_TAG_F_NUMBER:
            tagId = 33437;
            break;
        case TIFF_TAG_IMAGE_UNIQUE_ID:
            tagId = 42016;
            break;
        case TIFF_TAG_LIGHT_SOURCE:
            tagId = 37384;
            break;
        case TIFF_TAG_MAKER_NOTE:
            tagId = 37500;
            break;
        case TIFF_TAG_SHUTTER_SPEED_VALUE:
            tagId = 37377;
            break;
        case TIFF_TAG_USER_COMMENT:
            tagId = 37510;
            break;
        case TIFF_TAG_IPTC:
            tagId = 33723;
            break;
        case TIFF_TAG_ICC_PROFILE:
            tagId = 34675;
            break;
        case TIFF_TAG_XMP:
            tagId = 700;
            break;
        case TIFF_TAG_GDAL_METADATA:
            tagId = 42112;
            break;
        case TIFF_TAG_GDAL_NODATA:
            tagId = 42113;
            break;
        case TIFF_TAG_PHOTOSHOP:
            tagId = 34377;
            break;
        case TIFF_TAG_MODEL_PIXEL_SCALE:
            tagId = 33550;
            break;
        case TIFF_TAG_MODEL_TIEPOINT:
            tagId = 33922;
            break;
        case TIFF_TAG_MODEL_TRANSFORMATION:
            tagId = 34264;
            break;
        case TIFF_TAG_GEO_KEY_DIRECTORY:
            tagId = 34735;
            break;
        case TIFF_TAG_GEO_DOUBLE_PARAMS:
            tagId = 34736;
            break;
        case TIFF_TAG_GEO_ASCII_PARAMS:
            tagId = 34737;
            break;
        default:
            [NSException raise:@"Unsupported Field Tag" format:@"Unsupported Field Tag Type %u", fieldTagType];
            break;
    }
    
    return tagId;
}

+(int) isArray: (enum TIFFFieldTagType) fieldTagType{
    
    BOOL array = false;
    
    switch (fieldTagType) {
        case TIFF_TAG_ARTIST:
        case TIFF_TAG_CELL_LENGTH:
        case TIFF_TAG_CELL_WIDTH:
        case TIFF_TAG_COLOR_MAP:
        case TIFF_TAG_COMPRESSION:
        case TIFF_TAG_COPYRIGHT:
        case TIFF_TAG_DATE_TIME:
        case TIFF_TAG_FILL_ORDER:
        case TIFF_TAG_FREE_BYTE_COUNTS:
        case TIFF_TAG_FREE_OFFSETS:
        case TIFF_TAG_GRAY_RESPONSE_CURVE:
        case TIFF_TAG_GRAY_RESPONSE_UNIT:
        case TIFF_TAG_HOST_COMPUTER:
        case TIFF_TAG_IMAGE_DESCRIPTION:
        case TIFF_TAG_IMAGE_LENGTH:
        case TIFF_TAG_IMAGE_WIDTH:
        case TIFF_TAG_MAKE:
        case TIFF_TAG_MAX_SAMPLE_VALUE:
        case TIFF_TAG_MIN_SAMPLE_VALUE:
        case TIFF_TAG_MODEL:
        case TIFF_TAG_NEW_SUBFILE_TYPE:
        case TIFF_TAG_ORIENTATION:
        case TIFF_TAG_PHOTOMETRIC_INTERPRETATION:
        case TIFF_TAG_PLANAR_CONFIGURATION:
        case TIFF_TAG_RESOLUTION_UNIT:
        case TIFF_TAG_ROWS_PER_STRIP:
        case TIFF_TAG_SAMPLES_PER_PIXEL:
        case TIFF_TAG_SOFTWARE:
        case TIFF_TAG_SUBFILE_TYPE:
        case TIFF_TAG_THRESHOLDING:
        case TIFF_TAG_X_RESOLUTION:
        case TIFF_TAG_Y_RESOLUTION:
        case TIFF_TAG_BAD_FAX_LINES:
        case TIFF_TAG_CLEAN_FAX_DATA:
        case TIFF_TAG_CLIP_PATH:
        case TIFF_TAG_CONSECUTIVE_BAD_FAX_LINES:
        case TIFF_TAG_DECODE:
        case TIFF_TAG_DEFAULT_IMAGE_COLOR:
        case TIFF_TAG_DOCUMENT_NAME:
        case TIFF_TAG_DOT_RANGE:
        case TIFF_TAG_HALFTONE_HINTS:
        case TIFF_TAG_INDEXED:
        case TIFF_TAG_JPEG_TABLES:
        case TIFF_TAG_PAGE_NAME:
        case TIFF_TAG_PAGE_NUMBER:
        case TIFF_TAG_PREDICTOR:
        case TIFF_TAG_PRIMARY_CHROMATICITIES:
        case TIFF_TAG_REFERENCE_BLACK_WHITE:
        case TIFF_TAG_S_MIN_SAMPLE_VALUE:
        case TIFF_TAG_S_MAX_SAMPLE_VALUE:
        case TIFF_TAG_SUB_IFDS:
        case TIFF_TAG_T4_OPTIONS:
        case TIFF_TAG_T6_OPTIONS:
        case TIFF_TAG_TILE_LENGTH:
        case TIFF_TAG_TILE_WIDTH:
        case TIFF_TAG_TRANSFER_FUNCTION:
        case TIFF_TAG_WHITE_POINT:
        case TIFF_TAG_X_CLIP_PATH_UNITS:
        case TIFF_TAG_X_POSITION:
        case TIFF_TAG_Y_CB_CR_COEFFICIENTS:
        case TIFF_TAG_Y_CB_CR_POSITIONING:
        case TIFF_TAG_Y_CB_CR_SUB_SAMPLING:
        case TIFF_TAG_Y_CLIP_PATH_UNITS:
        case TIFF_TAG_Y_POSITION:
        case TIFF_TAG_APERTURE_VALUE:
        case TIFF_TAG_COLOR_SPACE:
        case TIFF_TAG_DATE_TIME_DIGITIZED:
        case TIFF_TAG_DATE_TIME_ORIGINAL:
        case TIFF_TAG_EXIF_IFD:
        case TIFF_TAG_EXIF_VERSION:
        case TIFF_TAG_EXPOSURE_TIME:
        case TIFF_TAG_FILE_SOURCE:
        case TIFF_TAG_FLASH:
        case TIFF_TAG_FLASHPIX_VERSION:
        case TIFF_TAG_F_NUMBER:
        case TIFF_TAG_IMAGE_UNIQUE_ID:
        case TIFF_TAG_LIGHT_SOURCE:
        case TIFF_TAG_MAKER_NOTE:
        case TIFF_TAG_SHUTTER_SPEED_VALUE:
        case TIFF_TAG_USER_COMMENT:
        case TIFF_TAG_IPTC:
        case TIFF_TAG_ICC_PROFILE:
        case TIFF_TAG_XMP:
        case TIFF_TAG_GDAL_METADATA:
        case TIFF_TAG_GDAL_NODATA:
        case TIFF_TAG_PHOTOSHOP:
        case TIFF_TAG_MODEL_PIXEL_SCALE:
        case TIFF_TAG_MODEL_TIEPOINT:
        case TIFF_TAG_MODEL_TRANSFORMATION:
        case TIFF_TAG_GEO_KEY_DIRECTORY:
        case TIFF_TAG_GEO_DOUBLE_PARAMS:
        case TIFF_TAG_GEO_ASCII_PARAMS:
            array = false;
            break;
            
        case TIFF_TAG_BITS_PER_SAMPLE:
        case TIFF_TAG_EXTRA_SAMPLES:
        case TIFF_TAG_STRIP_BYTE_COUNTS:
        case TIFF_TAG_STRIP_OFFSETS:
        case TIFF_TAG_SAMPLE_FORMAT:
        case TIFF_TAG_STRIP_ROW_COUNTS:
        case TIFF_TAG_TILE_BYTE_COUNTS:
        case TIFF_TAG_TILE_OFFSETS:
            array = true;
            break;
            
        default:
            [NSException raise:@"Unsupported Field Tag" format:@"Unsupported Field Tag Type %u", fieldTagType];
            break;
    }
    
    return array;

}

+(enum TIFFFieldTagType) typeByTagId: (int) tagId{
    
    enum TIFFFieldTagType fieldTagType;
    
    switch (tagId) {
        case 315:
            fieldTagType = TIFF_TAG_ARTIST;
            break;
        case 258:
            fieldTagType = TIFF_TAG_BITS_PER_SAMPLE;
            break;
        case 265:
            fieldTagType = TIFF_TAG_CELL_LENGTH;
            break;
        case 264:
            fieldTagType = TIFF_TAG_CELL_WIDTH;
            break;
        case 320:
            fieldTagType = TIFF_TAG_COLOR_MAP;
            break;
        case 259:
            fieldTagType = TIFF_TAG_COMPRESSION;
            break;
        case 33432:
            fieldTagType = TIFF_TAG_COPYRIGHT;
            break;
        case 306:
            fieldTagType = TIFF_TAG_DATE_TIME;
            break;
        case 338:
            fieldTagType = TIFF_TAG_EXTRA_SAMPLES;
            break;
        case 266:
            fieldTagType = TIFF_TAG_FILL_ORDER;
            break;
        case 289:
            fieldTagType = TIFF_TAG_FREE_BYTE_COUNTS;
            break;
        case 288:
            fieldTagType = TIFF_TAG_FREE_OFFSETS;
            break;
        case 291:
            fieldTagType = TIFF_TAG_GRAY_RESPONSE_CURVE;
            break;
        case 290:
            fieldTagType = TIFF_TAG_GRAY_RESPONSE_UNIT;
            break;
        case 316:
            fieldTagType = TIFF_TAG_HOST_COMPUTER;
            break;
        case 270:
            fieldTagType = TIFF_TAG_IMAGE_DESCRIPTION;
            break;
        case 257:
            fieldTagType = TIFF_TAG_IMAGE_LENGTH;
            break;
        case 256:
            fieldTagType = TIFF_TAG_IMAGE_WIDTH;
            break;
        case 271:
            fieldTagType = TIFF_TAG_MAKE;
            break;
        case 281:
            fieldTagType = TIFF_TAG_MAX_SAMPLE_VALUE;
            break;
        case 280:
            fieldTagType = TIFF_TAG_MIN_SAMPLE_VALUE;
            break;
        case 272:
            fieldTagType = TIFF_TAG_MODEL;
            break;
        case 254:
            fieldTagType = TIFF_TAG_NEW_SUBFILE_TYPE;
            break;
        case 274:
            fieldTagType = TIFF_TAG_ORIENTATION;
            break;
        case 262:
            fieldTagType = TIFF_TAG_PHOTOMETRIC_INTERPRETATION;
            break;
        case 284:
            fieldTagType = TIFF_TAG_PLANAR_CONFIGURATION;
            break;
        case 296:
            fieldTagType = TIFF_TAG_RESOLUTION_UNIT;
            break;
        case 278:
            fieldTagType = TIFF_TAG_ROWS_PER_STRIP;
            break;
        case 277:
            fieldTagType = TIFF_TAG_SAMPLES_PER_PIXEL;
            break;
        case 305:
            fieldTagType = TIFF_TAG_SOFTWARE;
            break;
        case 279:
            fieldTagType = TIFF_TAG_STRIP_BYTE_COUNTS;
            break;
        case 273:
            fieldTagType = TIFF_TAG_STRIP_OFFSETS;
            break;
        case 255:
            fieldTagType = TIFF_TAG_SUBFILE_TYPE;
            break;
        case 263:
            fieldTagType = TIFF_TAG_THRESHOLDING;
            break;
        case 282:
            fieldTagType = TIFF_TAG_X_RESOLUTION;
            break;
        case 283:
            fieldTagType = TIFF_TAG_Y_RESOLUTION;
            break;
        case 326:
            fieldTagType = TIFF_TAG_BAD_FAX_LINES;
            break;
        case 327:
            fieldTagType = TIFF_TAG_CLEAN_FAX_DATA;
            break;
        case 343:
            fieldTagType = TIFF_TAG_CLIP_PATH;
            break;
        case 328:
            fieldTagType = TIFF_TAG_CONSECUTIVE_BAD_FAX_LINES;
            break;
        case 433:
            fieldTagType = TIFF_TAG_DECODE;
            break;
        case 434:
            fieldTagType = TIFF_TAG_DEFAULT_IMAGE_COLOR;
            break;
        case 269:
            fieldTagType = TIFF_TAG_DOCUMENT_NAME;
            break;
        case 336:
            fieldTagType = TIFF_TAG_DOT_RANGE;
            break;
        case 321:
            fieldTagType = TIFF_TAG_HALFTONE_HINTS;
            break;
        case 346:
            fieldTagType = TIFF_TAG_INDEXED;
            break;
        case 347:
            fieldTagType = TIFF_TAG_JPEG_TABLES;
            break;
        case 285:
            fieldTagType = TIFF_TAG_PAGE_NAME;
            break;
        case 297:
            fieldTagType = TIFF_TAG_PAGE_NUMBER;
            break;
        case 317:
            fieldTagType = TIFF_TAG_PREDICTOR;
            break;
        case 319:
            fieldTagType = TIFF_TAG_PRIMARY_CHROMATICITIES;
            break;
        case 532:
            fieldTagType = TIFF_TAG_REFERENCE_BLACK_WHITE;
            break;
        case 339:
            fieldTagType = TIFF_TAG_SAMPLE_FORMAT;
            break;
        case 340:
            fieldTagType = TIFF_TAG_S_MIN_SAMPLE_VALUE;
            break;
        case 341:
            fieldTagType = TIFF_TAG_S_MAX_SAMPLE_VALUE;
            break;
        case 559:
            fieldTagType = TIFF_TAG_STRIP_ROW_COUNTS;
            break;
        case 330:
            fieldTagType = TIFF_TAG_SUB_IFDS;
            break;
        case 292:
            fieldTagType = TIFF_TAG_T4_OPTIONS;
            break;
        case 293:
            fieldTagType = TIFF_TAG_T6_OPTIONS;
            break;
        case 325:
            fieldTagType = TIFF_TAG_TILE_BYTE_COUNTS;
            break;
        case 323:
            fieldTagType = TIFF_TAG_TILE_LENGTH;
            break;
        case 324:
            fieldTagType = TIFF_TAG_TILE_OFFSETS;
            break;
        case 322:
            fieldTagType = TIFF_TAG_TILE_WIDTH;
            break;
        case 301:
            fieldTagType = TIFF_TAG_TRANSFER_FUNCTION;
            break;
        case 318:
            fieldTagType = TIFF_TAG_WHITE_POINT;
            break;
        case 344:
            fieldTagType = TIFF_TAG_X_CLIP_PATH_UNITS;
            break;
        case 286:
            fieldTagType = TIFF_TAG_X_POSITION;
            break;
        case 529:
            fieldTagType = TIFF_TAG_Y_CB_CR_COEFFICIENTS;
            break;
        case 531:
            fieldTagType = TIFF_TAG_Y_CB_CR_POSITIONING;
            break;
        case 530:
            fieldTagType = TIFF_TAG_Y_CB_CR_SUB_SAMPLING;
            break;
        case 345:
            fieldTagType = TIFF_TAG_Y_CLIP_PATH_UNITS;
            break;
        case 287:
            fieldTagType = TIFF_TAG_Y_POSITION;
            break;
        case 37378:
            fieldTagType = TIFF_TAG_APERTURE_VALUE;
            break;
        case 40961:
            fieldTagType = TIFF_TAG_COLOR_SPACE;
            break;
        case 36868:
            fieldTagType = TIFF_TAG_DATE_TIME_DIGITIZED;
            break;
        case 36867:
            fieldTagType = TIFF_TAG_DATE_TIME_ORIGINAL;
            break;
        case 34665:
            fieldTagType = TIFF_TAG_EXIF_IFD;
            break;
        case 36864:
            fieldTagType = TIFF_TAG_EXIF_VERSION;
            break;
        case 33434:
            fieldTagType = TIFF_TAG_EXPOSURE_TIME;
            break;
        case 41728:
            fieldTagType = TIFF_TAG_FILE_SOURCE;
            break;
        case 37385:
            fieldTagType = TIFF_TAG_FLASH;
            break;
        case 40960:
            fieldTagType = TIFF_TAG_FLASHPIX_VERSION;
            break;
        case 33437:
            fieldTagType = TIFF_TAG_F_NUMBER;
            break;
        case 42016:
            fieldTagType = TIFF_TAG_IMAGE_UNIQUE_ID;
            break;
        case 37384:
            fieldTagType = TIFF_TAG_LIGHT_SOURCE;
            break;
        case 37500:
            fieldTagType = TIFF_TAG_MAKER_NOTE;
            break;
        case 37377:
            fieldTagType = TIFF_TAG_SHUTTER_SPEED_VALUE;
            break;
        case 37510:
            fieldTagType = TIFF_TAG_USER_COMMENT;
            break;
        case 33723:
            fieldTagType = TIFF_TAG_IPTC;
            break;
        case 34675:
            fieldTagType = TIFF_TAG_ICC_PROFILE;
            break;
        case 700:
            fieldTagType = TIFF_TAG_XMP;
            break;
        case 42112:
            fieldTagType = TIFF_TAG_GDAL_METADATA;
            break;
        case 42113:
            fieldTagType = TIFF_TAG_GDAL_NODATA;
            break;
        case 34377:
            fieldTagType = TIFF_TAG_PHOTOSHOP;
            break;
        case 33550:
            fieldTagType = TIFF_TAG_MODEL_PIXEL_SCALE;
            break;
        case 33922:
            fieldTagType = TIFF_TAG_MODEL_TIEPOINT;
            break;
        case 34264:
            fieldTagType = TIFF_TAG_MODEL_TRANSFORMATION;
            break;
        case 34735:
            fieldTagType = TIFF_TAG_GEO_KEY_DIRECTORY;
            break;
        case 34736:
            fieldTagType = TIFF_TAG_GEO_DOUBLE_PARAMS;
            break;
        case 34737:
            fieldTagType = TIFF_TAG_GEO_ASCII_PARAMS;
            break;
        default:
            [NSException raise:@"Unsupported Field Tag Id" format:@"Unsupported Field Tag Id %d", tagId];
            break;
    }
    
    return tagId;
}

@end
