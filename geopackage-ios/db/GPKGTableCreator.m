//
//  GPKGTableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTableCreator.h"
#import "GPKGIOUtils.h"
#import "GPKGGeoPackageConstants.h"

@implementation GPKGTableCreator

-(instancetype)initWithDatabase:(GPKGConnection *) db{
    self = [super init];
    if(self){
        self.db = db;
    }
    return self;
}

-(int) createTable: (NSString *) tableName{
    
    NSString * tablesProperties = [GPKGIOUtils getPropertyListPathWithName:GPKG_GEO_PACKAGE_RESOURCES_TABLES];
    
    NSDictionary *tables = [NSDictionary dictionaryWithContentsOfFile:tablesProperties];
    NSArray *statements = [tables objectForKey:tableName];
    if(statements == nil){
        [NSException raise:@"Table Creation" format:@"Failed to find table creation statements for table: %@, in resource: %@", tableName, GPKG_GEO_PACKAGE_RESOURCES_TABLES];
    }
    
    for(NSString * statement in statements){
        [self.db exec:statement];
    }
    return (int)[statements count];
}

@end
