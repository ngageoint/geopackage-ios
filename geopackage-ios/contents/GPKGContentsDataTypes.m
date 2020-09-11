//
//  GPKGContentsDataTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/31/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGContentsDataTypes.h"
#import "GPKGUtils.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"

NSString * const GPKG_CDT_FEATURES_NAME = @"features";
NSString * const GPKG_CDT_TILES_NAME = @"tiles";
NSString * const GPKG_CDT_ATTRIBUTES_NAME = @"attributes";

@implementation GPKGContentsDataTypes

static NSMutableSet<NSString *> *coreTypes = nil;
static NSMutableDictionary<NSString *, NSNumber *> *types = nil;

+(void) initialize{
    if(coreTypes == nil){
        types = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInteger:GPKG_CDT_FEATURES], GPKG_CDT_FEATURES_NAME,
            [NSNumber numberWithInteger:GPKG_CDT_TILES], GPKG_CDT_TILES_NAME,
            [NSNumber numberWithInteger:GPKG_CDT_ATTRIBUTES], GPKG_CDT_ATTRIBUTES_NAME,
            nil
            ];
        coreTypes = [NSMutableSet setWithArray:[types allKeys]];
    }
}

+(NSString *) name: (enum GPKGContentsDataType) contentsDataType{
    NSString * name = nil;
    
    switch(contentsDataType){
        case GPKG_CDT_FEATURES:
            name = GPKG_CDT_FEATURES_NAME;
            break;
        case GPKG_CDT_TILES:
            name = GPKG_CDT_TILES_NAME;
            break;
        case GPKG_CDT_ATTRIBUTES:
            name = GPKG_CDT_ATTRIBUTES_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGContentsDataType) fromName: (NSString *) name{
    
    enum GPKGContentsDataType dataType = -1;
    
    if(name != nil){
        
        NSString *lowerName = [name lowercaseString];
        NSNumber *dataTypeNumber = [types objectForKey:lowerName];
        
        if(dataTypeNumber == nil){
            
            NSDictionary *dataTypeProperties = [GPKGProperties dictionaryValueOfProperty:GPKG_PROP_CONTENTS_DATA_TYPE];
            NSString *value = [dataTypeProperties objectForKey:name];
            if(value != nil){
                
                dataTypeNumber = [GPKGUtils objectForKey:[value lowercaseString] inDictionary:types];
                
                if(dataTypeNumber == nil){
                    NSLog(@"Unsupported configured data type: %@, for contents data type name: %@", value, name);
                }
                
            }
            
            [GPKGUtils setObject:dataTypeNumber forKey:lowerName inDictionary:types];
        }
        
        if(dataTypeNumber != nil && ![dataTypeNumber isEqual:[NSNull null]]){
            dataType = [dataTypeNumber intValue];
        }

    }
    
    return dataType;
}

+(BOOL) isType: (NSString *) name{
    return [self fromName:name] != -1;
}

+(enum GPKGContentsDataType) fromCoreName: (NSString *) name{
    enum GPKGContentsDataType dataType = -1;
    if([self isCoreType:name]){
        dataType = [[types objectForKey:[name lowercaseString]] intValue];
    }
    return dataType;
}

+(BOOL) isCoreType: (NSString *) name{
    BOOL coreType = NO;
    if(name != nil){
        coreType = [coreTypes containsObject:[name lowercaseString]];
    }
    return coreType;
}

+(void) setName: (NSString *) name asType: (enum GPKGContentsDataType) type{
    
    if (name != nil) {

        NSString *lowerName = [name lowercaseString];
        NSNumber *dataTypeNumber = [GPKGUtils objectForKey:lowerName inDictionary:types];

        if (dataTypeNumber == nil) {

            [types setObject:[NSNumber numberWithInt:type] forKey:lowerName];

        } else if ([dataTypeNumber intValue] != type) {

            if([coreTypes containsObject:lowerName]){
                [NSException raise:@"Data Type Changed" format:@"Core contents data type name '%@' can not be changed to type '%@'", name, [GPKGContentsDataTypes name:type]];
            }

            NSLog(@"Changed contents data type name '%@' from type '%@' to type '%@'", name, [GPKGContentsDataTypes name:[dataTypeNumber intValue]], [GPKGContentsDataTypes name:type]);

            [types setObject:[NSNumber numberWithInt:type] forKey:lowerName];
        }

    }
    
}

+(BOOL) isName: (NSString *) name ofType: (enum GPKGContentsDataType) type{
    return [self isName:name ofType:type andMatchUnknown:NO];
}

+(BOOL) isName: (NSString *) name ofType: (enum GPKGContentsDataType) type andMatchUnknown: (BOOL) matchUnknown{
    BOOL isType;
    enum GPKGContentsDataType dataType = [self fromName:name];
    if(dataType != -1){
        isType = dataType == type;
    }else{
        isType = matchUnknown;
    }
    return isType;
}

+(BOOL) isFeaturesType: (NSString *) name{
    return [self isFeaturesType:name andMatchUnknown:NO];
}

+(BOOL) isFeaturesType: (NSString *) name andMatchUnknown: (BOOL) matchUnknown{
    return [self isName:name ofType:GPKG_CDT_FEATURES andMatchUnknown:matchUnknown];
}

+(BOOL) isTilesType: (NSString *) name{
    return [self isTilesType:name andMatchUnknown:NO];
}

 +(BOOL) isTilesType: (NSString *) name andMatchUnknown: (BOOL) matchUnknown{
     return [self isName:name ofType:GPKG_CDT_TILES andMatchUnknown:matchUnknown];
 }

+(BOOL) isAttributesType: (NSString *) name{
    return [self isAttributesType:name andMatchUnknown:NO];
}

 +(BOOL) isAttributesType: (NSString *) name andMatchUnknown: (BOOL) matchUnknown{
     return [self isName:name ofType:GPKG_CDT_ATTRIBUTES andMatchUnknown:matchUnknown];
 }

@end
