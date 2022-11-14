//
//  GPKGDgiwgFileName.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgFileName.h"
#import "GPKGGeoPackageConstants.h"

NSString * const GPKG_DGIWG_FN_DELIMITER_ELEMENTS = @"_";
NSString * const GPKG_DGIWG_FN_DELIMITER_WORDS = @"-";
NSString * const GPKG_DGIWG_FN_DELIMITER_SCALE = @":";
NSString * const GPKG_DGIWG_FN_VERSION_PREFIX = @"v";
NSString * const GPKG_DGIWG_FN_DATE_FORMAT = @"ddMMMyyyy";

@interface GPKGDgiwgFileName ()

/**
 *  Zoom Level Part 1, min zoom or scale map units
 */
@property (nonatomic, strong) NSNumber *zoomLevel1;

/**
 *  Zoom Level Part 2, max zoom or scale surface units
 */
@property (nonatomic, strong) NSNumber *zoomLevel2;

/**
 *  Major version
 */
@property (nonatomic, strong) NSNumber *majorVersion;

/**
 *  Minor version
 */
@property (nonatomic, strong) NSNumber *minorVersion;

@end

@implementation GPKGDgiwgFileName

-(instancetype) init{
    self = [super init];
    return self;
}

-(instancetype) initWithName: (NSString *) name{
    self = [super init];
    if(self != nil){

        name = [[name lastPathComponent] stringByDeletingPathExtension];

        NSArray<NSString *> *elements = [name componentsSeparatedByString:GPKG_DGIWG_FN_DELIMITER_ELEMENTS];

        for(int i = 0; i < elements.count; i++){

            NSString *value = [elements objectAtIndex:i];

            switch (i) {

                case 0:
                    _producer = [self delimitersToSpaces:value];
                    break;

                case 1:
                    _dataProduct = [self delimitersToSpaces:value];
                    break;

                case 2:
                    _geographicCoverageArea = [self delimitersToSpaces:value];
                    break;

                case 3:
                    [self setZoomLevels:value];
                    break;

                case 4:
                    [self setVersion:value];
                    break;

                case 5:
                    [self setCreationDateText:value];
                    break;

                case 6:
                    _additional = [NSMutableArray array];

                default:
                    [_additional addObject:[self delimitersToSpaces:value]];
                    break;
            }

        }

    }
    return self;
}

-(void) setZoomLevels: (NSString *) zoomLevels{
    _zoomLevels = zoomLevels;

    NSArray<NSString *> *parts = [zoomLevels componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@":%@", GPKG_DGIWG_FN_DELIMITER_WORDS]]];
    if(parts.count == 2){

        NSString *zoom1 = [parts objectAtIndex:0];
        NSString *zoom2 = [parts objectAtIndex:1];

        NSNumber *zoomLevel1 = [self toInteger:zoom1];
        NSNumber *zoomLevel2 = [self toInteger:zoom2];

        if(zoomLevel1 != nil && zoomLevel2 != nil){
            _zoomLevel1 = zoomLevel1;
            _zoomLevel2 = zoomLevel2;
            NSString *delimiter = GPKG_DGIWG_FN_DELIMITER_SCALE;
            if([zoomLevel1 intValue] >= 0 && [zoomLevel2 intValue] <= 28){
                delimiter = GPKG_DGIWG_FN_DELIMITER_WORDS;
            }
            _zoomLevels = [NSString stringWithFormat:@"%@%@%@", zoomLevel1, delimiter, zoomLevel2];
        }else{
            _zoomLevels = [self delimitersToSpaces:zoomLevels];
        }

    }else{
        _zoomLevels = [self delimitersToSpaces:zoomLevels];
    }
    
}

-(NSNumber *) zoomLevel1{
    return _zoomLevel1;
}

-(BOOL) hasZoomLevel1{
    return _zoomLevel1 != nil;
}

-(NSNumber *) zoomLevel2{
    return _zoomLevel2;

}

-(BOOL) hasZoomLevel2{
    return _zoomLevel2 != nil;
}

-(void) setZoomLevelRangeWithMin: (int) minZoom andMax: (int) maxZoom{
    _zoomLevel1 = [NSNumber numberWithInt:minZoom];
    _zoomLevel2 = [NSNumber numberWithInt:maxZoom];
    _zoomLevels = [NSString stringWithFormat:@"%d%@%d", minZoom, GPKG_DGIWG_FN_DELIMITER_WORDS, maxZoom];
}

-(void) setZoomLevelScaleWithMapUnits: (int) mapUnits andSurfaceUnits: (int) surfaceUnits{
    _zoomLevel1 = [NSNumber numberWithInt:mapUnits];
    _zoomLevel2 = [NSNumber numberWithInt:surfaceUnits];
    _zoomLevels = [NSString stringWithFormat:@"%d%@%d", mapUnits, GPKG_DGIWG_FN_DELIMITER_SCALE, surfaceUnits];
}

-(void) setVersion: (NSString *) version{
    
    NSArray<NSString *> *parts = [version componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@".%@", GPKG_DGIWG_FN_DELIMITER_WORDS]]];
    if(parts.count == 2){

        NSString *major = [parts objectAtIndex:0];
        if([major hasPrefix:GPKG_DGIWG_FN_VERSION_PREFIX]){
            major = [major substringFromIndex:1];
        }
        NSString *minor = [parts objectAtIndex:1];

        NSNumber *majorVersion = [self toInteger:major];
        NSNumber *minorVersion = [self toInteger:minor];

        if(majorVersion != nil && minorVersion != nil){
            _majorVersion = majorVersion;
            _minorVersion = minorVersion;
            _version = [NSString stringWithFormat:@"%@.%@", majorVersion, minorVersion];
        }else{
            _version = [self delimitersToSpaces:version];
        }

    }else{
        _version = [self delimitersToSpaces:version];
    }
    
}

-(NSNumber *) majorVersion{
    return _majorVersion;
}

-(BOOL) hasMajorVersion{
    return _majorVersion != nil;
}

-(NSNumber *) minorVersion{
    return _minorVersion;
}

-(BOOL) hasMinorVersion{
    return _minorVersion != nil;
}

-(void) setVersionWithMajor: (int) majorVersion andMinor: (int) minorVersion{
    _majorVersion = [NSNumber numberWithInt:majorVersion];
    _minorVersion = [NSNumber numberWithInt:minorVersion];
    _version = [NSString stringWithFormat:@"%d.%d", majorVersion, minorVersion];
}

-(void) setCreationDateText: (NSString *) creationDateText{
    // TODO
}

-(void) setCreationDate: (NSDate *) creationDate{
    // TODO
}

-(BOOL) hasAdditional{
    return _additional != nil && _additional.count > 0;
}

-(void) addAdditional: (NSString *) additional{
    if(_additional == nil){
        _additional = [NSMutableArray array];
    }
    [_additional addObject:additional];
}

-(BOOL) isInformative{
    return _producer != nil && _dataProduct != nil && _geographicCoverageArea != nil && _zoomLevels != nil && _version != nil && _creationDateText != nil;
}

-(NSString *) name{
    return [self description];
}

-(NSString *) nameWithExtension{
    return [[self name] stringByAppendingPathExtension:GPKG_EXTENSION];
}

-(NSString *) delimitersToSpaces: (NSString *) value{
    value = [value stringByReplacingOccurrencesOfString:GPKG_DGIWG_FN_DELIMITER_WORDS withString:@" "];
    return [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

/**
 * Attempt to convert a value to an integer
 *
 * @param value
 *            string value
 * @return integer or null
 */
-(NSNumber *) toInteger: (NSString *) value{
    NSNumber *integer = nil;
    if(value != nil &&
       [[NSCharacterSet decimalDigitCharacterSet] isSupersetOfSet:
        [NSCharacterSet characterSetWithCharactersInString:value]]){
            integer = [NSNumber numberWithInt:[value intValue]];
    }
    return integer;
}

-(NSString *) description{
    // TODO
    return @"";
}

// TODO

@end
