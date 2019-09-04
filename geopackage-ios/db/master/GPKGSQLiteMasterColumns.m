//
//  GPKGSQLiteMasterColumns.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/26/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGSQLiteMasterColumns.h"
#import "GPKGUtils.h"

NSString * const GPKG_SMC_TYPE_NAME = @"TYPE";
NSString * const GPKG_SMC_NAME_NAME = @"NAME";
NSString * const GPKG_SMC_TBL_NAME_NAME = @"TBL_NAME";
NSString * const GPKG_SMC_ROOTPAGE_NAME = @"ROOTPAGE";
NSString * const GPKG_SMC_SQL_NAME = @"SQL";

@implementation GPKGSQLiteMasterColumns

+(NSString *) name: (enum GPKGSQLiteMasterColumn) type{
    NSString * name = nil;
    
    switch(type){
        case GPKG_SMC_TYPE:
            name = GPKG_SMC_TYPE_NAME;
            break;
        case GPKG_SMC_NAME:
            name = GPKG_SMC_NAME_NAME;
            break;
        case GPKG_SMC_TBL_NAME:
            name = GPKG_SMC_TBL_NAME_NAME;
            break;
        case GPKG_SMC_ROOTPAGE:
            name = GPKG_SMC_ROOTPAGE_NAME;
            break;
        case GPKG_SMC_SQL:
            name = GPKG_SMC_SQL_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGSQLiteMasterColumn) fromName: (NSString *) name{
    enum GPKGSQLiteMasterType value = -1;
    
    if(name != nil){
        name = [name uppercaseString];
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:GPKG_SMC_TYPE], GPKG_SMC_TYPE_NAME,
                               [NSNumber numberWithInteger:GPKG_SMC_NAME], GPKG_SMC_NAME_NAME,
                               [NSNumber numberWithInteger:GPKG_SMC_TBL_NAME], GPKG_SMC_TBL_NAME_NAME,
                               [NSNumber numberWithInteger:GPKG_SMC_ROOTPAGE], GPKG_SMC_ROOTPAGE_NAME,
                               [NSNumber numberWithInteger:GPKG_SMC_SQL], GPKG_SMC_SQL_NAME,
                               nil
                               ];
        NSNumber *enumValue = [GPKGUtils objectForKey:name inDictionary:types];
        if(enumValue != nil){
            value = (enum GPKGSQLiteMasterType)[enumValue intValue];
        }
    }
    
    return value;
}

+(NSArray<NSNumber *> *) values{
    return [NSArray arrayWithObjects:
            [NSNumber numberWithInteger:GPKG_SMC_TYPE],
            [NSNumber numberWithInteger:GPKG_SMC_NAME],
            [NSNumber numberWithInteger:GPKG_SMC_TBL_NAME],
            [NSNumber numberWithInteger:GPKG_SMC_ROOTPAGE],
            [NSNumber numberWithInteger:GPKG_SMC_SQL],
            nil];
}

@end
