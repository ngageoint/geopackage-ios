//
//  GPKGDgiwgFileName.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgFileName.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGDateConverter.h"

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
    _creationDateText = creationDateText;
    GPKGDateConverter *formatter = [self dateConverter];
    _creationDate = [formatter dateValue:creationDateText];
}

-(void) setCreationDate: (NSDate *) creationDate{
    _creationDate = creationDate;
    GPKGDateConverter *formatter = [self dateConverter];
    _creationDateText = [formatter stringValue:creationDate];
    if(_creationDateText != nil){
        _creationDateText = [_creationDateText uppercaseString];
    }
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

/**
 * Get a date converter
 *
 * @return date converter
 */
-(GPKGDateConverter *) dateConverter{
    GPKGDateConverter *converter = [GPKGDateConverter createWithFormats:[NSArray arrayWithObjects:GPKG_DGIWG_FN_DATE_FORMAT, GPKG_DTU_DATE_FORMAT, GPKG_DTU_DATE_FORMAT2, nil]];
    converter.expected = NO;
    return converter;
}

/**
 * Add a value to the description string
 *
 * @param value
 *            string value
 * @param description
 *            description
 */
-(void) addValue: (NSString *) value toDescription: (NSMutableString *) description{
    if(value != nil){
        [self addDelimiter:description];
        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        value = [value stringByReplacingOccurrencesOfString:@" " withString:GPKG_DGIWG_FN_DELIMITER_WORDS];
        [description appendString:value];
    }
}

/**
 * Add an element delimiter
 *
 * @param builder
 *            string builder
 */
-(void) addDelimiter: (NSMutableString *) description{
    if(description.length > 0){
        [description appendString:GPKG_DGIWG_FN_DELIMITER_ELEMENTS];
    }
}

-(NSString *) description{
    NSMutableString *description = [NSMutableString string];
    [self addValue:_producer toDescription:description];
    [self addValue:_dataProduct toDescription:description];
    [self addValue:_geographicCoverageArea toDescription:description];
    if(_zoomLevel1 != nil){
        [self addDelimiter:description];
        [description appendFormat:@"%@", _zoomLevel1];
        if(_zoomLevel2 != nil){
            [description appendString:GPKG_DGIWG_FN_DELIMITER_WORDS];
            [description appendFormat:@"%@", _zoomLevel2];
        }
    }else{
        [self addValue:_zoomLevels toDescription:description];
    }
    if(_majorVersion != nil){
        [self addDelimiter:description];
        [description appendString:GPKG_DGIWG_FN_VERSION_PREFIX];
        [description appendFormat:@"%@", _majorVersion];
        if(_minorVersion != nil){
            [description appendString:GPKG_DGIWG_FN_DELIMITER_WORDS];
            [description appendFormat:@"%@", _minorVersion];
        }
    }else{
        [self addValue:_version toDescription:description];
    }
    [self addValue:_creationDateText toDescription:description];
    if(_additional != nil){
        for(NSString *value in _additional){
            [self addValue:value toDescription:description];
        }
    }
    return description;
}

- (BOOL) isEqual: (id) object{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[GPKGDgiwgFileName class]]) {
        return NO;
    }
    
    return [[self description] isEqualToString:[((GPKGDgiwgFileName *)object) description]];
}

- (NSUInteger) hash{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [[self description] hash];
    return result;
}

@end
