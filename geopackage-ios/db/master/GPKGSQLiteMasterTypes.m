//
//  GPKGSQLiteMasterTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/26/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGSQLiteMasterTypes.h"
#import "GPKGUtils.h"

NSString * const GPKG_SMT_TABLE_NAME = @"TABLE";
NSString * const GPKG_SMT_INDEX_NAME = @"INDEX";
NSString * const GPKG_SMT_VIEW_NAME = @"VIEW";
NSString * const GPKG_SMT_TRIGGER_NAME = @"TRIGGER";

@implementation GPKGSQLiteMasterTypes

+(NSString *) name: (enum GPKGSQLiteMasterType) type{
    NSString * name = nil;
    
    switch(type){
        case GPKG_SMT_TABLE:
            name = GPKG_SMT_TABLE_NAME;
            break;
        case GPKG_SMT_INDEX:
            name = GPKG_SMT_INDEX_NAME;
            break;
        case GPKG_SMT_VIEW:
            name = GPKG_SMT_VIEW_NAME;
            break;
        case GPKG_SMT_TRIGGER:
            name = GPKG_SMT_TRIGGER_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGSQLiteMasterType) fromName: (NSString *) name{
    enum GPKGSQLiteMasterType value = -1;
    
    if(name != nil){
        name = [name uppercaseString];
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:GPKG_SMT_TABLE], GPKG_SMT_TABLE_NAME,
                               [NSNumber numberWithInteger:GPKG_SMT_INDEX], GPKG_SMT_INDEX_NAME,
                               [NSNumber numberWithInteger:GPKG_SMT_VIEW], GPKG_SMT_VIEW_NAME,
                               [NSNumber numberWithInteger:GPKG_SMT_TRIGGER], GPKG_SMT_TRIGGER_NAME,
                               nil
                               ];
        NSNumber *enumValue = [GPKGUtils objectForKey:name inDictionary:types];
        if(enumValue != nil){
            value = (enum GPKGSQLiteMasterType)[enumValue intValue];
        }
    }
    
    return value;
}

@end
